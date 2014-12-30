From: <shh.xie@gmail.com>
Subject: [PATCH 1/3][v2] net/fsl: remove reset from xgmac_mdio
Date: Tue, 30 Dec 2014 16:27:33 +0800
Message-ID: <1419928053-2450-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0065.outbound.protection.outlook.com ([157.56.110.65]:11808
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751683AbaL3JcO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2014 04:32:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

Since the reset is just clock setting, individual mdio reset is
not available.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
changes in v2:
no change.

 drivers/net/ethernet/freescale/xgmac_mdio.c | 19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index 6e7db66..90adba1 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -174,24 +174,6 @@ static int xgmac_mdio_read(struct mii_bus *bus, int phy_id, int regnum)
 	return value;
 }
 
-/* Reset the MIIM registers, and wait for the bus to free */
-static int xgmac_mdio_reset(struct mii_bus *bus)
-{
-	struct tgec_mdio_controller __iomem *regs = bus->priv;
-	int ret;
-
-	mutex_lock(&bus->mdio_lock);
-
-	/* Setup the MII Mgmt clock speed */
-	out_be32(&regs->mdio_stat, MDIO_STAT_CLKDIV(100));
-
-	ret = xgmac_wait_until_free(&bus->dev, regs);
-
-	mutex_unlock(&bus->mdio_lock);
-
-	return ret;
-}
-
 static int xgmac_mdio_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
@@ -212,7 +194,6 @@ static int xgmac_mdio_probe(struct platform_device *pdev)
 	bus->name = "Freescale XGMAC MDIO Bus";
 	bus->read = xgmac_mdio_read;
 	bus->write = xgmac_mdio_write;
-	bus->reset = xgmac_mdio_reset;
 	bus->irq = bus->priv;
 	bus->parent = &pdev->dev;
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%llx", (unsigned long long)res.start);
-- 
1.8.4.1
