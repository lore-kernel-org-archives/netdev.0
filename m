From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 02/21] iplink: bridge: export root_(port|path_cost), topology_change and change_detected
Date: Tue,  9 Feb 2016 00:14:20 +0100
Message-ID: <1454973279-9170-3-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36345 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932527AbcBHXOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:46 -0500
Received: by mail-wm0-f46.google.com with SMTP id p63so135606008wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:45 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Netlink already export these values, we just need to make them visible.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 3bbbcaa120cf..33ffa6c27f03 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -181,6 +181,22 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
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
