From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v5 net-next v5 04/14] net: dsa: mv88e6xxx: do not increment bus refcount
Date: Mon, 20 Jun 2016 13:14:01 -0400
Message-ID: <20160620171411.13746-5-vivien.didelot@savoirfairelinux.com>
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
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48970 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151AbcFTRWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 13:22:31 -0400
In-Reply-To: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MDIO device probe and remove functions are respectively incrementing
and decrementing the bus refcount themselves. Since these bus level
actions are out of the device scope, remove them.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Acked-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b3170ea..4b4bffc 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3712,8 +3712,6 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	ps->sw_addr = mdiodev->addr;
 	mutex_init(&ps->smi_mutex);
 
-	get_device(&ps->bus->dev);
-
 	ds->drv = &mv88e6xxx_switch_driver;
 
 	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
@@ -3767,7 +3765,6 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
 	dsa_unregister_switch(ds);
-	put_device(&ps->bus->dev);
 
 	mv88e6xxx_mdio_unregister(ps);
 }
-- 
2.9.0
