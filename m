From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 10/12] amd-xgbe-phy: Use the proper
 auto-negotiation XNP registers
Date: Fri, 16 Jan 2015 12:47:10 -0600
Message-ID: <20150116184710.18809.15250.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44034 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756806AbbAPSyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:31 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When receiving and processing extended next pages the base registers
were used instead of the XNP registers. Update the code to use the
device XNP and link partner XNP registers.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index 7207f36..e2074c7 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -122,6 +122,10 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define MDIO_AN_XNP			0x0016
 #endif
 
+#ifndef MDIO_AN_LPX
+#define MDIO_AN_LPX			0x0019
+#endif
+
 #ifndef MDIO_AN_INTMASK
 #define MDIO_AN_INTMASK			0x8001
 #endif
@@ -779,11 +783,11 @@ static enum amd_xgbe_phy_an amd_xgbe_an_rx_xnp(struct phy_device *phydev,
 	int ad_reg, lp_reg;
 
 	/* Check Extended Next Page support */
-	ad_reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE);
+	ad_reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_XNP);
 	if (ad_reg < 0)
 		return AMD_XGBE_AN_ERROR;
 
-	lp_reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_LPA);
+	lp_reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_LPX);
 	if (lp_reg < 0)
 		return AMD_XGBE_AN_ERROR;
 
