From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] i40e: Implement the API function for aq_set_switch_config
Date: Sat, 14 May 2016 21:57:25 -0700
Message-ID: <1463288255-1654-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51923 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731AbcEOE5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:39 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the support code for calling the AdminQ API call aq_set_switch_config

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 29 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  4 ++++
 2 files changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 4a934e1..4739a9c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2283,6 +2283,35 @@ i40e_status i40e_aq_get_switch_config(struct i40e_hw *hw,
 }
 
 /**
+ * i40e_aq_set_switch_config
+ * @hw: pointer to the hardware structure
+ * @flags: bit flag values to set
+ * @valid_flags: which bit flags to set
+ * @cmd_details: pointer to command details structure or NULL
+ *
+ * Set switch configuration bits
+ **/
+enum i40e_status_code i40e_aq_set_switch_config(struct i40e_hw *hw,
+						u16 flags,
+						u16 valid_flags,
+				struct i40e_asq_cmd_details *cmd_details)
+{
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_set_switch_config *scfg =
+		(struct i40e_aqc_set_switch_config *)&desc.params.raw;
+	enum i40e_status_code status;
+
+	i40e_fill_default_direct_cmd_desc(&desc,
+					  i40e_aqc_opc_set_switch_config);
+	scfg->flags = cpu_to_le16(flags);
+	scfg->valid_flags = cpu_to_le16(valid_flags);
+
+	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+
+	return status;
+}
+
+/**
  * i40e_aq_get_firmware_version
  * @hw: pointer to the hw struct
  * @fw_major_version: firmware major version
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 4c8977c..b76b158 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -182,6 +182,10 @@ i40e_status i40e_aq_get_switch_config(struct i40e_hw *hw,
 				struct i40e_aqc_get_switch_config_resp *buf,
 				u16 buf_size, u16 *start_seid,
 				struct i40e_asq_cmd_details *cmd_details);
+enum i40e_status_code i40e_aq_set_switch_config(struct i40e_hw *hw,
+						u16 flags,
+						u16 valid_flags,
+				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_request_resource(struct i40e_hw *hw,
 				enum i40e_aq_resources_ids resource,
 				enum i40e_aq_resource_access_type access,
-- 
2.5.5
