From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 14/21] iplink: bridge: add support for IFLA_BR_MCAST_STARTUP_QUERY_CNT
Date: Mon,  8 Feb 2016 12:55:20 +0100
Message-ID: <1454932527-30569-15-git-send-email-razor@blackwall.org>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38752 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbcBHL4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 06:56:21 -0500
Received: by mail-wm0-f54.google.com with SMTP id p63so112135391wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 03:56:20 -0800 (PST)
In-Reply-To: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_MCAST_STARTUP_QUERY_CNT
attribute in iproute2 so it can change the startup query count.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index d98b126698e2..d10a9255eb56 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -39,6 +39,7 @@ static void print_explain(FILE *f)
 		"                  [ mcast_hash_elasticity HASH_ELASTICITY ]\n"
 		"                  [ mcast_hash_max HASH_MAX ]\n"
 		"                  [ mcast_last_member_count LAST_MEMBER_COUNT ]\n"
+		"                  [ mcast_startup_query_count STARTUP_QUERY_COUNT ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -209,6 +210,16 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 
 			addattr32(n, 1024, IFLA_BR_MCAST_LAST_MEMBER_CNT,
 				  mcast_lmc);
+		} else if (matches(*argv, "mcast_startup_query_count") == 0) {
+			__u32 mcast_sqc;
+
+			NEXT_ARG();
+			if (get_u32(&mcast_sqc, *argv, 0))
+				invarg("invalid mcast_startup_query_count",
+				       *argv);
+
+			addattr32(n, 1024, IFLA_BR_MCAST_STARTUP_QUERY_CNT,
+				  mcast_sqc);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -356,6 +367,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_MCAST_LAST_MEMBER_CNT])
 		fprintf(f, "mcast_last_member_count %u ",
 			rta_getattr_u32(tb[IFLA_BR_MCAST_LAST_MEMBER_CNT]));
+
+	if (tb[IFLA_BR_MCAST_STARTUP_QUERY_CNT])
+		fprintf(f, "mcast_startup_query_count %u ",
+			rta_getattr_u32(tb[IFLA_BR_MCAST_STARTUP_QUERY_CNT]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
