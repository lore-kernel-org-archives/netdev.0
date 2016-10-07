From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH] net: macb: NULL out phydev after removing mdio bus
Date: Fri, 7 Oct 2016 10:13:22 -0500
Message-ID: <1475853202-19903-1-git-send-email-xander.huff@ni.com>
Cc: netdev@vger.kernel.org, Nathan Sullivan <nathan.sullivan@ni.com>,
        linux-kernel@vger.kernel.org, xander.huff@ni.com,
        Brad Mouring <brad.mouring@ni.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Sullivan <nathan.sullivan@ni.com>

To ensure the dev->phydev pointer is not used after becoming invalid in
mdiobus_unregister, set it to NULL. This happens when removing the macb
driver without first taking its interface down, since unregister_netdev
will end up calling macb_close.

Signed-off-by: Xander Huff <xander.huff@ni.com>
Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
Signed-off-by: Brad Mouring <brad.mouring@ni.com>
---
 drivers/net/ethernet/cadence/macb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 63144bb..b32444a 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -3117,6 +3117,7 @@ static int macb_remove(struct platform_device *pdev)
 		if (dev->phydev)
 			phy_disconnect(dev->phydev);
 		mdiobus_unregister(bp->mii_bus);
+		dev->phydev = NULL;
 		mdiobus_free(bp->mii_bus);
 
 		/* Shutdown the PHY if there is a GPIO reset */
-- 
1.9.1
