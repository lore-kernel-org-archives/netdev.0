From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 03/17] net: dsa: slave: Remove MDIO address from switch MDIO bus name
Date: Fri,  3 Jun 2016 18:44:02 +0200
Message-ID: <1464972256-10408-4-git-send-email-andrew@lunn.ch>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58696 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932150AbcFCQsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 12:48:37 -0400
In-Reply-To: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DSA layer should no longer assume the switch is connected to an
MDIO bus. As a result, we cannot use the address on the MDIO bus when
forming the name of the switches internal MDIO bus for its builtin and
possibly external PHYs. The switch index is sufficient to make the
name unique, so drop the MDIO address.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/slave.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 135a91706755..f640a48a6ff3 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -49,8 +49,7 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 	ds->slave_mii_bus->name = "dsa slave smi";
 	ds->slave_mii_bus->read = dsa_slave_phy_read;
 	ds->slave_mii_bus->write = dsa_slave_phy_write;
-	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "dsa-%d:%.2x",
-			ds->index, ds->cd->sw_addr);
+	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "dsa-%d", ds->index);
 	ds->slave_mii_bus->parent = ds->dev;
 	ds->slave_mii_bus->phy_mask = ~ds->phys_mii_mask;
 }
-- 
2.8.1
