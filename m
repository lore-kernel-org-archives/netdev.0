From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH v1 net-next 3/3] igb: add PHY support for Broadcom 54616
Date: Fri, 10 Apr 2015 16:03:38 -0700
Message-ID: <1428707018-6405-3-git-send-email-jtoppins@cumulusnetworks.com>
References: <1428707018-6405-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	shm@cumulusnetworks.com, Alan Liebthal <alanl@cumulusnetworks.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36486 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933124AbbDJXDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 19:03:49 -0400
Received: by pabsx10 with SMTP id sx10so35085573pab.3
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 16:03:48 -0700 (PDT)
In-Reply-To: <1428707018-6405-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Liebthal <alanl@cumulusnetworks.com>

The Celestica Redstone-XP Ethernet management port uses a Broadcom 54616
chip for the PHY layer. This adds support for this PHY to the Intel igb
e1000 driver.

Signed-off-by: Alan Liebthal <alanl@cumulusnetworks.com>
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c   |    5 +++++
 drivers/net/ethernet/intel/igb/e1000_defines.h |    1 +
 drivers/net/ethernet/intel/igb/e1000_hw.h      |    1 +
 3 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 0f69ef8..2dcc808 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -286,6 +286,9 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
 		phy->ops.set_d3_lplu_state = igb_set_d3_lplu_state_82580;
 		phy->ops.force_speed_duplex = igb_phy_force_speed_duplex_m88;
 		break;
+	case BCM54616_E_PHY_ID:
+		phy->type = e1000_phy_bcm54616;
+		break;
 	default:
 		ret_val = -E1000_ERR_PHY;
 		goto out;
@@ -1593,6 +1596,8 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 	case e1000_phy_82580:
 		ret_val = igb_copper_link_setup_82580(hw);
 		break;
+	case e1000_phy_bcm54616:
+		break;
 	default:
 		ret_val = -E1000_ERR_PHY;
 		break;
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 217f813..50d51e4 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -860,6 +860,7 @@
 #define M88_VENDOR           0x0141
 #define I210_I_PHY_ID        0x01410C00
 #define M88E1543_E_PHY_ID    0x01410EA0
+#define BCM54616_E_PHY_ID    0x03625D10
 
 /* M88E1000 Specific Registers */
 #define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index 2003b37..d82c96b 100644
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
1.7.10.4
