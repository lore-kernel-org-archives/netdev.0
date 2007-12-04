From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 8/11][IPV6] Use sysctl paths to register ipv6 sysctl
 tables
Date: Tue, 04 Dec 2007 13:13:11 +0300
Message-ID: <47552837.8080205@openvz.org>
References: <4755256F.9000505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39221 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248AbXLDKN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 05:13:28 -0500
In-Reply-To: <4755256F.9000505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have already done this for core, ipv4 and tr tables, so
repeat this for the ipv6 ones.

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

