From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/10] ixgbe: Allow setting multiple queues when SR-IOV is enabled
Date: Fri, 23 Sep 2016 00:51:40 -0700
Message-ID: <1474617103-59530-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:27953 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757624AbcIWHvs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:51:48 -0400
In-Reply-To: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The maximum queue count reported was 1, however support for multiple queues
with SR-IOV was added some time ago so we should report support for it to
the user so that they can select multiple queues if they so desire.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 730a99f..2d872be 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -3060,8 +3060,8 @@ static unsigned int ixgbe_max_channels(struct ixgbe_adapter *adapter)
 		/* We only support one q_vector without MSI-X */
 		max_combined = 1;
 	} else if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
-		/* SR-IOV currently only allows one queue on the PF */
-		max_combined = 1;
+		/* Limit value based on the queue mask */
+		max_combined = adapter->ring_feature[RING_F_RSS].mask + 1;
 	} else if (tcs > 1) {
 		/* For DCB report channels per traffic class */
 		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
-- 
2.7.4
