From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 2/3] net: mvpp2: unify the txq size define use
Date: Wed, 23 Aug 2017 09:46:55 +0200
Message-ID: <20170823074656.14595-3-antoine.tenart@free-electrons.com>
References: <20170823074656.14595-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:55985 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753438AbdHWHrM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 03:47:12 -0400
In-Reply-To: <20170823074656.14595-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The txq size is defined by MVPP2_AGGR_TXQ_SIZE, which is sometime not
used directly but through variables. As it is a fixed value use the
define everywhere in the driver.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 4a2ed5c66bb4..0f5a2a4f9ddf 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5413,15 +5413,14 @@ static unsigned int mvpp2_tx_done(struct mvpp2_port *port, u32 cause,
 
 /* Allocate and initialize descriptors for aggr TXQ */
 static int mvpp2_aggr_txq_init(struct platform_device *pdev,
-			       struct mvpp2_tx_queue *aggr_txq,
-			       int desc_num, int cpu,
+			       struct mvpp2_tx_queue *aggr_txq, int cpu,
 			       struct mvpp2 *priv)
 {
 	u32 txq_dma;
 
 	/* Allocate memory for TX descriptors */
 	aggr_txq->descs = dma_alloc_coherent(&pdev->dev,
-				desc_num * MVPP2_DESC_ALIGNED_SIZE,
+				MVPP2_AGGR_TXQ_SIZE * MVPP2_DESC_ALIGNED_SIZE,
 				&aggr_txq->descs_dma, GFP_KERNEL);
 	if (!aggr_txq->descs)
 		return -ENOMEM;
@@ -5442,7 +5441,8 @@ static int mvpp2_aggr_txq_init(struct platform_device *pdev,
 			MVPP22_AGGR_TXQ_DESC_ADDR_OFFS;
 
 	mvpp2_write(priv, MVPP2_AGGR_TXQ_DESC_ADDR_REG(cpu), txq_dma);
-	mvpp2_write(priv, MVPP2_AGGR_TXQ_DESC_SIZE_REG(cpu), desc_num);
+	mvpp2_write(priv, MVPP2_AGGR_TXQ_DESC_SIZE_REG(cpu),
+		    MVPP2_AGGR_TXQ_SIZE);
 
 	return 0;
 }
@@ -7691,8 +7691,7 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 	for_each_present_cpu(i) {
 		priv->aggr_txqs[i].id = i;
 		priv->aggr_txqs[i].size = MVPP2_AGGR_TXQ_SIZE;
-		err = mvpp2_aggr_txq_init(pdev, &priv->aggr_txqs[i],
-					  MVPP2_AGGR_TXQ_SIZE, i, priv);
+		err = mvpp2_aggr_txq_init(pdev, &priv->aggr_txqs[i], i, priv);
 		if (err < 0)
 			return err;
 	}
-- 
2.13.5
