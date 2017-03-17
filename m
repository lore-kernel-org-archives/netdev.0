From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] igb: Only sync size of expected frame in ethtool testing
Date: Fri, 17 Mar 2017 12:58:11 -0700
Message-ID: <20170317195818.74912-7-jeffrey.t.kirsher@intel.com>
References: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30552 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751230AbdCQT60 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 15:58:26 -0400
In-Reply-To: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We only need to sync the size of the frame that is read to test.  We don't
need to sync the entire Rx buffer.  This way the testing is more consistent
with how we handle things in the receive path.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 612cf13b7a3a..d5966feb7b96 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1818,7 +1818,7 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 		/* sync Rx buffer for CPU read */
 		dma_sync_single_for_cpu(rx_ring->dev,
 					rx_buffer_info->dma,
-					IGB_RX_BUFSZ,
+					size,
 					DMA_FROM_DEVICE);
 
 		/* verify contents of skb */
@@ -1828,7 +1828,7 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 		/* sync Rx buffer for device write */
 		dma_sync_single_for_device(rx_ring->dev,
 					   rx_buffer_info->dma,
-					   IGB_RX_BUFSZ,
+					   size,
 					   DMA_FROM_DEVICE);
 
 		/* unmap buffer on Tx side */
-- 
2.12.0
