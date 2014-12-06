From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/16] i40e: remove useless debug noise
Date: Sat,  6 Dec 2014 05:01:59 -0800
Message-ID: <1417870933-17248-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752652AbaLFNC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 08:02:57 -0500
In-Reply-To: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

This message really doesn't give any useful information and ends up
getting printed every service_task loop in the Linux driver, filling the
logfile with noise when AQ tracing is enabled.  This patch simply removes
the noise.

Change-ID: I30ad51e6b03c7ad12a7d9c102def0087db622df3
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 3 ---
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 3 ---
 2 files changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 5bb4914..5dc12c4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -956,9 +956,6 @@ i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
 	ntu = (rd32(hw, hw->aq.arq.head) & I40E_PF_ARQH_ARQH_MASK);
 	if (ntu == ntc) {
 		/* nothing to do - shouldn't need to update ring's values */
-		i40e_debug(hw,
-			   I40E_DEBUG_AQ_MESSAGE,
-			   "AQRX: Queue is empty.\n");
 		ret_code = I40E_ERR_ADMIN_QUEUE_NO_WORK;
 		goto clean_arq_element_out;
 	}
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index d7e446f..ff6305a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -905,9 +905,6 @@ i40e_status i40evf_clean_arq_element(struct i40e_hw *hw,
 	ntu = (rd32(hw, hw->aq.arq.head) & I40E_PF_ARQH_ARQH_MASK);
 	if (ntu == ntc) {
 		/* nothing to do - shouldn't need to update ring's values */
-		i40e_debug(hw,
-			   I40E_DEBUG_AQ_MESSAGE,
-			   "AQRX: Queue is empty.\n");
 		ret_code = I40E_ERR_ADMIN_QUEUE_NO_WORK;
 		goto clean_arq_element_out;
 	}
-- 
1.9.3
