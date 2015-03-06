From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH] bgmac: ratelimit warning messages
Date: Fri,  6 Mar 2015 19:17:54 +0100
Message-ID: <1425665874-14870-1-git-send-email-peter.senna@gmail.com>
Cc: Peter Senna Tschudin <peter.senna@gmail.com>
To: davem@davemloft.net, hauke@hauke-m.de,
	w-lkml@lebenslange-mailadresse.de, zajec5@gmail.com,
	joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On my test environment the troughput of a file transfer drops from
4.4Mbps to 116Kbps due the number of repeated warning messages.
Adding printk_ratelimit() solves the issue without removing the
warning message.

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 676ffe0..d1a259b 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -302,7 +302,7 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
 	slot->skb = skb;
 	slot->dma_addr = dma_addr;
 
-	if (slot->dma_addr & 0xC0000000)
+	if ((slot->dma_addr & 0xC0000000) && printk_ratelimit())
 		bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need translation trick\n");
 
 	return 0;
@@ -505,7 +505,7 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 				  ring->mmio_base);
 			goto err_dma_free;
 		}
-		if (ring->dma_base & 0xC0000000)
+		if ((ring->dma_base & 0xC0000000) && printk_ratelimit())
 			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need translation trick\n");
 
 		ring->unaligned = bgmac_dma_unaligned(bgmac, ring,
@@ -536,7 +536,7 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 			err = -ENOMEM;
 			goto err_dma_free;
 		}
-		if (ring->dma_base & 0xC0000000)
+		if ((ring->dma_base & 0xC0000000) && printk_ratelimit())
 			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need translation trick\n");
 
 		ring->unaligned = bgmac_dma_unaligned(bgmac, ring,
-- 
2.1.0
