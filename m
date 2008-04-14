From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6 1/2] [IPV6] ADDRCONF: Ensure disabling multicast RS
 even if privacy extensions are disabled.
Date: Mon, 14 Apr 2008 15:40:46 +0900 (JST)
Message-ID: <20080414.154046.27184508.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33484 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbYDNGi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:38:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a65935a..b9eeb4f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -371,6 +371,15 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	 */
 	in6_dev_hold(ndev);
 
+#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+	if (dev->type == ARPHRD_SIT && (dev->priv_flags & IFF_ISATAP)) {
+		printk(KERN_INFO
+		       "%s: Disabled Multicast RS\n",
+		       dev->name);
+		ndev->cnf.rtr_solicits = 0;
+	}
+#endif
+
 #ifdef CONFIG_IPV6_PRIVACY
 	setup_timer(&ndev->regen_timer, ipv6_regen_rndid, (unsigned long)ndev);
 	if ((dev->flags&IFF_LOOPBACK) ||
@@ -383,13 +392,6 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 		       "%s: Disabled Privacy Extensions\n",
 		       dev->name);
 		ndev->cnf.use_tempaddr = -1;
-
-		if (dev->type == ARPHRD_SIT && (dev->priv_flags & IFF_ISATAP)) {
-			printk(KERN_INFO
-			       "%s: Disabled Multicast RS\n",
-			       dev->name);
-			ndev->cnf.rtr_solicits = 0;
-		}
 	} else {
 		in6_dev_hold(ndev);
 		ipv6_regen_rndid((unsigned long) ndev);
-- 
1.4.4.4

