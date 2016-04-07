From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V2 8/8] net: mediatek: do not set the QID field in the TX DMA descriptors
Date: Thu,  7 Apr 2016 21:26:50 +0200
Message-ID: <1460057210-55786-9-git-send-email-blogic@openwrt.org>
References: <1460057210-55786-1-git-send-email-blogic@openwrt.org>
Cc: Felix Fietkau <nbd@openwrt.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	=?UTF-8?q?Sean=20Wang=20=28=E7=8E=8B=E5=BF=97=E4=BA=98=29?=
	<sean.wang@mediatek.com>, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	John Crispin <blogic@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460057210-55786-1-git-send-email-blogic@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The QID field gets set to the mac id. This made the DMA linked list queue
the traffic of each MAC on a different internal queue. However during long
term testing we found that this will cause traffic stalls as the multi
queue setup requires a more complete initialisation which is not part of
the upstream driver yet.

This patch removes the code setting the QID field, resulting in all
traffic ending up in queue 0 which works without any special setup.

Signed-off-by: John Crispin <blogic@openwrt.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index f9f8851..8163047 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -603,8 +603,7 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 			WRITE_ONCE(txd->txd1, mapped_addr);
 			WRITE_ONCE(txd->txd3, (TX_DMA_SWC |
 					       TX_DMA_PLEN0(frag_map_size) |
-					       last_frag * TX_DMA_LS0) |
-					       mac->id);
+					       last_frag * TX_DMA_LS0));
 			WRITE_ONCE(txd->txd4, 0);
 
 			tx_buf->skb = (struct sk_buff *)MTK_DMA_DUMMY_DESC;
-- 
1.7.10.4
