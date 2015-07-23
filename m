From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: clean up unneeded gotos
Date: Thu, 23 Jul 2015 06:52:36 -0700
Message-ID: <1437659564-48822-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Laurent Navet <laurent.navet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7061 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762AbbGWNww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:52:52 -0400
In-Reply-To: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

With a little work we can clean up some unnecessary logic jumping and
drop a variable.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Cc: Laurent Navet <laurent.navet@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_hmc.c | 37 ++++++++++--------------------
 1 file changed, 12 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_hmc.c
index b89856a..5ebe12d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_hmc.c
@@ -297,21 +297,15 @@ i40e_status i40e_remove_sd_bp_new(struct i40e_hw *hw,
 					    u32 idx, bool is_pf)
 {
 	struct i40e_hmc_sd_entry *sd_entry;
-	i40e_status ret_code = 0;
+
+	if (!is_pf)
+		return I40E_NOT_SUPPORTED;
 
 	/* get the entry and decrease its ref counter */
 	sd_entry = &hmc_info->sd_table.sd_entry[idx];
-	if (is_pf) {
-		I40E_CLEAR_PF_SD_ENTRY(hw, idx, I40E_SD_TYPE_DIRECT);
-	} else {
-		ret_code = I40E_NOT_SUPPORTED;
-		goto exit;
-	}
-	ret_code = i40e_free_dma_mem(hw, &(sd_entry->u.bp.addr));
-	if (ret_code)
-		goto exit;
-exit:
-	return ret_code;
+	I40E_CLEAR_PF_SD_ENTRY(hw, idx, I40E_SD_TYPE_DIRECT);
+
+	return i40e_free_dma_mem(hw, &sd_entry->u.bp.addr);
 }
 
 /**
@@ -351,20 +345,13 @@ i40e_status i40e_remove_pd_page_new(struct i40e_hw *hw,
 					      struct i40e_hmc_info *hmc_info,
 					      u32 idx, bool is_pf)
 {
-	i40e_status ret_code = 0;
 	struct i40e_hmc_sd_entry *sd_entry;
 
+	if (!is_pf)
+		return I40E_NOT_SUPPORTED;
+
 	sd_entry = &hmc_info->sd_table.sd_entry[idx];
-	if (is_pf) {
-		I40E_CLEAR_PF_SD_ENTRY(hw, idx, I40E_SD_TYPE_PAGED);
-	} else {
-		ret_code = I40E_NOT_SUPPORTED;
-		goto exit;
-	}
-	/* free memory here */
-	ret_code = i40e_free_dma_mem(hw, &(sd_entry->u.pd_table.pd_page_addr));
-	if (ret_code)
-		goto exit;
-exit:
-	return ret_code;
+	I40E_CLEAR_PF_SD_ENTRY(hw, idx, I40E_SD_TYPE_PAGED);
+
+	return  i40e_free_dma_mem(hw, &sd_entry->u.pd_table.pd_page_addr);
 }
-- 
2.4.3
