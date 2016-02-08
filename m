From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 07/21] iplink: bridge: add support for IFLA_BR_MCAST_ROUTER
Date: Mon,  8 Feb 2016 12:55:13 +0100
Message-ID: <1454932527-30569-8-git-send-email-razor@blackwall.org>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:32806 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbcBHL4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 06:56:15 -0500
Received: by mail-wm0-f46.google.com with SMTP id g62so129380186wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 03:56:14 -0800 (PST)
In-Reply-To: <1454932527-30569-1-git-send-email-razor@blackwall.org>
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
index e8bc66b498b3..11577a8994a3 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -32,6 +32,7 @@ static void print_explain(FILE *f)
 		"                  [ vlan_filtering VLAN_FILTERING ]\n"
 		"                  [ vlan_protocol VLAN_PROTOCOL ]\n"
 		"                  [ vlan_default_pvid VLAN_DEFAULT_PVID ]\n"
+		"                  [ mcast_router MULTICAST_ROUTER ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -139,6 +140,14 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 
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
@@ -258,6 +267,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
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
