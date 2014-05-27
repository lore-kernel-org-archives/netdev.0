From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] ixgbe: rename ixgbe_ptp_enable to ixgbe_ptp_feature_enable
Date: Tue, 27 May 2014 02:12:18 -0700
Message-ID: <1401181951-31358-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17021 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879AbaE0JMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:36 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Since the name ixgbe_ptp_enable could be misconstrued as a function
which enables the whole PTP core, rename this function so that it is
clear the function is for enabling of the extra features such as PPS
signal.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 8902ae6..1a88609 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -334,7 +334,7 @@ static int ixgbe_ptp_settime(struct ptp_clock_info *ptp,
 }
 
 /**
- * ixgbe_ptp_enable
+ * ixgbe_ptp_feature_enable
  * @ptp: the ptp clock structure
  * @rq: the requested feature to change
  * @on: whether to enable or disable the feature
@@ -342,8 +342,8 @@ static int ixgbe_ptp_settime(struct ptp_clock_info *ptp,
  * enable (or disable) ancillary features of the phc subsystem.
  * our driver only supports the PPS feature on the X540
  */
-static int ixgbe_ptp_enable(struct ptp_clock_info *ptp,
-			    struct ptp_clock_request *rq, int on)
+static int ixgbe_ptp_feature_enable(struct ptp_clock_info *ptp,
+				    struct ptp_clock_request *rq, int on)
 {
 	struct ixgbe_adapter *adapter =
 		container_of(ptp, struct ixgbe_adapter, ptp_caps);
@@ -851,7 +851,7 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 		adapter->ptp_caps.adjtime = ixgbe_ptp_adjtime;
 		adapter->ptp_caps.gettime = ixgbe_ptp_gettime;
 		adapter->ptp_caps.settime = ixgbe_ptp_settime;
-		adapter->ptp_caps.enable = ixgbe_ptp_enable;
+		adapter->ptp_caps.enable = ixgbe_ptp_feature_enable;
 		break;
 	case ixgbe_mac_82599EB:
 		snprintf(adapter->ptp_caps.name,
@@ -867,7 +867,7 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 		adapter->ptp_caps.adjtime = ixgbe_ptp_adjtime;
 		adapter->ptp_caps.gettime = ixgbe_ptp_gettime;
 		adapter->ptp_caps.settime = ixgbe_ptp_settime;
-		adapter->ptp_caps.enable = ixgbe_ptp_enable;
+		adapter->ptp_caps.enable = ixgbe_ptp_feature_enable;
 		break;
 	default:
 		adapter->ptp_clock = NULL;
-- 
1.9.3
