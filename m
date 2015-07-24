From: <shh.xie@gmail.com>
Subject: [PATCH] net: phy: fix auto negotiation checking for teranetics
Date: Fri, 24 Jul 2015 19:26:02 +0800
Message-ID: <1437737162-32854-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0080.outbound.protection.outlook.com ([207.46.100.80]:26496
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753028AbbGXLbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2015 07:31:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

When using fiber port, the phy cannot report it's auto negotiation state,
driver should always report auto negotiation is done when using fiber port.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/phy/teranetics.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/teranetics.c b/drivers/net/phy/teranetics.c
index 7dcb5aa..91e1bec 100644
--- a/drivers/net/phy/teranetics.c
+++ b/drivers/net/phy/teranetics.c
@@ -51,8 +51,15 @@ static int teranetics_aneg_done(struct phy_device *phydev)
 {
 	int reg;
 
-	reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
-	return (reg < 0) ? reg : (reg & BMSR_ANEGCOMPLETE);
+	/* auto negotiation state can only be checked when using copper
+	 * port, if using fiber port, just lie it's done.
+	 */
+	if (!phy_read_mmd(phydev, MDIO_MMD_VEND1, 93)) {
+		reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
+		return (reg < 0) ? reg : (reg & BMSR_ANEGCOMPLETE);
+	}
+
+	return 1;
 }
 
 static int teranetics_config_aneg(struct phy_device *phydev)
-- 
2.1.0.27.g96db324
