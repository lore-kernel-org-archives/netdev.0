From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 10/27] ip: iplink_bridge.c: add json output support
Date: Thu, 17 Aug 2017 10:35:57 -0700
Message-ID: <20170817173614.54987-11-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:36432 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753508AbdHQRk7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:40:59 -0400
Received: by mail-wr0-f180.google.com with SMTP id f8so5670370wrf.3
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:40:58 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema and live example:
bridge: IFLA_INFO_DATA
{
    "forward_delay": {
        "type": "uint",
        "attr": "IFLA_BR_FORWARD_DELAY"
    },
    "hello_time": {
        "type": "uint",
        "attr": "IFLA_BR_HELLO_TIME"
    },
    "max_age": {
        "type": "uint",
        "attr": "IFLA_BR_MAX_AGE"
    },
    "ageing_time": {
        "type": "uint",
        "attr": "IFLA_BR_AGEING_TIME"
    },
    "stp_state": {
        "type": "uint",
        "attr": "IFLA_BR_STP_STATE"
    },
    "priority": {
        "type": "uint",
        "attr": "IFLA_BR_PRIORITY"
    },
    "vlan_filtering": {
        "type": "uint",
        "attr": "IFLA_BR_VLAN_FILTERING"
    },
    "vlan_protocol": {
        "type": "string",
        "attr": "IFLA_BR_VLAN_PROTOCOL"
    },
    "bridge_id": {
        "type": "string",
        "attr": "IFLA_BR_BRIDGE_ID"
    },
    "root_id": {
        "type": "string",
        "attr": "IFLA_BR_ROOT_ID"
    },
    "root_port": {
        "type": "uint",
        "attr": "IFLA_BR_ROOT_PORT"
    },
    "root_path_cost": {
        "type": "uint",
        "attr": "IFLA_BR_ROOT_PATH_COST"
    },
    "topology_change": {
        "type": "uint",
        "attr": "IFLA_BR_TOPOLOGY_CHANGE"
    },
    "topology_change_detected": {
        "type": "uint",
        "attr": "IFLA_BR_TOPOLOGY_CHANGE_DETECTED"
    },
    "hello_timer": {
        "type": "float",
        "attr": "IFLA_BR_HELLO_TIMER"
    },
    "tcn_timer": {
        "type": "float",
        "attr": "IFLA_BR_TCN_TIMER"
    },
    "topology_change_timer": {
        "type": "float",
        "attr": "IFLA_BR_TOPOLOGY_CHANGE_TIMER"
    },
    "gc_timer": {
        "type": "float",
        "attr": "IFLA_BR_GC_TIMER"
    },
    "vlan_default_pvid": {
        "type": "uint",
        "attr": "IFLA_BR_VLAN_DEFAULT_PVID"
    },
    "vlan_stats_enabled": {
        "type": "uint",
        "attr": "IFLA_BR_VLAN_STATS_ENABLED"
    },
    "group_fwd_mask": {
        "type": "string",
        "attr": "IFLA_BR_GROUP_FWD_MASK"
    },
    "group_addr": {
        "type": "string",
        "attr": "IFLA_BR_GROUP_ADDR"
    },
    "mcast_snooping": {
        "type": "uint",
        "attr": "IFLA_BR_MCAST_SNOOPING"
    },
    "mcast_router": {
        "type": "uint",
        "attr": "IFLA_BR_MCAST_ROUTER"
    },
    "mcast_query_use_ifaddr": {
        "type": "uint",
        "attr": "IFLA_BR_MCAST_QUERY_USE_IFADDR"
    },
    "mcast_querier": {
        "type": "uint",
        "attr": "IFLA_BR_MCAST_QUERIER"
    },
    "mcast_hash_elasticity": {
        "type": "uint",
        "attr": "IFLA_BR_MCAST_HASH_ELASTICITY"
    },
    "mcast_hash_max": {
        "type": "uint",
        "attr": "IFLA_BR_MCAST_HASH_MAX"
    },
    "mcast_last_member_cnt": {
        "type": "uint",
        "attr": "IFLA_BR_MCAST_LAST_MEMBER_CNT"
    },
    "mcast_startup_query_cnt": {
        "type": "uint",
        "attr": "IFLA_BR_MCAST_STARTUP_QUERY_CNT"
    },
    "mcast_last_member_intvl": {
        "type": "lluint",
        "attr": "IFLA_BR_MCAST_LAST_MEMBER_INTVL"
    },
    "mcast_membership_intvl": {
        "type": "lluint",
        "attr": "IFLA_BR_MCAST_MEMBERSHIP_INTVL"
    },
    "mcast_querier_intvl": {
        "type": "lluint",
        "attr": "IFLA_BR_MCAST_QUERIER_INTVL"
    },
    "mcast_query_intvl": {
        "type": "lluint",
        "attr": "IFLA_BR_MCAST_QUERY_INTVL"
    },
    "mcast_query_response_intvl": {
        "type": "lluint",
        "attr": "IFLA_BR_MCAST_QUERY_RESPONSE_INTVL"
    },
    "mcast_startup_query_intvl": {
        "type": "lluint",
        "attr": "IFLA_BR_MCAST_STARTUP_QUERY_INTVL"
    },
    "mcast_stats_enabled": {
        "type": "uint",
        "attr": "IFLA_BR_MCAST_STATS_ENABLED"
    },
    "mcast_igmp_version": {
        "type": "uint",
        "attr": "IFLA_BR_MCAST_IGMP_VERSION"
    },
    "mcast_mld_version": {
        "type": "uint",
        "attr": "IFLA_BR_MCAST_MLD_VERSION"
    },
    "nf_call_iptables": {
        "type": "uint",
        "attr": "IFLA_BR_NF_CALL_IPTABLES"
    },
    "nf_call_ip6tables": {
        "type": "uint",
        "attr": "IFLA_BR_NF_CALL_IP6TABLES"
    },
    "nf_call_arptables": {
        "type": "uint",
        "attr": "IFLA_BR_NF_CALL_ARPTABLES"
    }
}

