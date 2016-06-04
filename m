From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/9] net: dsa: Provide unique DSA slave MII bus names
Date: Fri,  3 Jun 2016 17:05:25 -0700
Message-ID: <1464998733-10405-6-git-send-email-f.fainelli@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34033 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbcFDAFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:05:51 -0400
Received: by mail-pa0-f67.google.com with SMTP id x1so6939626pav.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:05:50 -0700 (PDT)
In-Reply-To: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we have multiples trees and switches with the same index, we
need to add another discriminating id: the switch tree.

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
