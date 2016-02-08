From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 06/21] iplink: bridge: add support for IFLA_BR_VLAN_DEFAULT_PVID
Date: Tue,  9 Feb 2016 00:14:24 +0100
Message-ID: <1454973279-9170-7-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:33163 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932548AbcBHXOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:49 -0500
Received: by mail-wm0-f49.google.com with SMTP id g62so153223024wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:49 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_VLAN_DEFAULT_PVID
attribute in iproute2 so it can change the default pvid.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 0a2845027acb..9a8924c2ee82 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -32,6 +32,7 @@ static void print_explain(FILE *f)
 		"                  [ group_address ADDRESS ]\n"
 		"                  [ vlan_filtering VLAN_FILTERING ]\n"
 		"                  [ vlan_protocol VLAN_PROTOCOL ]\n"
+		"                  [ vlan_default_pvid VLAN_DEFAULT_PVID ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -130,6 +131,15 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 			if (len < 0)
 				return -1;
 			addattr_l(n, 1024, IFLA_BR_GROUP_ADDR, llabuf, len);
+		} else if (matches(*argv, "vlan_default_pvid") == 0) {
+			__u16 default_pvid;
+
+			NEXT_ARG();
+			if (get_u16(&default_pvid, *argv, 0))
+				invarg("invalid vlan_default_pvid", *argv);
+
+			addattr16(n, 1024, IFLA_BR_VLAN_DEFAULT_PVID,
+				  default_pvid);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -251,6 +261,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			(int)tv.tv_usec/10000);
 	}
 
+	if (tb[IFLA_BR_VLAN_DEFAULT_PVID])
+		fprintf(f, "vlan_default_pvid %u ",
+			rta_getattr_u16(tb[IFLA_BR_VLAN_DEFAULT_PVID]));
+
 	if (tb[IFLA_BR_GROUP_FWD_MASK])
 		fprintf(f, "group_fwd_mask %#x ",
 			rta_getattr_u16(tb[IFLA_BR_GROUP_FWD_MASK]));
-- 
2.4.3
