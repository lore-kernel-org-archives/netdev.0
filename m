From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 01/22] net-next: mediatek: use mdiobus_free() in favour of kfree()
Date: Mon,  9 May 2016 12:03:53 +0200
Message-ID: <1462788254-40572-2-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:47289 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311AbcEIKEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:04:35 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver currently uses kfree() to clear the mii_bus. This is not the
correct way to clear the memory and mdiobus_free() should be used instead.
This patch fixes the two instances where this happens in the driver.

Reported-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index c984462..28f169f 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -280,7 +280,7 @@ static int mtk_mdio_init(struct mtk_eth *eth)
 	return 0;
 
 err_free_bus:
-	kfree(eth->mii_bus);
+	mdiobus_free(eth->mii_bus);
 
 err_put_node:
 	of_node_put(mii_np);
@@ -295,7 +295,7 @@ static void mtk_mdio_cleanup(struct mtk_eth *eth)
 
 	mdiobus_unregister(eth->mii_bus);
 	of_node_put(eth->mii_bus->dev.of_node);
-	kfree(eth->mii_bus);
+	mdiobus_free(eth->mii_bus);
 }
 
 static inline void mtk_irq_disable(struct mtk_eth *eth, u32 mask)
-- 
1.7.10.4
