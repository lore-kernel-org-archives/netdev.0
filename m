From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: add PHY IRQ to platform data
Date: Fri, 20 Dec 2013 01:39:52 +0300
Message-ID: <201312200139.52758.sergei.shtylyov@cogentembedded.com>
References: <201312200138.09307.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:60922 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756258Ab3LSVjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 16:39:45 -0500
Received: by mail-la0-f52.google.com with SMTP id y1so727019lam.39
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 13:39:44 -0800 (PST)
In-Reply-To: <201312200138.09307.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the platform code to pass PHY's IRQ to the driver.  Print this IRQ along
with the other PHY datails in sh_eth_phy_init().

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    6 ++++--
 include/linux/sh_eth.h                |    1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1685,8 +1685,8 @@ static int sh_eth_phy_init(struct net_de
 		return PTR_ERR(phydev);
 	}
 
-	dev_info(&ndev->dev, "attached phy %i to driver %s\n",
-		phydev->addr, phydev->drv->name);
+	dev_info(&ndev->dev, "attached PHY %d (IRQ %d) to driver %s\n",
+		 phydev->addr, phydev->irq, phydev->drv->name);
 
 	mdp->phydev = phydev;
 
@@ -2544,6 +2544,8 @@ static int sh_mdio_init(struct net_devic
 
 	for (i = 0; i < PHY_MAX_ADDR; i++)
 		mdp->mii_bus->irq[i] = PHY_POLL;
+	if (pd->phy_irq > 0)
+		mdp->mii_bus->irq[pd->phy] = pd->phy_irq;
 
 	/* register mdio bus */
 	ret = mdiobus_register(mdp->mii_bus);
Index: net-next/include/linux/sh_eth.h
===================================================================
--- net-next.orig/include/linux/sh_eth.h
+++ net-next/include/linux/sh_eth.h
@@ -8,6 +8,7 @@ enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_END
 
 struct sh_eth_plat_data {
 	int phy;
+	int phy_irq;
 	int edmac_endian;
 	phy_interface_t phy_interface;
 	void (*set_mdio_gate)(void *addr);
