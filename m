From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: dsa: bcm_sf2: Utilize nested MDIO read/write
Date: Sat,  7 Jan 2017 21:01:57 -0800
Message-ID: <20170108050157.16302-3-f.fainelli@gmail.com>
References: <20170108050157.16302-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35961 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932284AbdAHFCC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 00:02:02 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so10002780pgf.3
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 21:02:01 -0800 (PST)
In-Reply-To: <20170108050157.16302-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are implementing a MDIO bus which is behind another one, so use the
nested version of the accessors to get lockdep annotations correct.

Fixes: 461cd1b03e32 ("net: dsa: bcm_sf2: Register our slave MDIO bus")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 2f9f910c0e40..2ce7ae97ac91 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -393,7 +393,7 @@ static int bcm_sf2_sw_mdio_read(struct mii_bus *bus, int addr, int regnum)
 	if (addr == BRCM_PSEUDO_PHY_ADDR && priv->indir_phy_mask & BIT(addr))
 		return bcm_sf2_sw_indir_rw(priv, 1, addr, regnum, 0);
 	else
-		return mdiobus_read(priv->master_mii_bus, addr, regnum);
+		return mdiobus_read_nested(priv->master_mii_bus, addr, regnum);
 }
 
 static int bcm_sf2_sw_mdio_write(struct mii_bus *bus, int addr, int regnum,
@@ -407,7 +407,7 @@ static int bcm_sf2_sw_mdio_write(struct mii_bus *bus, int addr, int regnum,
 	if (addr == BRCM_PSEUDO_PHY_ADDR && priv->indir_phy_mask & BIT(addr))
 		bcm_sf2_sw_indir_rw(priv, 0, addr, regnum, val);
 	else
-		mdiobus_write(priv->master_mii_bus, addr, regnum, val);
+		mdiobus_write_nested(priv->master_mii_bus, addr, regnum, val);
 
 	return 0;
 }
-- 
2.9.3
