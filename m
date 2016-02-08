From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 09/21] iplink: bridge: add support for IFLA_BR_MCAST_QUERY_USE_IFADDR
Date: Mon,  8 Feb 2016 12:55:15 +0100
Message-ID: <1454932527-30569-10-git-send-email-razor@blackwall.org>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37312 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbcBHL4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 06:56:17 -0500
Received: by mail-wm0-f46.google.com with SMTP id g62so112741456wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 03:56:16 -0800 (PST)
In-Reply-To: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_MCAST_QUERY_USE_IFADDR
attribute in iproute2 so it can toggle the multicast_query_use_ifaddr val.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 208d155df440..30f7b8014e2a 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -34,6 +34,7 @@ static void print_explain(FILE *f)
 		"                  [ vlan_default_pvid VLAN_DEFAULT_PVID ]\n"
 		"                  [ mcast_snooping MULTICAST_SNOOPING ]\n"
 		"                  [ mcast_router MULTICAST_ROUTER ]\n"
+		"                  [ mcast_query_use_ifaddr MCAST_QUERY_USE_IFADDR ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -157,6 +158,16 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 				invarg("invalid mcast_snooping", *argv);
 
 			addattr8(n, 1024, IFLA_BR_MCAST_SNOOPING, mcast_snoop);
+		} else if (matches(*argv, "mcast_query_use_ifaddr") == 0) {
+			__u8 mcast_qui;
+
+			NEXT_ARG();
+			if (get_u8(&mcast_qui, *argv, 0))
+				invarg("invalid mcast_query_use_ifaddr",
+				       *argv);
+
+			addattr8(n, 1024, IFLA_BR_MCAST_QUERY_USE_IFADDR,
+				 mcast_qui);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -284,6 +295,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_MCAST_ROUTER])
 		fprintf(f, "mcast_router %u ",
 			rta_getattr_u8(tb[IFLA_BR_MCAST_ROUTER]));
+
+	if (tb[IFLA_BR_MCAST_QUERY_USE_IFADDR])
+		fprintf(f, "mcast_query_use_ifaddr %u ",
+			rta_getattr_u8(tb[IFLA_BR_MCAST_QUERY_USE_IFADDR]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
