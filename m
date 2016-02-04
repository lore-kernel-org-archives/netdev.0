From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/20] i40e: Limit DCB FW version checks to X710/XL710 devices
Date: Thu,  4 Feb 2016 03:49:07 -0800
Message-ID: <1454586551-35919-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Bowers <gregory.j.bowers@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43336 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965763AbcBDLtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:19 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Bowers <gregory.j.bowers@intel.com>

X710/XL710 devices require FW version checks to properly handle DCB
configurations from the FW.  Newer devices do not, so limit these checks
to X710/XL710.

Signed-off-by: Greg Bowers <gregory.j.bowers@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 2691277..582daa7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -814,13 +814,15 @@ i40e_status i40e_get_dcb_config(struct i40e_hw *hw)
 	struct i40e_aqc_get_cee_dcb_cfg_resp cee_cfg;
 	struct i40e_aqc_get_cee_dcb_cfg_v1_resp cee_v1_cfg;
 
-	/* If Firmware version < v4.33 IEEE only */
-	if (((hw->aq.fw_maj_ver == 4) && (hw->aq.fw_min_ver < 33)) ||
-	    (hw->aq.fw_maj_ver < 4))
+	/* If Firmware version < v4.33 on X710/XL710, IEEE only */
+	if ((hw->mac.type == I40E_MAC_XL710) &&
+	    (((hw->aq.fw_maj_ver == 4) && (hw->aq.fw_min_ver < 33)) ||
+	      (hw->aq.fw_maj_ver < 4)))
 		return i40e_get_ieee_dcb_config(hw);
 
-	/* If Firmware version == v4.33 use old CEE struct */
-	if ((hw->aq.fw_maj_ver == 4) && (hw->aq.fw_min_ver == 33)) {
+	/* If Firmware version == v4.33 on X710/XL710, use old CEE struct */
+	if ((hw->mac.type == I40E_MAC_XL710) &&
+	    ((hw->aq.fw_maj_ver == 4) && (hw->aq.fw_min_ver == 33))) {
 		ret = i40e_aq_get_cee_dcb_config(hw, &cee_v1_cfg,
 						 sizeof(cee_v1_cfg), NULL);
 		if (!ret) {
-- 
2.5.0
