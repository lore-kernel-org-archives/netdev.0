From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 11/21] iplink: bridge: add support for IFLA_BR_MCAST_HASH_ELASTICITY
Date: Tue,  9 Feb 2016 00:14:29 +0100
Message-ID: <1454973279-9170-12-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35138 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932564AbcBHXOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:53 -0500
Received: by mail-wm0-f46.google.com with SMTP id c200so37715218wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:53 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_MCAST_HASH_ELASTICTITY
attribute in iproute2 so it can change the hash elasticity value.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index fbea0a38fd41..93dcc982c623 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -37,6 +37,7 @@ static void print_explain(FILE *f)
 		"                  [ mcast_router MULTICAST_ROUTER ]\n"
 		"                  [ mcast_query_use_ifaddr MCAST_QUERY_USE_IFADDR ]\n"
 		"                  [ mcast_querier MULTICAST_QUERIER ]\n"
+		"                  [ mcast_hash_elasticity HASH_ELASTICITY ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -178,6 +179,16 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 				invarg("invalid mcast_querier", *argv);
 
 			addattr8(n, 1024, IFLA_BR_MCAST_QUERIER, mcast_querier);
+		} else if (matches(*argv, "mcast_hash_elasticity") == 0) {
+			__u32 mcast_hash_el;
+
+			NEXT_ARG();
+			if (get_u32(&mcast_hash_el, *argv, 0))
+				invarg("invalid mcast_hash_elasticity",
+				       *argv);
+
+			addattr32(n, 1024, IFLA_BR_MCAST_HASH_ELASTICITY,
+				  mcast_hash_el);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -331,6 +342,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_MCAST_QUERIER])
 		fprintf(f, "mcast_querier %u ",
 			rta_getattr_u8(tb[IFLA_BR_MCAST_QUERIER]));
+
+	if (tb[IFLA_BR_MCAST_HASH_ELASTICITY])
+		fprintf(f, "mcast_hash_elasticity %u ",
+			rta_getattr_u32(tb[IFLA_BR_MCAST_HASH_ELASTICITY]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
