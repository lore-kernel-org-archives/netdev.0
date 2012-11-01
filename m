From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] ixgbe: fix uninitialized event.type in ixgbe_ptp_check_pps_event
Date: Thu,  1 Nov 2012 03:44:22 -0700
Message-ID: <1351766667-28489-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351766667-28489-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1625 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756213Ab2KAKob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 06:44:31 -0400
In-Reply-To: <1351766667-28489-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes a bug in ixgbe_ptp_check_pps_event where the type was
uninitialized and could cause unknown event outcomes.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 842ba15..01d99af 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -387,6 +387,15 @@ void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ptp_clock_event event;
 
+	event.type = PTP_CLOCK_PPS;
+
+	/* this check is necessary in case the interrupt was enabled via some
+	 * alternative means (ex. debug_fs). Better to check here than
+	 * everywhere that calls this function.
+	 */
+	if (!adapter->ptp_clock)
+		return;
+
 	switch (hw->mac.type) {
 	case ixgbe_mac_X540:
 		ptp_clock_event(adapter->ptp_clock, &event);
-- 
1.7.11.7
