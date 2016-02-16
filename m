From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 2/5] iplink: bridge_slave: add support for IFLA_BRPORT_PROXYARP
Date: Tue, 16 Feb 2016 16:08:52 +0100
Message-ID: <1455635335-9973-3-git-send-email-razor@blackwall.org>
References: <1455635335-9973-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38612 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932345AbcBPPJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 10:09:32 -0500
Received: by mail-wm0-f54.google.com with SMTP id a4so104628079wme.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 07:09:31 -0800 (PST)
In-Reply-To: <1455635335-9973-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add support to be able to view and change IFLA_BRPORT_PROXYARP port
attribute.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge_slave.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index c58f55294261..c27d71837a2f 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -29,6 +29,7 @@ static void print_explain(FILE *f)
 		"                        [ root_block {on | off} ]\n"
 		"                        [ learning {on | off} ]\n"
 		"                        [ flood {on | off} ]\n"
+		"                        [ proxy_arp {on | off} ]\n"
 	);
 }
 
@@ -168,6 +169,9 @@ static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
 	if (tb[IFLA_BRPORT_CONFIG_PENDING])
 		fprintf(f, "config_pending %u ",
 			rta_getattr_u8(tb[IFLA_BRPORT_CONFIG_PENDING]));
+	if (tb[IFLA_BRPORT_PROXYARP])
+		print_onoff(f, "proxy_arp",
+			    rta_getattr_u8(tb[IFLA_BRPORT_PROXYARP]));
 }
 
 static void bridge_slave_parse_on_off(char *arg_name, char *arg_val,
@@ -232,6 +236,10 @@ static int bridge_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			bridge_slave_parse_on_off("flood", *argv, n,
 						  IFLA_BRPORT_UNICAST_FLOOD);
+		} else if (matches(*argv, "proxy_arp") == 0) {
+			NEXT_ARG();
+			bridge_slave_parse_on_off("proxy_arp", *argv, n,
+						  IFLA_BRPORT_PROXYARP);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
-- 
2.4.3
