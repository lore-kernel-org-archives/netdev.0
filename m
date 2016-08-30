From: <sean.wang@mediatek.com>
Subject: [PATCH net v3 9/9] net: ethernet: mediatek: fix error handling inside mtk_mdio_init
Date: Tue, 30 Aug 2016 10:59:25 +0800
Message-ID: <1472525965-10661-10-git-send-email-sean.wang@mediatek.com>
References: <1472525965-10661-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:19025 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757269AbcH3C75 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 22:59:57 -0400
In-Reply-To: <1472525965-10661-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

Return -ENODEV if the MDIO bus is disabled in the device tree.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
Acked-by: John Crispin <john@phrozen.org>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 2fc48bb..dfc12ab 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -304,7 +304,7 @@ static int mtk_mdio_init(struct mtk_eth *eth)
 	}
 
 	if (!of_device_is_available(mii_np)) {
-		ret = 0;
+		ret = -ENODEV;
 		goto err_put_node;
 	}
 
-- 
1.9.1
