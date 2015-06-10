From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/18] ixgbe: fix X550 default set_phy_power method
Date: Tue,  9 Jun 2015 18:10:28 -0700
Message-ID: <1433898629-76729-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56324 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933188AbbFJBKx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:53 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Even though X550 may later clear this value for certain devices
set it initially to support copper.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index d65327e..bb1439c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  *  Intel 10 Gigabit PCI Express Linux driver
- *  Copyright(c) 1999 - 2014 Intel Corporation.
+ *  Copyright(c) 1999 - 2015 Intel Corporation.
  *
  *  This program is free software; you can redistribute it and/or modify it
  *  under the terms and conditions of the GNU General Public License,
@@ -1855,6 +1855,7 @@ static struct ixgbe_eeprom_operations eeprom_ops_X550EM_x = {
 	.read_reg		= &ixgbe_read_phy_reg_generic, \
 	.write_reg		= &ixgbe_write_phy_reg_generic, \
 	.setup_link		= &ixgbe_setup_phy_link_generic, \
+	.set_phy_power		= &ixgbe_set_copper_phy_power, \
 	.check_overtemp		= &ixgbe_tn_check_overtemp, \
 	.get_firmware_version	= &ixgbe_get_phy_firmware_version_generic,
 
@@ -1864,7 +1865,6 @@ static struct ixgbe_phy_operations phy_ops_X550 = {
 	.identify		= &ixgbe_identify_phy_generic,
 	.read_i2c_combined	= &ixgbe_read_i2c_combined_generic,
 	.write_i2c_combined	= &ixgbe_write_i2c_combined_generic,
-	.set_phy_power		= &ixgbe_set_copper_phy_power,
 };
 
 static struct ixgbe_phy_operations phy_ops_X550EM_x = {
-- 
2.4.2
