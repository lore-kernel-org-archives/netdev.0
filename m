From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] ixgbe: cleanup error checking in ixgbe_identify_sfp_module_generic()
Date: Sat, 16 Feb 2013 00:33:33 -0800
Message-ID: <1361003616-3422-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2804 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491Ab3BPIds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:33:48 -0500
In-Reply-To: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch replaces instances where a return code from i2c operations
were checked against a list of error codes with a much simpler
if ( status != 0 ) check.

Some whitespace cleanups included.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 34 ++++++++--------------------
 1 file changed, 10 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index d7b5bd0..060d2ad 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -852,11 +852,9 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 
 	status = hw->phy.ops.read_i2c_eeprom(hw,
 					     IXGBE_SFF_IDENTIFIER,
-	                                     &identifier);
+					     &identifier);
 
-	if (status == IXGBE_ERR_SWFW_SYNC ||
-	    status == IXGBE_ERR_I2C ||
-	    status == IXGBE_ERR_SFP_NOT_PRESENT)
+	if (status != 0)
 		goto err_read_i2c_eeprom;
 
 	/* LAN ID is needed for sfp_type determination */
@@ -870,26 +868,20 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 						     IXGBE_SFF_1GBE_COMP_CODES,
 						     &comp_codes_1g);
 
-		if (status == IXGBE_ERR_SWFW_SYNC ||
-		    status == IXGBE_ERR_I2C ||
-		    status == IXGBE_ERR_SFP_NOT_PRESENT)
+		if (status != 0)
 			goto err_read_i2c_eeprom;
 
 		status = hw->phy.ops.read_i2c_eeprom(hw,
 						     IXGBE_SFF_10GBE_COMP_CODES,
 						     &comp_codes_10g);
 
-		if (status == IXGBE_ERR_SWFW_SYNC ||
-		    status == IXGBE_ERR_I2C ||
-		    status == IXGBE_ERR_SFP_NOT_PRESENT)
+		if (status != 0)
 			goto err_read_i2c_eeprom;
 		status = hw->phy.ops.read_i2c_eeprom(hw,
 						     IXGBE_SFF_CABLE_TECHNOLOGY,
 						     &cable_tech);
 
-		if (status == IXGBE_ERR_SWFW_SYNC ||
-		    status == IXGBE_ERR_I2C ||
-		    status == IXGBE_ERR_SFP_NOT_PRESENT)
+		if (status != 0)
 			goto err_read_i2c_eeprom;
 
 		 /* ID Module
@@ -984,30 +976,24 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 		if (hw->phy.type != ixgbe_phy_nl) {
 			hw->phy.id = identifier;
 			status = hw->phy.ops.read_i2c_eeprom(hw,
-			                            IXGBE_SFF_VENDOR_OUI_BYTE0,
-			                            &oui_bytes[0]);
+						    IXGBE_SFF_VENDOR_OUI_BYTE0,
+						    &oui_bytes[0]);
 
-			if (status == IXGBE_ERR_SWFW_SYNC ||
-			    status == IXGBE_ERR_I2C ||
-			    status == IXGBE_ERR_SFP_NOT_PRESENT)
+			if (status != 0)
 				goto err_read_i2c_eeprom;
 
 			status = hw->phy.ops.read_i2c_eeprom(hw,
 			                            IXGBE_SFF_VENDOR_OUI_BYTE1,
 			                            &oui_bytes[1]);
 
-			if (status == IXGBE_ERR_SWFW_SYNC ||
-			    status == IXGBE_ERR_I2C ||
-			    status == IXGBE_ERR_SFP_NOT_PRESENT)
+			if (status != 0)
 				goto err_read_i2c_eeprom;
 
 			status = hw->phy.ops.read_i2c_eeprom(hw,
 			                            IXGBE_SFF_VENDOR_OUI_BYTE2,
 			                            &oui_bytes[2]);
 
-			if (status == IXGBE_ERR_SWFW_SYNC ||
-			    status == IXGBE_ERR_I2C ||
-			    status == IXGBE_ERR_SFP_NOT_PRESENT)
+			if (status != 0)
 				goto err_read_i2c_eeprom;
 
 			vendor_oui =
-- 
1.7.11.7
