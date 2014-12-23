From: <shh.xie@gmail.com>
Subject: [PATCH 3/3] net/fsl: remove hardcoded clock setting from xgmac_mdio
Date: Tue, 23 Dec 2014 17:47:22 +0800
Message-ID: <1419328042-27294-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0100.outbound.protection.outlook.com ([157.56.111.100]:22944
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755816AbaLWLY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2014 06:24:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

There is no need to set the clock speed in read/write which will be performed
unnecessarily for each mdio access. Init it during probe is enough.

Also, the hardcoded clock value is not a proper way for all SoCs.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/ethernet/freescale/xgmac_mdio.c | 14 --------------
 1 file changed, 14 deletions(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index 72e0b85..f8c3bc0 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -94,13 +94,6 @@ static int xgmac_mdio_write(struct mii_bus *bus, int phy_id, int regnum, u16 val
 	uint16_t dev_addr = regnum >> 16;
 	int ret;
 
-	/* Setup the MII Mgmt clock speed */
-	out_be32(&regs->mdio_stat, MDIO_STAT_CLKDIV(100));
-
-	ret = xgmac_wait_until_free(&bus->dev, regs);
-	if (ret)
-		return ret;
-
 	/* Set the port and dev addr */
 	out_be32(&regs->mdio_ctl,
 		 MDIO_CTL_PORT_ADDR(phy_id) | MDIO_CTL_DEV_ADDR(dev_addr));
@@ -135,13 +128,6 @@ static int xgmac_mdio_read(struct mii_bus *bus, int phy_id, int regnum)
 	uint16_t value;
 	int ret;
 
-	/* Setup the MII Mgmt clock speed */
-	out_be32(&regs->mdio_stat, MDIO_STAT_CLKDIV(100));
-
-	ret = xgmac_wait_until_free(&bus->dev, regs);
-	if (ret)
-		return ret;
-
 	/* Set the Port and Device Addrs */
 	mdio_ctl = MDIO_CTL_PORT_ADDR(phy_id) | MDIO_CTL_DEV_ADDR(dev_addr);
 	out_be32(&regs->mdio_ctl, mdio_ctl);
-- 
1.8.4.1
