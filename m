From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v5 5/9] bgmac: add check for oversized packets
Date: Mon, 13 Apr 2015 19:27:43 +0200
Message-ID: <1428946067-75650-5-git-send-email-nbd@openwrt.org>
References: <1428946067-75650-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:51995
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754267AbbDMR1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:27:52 -0400
In-Reply-To: <1428946067-75650-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In very rare cases, the MAC can catch an internal buffer that is bigger
than it's supposed to be. Instead of crashing the kernel, simply pass
the buffer back to the hardware

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 1916ebc..eca063d 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -428,6 +428,13 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 				break;
 			}
 
+			if (len > BGMAC_RX_ALLOC_SIZE) {
+				bgmac_err(bgmac, "Found oversized packet at slot %d, DMA issue!\n",
+					  ring->start);
+				kfree(buf);
+				break;
+			}
+
 			/* Omit CRC. */
 			len -= ETH_FCS_LEN;
 
-- 
2.2.2
