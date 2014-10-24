From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] i40e/i40evf: Use usleep_range() instead of udelay()
Date: Thu, 23 Oct 2014 21:10:01 -0700
Message-ID: <1414123806-20049-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57054 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751733AbaJXEKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 00:10:17 -0400
In-Reply-To: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

As per the Documentation/timers/timers-howto.txt it is preferred to use
usleep_range() instead of udelay() if the delay value is > 10us in
non-atomic contexts.
So, replacing all the instances of udelay() with 10 or greater than 10
micro seconds delay in the driver and using usleep_range() instead.

Change-ID: Iaa2ab499a4c26f6005e5d86cc421407ef9de16c7
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 6 +++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d40fc3b..f7464e8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3440,7 +3440,7 @@ static int i40e_pf_txq_wait(struct i40e_pf *pf, int pf_q, bool enable)
 		if (enable == !!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
 			break;
 
-		udelay(10);
+		usleep_range(10, 20);
 	}
 	if (i >= I40E_QUEUE_WAIT_RETRY_LIMIT)
 		return -ETIMEDOUT;
@@ -3466,7 +3466,7 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 		/* warn the TX unit of coming changes */
 		i40e_pre_tx_queue_cfg(&pf->hw, pf_q, enable);
 		if (!enable)
-			udelay(10);
+			usleep_range(10, 20);
 
 		for (j = 0; j < 50; j++) {
 			tx_reg = rd32(hw, I40E_QTX_ENA(pf_q));
@@ -3526,7 +3526,7 @@ static int i40e_pf_rxq_wait(struct i40e_pf *pf, int pf_q, bool enable)
 		if (enable == !!(rx_reg & I40E_QRX_ENA_QENA_STAT_MASK))
 			break;
 
-		udelay(10);
+		usleep_range(10, 20);
 	}
 	if (i >= I40E_QUEUE_WAIT_RETRY_LIMIT)
 		return -ETIMEDOUT;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 4eeed26..fff3c27 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -674,7 +674,7 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 		 * that the requested op was completed
 		 * successfully
 		 */
-		udelay(10);
+		usleep_range(10, 20);
 		reg = rd32(hw, I40E_VPGEN_VFRSTAT(vf->vf_id));
 		if (reg & I40E_VPGEN_VFRSTAT_VFRD_MASK) {
 			rsd = true;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index c51bc7a..dabe6a4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1494,7 +1494,7 @@ static void i40evf_reset_task(struct work_struct *work)
 
 	while (test_and_set_bit(__I40EVF_IN_CRITICAL_TASK,
 				&adapter->crit_section))
-		udelay(500);
+		usleep_range(500, 1000);
 
 	if (adapter->flags & I40EVF_FLAG_RESET_NEEDED) {
 		dev_info(&adapter->pdev->dev, "Requesting reset from PF\n");
@@ -1980,7 +1980,7 @@ static int i40evf_check_reset_complete(struct i40e_hw *hw)
 		if ((rstat == I40E_VFR_VFACTIVE) ||
 		    (rstat == I40E_VFR_COMPLETED))
 			return 0;
-		udelay(10);
+		usleep_range(10, 20);
 	}
 	return -EBUSY;
 }
-- 
1.9.3
