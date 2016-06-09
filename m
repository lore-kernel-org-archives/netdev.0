From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/8] net: dsa: mv88e6xxx: use already declared variables
Date: Wed,  8 Jun 2016 20:44:51 -0400
Message-ID: <20160609004456.5441-4-vivien.didelot@savoirfairelinux.com>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the MDIO probing function, dev is already assigned to &mdiodev->dev
and np is already assigned to mdiodev->dev.of_node, so use them.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index cb8b1b7..cfa30ae 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3726,7 +3726,7 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (!ps->info)
 		return -ENODEV;
 
-	ps->reset = devm_gpiod_get(&mdiodev->dev, "reset", GPIOD_ASIS);
+	ps->reset = devm_gpiod_get(dev, "reset", GPIOD_ASIS);
 	if (IS_ERR(ps->reset)) {
 		err = PTR_ERR(ps->reset);
 		if (err == -ENOENT) {
@@ -3741,13 +3741,13 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	    !of_property_read_u32(np, "eeprom-length", &eeprom_len))
 		ps->eeprom_len = eeprom_len;
 
-	err = mv88e6xxx_mdio_register(ps, mdiodev->dev.of_node);
+	err = mv88e6xxx_mdio_register(ps, np);
 	if (err)
 		return err;
 
 	dev_set_drvdata(dev, ds);
 
-	err = dsa_register_switch(ds, mdiodev->dev.of_node);
+	err = dsa_register_switch(ds, np);
 	if (err) {
 		mv88e6xxx_mdio_unregister(ps);
 		return err;
-- 
2.8.3
