From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 07/10] bnx2x: Fix BCM8726 ROM load seq
Date: Thu, 5 Nov 2009 19:18:26 +0200
Message-ID: <1257441506.3390.54.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2641 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756036AbZKEPSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 10:18:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 7897fe1..1b73c1d 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -2592,16 +2592,11 @@ static void bnx2x_bcm8726_external_rom_boot(struct link_params *params)
 	/* Need to wait 100ms after reset */
 	msleep(100);
 
-	/* Set serial boot control for external load */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_MISC_CTRL1, 0x0001);
-
 	/* Micro controller re-boot */
 	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_GEN_CTRL,
-		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
+		       0x018B);
 
 	/* Set soft reset */
 	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
@@ -2609,14 +2604,10 @@ static void bnx2x_bcm8726_external_rom_boot(struct link_params *params)
 		       MDIO_PMA_REG_GEN_CTRL,
 		       MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
 
-	/* Set PLL register value to be same like in P13 ver */
 	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
 		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_PLL_CTRL,
-		       0x73A0);
+		       MDIO_PMA_REG_MISC_CTRL1, 0x0001);
 
-	/* Clear soft reset.
-	Will automatically reset micro-controller re-boot */
 	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_GEN_CTRL,
-- 
1.6.5.2




