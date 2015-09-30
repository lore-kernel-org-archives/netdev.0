From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] i40e: fixup padding issue in get_cee_dcb_cfg_v1_resp
Date: Wed, 30 Sep 2015 05:52:29 -0700
Message-ID: <1443617561-40490-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8321 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755491AbbI3Mwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:44 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The struct i40e_aqc_get_cee_dcb_cfg_v1_resp was originally defined with
word boundary layout issues, which most compilers deal with by silently
adding padding, making the actual struct larger than designed.
This patch adds an extra byte in fields reserved3 and reserved4 to directly
acknowledge that padding.

Because the struct doesn't actually change in size or layout, this doesn't
constitute a change in the API.

Change-ID: I53fa4741b73fa255621232a85fba000b0e223015
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 95d23bf..b840fab 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -2074,6 +2074,15 @@ I40E_CHECK_CMD_LENGTH(i40e_aqc_lldp_start);
 #define I40E_AQC_CEE_ISCSI_STATUS_MASK	(0x7 << I40E_AQC_CEE_ISCSI_STATUS_SHIFT)
 #define I40E_AQC_CEE_FIP_STATUS_SHIFT	0x10
 #define I40E_AQC_CEE_FIP_STATUS_MASK	(0x7 << I40E_AQC_CEE_FIP_STATUS_SHIFT)
+
+/* struct i40e_aqc_get_cee_dcb_cfg_v1_resp was originally defined with
+ * word boundary layout issues, which the Linux compilers silently deal
+ * with by adding padding, making the actual struct larger than designed.
+ * However, the FW compiler for the NIC is less lenient and complains
+ * about the struct.  Hence, the struct defined here has an extra byte in
+ * fields reserved3 and reserved4 to directly acknowledge that padding,
+ * and the new length is used in the length check macro.
+ */
 struct i40e_aqc_get_cee_dcb_cfg_v1_resp {
 	u8	reserved1;
 	u8	oper_num_tc;
@@ -2081,9 +2090,9 @@ struct i40e_aqc_get_cee_dcb_cfg_v1_resp {
 	u8	reserved2;
 	u8	oper_tc_bw[8];
 	u8	oper_pfc_en;
-	u8	reserved3;
+	u8	reserved3[2];
 	__le16	oper_app_prio;
-	u8	reserved4;
+	u8	reserved4[2];
 	__le16	tlv_status;
 };
 
-- 
2.4.3
