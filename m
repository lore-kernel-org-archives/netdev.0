From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 10/11] ixgbe: Cleanup some whitespace issues,
	fixup and add some comments
Date: Sat, 14 Mar 2009 01:15:31 -0700
Message-ID: <20090314081531.4687.34601.stgit@lost.foo-projects.org>
References: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:41534
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753268AbZCNIPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 04:15:55 -0400
In-Reply-To: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Cleanup a bit of whitespace, add some function header comments, and fix a
few comments around the driver.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    5 ++---
 drivers/net/ixgbe/ixgbe_main.c  |   31 +++++++++++++++++++++++++++----
 2 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 56efa98..beae7e0 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -404,8 +404,7 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw)
 {
 	s32 status = 0;
 	ixgbe_link_speed link_speed = IXGBE_LINK_SPEED_82599_AUTONEG;
-	status = ixgbe_setup_mac_link_speed_multispeed_fiber(hw,
-	                                                     link_speed,
+	status = ixgbe_setup_mac_link_speed_multispeed_fiber(hw, link_speed,
 	                                                     true, true);
 	return status;
 }
@@ -759,7 +758,7 @@ s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 		hw->mac.orig_autoc = autoc;
 		hw->mac.orig_autoc2 = autoc2;
 		hw->mac.orig_link_settings_stored = true;
-	} else  {
+	} else {
 		if (autoc != hw->mac.orig_autoc)
 			IXGBE_WRITE_REG(hw, IXGBE_AUTOC, (hw->mac.orig_autoc |
 			                IXGBE_AUTOC_AN_RESTART));
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ef0b99a..335119a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -779,7 +779,8 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 
 	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
-	/* Populate the IVAR table and set the ITR values to the
+	/*
+	 * Populate the IVAR table and set the ITR values to the
 	 * corresponding register.
 	 */
 	for (v_idx = 0; v_idx < q_vectors; v_idx++) {
@@ -814,7 +815,7 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 			q_vector->eitr = adapter->eitr_param;
 
 		/*
-		 * since ths is initial set up don't need to call
+		 * since this is initial set up don't need to call
 		 * ixgbe_write_eitr helper
 		 */
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx),
@@ -2675,6 +2676,14 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 }
 #endif
 
+/**
+ * ixgbe_set_rss_queues: Allocate queues for RSS
+ * @adapter: board private structure to initialize
+ *
+ * This is our "base" multiqueue mode.  RSS (Receive Side Scaling) will try
+ * to allocate one Rx queue per CPU, and if available, one Tx queue per CPU.
+ *
+ **/
 static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 {
 	bool ret = false;
@@ -2693,6 +2702,17 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 	return ret;
 }
 
+/*
+ * ixgbe_set_num_queues: Allocate queues for device, feature dependant
+ * @adapter: board private structure to initialize
+ *
+ * This is the top level queue allocation routine.  The order here is very
+ * important, starting with the "most" number of features turned on at once,
+ * and ending with the smallest set of features.  This way large combinations
+ * can be allocated if they're turned on, and smaller combinations are the
+ * fallthrough conditions.
+ *
+ **/
 static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 {
 	/* Start with base case */
@@ -2856,7 +2876,8 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
  * @adapter: board private structure to initialize
  *
  * We allocate one ring per queue at run-time since we don't know the
- * number of queues at compile-time.
+ * number of queues at compile-time.  The polling_netdev array is
+ * intended for Multiqueue, but should work fine with a single queue.
  **/
 static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 {
@@ -3035,7 +3056,8 @@ static void ixgbe_sfp_timer(unsigned long data)
 {
 	struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)data;
 
-	/* Do the sfp_timer outside of interrupt context due to the
+	/*
+	 * Do the sfp_timer outside of interrupt context due to the
 	 * delays that sfp+ detection requires
 	 */
 	schedule_work(&adapter->sfp_task);
@@ -3609,6 +3631,7 @@ static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
 	retval = pci_save_state(pdev);
 	if (retval)
 		return retval;
+
 #endif
 	if (wufc) {
 		ixgbe_set_rx_mode(netdev);

