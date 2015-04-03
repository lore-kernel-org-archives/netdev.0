From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: Change some memcpys to struct assignments
Date: Fri,  3 Apr 2015 05:04:47 -0700
Message-ID: <1428062698-16180-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40006 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752377AbbDCMFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2015 08:05:33 -0400
In-Reply-To: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Several memcpys are not necessary and can be changed to structure
assignments.  Struct assignments are always type safe so this
is preferable.

Change-ID: I7daf45a4b5e799c686b9d5c8ba9db047584ab82b
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 77e3b84..9e19933 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1969,7 +1969,7 @@ void i40e_vlan_stripping_enable(struct i40e_vsi *vsi)
 				    I40E_AQ_VSI_PVLAN_EMOD_STR_BOTH;
 
 	ctxt.seid = vsi->seid;
-	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
+	ctxt.info = vsi->info;
 	ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (ret) {
 		dev_info(&vsi->back->pdev->dev,
@@ -1998,7 +1998,7 @@ void i40e_vlan_stripping_disable(struct i40e_vsi *vsi)
 				    I40E_AQ_VSI_PVLAN_EMOD_NOTHING;
 
 	ctxt.seid = vsi->seid;
-	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
+	ctxt.info = vsi->info;
 	ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (ret) {
 		dev_info(&vsi->back->pdev->dev,
@@ -2282,7 +2282,7 @@ int i40e_vsi_add_pvid(struct i40e_vsi *vsi, u16 vid)
 				    I40E_AQ_VSI_PVLAN_EMOD_STR;
 
 	ctxt.seid = vsi->seid;
-	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
+	ctxt.info = vsi->info;
 	aq_ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (aq_ret) {
 		dev_info(&vsi->back->pdev->dev,
@@ -4395,7 +4395,7 @@ static int i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 	ctxt.pf_num = vsi->back->hw.pf_id;
 	ctxt.vf_num = 0;
 	ctxt.uplink_seid = vsi->uplink_seid;
-	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
+	ctxt.info = vsi->info;
 	i40e_vsi_setup_queue_map(vsi, &ctxt, enabled_tc, false);
 
 	/* Update the VSI after updating the VSI queue-mapping information */
@@ -5223,9 +5223,8 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 		goto exit;
 	}
 
-	memset(&tmp_dcbx_cfg, 0, sizeof(tmp_dcbx_cfg));
 	/* Store the old configuration */
-	memcpy(&tmp_dcbx_cfg, &hw->local_dcbx_config, sizeof(tmp_dcbx_cfg));
+	tmp_dcbx_cfg = hw->local_dcbx_config;
 
 	/* Reset the old DCBx configuration data */
 	memset(&hw->local_dcbx_config, 0, sizeof(hw->local_dcbx_config));
@@ -5785,11 +5784,9 @@ static void i40e_handle_link_event(struct i40e_pf *pf,
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_aqc_get_link_status *status =
 		(struct i40e_aqc_get_link_status *)&e->desc.params.raw;
-	struct i40e_link_status *hw_link_info = &hw->phy.link_info;
 
 	/* save off old link status information */
-	memcpy(&pf->hw.phy.link_info_old, hw_link_info,
-	       sizeof(pf->hw.phy.link_info_old));
+	hw->phy.link_info_old = hw->phy.link_info;
 
 	/* Do a new status request to re-enable LSE reporting
 	 * and load new status information into the hw struct
@@ -8272,7 +8269,7 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 				 ret, pf->hw.aq.asq_last_status);
 			return -ENOENT;
 		}
-		memcpy(&vsi->info, &ctxt.info, sizeof(ctxt.info));
+		vsi->info = ctxt.info;
 		vsi->info.valid_sections = 0;
 
 		vsi->seid = ctxt.seid;
@@ -8406,7 +8403,7 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 			ret = -ENOENT;
 			goto err;
 		}
-		memcpy(&vsi->info, &ctxt.info, sizeof(ctxt.info));
+		vsi->info = ctxt.info;
 		vsi->info.valid_sections = 0;
 		vsi->seid = ctxt.seid;
 		vsi->id = ctxt.vsi_number;
-- 
1.9.3
