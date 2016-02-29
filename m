From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net 3/5] dwc_eth_qos: use GFP_KERNEL in dma_alloc_coherent()
Date: Mon, 29 Feb 2016 16:22:32 +0100
Message-ID: <954958f6c10eacc76b39b8f0d6a5528fcc675a80.1456756740.git.larper@axis.com>
References: <cover.1456756740.git.larper@axis.com>
Cc: linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>,
	Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1456756740.git.larper@axis.com>
In-Reply-To: <cover.1456756740.git.larper@axis.com>
References: <cover.1456756740.git.larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rabin Vincent <rabinv@axis.com>

Since we are in non-atomic context here we can pass GFP_KERNEL to
dma_alloc_coherent(). This enables use of the CMA.

Signed-off-by: Rabin Vincent <rabinv@axis.com>
Signed-off-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 53d48c0..3ca2d5c 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -1113,7 +1113,7 @@ static int dwceqos_descriptor_init(struct net_local *lp)
 	/* Allocate DMA descriptors */
 	size = DWCEQOS_RX_DCNT * sizeof(struct dwceqos_dma_desc);
 	lp->rx_descs = dma_alloc_coherent(lp->ndev->dev.parent, size,
-			&lp->rx_descs_addr, 0);
+			&lp->rx_descs_addr, GFP_KERNEL);
 	if (!lp->rx_descs)
 		goto err_out;
 	lp->rx_descs_tail_addr = lp->rx_descs_addr +
@@ -1121,7 +1121,7 @@ static int dwceqos_descriptor_init(struct net_local *lp)
 
 	size = DWCEQOS_TX_DCNT * sizeof(struct dwceqos_dma_desc);
 	lp->tx_descs = dma_alloc_coherent(lp->ndev->dev.parent, size,
-			&lp->tx_descs_addr, 0);
+			&lp->tx_descs_addr, GFP_KERNEL);
 	if (!lp->tx_descs)
 		goto err_out;
 	lp->tx_descs_tail_addr = lp->tx_descs_addr +
-- 
2.1.4
