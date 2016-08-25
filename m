From: Sean@vger.kernel.org, Wang@vger.kernel.org
Subject: [PATCH net 10/10] net: ethernet: mediatek: fix error handling inside mtk_mdio_init
Date: Thu, 25 Aug 2016 18:22:37 +0800
Message-ID: <1472120557-15216-11-git-send-email-sean.wang@mediatek.com>
References: <1472120557-15216-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:35654 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754425AbcHYKXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 06:23:51 -0400
In-Reply-To: <1472120557-15216-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

return -ENODEV if no child is found in MDIO bus.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 05d85da..2d547c2 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -300,7 +300,7 @@ static int mtk_mdio_init(struct mtk_eth *eth)
 	}
 
 	if (!of_device_is_available(mii_np)) {
-		err = 0;
+		err = -ENODEV;
 		goto err_put_node;
 	}
 
-- 
1.9.1
