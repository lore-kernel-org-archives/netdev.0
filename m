From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 12/21] iplink: bridge: add support for IFLA_BR_MCAST_HASH_MAX
Date: Tue,  9 Feb 2016 00:14:30 +0100
Message-ID: <1454973279-9170-13-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37409 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932551AbcBHXOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:54 -0500
Received: by mail-wm0-f52.google.com with SMTP id g62so860479wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:54 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
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
index 93dcc982c623..f912c318c24a 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -38,6 +38,7 @@ static void print_explain(FILE *f)
 		"                  [ mcast_query_use_ifaddr MCAST_QUERY_USE_IFADDR ]\n"
 		"                  [ mcast_querier MULTICAST_QUERIER ]\n"
 		"                  [ mcast_hash_elasticity HASH_ELASTICITY ]\n"
+		"                  [ mcast_hash_max HASH_MAX ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -189,6 +190,15 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 
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
@@ -346,6 +356,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
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
