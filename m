From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/8] i40e/i40evf: save aq writeback for future inspection
Date: Thu, 17 Sep 2015 17:17:54 -0700
Message-ID: <1442535480-65222-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57564 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751929AbbIRASG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 20:18:06 -0400
In-Reply-To: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the ability to save the AdminQ write back descriptor if a
caller supplies a buffer for it to be saved into.

Change-ID: I3d1301d26360b39a2d66dc8569e851f54133a3af
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 4 ++++
 drivers/net/ethernet/intel/i40e/i40e_adminq.h   | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 4 ++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h | 1 +
 4 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 3e0d200..8a77f59 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -889,6 +889,10 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 		   "AQTX: desc and buffer writeback:\n");
 	i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff, buff_size);
 
+	/* save writeback aq if requested */
+	if (details->wb_desc)
+		*details->wb_desc = *desc_on_ring;
+
 	/* update the error if time out occurred */
 	if ((!cmd_completed) &&
 	    (!details->async && !details->postpone)) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index 28e519a..b67b34c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -69,6 +69,7 @@ struct i40e_asq_cmd_details {
 	u16 flags_dis;
 	bool async;
 	bool postpone;
+	struct i40e_aq_desc *wb_desc;
 };
 
 #define I40E_ADMINQ_DETAILS(R, i)   \
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index f08450b..15c8ac8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -830,6 +830,10 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 	i40evf_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff,
 			buff_size);
 
+	/* save writeback aq if requested */
+	if (details->wb_desc)
+		*details->wb_desc = *desc_on_ring;
+
 	/* update the error if time out occurred */
 	if ((!cmd_completed) &&
 	    (!details->async && !details->postpone)) {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index ef43d68..547b79b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -69,6 +69,7 @@ struct i40e_asq_cmd_details {
 	u16 flags_dis;
 	bool async;
 	bool postpone;
+	struct i40e_aq_desc *wb_desc;
 };
 
 #define I40E_ADMINQ_DETAILS(R, i)   \
-- 
2.4.3