$ ip link add dev br42 type bridge
$ ip link add dev bond42 type bond
$ ip link set dev bond42 master br42
$ ip link set dev bond42 up
$ ip link set dev br42 up

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
 ip/iplink_bridge.c | 293 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 185 insertions(+), 108 deletions(-)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index cccdec1c..d3250980 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -373,45 +373,81 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 	return 0;
 }
 
+static void _bridge_print_timer(FILE *f,
+				const char *attr,
+				struct rtattr *timer)
+{
+	struct timeval tv;
+
+	__jiffies_to_tv(&tv, rta_getattr_u64(timer));
+	if (is_json_context()) {
+		json_writer_t *jw = get_json_writer();
+
+		jsonw_name(jw, attr);
+		jsonw_printf(jw, "%i.%.2i",
+			     (int)tv.tv_sec,
+			     (int)tv.tv_usec / 10000);
+	} else {
+		fprintf(f, "%s %4i.%.2i ", attr, (int)tv.tv_sec,
+			(int)tv.tv_usec / 10000);
+	}
+}
+
 static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
 	if (!tb)
 		return;
 
 	if (tb[IFLA_BR_FORWARD_DELAY])
-		fprintf(f, "forward_delay %u ",
-			rta_getattr_u32(tb[IFLA_BR_FORWARD_DELAY]));
+		print_uint(PRINT_ANY,
+			   "forward_delay",
+			   "forward_delay %u ",
+			   rta_getattr_u32(tb[IFLA_BR_FORWARD_DELAY]));
 
 	if (tb[IFLA_BR_HELLO_TIME])
