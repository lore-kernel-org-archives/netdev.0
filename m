From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] atl1c: remove private #define.
Date: Thu, 20 Jan 2011 15:59:06 +0100
Message-ID: <20110120145906.GA7291@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35506 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755867Ab1ATPAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 10:00:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Either unused or duplicates from mii.h.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
Cc: Jie Yang <jie.yang@atheros.com>
---
 drivers/net/atl1c/atl1c_hw.c |   15 ++++++-------
 drivers/net/atl1c/atl1c_hw.h |   43 +----------------------------------------
 2 files changed, 9 insertions(+), 49 deletions(-)

diff --git a/drivers/net/atl1c/atl1c_hw.c b/drivers/net/atl1c/atl1c_hw.c
index 1bf6720..23f2ab0 100644
--- a/drivers/net/atl1c/atl1c_hw.c
+++ b/drivers/net/atl1c/atl1c_hw.c
@@ -345,7 +345,7 @@ int atl1c_write_phy_reg(struct atl1c_hw *hw, u32 reg_addr, u16 phy_data)
  */
 static int atl1c_phy_setup_adv(struct atl1c_hw *hw)
 {
-	u16 mii_adv_data = ADVERTISE_DEFAULT_CAP & ~ADVERTISE_SPEED_MASK;
+	u16 mii_adv_data = ADVERTISE_DEFAULT_CAP & ~ADVERTISE_ALL;
 	u16 mii_giga_ctrl_data = GIGA_CR_1000T_DEFAULT_CAP &
 				~GIGA_CR_1000T_SPEED_MASK;
 
@@ -373,7 +373,7 @@ static int atl1c_phy_setup_adv(struct atl1c_hw *hw)
 	}
 
 	if (atl1c_write_phy_reg(hw, MII_ADVERTISE, mii_adv_data) != 0 ||
-	    atl1c_write_phy_reg(hw, MII_GIGA_CR, mii_giga_ctrl_data) != 0)
+	    atl1c_write_phy_reg(hw, MII_CTRL1000, mii_giga_ctrl_data) != 0)
 		return -1;
 	return 0;
 }
@@ -517,19 +517,18 @@ int atl1c_phy_init(struct atl1c_hw *hw)
 					"Error Setting up Auto-Negotiation\n");
 			return ret_val;
 		}
-		mii_bmcr_data |= BMCR_AUTO_NEG_EN | BMCR_RESTART_AUTO_NEG;
+		mii_bmcr_data |= BMCR_ANENABLE | BMCR_ANRESTART;
 		break;
 	case MEDIA_TYPE_100M_FULL:
-		mii_bmcr_data |= BMCR_SPEED_100 | BMCR_FULL_DUPLEX;
+		mii_bmcr_data |= BMCR_SPEED100 | BMCR_FULLDPLX;
 		break;
 	case MEDIA_TYPE_100M_HALF:
-		mii_bmcr_data |= BMCR_SPEED_100;
+		mii_bmcr_data |= BMCR_SPEED100;
 		break;
 	case MEDIA_TYPE_10M_FULL:
-		mii_bmcr_data |= BMCR_SPEED_10 | BMCR_FULL_DUPLEX;
+		mii_bmcr_data |= BMCR_FULLDPLX;
 		break;
 	case MEDIA_TYPE_10M_HALF:
-		mii_bmcr_data |= BMCR_SPEED_10;
 		break;
 	default:
 		if (netif_msg_link(adapter))
@@ -657,7 +656,7 @@ int atl1c_restart_autoneg(struct atl1c_hw *hw)
 	err = atl1c_phy_setup_adv(hw);
 	if (err)
 		return err;
-	mii_bmcr_data |= BMCR_AUTO_NEG_EN | BMCR_RESTART_AUTO_NEG;
+	mii_bmcr_data |= BMCR_ANENABLE | BMCR_ANRESTART;
 
 	return atl1c_write_phy_reg(hw, MII_BMCR, mii_bmcr_data);
 }
