From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/5] ixgbe: fix PTP ethtool timestamping function
Date: Wed,  3 Oct 2012 15:27:09 -0700
Message-ID: <1349303231-28855-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1349303231-28855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22286 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756680Ab2JCW1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 18:27:17 -0400
In-Reply-To: <1349303231-28855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes a development issue that occurred due to invalid modes reported
in the ethtool get_ts_info function. The issue is resolved by removing
unsupported modes from the Rx supported list.

CC: stable <stable@vger.kernel.org> [3.5+]
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 4104ea25..56b20d1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2690,10 +2690,7 @@ static int ixgbe_get_ts_info(struct net_device *dev,
 			(1 << HWTSTAMP_FILTER_NONE) |
 			(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
 			(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
-			(1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
-			(1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
-			(1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
-			(1 << HWTSTAMP_FILTER_SOME);
+			(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
 		break;
 #endif /* CONFIG_IXGBE_PTP */
 	default:
-- 
1.7.11.4
