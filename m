From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 3/4] net: cpsw: remove redundant calls enabling dma interrupts.
Date: Mon, 25 May 2015 11:02:15 +0200
Message-ID: <af0fb21126093a0c5510188bd78140935ed77778.1432544195.git.richardcochran@gmail.com>
References: <cover.1432544195.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33132 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbbEYJC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 05:02:27 -0400
Received: by wicmx19 with SMTP id mx19so35214451wic.0
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 02:02:26 -0700 (PDT)
In-Reply-To: <cover.1432544195.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function, cpsw_intr_enable, already calls cpdma_ctlr_int_ctrl.  There
is no need to enable the dma interrupts twice.  This patch removes the
extra call.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e9e3ab3..0d0cf9a 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1592,7 +1592,6 @@ static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 	cpdma_ctlr_int_ctrl(priv->dma, false);
 	cpdma_chan_stop(priv->txch);
 	cpdma_chan_start(priv->txch);
-	cpdma_ctlr_int_ctrl(priv->dma, true);
 	cpsw_intr_enable(priv);
 }
 
@@ -1632,7 +1631,6 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 	cpdma_ctlr_int_ctrl(priv->dma, false);
 	cpsw_rx_interrupt(priv->irqs_table[0], priv);
 	cpsw_tx_interrupt(priv->irqs_table[1], priv);
-	cpdma_ctlr_int_ctrl(priv->dma, true);
 	cpsw_intr_enable(priv);
 }
 #endif
-- 
2.1.4
