From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/17] i40e/i40evf: AdminQ updates ww36
Date: Thu, 15 Jan 2015 04:19:12 -0800
Message-ID: <1421324368-6860-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Kamil Kacperski <kamil.kacperski@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47496 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994AbbAOMTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:19:31 -0500
In-Reply-To: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Several little tweaks to keep FW, SV, and SW in line together
 - Remove the unused and deprecated
   i40e_aqc_opc_debug_modify_internals
 - Add define for iSCSI capability
 - Fix queue mask size
 - Adjust i40e_aqc_oem_param_change for ease-of-use

Change-ID: I51f250b367912968a7cec61b3a68110d9796e914
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Kamil Kacperski <kamil.kacperski@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 9 +++++----
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 9 +++++----
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 8835aee..490dfcf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -276,7 +276,6 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_debug_write_reg		= 0xFF04,
 	i40e_aqc_opc_debug_modify_reg		= 0xFF07,
 	i40e_aqc_opc_debug_dump_internals	= 0xFF08,
-	i40e_aqc_opc_debug_modify_internals	= 0xFF09,
 };
 
 /* command structures and indirect data structures */
@@ -410,6 +409,7 @@ struct i40e_aqc_list_capabilities_element_resp {
 #define I40E_AQ_CAP_ID_VSI		0x0017
 #define I40E_AQ_CAP_ID_DCB		0x0018
 #define I40E_AQ_CAP_ID_FCOE		0x0021
+#define I40E_AQ_CAP_ID_ISCSI		0x0022
 #define I40E_AQ_CAP_ID_RSS		0x0040
 #define I40E_AQ_CAP_ID_RXQ		0x0041
 #define I40E_AQ_CAP_ID_TXQ		0x0042
@@ -1207,7 +1207,7 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 	} ipaddr;
 	__le16	flags;
 #define I40E_AQC_ADD_CLOUD_FILTER_SHIFT			0
-#define I40E_AQC_ADD_CLOUD_FILTER_MASK			(0x3F << \
+#define I40E_AQC_ADD_CLOUD_FILTER_MASK	(0x3F << \
 					I40E_AQC_ADD_CLOUD_FILTER_SHIFT)
 /* 0x0000 reserved */
 #define I40E_AQC_ADD_CLOUD_FILTER_OIP			0x0001
@@ -1240,7 +1240,7 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 	u8	reserved[4];
 	__le16	queue_number;
 #define I40E_AQC_ADD_CLOUD_QUEUE_SHIFT		0
-#define I40E_AQC_ADD_CLOUD_QUEUE_MASK		(0x3F << \
+#define I40E_AQC_ADD_CLOUD_QUEUE_MASK		(0x7FF << \
 						 I40E_AQC_ADD_CLOUD_QUEUE_SHIFT)
 	u8	reserved2[14];
 	/* response section */
@@ -2106,7 +2106,8 @@ struct i40e_aqc_oem_param_change {
 #define I40E_AQ_OEM_PARAM_TYPE_BW_CTL	1
 #define I40E_AQ_OEM_PARAM_MAC		2
 	__le32	param_value1;
-	u8	param_value2[8];
+	__le16	param_value2;
+	u8	reserved[6];
 };
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_oem_param_change);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index ff1b163..a20b2b0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -276,7 +276,6 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_debug_write_reg		= 0xFF04,
 	i40e_aqc_opc_debug_modify_reg		= 0xFF07,
 	i40e_aqc_opc_debug_dump_internals	= 0xFF08,
-	i40e_aqc_opc_debug_modify_internals	= 0xFF09,
 };
 
 /* command structures and indirect data structures */
@@ -410,6 +409,7 @@ struct i40e_aqc_list_capabilities_element_resp {
 #define I40E_AQ_CAP_ID_VSI		0x0017
 #define I40E_AQ_CAP_ID_DCB		0x0018
 #define I40E_AQ_CAP_ID_FCOE		0x0021
+#define I40E_AQ_CAP_ID_ISCSI		0x0022
 #define I40E_AQ_CAP_ID_RSS		0x0040
 #define I40E_AQ_CAP_ID_RXQ		0x0041
 #define I40E_AQ_CAP_ID_TXQ		0x0042
@@ -1207,7 +1207,7 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 	} ipaddr;
 	__le16	flags;
 #define I40E_AQC_ADD_CLOUD_FILTER_SHIFT			0
-#define I40E_AQC_ADD_CLOUD_FILTER_MASK			(0x3F << \
+#define I40E_AQC_ADD_CLOUD_FILTER_MASK	(0x3F << \
 					I40E_AQC_ADD_CLOUD_FILTER_SHIFT)
 /* 0x0000 reserved */
 #define I40E_AQC_ADD_CLOUD_FILTER_OIP			0x0001
@@ -1240,7 +1240,7 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 	u8	reserved[4];
 	__le16	queue_number;
 #define I40E_AQC_ADD_CLOUD_QUEUE_SHIFT		0
-#define I40E_AQC_ADD_CLOUD_QUEUE_MASK		(0x3F << \
+#define I40E_AQC_ADD_CLOUD_QUEUE_MASK		(0x7FF << \
 						 I40E_AQC_ADD_CLOUD_QUEUE_SHIFT)
 	u8	reserved2[14];
 	/* response section */
@@ -2082,7 +2082,8 @@ struct i40e_aqc_oem_param_change {
 #define I40E_AQ_OEM_PARAM_TYPE_BW_CTL	1
 #define I40E_AQ_OEM_PARAM_MAC		2
 	__le32	param_value1;
-	u8	param_value2[8];
+	__le16	param_value2;
+	u8	reserved[6];
 };
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_oem_param_change);
-- 
1.9.3
