From: <shh.xie@gmail.com>
Subject: [PATCH 2/3] net/fsl: remove irq assignment from xgmac_mdio
Date: Tue, 23 Dec 2014 17:46:59 +0800
Message-ID: <1419328019-27254-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0066.outbound.protection.outlook.com ([157.56.111.66]:39851
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755815AbaLWLYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2014 06:24:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

Which is wrong and not used, so no extra space needed by
mdio_alloc_size(), change the parameter accordingly.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/ethernet/freescale/xgmac_mdio.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index 90adba1..72e0b85 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -187,14 +187,13 @@ static int xgmac_mdio_probe(struct platform_device *pdev)
 		return ret;
 	}
 
-	bus = mdiobus_alloc_size(PHY_MAX_ADDR * sizeof(int));
+	bus = mdiobus_alloc_size(0);
 	if (!bus)
 		return -ENOMEM;
 
 	bus->name = "Freescale XGMAC MDIO Bus";
 	bus->read = xgmac_mdio_read;
 	bus->write = xgmac_mdio_write;
-	bus->irq = bus->priv;
 	bus->parent = &pdev->dev;
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%llx", (unsigned long long)res.start);
 
-- 
1.8.4.1
