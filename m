From: Heiko Schocher <hs@denx.de>
Subject: [PATCH] net, fixed phy: make BUSID configurable
Date: Sun,  4 Dec 2011 10:37:24 +0100
Message-ID: <1322991444-20626-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs@denx.de>, netdev@vger.kernel.org,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Andrew Morton <akpm@osdl.org>, Jeff Garzik <jeff@garzik.org>,
	Wolfgang Denk <wd@denx.de>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:47029 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626Ab1LDJh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 04:37:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Heiko Schocher <hs@denx.de>
Cc: netdev@vger.kernel.org
Cc: Vitaly Bordug <vbordug@ru.mvista.com>
Cc: Andrew Morton <akpm@osdl.org>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Wolfgang Denk <wd@denx.de>
---
 drivers/net/phy/Kconfig |    5 +++++
 drivers/net/phy/fixed.c |    2 +-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index bb88e12..bed4bdd 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -101,6 +101,11 @@ config FIXED_PHY
 
 	  Currently tested with mpc866ads and mpc8349e-mitx.
 
+config FIXED_PHY_ID
+	int "BUS ID for fixed Bus/PHY emulation"
+	depends on FIXED_PHY
+	default "0"
+
 config MDIO_BITBANG
 	tristate "Support for bitbanged MDIO buses"
 	help
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 1fa4d73..5c77478 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -220,7 +220,7 @@ static int __init fixed_mdio_bus_init(void)
 		goto err_mdiobus_reg;
 	}
 
-	snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "0");
+	snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "%d", CONFIG_FIXED_PHY_ID);
 	fmb->mii_bus->name = "Fixed MDIO Bus";
 	fmb->mii_bus->priv = fmb;
 	fmb->mii_bus->parent = &pdev->dev;
-- 
1.7.6.4
