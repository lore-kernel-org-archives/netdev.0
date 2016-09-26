From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next 1/2] net: ethernet: mediatek: add to stop PDMA while stopping the frame engine
Date: Mon, 26 Sep 2016 14:33:49 +0800
Message-ID: <1474871630-4134-2-git-send-email-nelson.chang@mediatek.com>
References: <1474871630-4134-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:28239 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1761378AbcIZGd6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 02:33:58 -0400
In-Reply-To: <1474871630-4134-1-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stop PDMA while the frame engine is going to stop.

Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 4cc50c0..62de68d 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1784,6 +1784,7 @@ static int mtk_stop(struct net_device *dev)
 	napi_disable(&eth->rx_napi);
 
 	mtk_stop_dma(eth, MTK_QDMA_GLO_CFG);
+	mtk_stop_dma(eth, MTK_PDMA_GLO_CFG);
 
 	mtk_dma_free(eth);
 
-- 
1.9.1
