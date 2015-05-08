From: Bert Vermeulen <bert@biot.com>
Subject: [PATCH] net: mdio-gpio: Allow for unspecified bus id
Date: Fri,  8 May 2015 16:18:49 +0200
Message-ID: <1431094729-21775-1-git-send-email-bert@biot.com>
Cc: Bert Vermeulen <bert@biot.com>
To: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the bus id was supplied via a struct platform_device, the driver wasn't
handling -1 to mean an unspecified id of the only instance of this driver,
as the platform spec requires.

Signed-off-by: Bert Vermeulen <bert@biot.com>
---
 drivers/net/phy/mdio-gpio.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index f5cddf5..7bd90db 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -165,7 +165,10 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
 		if (!new_bus->irq[i])
 			new_bus->irq[i] = PHY_POLL;
 
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "gpio-%x", bus_id);
+	if (bus_id != -1)
+		snprintf(new_bus->id, MII_BUS_ID_SIZE, "gpio-%x", bus_id);
+	else
+		strncpy(new_bus->id, "gpio", MII_BUS_ID_SIZE);
 
 	if (devm_gpio_request(dev, bitbang->mdc, "mdc"))
 		goto out_free_bus;
-- 
1.9.1
