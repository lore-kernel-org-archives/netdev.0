From: Joe Perches <joe@perches.com>
Subject: [PATCH 16/22] mwl8k: Use pci_zalloc_consistent
Date: Mon, 23 Jun 2014 06:41:44 -0700
Message-ID: <5a221c96b8c3ab59cf343fda8e86397259ca224e.1403530604.git.joe@perches.com>
References: <cover.1403530604.git.joe@perches.com>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1403530604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the now unnecessary memset too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/mwl8k.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 3c0a0a8..7e6b981 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -1159,12 +1159,11 @@ static int mwl8k_rxq_init(struct ieee80211_hw *hw, int index)
 
 	size = MWL8K_RX_DESCS * priv->rxd_ops->rxd_size;
 
-	rxq->rxd = pci_alloc_consistent(priv->pdev, size, &rxq->rxd_dma);
+	rxq->rxd = pci_zalloc_consistent(priv->pdev, size, &rxq->rxd_dma);
 	if (rxq->rxd == NULL) {
 		wiphy_err(hw->wiphy, "failed to alloc RX descriptors\n");
 		return -ENOMEM;
 	}
-	memset(rxq->rxd, 0, size);
 
 	rxq->buf = kcalloc(MWL8K_RX_DESCS, sizeof(*rxq->buf), GFP_KERNEL);
 	if (rxq->buf == NULL) {
@@ -1451,12 +1450,11 @@ static int mwl8k_txq_init(struct ieee80211_hw *hw, int index)
 
 	size = MWL8K_TX_DESCS * sizeof(struct mwl8k_tx_desc);
 
-	txq->txd = pci_alloc_consistent(priv->pdev, size, &txq->txd_dma);
+	txq->txd = pci_zalloc_consistent(priv->pdev, size, &txq->txd_dma);
 	if (txq->txd == NULL) {
 		wiphy_err(hw->wiphy, "failed to alloc TX descriptors\n");
 		return -ENOMEM;
 	}
-	memset(txq->txd, 0, size);
 
 	txq->skb = kcalloc(MWL8K_TX_DESCS, sizeof(*txq->skb), GFP_KERNEL);
 	if (txq->skb == NULL) {
-- 
1.8.1.2.459.gbcd45b4.dirty
