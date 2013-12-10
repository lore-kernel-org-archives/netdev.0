From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] i40e: loopback info and set loopback fix
Date: Tue, 10 Dec 2013 02:22:31 -0800
Message-ID: <1386670961-20392-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30241 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522Ab3LJKXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 05:23:10 -0500
In-Reply-To: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamil Krawczyk <kamil.krawczyk@intel.com>

Add information about current loopback mode to data returned from
get_link_info function. Minor fix in set_loopback function and
update in loopback types enum.

Change-Id: I9d1c540a84ab18eef5ea6429be6331f33fc06aca
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 1 +
 drivers/net/ethernet/intel/i40e/i40e_diag.h   | 8 ++++----
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 1 +
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 0b52fbc..e526d40 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -562,6 +562,7 @@ i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
 	hw_link_info->link_info = resp->link_info;
 	hw_link_info->an_info = resp->an_info;
 	hw_link_info->ext_info = resp->ext_info;
+	hw_link_info->loopback = resp->loopback;
 
 	if (resp->command_flags & cpu_to_le16(I40E_AQ_LSE_ENABLE))
 		hw_link_info->lse_enable = true;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_diag.h b/drivers/net/ethernet/intel/i40e/i40e_diag.h
index 3d98277..d1fc68c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_diag.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_diag.h
@@ -31,10 +31,10 @@
 #include "i40e_type.h"
 
 enum i40e_lb_mode {
-	I40E_LB_MODE_NONE = 0,
-	I40E_LB_MODE_PHY_LOCAL,
-	I40E_LB_MODE_PHY_REMOTE,
-	I40E_LB_MODE_MAC_LOCAL,
+	I40E_LB_MODE_NONE       = 0x0,
+	I40E_LB_MODE_PHY_LOCAL  = I40E_AQ_LB_PHY_LOCAL,
+	I40E_LB_MODE_PHY_REMOTE = I40E_AQ_LB_PHY_REMOTE,
+	I40E_LB_MODE_MAC_LOCAL  = I40E_AQ_LB_MAC_LOCAL,
 };
 
 struct i40e_diag_reg_test_info {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 88b37e0..8ae6445 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -172,6 +172,7 @@ struct i40e_link_status {
 	u8 link_info;
 	u8 an_info;
 	u8 ext_info;
+	u8 loopback;
 	/* is Link Status Event notification to SW enabled */
 	bool lse_enable;
 };
-- 
1.8.3.1
