From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2 3/3] iplink: shortify printing the usage of link type
Date: Wed, 12 Aug 2015 06:03:24 +0000
Message-ID: <1439359404-5085-4-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1439359404-5085-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2372 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933637AbbHLGAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 02:00:24 -0400
In-Reply-To: <1439359404-5085-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow to print link type usage by: ip link help bridge_slave

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/iplink_bridge_slave.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index a285185..4593872 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -19,9 +19,9 @@
 #include "utils.h"
 #include "ip_common.h"
 
-static void explain(void)
+static void print_explain(FILE *f)
 {
-	fprintf(stderr,
+	fprintf(f,
 		"Usage: ... bridge_slave [ state STATE ] [ priority PRIO ] [cost COST ]\n"
 		"                        [ guard {on | off} ]\n"
 		"                        [ hairpin {on | off} ] \n"
@@ -32,6 +32,11 @@ static void explain(void)
 	);
 }
 
+static void explain(void)
+{
+	print_explain(stderr);
+}
+
 static const char *port_states[] = {
 	[BR_STATE_DISABLED] = "disabled",
 	[BR_STATE_LISTENING] = "listening",
@@ -172,10 +177,17 @@ static int bridge_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 	return 0;
 }
 
+static void bridge_slave_print_help(struct link_util *lu, int argc, char **argv,
+		FILE *f)
+{
+	print_explain(f);
+}
+
 struct link_util bridge_slave_link_util = {
 	.id		= "bridge",
 	.maxattr	= IFLA_BRPORT_MAX,
 	.print_opt	= bridge_slave_print_opt,
 	.parse_opt	= bridge_slave_parse_opt,
+	.print_help     = bridge_slave_print_help,
 	.slave		= true,
 };
-- 
1.8.3.1
