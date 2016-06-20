From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v5 net-next v5 03/14] net: dsa: mv88e6xxx: use already declared variables
Date: Mon, 20 Jun 2016 13:14:00 -0400
Message-ID: <20160620171411.13746-4-vivien.didelot@savoirfairelinux.com>
References: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the MDIO probing function, dev is already assigned to &mdiodev->dev
and np is already assigned to mdiodev->dev.of_node, so use them.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 673283a..b3170ea 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3728,7 +3728,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (!ps->info)
 		return -ENODEV;
 
-	ps->reset = devm_gpiod_get(&mdiodev->dev, "reset", GPIOD_ASIS);
+	ps->reset = devm_gpiod_get(dev, "reset", GPIOD_ASIS);
 	if (IS_ERR(ps->reset)) {
 		err = PTR_ERR(ps->reset);
 		if (err == -ENOENT) {
@@ -3743,13 +3743,13 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
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
2.9.0
