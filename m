From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 15/21] iplink: bridge: add support for IFLA_BR_MCAST_LAST_MEMBER_INTVL
Date: Tue,  9 Feb 2016 00:14:33 +0100
Message-ID: <1454973279-9170-16-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37436 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932551AbcBHXO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:57 -0500
Received: by mail-wm0-f53.google.com with SMTP id g62so861361wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:56 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_MCAST_LAST_MEMBER_INTVL
attribute in iproute2 so it can change the last member interval.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 58c19a1f0920..9522c3f1918e 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -41,6 +41,7 @@ static void print_explain(FILE *f)
 		"                  [ mcast_hash_max HASH_MAX ]\n"
 		"                  [ mcast_last_member_count LAST_MEMBER_COUNT ]\n"
 		"                  [ mcast_startup_query_count STARTUP_QUERY_COUNT ]\n"
+		"                  [ mcast_last_member_interval LAST_MEMBER_INTERVAL ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -221,6 +222,16 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 
 			addattr32(n, 1024, IFLA_BR_MCAST_STARTUP_QUERY_CNT,
 				  mcast_sqc);
+		} else if (matches(*argv, "mcast_last_member_interval") == 0) {
+			__u64 mcast_last_member_intvl;
+
+			NEXT_ARG();
+			if (get_u64(&mcast_last_member_intvl, *argv, 0))
+				invarg("invalid mcast_last_member_interval",
+				       *argv);
+
+			addattr64(n, 1024, IFLA_BR_MCAST_LAST_MEMBER_INTVL,
+				  mcast_last_member_intvl);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -390,6 +401,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_MCAST_STARTUP_QUERY_CNT])
 		fprintf(f, "mcast_startup_query_count %u ",
 			rta_getattr_u32(tb[IFLA_BR_MCAST_STARTUP_QUERY_CNT]));
+
+	if (tb[IFLA_BR_MCAST_LAST_MEMBER_INTVL])
+		fprintf(f, "mcast_last_member_interval %llu ",
+			rta_getattr_u64(tb[IFLA_BR_MCAST_LAST_MEMBER_INTVL]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
