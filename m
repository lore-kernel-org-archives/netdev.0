From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 10/21] iplink: bridge: add support for IFLA_BR_MCAST_QUERIER
Date: Tue,  9 Feb 2016 00:14:28 +0100
Message-ID: <1454973279-9170-11-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33196 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932560AbcBHXOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:52 -0500
Received: by mail-wm0-f51.google.com with SMTP id g62so153224148wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:52 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_MCAST_QUERIER attribute
in iproute2 so it can toggle the mcast querier value.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index b802ef15eb1d..fbea0a38fd41 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -36,6 +36,7 @@ static void print_explain(FILE *f)
 		"                  [ mcast_snooping MULTICAST_SNOOPING ]\n"
 		"                  [ mcast_router MULTICAST_ROUTER ]\n"
 		"                  [ mcast_query_use_ifaddr MCAST_QUERY_USE_IFADDR ]\n"
+		"                  [ mcast_querier MULTICAST_QUERIER ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -169,6 +170,14 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 
 			addattr8(n, 1024, IFLA_BR_MCAST_QUERY_USE_IFADDR,
 				 mcast_qui);
+		} else if (matches(*argv, "mcast_querier") == 0) {
+			__u8 mcast_querier;
+
+			NEXT_ARG();
+			if (get_u8(&mcast_querier, *argv, 0))
+				invarg("invalid mcast_querier", *argv);
+
+			addattr8(n, 1024, IFLA_BR_MCAST_QUERIER, mcast_querier);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -318,6 +327,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_MCAST_QUERY_USE_IFADDR])
 		fprintf(f, "mcast_query_use_ifaddr %u ",
 			rta_getattr_u8(tb[IFLA_BR_MCAST_QUERY_USE_IFADDR]));
+
+	if (tb[IFLA_BR_MCAST_QUERIER])
+		fprintf(f, "mcast_querier %u ",
+			rta_getattr_u8(tb[IFLA_BR_MCAST_QUERIER]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
