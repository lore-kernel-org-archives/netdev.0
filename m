From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 01/14] net: greth: remove empty MDIO bus reset function
Date: Wed, 26 Mar 2014 18:07:13 -0700
Message-ID: <1395882446-552-2-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:39350 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816AbaC0BHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:07:41 -0400
Received: by mail-pb0-f41.google.com with SMTP id jt11so2729667pbb.0
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:07:41 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

greth_mdio_reset() does nothing useful and this function is optional for
the MDIO bus code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/aeroflex/greth.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index c5d75e7aeeb6..23578dfee249 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1213,11 +1213,6 @@ static int greth_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 	return 0;
 }
 
-static int greth_mdio_reset(struct mii_bus *bus)
-{
-	return 0;
-}
-
 static void greth_link_change(struct net_device *dev)
 {
 	struct greth_private *greth = netdev_priv(dev);
@@ -1332,7 +1327,6 @@ static int greth_mdio_init(struct greth_private *greth)
 	snprintf(greth->mdio->id, MII_BUS_ID_SIZE, "%s-%d", greth->mdio->name, greth->irq);
 	greth->mdio->read = greth_mdio_read;
 	greth->mdio->write = greth_mdio_write;
-	greth->mdio->reset = greth_mdio_reset;
 	greth->mdio->priv = greth;
 
 	greth->mdio->irq = greth->mdio_irqs;
-- 
1.8.3.2
