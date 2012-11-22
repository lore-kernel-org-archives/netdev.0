From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] ixgbe: use ETQF filter name instead of magic number
Date: Thu, 22 Nov 2012 02:11:11 -0800
Message-ID: <1353579077-12097-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1353579077-12097-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9107 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753165Ab2KVSe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 13:34:28 -0500
In-Reply-To: <1353579077-12097-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch removes a magic number that was used for the ETQF used for
filtering L2 ptp packets and replaces it with the supplied define that
previously existed. The intent is to clarify that this filter is already
set aside for L2 1588 work.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 01d99af..29ca293 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -704,14 +704,14 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 	/* Store filter value for later use */
 	adapter->rx_hwtstamp_filter = config.rx_filter;
 
-	/* define ethertype filter for timestamped packets */
+	/* define ethertype filter for timestamping L2 packets */
 	if (is_l2)
-		IXGBE_WRITE_REG(hw, IXGBE_ETQF(3),
+		IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_1588),
 				(IXGBE_ETQF_FILTER_EN | /* enable filter */
 				 IXGBE_ETQF_1588 | /* enable timestamping */
 				 ETH_P_1588));     /* 1588 eth protocol type */
 	else
-		IXGBE_WRITE_REG(hw, IXGBE_ETQF(3), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_1588), 0);
 
 #define PTP_PORT 319
 	/* L4 Queue Filter[3]: filter by destination port and protocol */
-- 
1.7.11.7
