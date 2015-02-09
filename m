From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] net: dsa: Remove redundant phy_attach()
Date: Mon,  9 Feb 2015 02:29:55 +0100
Message-ID: <1423445395-412-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40028 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754359AbbBIBcn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Feb 2015 20:32:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dsa_slave_phy_setup() finds the phy for the port via device tree and
using of_phy_connect(), or it uses the fall back of taking a phy from
the switch internal mdio bus and calling phy_connect_direct(). Either
way, if a phy is found, phy_attach_direct() is called to attach the
phy to the slave device.

In dsa_slave_create(), a second call to phy_attach() is made. This
results in the warning "PHY already attached". Remove this second,
redundant attaching of the phy.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/slave.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 589aafd01fc5..d104ae15836f 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -676,18 +676,5 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	netif_carrier_off(slave_dev);
 
-	if (p->phy != NULL) {
-		if (ds->drv->get_phy_flags)
-			p->phy->dev_flags |= ds->drv->get_phy_flags(ds, port);
-
-		phy_attach(slave_dev, dev_name(&p->phy->dev),
-			   PHY_INTERFACE_MODE_GMII);
-
-		p->phy->autoneg = AUTONEG_ENABLE;
-		p->phy->speed = 0;
-		p->phy->duplex = 0;
-		p->phy->advertising = p->phy->supported | ADVERTISED_Autoneg;
-	}
-
 	return slave_dev;
 }
-- 
2.1.4
