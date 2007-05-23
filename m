From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 hangs without any messages
Date: Wed, 23 May 2007 08:49:22 -0700
Message-ID: <20070523084922.04dedd08@freepuppy>
References: <20070523075431.GA15935@dose.home.local>
	<20070523075026.3f78e306@freepuppy>
	<20070523150118.GA25026@dose.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tino Keitel <tino.keitel@tikei.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:40661 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756727AbXEWPt3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 11:49:29 -0400
In-Reply-To: <20070523150118.GA25026@dose.home.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Does this patch fix the problem? It is something I saw while doing
review for support of newer chips.
--------------------
Subject: sky2: don't set bogus bit in PHY register

This code inherited from the sk98lin driver is incorrect on the Yukon2.
The definition used for these bits is incorrect. Actual usage varies
with chip type, and we don't need to mess with them (yet).

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
