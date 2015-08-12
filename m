From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2 2/3] iplink: use the short format to print help info
Date: Wed, 12 Aug 2015 06:03:23 +0000
Message-ID: <1439359404-5085-3-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1439359404-5085-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3356 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933602AbbHLGAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 02:00:24 -0400
In-Reply-To: <1439359404-5085-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow to print link type usage by: ip link help bridge

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/iplink_bridge.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 297160c..1e69960 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -17,9 +17,9 @@
 #include "utils.h"
 #include "ip_common.h"
 
-static void explain(void)
+static void print_explain(FILE *f)
 {
-	fprintf(stderr,
+	fprintf(f,
 		"Usage: ... bridge [ forward_delay FORWARD_DELAY ]\n"
 		"                  [ hello_time HELLO_TIME ]\n"
 		"                  [ max_age MAX_AGE ]\n"
@@ -29,6 +29,11 @@ static void explain(void)
 	);
 }
 
+static void explain(void)
+{
+	print_explain(stderr);
+}
+
 static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 			    struct nlmsghdr *n)
 {
@@ -111,9 +116,16 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			rta_getattr_u32(tb[IFLA_BR_MAX_AGE]));
 }
 
+static void bridge_print_help(struct link_util *lu, int argc, char **argv,
+		FILE *f)
+{
+	print_explain(f);
+}
+
 struct link_util bridge_link_util = {
 	.id		= "bridge",
 	.maxattr	= IFLA_BR_MAX,
 	.parse_opt	= bridge_parse_opt,
 	.print_opt	= bridge_print_opt,
+	.print_help     = bridge_print_help,
 };
-- 
1.8.3.1
