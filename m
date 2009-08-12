From: Jens Rosenboom <jens@mcbone.net>
Subject: [PATCH] ipv6: Log the explicit address that triggered DAD failure
Date: Wed, 12 Aug 2009 16:58:27 +0200
Message-ID: <1250089107.6641.36.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Linux Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:55372 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752367AbZHLPpf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 11:45:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an interface has multiple addresses, the current message for DAD
failure isn't really helpful, so this patch adds the address itself to
the printk.

Signed-off-by: Jens Rosenboom <jens@mcbone.net>

---

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 43b3c9f..01a4b25 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1403,8 +1403,8 @@ void addrconf_dad_failure(struct inet6_ifaddr
*ifp)
 	struct inet6_dev *idev = ifp->idev;
 
 	if (net_ratelimit())
-		printk(KERN_INFO "%s: IPv6 duplicate address detected!\n",
-			ifp->idev->dev->name);
+		printk(KERN_INFO "%s: IPv6 duplicate address %pI6 detected!\n",
+			ifp->idev->dev->name, &ifp->addr);
 
 	if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
 		struct in6_addr addr;


