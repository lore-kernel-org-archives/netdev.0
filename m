From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] e1000e: cleanup: remove unnecessary assignments just before returning
Date: Mon, 13 Feb 2012 13:47:40 -0800
Message-ID: <1329169670-5403-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3407 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754677Ab2BMVr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:47:56 -0500
In-Reply-To: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Just return the appropriate value.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |   10 +++-------
 drivers/net/ethernet/intel/e1000e/82571.c       |    4 +---
 drivers/net/ethernet/intel/e1000e/mac.c         |    6 ++----
 drivers/net/ethernet/intel/e1000e/phy.c         |    3 +--
 4 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index 99eb090..05a79cb 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -470,9 +470,8 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 		ret_val = e1000e_read_phy_reg_mdic(hw, page_select, &temp);
 
 		if (((u16)offset >> GG82563_PAGE_SHIFT) != temp) {
-			ret_val = -E1000_ERR_PHY;
 			e1000_release_phy_80003es2lan(hw);
-			return ret_val;
+			return -E1000_ERR_PHY;
 		}
 
 		udelay(200);
@@ -804,9 +803,7 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 	ew32(IMC, 0xffffffff);
 	er32(ICR);
 
-	ret_val = e1000_check_alt_mac_addr_generic(hw);
-
-	return ret_val;
+	return e1000_check_alt_mac_addr_generic(hw);
 }
 
 /**
@@ -1265,9 +1262,8 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 	} while ((reg_data != reg_data2) && (i < GG82563_MAX_KMRN_RETRY));
 
 	reg_data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
-	ret_val = e1e_wphy(hw, GG82563_PHY_KMRN_MODE_CTRL, reg_data);
 
-	return ret_val;
+	return e1e_wphy(hw, GG82563_PHY_KMRN_MODE_CTRL, reg_data);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 795c3d6..024ac24 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1497,9 +1497,7 @@ static s32 e1000_setup_copper_link_82571(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	ret_val = e1000e_setup_copper_link(hw);
-
-	return ret_val;
+	return e1000e_setup_copper_link(hw);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index 83f9368..ce8a55a 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -458,10 +458,8 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 	 * If we are forcing speed/duplex, then we simply return since
 	 * we have already determined whether we have link or not.
 	 */
-	if (!mac->autoneg) {
-		ret_val = -E1000_ERR_CONFIG;
-		return ret_val;
-	}
+	if (!mac->autoneg)
+		return -E1000_ERR_CONFIG;
 
 	/*
 	 * Auto-Neg is enabled.  Auto Speed Detection takes care
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 70e8eb6..323cb14 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -1064,8 +1064,7 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 		break;
 	default:
 		e_dbg("Flow control param set incorrectly\n");
-		ret_val = -E1000_ERR_CONFIG;
-		return ret_val;
+		return -E1000_ERR_CONFIG;
 	}
 
 	ret_val = e1e_wphy(hw, PHY_AUTONEG_ADV, mii_autoneg_adv_reg);
-- 
1.7.7.6
