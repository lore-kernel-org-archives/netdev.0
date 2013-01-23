From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] ixgbe: add missing supported filters to get_ts_info
Date: Wed, 23 Jan 2013 14:44:38 -0800
Message-ID: <1358981090-5794-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63042 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415Ab3AWWpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 17:45:17 -0500
In-Reply-To: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch updates the filters for ethtool's get_ts_info to return support for
all filters which can be supported by upscaling to ptp_v2_event. The intent
behind this change is due to reasoning that we do in fact support the
filters. (hwtstamp_ioctl returns success after setting the filter to the
upscaled version). In this way we can remain consistent over which filters are
supported via the get_ts_info ioctl and which filters are in practice actually
supported.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 21bc72e..1513b10 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2709,6 +2709,14 @@ static int ixgbe_get_ts_info(struct net_device *dev,
 			(1 << HWTSTAMP_FILTER_NONE) |
 			(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
 			(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+			(1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
+			(1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
+			(1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
+			(1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
+			(1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
+			(1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
+			(1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ) |
+			(1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
 			(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
 		break;
 	default:
-- 
1.7.11.7
