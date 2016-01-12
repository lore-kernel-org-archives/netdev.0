From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 2/2 -next] phy: remove an unneeded condition
Date: Tue, 12 Jan 2016 12:36:21 +0300
Message-ID: <20160112093621.GF29804@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It used to be that bus->irq was a pointer but after e7f4dc3536a4
('mdio: Move allocation of interrupts into core') it's an array inside
the mdio struct, so it can never be NULL.  Let's remove the check.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 3193006..903737a 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -340,7 +340,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 	dev->phy_id = phy_id;
 	if (c45_ids)
 		dev->c45_ids = *c45_ids;
-	dev->irq = bus->irq ? bus->irq[addr] : PHY_POLL;
+	dev->irq = bus->irq[addr];
 	dev_set_name(&mdiodev->dev, PHY_ID_FMT, bus->id, addr);
 
 	dev->state = PHY_DOWN;
