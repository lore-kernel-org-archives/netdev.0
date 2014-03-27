From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 02/14] tg3: remove empty MDIO bus reset function
Date: Wed, 26 Mar 2014 18:07:14 -0700
Message-ID: <1395882446-552-3-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:58845 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754894AbaC0BHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:07:43 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so2725823pad.0
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:07:43 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3_mdio_reset() does nothing useful and is optional for the MDIO bus
code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 37422af9ef13..1ac461a7d949 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1401,11 +1401,6 @@ static int tg3_mdio_write(struct mii_bus *bp, int mii_id, int reg, u16 val)
 	return ret;
 }
 
-static int tg3_mdio_reset(struct mii_bus *bp)
-{
-	return 0;
-}
-
 static void tg3_mdio_config_5785(struct tg3 *tp)
 {
 	u32 val;
@@ -1542,7 +1537,6 @@ static int tg3_mdio_init(struct tg3 *tp)
 	tp->mdio_bus->parent   = &tp->pdev->dev;
 	tp->mdio_bus->read     = &tg3_mdio_read;
 	tp->mdio_bus->write    = &tg3_mdio_write;
-	tp->mdio_bus->reset    = &tg3_mdio_reset;
 	tp->mdio_bus->phy_mask = ~(1 << tp->phy_addr);
 	tp->mdio_bus->irq      = &tp->mdio_irq[0];
 
-- 
1.8.3.2
