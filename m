From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 05/14] net: ethoc: remove empty MDIO bus function
Date: Wed, 26 Mar 2014 18:07:17 -0700
Message-ID: <1395882446-552-6-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:49713 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756405AbaC0BHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:07:51 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so2621013pdb.28
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:07:50 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethoc_mdio_reset() does nothing useful and is optional for the MDIO bus
code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 55e0fa03dc90..8b70ca7e342b 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -660,11 +660,6 @@ static int ethoc_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 	return -EBUSY;
 }
 
-static int ethoc_mdio_reset(struct mii_bus *bus)
-{
-	return 0;
-}
-
 static void ethoc_mdio_poll(struct net_device *dev)
 {
 }
@@ -1210,7 +1205,6 @@ static int ethoc_probe(struct platform_device *pdev)
 			priv->mdio->name, pdev->id);
 	priv->mdio->read = ethoc_mdio_read;
 	priv->mdio->write = ethoc_mdio_write;
-	priv->mdio->reset = ethoc_mdio_reset;
 	priv->mdio->priv = priv;
 
 	priv->mdio->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
-- 
1.8.3.2
