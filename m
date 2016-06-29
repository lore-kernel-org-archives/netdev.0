From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] i40e: add functions to control default VSI
Date: Tue, 28 Jun 2016 21:40:47 -0700
Message-ID: <1467175262-54719-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20214 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbcF2ErJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:47:09 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Add functions to enable and disable default VSI on a VEB. This allows
for configuration of limited promiscuous mode specifically for bridging
purposes.

Change-ID: I0cc5bd68b31c500fdff4d47e1f15d50d2739faf4
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 56 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  2 +
 2 files changed, 58 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 422b41d..e447dc4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1967,6 +1967,62 @@ aq_add_vsi_exit:
 }
 
 /**
+ * i40e_aq_set_default_vsi
+ * @hw: pointer to the hw struct
+ * @seid: vsi number
+ * @cmd_details: pointer to command details structure or NULL
+ **/
+i40e_status i40e_aq_set_default_vsi(struct i40e_hw *hw,
+				    u16 seid,
+				    struct i40e_asq_cmd_details *cmd_details)
+{
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_set_vsi_promiscuous_modes *cmd =
+		(struct i40e_aqc_set_vsi_promiscuous_modes *)
+		&desc.params.raw;
+	i40e_status status;
+
+	i40e_fill_default_direct_cmd_desc(&desc,
+					  i40e_aqc_opc_set_vsi_promiscuous_modes);
+
+	cmd->promiscuous_flags = cpu_to_le16(I40E_AQC_SET_VSI_DEFAULT);
+	cmd->valid_flags = cpu_to_le16(I40E_AQC_SET_VSI_DEFAULT);
+	cmd->seid = cpu_to_le16(seid);
+
+	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+
+	return status;
+}
+
+/**
+ * i40e_aq_clear_default_vsi
+ * @hw: pointer to the hw struct
+ * @seid: vsi number
+ * @cmd_details: pointer to command details structure or NULL
+ **/
+i40e_status i40e_aq_clear_default_vsi(struct i40e_hw *hw,
+				      u16 seid,
+				      struct i40e_asq_cmd_details *cmd_details)
+{
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_set_vsi_promiscuous_modes *cmd =
+		(struct i40e_aqc_set_vsi_promiscuous_modes *)
+		&desc.params.raw;
+	i40e_status status;
+
+	i40e_fill_default_direct_cmd_desc(&desc,
+					  i40e_aqc_opc_set_vsi_promiscuous_modes);
+
+	cmd->promiscuous_flags = cpu_to_le16(0);
+	cmd->valid_flags = cpu_to_le16(I40E_AQC_SET_VSI_DEFAULT);
+	cmd->seid = cpu_to_le16(seid);
+
+	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+
+	return status;
+}
+
+/**
  * i40e_aq_set_vsi_unicast_promiscuous
  * @hw: pointer to the hw struct
  * @seid: vsi number
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 80403c6..4660c5a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -98,6 +98,8 @@ i40e_status i40e_aq_set_phy_debug(struct i40e_hw *hw, u8 cmd_flags,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_default_vsi(struct i40e_hw *hw, u16 vsi_id,
 				struct i40e_asq_cmd_details *cmd_details);
+i40e_status i40e_aq_clear_default_vsi(struct i40e_hw *hw, u16 vsi_id,
+				      struct i40e_asq_cmd_details *cmd_details);
 enum i40e_status_code i40e_aq_get_phy_capabilities(struct i40e_hw *hw,
 			bool qualified_modules, bool report_init,
 			struct i40e_aq_get_phy_abilities_resp *abilities,
-- 
2.5.5
