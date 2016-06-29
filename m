From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] ixgbe: Correct reporting of timestamping for x550
Date: Wed, 29 Jun 2016 14:33:00 -0700
Message-ID: <1467235982-55437-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32574 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845AbcF2VdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 17:33:08 -0400
In-Reply-To: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Update ixgbe_ethtool_get_ts_info() to show that x550 supports hardware
timestamping of all packets.

Reported-by: Guy Harris <guy@alum.mit.edu>
Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 59b771b..8a84507 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2991,10 +2991,15 @@ static int ixgbe_get_ts_info(struct net_device *dev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
+	/* we always support timestamping disabled */
+	info->rx_filters = BIT(HWTSTAMP_FILTER_NONE);
+
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_X550:
 	case ixgbe_mac_X550EM_x:
 	case ixgbe_mac_x550em_a:
+		info->rx_filters |= BIT(HWTSTAMP_FILTER_ALL);
+		/* fallthrough */
 	case ixgbe_mac_X540:
 	case ixgbe_mac_82599EB:
 		info->so_timestamping =
@@ -3014,8 +3019,7 @@ static int ixgbe_get_ts_info(struct net_device *dev,
 			BIT(HWTSTAMP_TX_OFF) |
 			BIT(HWTSTAMP_TX_ON);
 
-		info->rx_filters =
-			BIT(HWTSTAMP_FILTER_NONE) |
+		info->rx_filters |=
 			BIT(HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
 			BIT(HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
 			BIT(HWTSTAMP_FILTER_PTP_V2_EVENT);
-- 
2.5.5
