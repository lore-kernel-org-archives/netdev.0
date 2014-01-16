From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 6/6] ixgbe: Fix incorrect logic for fixed fiber eeprom write
Date: Thu, 16 Jan 2014 02:30:10 -0800
Message-ID: <1389868210-24035-7-git-send-email-aaron.f.brown@intel.com>
References: <1389868210-24035-1-git-send-email-aaron.f.brown@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22915 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751123AbaAPKaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 05:30:25 -0500
In-Reply-To: <1389868210-24035-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

In this code we wanted to set the bit in IXGBE_SFF_SOFT_RS_SELECT_MASK to
the value in rs.  So we really needed a logical or rather than an and, this
patch makes that change.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 007a008..edda681 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -626,7 +626,7 @@ static void ixgbe_set_fiber_fixed_speed(struct ixgbe_hw *hw,
 		goto out;
 	}
 
-	eeprom_data = (eeprom_data & ~IXGBE_SFF_SOFT_RS_SELECT_MASK) & rs;
+	eeprom_data = (eeprom_data & ~IXGBE_SFF_SOFT_RS_SELECT_MASK) | rs;
 
 	status = hw->phy.ops.write_i2c_byte(hw, IXGBE_SFF_SFF_8472_OSCB,
 					    IXGBE_I2C_EEPROM_DEV_ADDR2,
-- 
1.8.5.GIT
