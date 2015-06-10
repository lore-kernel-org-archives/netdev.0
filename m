From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/18] ixgbe: fix X550 PHY function pointers
Date: Tue,  9 Jun 2015 18:10:24 -0700
Message-ID: <1433898629-76729-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10750 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754149AbbFJBKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:51 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

A subset of the X550 function pointers didn't have default methods. This
didn't cause any issue with previous X550 devices as they were all
redefined.  However future devices will need these default values.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index ef3d686..fee3d07 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1800,6 +1800,9 @@ static struct ixgbe_eeprom_operations eeprom_ops_X550EM_x = {
 	.read_i2c_sff8472	= &ixgbe_read_i2c_sff8472_generic, \
 	.read_i2c_eeprom	= &ixgbe_read_i2c_eeprom_generic, \
 	.write_i2c_eeprom	= &ixgbe_write_i2c_eeprom_generic, \
+	.read_reg		= &ixgbe_read_phy_reg_generic, \
+	.write_reg		= &ixgbe_write_phy_reg_generic, \
+	.setup_link		= &ixgbe_setup_phy_link_generic, \
 	.check_overtemp		= &ixgbe_tn_check_overtemp, \
 	.get_firmware_version	= &ixgbe_get_phy_firmware_version_generic,
 
@@ -1807,9 +1810,6 @@ static struct ixgbe_phy_operations phy_ops_X550 = {
 	X550_COMMON_PHY
 	.init			= NULL,
 	.identify		= &ixgbe_identify_phy_generic,
-	.read_reg		= &ixgbe_read_phy_reg_generic,
-	.write_reg		= &ixgbe_write_phy_reg_generic,
-	.setup_link		= &ixgbe_setup_phy_link_generic,
 	.read_i2c_combined	= &ixgbe_read_i2c_combined_generic,
 	.write_i2c_combined	= &ixgbe_write_i2c_combined_generic,
 	.set_phy_power		= &ixgbe_set_copper_phy_power,
@@ -1819,9 +1819,6 @@ static struct ixgbe_phy_operations phy_ops_X550EM_x = {
 	X550_COMMON_PHY
 	.init			= &ixgbe_init_phy_ops_X550em,
 	.identify		= &ixgbe_identify_phy_x550em,
-	.read_reg		= NULL, /* defined later */
-	.write_reg		= NULL, /* defined later */
-	.setup_link		= NULL, /* defined later */
 };
 
 static const u32 ixgbe_mvals_X550[IXGBE_MVALS_IDX_LIMIT] = {
-- 
2.4.2
