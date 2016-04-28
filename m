From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2] of: of_mdio: Check if MDIO bus controller is available
Date: Thu, 28 Apr 2016 16:24:12 -0700
Message-ID: <1461885853-28846-1-git-send-email-f.fainelli@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, nathan.sullivan-acOepvfBmUk@public.gmane.org,
	nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:OPEN FIRMWARE AND FLATTENED
	DEVICE TREE), linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a check whether the 'struct device_node' pointer passed to
of_mdiobus_register() is an available (aka enabled) node in the Device
Tree.

Rationale for doing this are cases where an Ethernet MAC provides a MDIO
bus controller and node, and an additional Ethernet MAC might be
connecting its PHY/switches to that first MDIO bus controller, while
still embedding one internally which is therefore marked as "disabled".

Instead of sprinkling checks like these in callers of
of_mdiobus_register(), do this in a central location.

Reviewed-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
Changes in v2:
- utilize -ENODEV instead of -EINVAL
- added Andrew's reviewed-by tag

 drivers/of/of_mdio.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index b622b33dbf93..e051e1b57609 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -209,6 +209,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 	bool scanphys = false;
 	int addr, rc;
 
+	/* Do not continue if the node is disabled */
+	if (!of_device_is_available(np))
+		return -ENODEV;
+
 	/* Mask out all PHYs from auto probing.  Instead the PHYs listed in
 	 * the device tree are populated after the bus has been registered */
 	mdio->phy_mask = ~0;
-- 
2.1.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
