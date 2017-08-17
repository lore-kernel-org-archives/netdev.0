From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 11/27] ip: iplink_bridge_slave.c: add json output support
Date: Thu, 17 Aug 2017 10:35:58 -0700
Message-ID: <20170817173614.54987-12-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:35300 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753425AbdHQRlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:41:06 -0400
Received: by mail-wr0-f178.google.com with SMTP id 49so41470462wrw.2
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:41:05 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema:
bridge_slave: IFLA_INFO_SLAVE_DATA
{
    "state": {
        "type": "string",
        "attr": "IFLA_BRPORT_STATE",
        "mutually_exclusive": {
            "state_index": {
                "type": "uint",
                "comment": "if (state > BR_STATE_BLOCKING)"
            }
        }
    },
    "priority": {
        "type": "int",
        "attr": "IFLA_BRPORT_PRIORITY"
    },
    "cost": {
        "type": "int",
        "attr": "IFLA_BRPORT_COST"
    },
    "mode": {
        "type": "bool",
        "attr": "IFLA_BRPORT_MODE"
    },
    "guard": {
        "type": "bool",
        "attr": "IFLA_BRPORT_GUARD"
    },
    "protect": {
        "type": "bool",
        "attr": "IFLA_BRPORT_PROTECT"
    },
    "fast_leave": {
        "type": "bool",
        "attr": "IFLA_BRPORT_FAST_LEAVE"
    },
    "learning": {
        "type": "bool",
        "attr": "IFLA_BRPORT_LEARNING"
    },
    "unicast_flood": {
        "type": "bool",
        "attr": "IFLA_BRPORT_UNICAST_FLOOD"
    },
    "id": {
        "type": "string",
        "attr": "IFLA_BRPORT_ID"
    },
    "no": {
        "type": "string",
        "attr": "IFLA_BRPORT_NO"
    },
    "designated_port": {
        "type": "uint",
        "attr": "IFLA_BRPORT_DESIGNATED_PORT"
    },
    "designated_cost": {
        "type": "uint",
        "attr": "IFLA_BRPORT_DESIGNATED_COST"
    },
    "bridge_id": {
        "type": "string",
        "attr": "IFLA_BRPORT_BRIDGE_ID"
    },
    "root_id": {
        "type": "string",
        "attr": "IFLA_BRPORT_ROOT_ID"
    },
    "hold_timer": {
        "type": "float",
        "attr": "IFLA_BRPORT_HOLD_TIMER"
    },
    "message_age_timer": {
        "type": "float",
        "attr": "IFLA_BRPORT_MESSAGE_AGE_TIMER"
    },
    "forward_delay_timer": {
        "type": "float",
        "attr": "IFLA_BRPORT_FORWARD_DELAY_TIMER"
    },
    "topology_change_ack": {
        "type": "uint",
        "attr": "IFLA_BRPORT_TOPOLOGY_CHANGE_ACK"
    },
    "config_pending": {
        "type": "uint",
        "attr": "IFLA_BRPORT_CONFIG_PENDING"
    },
    "proxyarp": {
        "type": "bool",
        "attr": "IFLA_BRPORT_PROXYARP"
    },
    "proxyarp_wifi": {
        "type": "bool",
        "attr": "IFLA_BRPORT_PROXYARP_WIFI"
    },
    "multicast_router": {
        "type": "uint",
        "attr": "IFLA_BRPORT_MULTICAST_ROUTER"
    },
    "mcast_flood": {
        "type": "bool",
        "attr": "IFLA_BRPORT_MCAST_FLOOD"
    }
}

$ ip link add dev br42 type bridge
$ ip link add dev bond42 type bond
$ ip link set dev bond42 master br42
$ ip link set dev bond42 up
$ ip link set dev br42 up
$ ip -details link show
$ ip -details link show
15: br42: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state
UP mode DEFAULT group default
    link/ether 22:8f:91:bb:9f:09 brd ff:ff:ff:ff:ff:ff promiscuity 0
    bridge forward_delay 1500 hello_time 200 max_age 2000 ageing_time
