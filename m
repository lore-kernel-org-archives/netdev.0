From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH] bgmac: Clean warning messages
Date: Sat,  7 Mar 2015 11:51:58 +0100
Message-ID: <1425725518-30651-1-git-send-email-peter.senna@gmail.com>
Cc: Peter Senna Tschudin <peter.senna@gmail.com>
To: davem@davemloft.net, hauke@hauke-m.de,
	w-lkml@lebenslange-mailadresse.de, zajec5@gmail.com,
	joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:46187 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbbCGKwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 05:52:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On my test environment the throughput of a file transfer drops
from 4.4MBps to 116KBps due the number of repeated warning
messages. This patch removes the warning messages.

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---
Changes from: bgmac: ratelimit warning messages
   - Remove the messages instead of using printk_ratelimit()

 drivers/net/ethernet/broadcom/bgmac.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 676ffe0..0469f72 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -302,9 +302,6 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
 	slot->skb = skb;
 	slot->dma_addr = dma_addr;
 
-	if (slot->dma_addr & 0xC0000000)
-		bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need translation trick\n");
-
 	return 0;
 }
 
@@ -505,8 +502,6 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 				  ring->mmio_base);
 			goto err_dma_free;
 		}
-		if (ring->dma_base & 0xC0000000)
-			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need translation trick\n");
 
 		ring->unaligned = bgmac_dma_unaligned(bgmac, ring,
 						      BGMAC_DMA_RING_TX);
@@ -536,8 +531,6 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 			err = -ENOMEM;
 			goto err_dma_free;
 		}
-		if (ring->dma_base & 0xC0000000)
-			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need translation trick\n");
 
 		ring->unaligned = bgmac_dma_unaligned(bgmac, ring,
 						      BGMAC_DMA_RING_RX);
-- 
2.1.0
