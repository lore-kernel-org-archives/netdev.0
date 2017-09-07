From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: netcp_core: no need in netif_napi_del
Date: Thu,  7 Sep 2017 18:32:30 +0300
Message-ID: <1504798350-790-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-kernel@vger.kernel.org, grygorii.strashko@ti.com,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: w-kwok2@ti.com, m-karicheri2@ti.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't remove rx_napi specifically just before free_netdev(),
it's supposed to be done in it and is confusing w/o tx_napi deletion.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
Based on net-next/master

 drivers/net/ethernet/ti/netcp_core.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index eb96a69..437d362 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -2145,7 +2145,6 @@ static void netcp_delete_interface(struct netcp_device *netcp_device,
 
 	of_node_put(netcp->node_interface);
 	unregister_netdev(ndev);
-	netif_napi_del(&netcp->rx_napi);
 	free_netdev(ndev);
 }
 
-- 
2.7.4
