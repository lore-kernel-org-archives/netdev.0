From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V2 1/8] net: mediatek: watchdog_timeo was not set
Date: Thu,  7 Apr 2016 21:26:43 +0200
Message-ID: <1460057210-55786-2-git-send-email-blogic@openwrt.org>
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

The original commit failed to set watchdog_timeo. This patch sets
watchdog_timeo to HZ.

Signed-off-by: John Crispin <blogic@openwrt.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index e0b68af..bb10d57 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1645,6 +1645,7 @@ static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
 	mac->hw_stats->reg_offset = id * MTK_STAT_OFFSET;
 
 	SET_NETDEV_DEV(eth->netdev[id], eth->dev);
+	eth->netdev[id]->watchdog_timeo = HZ;
 	eth->netdev[id]->netdev_ops = &mtk_netdev_ops;
 	eth->netdev[id]->base_addr = (unsigned long)eth->base;
 	eth->netdev[id]->vlan_features = MTK_HW_FEATURES &
-- 
1.7.10.4
