From: <sean.wang@mediatek.com>
Subject: [PATCH net-next 2/7] net: ethernet: mediatek: add mtk_hw_deinit call as the opposite to mtk_hw_init call
Date: Wed, 14 Sep 2016 11:50:36 +0800
Message-ID: <1473825041-21072-3-git-send-email-sean.wang@mediatek.com>
References: <1473825041-21072-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:46069 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757736AbcINDuz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 23:50:55 -0400
In-Reply-To: <1473825041-21072-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

grouping things related to the deinitialization of what
mtk_hw_init call does that help to be reused by the reset
process and the error path handling.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index ca46e82..c71b0b3 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1477,6 +1477,16 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
 	return 0;
 }
 
+static int mtk_hw_deinit(struct mtk_eth *eth)
+{
+	clk_disable_unprepare(eth->clks[MTK_CLK_GP2]);
+	clk_disable_unprepare(eth->clks[MTK_CLK_GP1]);
+	clk_disable_unprepare(eth->clks[MTK_CLK_ESW]);
+	clk_disable_unprepare(eth->clks[MTK_CLK_ETHIF]);
+
+	return 0;
+}
+
 static int __init mtk_init(struct net_device *dev)
 {
 	struct mtk_mac *mac = netdev_priv(dev);
@@ -1923,10 +1933,7 @@ static int mtk_remove(struct platform_device *pdev)
 		mtk_stop(eth->netdev[i]);
 	}
 
-	clk_disable_unprepare(eth->clks[MTK_CLK_ETHIF]);
-	clk_disable_unprepare(eth->clks[MTK_CLK_ESW]);
-	clk_disable_unprepare(eth->clks[MTK_CLK_GP1]);
-	clk_disable_unprepare(eth->clks[MTK_CLK_GP2]);
+	mtk_hw_deinit(eth);
 
 	netif_napi_del(&eth->tx_napi);
 	netif_napi_del(&eth->rx_napi);
-- 
1.9.1
