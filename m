From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] ixgbe: add missing configuration for rate select 1
Date: Wed, 31 May 2017 14:19:35 -0700
Message-ID: <20170531211936.63417-15-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:17444 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750977AbdEaVTz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:55 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Add RS1 configuration to ixgbe_set_soft_rate_select_speed()

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 7af85f505bad..4e35e7017f3d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -4278,4 +4278,23 @@ void ixgbe_set_soft_rate_select_speed(struct ixgbe_hw *hw,
 		hw_dbg(hw, "Failed to write Rx Rate Select RS0\n");
 		return;
 	}
+
+	/* Set RS1 */
+	status = hw->phy.ops.read_i2c_byte(hw, IXGBE_SFF_SFF_8472_ESCB,
+					   IXGBE_I2C_EEPROM_DEV_ADDR2,
+					   &eeprom_data);
+	if (status) {
+		hw_dbg(hw, "Failed to read Rx Rate Select RS1\n");
+		return;
+	}
+
+	eeprom_data = (eeprom_data & ~IXGBE_SFF_SOFT_RS_SELECT_MASK) | rs;
+
+	status = hw->phy.ops.write_i2c_byte(hw, IXGBE_SFF_SFF_8472_ESCB,
+					    IXGBE_I2C_EEPROM_DEV_ADDR2,
+					    eeprom_data);
+	if (status) {
+		hw_dbg(hw, "Failed to write Rx Rate Select RS1\n");
+		return;
+	}
 }
-- 
2.12.2
