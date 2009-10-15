From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] mdio-gpio: inline mdio_gpio_bus_deinit to avoid section issues
Date: Thu, 15 Oct 2009 03:01:41 -0400
Message-ID: <1255590101-5813-1-git-send-email-vapier@gentoo.org>
Cc: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	Roel Kluin <roel.kluin@gmail.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934866AbZJOHCV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mdio_gpio_bus_deinit() code is called from the probe/remove functions
which accordingly have __devinit/__devexit markings.  Rather than simply
remove its section marking, inline the code so that it can be freed as
needed by each function.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/phy/mdio-gpio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 22cdd45..a280224 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -139,7 +139,7 @@ out:
 	return NULL;
 }
 
-static void __devinit mdio_gpio_bus_deinit(struct device *dev)
+static inline void mdio_gpio_bus_deinit(struct device *dev)
 {
 	struct mii_bus *bus = dev_get_drvdata(dev);
 	struct mdio_gpio_info *bitbang = bus->priv;
-- 
1.6.5
