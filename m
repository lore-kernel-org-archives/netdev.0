From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 13/22] net-next: mediatek: increase watchdog_timeo
Date: Mon,  9 May 2016 12:04:05 +0200
Message-ID: <1462788254-40572-14-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:51765 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751377AbcEIKkz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:40:55 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During stress testing, after reducing the threshold value, we have seen
TX timeouts that were caused by the watchdog_timeo value being too low.
Increase the value to 5 * HZ which is a value commonly used by many other
drivers.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 984788a..3ece159 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1706,7 +1706,7 @@ static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
 	mac->hw_stats->reg_offset = id * MTK_STAT_OFFSET;
 
 	SET_NETDEV_DEV(eth->netdev[id], eth->dev);
-	eth->netdev[id]->watchdog_timeo = HZ;
+	eth->netdev[id]->watchdog_timeo = 5 * HZ;
 	eth->netdev[id]->netdev_ops = &mtk_netdev_ops;
 	eth->netdev[id]->base_addr = (unsigned long)eth->base;
 	eth->netdev[id]->vlan_features = MTK_HW_FEATURES &
-- 
1.7.10.4
