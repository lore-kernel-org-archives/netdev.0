From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/7] sky2: dont set bogus bit in PHY register
Date: Thu, 24 May 2007 15:22:43 -0700
Message-ID: <20070524222538.375321658@linux-foundation.org>
References: <20070524222242.555399884@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:42731 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752790AbXEXWbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 18:31:00 -0400
Content-Disposition: inline; filename=sky2-gphy-ctrl.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This code inherited from the sk98lin driver is incorrect on the Yukon2.
The GPHY_CTRL register values are specific to the internal PHY of the chip
and the values used were leftovers.
Driver was setting bit 13 which is now the INT polarity for the PHY!

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-05-23 08:44:09.000000000 -0700
+++ b/drivers/net/sky2.c	2007-05-23 08:47:11.000000000 -0700
@@ -658,7 +658,7 @@ static void sky2_mac_init(struct sky2_hw
 	const u8 *addr = hw->dev[port]->dev_addr;
 
 	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
-	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR|GPC_ENA_PAUSE);
+	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
 
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
 
--- a/drivers/net/sky2.h	2007-05-23 08:44:09.000000000 -0700
+++ b/drivers/net/sky2.h	2007-05-23 08:47:11.000000000 -0700
@@ -1732,28 +1732,6 @@ enum {
 
 /*	GPHY_CTRL		32 bit	GPHY Control Reg (YUKON only) */
 enum {
-	GPC_SEL_BDT	= 1<<28, /* Select Bi-Dir. Transfer for MDC/MDIO */
-	GPC_INT_POL_HI	= 1<<27, /* IRQ Polarity is Active HIGH */
-	GPC_75_OHM	= 1<<26, /* Use 75 Ohm Termination instead of 50 */
-	GPC_DIS_FC	= 1<<25, /* Disable Automatic Fiber/Copper Detection */
-	GPC_DIS_SLEEP	= 1<<24, /* Disable Energy Detect */
-	GPC_HWCFG_M_3	= 1<<23, /* HWCFG_MODE[3] */
-	GPC_HWCFG_M_2	= 1<<22, /* HWCFG_MODE[2] */
-	GPC_HWCFG_M_1	= 1<<21, /* HWCFG_MODE[1] */
-	GPC_HWCFG_M_0	= 1<<20, /* HWCFG_MODE[0] */
-	GPC_ANEG_0	= 1<<19, /* ANEG[0] */
-	GPC_ENA_XC	= 1<<18, /* Enable MDI crossover */
-	GPC_DIS_125	= 1<<17, /* Disable 125 MHz clock */
-	GPC_ANEG_3	= 1<<16, /* ANEG[3] */
-	GPC_ANEG_2	= 1<<15, /* ANEG[2] */
-	GPC_ANEG_1	= 1<<14, /* ANEG[1] */
-	GPC_ENA_PAUSE	= 1<<13, /* Enable Pause (SYM_OR_REM) */
-	GPC_PHYADDR_4	= 1<<12, /* Bit 4 of Phy Addr */
-	GPC_PHYADDR_3	= 1<<11, /* Bit 3 of Phy Addr */
-	GPC_PHYADDR_2	= 1<<10, /* Bit 2 of Phy Addr */
-	GPC_PHYADDR_1	= 1<<9,	 /* Bit 1 of Phy Addr */
-	GPC_PHYADDR_0	= 1<<8,	 /* Bit 0 of Phy Addr */
-						/* Bits  7..2:	reserved */
 	GPC_RST_CLR	= 1<<1,	/* Clear GPHY Reset */
 	GPC_RST_SET	= 1<<0,	/* Set   GPHY Reset */
 };

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

