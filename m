From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: netcp_core: remove netif_trans_update
Date: Thu,  9 Feb 2017 16:17:40 +0200
Message-ID: <1486649860-8824-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: w-kwok2@ti.com, m-karicheri2@ti.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to update jiffies in txq->trans_start twice and only for tx 0,
it's supposed to be done in netdev_start_xmit() and per tx queue.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
Based on net-next/master

 drivers/net/ethernet/ti/netcp_core.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index ebab1473..7c7ae08 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1316,8 +1316,6 @@ static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (ret)
 		goto drop;
 
-	netif_trans_update(ndev);
-
 	/* Check Tx pool count & stop subqueue if needed */
 	desc_count = knav_pool_count(netcp->tx_pool);
 	if (desc_count < netcp->tx_pause_threshold) {
-- 
2.7.4
