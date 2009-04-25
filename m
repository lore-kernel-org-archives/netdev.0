From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v3 10/13] powerpc/82xx: Rework Embedded Planet ep8248e
	platform to use of_mdio
Date: Sat, 25 Apr 2009 16:53:28 -0600
Message-ID: <20090425225328.32392.2015.stgit@localhost.localdomain>
References: <20090425224458.32392.31296.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Andy Fleming <afleming@freescale.com>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:42493 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557AbZDYWxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 18:53:31 -0400
Received: by wf-out-1314.google.com with SMTP id 26so1420203wfd.4
        for <netdev@vger.kernel.org>; Sat, 25 Apr 2009 15:53:30 -0700 (PDT)
In-Reply-To: <20090425224458.32392.31296.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch modifies the bitbanged MDIO driver in the ep8248e platform
code to use the common of_mdio infrastructure.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
Acked-by: Andy Fleming <afleming@freescale.com>
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

