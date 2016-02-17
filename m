From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/16] i40e: AQ Add set_switch_config
Date: Tue, 16 Feb 2016 21:34:08 -0800
Message-ID: <1455687262-20453-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43674 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756053AbcBQFe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:26 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the new Set Switch Config AdminQ command, and mark the L2 Filter
bit as deprecated in the Add VEB command.

Change-ID: I5b24790f14c56f0ddf3f70df1e486844146b039f
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 15 ++++++++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 15 ++++++++++++++-
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 6e0834e..7e96615 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -145,6 +145,7 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_remove_statistics		= 0x0202,
 	i40e_aqc_opc_set_port_parameters	= 0x0203,
 	i40e_aqc_opc_get_switch_resource_alloc	= 0x0204,
+	i40e_aqc_opc_set_switch_config		= 0x0205,
 
 	i40e_aqc_opc_add_vsi			= 0x0210,
 	i40e_aqc_opc_update_vsi_parameters	= 0x0211,
@@ -683,6 +684,17 @@ struct i40e_aqc_switch_resource_alloc_element_resp {
 
 I40E_CHECK_STRUCT_LEN(0x10, i40e_aqc_switch_resource_alloc_element_resp);
 
+/* Set Switch Configuration (direct 0x0205) */
+struct i40e_aqc_set_switch_config {
+	__le16	flags;
+#define I40E_AQ_SET_SWITCH_CFG_PROMISC		0x0001
+#define I40E_AQ_SET_SWITCH_CFG_L2_FILTER	0x0002
+	__le16	valid_flags;
+	u8	reserved[12];
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aqc_set_switch_config);
+
 /* Add VSI (indirect 0x0210)
  *    this indirect command uses struct i40e_aqc_vsi_properties_data
  *    as the indirect buffer (128 bytes)
@@ -909,7 +921,8 @@ struct i40e_aqc_add_veb {
 					I40E_AQC_ADD_VEB_PORT_TYPE_SHIFT)
 #define I40E_AQC_ADD_VEB_PORT_TYPE_DEFAULT	0x2
 #define I40E_AQC_ADD_VEB_PORT_TYPE_DATA		0x4
-#define I40E_AQC_ADD_VEB_ENABLE_L2_FILTER	0x8
+#define I40E_AQC_ADD_VEB_ENABLE_L2_FILTER	0x8     /* deprecated */
+#define I40E_AQC_ADD_VEB_ENABLE_DISABLE_STATS	0x10
 	u8	enable_tcs;
 	u8	reserved[9];
 };
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 220b972..2c8f3ed 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -145,6 +145,7 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_remove_statistics		= 0x0202,
 	i40e_aqc_opc_set_port_parameters	= 0x0203,
 	i40e_aqc_opc_get_switch_resource_alloc	= 0x0204,
+	i40e_aqc_opc_set_switch_config		= 0x0205,
 
 	i40e_aqc_opc_add_vsi			= 0x0210,
 	i40e_aqc_opc_update_vsi_parameters	= 0x0211,
@@ -680,6 +681,17 @@ struct i40e_aqc_switch_resource_alloc_element_resp {
 
 I40E_CHECK_STRUCT_LEN(0x10, i40e_aqc_switch_resource_alloc_element_resp);
 
+/* Set Switch Configuration (direct 0x0205) */
+struct i40e_aqc_set_switch_config {
+	__le16	flags;
+#define I40E_AQ_SET_SWITCH_CFG_PROMISC		0x0001
+#define I40E_AQ_SET_SWITCH_CFG_L2_FILTER	0x0002
+	__le16	valid_flags;
+	u8	reserved[12];
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aqc_set_switch_config);
+
 /* Add VSI (indirect 0x0210)
  *    this indirect command uses struct i40e_aqc_vsi_properties_data
  *    as the indirect buffer (128 bytes)
@@ -906,7 +918,8 @@ struct i40e_aqc_add_veb {
 					I40E_AQC_ADD_VEB_PORT_TYPE_SHIFT)
 #define I40E_AQC_ADD_VEB_PORT_TYPE_DEFAULT	0x2
 #define I40E_AQC_ADD_VEB_PORT_TYPE_DATA		0x4
-#define I40E_AQC_ADD_VEB_ENABLE_L2_FILTER	0x8
+#define I40E_AQC_ADD_VEB_ENABLE_L2_FILTER	0x8     /* deprecated */
+#define I40E_AQC_ADD_VEB_ENABLE_DISABLE_STATS	0x10
 	u8	enable_tcs;
 	u8	reserved[9];
 };
-- 
2.5.0
