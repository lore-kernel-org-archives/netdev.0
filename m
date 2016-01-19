From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/3] net: bcmgenet: Properly configure PHY to ignore interrupt
Date: Mon, 18 Jan 2016 19:33:08 -0800
Message-ID: <1453174388-26752-4-git-send-email-f.fainelli@gmail.com>
References: <1453174388-26752-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	sergei.shtylyov@cogentembedded.com, Woojung.Huh@microchip.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34547 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756522AbcASDd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 22:33:59 -0500
Received: by mail-pa0-f51.google.com with SMTP id uo6so429768084pac.1
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 19:33:58 -0800 (PST)
In-Reply-To: <1453174388-26752-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By the time we execute bcmgenet_mii_probe(), the MDIO bus structure has
long been allocated and registered. Overirring the PHY interrupt using
the MDIO bus structure has no chance to work anymore, because
of_mdiobus_register() has call phy_device_create() for use, which copied
the MDIO bus address's irq for the PHY into the PHY device "irq" member.

Since we do have a proper reference to a PHY device in
bcmgenet_mii_probe(), just assign the desired IRQ value here.

Fixes: aa09677cba42 ("net: bcmgenet: add MDIO routines")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 0d775964b060..457c3bc8cfff 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -401,7 +401,7 @@ int bcmgenet_mii_probe(struct net_device *dev)
 	 * Ethernet MAC ISRs
 	 */
 	if (priv->internal_phy)
-		priv->mii_bus->irq[phydev->mdio.addr] = PHY_IGNORE_INTERRUPT;
+		priv->phydev->irq = PHY_IGNORE_INTERRUPT;
 
 	return 0;
 }
-- 
2.1.0
