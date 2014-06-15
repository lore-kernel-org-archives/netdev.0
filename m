From: Joe Perches <joe@perches.com>
Subject: [PATCH -next 10/26] broadcom: Use dma_zalloc_coherent
Date: Sun, 15 Jun 2014 13:37:39 -0700
Message-ID: <6b329f3d7f7b5f14d19304178bc95f9081b07bf5.1402863905.git.joe@perches.com>
References: <cover.1402863904.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1402863904.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the zeroing function instead of dma_alloc_coherent & memset(,0,)

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 3e8d1a8..8c61c81 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -2165,27 +2165,25 @@ static int bcm_enetsw_open(struct net_device *dev)
 
 	/* allocate rx dma ring */
 	size = priv->rx_ring_size * sizeof(struct bcm_enet_desc);
-	p = dma_alloc_coherent(kdev, size, &priv->rx_desc_dma, GFP_KERNEL);
+	p = dma_zalloc_coherent(kdev, size, &priv->rx_desc_dma, GFP_KERNEL);
 	if (!p) {
 		dev_err(kdev, "cannot allocate rx ring %u\n", size);
 		ret = -ENOMEM;
 		goto out_freeirq_tx;
 	}
 
-	memset(p, 0, size);
 	priv->rx_desc_alloc_size = size;
 	priv->rx_desc_cpu = p;
 
 	/* allocate tx dma ring */
 	size = priv->tx_ring_size * sizeof(struct bcm_enet_desc);
-	p = dma_alloc_coherent(kdev, size, &priv->tx_desc_dma, GFP_KERNEL);
+	p = dma_zalloc_coherent(kdev, size, &priv->tx_desc_dma, GFP_KERNEL);
 	if (!p) {
 		dev_err(kdev, "cannot allocate tx ring\n");
 		ret = -ENOMEM;
 		goto out_free_rx_ring;
 	}
 
-	memset(p, 0, size);
 	priv->tx_desc_alloc_size = size;
 	priv->tx_desc_cpu = p;
 
-- 
1.8.1.2.459.gbcd45b4.dirty
