From: <sean.wang@mediatek.com>
Subject: [PATCH net v2 7/9] net: ethernet: mediatek: fix the missing of_node_put() after node is used done inside mtk_mdio_init
Date: Mon, 29 Aug 2016 13:03:21 +0800
Message-ID: <1472447003-30726-8-git-send-email-sean.wang@mediatek.com>
References: <1472447003-30726-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:33234 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751062AbcH2FEq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 01:04:46 -0400
In-Reply-To: <1472447003-30726-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

This patch adds the missing of_node_put() after finishing the usage
of of_get_child_by_name.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
Acked-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 1001317..85a527a 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -324,6 +324,7 @@ static int mtk_mdio_init(struct mtk_eth *eth)
 	err = of_mdiobus_register(eth->mii_bus, mii_np);
 	if (err)
 		goto err_free_bus;
+	of_node_put(mii_np);
 
 	return 0;
 
-- 
1.9.1
