From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH 1/1] net: phylib: add error checking if no phy found
Date: Tue, 13 Mar 2012 18:58:22 +0800
Message-ID: <1331636302-18256-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <timur@freescale.com>,
	<rdunlap@xenotime.net>, <kernel@pengutronix.de>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dong Aisheng <dong.aisheng@linaro.org>

Signed-off-by: Dong Aisheng <dong.aisheng@linaro.org>
---
 drivers/net/phy/mdio_bus.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 88cc5db..d8e044d 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -101,6 +101,7 @@ static struct class mdio_bus_class = {
 int mdiobus_register(struct mii_bus *bus)
 {
 	int i, err;
+	u32 phynum = 0;
 
 	if (NULL == bus || NULL == bus->name ||
 			NULL == bus->read ||
@@ -134,12 +135,20 @@ int mdiobus_register(struct mii_bus *bus)
 			if (IS_ERR(phydev)) {
 				err = PTR_ERR(phydev);
 				goto error;
+			} else if (phydev != NULL) {
+				phynum++;
 			}
 		}
 	}
 
+	if (!phynum) {
+		err = -ENODEV;
+		printk(KERN_ERR "%s: no phys found\n", bus->name);
+		goto error;
+	}
+
 	bus->state = MDIOBUS_REGISTERED;
-	pr_info("%s: probed\n", bus->name);
+	pr_info("%s: %d phys probed\n", bus->name, phynum);
 	return 0;
 
 error:
-- 
1.7.0.4
