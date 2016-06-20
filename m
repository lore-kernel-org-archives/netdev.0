From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v5 net-next v5 02/14] net: dsa: mv88e6xxx: remove redundant assignments
Date: Mon, 20 Jun 2016 13:13:59 -0400
Message-ID: <20160620171411.13746-3-vivien.didelot@savoirfairelinux.com>
References: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48685 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756111AbcFTRPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 13:15:19 -0400
In-Reply-To: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The chip->ds and ds->slave_mii_bus assignments are common to both legacy
and new MDIO probing and are already done in the later setup code.

Remove the duplicated assignments from the MDIO probing code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 1972ec5..673283a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3708,7 +3708,6 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	ds->priv = ps;
 	ds->dev = dev;
 	ps->dev = dev;
-	ps->ds = ds;
 	ps->bus = mdiodev->bus;
 	ps->sw_addr = mdiodev->addr;
 	mutex_init(&ps->smi_mutex);
@@ -3748,8 +3747,6 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (err)
 		return err;
 
-	ds->slave_mii_bus = ps->mdio_bus;
-
 	dev_set_drvdata(dev, ds);
 
 	err = dsa_register_switch(ds, mdiodev->dev.of_node);
-- 
2.9.0
