From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: [PATCH] phy: micrel: Fix build failure in ksz9031_config_init()
Date: Sat,  9 Jan 2016 12:24:34 +0100
Message-ID: <1452338674-3353-1-git-send-email-sedat.dilek@gmail.com>
Cc: Sedat Dilek <sedat.dilek@gmail.com>,
	Roosen Henri <Henri.Roosen@ginzinger.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Daney <david.daney@cavium.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38141 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236AbcAILXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 06:23:24 -0500
Received: by mail-wm0-f48.google.com with SMTP id b14so205471197wmb.1
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 03:23:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the following build failure seen in net.git#master on top of
Linux v4.4-rc8+:

drivers/net/phy/micrel.c: In function 'ksz9031_config_init':
drivers/net/phy/micrel.c:492:22: error: 'struct phy_device' has no member named 'dev'
  dev_walker = &phydev->dev;

Fixes: b4c19f71252e ("phy: micrel: Fix finding PHY properties in MAC node for KSZ9031.")
CC: Roosen Henri <Henri.Roosen@ginzinger.com>
CC: Andrew Lunn <andrew@lunn.ch>
CC: David Daney <david.daney@cavium.com>
CC: Florian Fainelli <f.fainelli@gmail.com>
CC: David S. Miller <davem@davemloft.net>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>
---
 drivers/net/phy/micrel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 7a5679982c03..a7e17eabec37 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -476,7 +476,7 @@ static int ksz9031_config_init(struct phy_device *phydev)
 	 * properties in the MAC node. Walk up the tree of devices to
 	 * find a device with an OF node.
 	 */
-	dev_walker = &phydev->dev;
+	dev_walker = &phydev->mdio.dev;
 	do {
 		of_node = dev_walker->of_node;
 		dev_walker = dev_walker->parent;
-- 
2.7.0
