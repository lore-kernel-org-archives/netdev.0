From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/8] net: dsa: mv88e6xxx: do not increment bus refcount
Date: Wed,  8 Jun 2016 20:44:52 -0400
Message-ID: <20160609004456.5441-5-vivien.didelot@savoirfairelinux.com>
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

The MDIO device probe and remove functions are respectively incrementing
and decrementing the bus refcount themselves. Since these bus level
actions are out of the device scope, remove them.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index cfa30ae..02b0af7 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3710,8 +3710,6 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	ps->sw_addr = mdiodev->addr;
 	mutex_init(&ps->smi_mutex);
 
-	get_device(&ps->bus->dev);
-
 	ds->drv = &mv88e6xxx_switch_driver;
 
 	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
@@ -3765,7 +3763,6 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
 	dsa_unregister_switch(ds);
-	put_device(&ps->bus->dev);
 
 	mv88e6xxx_mdio_unregister(ps);
 }
-- 
2.8.3
