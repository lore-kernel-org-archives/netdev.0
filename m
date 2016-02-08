From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 01/21] iplink: bridge: export bridge_id and designated_root
Date: Mon,  8 Feb 2016 12:55:07 +0100
Message-ID: <1454932527-30569-2-git-send-email-razor@blackwall.org>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38558 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbcBHL4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 06:56:11 -0500
Received: by mail-wm0-f48.google.com with SMTP id p63so112128872wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 03:56:10 -0800 (PST)
In-Reply-To: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Netlink returns the bridge_id and designated_root, we just need to
make them visible.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 00804093dcb5..6978e58e6b74 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -39,6 +39,15 @@ static void explain(void)
 	print_explain(stderr);
 }
 
+static void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf,
+			      size_t len)
+{
+	const unsigned char *x = (const unsigned char *)id;
+
+	snprintf(buf, len, "%.2x%.2x.%.2x%.2x%.2x%.2x%.2x%.2x", x[0], x[1],
+		 x[2], x[3], x[4], x[5], x[6], x[7]);
+}
+
 static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 			    struct nlmsghdr *n)
 {
@@ -155,6 +164,22 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			ll_proto_n2a(rta_getattr_u16(tb[IFLA_BR_VLAN_PROTOCOL]),
 				     b1, sizeof(b1)));
 	}
+
+	if (tb[IFLA_BR_BRIDGE_ID]) {
+		char bridge_id[32];
+
+		br_dump_bridge_id(RTA_DATA(tb[IFLA_BR_BRIDGE_ID]), bridge_id,
+				  sizeof(bridge_id));
+		fprintf(f, "bridge_id %s ", bridge_id);
+	}
+
+	if (tb[IFLA_BR_ROOT_ID]) {
+		char root_id[32];
+
+		br_dump_bridge_id(RTA_DATA(tb[IFLA_BR_BRIDGE_ID]), root_id,
+				  sizeof(root_id));
+		fprintf(f, "designated_root %s ", root_id);
+	}
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
