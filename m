From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/13] i40e: remove unused nvm_semaphore_wait
Date: Tue,  9 Dec 2014 13:26:14 -0800
Message-ID: <1418160380-29847-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:29734 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753097AbaLIV01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 16:26:27 -0500
In-Reply-To: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The nvm_semaphore_wait field is set but never used, so let's
just get rid of it.

Change-ID: I2107bd29b69f99b1a61d7591d087429527c9d8fa
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Michal Kosiarz <michal.kosiarz@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c    | 2 --
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 1 -
 3 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index df429bb..37f0f5f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -116,8 +116,6 @@ i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
 		}
 		if (ret_code) {
 			hw->nvm.hw_semaphore_timeout = 0;
-			hw->nvm.hw_semaphore_wait =
-						I40E_MS_TO_GTIME(time) + gtime;
 			i40e_debug(hw, I40E_DEBUG_NVM,
 				   "NVM acquire timed out, wait %llu ms before trying again.\n",
 				   time);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 3904dd8..306a23a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -262,7 +262,6 @@ enum i40e_aq_resource_access_type {
 
 struct i40e_nvm_info {
 	u64 hw_semaphore_timeout; /* 2usec global time (GTIME resolution) */
-	u64 hw_semaphore_wait;    /* - || - */
 	u32 timeout;              /* [ms] */
 	u16 sr_size;              /* Shadow RAM size in words */
 	bool blank_nvm_mode;      /* is NVM empty (no FW present)*/
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 77abe17..9d472d6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -261,7 +261,6 @@ enum i40e_aq_resource_access_type {
 
 struct i40e_nvm_info {
 	u64 hw_semaphore_timeout; /* 2usec global time (GTIME resolution) */
-	u64 hw_semaphore_wait;    /* - || - */
 	u32 timeout;              /* [ms] */
 	u16 sr_size;              /* Shadow RAM size in words */
 	bool blank_nvm_mode;      /* is NVM empty (no FW present)*/
-- 
1.9.3
