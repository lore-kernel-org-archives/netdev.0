From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH 1/3] pxa168_eth: Allocate receive queue initialized to zero
Date: Tue, 18 Jun 2013 19:30:48 +0200
Message-ID: <1371576648-21632-1-git-send-email-lkundrak@v3.sk>
Cc: Lubomir Rintel <lkundrak@v3.sk>,
	Kosta Zertsekel <konszert@marvell.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kosta Zertsekel <konszert@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zero pointer in rx_skb or tx_skb is how respective *_deinit() functions find
out that a skb slot is unallocated. If *_init() functions unsuccessfully return
after the allocation (e.g. when subsequent dma_alloc_coherent() is not
successful), this would result in attempt to kfree() invalid pointers.

Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
Cc: Kosta Zertsekel <konszert@marvell.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

---
 drivers/net/ethernet/marvell/pxa168_eth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 339bb32..1c8af8b 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1015,7 +1015,7 @@ static int rxq_init(struct net_device *dev)
 	int rx_desc_num = pep->rx_ring_size;
 
 	/* Allocate RX skb rings */
-	pep->rx_skb = kmalloc(sizeof(*pep->rx_skb) * pep->rx_ring_size,
+	pep->rx_skb = kzalloc(sizeof(*pep->rx_skb) * pep->rx_ring_size,
 			     GFP_KERNEL);
 	if (!pep->rx_skb)
 		return -ENOMEM;
@@ -1076,7 +1076,7 @@ static int txq_init(struct net_device *dev)
 	int size = 0, i = 0;
 	int tx_desc_num = pep->tx_ring_size;
 
-	pep->tx_skb = kmalloc(sizeof(*pep->tx_skb) * pep->tx_ring_size,
+	pep->tx_skb = kzalloc(sizeof(*pep->tx_skb) * pep->tx_ring_size,
 			     GFP_KERNEL);
 	if (!pep->tx_skb)
 		return -ENOMEM;
-- 
1.7.1
