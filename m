From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2] bgmac: fix unaligned accesses to network headers
Date: Sat, 16 Feb 2013 22:10:38 +0100
Message-ID: <1361049038-25924-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:34935 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754379Ab3BPVKr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 16:10:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch I get many unaligned access warnings per packet,
this patches fixes them all. This should improve performance on some
systems like mips.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index d341090..3fd3288 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -301,7 +301,7 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 			bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n",
 				  ring->start);
 		} else {
-			new_skb = netdev_alloc_skb(bgmac->net_dev, len);
+			new_skb = netdev_alloc_skb_ip_align(bgmac->net_dev, len);
 			if (new_skb) {
 				skb_put(new_skb, len);
 				skb_copy_from_linear_data_offset(skb, BGMAC_RX_FRAME_OFFSET,
-- 
1.7.10.4
