From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 11/14] net: ftgmac100: remove empty MDIO bus reset function
Date: Wed, 26 Mar 2014 18:07:23 -0700
Message-ID: <1395882446-552-12-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34630 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756561AbaC0BIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:08:13 -0400
Received: by mail-pd0-f172.google.com with SMTP id p10so2607006pdj.31
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:08:13 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ftgmac100_mdiobus_reset() does nothing useful and is optional for the
MDIO bus code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index c11ecbc98149..68069eabc4f8 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -940,11 +940,6 @@ static int ftgmac100_mdiobus_write(struct mii_bus *bus, int phy_addr,
 	return -EIO;
 }
 
-static int ftgmac100_mdiobus_reset(struct mii_bus *bus)
-{
-	return 0;
-}
-
 /******************************************************************************
  * struct ethtool_ops functions
  *****************************************************************************/
@@ -1262,7 +1257,6 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	priv->mii_bus->priv = netdev;
 	priv->mii_bus->read = ftgmac100_mdiobus_read;
 	priv->mii_bus->write = ftgmac100_mdiobus_write;
-	priv->mii_bus->reset = ftgmac100_mdiobus_reset;
 	priv->mii_bus->irq = priv->phy_irq;
 
 	for (i = 0; i < PHY_MAX_ADDR; i++)
-- 
1.8.3.2