-		fprintf(f, "hello_time %u ",
-			rta_getattr_u32(tb[IFLA_BR_HELLO_TIME]));
+		print_uint(PRINT_ANY,
+			   "hello_time",
+			   "hello_time %u ",
+			   rta_getattr_u32(tb[IFLA_BR_HELLO_TIME]));
 
 	if (tb[IFLA_BR_MAX_AGE])
-		fprintf(f, "max_age %u ",
-			rta_getattr_u32(tb[IFLA_BR_MAX_AGE]));
+		print_uint(PRINT_ANY,
+			   "max_age",
+			   "max_age %u ",
+			   rta_getattr_u32(tb[IFLA_BR_MAX_AGE]));
 
 	if (tb[IFLA_BR_AGEING_TIME])
-		fprintf(f, "ageing_time %u ",
-			rta_getattr_u32(tb[IFLA_BR_AGEING_TIME]));
+		print_uint(PRINT_ANY,
+			   "ageing_time",
+			   "ageing_time %u ",
+			   rta_getattr_u32(tb[IFLA_BR_AGEING_TIME]));
 
 	if (tb[IFLA_BR_STP_STATE])
-		fprintf(f, "stp_state %u ",
-			rta_getattr_u32(tb[IFLA_BR_STP_STATE]));
+		print_uint(PRINT_ANY,
+			   "stp_state",
+			   "stp_state %u ",
+			   rta_getattr_u32(tb[IFLA_BR_STP_STATE]));
 
 	if (tb[IFLA_BR_PRIORITY])
-		fprintf(f, "priority %u ",
-			rta_getattr_u16(tb[IFLA_BR_PRIORITY]));
+		print_uint(PRINT_ANY,
+			   "priority",
+			   "priority %u ",
+			   rta_getattr_u16(tb[IFLA_BR_PRIORITY]));
 
 	if (tb[IFLA_BR_VLAN_FILTERING])
-		fprintf(f, "vlan_filtering %u ",
-			rta_getattr_u8(tb[IFLA_BR_VLAN_FILTERING]));
+		print_uint(PRINT_ANY,
+			   "vlan_filtering",
+			   "vlan_filtering %u ",
+			   rta_getattr_u8(tb[IFLA_BR_VLAN_FILTERING]));
 
 	if (tb[IFLA_BR_VLAN_PROTOCOL]) {
 		SPRINT_BUF(b1);
 
-		fprintf(f, "vlan_protocol %s ",
-			ll_proto_n2a(rta_getattr_u16(tb[IFLA_BR_VLAN_PROTOCOL]),
-				     b1, sizeof(b1)));
+		print_string(PRINT_ANY,
+			     "vlan_protocol",
+			     "vlan_protocol %s ",
+			     ll_proto_n2a(rta_getattr_u16(tb[IFLA_BR_VLAN_PROTOCOL]),
+					  b1, sizeof(b1)));
 	}
 
 	if (tb[IFLA_BR_BRIDGE_ID]) {
@@ -419,7 +455,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 		br_dump_bridge_id(RTA_DATA(tb[IFLA_BR_BRIDGE_ID]), bridge_id,
 				  sizeof(bridge_id));
-		fprintf(f, "bridge_id %s ", bridge_id);
+		print_string(PRINT_ANY,
+			     "bridge_id",
+			     "bridge_id %s ",
+			     bridge_id);
 	}
 
 	if (tb[IFLA_BR_ROOT_ID]) {
@@ -427,163 +466,201 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 		br_dump_bridge_id(RTA_DATA(tb[IFLA_BR_BRIDGE_ID]), root_id,
 				  sizeof(root_id));
-		fprintf(f, "designated_root %s ", root_id);
+		print_string(PRINT_ANY,
+			     "root_id",
+			     "designated_root %s ",
+			     root_id);
 	}
 
 	if (tb[IFLA_BR_ROOT_PORT])
-		fprintf(f, "root_port %u ",
-			rta_getattr_u16(tb[IFLA_BR_ROOT_PORT]));
+		print_uint(PRINT_ANY,
+			   "root_port",
+			   "root_port %u ",
+			   rta_getattr_u16(tb[IFLA_BR_ROOT_PORT]));
 
 	if (tb[IFLA_BR_ROOT_PATH_COST])
