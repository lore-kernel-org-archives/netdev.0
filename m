From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] ixgbe: Track instances of buffer available but no DMA resources present
Date: Fri,  4 May 2012 03:35:11 -0700
Message-ID: <1336127716-20383-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336127716-20383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2289 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754901Ab2EDKfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 06:35:20 -0400
In-Reply-To: <1336127716-20383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we can track instances of where a packet was
dropped due to a packet being received when there are no DMA buffers
available in the ring.

For some reason this was only being enabled with RSC, however it makes
more sense to always have this feature on so that we can track any cases
where we might drop a buffer due to an Rx ring being full.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 688c7bb..09409ae 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4967,9 +4967,6 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
 		u64 rsc_count = 0;
 		u64 rsc_flush = 0;
-		for (i = 0; i < 16; i++)
-			adapter->hw_rx_no_dma_resources +=
-				IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			rsc_count += adapter->rx_ring[i]->rx_stats.rsc_count;
 			rsc_flush += adapter->rx_ring[i]->rx_stats.rsc_flush;
@@ -5072,6 +5069,9 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		hwstats->b2ospc += IXGBE_READ_REG(hw, IXGBE_B2OSPC);
 		hwstats->b2ogprc += IXGBE_READ_REG(hw, IXGBE_B2OGPRC);
 	case ixgbe_mac_82599EB:
+		for (i = 0; i < 16; i++)
+			adapter->hw_rx_no_dma_resources +=
+					     IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
 		hwstats->gorc += IXGBE_READ_REG(hw, IXGBE_GORCL);
 		IXGBE_READ_REG(hw, IXGBE_GORCH); /* to clear */
 		hwstats->gotc += IXGBE_READ_REG(hw, IXGBE_GOTCL);
-- 
1.7.7.6
