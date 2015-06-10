From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/18] ixgbe: Set lan_id before using I2C
Date: Tue,  9 Jun 2015 18:10:27 -0700
Message-ID: <1433898629-76729-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10750 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933186AbbFJBKx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:53 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We need to call the set_lan_id before accessing I2C and this wasn't
being done so this patch corrects that.  Likewise we do the same for
QSFP just to be consistent.

In the X550 case this is even more important as with out it the mux
is not controlled properly.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  | 6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 2 ++
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index ac6c0af..526a20b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1352,6 +1352,9 @@ static s32 ixgbe_identify_qsfp_module_generic(struct ixgbe_hw *hw)
 		return IXGBE_ERR_SFP_NOT_PRESENT;
 	}
 
+	/* LAN ID is needed for sfp_type determination */
+	hw->mac.ops.set_lan_id(hw);
+
 	status = hw->phy.ops.read_i2c_eeprom(hw, IXGBE_SFF_IDENTIFIER,
 					     &identifier);
 
@@ -1365,9 +1368,6 @@ static s32 ixgbe_identify_qsfp_module_generic(struct ixgbe_hw *hw)
 
 	hw->phy.id = identifier;
 
-	/* LAN ID is needed for sfp_type determination */
-	hw->mac.ops.set_lan_id(hw);
-
 	status = hw->phy.ops.read_i2c_eeprom(hw, IXGBE_SFF_QSFP_10GBE_COMP,
 					     &comp_codes_10g);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index dc320af..d65327e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1457,6 +1457,8 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 	ixgbe_link_speed speed;
 	s32 ret_val;
 
+	hw->mac.ops.set_lan_id(hw);
+
 	if (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) {
 		phy->phy_semaphore_mask = IXGBE_GSSR_SHARED_I2C_SM;
 		ixgbe_setup_mux_ctl(hw);
-- 
2.4.2
