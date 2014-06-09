From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] i40e: remove unused variable and memory allocation
Date: Mon,  9 Jun 2014 01:49:09 -0700
Message-ID: <1402303758-1429-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27481 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754217AbaFIItY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 04:49:24 -0400
In-Reply-To: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

This was a vestige of early driver development that no longer
has any actual use.

Change-ID: I95b5b19c4bbfaff8759197af671ebaf716cb6ab5
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 ----------
 2 files changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index ebeaf95..2af28fd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -297,7 +297,6 @@ struct i40e_pf {
 	u16 pf_seid;
 	u16 main_vsi_seid;
 	u16 mac_seid;
-	struct i40e_aqc_get_switch_config_data *sw_config;
 	struct kobject *switch_kobj;
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *i40e_dbg_pf;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d9a6c69..4ba5192 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7990,15 +7990,6 @@ int i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
 				 "header: %d reported %d total\n",
 				 num_reported, num_total);
 
-		if (num_reported) {
-			int sz = sizeof(*sw_config) * num_reported;
-
-			kfree(pf->sw_config);
-			pf->sw_config = kzalloc(sz, GFP_KERNEL);
-			if (pf->sw_config)
-				memcpy(pf->sw_config, sw_config, sz);
-		}
-
 		for (i = 0; i < num_reported; i++) {
 			struct i40e_aqc_switch_config_element_resp *ele =
 				&sw_config->element[i];
@@ -8718,7 +8709,6 @@ static void i40e_remove(struct pci_dev *pdev)
 
 	kfree(pf->qp_pile);
 	kfree(pf->irq_pile);
-	kfree(pf->sw_config);
 	kfree(pf->vsi);
 
 	/* force a PF reset to clean anything leftover */
-- 
1.9.3
