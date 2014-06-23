From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/22] amd: Use pci_zalloc_consistent
Date: Mon, 23 Jun 2014 06:41:36 -0700
Message-ID: <c7cdaa8e080157cdabb92278a4c3beba89b49070.1403530604.git.joe@perches.com>
References: <cover.1403530604.git.joe@perches.com>
Cc: Don Fry <pcnet32@frontier.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1403530604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the now unnecessary memset too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/amd/pcnet32.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index e7cc917..e5e2725 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -484,15 +484,13 @@ static void pcnet32_realloc_tx_ring(struct net_device *dev,
 
 	pcnet32_purge_tx_ring(dev);
 
-	new_tx_ring = pci_alloc_consistent(lp->pci_dev,
-					   sizeof(struct pcnet32_tx_head) *
-					   (1 << size),
-					   &new_ring_dma_addr);
+	new_tx_ring = pci_zalloc_consistent(lp->pci_dev,
+					    sizeof(struct pcnet32_tx_head) * (1 << size),
+					    &new_ring_dma_addr);
 	if (new_tx_ring == NULL) {
 		netif_err(lp, drv, dev, "Consistent memory allocation failed\n");
 		return;
 	}
-	memset(new_tx_ring, 0, sizeof(struct pcnet32_tx_head) * (1 << size));
 
 	new_dma_addr_list = kcalloc(1 << size, sizeof(dma_addr_t),
 				    GFP_ATOMIC);
@@ -551,15 +549,13 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	int new, overlap;
 	unsigned int entries = 1 << size;
 
-	new_rx_ring = pci_alloc_consistent(lp->pci_dev,
-					   sizeof(struct pcnet32_rx_head) *
-					   entries,
-					   &new_ring_dma_addr);
+	new_rx_ring = pci_zalloc_consistent(lp->pci_dev,
+					    sizeof(struct pcnet32_rx_head) * entries,
+					    &new_ring_dma_addr);
 	if (new_rx_ring == NULL) {
 		netif_err(lp, drv, dev, "Consistent memory allocation failed\n");
 		return;
 	}
-	memset(new_rx_ring, 0, sizeof(struct pcnet32_rx_head) * entries);
 
 	new_dma_addr_list = kcalloc(entries, sizeof(dma_addr_t), GFP_ATOMIC);
 	if (!new_dma_addr_list)
-- 
1.8.1.2.459.gbcd45b4.dirty
