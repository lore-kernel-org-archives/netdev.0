From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: netcp_core: return netdev_tx_t in xmit
Date: Thu,  9 Feb 2017 16:24:14 +0200
Message-ID: <1486650254-8976-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: w-kwok2@ti.com, m-karicheri2@ti.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The _xmit function should return netdev_tx_t type.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
Based on net-next/master

 drivers/net/ethernet/ti/netcp_core.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 7c7ae08..5845ad8 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1280,7 +1280,8 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 }
 
 /* Submit the packet */
-static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+static netdev_tx_t netcp_ndo_start_xmit(struct sk_buff *skb,
+					struct net_device *ndev)
 {
 	struct netcp_intf *netcp = netdev_priv(ndev);
 	struct netcp_stats *tx_stats = &netcp->stats;
@@ -1300,7 +1301,7 @@ static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 			dev_warn(netcp->ndev_dev, "padding failed (%d), packet dropped\n",
 				 ret);
 			tx_stats->tx_dropped++;
-			return ret;
+			return NETDEV_TX_BUSY;
 		}
 		skb->len = NETCP_MIN_PACKET_SIZE;
 	}
@@ -1329,7 +1330,7 @@ static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (desc)
 		netcp_free_tx_desc_chain(netcp, desc, sizeof(*desc));
 	dev_kfree_skb(skb);
-	return ret;
+	return NETDEV_TX_BUSY;
 }
 
 int netcp_txpipe_close(struct netcp_tx_pipe *tx_pipe)
-- 
2.7.4
