From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH 2/3] ixgb: Add missing dma_mapping_error-call in ixgb_alloc_rx_buffers
Date: Sat, 16 Mar 2013 11:32:04 +0100
Message-ID: <1363429925-12724-3-git-send-email-christoph.paasch@uclouvain.be>
References: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:51918 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755594Ab3CPKcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 06:32:17 -0400
In-Reply-To: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After dma_map_single, dma_mapping_error must be called. It seems safe to
not free the skb allocated in this function, as the skb can be reused
later.

Additionally this patch fixes one coding-style error.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index e23f023..6662c7c 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -2155,6 +2155,10 @@ map_skb:
 		                                  skb->data,
 		                                  adapter->rx_buffer_len,
 						  DMA_FROM_DEVICE);
+		if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
+			adapter->alloc_rx_buff_failed++;
+			break;
+		}
 
 		rx_desc = IXGB_RX_DESC(*rx_ring, i);
 		rx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
@@ -2164,7 +2168,8 @@ map_skb:
 		rx_desc->status = 0;
 
 
-		if (++i == rx_ring->count) i = 0;
+		if (++i == rx_ring->count)
+			i = 0;
 		buffer_info = &rx_ring->buffer_info[i];
 	}
 
-- 
1.8.1.227.g44fe835
