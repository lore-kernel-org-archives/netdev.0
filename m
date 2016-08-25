From: Sean@vger.kernel.org, Wang@vger.kernel.org
Subject: [PATCH net 05/10] net: ethernet: mediatek: fix logic unbalance between probe and remove
Date: Thu, 25 Aug 2016 18:22:32 +0800
Message-ID: <1472120557-15216-6-git-send-email-sean.wang@mediatek.com>
References: <1472120557-15216-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:60915 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753343AbcHYKXu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 06:23:50 -0400
In-Reply-To: <1472120557-15216-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

original mdio_cleanup is not in the symmetric place against where
mdio_init is, so relocate mdio_cleanup to the right one.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 9883dac..5bd31f8 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1504,7 +1504,6 @@ static void mtk_uninit(struct net_device *dev)
 	struct mtk_eth *eth = mac->hw;
 
 	phy_disconnect(mac->phy_dev);
-	mtk_mdio_cleanup(eth);
 	mtk_irq_disable(eth, ~0);
 }
 
@@ -1915,6 +1914,7 @@ static int mtk_remove(struct platform_device *pdev)
 	netif_napi_del(&eth->tx_napi);
 	netif_napi_del(&eth->rx_napi);
 	mtk_cleanup(eth);
+	mtk_mdio_cleanup(eth);
 
 	return 0;
 }
-- 
1.9.1
