From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 05/11] net: calxedaxgmac: update ring buffer tx_head after barriers
Date: Mon, 26 Aug 2013 17:45:20 -0500
Message-ID: <1377557126-10716-5-git-send-email-robherring2@gmail.com>
References: <1377557126-10716-1-git-send-email-robherring2@gmail.com>
Cc: Andreas Herrmann <andreas.herrmann@calxeda.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377557126-10716-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

Ensure that the descriptor writes are visible before the ring buffer head
is updated. Since writel is a barrier, we can simply update the head after
the writel.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 64854ad..f630855 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1121,9 +1121,10 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	wmb();
 	desc_set_tx_owner(first, desc_flags | TXDESC_FIRST_SEG);
 
+	writel(1, priv->base + XGMAC_DMA_TX_POLL);
+
 	priv->tx_head = dma_ring_incr(entry, DMA_TX_RING_SZ);
 
-	writel(1, priv->base + XGMAC_DMA_TX_POLL);
 	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) <
 	    MAX_SKB_FRAGS)
 		netif_stop_queue(dev);
-- 
1.8.1.2
