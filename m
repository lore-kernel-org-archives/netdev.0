From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 4/4] net: cpsw: remove redundant calls disabling dma interrupts.
Date: Mon, 25 May 2015 11:02:16 +0200
Message-ID: <993c9ee24940f329b462b94a71677e2daa8879fd.1432544195.git.richardcochran@gmail.com>
References: <cover.1432544195.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34792 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbbEYJC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 05:02:28 -0400
Received: by wicmc15 with SMTP id mc15so35195264wic.1
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 02:02:27 -0700 (PDT)
In-Reply-To: <cover.1432544195.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function, cpsw_intr_disable, already calls cpdma_ctlr_int_ctrl.  There
is no need to disable the dma interrupts twice.  This patch removes the
extra calls.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 0d0cf9a..4628205 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1361,7 +1361,6 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	if (cpsw_common_res_usage_state(priv) <= 1) {
 		cpts_unregister(priv->cpts);
 		cpsw_intr_disable(priv);
-		cpdma_ctlr_int_ctrl(priv->dma, false);
 		cpdma_ctlr_stop(priv->dma);
 		cpsw_ale_stop(priv->ale);
 	}
@@ -1589,7 +1588,6 @@ static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 	cpsw_err(priv, tx_err, "transmit timeout, restarting dma\n");
 	ndev->stats.tx_errors++;
 	cpsw_intr_disable(priv);
-	cpdma_ctlr_int_ctrl(priv->dma, false);
 	cpdma_chan_stop(priv->txch);
 	cpdma_chan_start(priv->txch);
 	cpsw_intr_enable(priv);
@@ -1628,7 +1626,6 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 
 	cpsw_intr_disable(priv);
-	cpdma_ctlr_int_ctrl(priv->dma, false);
 	cpsw_rx_interrupt(priv->irqs_table[0], priv);
 	cpsw_tx_interrupt(priv->irqs_table[1], priv);
 	cpsw_intr_enable(priv);
-- 
2.1.4
