From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/3] ixgb: Add missing dma_mapping_error-call in ixgb_alloc_rx_buffers
Date: Wed, 27 Mar 2013 04:05:32 -0700
Message-ID: <1364382333-14721-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364382333-14721-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6012 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972Ab3C0LFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 07:05:44 -0400
In-Reply-To: <1364382333-14721-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>

After dma_map_single, dma_mapping_error must be called. It seems safe to
not free the skb allocated in this function, as the skb can be reused
later.

Additionally this patch fixes one coding-style error.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index ea48083..b5f94ab 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -2159,6 +2159,10 @@ map_skb:
 		                                  skb->data,
 		                                  adapter->rx_buffer_len,
 						  DMA_FROM_DEVICE);
+		if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
+			adapter->alloc_rx_buff_failed++;
+			break;
+		}
 
 		rx_desc = IXGB_RX_DESC(*rx_ring, i);
 		rx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
@@ -2168,7 +2172,8 @@ map_skb:
 		rx_desc->status = 0;
 
 
-		if (++i == rx_ring->count) i = 0;
+		if (++i == rx_ring->count)
+			i = 0;
 		buffer_info = &rx_ring->buffer_info[i];
 	}
 
-- 
1.7.11.7
