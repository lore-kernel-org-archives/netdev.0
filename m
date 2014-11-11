From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/10] i40e: clean up throttle rate code
Date: Tue, 11 Nov 2014 06:44:39 -0800
Message-ID: <1415717086-3441-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415717086-3441-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3085 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440AbaKKOp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 09:45:29 -0500
In-Reply-To: <1415717086-3441-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The interrupt throttle rate minimum is actually 2us, so
fix that define and while we are there, remove some unused defines.

Change some strings in the function to be a bit less wrappy, and
express the correct limits.

Change-ID: I96829bbc77935e0b57c6f0fc1439fb4152b2960a
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 11 ++++-------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |  5 +----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h  |  5 +----
 3 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index b6e745f..afad5aa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1575,11 +1575,9 @@ static int i40e_set_coalesce(struct net_device *netdev,
 	} else if (ec->rx_coalesce_usecs == 0) {
 		vsi->rx_itr_setting = ec->rx_coalesce_usecs;
 		if (ec->use_adaptive_rx_coalesce)
-			netif_info(pf, drv, netdev,
-				   "Rx-secs=0, need to disable adaptive-Rx for a complete disable\n");
+			netif_info(pf, drv, netdev, "rx-usecs=0, need to disable adaptive-rx for a complete disable\n");
 	} else {
-		netif_info(pf, drv, netdev,
-			   "Invalid value, Rx-usecs range is 0, 8-8160\n");
+		netif_info(pf, drv, netdev, "Invalid value, rx-usecs range is 0-8160\n");
 		return -EINVAL;
 	}
 
@@ -1589,11 +1587,10 @@ static int i40e_set_coalesce(struct net_device *netdev,
 	} else if (ec->tx_coalesce_usecs == 0) {
 		vsi->tx_itr_setting = ec->tx_coalesce_usecs;
 		if (ec->use_adaptive_tx_coalesce)
-			netif_info(pf, drv, netdev,
-				   "Tx-secs=0, need to disable adaptive-Tx for a complete disable\n");
+			netif_info(pf, drv, netdev, "tx-usecs=0, need to disable adaptive-tx for a complete disable\n");
 	} else {
 		netif_info(pf, drv, netdev,
-			   "Invalid value, Tx-usecs range is 0, 8-8160\n");
+			   "Invalid value, tx-usecs range is 0-8160\n");
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index d7a625a..e60d3ac 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -30,10 +30,7 @@
 /* Interrupt Throttling and Rate Limiting Goodies */
 
 #define I40E_MAX_ITR               0x0FF0  /* reg uses 2 usec resolution */
-#define I40E_MIN_ITR               0x0004  /* reg uses 2 usec resolution */
-#define I40E_MAX_IRATE             0x03F
-#define I40E_MIN_IRATE             0x001
-#define I40E_IRATE_USEC_RESOLUTION 4
+#define I40E_MIN_ITR               0x0001  /* reg uses 2 usec resolution */
 #define I40E_ITR_100K              0x0005
 #define I40E_ITR_20K               0x0019
 #define I40E_ITR_8K                0x003E
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index f6dcf9d..c7f2962 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -30,10 +30,7 @@
 /* Interrupt Throttling and Rate Limiting Goodies */
 
 #define I40E_MAX_ITR               0x0FF0  /* reg uses 2 usec resolution */
-#define I40E_MIN_ITR               0x0004  /* reg uses 2 usec resolution */
-#define I40E_MAX_IRATE             0x03F
-#define I40E_MIN_IRATE             0x001
-#define I40E_IRATE_USEC_RESOLUTION 4
+#define I40E_MIN_ITR               0x0001  /* reg uses 2 usec resolution */
 #define I40E_ITR_100K              0x0005
 #define I40E_ITR_20K               0x0019
 #define I40E_ITR_8K                0x003E
-- 
1.9.3