-		fprintf(f, "root_path_cost %u ",
-			rta_getattr_u32(tb[IFLA_BR_ROOT_PATH_COST]));
+		print_uint(PRINT_ANY,
+			   "root_path_cost",
+			   "root_path_cost %u ",
+			   rta_getattr_u32(tb[IFLA_BR_ROOT_PATH_COST]));
 
 	if (tb[IFLA_BR_TOPOLOGY_CHANGE])
-		fprintf(f, "topology_change %u ",
-			rta_getattr_u8(tb[IFLA_BR_TOPOLOGY_CHANGE]));
+		print_uint(PRINT_ANY,
+			   "topology_change",
+			   "topology_change %u ",
+			   rta_getattr_u8(tb[IFLA_BR_TOPOLOGY_CHANGE]));
 
 	if (tb[IFLA_BR_TOPOLOGY_CHANGE_DETECTED])
-		fprintf(f, "topology_change_detected %u ",
-			rta_getattr_u8(tb[IFLA_BR_TOPOLOGY_CHANGE_DETECTED]));
-
-	if (tb[IFLA_BR_HELLO_TIMER]) {
-		struct timeval tv;
-
-		__jiffies_to_tv(&tv, rta_getattr_u64(tb[IFLA_BR_HELLO_TIMER]));
-		fprintf(f, "hello_timer %4i.%.2i ", (int)tv.tv_sec,
-			(int)tv.tv_usec/10000);
-	}
-
-	if (tb[IFLA_BR_TCN_TIMER]) {
-		struct timeval tv;
-
-		__jiffies_to_tv(&tv, rta_getattr_u64(tb[IFLA_BR_TCN_TIMER]));
-		fprintf(f, "tcn_timer %4i.%.2i ", (int)tv.tv_sec,
-			(int)tv.tv_usec/10000);
-	}
+		print_uint(PRINT_ANY,
+			   "topology_change_detected",
+			   "topology_change_detected %u ",
+			   rta_getattr_u8(tb[IFLA_BR_TOPOLOGY_CHANGE_DETECTED]));
 
-	if (tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER]) {
-		unsigned long jiffies;
-		struct timeval tv;
+	if (tb[IFLA_BR_HELLO_TIMER])
+		_bridge_print_timer(f, "hello_timer", tb[IFLA_BR_HELLO_TIMER]);
 
-		jiffies = rta_getattr_u64(tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER]);
-		__jiffies_to_tv(&tv, jiffies);
-		fprintf(f, "topology_change_timer %4i.%.2i ", (int)tv.tv_sec,
-			(int)tv.tv_usec/10000);
-	}
+	if (tb[IFLA_BR_TCN_TIMER])
+		_bridge_print_timer(f, "tcn_timer", tb[IFLA_BR_TCN_TIMER]);
 
-	if (tb[IFLA_BR_GC_TIMER]) {
-		struct timeval tv;
+	if (tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER])
+		_bridge_print_timer(f, "topology_change_timer",
+				    tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER]);
 
-		__jiffies_to_tv(&tv, rta_getattr_u64(tb[IFLA_BR_GC_TIMER]));
-		fprintf(f, "gc_timer %4i.%.2i ", (int)tv.tv_sec,
-			(int)tv.tv_usec/10000);
-	}
+	if (tb[IFLA_BR_GC_TIMER])
+		_bridge_print_timer(f, "gc_timer", tb[IFLA_BR_GC_TIMER]);
 
 	if (tb[IFLA_BR_VLAN_DEFAULT_PVID])
-		fprintf(f, "vlan_default_pvid %u ",
-			rta_getattr_u16(tb[IFLA_BR_VLAN_DEFAULT_PVID]));
+		print_uint(PRINT_ANY,
+			   "vlan_default_pvid",
+			   "vlan_default_pvid %u ",
+			   rta_getattr_u16(tb[IFLA_BR_VLAN_DEFAULT_PVID]));
 
 	if (tb[IFLA_BR_VLAN_STATS_ENABLED])
