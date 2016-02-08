From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 04/21] iplink: bridge: add support for IFLA_BR_GROUP_FWD_MASK
Date: Mon,  8 Feb 2016 12:55:10 +0100
Message-ID: <1454932527-30569-5-git-send-email-razor@blackwall.org>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38598 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbcBHL4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 06:56:13 -0500
Received: by mail-wm0-f52.google.com with SMTP id p63so112130340wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 03:56:12 -0800 (PST)
In-Reply-To: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_GROUP_FWD_MASK attribute
in iproute2 so it can change the group forwarding mask.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 8504be5625fa..fb448f9f863d 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -27,6 +27,7 @@ static void print_explain(FILE *f)
 		"                  [ ageing_time AGEING_TIME ]\n"
 		"                  [ stp_state STP_STATE ]\n"
 		"                  [ priority PRIORITY ]\n"
+		"                  [ group_fwd_mask MASK ]\n"
 		"                  [ vlan_filtering VLAN_FILTERING ]\n"
 		"                  [ vlan_protocol VLAN_PROTOCOL ]\n"
 		"\n"
@@ -110,6 +111,14 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 				return -1;
 			}
 			addattr16(n, 1024, IFLA_BR_VLAN_PROTOCOL, vlan_proto);
+		} else if (matches(*argv, "group_fwd_mask") == 0) {
+			__u16 fwd_mask;
+
+			NEXT_ARG();
+			if (get_u16(&fwd_mask, *argv, 0))
+				invarg("invalid group_fwd_mask", *argv);
+
+			addattr16(n, 1024, IFLA_BR_GROUP_FWD_MASK, fwd_mask);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -212,6 +221,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_GC_TIMER])
 		fprintf(f, "gc_timer %llu ",
 			rta_getattr_u64(tb[IFLA_BR_GC_TIMER]));
+
+	if (tb[IFLA_BR_GROUP_FWD_MASK])
+		fprintf(f, "group_fwd_mask %#x ",
+			rta_getattr_u16(tb[IFLA_BR_GROUP_FWD_MASK]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
