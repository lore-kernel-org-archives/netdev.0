From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 02/21] iplink: bridge: export root_(port|path_cost), topology_change and change_detected
Date: Mon,  8 Feb 2016 12:55:08 +0100
Message-ID: <1454932527-30569-3-git-send-email-razor@blackwall.org>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37214 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbcBHL4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 06:56:11 -0500
Received: by mail-wm0-f41.google.com with SMTP id g62so112738287wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 03:56:10 -0800 (PST)
In-Reply-To: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Netlink already export these values, we just need to make them visible.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 6978e58e6b74..d9a725b0be0f 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -180,6 +180,22 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 				  sizeof(root_id));
 		fprintf(f, "designated_root %s ", root_id);
 	}
+
+	if (tb[IFLA_BR_ROOT_PORT])
+		fprintf(f, "root_port %u ",
+			rta_getattr_u16(tb[IFLA_BR_ROOT_PORT]));
+
+	if (tb[IFLA_BR_ROOT_PATH_COST])
+		fprintf(f, "root_path_cost %u ",
+			rta_getattr_u32(tb[IFLA_BR_ROOT_PATH_COST]));
+
+	if (tb[IFLA_BR_TOPOLOGY_CHANGE])
+		fprintf(f, "topology_change %u ",
+			rta_getattr_u8(tb[IFLA_BR_TOPOLOGY_CHANGE]));
+
+	if (tb[IFLA_BR_TOPOLOGY_CHANGE_DETECTED])
+		fprintf(f, "topology_change_detected %u ",
+			rta_getattr_u8(tb[IFLA_BR_TOPOLOGY_CHANGE_DETECTED]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