30000 stp_state 0 priority 32768 vlan_filtering 0 vlan_protocol 802.1Q
bridge_id 8000.22:8f:91:bb:9f:9 designated_root 8000.22:8f:91:bb:9f:9
root_port 0 root_path_cost 0 topology_change 0 topology_change_detected 0
hello_timer    0.00 tcn_timer    0.00 topology_change_timer    0.00
gc_timer  199.11 vlan_default_pvid 1 vlan_stats_enabled 0 group_fwd_mask 0
group_address 01:80:c2:00:00:00 mcast_snooping 1 mcast_router 1
mcast_query_use_ifaddr 0 mcast_querier 0 mcast_hash_elasticity 4096
mcast_hash_max 4096 mcast_last_member_count 2 mcast_startup_query_count 2
mcast_last_member_interval 100 mcast_membership_interval 26000
mcast_querier_interval 25500 mcast_query_interval 12500
mcast_query_response_interval 1000 mcast_startup_query_interval 3125
mcast_stats_enabled 0 mcast_igmp_version 2 mcast_mld_version 1
nf_call_iptables 0 nf_call_ip6tables 0 nf_call_arptables 0 addrgenmode
eui64
16: bond42: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc
noqueue master br42 state UNKNOWN mode DEFAULT group default
    link/ether 22:8f:91:bb:9f:09 brd ff:ff:ff:ff:ff:ff promiscuity 1
    bond mode 802.3ad miimon 100 updelay 0 downdelay 0 use_carrier 1
arp_interval 0 arp_validate none arp_all_targets any primary_reselect
always fail_over_mac none xmit_hash_policy layer3+4 resend_igmp 1
num_grat_arp 1 all_slaves_active 0 min_links 1 lp_interval 1
packets_per_slave 1 lacp_rate fast ad_select stable ad_actor_sys_prio
65535 ad_user_port_key 0 ad_actor_system 00:00:00:00:00:00
    bridge_slave state forwarding priority 8 cost 100 hairpin off guard
off root_block off fastleave off learning on flood on port_id 0x8001
port_no 0x1 designated_port 32769 designated_cost 0 designated_bridge
8000.22:8f:91:bb:9f:9 designated_root 8000.22:8f:91:bb:9f:9 hold_timer
0.00 message_age_timer    0.00 forward_delay_timer    0.00
topology_change_ack 0 config_pending 0 proxy_arp off proxy_arp_wifi off
mcast_router 1 mcast_fast_leave off mcast_flood on neigh_suppress off
addrgenmode eui64