-		fprintf(f, "vlan_stats_enabled %u ",
-			rta_getattr_u8(tb[IFLA_BR_VLAN_STATS_ENABLED]));
+		print_uint(PRINT_ANY,
+			   "vlan_stats_enabled",
+			   "vlan_stats_enabled %u ",
+			   rta_getattr_u8(tb[IFLA_BR_VLAN_STATS_ENABLED]));
 
 	if (tb[IFLA_BR_GROUP_FWD_MASK])
-		fprintf(f, "group_fwd_mask %#x ",
-			rta_getattr_u16(tb[IFLA_BR_GROUP_FWD_MASK]));
+		print_0xhex(PRINT_ANY,
+			    "group_fwd_mask",
+			    "group_fwd_mask %#x ",
+			    rta_getattr_u16(tb[IFLA_BR_GROUP_FWD_MASK]));
 
 	if (tb[IFLA_BR_GROUP_ADDR]) {
 		SPRINT_BUF(mac);
 
-		fprintf(f, "group_address %s ",
-			ll_addr_n2a(RTA_DATA(tb[IFLA_BR_GROUP_ADDR]),
-				    RTA_PAYLOAD(tb[IFLA_BR_GROUP_ADDR]),
-				    1 /*ARPHDR_ETHER*/, mac, sizeof(mac)));
+		print_string(PRINT_ANY,
+			     "group_addr",
+			     "group_address %s ",
+			     ll_addr_n2a(RTA_DATA(tb[IFLA_BR_GROUP_ADDR]),
+					 RTA_PAYLOAD(tb[IFLA_BR_GROUP_ADDR]),
+					 1 /*ARPHDR_ETHER*/, mac, sizeof(mac)));
 	}
 
 	if (tb[IFLA_BR_MCAST_SNOOPING])
-		fprintf(f, "mcast_snooping %u ",
-			rta_getattr_u8(tb[IFLA_BR_MCAST_SNOOPING]));
+		print_uint(PRINT_ANY,
+			   "mcast_snooping",
+			   "mcast_snooping %u ",
+			   rta_getattr_u8(tb[IFLA_BR_MCAST_SNOOPING]));
 
 	if (tb[IFLA_BR_MCAST_ROUTER])
-		fprintf(f, "mcast_router %u ",
-			rta_getattr_u8(tb[IFLA_BR_MCAST_ROUTER]));
+		print_uint(PRINT_ANY,
+			   "mcast_router",
+			   "mcast_router %u ",
+			   rta_getattr_u8(tb[IFLA_BR_MCAST_ROUTER]));
 
 	if (tb[IFLA_BR_MCAST_QUERY_USE_IFADDR])
-		fprintf(f, "mcast_query_use_ifaddr %u ",
-			rta_getattr_u8(tb[IFLA_BR_MCAST_QUERY_USE_IFADDR]));
+		print_uint(PRINT_ANY,
+			   "mcast_query_use_ifaddr",
+			   "mcast_query_use_ifaddr %u ",
+			   rta_getattr_u8(tb[IFLA_BR_MCAST_QUERY_USE_IFADDR]));
 
 	if (tb[IFLA_BR_MCAST_QUERIER])
-		fprintf(f, "mcast_querier %u ",
-			rta_getattr_u8(tb[IFLA_BR_MCAST_QUERIER]));
+		print_uint(PRINT_ANY,
+			   "mcast_querier",
+			   "mcast_querier %u ",
+			   rta_getattr_u8(tb[IFLA_BR_MCAST_QUERIER]));
 
 	if (tb[IFLA_BR_MCAST_HASH_ELASTICITY])
