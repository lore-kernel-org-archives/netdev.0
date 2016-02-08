From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 18/21] iplink: bridge: add support for IFLA_BR_MCAST_QUERY_INTVL
Date: Tue,  9 Feb 2016 00:14:36 +0100
Message-ID: <1454973279-9170-19-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38044 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932593AbcBHXO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:59 -0500
Received: by mail-wm0-f54.google.com with SMTP id p63so833109wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:58 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_MCAST_QUERY_INTVL attribute
in iproute2 so it can change the query interval.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 1138e6ee7599..16fc0d31c90f 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -44,6 +44,7 @@ static void print_explain(FILE *f)
 		"                  [ mcast_last_member_interval LAST_MEMBER_INTERVAL ]\n"
 		"                  [ mcast_membership_interval MEMBERSHIP_INTERVAL ]\n"
 		"                  [ mcast_querier_interval QUERIER_INTERVAL ]\n"
+		"                  [ mcast_query_interval QUERY_INTERVAL ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -256,6 +257,17 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 			}
 			addattr64(n, 1024, IFLA_BR_MCAST_QUERIER_INTVL,
 				  mcast_querier_intvl);
+		} else if (matches(*argv, "mcast_query_interval") == 0) {
+			__u64 mcast_query_intvl;
+
+			NEXT_ARG();
+			if (get_u64(&mcast_query_intvl, *argv, 0)) {
+				invarg("invalid mcast_query_interval",
+				       *argv);
+				return -1;
+			}
+			addattr64(n, 1024, IFLA_BR_MCAST_QUERY_INTVL,
+				  mcast_query_intvl);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -437,6 +449,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_MCAST_QUERIER_INTVL])
 		fprintf(f, "mcast_querier_interval %llu ",
 			rta_getattr_u64(tb[IFLA_BR_MCAST_QUERIER_INTVL]));
+
+	if (tb[IFLA_BR_MCAST_QUERY_INTVL])
+		fprintf(f, "mcast_query_interval %llu ",
+			rta_getattr_u64(tb[IFLA_BR_MCAST_QUERY_INTVL]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
