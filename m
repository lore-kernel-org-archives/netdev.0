From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] e1000: convert mdelay to msleep
Date: Fri,  7 Oct 2011 00:18:36 -0700
Message-ID: <1317971926-23145-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34220 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758795Ab1JGHSu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 03:18:50 -0400
In-Reply-To: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

With the previous commit, there are several functions
that are only ever called from thread context, and are
able to sleep with msleep instead of mdelay.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Tushar Dave <tushar.n.dave@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c   |   22 +++++++++++-----------
 drivers/net/ethernet/intel/e1000/e1000_main.c |    2 +-
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index a5a89ec..36ee76b 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -5385,7 +5385,7 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 			if (ret_val)
 				return ret_val;
 
-			mdelay(20);
+			msleep(20);
 
 			ret_val = e1000_write_phy_reg(hw, 0x0000,
 						      IGP01E1000_IEEE_FORCE_GIGA);
@@ -5413,7 +5413,7 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 			if (ret_val)
 				return ret_val;
 
-			mdelay(20);
+			msleep(20);
 
 			/* Now enable the transmitter */
 			ret_val =
@@ -5440,7 +5440,7 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 			if (ret_val)
 				return ret_val;
 
-			mdelay(20);
+			msleep(20);
 
 			ret_val = e1000_write_phy_reg(hw, 0x0000,
 						      IGP01E1000_IEEE_FORCE_GIGA);
@@ -5457,7 +5457,7 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 			if (ret_val)
 				return ret_val;
 
-			mdelay(20);
+			msleep(20);
 
 			/* Now enable the transmitter */
 			ret_val =
@@ -5750,26 +5750,26 @@ static s32 e1000_polarity_reversal_workaround(struct e1000_hw *hw)
 
 		if ((mii_status_reg & ~MII_SR_LINK_STATUS) == 0)
 			break;
-		mdelay(100);
+		msleep(100);
 	}
 
 	/* Recommended delay time after link has been lost */
-	mdelay(1000);
+	msleep(1000);
 
 	/* Now we will re-enable th transmitter on the PHY */
 
 	ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT, 0x0019);
 	if (ret_val)
 		return ret_val;
-	mdelay(50);
+	msleep(50);
 	ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xFFF0);
 	if (ret_val)
 		return ret_val;
-	mdelay(50);
+	msleep(50);
 	ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xFF00);
 	if (ret_val)
 		return ret_val;
-	mdelay(50);
+	msleep(50);
 	ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0x0000);
 	if (ret_val)
 		return ret_val;
@@ -5794,7 +5794,7 @@ static s32 e1000_polarity_reversal_workaround(struct e1000_hw *hw)
 
 		if (mii_status_reg & MII_SR_LINK_STATUS)
 			break;
-		mdelay(100);
+		msleep(100);
 	}
 	return E1000_SUCCESS;
 }
@@ -5825,6 +5825,6 @@ static s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw)
 {
 	e_dbg("e1000_get_phy_cfg_done");
-	mdelay(10);
+	msleep(10);
 	return E1000_SUCCESS;
 }
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index a0c5ea0..6d03d76 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -485,7 +485,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 		e1000_read_phy_reg(hw, PHY_CTRL, &mii_reg);
 		mii_reg |= MII_CR_POWER_DOWN;
 		e1000_write_phy_reg(hw, PHY_CTRL, mii_reg);
-		mdelay(1);
+		msleep(1);
 	}
 out:
 	return;
-- 
1.7.6.4
