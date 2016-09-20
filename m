From: <sean.wang@mediatek.com>
Subject: [PATCH net-next] net: ethernet: mediatek: fix missing changes merged for conflicts overlapping commits
Date: Tue, 20 Sep 2016 23:53:24 +0800
Message-ID: <1474386804-11728-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:4059 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755070AbcITPxe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 11:53:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

add the missing commits about
1)
Commit d3bd1ce4db8e843dce421e2f8f123e5251a9c7d3
("remove redundant free_irq for devm_request_ir allocated irq")
2)
Commit 7c6b0d76fa02213393815e3b6d5e4a415bf3f0e2
("fix logic unbalance between probe and remove")

during merge for conflicts overlapping commits by
Commit b20b378d49926b82c0a131492fa8842156e0e8a9
("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 609fd2b..b831a8b 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1945,11 +1945,8 @@ static void mtk_uninit(struct net_device *dev)
 	struct mtk_eth *eth = mac->hw;
 
 	phy_disconnect(mac->phy_dev);
-	mtk_mdio_cleanup(eth);
 	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, ~0);
 	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, ~0);
-	free_irq(eth->irq[1], dev);
-	free_irq(eth->irq[2], dev);
 }
 
 static int mtk_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -2505,6 +2502,7 @@ static int mtk_remove(struct platform_device *pdev)
 	netif_napi_del(&eth->tx_napi);
 	netif_napi_del(&eth->rx_napi);
 	mtk_cleanup(eth);
+	mtk_mdio_cleanup(eth);
 
 	return 0;
 }
-- 
1.9.1
