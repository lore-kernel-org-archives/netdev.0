From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 5/5] iplink: bridge_slave: add support for IFLA_BRPORT_FAST_LEAVE
Date: Tue, 16 Feb 2016 16:08:55 +0100
Message-ID: <1455635335-9973-6-git-send-email-razor@blackwall.org>
References: <1455635335-9973-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36912 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932234AbcBPPJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 10:09:35 -0500
Received: by mail-wm0-f49.google.com with SMTP id g62so157093598wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 07:09:34 -0800 (PST)
In-Reply-To: <1455635335-9973-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add support to be able to view and change IFLA_BRPORT_FAST_LEAVE
port attribute.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge_slave.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index 16b364f6bdce..3ec2bba72224 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -32,6 +32,7 @@ static void print_explain(FILE *f)
 		"                        [ proxy_arp {on | off} ]\n"
 		"                        [ proxy_arp_wifi {on | off} ]\n"
 		"                        [ mcast_router MULTICAST_ROUTER ]\n"
+		"                        [ mcast_fast_leave {on | off} ]\n"
 	);
 }
 
@@ -182,6 +183,10 @@ static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
 	if (tb[IFLA_BRPORT_MULTICAST_ROUTER])
 		fprintf(f, "mcast_router %u ",
 			rta_getattr_u8(tb[IFLA_BRPORT_MULTICAST_ROUTER]));
+
+	if (tb[IFLA_BRPORT_FAST_LEAVE])
+		print_onoff(f, "mcast_fast_leave",
+			    rta_getattr_u8(tb[IFLA_BRPORT_FAST_LEAVE]));
 }
 
 static void bridge_slave_parse_on_off(char *arg_name, char *arg_val,
@@ -262,6 +267,10 @@ static int bridge_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 				invarg("invalid mcast_router", *argv);
 			addattr8(n, 1024, IFLA_BRPORT_MULTICAST_ROUTER,
 				 mcast_router);
+		} else if (matches(*argv, "mcast_fast_leave") == 0) {
+			NEXT_ARG();
+			bridge_slave_parse_on_off("mcast_fast_leave", *argv, n,
+						  IFLA_BRPORT_FAST_LEAVE);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
-- 
2.4.3
