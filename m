From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 1/4] net: calxedaxgmac: fix net timeout recovery
Date: Mon,  9 Jul 2012 19:16:07 -0500
Message-ID: <1341879370-23385-2-git-send-email-robherring2@gmail.com>
References: <1341879370-23385-1-git-send-email-robherring2@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341879370-23385-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

Fix net tx watchdog timeout recovery. The descriptor ring was reset,
but the DMA engine was not reset to the beginning of the ring.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 11f667f..c4fd2e3 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -933,6 +933,7 @@ static void xgmac_tx_err(struct xgmac_priv *priv)
 	desc_init_tx_desc(priv->dma_tx, DMA_TX_RING_SZ);
 	priv->tx_tail = 0;
 	priv->tx_head = 0;
+	writel(priv->dma_tx_phy, priv->base + XGMAC_DMA_TX_BASE_ADDR);
 	writel(reg | DMA_CONTROL_ST, priv->base + XGMAC_DMA_CONTROL);
 
 	writel(DMA_STATUS_TU | DMA_STATUS_TPS | DMA_STATUS_NIS | DMA_STATUS_AIS,
-- 
1.7.9.5
