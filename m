From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v3 net-next v3 02/14] net: dsa: mv88e6xxx: remove redundant assignments
Date: Fri, 17 Jun 2016 20:07:24 -0400
Message-ID: <20160618000736.5598-3-vivien.didelot@savoirfairelinux.com>
References: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
2.8.3
