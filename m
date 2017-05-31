From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] ixgbe: correct CS4223/7 PHY identification
Date: Wed, 31 May 2017 14:19:32 -0700
Message-ID: <20170531211936.63417-12-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:17444 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751201AbdEaVTx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:53 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Previous method was unreliable. Use a different register to
differentiate between the SKUs.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h  | 5 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 8 ++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
index 5aa2c3cf7aec..b0cac961df3b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
@@ -84,8 +84,9 @@
 #define IXGBE_CS4227_GLOBAL_ID_LSB		0
 #define IXGBE_CS4227_GLOBAL_ID_MSB		1
 #define IXGBE_CS4227_SCRATCH			2
-#define IXGBE_CS4223_PHY_ID			0x7003	/* Quad port */
-#define IXGBE_CS4227_PHY_ID			0x3003	/* Dual port */
+#define IXGBE_CS4227_EFUSE_PDF_SKU		0x19F
+#define IXGBE_CS4223_SKU_ID			0x0010  /* Quad port */
+#define IXGBE_CS4227_SKU_ID			0x0014  /* Dual port */
 #define IXGBE_CS4227_RESET_PENDING		0x1357
 #define IXGBE_CS4227_RESET_COMPLETE		0x5AA5
 #define IXGBE_CS4227_RETRIES			15
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 50aaa2bd3c81..32b35efde2df 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1807,16 +1807,16 @@ ixgbe_setup_mac_link_sfp_x550a(struct ixgbe_hw *hw, ixgbe_link_speed speed,
 	if (hw->phy.mdio.prtad == MDIO_PRTAD_NONE)
 		return IXGBE_ERR_PHY_ADDR_INVALID;
 
-	/* Get external PHY device id */
-	ret_val = hw->phy.ops.read_reg(hw, IXGBE_CS4227_GLOBAL_ID_MSB,
-				  IXGBE_MDIO_ZERO_DEV_TYPE, &reg_phy_ext);
+	/* Get external PHY SKU id */
+	ret_val = hw->phy.ops.read_reg(hw, IXGBE_CS4227_EFUSE_PDF_SKU,
+				       IXGBE_MDIO_ZERO_DEV_TYPE, &reg_phy_ext);
 	if (ret_val)
 		return ret_val;
 
 	/* When configuring quad port CS4223, the MAC instance is part
 	 * of the slice offset.
 	 */
-	if (reg_phy_ext == IXGBE_CS4223_PHY_ID)
+	if (reg_phy_ext == IXGBE_CS4223_SKU_ID)
 		slice_offset = (hw->bus.lan_id +
 				(hw->bus.instance_id << 1)) << 12;
 	else
-- 
2.12.2
