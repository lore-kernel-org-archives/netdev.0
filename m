From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 2/2][IPV6] Use sysctl paths to register ipv6 sysctl
 tables
Date: Mon, 03 Dec 2007 14:26:29 +0300
Message-ID: <4753E7E5.6010400@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36516 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbXLCL0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 06:26:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes the ipv6.ko smaller and creates the ground needed
for net namespaces support in ipv6.ko ssctls.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 227efa7..0b5bec3 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -82,31 +82,17 @@ static ctl_table ipv6_table[] = {
 	{ .ctl_name = 0 }
 };
 
-static struct ctl_table_header *ipv6_sysctl_header;
-
-static ctl_table ipv6_net_table[] = {
-	{
-		.ctl_name	= NET_IPV6,
-		.procname	= "ipv6",
-		.mode		= 0555,
-		.child		= ipv6_table
-	},
-	{ .ctl_name = 0 }
+static struct ctl_path ipv6_ctl_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "ipv6", .ctl_name = NET_IPV6, },
+	{ },
 };
 
-static ctl_table ipv6_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= ipv6_net_table
-	},
-	{ .ctl_name = 0 }
-};
+static struct ctl_table_header *ipv6_sysctl_header;
 
 void ipv6_sysctl_register(void)
 {
-	ipv6_sysctl_header = register_sysctl_table(ipv6_root_table);
+	ipv6_sysctl_header = register_sysctl_paths(ipv6_ctl_path, ipv6_table);
 }
 
 void ipv6_sysctl_unregister(void)
-- 
1.5.3.4

