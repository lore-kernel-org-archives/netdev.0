From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 6/11] ixgb: Fix EEPROM functions to
 be endian-aware
Date: Thu, 28 Apr 2005 19:03:32 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281856440.28003-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix EEPROM functions to be endian-aware

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ee.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ee.c	2005-04-05 23:06:36.331229608 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.c	2005-04-05 23:06:37.998976072 -0700
@@ -411,7 +411,7 @@ ixgb_write_eeprom(struct ixgb_hw *hw, ui
 	ixgb_cleanup_eeprom(hw);
 
 	/* clear the init_ctrl_reg_1 to signify that the cache is invalidated */
-	ee_map->init_ctrl_reg_1 = EEPROM_ICW1_SIGNATURE_CLEAR;
+	ee_map->init_ctrl_reg_1 = le16_to_cpu(EEPROM_ICW1_SIGNATURE_CLEAR);
 
 	return;
 }
@@ -483,7 +461,7 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
 		DEBUGOUT("ixgb_ee: Checksum invalid.\n");
 		/* clear the init_ctrl_reg_1 to signify that the cache is
 		 * invalidated */
-		ee_map->init_ctrl_reg_1 = EEPROM_ICW1_SIGNATURE_CLEAR;
+		ee_map->init_ctrl_reg_1 = le16_to_cpu(EEPROM_ICW1_SIGNATURE_CLEAR);
 		return (FALSE);
 	}
 
@@ -579,7 +568,7 @@ ixgb_get_ee_compatibility(struct ixgb_hw
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return(ee_map->compatibility);
+		return (le16_to_cpu(ee_map->compatibility));
 
 	return(0);
 }
@@ -616,7 +605,7 @@ ixgb_get_ee_init_ctrl_reg_1(struct ixgb_
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return(ee_map->init_ctrl_reg_1);
+		return (le16_to_cpu(ee_map->init_ctrl_reg_1));
 
 	return(0);
 }
@@ -635,7 +624,7 @@ ixgb_get_ee_init_ctrl_reg_2(struct ixgb_
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return(ee_map->init_ctrl_reg_2);
+		return (le16_to_cpu(ee_map->init_ctrl_reg_2));
 
 	return(0);
 }
@@ -654,7 +643,7 @@ ixgb_get_ee_subsystem_id(struct ixgb_hw 
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
-	   return(ee_map->subsystem_id);
+		return (le16_to_cpu(ee_map->subsystem_id));
 
 	return(0);
 }
@@ -673,7 +662,7 @@ ixgb_get_ee_subvendor_id(struct ixgb_hw 
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return(ee_map->subvendor_id);
+		return (le16_to_cpu(ee_map->subvendor_id));
 
 	return(0);
 }
@@ -692,7 +681,7 @@ ixgb_get_ee_device_id(struct ixgb_hw *hw
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return(ee_map->device_id);
+		return (le16_to_cpu(ee_map->device_id));
 
 	return(0);
 }
@@ -711,7 +700,7 @@ ixgb_get_ee_vendor_id(struct ixgb_hw *hw
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return(ee_map->vendor_id);
+		return (le16_to_cpu(ee_map->vendor_id));
 
 	return(0);
 }
@@ -730,7 +719,7 @@ ixgb_get_ee_swdpins_reg(struct ixgb_hw *
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return(ee_map->swdpins_reg);
+		return (le16_to_cpu(ee_map->swdpins_reg));
 
 	return(0);
 }
@@ -749,7 +738,7 @@ ixgb_get_ee_d3_power(struct ixgb_hw *hw)
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return(ee_map->d3_power);
+		return (le16_to_cpu(ee_map->d3_power));
 
 	return(0);
 }
@@ -768,7 +757,7 @@ ixgb_get_ee_d0_power(struct ixgb_hw *hw)
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return(ee_map->d0_power);
+		return (le16_to_cpu(ee_map->d0_power));
 
 	return(0);
 }