-		fprintf(f, "mcast_hash_elasticity %u ",
-			rta_getattr_u32(tb[IFLA_BR_MCAST_HASH_ELASTICITY]));
+		print_uint(PRINT_ANY,
+			   "mcast_hash_elasticity",
+			   "mcast_hash_elasticity %u ",
+			   rta_getattr_u32(tb[IFLA_BR_MCAST_HASH_ELASTICITY]));
 
 	if (tb[IFLA_BR_MCAST_HASH_MAX])
-		fprintf(f, "mcast_hash_max %u ",
-			rta_getattr_u32(tb[IFLA_BR_MCAST_HASH_MAX]));
+		print_uint(PRINT_ANY,
+			   "mcast_hash_max",
+			   "mcast_hash_max %u ",
+			   rta_getattr_u32(tb[IFLA_BR_MCAST_HASH_MAX]));
 
 	if (tb[IFLA_BR_MCAST_LAST_MEMBER_CNT])
-		fprintf(f, "mcast_last_member_count %u ",
-			rta_getattr_u32(tb[IFLA_BR_MCAST_LAST_MEMBER_CNT]));
+		print_uint(PRINT_ANY,
+			   "mcast_last_member_cnt",
+			   "mcast_last_member_count %u ",
+			   rta_getattr_u32(tb[IFLA_BR_MCAST_LAST_MEMBER_CNT]));
 
 	if (tb[IFLA_BR_MCAST_STARTUP_QUERY_CNT])
-		fprintf(f, "mcast_startup_query_count %u ",
-			rta_getattr_u32(tb[IFLA_BR_MCAST_STARTUP_QUERY_CNT]));
+		print_uint(PRINT_ANY,
+			   "mcast_startup_query_cnt",
+			   "mcast_startup_query_count %u ",
+			   rta_getattr_u32(tb[IFLA_BR_MCAST_STARTUP_QUERY_CNT]));
 
 	if (tb[IFLA_BR_MCAST_LAST_MEMBER_INTVL])
-		fprintf(f, "mcast_last_member_interval %llu ",
-			rta_getattr_u64(tb[IFLA_BR_MCAST_LAST_MEMBER_INTVL]));
+		print_lluint(PRINT_ANY,
+			     "mcast_last_member_intvl",
+			     "mcast_last_member_interval %llu ",
+			     rta_getattr_u64(tb[IFLA_BR_MCAST_LAST_MEMBER_INTVL]));
 
 	if (tb[IFLA_BR_MCAST_MEMBERSHIP_INTVL])
-		fprintf(f, "mcast_membership_interval %llu ",
-			rta_getattr_u64(tb[IFLA_BR_MCAST_MEMBERSHIP_INTVL]));
+		print_lluint(PRINT_ANY,
+			     "mcast_membership_intvl",
+			     "mcast_membership_interval %llu ",
+			     rta_getattr_u64(tb[IFLA_BR_MCAST_MEMBERSHIP_INTVL]));
 
 	if (tb[IFLA_BR_MCAST_QUERIER_INTVL])
-		fprintf(f, "mcast_querier_interval %llu ",
-			rta_getattr_u64(tb[IFLA_BR_MCAST_QUERIER_INTVL]));
+		print_lluint(PRINT_ANY,
+			     "mcast_querier_intvl",
+			     "mcast_querier_interval %llu ",
+			     rta_getattr_u64(tb[IFLA_BR_MCAST_QUERIER_INTVL]));
 
 	if (tb[IFLA_BR_MCAST_QUERY_INTVL])
-		fprintf(f, "mcast_query_interval %llu ",
-			rta_getattr_u64(tb[IFLA_BR_MCAST_QUERY_INTVL]));
+		print_lluint(PRINT_ANY,
+			     "mcast_query_intvl",
+			     "mcast_query_interval %llu ",
+			     rta_getattr_u64(tb[IFLA_BR_MCAST_QUERY_INTVL]));
 
 	if (tb[IFLA_BR_MCAST_QUERY_RESPONSE_INTVL])
