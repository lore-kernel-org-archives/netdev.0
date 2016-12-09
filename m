From: Rayagond Kokatanur <rayagond.kokatanur@gmail.com>
Subject: [PATCH] net:ethernet:samsung:initialize cur_rx_qnum
Date: Fri,  9 Dec 2016 17:44:05 +0530
Message-ID: <1481285645-6028-1-git-send-email-rayagond.kokatanur@gmail.com>
Cc: netdev@vger.kernel.org,
        Rayagond Kokatanur <rayagond.kokatanur@gmail.com>
To: siva.kallam@samsung.com, bh74.an@samsung.com, ks.giri@samsung.com,
        vipul.pandya@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33675 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932782AbcLIMOY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 07:14:24 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so2202311pgd.0
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 04:14:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch initialize the cur_rx_qnum upon occurence of rx interrupt,
without this initialization driver will not work with multiple rx queues configurations.

NOTE: This patch is not tested on actual hw.
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index ea44a24..580a1a4 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1681,6 +1681,7 @@ static irqreturn_t sxgbe_rx_interrupt(int irq, void *dev_id)
 	struct sxgbe_rx_queue *rxq = (struct sxgbe_rx_queue *)dev_id;
 	struct sxgbe_priv_data *priv = rxq->priv_ptr;
 
+	priv->cur_rx_qnum = rxq->queue_no;
 	/* get the channel status */
 	status = priv->hw->dma->rx_dma_int_status(priv->ioaddr, rxq->queue_no,
 						  &priv->xstats);
-- 
1.9.1
