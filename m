From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] igb: Store the MAC address in the name in the PTP struct.
Date: Wed,  5 Sep 2012 16:35:04 -0700
Message-ID: <1346888106-25638-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27164 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759944Ab2IEXfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 19:35:12 -0400
In-Reply-To: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Change the name of the adapter in the PTP struct to enable easier
correlation between interface and PTP device.

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Acked-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by:  Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 34e0d69..e69555f 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -547,14 +547,15 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 void igb_ptp_init(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
 
 	switch (hw->mac.type) {
 	case e1000_i210:
 	case e1000_i211:
 	case e1000_i350:
 	case e1000_82580:
+		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
 		adapter->ptp_caps.owner = THIS_MODULE;
-		strcpy(adapter->ptp_caps.name, "igb-82580");
 		adapter->ptp_caps.max_adj = 62499999;
 		adapter->ptp_caps.n_ext_ts = 0;
 		adapter->ptp_caps.pps = 0;
@@ -570,10 +571,9 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		/* Enable the timer functions by clearing bit 31. */
 		wr32(E1000_TSAUXC, 0x0);
 		break;
-
 	case e1000_82576:
+		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
 		adapter->ptp_caps.owner = THIS_MODULE;
-		strcpy(adapter->ptp_caps.name, "igb-82576");
 		adapter->ptp_caps.max_adj = 1000000000;
 		adapter->ptp_caps.n_ext_ts = 0;
 		adapter->ptp_caps.pps = 0;
@@ -589,7 +589,6 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		/* Dial the nominal frequency. */
 		wr32(E1000_TIMINCA, INCPERIOD_82576 | INCVALUE_82576);
 		break;
-
 	default:
 		adapter->ptp_clock = NULL;
 		return;
-- 
1.7.11.4