-		fprintf(f, "mcast_query_response_interval %llu ",
-			rta_getattr_u64(tb[IFLA_BR_MCAST_QUERY_RESPONSE_INTVL]));
+		print_lluint(PRINT_ANY,
+			     "mcast_query_response_intvl",
+			     "mcast_query_response_interval %llu ",
+			     rta_getattr_u64(tb[IFLA_BR_MCAST_QUERY_RESPONSE_INTVL]));
 
 	if (tb[IFLA_BR_MCAST_STARTUP_QUERY_INTVL])
-		fprintf(f, "mcast_startup_query_interval %llu ",
-			rta_getattr_u64(tb[IFLA_BR_MCAST_STARTUP_QUERY_INTVL]));
+		print_lluint(PRINT_ANY,
+			     "mcast_startup_query_intvl",
+			     "mcast_startup_query_interval %llu ",
+			     rta_getattr_u64(tb[IFLA_BR_MCAST_STARTUP_QUERY_INTVL]));
 
 	if (tb[IFLA_BR_MCAST_STATS_ENABLED])
-		fprintf(f, "mcast_stats_enabled %u ",
-			rta_getattr_u8(tb[IFLA_BR_MCAST_STATS_ENABLED]));
+		print_uint(PRINT_ANY,
+			   "mcast_stats_enabled",
+			   "mcast_stats_enabled %u ",
+			   rta_getattr_u8(tb[IFLA_BR_MCAST_STATS_ENABLED]));
 
 	if (tb[IFLA_BR_MCAST_IGMP_VERSION])
-		fprintf(f, "mcast_igmp_version %u ",
-			rta_getattr_u8(tb[IFLA_BR_MCAST_IGMP_VERSION]));
+		print_uint(PRINT_ANY,
+			   "mcast_igmp_version",
+			   "mcast_igmp_version %u ",
+			   rta_getattr_u8(tb[IFLA_BR_MCAST_IGMP_VERSION]));
 
 	if (tb[IFLA_BR_MCAST_MLD_VERSION])
-		fprintf(f, "mcast_mld_version %u ",
-			rta_getattr_u8(tb[IFLA_BR_MCAST_MLD_VERSION]));
+		print_uint(PRINT_ANY,
+			   "mcast_mld_version",
+			   "mcast_mld_version %u ",
+			   rta_getattr_u8(tb[IFLA_BR_MCAST_MLD_VERSION]));
 
 	if (tb[IFLA_BR_NF_CALL_IPTABLES])
-		fprintf(f, "nf_call_iptables %u ",
-			rta_getattr_u8(tb[IFLA_BR_NF_CALL_IPTABLES]));
+		print_uint(PRINT_ANY,
+			   "nf_call_iptables",
+			   "nf_call_iptables %u ",
+			   rta_getattr_u8(tb[IFLA_BR_NF_CALL_IPTABLES]));
 
 	if (tb[IFLA_BR_NF_CALL_IP6TABLES])
-		fprintf(f, "nf_call_ip6tables %u ",
-			rta_getattr_u8(tb[IFLA_BR_NF_CALL_IP6TABLES]));
+		print_uint(PRINT_ANY,
+			   "nf_call_ip6tables",
+			   "nf_call_ip6tables %u ",
+			   rta_getattr_u8(tb[IFLA_BR_NF_CALL_IP6TABLES]));
 
 	if (tb[IFLA_BR_NF_CALL_ARPTABLES])
-		fprintf(f, "nf_call_arptables %u ",
-			rta_getattr_u8(tb[IFLA_BR_NF_CALL_ARPTABLES]));
+		print_uint(PRINT_ANY,
+			   "nf_call_arptables",
+			   "nf_call_arptables %u ",
+			   rta_getattr_u8(tb[IFLA_BR_NF_CALL_ARPTABLES]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-		FILE *f)
+			      FILE *f)
 {
 	print_explain(f);
 }
-- 
2.14.1
