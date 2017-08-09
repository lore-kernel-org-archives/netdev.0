From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/12] igb: support BCM54616 PHY
Date: Wed,  9 Aug 2017 14:47:46 -0700
Message-ID: <20170809214746.28139-13-jeffrey.t.kirsher@intel.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Cc: John W Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:44498 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752248AbdHIVr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 17:47:58 -0400
In-Reply-To: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John W Linville <linville@tuxdriver.com>

The management port on an Edgecore AS7712-32 switch uses an igb MAC, but
it uses a BCM54616 PHY. Without a patch like this, loading the igb
module produces dmesg output like this:

[    3.439125] igb: Copyright (c) 2007-2014 Intel Corporation.
[    3.439866] igb: probe of 0000:00:14.0 failed with error -2

Signed-off-by: John W Linville <linville@tuxdriver.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 6 ++++++
 drivers/net/ethernet/intel/igb/e1000_defines.h | 1 +
 drivers/net/ethernet/intel/igb/e1000_hw.h      | 1 +
 3 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 4a50870e0fa7..c37cc8bccf47 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -340,6 +340,9 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
 		phy->ops.set_d3_lplu_state = igb_set_d3_lplu_state_82580;
 		phy->ops.force_speed_duplex = igb_phy_force_speed_duplex_m88;
 		break;
+	case BCM54616_E_PHY_ID:
+		phy->type = e1000_phy_bcm54616;
+		break;
 	default:
 		ret_val = -E1000_ERR_PHY;
 		goto out;
@@ -1659,6 +1662,9 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 	case e1000_phy_82580:
 		ret_val = igb_copper_link_setup_82580(hw);
 		break;
+	case e1000_phy_bcm54616:
+		ret_val = 0;
+		break;
 	default:
 		ret_val = -E1000_ERR_PHY;
 		break;
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index d8517779439b..1de82f247312 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -889,6 +889,7 @@
 #define I210_I_PHY_ID        0x01410C00
 #define M88E1543_E_PHY_ID    0x01410EA0
 #define M88E1512_E_PHY_ID    0x01410DD0
+#define BCM54616_E_PHY_ID    0x03625D10
 
 /* M88E1000 Specific Registers */
 #define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index 6ea9f702ba0f..6c9485ab4b57 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -128,6 +128,7 @@ enum e1000_phy_type {
 	e1000_phy_ife,
 	e1000_phy_82580,
 	e1000_phy_i210,
+	e1000_phy_bcm54616,
 };
 
 enum e1000_bus_type {
-- 
2.13.3
