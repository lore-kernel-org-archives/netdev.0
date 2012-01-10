From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 05/21] macb: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:11 +0100
Message-ID: <1326189567-21663-6-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59607 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755979Ab2AJJ77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 04:59:59 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/cadence/macb.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index a437b46..49508b7 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -244,7 +244,8 @@ static int macb_mii_init(struct macb *bp)
 	bp->mii_bus->read = &macb_mdio_read;
 	bp->mii_bus->write = &macb_mdio_write;
 	bp->mii_bus->reset = &macb_mdio_reset;
-	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%x", bp->pdev->id);
+	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		bp->pdev->name, bp->pdev->id);
 	bp->mii_bus->priv = bp;
 	bp->mii_bus->parent = &bp->dev->dev;
 	pdata = bp->pdev->dev.platform_data;
-- 
1.7.5.4
