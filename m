From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 1/6] net: dsa: Provide unique DSA slave MII bus names
Date: Tue,  7 Jun 2016 16:32:38 -0700
Message-ID: <1465342363-28055-2-git-send-email-f.fainelli@gmail.com>
References: <1465342363-28055-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36789 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932478AbcFGXcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:32:55 -0400
Received: by mail-pf0-f195.google.com with SMTP id 62so21543503pfd.3
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 16:32:54 -0700 (PDT)
In-Reply-To: <1465342363-28055-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we have multiples trees and switches with the same index, we
need to add another discriminating id: the switch tree.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 15a492261895..a51dfedf0014 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -49,7 +49,8 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 	ds->slave_mii_bus->name = "dsa slave smi";
 	ds->slave_mii_bus->read = dsa_slave_phy_read;
 	ds->slave_mii_bus->write = dsa_slave_phy_write;
-	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "dsa-%d", ds->index);
+	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "dsa-%d.%d",
+		 ds->dst->tree, ds->index);
 	ds->slave_mii_bus->parent = ds->dev;
 	ds->slave_mii_bus->phy_mask = ~ds->phys_mii_mask;
 }
-- 
2.7.4
