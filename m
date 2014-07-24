From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] i40e: always print aqtx answer
Date: Thu, 24 Jul 2014 06:13:24 -0700
Message-ID: <1406207604-31653-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36520 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759287AbaGXNOH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 09:14:07 -0400
In-Reply-To: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Sometimes the AQTX answer comes back with no data, but we still want to print
the descriptor that got written back.

Change-ID: I5f734d99b4c95510987413893f0a34626571d474
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 8 +++-----
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 8 +++-----
 2 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index c6d767c..b29c157 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -889,11 +889,9 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 		hw->aq.asq_last_status = (enum i40e_admin_queue_err)retval;
 	}
 
-	if (le16_to_cpu(desc->datalen) == buff_size) {
-		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
-			   "AQTX: desc and buffer writeback:\n");
-		i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff);
-	}
+	i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
+		   "AQTX: desc and buffer writeback:\n");
+	i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff);
 
 	/* update the error if time out occurred */
 	if ((!cmd_completed) &&
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 3291d2c..0030060 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -840,11 +840,9 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 	if (i40e_is_nvm_update_op(desc))
 		hw->aq.nvm_busy = true;
 
-	if (le16_to_cpu(desc->datalen) == buff_size) {
-		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
-			   "AQTX: desc and buffer writeback:\n");
-		i40evf_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff);
-	}
+	i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
+		   "AQTX: desc and buffer writeback:\n");
+	i40evf_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff);
 
 	/* update the error if time out occurred */
 	if ((!cmd_completed) &&
-- 
1.9.3
