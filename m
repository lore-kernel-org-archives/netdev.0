From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 12/21] iplink: bridge: add support for IFLA_BR_MCAST_HASH_MAX
Date: Mon,  8 Feb 2016 12:55:18 +0100
Message-ID: <1454932527-30569-13-git-send-email-razor@blackwall.org>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36222 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbcBHL4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 06:56:19 -0500
Received: by mail-wm0-f42.google.com with SMTP id p63so109816272wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 03:56:18 -0800 (PST)
In-Reply-To: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_MCAST_HASH_MAX attribute
in iproute2 so it can change the maximum hashed entries.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 14aae3e9b0d2..d15bd45dcdf6 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -37,6 +37,7 @@ static void print_explain(FILE *f)
 		"                  [ mcast_query_use_ifaddr MCAST_QUERY_USE_IFADDR ]\n"
 		"                  [ mcast_querier MULTICAST_QUERIER ]\n"
 		"                  [ mcast_hash_elasticity HASH_ELASTICITY ]\n"
+		"                  [ mcast_hash_max HASH_MAX ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -188,6 +189,15 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 
 			addattr32(n, 1024, IFLA_BR_MCAST_HASH_ELASTICITY,
 				  mcast_hash_el);
+		} else if (matches(*argv, "mcast_hash_max") == 0) {
+			__u32 mcast_hash_max;
+
+			NEXT_ARG();
+			if (get_u32(&mcast_hash_max, *argv, 0))
+				invarg("invalid mcast_hash_max", *argv);
+
+			addattr32(n, 1024, IFLA_BR_MCAST_HASH_MAX,
+				  mcast_hash_max);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -327,6 +337,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_MCAST_HASH_ELASTICITY])
 		fprintf(f, "mcast_hash_elasticity %u ",
 			rta_getattr_u32(tb[IFLA_BR_MCAST_HASH_ELASTICITY]));
+
+	if (tb[IFLA_BR_MCAST_HASH_MAX])
+		fprintf(f, "mcast_hash_max %u ",
+			rta_getattr_u32(tb[IFLA_BR_MCAST_HASH_MAX]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
