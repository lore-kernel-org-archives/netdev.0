From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NETNS]: Don't initialize err variable twice.
Date: Mon, 21 Apr 2008 17:07:53 +0400
Message-ID: <480C91A9.4030004@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52535 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756771AbYDUNJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 09:09:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip6_route_net_init() performs some unneeded actions.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 210a079..7f82e80 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2614,7 +2614,7 @@ struct ctl_table *ipv6_route_sysctl_init(struct net *net)
 
 static int ip6_route_net_init(struct net *net)
 {
-	int ret = 0;
+	int ret;
 
 	ret = -ENOMEM;
 	net->ipv6.ip6_dst_ops = kmemdup(&ip6_dst_ops_template,
