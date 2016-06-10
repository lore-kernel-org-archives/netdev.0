From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 08/11] net: mediatek: increase watchdog_timeo
Date: Fri, 10 Jun 2016 13:28:05 +0200
Message-ID: <1465558088-15265-9-git-send-email-john@phrozen.org>
References: <1465558088-15265-1-git-send-email-john@phrozen.org>
Cc: Felix Fietkau <nbd@nbd.name>, Sean Wang <keyhaede@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465558088-15265-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During stress testing, after reducing the threshold value, we have seen
TX timeouts that were caused by the watchdog_timeo value being too low.
Increase the value to 5 * HZ which is a value commonly used by many other
drivers.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 8b289e1..24714ab 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1688,7 +1688,7 @@ static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
 	mac->hw_stats->reg_offset = id * MTK_STAT_OFFSET;
 
 	SET_NETDEV_DEV(eth->netdev[id], eth->dev);
-	eth->netdev[id]->watchdog_timeo = HZ;
+	eth->netdev[id]->watchdog_timeo = 5 * HZ;
 	eth->netdev[id]->netdev_ops = &mtk_netdev_ops;
 	eth->netdev[id]->base_addr = (unsigned long)eth->base;
 	eth->netdev[id]->vlan_features = MTK_HW_FEATURES &
-- 
1.7.10.4
