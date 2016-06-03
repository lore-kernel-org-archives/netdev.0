From: John Crispin <john@phrozen.org>
Subject: [PATCH V4 1/4] net-next: mediatek: use mdiobus_free() in favour of kfree()
Date: Fri,  3 Jun 2016 10:17:06 +0200
Message-ID: <1464941829-38712-2-git-send-email-john@phrozen.org>
References: <1464941829-38712-1-git-send-email-john@phrozen.org>
Cc: Felix Fietkau <nbd@openwrt.org>, Sean Wang <keyhaede@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464941829-38712-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver currently uses kfree() to clear the mii_bus. This is not the
correct way to clear the memory and mdiobus_free() should be used instead.
This patch fixes the two instances where this happens in the driver.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
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
