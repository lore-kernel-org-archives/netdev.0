From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/17] ixgbe: Set lan_id before first I2C eeprom access
Date: Tue, 22 Sep 2015 16:54:35 -0700
Message-ID: <1442966076-14359-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54666 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935078AbbIVXyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:45 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The lan_id is being set after a previous I2C eeprom access which
makes no sense because it needs to be set before any access. Move
the setting to before the access.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 0856d0b..2b238ca 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1171,6 +1171,9 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 		return IXGBE_ERR_SFP_NOT_PRESENT;
 	}
 
+	/* LAN ID is needed for sfp_type determination */
+	hw->mac.ops.set_lan_id(hw);
+
 	status = hw->phy.ops.read_i2c_eeprom(hw,
 					     IXGBE_SFF_IDENTIFIER,
 					     &identifier);
@@ -1178,9 +1181,6 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 	if (status)
 		goto err_read_i2c_eeprom;
 
-	/* LAN ID is needed for sfp_type determination */
-	hw->mac.ops.set_lan_id(hw);
-
 	if (identifier != IXGBE_SFF_IDENTIFIER_SFP) {
 		hw->phy.type = ixgbe_phy_sfp_unsupported;
 		return IXGBE_ERR_SFP_NOT_SUPPORTED;
-- 
2.4.3
