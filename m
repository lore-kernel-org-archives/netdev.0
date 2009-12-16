From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Subject: [RFC PATCH] gianfar: update txq->trans_start rather than dev->trans_start
Date: Wed, 16 Dec 2009 19:34:41 +0530
Message-ID: <1260972281-20012-1-git-send-email-Sandeep.Kumar@freescale.com>
Cc: davem@davemloft.net, Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
To: netdev@vger.kernel.org, avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:59180 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933892AbZLPOE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 09:04:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
---

 *. Please let me know if updating txq->trans_start in gfar_start is
    alright, although updating txq->trans_start in gfar_start_xmit( )
    should be done.
 
 drivers/net/gianfar.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index e0620d0..f8bcc72 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1665,6 +1665,7 @@ void gfar_start(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+	struct netdev_queue *txq;
 	u32 tempval;
 	int i = 0;
 
@@ -1692,7 +1693,11 @@ void gfar_start(struct net_device *dev)
 		gfar_write(&regs->imask, IMASK_DEFAULT);
 	}
 
-	dev->trans_start = jiffies;
+	/* Update the trans_start for each queue */
+	for (i = 0; i < priv->num_tx_queues; i++) {
+		txq = netdev_get_tx_queue(dev, i);
+		txq->trans_start = jiffies;
+	}
 }
 
 void gfar_configure_coalescing(struct gfar_private *priv,
@@ -2069,7 +2074,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* reduce TxBD free count */
 	tx_queue->num_txbdfree -= (nr_frags + 1);
 
-	dev->trans_start = jiffies;
+	txq->trans_start = jiffies;
 
 	/* If the next BD still needs to be cleaned up, then the bds
 	   are full.  We need to tell the kernel to stop sending us stuff. */
-- 
1.6.5.6

