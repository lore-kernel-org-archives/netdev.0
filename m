From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 10/13] powerpc/82xx: Rework Embedded Planet ep8248e
	platform to use of_mdio
Date: Sat, 21 Mar 2009 16:29:07 -0600
Message-ID: <20090321222906.20493.32061.stgit@localhost.localdomain>
References: <20090321222047.20493.87335.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, galak@kernel.crashing.org,
	davem@davemloft.net
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:30079 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756174AbZCUW3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 18:29:12 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2085855wff.4
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2009 15:29:10 -0700 (PDT)
In-Reply-To: <20090321222047.20493.87335.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch modifies the bitbanged MDIO driver in the ep8248e platform
code to use the common of_mdio infrastructure.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 arch/powerpc/platforms/82xx/ep8248e.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)


diff --git a/arch/powerpc/platforms/82xx/ep8248e.c b/arch/powerpc/platforms/82xx/ep8248e.c
index 0eb6d7f..bd323b5 100644
--- a/arch/powerpc/platforms/82xx/ep8248e.c
+++ b/arch/powerpc/platforms/82xx/ep8248e.c
@@ -14,6 +14,7 @@
 #include <linux/interrupt.h>
 #include <linux/fsl_devices.h>
 #include <linux/mdio-bitbang.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 
 #include <asm/io.h>
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

