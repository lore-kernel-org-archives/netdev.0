From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 07/21] iplink: bridge: add support for IFLA_BR_MCAST_ROUTER
Date: Tue,  9 Feb 2016 00:14:25 +0100
Message-ID: <1454973279-9170-8-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37362 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932551AbcBHXOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:50 -0500
Received: by mail-wm0-f53.google.com with SMTP id g62so858911wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:50 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_MCAST_ROUTER attribute
in iproute2 so it can change the multicast router value.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 9a8924c2ee82..7a945ed2ae63 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -33,6 +33,7 @@ static void print_explain(FILE *f)
 		"                  [ vlan_filtering VLAN_FILTERING ]\n"
 		"                  [ vlan_protocol VLAN_PROTOCOL ]\n"
 		"                  [ vlan_default_pvid VLAN_DEFAULT_PVID ]\n"
+		"                  [ mcast_router MULTICAST_ROUTER ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -140,6 +141,14 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 
 			addattr16(n, 1024, IFLA_BR_VLAN_DEFAULT_PVID,
 				  default_pvid);
+		} else if (matches(*argv, "mcast_router") == 0) {
+			__u8 mcast_router;
+
+			NEXT_ARG();
+			if (get_u8(&mcast_router, *argv, 0))
+				invarg("invalid mcast_router", *argv);
+
+			addattr8(n, 1024, IFLA_BR_MCAST_ROUTER, mcast_router);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -277,6 +286,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 				    RTA_PAYLOAD(tb[IFLA_BR_GROUP_ADDR]),
 				    1 /*ARPHDR_ETHER*/, mac, sizeof(mac)));
 	}
+
+	if (tb[IFLA_BR_MCAST_ROUTER])
+		fprintf(f, "mcast_router %u ",
+			rta_getattr_u8(tb[IFLA_BR_MCAST_ROUTER]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
