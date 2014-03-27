From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 09/14] net: emaclite: remove empty MDIO bus reset function
Date: Wed, 26 Mar 2014 18:07:21 -0700
Message-ID: <1395882446-552-10-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:57921 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756551AbaC0BIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:08:05 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so2618483pdj.4
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:08:05 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xemaclite_mdio_reset() does nothing useful and is optional for the MDIO
bus code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 58756617644f..0d87c67a5ff7 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -795,18 +795,6 @@ static int xemaclite_mdio_write(struct mii_bus *bus, int phy_id, int reg,
 }
 
 /**
- * xemaclite_mdio_reset - Reset the mdio bus.
- * @bus:	Pointer to the MII bus
- *
- * This function is required(?) as per Documentation/networking/phy.txt.
- * There is no reset in this device; this function always returns 0.
- */
-static int xemaclite_mdio_reset(struct mii_bus *bus)
-{
-	return 0;
-}
-
-/**
  * xemaclite_mdio_setup - Register mii_bus for the Emaclite device
  * @lp:		Pointer to the Emaclite device private data
  * @ofdev:	Pointer to OF device structure
@@ -861,7 +849,6 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 	bus->name = "Xilinx Emaclite MDIO";
 	bus->read = xemaclite_mdio_read;
 	bus->write = xemaclite_mdio_write;
-	bus->reset = xemaclite_mdio_reset;
 	bus->parent = dev;
 	bus->irq = lp->mdio_irqs; /* preallocated IRQ table */
 
-- 
1.8.3.2
