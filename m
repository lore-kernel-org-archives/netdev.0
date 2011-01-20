From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] atl1e: remove private #define.
Date: Thu, 20 Jan 2011 15:59:23 +0100
Message-ID: <20110120145922.GB7291@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35501 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861Ab1ATPAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 10:00:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Either unused or duplicates from mii.h.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
Cc: Jie Yang <jie.yang@atheros.com>
---
 drivers/net/atl1e/atl1e_ethtool.c |   12 ++--
 drivers/net/atl1e/atl1e_hw.c      |   34 ++++-------
 drivers/net/atl1e/atl1e_hw.h      |  111 +-----------------------------------
 drivers/net/atl1e/atl1e_main.c    |    4 +-
 4 files changed, 25 insertions(+), 136 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1e_ethtool.c
index 6943a6c..1209297 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -95,18 +95,18 @@ static int atl1e_set_settings(struct net_device *netdev,
 		ecmd->advertising = hw->autoneg_advertised |
 				    ADVERTISED_TP | ADVERTISED_Autoneg;
 
-		adv4 = hw->mii_autoneg_adv_reg & ~MII_AR_SPEED_MASK;
+		adv4 = hw->mii_autoneg_adv_reg & ~ADVERTISE_ALL;
 		adv9 = hw->mii_1000t_ctrl_reg & ~MII_AT001_CR_1000T_SPEED_MASK;
 		if (hw->autoneg_advertised & ADVERTISE_10_HALF)
-			adv4 |= MII_AR_10T_HD_CAPS;
+			adv4 |= ADVERTISE_10HALF;
 		if (hw->autoneg_advertised & ADVERTISE_10_FULL)
-			adv4 |= MII_AR_10T_FD_CAPS;
+			adv4 |= ADVERTISE_10FULL;
 		if (hw->autoneg_advertised & ADVERTISE_100_HALF)
-			adv4 |= MII_AR_100TX_HD_CAPS;
+			adv4 |= ADVERTISE_100HALF;
 		if (hw->autoneg_advertised & ADVERTISE_100_FULL)
-			adv4 |= MII_AR_100TX_FD_CAPS;
+			adv4 |= ADVERTISE_100FULL;
 		if (hw->autoneg_advertised & ADVERTISE_1000_FULL)
-			adv9 |= MII_AT001_CR_1000T_FD_CAPS;
+			adv9 |= ADVERTISE_1000FULL;
 
 		if (adv4 != hw->mii_autoneg_adv_reg ||
 				adv9 != hw->mii_1000t_ctrl_reg) {
diff --git a/drivers/net/atl1e/atl1e_hw.c b/drivers/net/atl1e/atl1e_hw.c
index 76cc043..923063d 100644
--- a/drivers/net/atl1e/atl1e_hw.c
+++ b/drivers/net/atl1e/atl1e_hw.c
@@ -318,7 +318,7 @@ static int atl1e_phy_setup_autoneg_adv(struct atl1e_hw *hw)
 	 * Advertisement Register (Address 4) and the 1000 mb speed bits in
 	 * the  1000Base-T control Register (Address 9).
 	 */
-	mii_autoneg_adv_reg &= ~MII_AR_SPEED_MASK;
+	mii_autoneg_adv_reg &= ~ADVERTISE_ALL;
 	mii_1000t_ctrl_reg  &= ~MII_AT001_CR_1000T_SPEED_MASK;
 
 	/*
@@ -327,44 +327,37 @@ static int atl1e_phy_setup_autoneg_adv(struct atl1e_hw *hw)
 	 */
 	switch (hw->media_type) {
 	case MEDIA_TYPE_AUTO_SENSOR:
-		mii_autoneg_adv_reg |= (MII_AR_10T_HD_CAPS   |
-					MII_AR_10T_FD_CAPS   |
-					MII_AR_100TX_HD_CAPS |
-					MII_AR_100TX_FD_CAPS);
-		hw->autoneg_advertised = ADVERTISE_10_HALF  |
-					 ADVERTISE_10_FULL  |
-					 ADVERTISE_100_HALF |
-					 ADVERTISE_100_FULL;
+		mii_autoneg_adv_reg |= ADVERTISE_ALL;
+		hw->autoneg_advertised = ADVERTISE_ALL;
 		if (hw->nic_type == athr_l1e) {
-			mii_1000t_ctrl_reg |=
-				MII_AT001_CR_1000T_FD_CAPS;
+			mii_1000t_ctrl_reg |= ADVERTISE_1000FULL;
 			hw->autoneg_advertised |= ADVERTISE_1000_FULL;
 		}
 		break;
 
 	case MEDIA_TYPE_100M_FULL:
-		mii_autoneg_adv_reg   |= MII_AR_100TX_FD_CAPS;
+		mii_autoneg_adv_reg   |= ADVERTISE_100FULL;
 		hw->autoneg_advertised = ADVERTISE_100_FULL;
 		break;
 
 	case MEDIA_TYPE_100M_HALF:
-		mii_autoneg_adv_reg   |= MII_AR_100TX_HD_CAPS;
+		mii_autoneg_adv_reg   |= ADVERTISE_100_HALF;
 		hw->autoneg_advertised = ADVERTISE_100_HALF;
 		break;
 
 	case MEDIA_TYPE_10M_FULL:
-		mii_autoneg_adv_reg   |= MII_AR_10T_FD_CAPS;
+		mii_autoneg_adv_reg   |= ADVERTISE_10_FULL;
 		hw->autoneg_advertised = ADVERTISE_10_FULL;
 		break;
 
 	default:
-		mii_autoneg_adv_reg   |= MII_AR_10T_HD_CAPS;
+		mii_autoneg_adv_reg   |= ADVERTISE_10_HALF;
 		hw->autoneg_advertised = ADVERTISE_10_HALF;
 		break;
 	}
 
 	/* flow control fixed to enable all */
-	mii_autoneg_adv_reg |= (MII_AR_ASM_DIR | MII_AR_PAUSE);
+	mii_autoneg_adv_reg |= (ADVERTISE_PAUSE_ASYM | ADVERTISE_PAUSE_CAP);
 
 	hw->mii_autoneg_adv_reg = mii_autoneg_adv_reg;
 	hw->mii_1000t_ctrl_reg  = mii_1000t_ctrl_reg;
@@ -374,7 +367,7 @@ static int atl1e_phy_setup_autoneg_adv(struct atl1e_hw *hw)
 		return ret_val;
 
 	if (hw->nic_type == athr_l1e || hw->nic_type == athr_l2e_revA) {
-		ret_val = atl1e_write_phy_reg(hw, MII_AT001_CR,
+		ret_val = atl1e_write_phy_reg(hw, MII_CTRL1000,
 					   mii_1000t_ctrl_reg);
 		if (ret_val)
 			return ret_val;
@@ -397,7 +390,7 @@ int atl1e_phy_commit(struct atl1e_hw *hw)
 	int ret_val;
 	u16 phy_data;
 
-	phy_data = MII_CR_RESET | MII_CR_AUTO_NEG_EN | MII_CR_RESTART_AUTO_NEG;
+	phy_data = BMCR_RESET | BMCR_ANENABLE | BMCR_ANRESTART;
 
 	ret_val = atl1e_write_phy_reg(hw, MII_BMCR, phy_data);
 	if (ret_val) {
@@ -645,15 +638,14 @@ int atl1e_restart_autoneg(struct atl1e_hw *hw)
 		return err;
 
 	if (hw->nic_type == athr_l1e || hw->nic_type == athr_l2e_revA) {
-		err = atl1e_write_phy_reg(hw, MII_AT001_CR,
+		err = atl1e_write_phy_reg(hw, MII_CTRL1000,
 				       hw->mii_1000t_ctrl_reg);
 		if (err)
 			return err;
 	}
 
 	err = atl1e_write_phy_reg(hw, MII_BMCR,
-			MII_CR_RESET | MII_CR_AUTO_NEG_EN |
-			MII_CR_RESTART_AUTO_NEG);
+			BMCR_RESET | BMCR_ANENABLE | BMCR_ANRESTART);
 	return err;
 }
 
diff --git a/drivers/net/atl1e/atl1e_hw.h b/drivers/net/atl1e/atl1e_hw.h
index 5ea2f4d..74df16a 100644
--- a/drivers/net/atl1e/atl1e_hw.h
+++ b/drivers/net/atl1e/atl1e_hw.h
@@ -629,127 +629,24 @@ s32 atl1e_restart_autoneg(struct atl1e_hw *hw);
 
 /***************************** MII definition ***************************************/
 /* PHY Common Register */
-#define MII_BMCR                        0x00
-#define MII_BMSR                        0x01
-#define MII_PHYSID1                     0x02
-#define MII_PHYSID2                     0x03
-#define MII_ADVERTISE                   0x04
-#define MII_LPA                         0x05
-#define MII_EXPANSION                   0x06
-#define MII_AT001_CR                    0x09
-#define MII_AT001_SR                    0x0A
-#define MII_AT001_ESR                   0x0F
 #define MII_AT001_PSCR                  0x10
 #define MII_AT001_PSSR                  0x11
 #define MII_INT_CTRL                    0x12
 #define MII_INT_STATUS                  0x13
 #define MII_SMARTSPEED                  0x14
-#define MII_RERRCOUNTER                 0x15
-#define MII_SREVISION                   0x16
-#define MII_RESV1                       0x17
 #define MII_LBRERROR                    0x18
-#define MII_PHYADDR                     0x19
 #define MII_RESV2                       0x1a
-#define MII_TPISTATUS                   0x1b
-#define MII_NCONFIG                     0x1c
 
 #define MII_DBG_ADDR			0x1D
 #define MII_DBG_DATA			0x1E
 
-
-/* PHY Control Register */
-#define MII_CR_SPEED_SELECT_MSB                  0x0040  /* bits 6,13: 10=1000, 01=100, 00=10 */
-#define MII_CR_COLL_TEST_ENABLE                  0x0080  /* Collision test enable */
-#define MII_CR_FULL_DUPLEX                       0x0100  /* FDX =1, half duplex =0 */
-#define MII_CR_RESTART_AUTO_NEG                  0x0200  /* Restart auto negotiation */
-#define MII_CR_ISOLATE                           0x0400  /* Isolate PHY from MII */
-#define MII_CR_POWER_DOWN                        0x0800  /* Power down */
-#define MII_CR_AUTO_NEG_EN                       0x1000  /* Auto Neg Enable */
-#define MII_CR_SPEED_SELECT_LSB                  0x2000  /* bits 6,13: 10=1000, 01=100, 00=10 */
-#define MII_CR_LOOPBACK                          0x4000  /* 0 = normal, 1 = loopback */
-#define MII_CR_RESET                             0x8000  /* 0 = normal, 1 = PHY reset */
-#define MII_CR_SPEED_MASK                        0x2040
-#define MII_CR_SPEED_1000                        0x0040
-#define MII_CR_SPEED_100                         0x2000
-#define MII_CR_SPEED_10                          0x0000
-
-
-/* PHY Status Register */
-#define MII_SR_EXTENDED_CAPS                     0x0001  /* Extended register capabilities */
-#define MII_SR_JABBER_DETECT                     0x0002  /* Jabber Detected */
-#define MII_SR_LINK_STATUS                       0x0004  /* Link Status 1 = link */
-#define MII_SR_AUTONEG_CAPS                      0x0008  /* Auto Neg Capable */
-#define MII_SR_REMOTE_FAULT                      0x0010  /* Remote Fault Detect */
-#define MII_SR_AUTONEG_COMPLETE                  0x0020  /* Auto Neg Complete */
-#define MII_SR_PREAMBLE_SUPPRESS                 0x0040  /* Preamble may be suppressed */
-#define MII_SR_EXTENDED_STATUS                   0x0100  /* Ext. status info in Reg 0x0F */
-#define MII_SR_100T2_HD_CAPS                     0x0200  /* 100T2 Half Duplex Capable */
-#define MII_SR_100T2_FD_CAPS                     0x0400  /* 100T2 Full Duplex Capable */
-#define MII_SR_10T_HD_CAPS                       0x0800  /* 10T   Half Duplex Capable */
-#define MII_SR_10T_FD_CAPS                       0x1000  /* 10T   Full Duplex Capable */
-#define MII_SR_100X_HD_CAPS                      0x2000  /* 100X  Half Duplex Capable */
-#define MII_SR_100X_FD_CAPS                      0x4000  /* 100X  Full Duplex Capable */
-#define MII_SR_100T4_CAPS                        0x8000  /* 100T4 Capable */
-
-/* Link partner ability register. */
-#define MII_LPA_SLCT                             0x001f  /* Same as advertise selector  */
-#define MII_LPA_10HALF                           0x0020  /* Can do 10mbps half-duplex   */
-#define MII_LPA_10FULL                           0x0040  /* Can do 10mbps full-duplex   */
-#define MII_LPA_100HALF                          0x0080  /* Can do 100mbps half-duplex  */
-#define MII_LPA_100FULL                          0x0100  /* Can do 100mbps full-duplex  */
-#define MII_LPA_100BASE4                         0x0200  /* 100BASE-T4  */
-#define MII_LPA_PAUSE                            0x0400  /* PAUSE */
-#define MII_LPA_ASYPAUSE                         0x0800  /* Asymmetrical PAUSE */
-#define MII_LPA_RFAULT                           0x2000  /* Link partner faulted        */
-#define MII_LPA_LPACK                            0x4000  /* Link partner acked us       */
-#define MII_LPA_NPAGE                            0x8000  /* Next page bit               */
-
 /* Autoneg Advertisement Register */
-#define MII_AR_SELECTOR_FIELD                   0x0001  /* indicates IEEE 802.3 CSMA/CD */
-#define MII_AR_10T_HD_CAPS                      0x0020  /* 10T   Half Duplex Capable */
-#define MII_AR_10T_FD_CAPS                      0x0040  /* 10T   Full Duplex Capable */
-#define MII_AR_100TX_HD_CAPS                    0x0080  /* 100TX Half Duplex Capable */
-#define MII_AR_100TX_FD_CAPS                    0x0100  /* 100TX Full Duplex Capable */
-#define MII_AR_100T4_CAPS                       0x0200  /* 100T4 Capable */
-#define MII_AR_PAUSE                            0x0400  /* Pause operation desired */
-#define MII_AR_ASM_DIR                          0x0800  /* Asymmetric Pause Direction bit */
-#define MII_AR_REMOTE_FAULT                     0x2000  /* Remote Fault detected */
-#define MII_AR_NEXT_PAGE                        0x8000  /* Next Page ability supported */
-#define MII_AR_SPEED_MASK                       0x01E0
-#define MII_AR_DEFAULT_CAP_MASK                 0x0DE0
+#define MII_AR_DEFAULT_CAP_MASK                 0
 
 /* 1000BASE-T Control Register */
-#define MII_AT001_CR_1000T_HD_CAPS              0x0100  /* Advertise 1000T HD capability */
-#define MII_AT001_CR_1000T_FD_CAPS              0x0200  /* Advertise 1000T FD capability  */
-#define MII_AT001_CR_1000T_REPEATER_DTE         0x0400  /* 1=Repeater/switch device port */
-/* 0=DTE device */
-#define MII_AT001_CR_1000T_MS_VALUE             0x0800  /* 1=Configure PHY as Master */
-/* 0=Configure PHY as Slave */
-#define MII_AT001_CR_1000T_MS_ENABLE            0x1000  /* 1=Master/Slave manual config value */
-/* 0=Automatic Master/Slave config */
-#define MII_AT001_CR_1000T_TEST_MODE_NORMAL     0x0000  /* Normal Operation */
-#define MII_AT001_CR_1000T_TEST_MODE_1          0x2000  /* Transmit Waveform test */
-#define MII_AT001_CR_1000T_TEST_MODE_2          0x4000  /* Master Transmit Jitter test */
-#define MII_AT001_CR_1000T_TEST_MODE_3          0x6000  /* Slave Transmit Jitter test */
-#define MII_AT001_CR_1000T_TEST_MODE_4          0x8000  /* Transmitter Distortion test */
-#define MII_AT001_CR_1000T_SPEED_MASK           0x0300
-#define MII_AT001_CR_1000T_DEFAULT_CAP_MASK     0x0300
-
-/* 1000BASE-T Status Register */
-#define MII_AT001_SR_1000T_LP_HD_CAPS           0x0400  /* LP is 1000T HD capable */
-#define MII_AT001_SR_1000T_LP_FD_CAPS           0x0800  /* LP is 1000T FD capable */
-#define MII_AT001_SR_1000T_REMOTE_RX_STATUS     0x1000  /* Remote receiver OK */
-#define MII_AT001_SR_1000T_LOCAL_RX_STATUS      0x2000  /* Local receiver OK */
-#define MII_AT001_SR_1000T_MS_CONFIG_RES        0x4000  /* 1=Local TX is Master, 0=Slave */
-#define MII_AT001_SR_1000T_MS_CONFIG_FAULT      0x8000  /* Master/Slave config fault */
-#define MII_AT001_SR_1000T_REMOTE_RX_STATUS_SHIFT   12
-#define MII_AT001_SR_1000T_LOCAL_RX_STATUS_SHIFT    13
-
-/* Extended Status Register */
-#define MII_AT001_ESR_1000T_HD_CAPS             0x1000  /* 1000T HD capable */
-#define MII_AT001_ESR_1000T_FD_CAPS             0x2000  /* 1000T FD capable */
-#define MII_AT001_ESR_1000X_HD_CAPS             0x4000  /* 1000X HD capable */
-#define MII_AT001_ESR_1000X_FD_CAPS             0x8000  /* 1000X FD capable */
+#define MII_AT001_CR_1000T_SPEED_MASK \
+	(ADVERTISE_1000FULL | ADVERTISE_1000HALF)
+#define MII_AT001_CR_1000T_DEFAULT_CAP_MASK	MII_AT001_CR_1000T_SPEED_MASK
 
 /* AT001 PHY Specific Control Register */
 #define MII_AT001_PSCR_JABBER_DISABLE           0x0001  /* 1=Jabber Function disabled */
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index e28f8ba..bf7500c 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2051,9 +2051,9 @@ static int atl1e_suspend(struct pci_dev *pdev, pm_message_t state)
 		atl1e_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);
 		atl1e_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);
 
-		mii_advertise_data = MII_AR_10T_HD_CAPS;
+		mii_advertise_data = ADVERTISE_10HALF;
 
-		if ((atl1e_write_phy_reg(hw, MII_AT001_CR, 0) != 0) ||
+		if ((atl1e_write_phy_reg(hw, MII_CTRL1000, 0) != 0) ||
 		    (atl1e_write_phy_reg(hw,
 			   MII_ADVERTISE, mii_advertise_data) != 0) ||
 		    (atl1e_phy_commit(hw)) != 0) {
-- 
1.7.3.4

