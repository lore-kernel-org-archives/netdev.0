From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/10] ixgbe: fix incorrect limit value in ring transverse
Date: Thu, 29 Aug 2013 03:49:59 -0700
Message-ID: <1377773406-24851-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:60952 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756023Ab3H2KuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 06:50:14 -0400
In-Reply-To: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We were transversing the tx_ring with IXGBE_NUM_RX_QUEUES.  Now this define
happens to have the correct value but this is misleading and a change later
could easily make this no longer true.  I updated it to netdev->num_tx_queues
like we use in ixgbe_get_strings().

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 50c1e9b..db0dbf6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1049,7 +1049,7 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 		data[i] = (ixgbe_gstrings_stats[i].sizeof_stat ==
 		           sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
-	for (j = 0; j < IXGBE_NUM_RX_QUEUES; j++) {
+	for (j = 0; j < netdev->num_tx_queues; j++) {
 		ring = adapter->tx_ring[j];
 		if (!ring) {
 			data[i] = 0;
-- 
1.8.3.1