diff --git a/drivers/net/atl1c/atl1c_hw.h b/drivers/net/atl1c/atl1c_hw.h
index 3dd6759..655fc6c 100644
--- a/drivers/net/atl1c/atl1c_hw.h
+++ b/drivers/net/atl1c/atl1c_hw.h
@@ -736,55 +736,16 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define REG_DEBUG_DATA0 		0x1900
 #define REG_DEBUG_DATA1 		0x1904
 
-/* PHY Control Register */
-#define MII_BMCR			0x00
-#define BMCR_SPEED_SELECT_MSB		0x0040  /* bits 6,13: 10=1000, 01=100, 00=10 */
-#define BMCR_COLL_TEST_ENABLE		0x0080  /* Collision test enable */
-#define BMCR_FULL_DUPLEX		0x0100  /* FDX =1, half duplex =0 */
-#define BMCR_RESTART_AUTO_NEG		0x0200  /* Restart auto negotiation */
-#define BMCR_ISOLATE			0x0400  /* Isolate PHY from MII */
-#define BMCR_POWER_DOWN			0x0800  /* Power down */
-#define BMCR_AUTO_NEG_EN		0x1000  /* Auto Neg Enable */
-#define BMCR_SPEED_SELECT_LSB		0x2000  /* bits 6,13: 10=1000, 01=100, 00=10 */
-#define BMCR_LOOPBACK			0x4000  /* 0 = normal, 1 = loopback */
-#define BMCR_RESET			0x8000  /* 0 = normal, 1 = PHY reset */
-#define BMCR_SPEED_MASK			0x2040
-#define BMCR_SPEED_1000			0x0040
-#define BMCR_SPEED_100			0x2000
-#define BMCR_SPEED_10			0x0000
-
-/* PHY Status Register */
-#define MII_BMSR			0x01
-#define BMMSR_EXTENDED_CAPS		0x0001  /* Extended register capabilities */
-#define BMSR_JABBER_DETECT		0x0002  /* Jabber Detected */
-#define BMSR_LINK_STATUS		0x0004  /* Link Status 1 = link */
-#define BMSR_AUTONEG_CAPS		0x0008  /* Auto Neg Capable */
-#define BMSR_REMOTE_FAULT		0x0010  /* Remote Fault Detect */
-#define BMSR_AUTONEG_COMPLETE		0x0020  /* Auto Neg Complete */
-#define BMSR_PREAMBLE_SUPPRESS		0x0040  /* Preamble may be suppressed */
-#define BMSR_EXTENDED_STATUS		0x0100  /* Ext. status info in Reg 0x0F */
-#define BMSR_100T2_HD_CAPS		0x0200  /* 100T2 Half Duplex Capable */
-#define BMSR_100T2_FD_CAPS		0x0400  /* 100T2 Full Duplex Capable */
-#define BMSR_10T_HD_CAPS		0x0800  /* 10T   Half Duplex Capable */
-#define BMSR_10T_FD_CAPS		0x1000  /* 10T   Full Duplex Capable */
-#define BMSR_100X_HD_CAPS		0x2000  /* 100X  Half Duplex Capable */
-#define BMMII_SR_100X_FD_CAPS		0x4000  /* 100X  Full Duplex Capable */
-#define BMMII_SR_100T4_CAPS		0x8000  /* 100T4 Capable */
-
-#define MII_PHYSID1			0x02
-#define MII_PHYSID2			0x03
 #define L1D_MPW_PHYID1			0xD01C  /* V7 */
 #define L1D_MPW_PHYID2			0xD01D  /* V1-V6 */
 #define L1D_MPW_PHYID3			0xD01E  /* V8 */
 
 
 /* Autoneg Advertisement Register */
-#define MII_ADVERTISE			0x04
-#define ADVERTISE_SPEED_MASK		0x01E0
-#define ADVERTISE_DEFAULT_CAP		0x0DE0
+#define ADVERTISE_DEFAULT_CAP \
+	(ADVERTISE_ALL | ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM)
 
 /* 1000BASE-T Control Register */
-#define MII_GIGA_CR			0x09
 #define GIGA_CR_1000T_REPEATER_DTE	0x0400  /* 1=Repeater/switch device port 0=DTE device */
 
 #define GIGA_CR_1000T_MS_VALUE		0x0800  /* 1=Configure PHY as Master 0=Configure PHY as Slave */
-- 
1.7.3.4

