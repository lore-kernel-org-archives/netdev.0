From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v4 net-next v4 03/14] net: dsa: mv88e6xxx: use already declared variables
Date: Mon, 20 Jun 2016 12:03:26 -0400
Message-ID: <20160620160337.2934-4-vivien.didelot@savoirfairelinux.com>
References: <20160620160337.2934-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45999 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbcFTQOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 12:14:49 -0400
In-Reply-To: <20160620160337.2934-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
