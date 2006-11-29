From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] sundance: use NULL for pointer
Date: Wed, 29 Nov 2006 13:15:17 -0800
Message-ID: <20061129131517.277efed0.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:49126 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1758118AbWK2VUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 16:20:46 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Use NULL instead of 0 for pointers (cures sparse warnings).

drivers/net/sundance.c:1106:16: warning: Using plain integer as NULL pointer
drivers/net/sundance.c:1652:16: warning: Using plain integer as NULL pointer

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/sundance.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.19-rc6-mm2.orig/drivers/net/sundance.c
+++ linux-2.6.19-rc6-mm2/drivers/net/sundance.c
@@ -1103,7 +1103,7 @@ reset_tx (struct net_device *dev)
 	np->cur_tx = np->dirty_tx = 0;
 	np->cur_task = 0;
 
-	np->last_tx = 0;
+	np->last_tx = NULL;
 	iowrite8(127, ioaddr + TxDMAPollPeriod);
 
 	iowrite16 (StatsEnable | RxEnable | TxEnable, ioaddr + MACCtrl1);
@@ -1649,7 +1649,7 @@ static int netdev_close(struct net_devic
 	np->cur_tx = 0;
 	np->dirty_tx = 0;
 	np->cur_task = 0;
-	np->last_tx = 0;
+	np->last_tx = NULL;
 
 	netif_stop_queue(dev);
 


---
