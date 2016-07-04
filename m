From: John Crispin <john@phrozen.org>
Subject: [PATCH] net-next: mediatek: remove superfluous free_irq() call
Date: Mon,  4 Jul 2016 15:37:10 +0200
Message-ID: <1467639430-64370-1-git-send-email-john@phrozen.org>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:47726 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753632AbcGDNh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 09:37:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8067302973a1 ("net-next: mediatek: add support for IRQ grouping")
adds handling for irq 1 and 2 to the uninit function but did not remove
irq 0 which is not used since irq grouping was introduced. Fix this by
removing the superfluous call to free_irq().

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index fbab9b2..682797e 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1492,7 +1492,6 @@ static void mtk_uninit(struct net_device *dev)
 	phy_disconnect(mac->phy_dev);
 	mtk_mdio_cleanup(eth);
 	mtk_irq_disable(eth, ~0);
-	free_irq(eth->irq[0], dev);
 	free_irq(eth->irq[1], dev);
 	free_irq(eth->irq[2], dev);
 }
-- 
1.7.10.4
