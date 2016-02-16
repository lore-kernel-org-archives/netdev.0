From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 3/5] iplink: bridge_slave: add support for IFLA_BRPORT_PROXYARP_WIFI
Date: Tue, 16 Feb 2016 16:08:53 +0100
Message-ID: <1455635335-9973-4-git-send-email-razor@blackwall.org>
References: <1455635335-9973-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34491 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233AbcBPPJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 10:09:33 -0500
Received: by mail-wm0-f45.google.com with SMTP id b205so114325029wmb.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 07:09:32 -0800 (PST)
In-Reply-To: <1455635335-9973-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add support to be able to view and change IFLA_BRPORT_PROXYARP_WIFI port
attribute.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge_slave.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index c27d71837a2f..68d140894529 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -30,6 +30,7 @@ static void print_explain(FILE *f)
 		"                        [ learning {on | off} ]\n"
 		"                        [ flood {on | off} ]\n"
 		"                        [ proxy_arp {on | off} ]\n"
+		"                        [ proxy_arp_wifi {on | off} ]\n"
 	);
 }
 
@@ -172,6 +173,10 @@ static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
 	if (tb[IFLA_BRPORT_PROXYARP])
 		print_onoff(f, "proxy_arp",
 			    rta_getattr_u8(tb[IFLA_BRPORT_PROXYARP]));
+
+	if (tb[IFLA_BRPORT_PROXYARP_WIFI])
+		print_onoff(f, "proxy_arp_wifi",
+			    rta_getattr_u8(tb[IFLA_BRPORT_PROXYARP_WIFI]));
 }
 
 static void bridge_slave_parse_on_off(char *arg_name, char *arg_val,
@@ -240,6 +245,10 @@ static int bridge_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			bridge_slave_parse_on_off("proxy_arp", *argv, n,
 						  IFLA_BRPORT_PROXYARP);
+		} else if (matches(*argv, "proxy_arp_wifi") == 0) {
+			NEXT_ARG();
+			bridge_slave_parse_on_off("proxy_arp_wifi", *argv, n,
+						  IFLA_BRPORT_PROXYARP_WIFI);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
-- 
2.4.3
