From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 03/14] macb: remove empty MDIO bus reset function
Date: Wed, 26 Mar 2014 18:07:15 -0700
Message-ID: <1395882446-552-4-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:33359 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816AbaC0BHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:07:46 -0400
Received: by mail-pb0-f45.google.com with SMTP id uo5so2699302pbc.18
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:07:45 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macb_mdio_reset() does nothing useful and is optional for the MDIO bus
code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 6116887d2880..ca97005e24b4 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -199,11 +199,6 @@ static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	return 0;
 }
 
-static int macb_mdio_reset(struct mii_bus *bus)
-{
-	return 0;
-}
-
 /**
  * macb_set_tx_clk() - Set a clock to a new frequency
  * @clk		Pointer to the clock to change
@@ -375,7 +370,6 @@ int macb_mii_init(struct macb *bp)
 	bp->mii_bus->name = "MACB_mii_bus";
 	bp->mii_bus->read = &macb_mdio_read;
 	bp->mii_bus->write = &macb_mdio_write;
-	bp->mii_bus->reset = &macb_mdio_reset;
 	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
 		bp->pdev->name, bp->pdev->id);
 	bp->mii_bus->priv = bp;
-- 
1.8.3.2
