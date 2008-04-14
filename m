From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6 2/2] [IPV6] ADDRCONF: Don't generate temporary
 address for ip6-ip6 interface.
Date: Mon, 14 Apr 2008 15:47:06 +0900 (JST)
Message-ID: <20080414.154706.62976282.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33488 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564AbYDNGpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:45:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As far as I can remember, I was going to disable privacy extensions
on all "tunnel" interfaces.  Disable it on ip6-ip6 interface as well.

Also, just remove ifdefs for SIT for simplicity.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b9eeb4f..e08955b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -384,9 +384,8 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	setup_timer(&ndev->regen_timer, ipv6_regen_rndid, (unsigned long)ndev);
 	if ((dev->flags&IFF_LOOPBACK) ||
 	    dev->type == ARPHRD_TUNNEL ||
-#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+	    dev->type == ARPHRD_TUNNEL6 ||
 	    dev->type == ARPHRD_SIT ||
-#endif
 	    dev->type == ARPHRD_NONE) {
 		printk(KERN_INFO
 		       "%s: Disabled Privacy Extensions\n",
-- 
1.4.4.4

