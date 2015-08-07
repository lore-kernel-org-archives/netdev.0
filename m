From: <shh.xie@gmail.com>
Subject: [PATCH] net: phy: select copper mode when Marvel 88e1111 in SGMII
Date: Fri, 7 Aug 2015 17:07:50 +0800
Message-ID: <1438938470-5776-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Madalin Bucur <madalin.bucur@freescale.com>,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0095.outbound.protection.outlook.com ([65.55.169.95]:60614
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751776AbbHGJNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2015 05:13:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@freescale.com>

For the Marvel 88e1111 PHY only two SGMII modes are available, both
allowing only SGMII to copper mode (with or without clock). SGMII
to fiber mode is not supported. Make sure the fiber/copper registers
selector bits are cleared for selecting copper mode.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/phy/marvell.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 3320a17..e6897b6 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -52,6 +52,7 @@
 #define MII_M1011_PHY_SCR_MDI_X		0x0020
 #define MII_M1011_PHY_SCR_AUTO_CROSS	0x0060
 
+#define MII_M1145_PHY_EXT_ADDR_PAGE	0x16
 #define MII_M1145_PHY_EXT_SR		0x1b
 #define MII_M1145_PHY_EXT_CR		0x14
 #define MII_M1145_RGMII_RX_DELAY	0x0080
@@ -552,6 +553,16 @@ static int m88e1111_config_init(struct phy_device *phydev)
 		err = phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
 		if (err < 0)
 			return err;
+
+		/* make sure copper is selected */
+		err = phy_read(phydev, MII_M1145_PHY_EXT_ADDR_PAGE);
+		if (err < 0)
+			return err;
+
+		err = phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE,
+				err & (~0xff));
+		if (err < 0)
+			return err;
 	}
 
 	if (phydev->interface == PHY_INTERFACE_MODE_RTBI) {
-- 
2.1.0.27.g96db324
