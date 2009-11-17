From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] net: fix mdio section mismatch warning
Date: Tue, 17 Nov 2009 19:47:33 +1100
Message-ID: <20091117194733.bd2308a8.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Laurent Pinchart <laurentp@cse-semaphore.com>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	Mark Ware <mware@elphinstone.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:53639 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579AbZKQIre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 03:47:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the following warning:

WARNING: drivers/net/phy/built-in.o(.devexit.text+0x70): Section mismatch in reference from the function .mdio_gpio_bus_destroy() to the function .devinit.text:.mdio_gpio_bus_deinit()
The function __devexit .mdio_gpio_bus_destroy() references
a function __devinit .mdio_gpio_bus_deinit().
This is often seen when error handling in the exit function
uses functionality in the init path.
The fix is often to remove the __devinit annotation of
.mdio_gpio_bus_deinit() so it may be used outside an init section.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/phy/mdio-gpio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 8659d34..3589713 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -139,7 +139,7 @@ out:
 	return NULL;
 }
 
-static void __devinit mdio_gpio_bus_deinit(struct device *dev)
+static void mdio_gpio_bus_deinit(struct device *dev)
 {
 	struct mii_bus *bus = dev_get_drvdata(dev);
 	struct mdio_gpio_info *bitbang = bus->priv;
-- 
1.6.5.2

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
