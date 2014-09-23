From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 3/4] net: fec: align rx data buffer size for dma map/unmap
Date: Tue, 23 Sep 2014 15:40:57 +0800
Message-ID: <1411458058-18934-4-git-send-email-b38611@freescale.com>
References: <1411458058-18934-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b20596@freescale.com>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0109.outbound.protection.outlook.com ([65.55.169.109]:54304
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754279AbaIWIXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 04:23:36 -0400
In-Reply-To: <1411458058-18934-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Align allocated rx data buffer size for dma map/unmap, otherwise
kernel print warning when enable DMA_API_DEBUG.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e87a8e9..3ce3567 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1403,7 +1403,8 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 		index = fec_enet_get_bd_index(rxq->rx_bd_base, bdp, fep);
 		data = rxq->rx_skbuff[index]->data;
 		dma_sync_single_for_cpu(&fep->pdev->dev, bdp->cbd_bufaddr,
-					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
+					FEC_ENET_RX_FRSIZE - fep->rx_align,
+					DMA_FROM_DEVICE);
 
 		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
 			swap_buffer(data, pkt_len);
@@ -1475,7 +1476,8 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 		}
 
 		dma_sync_single_for_device(&fep->pdev->dev, bdp->cbd_bufaddr,
-					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
+					   FEC_ENET_RX_FRSIZE - fep->rx_align,
+					   DMA_FROM_DEVICE);
 rx_processing_done:
 		/* Clear the status flags for this buffer */
 		status &= ~BD_ENET_RX_STATS;
@@ -2448,7 +2450,7 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 			if (skb) {
 				dma_unmap_single(&fep->pdev->dev,
 						 bdp->cbd_bufaddr,
-						 FEC_ENET_RX_FRSIZE,
+						 FEC_ENET_RX_FRSIZE - fep->rx_align,
 						 DMA_FROM_DEVICE);
 				dev_kfree_skb(skb);
 			}
-- 
1.7.8
