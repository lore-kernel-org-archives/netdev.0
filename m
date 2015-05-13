From: Bert Vermeulen <bert@biot.com>
Subject: [PATCH] mdio-gpio: Propagate mii_bus.phy_ignore_ta_mask
Date: Wed, 13 May 2015 13:35:39 +0200
Message-ID: <1431516939-16589-1-git-send-email-bert@biot.com>
Cc: Bert Vermeulen <bert@biot.com>
To: f.fainelli@gmail.com, netdev@vger.kernel.org, jogo@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kiutl.biot.com ([31.172.244.210]:37875 "EHLO kiutl.biot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459AbbEMLfs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 07:35:48 -0400
Received: from spamd by kiutl.biot.com with sa-checked (Exim 4.83)
	(envelope-from <bert@biot.com>)
	id 1YsUwz-0003wm-VB
	for netdev@vger.kernel.org; Wed, 13 May 2015 13:35:46 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also changes mii_bus.phy_mask to u32 for consistency.

Signed-off-by: Bert Vermeulen <bert@biot.com>
---
This goes on top of Florian Fainelli's patch:
	net: phy: Add phy_ignore_ta_mask to account for broken turn-around

 drivers/net/phy/mdio-gpio.c | 1 +
 include/linux/mdio-gpio.h   | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index c0b7c56..859866a 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -154,6 +154,7 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
 	new_bus->name = "GPIO Bitbanged MDIO",
 
 	new_bus->phy_mask = pdata->phy_mask;
+	new_bus->phy_ignore_ta_mask = pdata->phy_ignore_ta_mask;
 	new_bus->irq = pdata->irqs;
 	new_bus->parent = dev;
 
diff --git a/include/linux/mdio-gpio.h b/include/linux/mdio-gpio.h
index 66c30a7..11f00cd 100644
--- a/include/linux/mdio-gpio.h
+++ b/include/linux/mdio-gpio.h
@@ -23,7 +23,8 @@ struct mdio_gpio_platform_data {
 	bool mdio_active_low;
 	bool mdo_active_low;
 
-	unsigned int phy_mask;
+	u32 phy_mask;
+	u32 phy_ignore_ta_mask;
 	int irqs[PHY_MAX_ADDR];
 	/* reset callback */
 	int (*reset)(struct mii_bus *bus);
-- 
1.9.1
