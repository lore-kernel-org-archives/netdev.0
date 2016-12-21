From: Romain Perier <romain.perier-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCH v3 net-next 1/3] net: dsa: mv88e6xxx: Don't forbid MDIO I/Os for PHY addr >= num_of_ports
Date: Wed, 21 Dec 2016 10:00:43 +0100
Message-ID: <20161221090045.474-2-romain.perier@free-electrons.com>
References: <20161221090045.474-1-romain.perier@free-electrons.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Nadav Haklai <nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Romain Perier <romain.perier-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161221090045.474-1-romain.perier-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some Marvell ethernet switches have internal ethernet transceivers with
hardcoded phy addresses. These addresses can be grearer than the number
of ports or its value might be different than the associated port number.
This is for example the case for MV88E6341 that has 6 ports and internal
Port 1 to Port4 PHYs mapped at SMI addresses from 0x11 to 0x14.

This commits fixes the issue by removing the condition in MDIO callbacks.

Signed-off-by: Romain Perier <romain.perier-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Reviewed-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
---

Changes in v2:
 - Added tag "Reviewed-by" by Andrew
 - Fixed typo in the commit log

 drivers/net/dsa/mv88e6xxx/chip.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b5f0e1e..76d944e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2881,9 +2881,6 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 	u16 val;
 	int err;
 
-	if (phy >= mv88e6xxx_num_ports(chip))
-		return 0xffff;
-
 	mutex_lock(&chip->reg_lock);
 	err = mv88e6xxx_phy_read(chip, phy, reg, &val);
 	mutex_unlock(&chip->reg_lock);
@@ -2896,9 +2893,6 @@ static int mv88e6xxx_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 	struct mv88e6xxx_chip *chip = bus->priv;
 	int err;
 
-	if (phy >= mv88e6xxx_num_ports(chip))
-		return 0xffff;
-
 	mutex_lock(&chip->reg_lock);
 	err = mv88e6xxx_phy_write(chip, phy, reg, val);
 	mutex_unlock(&chip->reg_lock);
-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
