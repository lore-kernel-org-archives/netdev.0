From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/7] ixgbe: fix incorrect PHY register reads
Date: Mon,  2 Jan 2012 17:50:47 -0800
Message-ID: <1325555451-4697-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1325555451-4697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18965 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751156Ab2ACBuz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jan 2012 20:50:55 -0500
In-Reply-To: <1325555451-4697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Fix some register reads that had the opcode and register parameters swapped.
Also use define instead of a magic (0x3) number.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index bdf535a..a3aa633 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -266,10 +266,10 @@ s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw)
 	if (hw->mac.type == ixgbe_mac_X540) {
 		if (hw->phy.id == 0)
 			hw->phy.ops.identify(hw);
-		hw->phy.ops.read_reg(hw, 0x3, IXGBE_PCRC8ECL, &i);
-		hw->phy.ops.read_reg(hw, 0x3, IXGBE_PCRC8ECH, &i);
-		hw->phy.ops.read_reg(hw, 0x3, IXGBE_LDPCECL, &i);
-		hw->phy.ops.read_reg(hw, 0x3, IXGBE_LDPCECH, &i);
+		hw->phy.ops.read_reg(hw, IXGBE_PCRC8ECL, MDIO_MMD_PCS, &i);
+		hw->phy.ops.read_reg(hw, IXGBE_PCRC8ECH, MDIO_MMD_PCS, &i);
+		hw->phy.ops.read_reg(hw, IXGBE_LDPCECL, MDIO_MMD_PCS, &i);
+		hw->phy.ops.read_reg(hw, IXGBE_LDPCECH, MDIO_MMD_PCS, &i);
 	}
 
 	return 0;
-- 
1.7.7.4
