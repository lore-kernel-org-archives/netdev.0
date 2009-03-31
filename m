From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 12/14] powerpc/82xx: Rework Embedded Planet ep8248e platform
	to use of_mdio
Date: Tue, 31 Mar 2009 02:27:46 -0600
Message-ID: <20090331082745.1427.91493.stgit@localhost.localdomain>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, afleming@freescale.com, galak@kernel.crashing.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:58055 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbZCaI1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 04:27:49 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2906140rvb.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 01:27:48 -0700 (PDT)
In-Reply-To: <20090331075537.1427.7819.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch modifies the bitbanged MDIO driver in the ep8248e platform
code to use the common of_mdio infrastructure.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 arch/powerpc/platforms/82xx/ep8248e.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)


diff --git a/arch/powerpc/platforms/82xx/ep8248e.c b/arch/powerpc/platforms/82xx/ep8248e.c
index 0eb6d7f..51fcae4 100644
--- a/arch/powerpc/platforms/82xx/ep8248e.c
+++ b/arch/powerpc/platforms/82xx/ep8248e.c
@@ -14,6 +14,7 @@
 #include <linux/interrupt.h>
 #include <linux/fsl_devices.h>
 #include <linux/mdio-bitbang.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 
 #include <asm/io.h>
@@ -115,7 +116,7 @@ static int __devinit ep8248e_mdio_probe(struct of_device *ofdev,
 	struct mii_bus *bus;
 	struct resource res;
 	struct device_node *node;
-	int ret, i;
+	int ret;
 
 	node = of_get_parent(ofdev->node);
 	of_node_put(node);
@@ -130,17 +131,13 @@ static int __devinit ep8248e_mdio_probe(struct of_device *ofdev,
 	if (!bus)
 		return -ENOMEM;
 
-	bus->phy_mask = 0;
 	bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
 
-	for (i = 0; i < PHY_MAX_ADDR; i++)
-		bus->irq[i] = -1;
-
 	bus->name = "ep8248e-mdio-bitbang";
 	bus->parent = &ofdev->dev;
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 
-	return mdiobus_register(bus);
+	return of_mdiobus_register(bus, ofdev->node);
 }
 
 static int ep8248e_mdio_remove(struct of_device *ofdev)

