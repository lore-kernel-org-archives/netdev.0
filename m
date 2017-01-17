From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 net-next 2/5] iplink: bridge: add support for IFLA_BR_VLAN_STATS_ENABLED
Date: Tue, 17 Jan 2017 17:32:29 +0800
Message-ID: <1484645552-29440-3-git-send-email-liuhangbin@gmail.com>
References: <1484645552-29440-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34216 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbdAQJls (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 04:41:48 -0500
Received: by mail-pg0-f66.google.com with SMTP id t6so3516390pgt.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 01:41:48 -0800 (PST)
In-Reply-To: <1484645552-29440-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements support for the IFLA_BR_VLAN_STATS_ENABLED
attribute in iproute2 so it can change the vlan state.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iplink_bridge.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 85e6597..8caf53a 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -34,6 +34,7 @@ static void print_explain(FILE *f)
 		"                  [ vlan_filtering VLAN_FILTERING ]\n"
 		"                  [ vlan_protocol VLAN_PROTOCOL ]\n"
 		"                  [ vlan_default_pvid VLAN_DEFAULT_PVID ]\n"
+		"                  [ vlan_state VLAN_STATE ]\n"
 		"                  [ mcast_snooping MULTICAST_SNOOPING ]\n"
 		"                  [ mcast_router MULTICAST_ROUTER ]\n"
 		"                  [ mcast_query_use_ifaddr MCAST_QUERY_USE_IFADDR ]\n"
@@ -157,6 +158,14 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 
 			addattr16(n, 1024, IFLA_BR_VLAN_DEFAULT_PVID,
 				  default_pvid);
+		} else if (matches(*argv, "vlan_state") == 0) {
+			__u8 vlan_state;
+
+			NEXT_ARG();
+			if (get_u8(&vlan_state, *argv, 0))
+				invarg("invalid vlan_state", *argv);
+			addattr8(n, 1024, IFLA_BR_VLAN_STATS_ENABLED,
+				  vlan_state);
 		} else if (matches(*argv, "mcast_router") == 0) {
 			__u8 mcast_router;
 
@@ -442,6 +451,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fprintf(f, "vlan_default_pvid %u ",
 			rta_getattr_u16(tb[IFLA_BR_VLAN_DEFAULT_PVID]));
 
+	if (tb[IFLA_BR_VLAN_STATS_ENABLED])
+		fprintf(f, "vlan_state %u ",
+			rta_getattr_u8(tb[IFLA_BR_VLAN_STATS_ENABLED]));
+
 	if (tb[IFLA_BR_GROUP_FWD_MASK])
 		fprintf(f, "group_fwd_mask %#x ",
 			rta_getattr_u16(tb[IFLA_BR_GROUP_FWD_MASK]));
-- 
2.5.5