$ ip -details -json link show
[{
        "ifindex": 15,
        "ifname": "br42",
        "flags": ["BROADCAST","MULTICAST","UP","LOWER_UP"],
        "mtu": 1500,
        "qdisc": "noqueue",
        "operstate": "UP",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "22:8f:91:bb:9f:09",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "bridge",
            "info_data": {
                "forward_delay": 1500,
                "hello_time": 200,
                "max_age": 2000,
                "ageing_time": 30000,
                "stp_state": 0,
                "priority": 32768,
                "vlan_filtering": 0,
                "vlan_protocol": "802.1Q",
                "bridge_id": "8000.22:8f:91:bb:9f:9",
                "root_id": "8000.22:8f:91:bb:9f:9",
                "root_port": 0,
                "root_path_cost": 0,
                "topology_change": 0,
                "topology_change_detected": 0,
                "hello_timer": 0.00,
                "tcn_timer": 0.00,
                "topology_change_timer": 0.00,
                "gc_timer": 298.27,
                "vlan_default_pvid": 1,
                "vlan_stats_enabled": 0,
                "group_fwd_mask": "0",
                "group_addr": "01:80:c2:00:00:00",
                "mcast_snooping": 1,
                "mcast_router": 1,
                "mcast_query_use_ifaddr": 0,
                "mcast_querier": 0,
                "mcast_hash_elasticity": 4096,
                "mcast_hash_max": 4096,
                "mcast_last_member_cnt": 2,
                "mcast_startup_query_cnt": 2,
                "mcast_last_member_intvl": 100,
                "mcast_membership_intvl": 26000,
                "mcast_querier_intvl": 25500,
                "mcast_query_intvl": 12500,
                "mcast_query_response_intvl": 1000,
                "mcast_startup_query_intvl": 3125,
                "mcast_stats_enabled": 0,
                "mcast_igmp_version": 2,
                "mcast_mld_version": 1,
                "nf_call_iptables": 0,
                "nf_call_ip6tables": 0,
                "nf_call_arptables": 0
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 16,
        "ifname": "bond42",
        "flags": ["BROADCAST","MULTICAST","MASTER","UP","LOWER_UP"],
        "mtu": 1500,
        "qdisc": "noqueue",
        "master": "br42",
        "operstate": "UNKNOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "22:8f:91:bb:9f:09",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 1,
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
                "ad_actor_sys_prio": 65535,
                "ad_user_port_key": 0,
                "ad_actor_system": "00:00:00:00:00:00"
            },
            "info_slave_kind": "bridge",
            "info_slave_data": {
                "state": "forwarding",
                "priority": 8,
                "cost": 100,
                "hairpin": false,
                "guard": false,
                "root_block": false,
                "fastleave": false,
                "learning": true,
                "flood": true,
                "id": "0x8001",
                "no": "0x1",
                "designated_port": 32769,
                "designated_cost": 0,
                "bridge_id": "8000.22:8f:91:bb:9f:9",
                "root_id": "8000.22:8f:91:bb:9f:9",
                "hold_timer": 0.00,
                "message_age_timer": 0.00,
                "forward_delay_timer": 11.97,
                "topology_change_ack": 0,
                "config_pending": 0,
                "proxy_arp": false,
                "proxy_arp_wifi": false,
                "multicast_router": 1,
                "mcast_flood": true
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
 ip/iplink_bridge_slave.c | 185 +++++++++++++++++++++++++++++------------------
 1 file changed, 114 insertions(+), 71 deletions(-)

diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index 3e883328..80272b09 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -56,14 +56,52 @@ static const char *port_states[] = {
 static void print_portstate(FILE *f, __u8 state)
 {
 	if (state <= BR_STATE_BLOCKING)
-		fprintf(f, "state %s ", port_states[state]);
+		print_string(PRINT_ANY,
+			     "state",
+			     "state %s ",
+			     port_states[state]);
 	else
-		fprintf(f, "state (%d) ", state);
+		print_int(PRINT_ANY, "state_index", "state (%d) ", state);
 }
 
-static void print_onoff(FILE *f, char *flag, __u8 val)
+static void _print_onoff(FILE *f, char *json_flag, char *flag, __u8 val)
 {
-	fprintf(f, "%s %s ", flag, val ? "on" : "off");
+	if (is_json_context())
+		print_bool(PRINT_JSON, flag, NULL, val);
+	else
+		fprintf(f, "%s %s ", flag, val ? "on" : "off");
+}
+
+static void _print_hex(FILE *f,
+		       const char *json_attr,
+		       const char *attr,
+		       __u16 val)
+{
+	if (is_json_context()) {
+		SPRINT_BUF(b1);
+
+		snprintf(b1, sizeof(b1), "0x%x", val);
+		print_string(PRINT_JSON, json_attr, NULL, b1);
+	} else {
+		fprintf(f, "%s 0x%x ", attr, val);
+	}
+}
+
+static void _print_timer(FILE *f, const char *attr, struct rtattr *timer)
+{
+	struct timeval tv;
+
+	__jiffies_to_tv(&tv, rta_getattr_u64(timer));
+	if (is_json_context()) {
+		json_writer_t *jw = get_json_writer();
+
+		jsonw_name(jw, attr);
+		jsonw_printf(jw, "%i.%.2i",
+			     (int)tv.tv_sec, (int)tv.tv_usec / 10000);
+	} else {
+		fprintf(f, "%s %4i.%.2i ", attr, (int)tv.tv_sec,
+			(int)tv.tv_usec / 10000);
+	}
 }
 
 static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
@@ -76,59 +114,70 @@ static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
 		print_portstate(f, rta_getattr_u8(tb[IFLA_BRPORT_STATE]));
 
 	if (tb[IFLA_BRPORT_PRIORITY])
-		fprintf(f, "priority %d ",
-			rta_getattr_u16(tb[IFLA_BRPORT_PRIORITY]));
+		print_int(PRINT_ANY,
+			  "priority",
+			  "priority %d ",
+			  rta_getattr_u16(tb[IFLA_BRPORT_PRIORITY]));
 
 	if (tb[IFLA_BRPORT_COST])
-		fprintf(f, "cost %d ",
-			rta_getattr_u32(tb[IFLA_BRPORT_COST]));
+		print_int(PRINT_ANY,
+			  "cost",
+			  "cost %d ",
+			  rta_getattr_u32(tb[IFLA_BRPORT_COST]));
 
 	if (tb[IFLA_BRPORT_MODE])
-		print_onoff(f, "hairpin",
-			    rta_getattr_u8(tb[IFLA_BRPORT_MODE]));
+		_print_onoff(f, "mode", "hairpin",
+			     rta_getattr_u8(tb[IFLA_BRPORT_MODE]));
 
 	if (tb[IFLA_BRPORT_GUARD])
-		print_onoff(f, "guard",
-			    rta_getattr_u8(tb[IFLA_BRPORT_GUARD]));
+		_print_onoff(f, "guard", "guard",
+			     rta_getattr_u8(tb[IFLA_BRPORT_GUARD]));
 
 	if (tb[IFLA_BRPORT_PROTECT])
-		print_onoff(f, "root_block",
-			    rta_getattr_u8(tb[IFLA_BRPORT_PROTECT]));
+		_print_onoff(f, "protect", "root_block",
+			     rta_getattr_u8(tb[IFLA_BRPORT_PROTECT]));
 
 	if (tb[IFLA_BRPORT_FAST_LEAVE])
-		print_onoff(f, "fastleave",
-			    rta_getattr_u8(tb[IFLA_BRPORT_FAST_LEAVE]));
+		_print_onoff(f, "fast_leave", "fastleave",
+			     rta_getattr_u8(tb[IFLA_BRPORT_FAST_LEAVE]));
 
 	if (tb[IFLA_BRPORT_LEARNING])
-		print_onoff(f, "learning",
-			rta_getattr_u8(tb[IFLA_BRPORT_LEARNING]));
+		_print_onoff(f, "learning", "learning",
+			     rta_getattr_u8(tb[IFLA_BRPORT_LEARNING]));
 
 	if (tb[IFLA_BRPORT_UNICAST_FLOOD])
-		print_onoff(f, "flood",
-			rta_getattr_u8(tb[IFLA_BRPORT_UNICAST_FLOOD]));
+		_print_onoff(f, "unicast_flood", "flood",
+			     rta_getattr_u8(tb[IFLA_BRPORT_UNICAST_FLOOD]));
 
 	if (tb[IFLA_BRPORT_ID])
-		fprintf(f, "port_id 0x%x ",
-			rta_getattr_u16(tb[IFLA_BRPORT_ID]));
+		_print_hex(f, "id", "port_id",
+			   rta_getattr_u16(tb[IFLA_BRPORT_ID]));
 
 	if (tb[IFLA_BRPORT_NO])
-		fprintf(f, "port_no 0x%x ",
-			rta_getattr_u16(tb[IFLA_BRPORT_NO]));
+		_print_hex(f, "no", "port_no",
+			   rta_getattr_u16(tb[IFLA_BRPORT_NO]));
 
 	if (tb[IFLA_BRPORT_DESIGNATED_PORT])
-		fprintf(f, "designated_port %u ",
-			rta_getattr_u16(tb[IFLA_BRPORT_DESIGNATED_PORT]));
+		print_uint(PRINT_ANY,
+			   "designated_port",
+			   "designated_port %u ",
+			   rta_getattr_u16(tb[IFLA_BRPORT_DESIGNATED_PORT]));
 
 	if (tb[IFLA_BRPORT_DESIGNATED_COST])
-		fprintf(f, "designated_cost %u ",
-			rta_getattr_u16(tb[IFLA_BRPORT_DESIGNATED_COST]));
+		print_uint(PRINT_ANY,
+			   "designated_cost",
+			   "designated_cost %u ",
+			   rta_getattr_u16(tb[IFLA_BRPORT_DESIGNATED_COST]));
 
 	if (tb[IFLA_BRPORT_BRIDGE_ID]) {
 		char bridge_id[32];
 
 		br_dump_bridge_id(RTA_DATA(tb[IFLA_BRPORT_BRIDGE_ID]),
 				  bridge_id, sizeof(bridge_id));
-		fprintf(f, "designated_bridge %s ", bridge_id);
+		print_string(PRINT_ANY,
+			     "bridge_id",
+			     "designated_bridge %s ",
+			     bridge_id);
 	}
 
 	if (tb[IFLA_BRPORT_ROOT_ID]) {
@@ -136,65 +185,59 @@ static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
 
 		br_dump_bridge_id(RTA_DATA(tb[IFLA_BRPORT_ROOT_ID]),
 				  root_id, sizeof(root_id));
-		fprintf(f, "designated_root %s ", root_id);
-	}
-
-	if (tb[IFLA_BRPORT_HOLD_TIMER]) {
-		struct timeval tv;
-		__u64 htimer;
-
-		htimer = rta_getattr_u64(tb[IFLA_BRPORT_HOLD_TIMER]);
-		__jiffies_to_tv(&tv, htimer);
-		fprintf(f, "hold_timer %4i.%.2i ", (int)tv.tv_sec,
-			(int)tv.tv_usec/10000);
+		print_string(PRINT_ANY,
+			     "root_id",
+			     "designated_root %s ", root_id);
 	}
 
-	if (tb[IFLA_BRPORT_MESSAGE_AGE_TIMER]) {
-		struct timeval tv;
-		__u64 agetimer;
+	if (tb[IFLA_BRPORT_HOLD_TIMER])
+		_print_timer(f, "hold_timer", tb[IFLA_BRPORT_HOLD_TIMER]);
 
-		agetimer = rta_getattr_u64(tb[IFLA_BRPORT_MESSAGE_AGE_TIMER]);
-		__jiffies_to_tv(&tv, agetimer);
-		fprintf(f, "message_age_timer %4i.%.2i ", (int)tv.tv_sec,
-			(int)tv.tv_usec/10000);
-	}
-
-	if (tb[IFLA_BRPORT_FORWARD_DELAY_TIMER]) {
-		struct timeval tv;
-		__u64 fwdtimer;
+	if (tb[IFLA_BRPORT_MESSAGE_AGE_TIMER])
+		_print_timer(f, "message_age_timer",
+			     tb[IFLA_BRPORT_MESSAGE_AGE_TIMER]);
 
-		fwdtimer = rta_getattr_u64(tb[IFLA_BRPORT_FORWARD_DELAY_TIMER]);
-		__jiffies_to_tv(&tv, fwdtimer);
-		fprintf(f, "forward_delay_timer %4i.%.2i ", (int)tv.tv_sec,
-			(int)tv.tv_usec/10000);
-	}
+	if (tb[IFLA_BRPORT_FORWARD_DELAY_TIMER])
+		_print_timer(f, "forward_delay_timer",
+			     tb[IFLA_BRPORT_FORWARD_DELAY_TIMER]);
 
 	if (tb[IFLA_BRPORT_TOPOLOGY_CHANGE_ACK])
-		fprintf(f, "topology_change_ack %u ",
-			rta_getattr_u8(tb[IFLA_BRPORT_TOPOLOGY_CHANGE_ACK]));
+		print_uint(PRINT_ANY,
+			   "topology_change_ack",
+			   "topology_change_ack %u ",
+			   rta_getattr_u8(tb[IFLA_BRPORT_TOPOLOGY_CHANGE_ACK]));
 
 	if (tb[IFLA_BRPORT_CONFIG_PENDING])
-		fprintf(f, "config_pending %u ",
-			rta_getattr_u8(tb[IFLA_BRPORT_CONFIG_PENDING]));
+		print_uint(PRINT_ANY,
+			   "config_pending",
+			   "config_pending %u ",
+			   rta_getattr_u8(tb[IFLA_BRPORT_CONFIG_PENDING]));
+
 	if (tb[IFLA_BRPORT_PROXYARP])
-		print_onoff(f, "proxy_arp",
-			    rta_getattr_u8(tb[IFLA_BRPORT_PROXYARP]));
+		_print_onoff(f, "proxyarp", "proxy_arp",
+			     rta_getattr_u8(tb[IFLA_BRPORT_PROXYARP]));
 
 	if (tb[IFLA_BRPORT_PROXYARP_WIFI])
-		print_onoff(f, "proxy_arp_wifi",
-			    rta_getattr_u8(tb[IFLA_BRPORT_PROXYARP_WIFI]));
+		_print_onoff(f, "proxyarp_wifi", "proxy_arp_wifi",
+			     rta_getattr_u8(tb[IFLA_BRPORT_PROXYARP_WIFI]));
 
 	if (tb[IFLA_BRPORT_MULTICAST_ROUTER])
-		fprintf(f, "mcast_router %u ",
-			rta_getattr_u8(tb[IFLA_BRPORT_MULTICAST_ROUTER]));
+		print_uint(PRINT_ANY,
+			   "multicast_router",
+			   "mcast_router %u ",
+			   rta_getattr_u8(tb[IFLA_BRPORT_MULTICAST_ROUTER]));
 
 	if (tb[IFLA_BRPORT_FAST_LEAVE])
-		print_onoff(f, "mcast_fast_leave",
-			    rta_getattr_u8(tb[IFLA_BRPORT_FAST_LEAVE]));
+		// not printing any json here because
+		// we already printed fast_leave before
+		print_string(PRINT_FP,
+			     NULL,
+			     "mcast_fast_leave %s ",
+			     rta_getattr_u8(tb[IFLA_BRPORT_FAST_LEAVE]) ? "on" : "off");
 
 	if (tb[IFLA_BRPORT_MCAST_FLOOD])
-		print_onoff(f, "mcast_flood",
-			rta_getattr_u8(tb[IFLA_BRPORT_MCAST_FLOOD]));
+		_print_onoff(f, "mcast_flood", "mcast_flood",
+			     rta_getattr_u8(tb[IFLA_BRPORT_MCAST_FLOOD]));
 }
 
 static void bridge_slave_parse_on_off(char *arg_name, char *arg_val,
-- 
2.14.1
