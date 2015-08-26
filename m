From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/14] i40e/i40evf: Cache the CEE TLV status returned from firmware
Date: Wed, 26 Aug 2015 15:49:32 -0700
Message-ID: <1440629373-21287-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12760 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757010AbbHZWtj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 18:49:39 -0400
In-Reply-To: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

Store the CEE TLV status returned by firmware to allow drivers to dump that
for debug purposes.

Change-ID: Ie3c4cf8cebabee4f15e1e3fdc4fc8a68bbca40ee
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c    | 4 ++++
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 1 +
 3 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 2547aa2..90de46a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -588,6 +588,8 @@ i40e_status i40e_get_dcb_config(struct i40e_hw *hw)
 		if (!ret) {
 			/* CEE mode */
 			hw->local_dcbx_config.dcbx_mode = I40E_DCBX_MODE_CEE;
+			hw->local_dcbx_config.tlv_status =
+					le16_to_cpu(cee_v1_cfg.tlv_status);
 			i40e_cee_to_dcb_v1_config(&cee_v1_cfg,
 						  &hw->local_dcbx_config);
 		}
@@ -597,6 +599,8 @@ i40e_status i40e_get_dcb_config(struct i40e_hw *hw)
 		if (!ret) {
 			/* CEE mode */
 			hw->local_dcbx_config.dcbx_mode = I40E_DCBX_MODE_CEE;
+			hw->local_dcbx_config.tlv_status =
+					le32_to_cpu(cee_cfg.tlv_status);
 			i40e_cee_to_dcb_config(&cee_cfg,
 					       &hw->local_dcbx_config);
 		}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index acb2aad..4842239 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -440,6 +440,7 @@ struct i40e_dcbx_config {
 #define I40E_DCBX_MODE_CEE	0x1
 #define I40E_DCBX_MODE_IEEE	0x2
 	u32 numapps;
+	u32 tlv_status; /* CEE mode TLV status */
 	struct i40e_dcb_ets_config etscfg;
 	struct i40e_dcb_ets_config etsrec;
 	struct i40e_dcb_pfc_config pfc;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 1ab2498..24a2693 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -434,6 +434,7 @@ struct i40e_ieee_app_priority_table {
 
 struct i40e_dcbx_config {
 	u32 numapps;
+	u32 tlv_status; /* CEE mode TLV status */
 	struct i40e_ieee_ets_config etscfg;
 	struct i40e_ieee_ets_recommend etsrec;
 	struct i40e_ieee_pfc_config pfc;
-- 
2.4.3
