From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Add support for HMC resource and profile for X722
Date: Fri, 19 Aug 2016 23:19:44 -0700
Message-ID: <1471673991-117115-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:37803 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752404AbcHTGTz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:19:55 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds support for HMC resource and profile cmds for X722
firmware.

Change-ID: Icc332101f38ab15d1bfa167823100eb4f6822f7e
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 21 +++++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 21 +++++++++++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 5c4bf76..67e396b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -204,6 +204,9 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_suspend_port_tx				= 0x041B,
 	i40e_aqc_opc_resume_port_tx				= 0x041C,
 	i40e_aqc_opc_configure_partition_bw			= 0x041D,
+	/* hmc */
+	i40e_aqc_opc_query_hmc_resource_profile	= 0x0500,
+	i40e_aqc_opc_set_hmc_resource_profile	= 0x0501,
 
 	/* phy commands*/
 	i40e_aqc_opc_get_phy_abilities		= 0x0600,
@@ -1586,6 +1589,24 @@ struct i40e_aqc_configure_partition_bw_data {
 
 I40E_CHECK_STRUCT_LEN(0x22, i40e_aqc_configure_partition_bw_data);
 
+/* Get and set the active HMC resource profile and status.
+ * (direct 0x0500) and (direct 0x0501)
+ */
+struct i40e_aq_get_set_hmc_resource_profile {
+	u8	pm_profile;
+	u8	pe_vf_enabled;
+	u8	reserved[14];
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aq_get_set_hmc_resource_profile);
+
+enum i40e_aq_hmc_profile {
+	/* I40E_HMC_PROFILE_NO_CHANGE	= 0, reserved */
+	I40E_HMC_PROFILE_DEFAULT	= 1,
+	I40E_HMC_PROFILE_FAVOR_VF	= 2,
+	I40E_HMC_PROFILE_EQUAL		= 3,
+};
+
 /* Get PHY Abilities (indirect 0x0600) uses the generic indirect struct */
 
 /* set in param0 for get phy abilities to report qualified modules */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 0045650..40b0eaf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -204,6 +204,9 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_suspend_port_tx				= 0x041B,
 	i40e_aqc_opc_resume_port_tx				= 0x041C,
 	i40e_aqc_opc_configure_partition_bw			= 0x041D,
+	/* hmc */
+	i40e_aqc_opc_query_hmc_resource_profile	= 0x0500,
+	i40e_aqc_opc_set_hmc_resource_profile	= 0x0501,
 
 	/* phy commands*/
 	i40e_aqc_opc_get_phy_abilities		= 0x0600,
@@ -1583,6 +1586,24 @@ struct i40e_aqc_configure_partition_bw_data {
 
 I40E_CHECK_STRUCT_LEN(0x22, i40e_aqc_configure_partition_bw_data);
 
+/* Get and set the active HMC resource profile and status.
+ * (direct 0x0500) and (direct 0x0501)
+ */
+struct i40e_aq_get_set_hmc_resource_profile {
+	u8	pm_profile;
+	u8	pe_vf_enabled;
+	u8	reserved[14];
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aq_get_set_hmc_resource_profile);
+
+enum i40e_aq_hmc_profile {
+	/* I40E_HMC_PROFILE_NO_CHANGE	= 0, reserved */
+	I40E_HMC_PROFILE_DEFAULT	= 1,
+	I40E_HMC_PROFILE_FAVOR_VF	= 2,
+	I40E_HMC_PROFILE_EQUAL		= 3,
+};
+
 /* Get PHY Abilities (indirect 0x0600) uses the generic indirect struct */
 
 /* set in param0 for get phy abilities to report qualified modules */
-- 
2.7.4
