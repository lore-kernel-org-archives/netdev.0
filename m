From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] Revert "dev: set iflink to 0 for virtual interfaces"
Date: Mon,  6 Jul 2015 17:25:10 +0200
Message-ID: <1436196310-4090-1-git-send-email-nicolas.dichtel@6wind.com>
References: <5589959A.8060600@hartkopp.net>
Cc: ulrich.gemkow@ikr.uni-stuttgart.de, davem@davemloft.net,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:32976 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753105AbbGFPcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:32:52 -0400
In-Reply-To: <5589959A.8060600@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit e1622baf54df8cc958bf29d71de5ad545ea7d93c.

The side effect of this commit is to add a '@NONE' after each virtual
interface name with a 'ip link'. It may break existing scripts.

Reported-by: Olivier Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/dev.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6778a9999d52..72e0a4331154 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -677,10 +677,6 @@ int dev_get_iflink(const struct net_device *dev)
 	if (dev->netdev_ops && dev->netdev_ops->ndo_get_iflink)
 		return dev->netdev_ops->ndo_get_iflink(dev);
 
-	/* If dev->rtnl_link_ops is set, it's a virtual interface. */
-	if (dev->rtnl_link_ops)
-		return 0;
-
 	return dev->ifindex;
 }
 EXPORT_SYMBOL(dev_get_iflink);
-- 
2.4.2
