From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] i40e: get rid of unused locals
Date: Tue, 14 Apr 2015 21:51:49 -0700
Message-ID: <1429073511-27664-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49799 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396AbbDOEwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:52:15 -0400
In-Reply-To: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

These changes just remove unused variables and any code that uses them
as the results of storing into these variables doesn't have any
side effects that I can see or provide any benefit.

Change-ID: I8a5ec7132ff1443d23aae729cef94beaaaf19e3a
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c | 6 ++----
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 3 +--
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 6e14667..2547aa2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -419,7 +419,7 @@ static void i40e_cee_to_dcb_v1_config(
 {
 	u16 status, tlv_status = le16_to_cpu(cee_cfg->tlv_status);
 	u16 app_prio = le16_to_cpu(cee_cfg->oper_app_prio);
-	u8 i, tc, err, sync, oper;
+	u8 i, tc, err;
 
 	/* CEE PG data to ETS config */
 	dcbcfg->etscfg.maxtcs = cee_cfg->oper_num_tc;
@@ -456,9 +456,7 @@ static void i40e_cee_to_dcb_v1_config(
 	status = (tlv_status & I40E_AQC_CEE_APP_STATUS_MASK) >>
 		  I40E_AQC_CEE_APP_STATUS_SHIFT;
 	err = (status & I40E_TLV_STATUS_ERR) ? 1 : 0;
-	sync = (status & I40E_TLV_STATUS_SYNC) ? 1 : 0;
-	oper = (status & I40E_TLV_STATUS_OPER) ? 1 : 0;
-	/* Add APPs if Error is False and Oper/Sync is True */
+	/* Add APPs if Error is False */
 	if (!err) {
 		/* CEE operating configuration supports FCoE/iSCSI/FIP only */
 		dcbcfg->numapps = I40E_CEE_OPER_MAX_APPS;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index e49acd2..554e49d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -821,13 +821,12 @@ static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 						 int *errno)
 {
 	enum i40e_nvmupd_cmd upd_cmd;
-	u8 transaction, module;
+	u8 transaction;
 
 	/* anything that doesn't match a recognized case is an error */
 	upd_cmd = I40E_NVMUPD_INVALID;
 
 	transaction = i40e_nvmupd_get_transaction(cmd->config);
-	module = i40e_nvmupd_get_module(cmd->config);
 
 	/* limits on data size */
 	if ((cmd->data_size < 1) ||
-- 
1.9.3
