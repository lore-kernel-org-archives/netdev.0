From: Sean Wang <sean.wang@mediatek.com>
Subject: [RESEND PATCH net 04/10] net: ethernet: mediatek: remove redundant free_irq for devm_request_irq allocated irq
Date: Thu, 25 Aug 2016 18:44:55 +0800
Message-ID: <1472121901-15629-5-git-send-email-sean.wang@mediatek.com>
References: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:49643 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S933127AbcHYKpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 06:45:13 -0400
In-Reply-To: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

these irqs are not used for shared irq and disabled during ethernet stops.
irq requested by devm_request_irq is safe to be freed automatically on
driver detach.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 1b131a1..9883dac 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1506,8 +1506,6 @@ static void mtk_uninit(struct net_device *dev)
 	phy_disconnect(mac->phy_dev);
 	mtk_mdio_cleanup(eth);
 	mtk_irq_disable(eth, ~0);
-	free_irq(eth->irq[1], dev);
-	free_irq(eth->irq[2], dev);
 }
 
 static int mtk_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
-- 
1.9.1
