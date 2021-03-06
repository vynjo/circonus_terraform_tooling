variable "usage_tags" {
  type = "list"
  default = [
    "app:circonus",
    "author:terraform",
    "source:circonus",
  ]
}

resource "circonus_check" "usage" {
  # collectors = ["${var.collectors}"]
  collector {
    id = "${var.collectors_public[0]}"
  }

  # collector {
  #   id = "${var.collectors[1]}"
  # }

  name       = "${var.check_name}"
  notes      = "${var.check_notes}"

  json {
    url = "https://${var.target}/account/current"

    headers = {
      Accept                = "application/json"
      X-Circonus-App-Name   = "TerraformCheck"
      X-Circonus-Auth-Token = "${var.api_token}"
    }
  }

  stream {
    name = "${circonus_metric.limit.name}"
    tags = ["${circonus_metric.limit.tags}"]
    type = "${circonus_metric.limit.type}"
    unit = "${circonus_metric.limit.unit}"
  }

  stream {
    name = "${circonus_metric.used.name}"
    tags = ["${circonus_metric.used.tags}"]
    type = "${circonus_metric.used.type}"
    unit = "${circonus_metric.used.unit}"
  }

  tags = [ "${var.usage_tags}" ]
}

resource "circonus_metric" "limit" {
  name = "${var.limit_metric_name}"
  type = "numeric"
  unit = "qty"
  tags = [ "${var.usage_tags}" ]
}

resource "circonus_metric" "used" {
  name = "${var.used_metric_name}"
  type = "numeric"
  unit = "qty"
  tags = [ "${var.usage_tags}" ]
}

/*resource "circonus_trigger" "usage-alarm" {
  check = "${circonus_check.usage.checks[0]}"
  stream_name = "${var.used_metric_name}"
  notes = <<EOF
Need to delete old/stale metrics.
EOF
  link = "https://${var.account_name}.circonus.com/profile"
#  parent = "${check cid}"

  if {
    value {
      absent = "3600s"
    }

    then {
      notify = [
        "${circonus_contact_group.circonus-owners-slack.id}",
        "${circonus_contact_group.circonus-owners-slack-escalation.id}",
      ]
      severity = 1
    }
  }

  if {
    value {
      # SEV1 if we're within 95% of our account limit
      more = "${data.circonus_account.current.usage.0.limit * 0.95}"
    }

    then {
      notify = [
        "${circonus_contact_group.circonus-owners-slack.id}",
        "${circonus_contact_group.circonus-owners-slack-escalation.id}",
      ]
      severity = 1
    }
  }

  if {
    value {
      # SEV2 if we're within 85% of our account limit
      more = "${data.circonus_account.current.usage.0.limit * 0.85}"
    }

    then {
      notify = [ "${circonus_contact_group.circonus-owners-slack.id}" ]
      severity = 2
    }
  }

  if {
    value {
      # SEV3 if we're within 75% of our account limit
      more = "${data.circonus_account.current.usage.0.limit * 0.75}"
    }

    then {
      notify = [ "${circonus_contact_group.circonus-owners-slack.id}" ]
      severity = 3
    }
  }

  tags = ["${circonus_metric.limit.tags}"]
}*/
