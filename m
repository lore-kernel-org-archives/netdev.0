From: Jens Rosenboom <me@jayr.de>
Subject: [PATCH] ipv6: Log the affected address when DAD failure occurs
Date: Wed, 16 Sep 2009 13:44:37 +0200
Message-ID: <1253101477.10715.8.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Linux Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:37840 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754150AbZIPLol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 07:44:41 -0400
Received: from fnki-ws00028.freenet-ag.de ([194.97.6.48])
	by leia.mcbone.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <me@jayr.de>)
	id 1MnswG-00088o-Dl
	for netdev@vger.kernel.org; Wed, 16 Sep 2009 11:44:44 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Rosenboom <me@jayr.de>

If an interface has multiple addresses, the current message for DAD
failure isn't really helpful, so this patch adds the address itself to
the printk.

Signed-off-by: Jens Rosenboom <me@jayr.de>

---
This is a resubmit of http://patchwork.ozlabs.org/patch/31196/ which
erroneously was marked as superseded, but using the new compact output format.

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c9b3690..907a6f7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1405,8 +1405,8 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 	struct inet6_dev *idev = ifp->idev;
 
 	if (net_ratelimit())
-		printk(KERN_INFO "%s: IPv6 duplicate address detected!\n",
-			ifp->idev->dev->name);
+		printk(KERN_INFO "%s: IPv6 duplicate address %pI6c detected!\n",
+			ifp->idev->dev->name, &ifp->addr);
 
 	if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
 		struct in6_addr addr;


