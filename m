From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 03/16] dsa: slave: Remove MDIO address from switch MDIO bus name
Date: Fri, 27 May 2016 03:20:37 +0200
Message-ID: <1464312050-23023-4-git-send-email-andrew@lunn.ch>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52510 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755771AbcE0BWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 21:22:40 -0400
In-Reply-To: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
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
