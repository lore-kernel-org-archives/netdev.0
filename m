From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 08/27] ip: iplink_bond_slave.c: add json output support (info_slave_data)
Date: Thu, 17 Aug 2017 10:35:55 -0700
Message-ID: <20170817173614.54987-9-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:34723 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753508AbdHQRks (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:40:48 -0400
Received: by mail-wr0-f174.google.com with SMTP id y96so47226301wrc.1
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:40:48 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema and live example:
bond_slave: IFLA_INFO_SLAVE_DATA
{
    "state": {
        "type": "string",
        "attr": "IFLA_BOND_SLAVE_STATE",
        "mutually_exclusive": {
            "state_index": {
                "type": "int",
                "comment": "if (state >= ARRAY_SIZE(slave_states))"
            }
        }
    },
    "mii_status": {
        "type": "string",
        "attr": "IFLA_BOND_SLAVE_MII_STATUS",
        "mutually_exclusive": {
            "mii_status_index": {
                "type": "int",
                "comment": "if (status >= ARRAY_SIZE(slave_mii_status))"
            }
        }
    },
    "link_failure_count": {
        "type": "int",
        "attr": "IFLA_BOND_SLAVE_LINK_FAILURE_COUNT"
    },
    "perm_hwaddr": {
        "type": "string",
        "attr": "IFLA_BOND_SLAVE_PERM_HWADDR"
    },
    "queue_id": {
        "type": "int",
        "attr": "IFLA_BOND_SLAVE_QUEUE_ID"
    },
    "ad_aggregator_id": {
        "type": "int",
        "attr": "IFLA_BOND_SLAVE_AD_AGGREGATOR_ID"
    },
    "ad_actor_oper_port_state": {
        "type": "int",
        "attr": "IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE"
    },
    "ad_partner_oper_port_state": {
        "type": "int",
        "attr": "IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE"
    }
}

$ ip link add dev bond42 type bond
$ ip link set dev swp5 master bond42
$ ip link set dev bond42 up
$ ip link set dev swp5 up
$ ip -details -json link show
[{
        "ifindex": 7,
        "ifname": "swp5",
        "flags": ["BROADCAST","MULTICAST","SLAVE","UP","LOWER_UP"],
        "mtu": 1500,
        "qdisc": "pfifo_fast",
        "master": "bond42",
        "operstate": "UP",
        "linkmode": "DEFAULT",
        "group": "default",
        "txqlen": 1000,
        "link_type": "ether",
        "address": "08:00:27:5c:03:c6",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "linkinfo": {
            "info_slave_kind": "bond",
            "info_slave_data": {
                "state": "BACKUP",
                "mii_status": "UP",
                "link_failure_count": 0,
                "perm_hwaddr": "08:00:27:5c:03:c6",
                "queue_id": 0,
                "ad_aggregator_id": 1,
                "ad_actor_oper_port_state": 79,
                "ad_partner_oper_port_state": 1
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 14,
        "ifname": "bond42",
        "flags": ["NO-CARRIER","BROADCAST","MULTICAST","MASTER","UP"],
        "mtu": 1500,
        "qdisc": "noqueue",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "08:00:27:5c:03:c6",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "bond",
            "info_data": {
                "mode": "802.3ad",
                "miimon": 100,
                "updelay": 0,
                "downdelay": 0,
                "use_carrier": 1,
                "arp_interval": 0,
                "arp_validate": null,
                "arp_all_targets": "any",
                "primary_reselect": "always",
                "fail_over_mac": "none",
                "xmit_hash_policy": "layer3+4",
                "resend_igmp": 1,
                "num_peer_notif": 1,
                "all_slaves_active": 0,
                "min_links": 1,
                "lp_interval": 1,
                "packets_per_slave": 1,
                "ad_lacp_rate": "fast",
                "ad_select": "stable",
                "ad_info": {
                    "aggregator": 1,
                    "num_ports": 1,
                    "actor_key": 0,
                    "partner_key": 1,
                    "partner_mac": "00:00:00:00:00:00"
                },
                "ad_actor_sys_prio": 65535,
                "ad_user_port_key": 0,
                "ad_actor_system": "00:00:00:00:00:00"
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 16,
        "num_rx_queues": 16,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    }
]

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/iplink_bond_slave.c | 57 ++++++++++++++++++++++++++++++++++----------------
 1 file changed, 39 insertions(+), 18 deletions(-)

diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
index 877e2d9e..67219c67 100644
--- a/ip/iplink_bond_slave.c
+++ b/ip/iplink_bond_slave.c
@@ -37,9 +37,12 @@ static void print_slave_state(FILE *f, struct rtattr *tb)
 	unsigned int state = rta_getattr_u8(tb);
 
 	if (state >= ARRAY_SIZE(slave_states))
-		fprintf(f, "state %d ", state);
+		print_int(PRINT_ANY, "state_index", "state %d ", state);
 	else
-		fprintf(f, "state %s ", slave_states[state]);
+		print_string(PRINT_ANY,
+			     "state",
+			     "state %s ",
+			     slave_states[state]);
 }
 
 static const char *slave_mii_status[] = {
@@ -54,9 +57,15 @@ static void print_slave_mii_status(FILE *f, struct rtattr *tb)
 	unsigned int status = rta_getattr_u8(tb);
 
 	if (status >= ARRAY_SIZE(slave_mii_status))
-		fprintf(f, "mii_status %d ", status);
+		print_int(PRINT_ANY,
+			  "mii_status_index",
+			  "mii_status %d ",
+			  status);
 	else
-		fprintf(f, "mii_status %s ", slave_mii_status[status]);
+		print_string(PRINT_ANY,
+			     "mii_status",
+			     "mii_status %s ",
+			     slave_mii_status[status]);
 }
 
 static void bond_slave_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
@@ -72,30 +81,42 @@ static void bond_slave_print_opt(struct link_util *lu, FILE *f, struct rtattr *t
 		print_slave_mii_status(f, tb[IFLA_BOND_SLAVE_MII_STATUS]);
 
 	if (tb[IFLA_BOND_SLAVE_LINK_FAILURE_COUNT])
-		fprintf(f, "link_failure_count %d ",
-			rta_getattr_u32(tb[IFLA_BOND_SLAVE_LINK_FAILURE_COUNT]));
+		print_int(PRINT_ANY,
+			  "link_failure_count",
+			  "link_failure_count %d ",
+			  rta_getattr_u32(tb[IFLA_BOND_SLAVE_LINK_FAILURE_COUNT]));
 
 	if (tb[IFLA_BOND_SLAVE_PERM_HWADDR])
-		fprintf(f, "perm_hwaddr %s ",
-			ll_addr_n2a(RTA_DATA(tb[IFLA_BOND_SLAVE_PERM_HWADDR]),
-				    RTA_PAYLOAD(tb[IFLA_BOND_SLAVE_PERM_HWADDR]),
-				    0, b1, sizeof(b1)));
+		print_string(PRINT_ANY,
+			     "perm_hwaddr",
+			     "perm_hwaddr %s ",
+			     ll_addr_n2a(RTA_DATA(tb[IFLA_BOND_SLAVE_PERM_HWADDR]),
+					 RTA_PAYLOAD(tb[IFLA_BOND_SLAVE_PERM_HWADDR]),
+					 0, b1, sizeof(b1)));
 
 	if (tb[IFLA_BOND_SLAVE_QUEUE_ID])
-		fprintf(f, "queue_id %d ",
-			rta_getattr_u16(tb[IFLA_BOND_SLAVE_QUEUE_ID]));
+		print_int(PRINT_ANY,
+			  "queue_id",
+			  "queue_id %d ",
+			  rta_getattr_u16(tb[IFLA_BOND_SLAVE_QUEUE_ID]));
 
 	if (tb[IFLA_BOND_SLAVE_AD_AGGREGATOR_ID])
-		fprintf(f, "ad_aggregator_id %d ",
-			rta_getattr_u16(tb[IFLA_BOND_SLAVE_AD_AGGREGATOR_ID]));
+		print_int(PRINT_ANY,
+			  "ad_aggregator_id",
+			  "ad_aggregator_id %d ",
+			  rta_getattr_u16(tb[IFLA_BOND_SLAVE_AD_AGGREGATOR_ID]));
 
 	if (tb[IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE])
-		fprintf(f, "ad_actor_oper_port_state %d ",
-			rta_getattr_u8(tb[IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE]));
+		print_int(PRINT_ANY,
+			  "ad_actor_oper_port_state",
+			  "ad_actor_oper_port_state %d ",
+			  rta_getattr_u8(tb[IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE]));
 
 	if (tb[IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE])
-		fprintf(f, "ad_partner_oper_port_state %d ",
-			rta_getattr_u16(tb[IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE]));
+		print_int(PRINT_ANY,
+			  "ad_partner_oper_port_state",
+			  "ad_partner_oper_port_state %d ",
+			  rta_getattr_u16(tb[IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE]));
 }
 
 static int bond_slave_parse_opt(struct link_util *lu, int argc, char **argv,
-- 
2.14.1
