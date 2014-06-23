From: Joe Perches <joe@perches.com>
Subject: [PATCH 17/22] rtl818x: Use pci_zalloc_consistent
Date: Mon, 23 Jun 2014 06:41:45 -0700
Message-ID: <b4cf2aa62c7bec157a3e7079cdebe0670cdcba7c.1403530604.git.joe@perches.com>
References: <cover.1403530604.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1403530604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the now unnecessary memset too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtl818x/rtl8180/dev.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wireless/rtl818x/rtl8180/dev.c
index 1e25929..7577e01 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -964,16 +964,13 @@ static int rtl8180_init_rx_ring(struct ieee80211_hw *dev)
 	else
 		priv->rx_ring_sz = sizeof(struct rtl8180_rx_desc);
 
-	priv->rx_ring = pci_alloc_consistent(priv->pdev,
-					     priv->rx_ring_sz * 32,
-					     &priv->rx_ring_dma);
-
+	priv->rx_ring = pci_zalloc_consistent(priv->pdev, priv->rx_ring_sz * 32,
+					      &priv->rx_ring_dma);
 	if (!priv->rx_ring || (unsigned long)priv->rx_ring & 0xFF) {
 		wiphy_err(dev->wiphy, "Cannot allocate RX ring\n");
 		return -ENOMEM;
 	}
 
-	memset(priv->rx_ring, 0, priv->rx_ring_sz * 32);
 	priv->rx_idx = 0;
 
 	for (i = 0; i < 32; i++) {
@@ -1032,14 +1029,14 @@ static int rtl8180_init_tx_ring(struct ieee80211_hw *dev,
 	dma_addr_t dma;
 	int i;
 
-	ring = pci_alloc_consistent(priv->pdev, sizeof(*ring) * entries, &dma);
+	ring = pci_zalloc_consistent(priv->pdev, sizeof(*ring) * entries,
+				     &dma);
 	if (!ring || (unsigned long)ring & 0xFF) {
 		wiphy_err(dev->wiphy, "Cannot allocate TX ring (prio = %d)\n",
 			  prio);
 		return -ENOMEM;
 	}
 
-	memset(ring, 0, sizeof(*ring)*entries);
 	priv->tx_ring[prio].desc = ring;
 	priv->tx_ring[prio].dma = dma;
 	priv->tx_ring[prio].idx = 0;
-- 
1.8.1.2.459.gbcd45b4.dirty
