From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbe: PTP get_ts_info missing software support
Date: Thu,  1 Nov 2012 01:30:54 -0700
Message-ID: <1351758654-9718-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33614 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815Ab2KAIbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 04:31:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch corrects the ethtool get_ts_info functon which did not state that
software timestamping was supported, even though it is.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
CC: Stable <stable@vger.kernel.org> [3.5]
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 56b20d1..116f0e9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2673,6 +2673,9 @@ static int ixgbe_get_ts_info(struct net_device *dev,
 	case ixgbe_mac_X540:
 	case ixgbe_mac_82599EB:
 		info->so_timestamping =
+			SOF_TIMESTAMPING_TX_SOFTWARE |
+			SOF_TIMESTAMPING_RX_SOFTWARE |
+			SOF_TIMESTAMPING_SOFTWARE |
 			SOF_TIMESTAMPING_TX_HARDWARE |
 			SOF_TIMESTAMPING_RX_HARDWARE |
 			SOF_TIMESTAMPING_RAW_HARDWARE;
-- 
1.7.11.7
