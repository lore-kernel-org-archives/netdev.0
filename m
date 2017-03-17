From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] igb: Add support for DMA_ATTR_WEAK_ORDERING
Date: Fri, 17 Mar 2017 12:58:06 -0700
Message-ID: <20170317195818.74912-2-jeffrey.t.kirsher@intel.com>
References: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30552 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751101AbdCQT6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 15:58:25 -0400
In-Reply-To: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Since we are already using DMA attributes in igb for Rx there is no reason
why we can't also apply DMA_ATTR_WEAK_ORDERING which is needed on some
platforms to improve performance.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      | 3 +++
 drivers/net/ethernet/intel/igb/igb_main.c | 6 +++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index acbc3abe2ddd..87c9fe9d6f18 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -148,6 +148,9 @@ struct vf_data_storage {
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define IGB_RX_BUFFER_WRITE	16 /* Must be power of 2 */
 
+#define IGB_RX_DMA_ATTR \
+	(DMA_ATTR_SKIP_CPU_SYNC | DMA_ATTR_WEAK_ORDERING)
+
 #define AUTO_ALL_MODES		0
 #define IGB_EEPROM_APME		0x0400
 
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index be456bae8169..cf7ee9cdac6f 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3963,7 +3963,7 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 				     buffer_info->dma,
 				     PAGE_SIZE,
 				     DMA_FROM_DEVICE,
-				     DMA_ATTR_SKIP_CPU_SYNC);
+				     IGB_RX_DMA_ATTR);
 		__page_frag_cache_drain(buffer_info->page,
 					buffer_info->pagecnt_bias);
 
@@ -6990,7 +6990,7 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 		 */
 		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
 				     PAGE_SIZE, DMA_FROM_DEVICE,
-				     DMA_ATTR_SKIP_CPU_SYNC);
+				     IGB_RX_DMA_ATTR);
 		__page_frag_cache_drain(page, rx_buffer->pagecnt_bias);
 	}
 
@@ -7250,7 +7250,7 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 
 	/* map page for use */
 	dma = dma_map_page_attrs(rx_ring->dev, page, 0, PAGE_SIZE,
-				 DMA_FROM_DEVICE, DMA_ATTR_SKIP_CPU_SYNC);
+				 DMA_FROM_DEVICE, IGB_RX_DMA_ATTR);
 
 	/* if mapping failed free memory back to system since
 	 * there isn't much point in holding memory we can't use
-- 
2.12.0
