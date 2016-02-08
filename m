From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 13/21] iplink: bridge: add support for IFLA_BR_MCAST_LAST_MEMBER_CNT
Date: Tue,  9 Feb 2016 00:14:31 +0100
Message-ID: <1454973279-9170-14-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34061 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932575AbcBHXOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:55 -0500
Received: by mail-wm0-f43.google.com with SMTP id 128so175353444wmz.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:54 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_MCAST_LAST_MEMBER_CNT
attribute in iproute2 so it can change the last member count value.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index f912c318c24a..be83a5690d39 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -39,6 +39,7 @@ static void print_explain(FILE *f)
 		"                  [ mcast_querier MULTICAST_QUERIER ]\n"
 		"                  [ mcast_hash_elasticity HASH_ELASTICITY ]\n"
 		"                  [ mcast_hash_max HASH_MAX ]\n"
+		"                  [ mcast_last_member_count LAST_MEMBER_COUNT ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -199,6 +200,16 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 
 			addattr32(n, 1024, IFLA_BR_MCAST_HASH_MAX,
 				  mcast_hash_max);
+		} else if (matches(*argv, "mcast_last_member_count") == 0) {
+			__u32 mcast_lmc;
+
+			NEXT_ARG();
+			if (get_u32(&mcast_lmc, *argv, 0))
+				invarg("invalid mcast_last_member_count",
+				       *argv);
+
+			addattr32(n, 1024, IFLA_BR_MCAST_LAST_MEMBER_CNT,
+				  mcast_lmc);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -360,6 +371,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_MCAST_HASH_MAX])
 		fprintf(f, "mcast_hash_max %u ",
 			rta_getattr_u32(tb[IFLA_BR_MCAST_HASH_MAX]));
+
+	if (tb[IFLA_BR_MCAST_LAST_MEMBER_CNT])
+		fprintf(f, "mcast_last_member_count %u ",
+			rta_getattr_u32(tb[IFLA_BR_MCAST_LAST_MEMBER_CNT]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
