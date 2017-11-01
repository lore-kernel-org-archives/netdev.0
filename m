From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 2/2] net: dpaa: remove init which already done in per-cpu allocation
Date: Wed,  1 Nov 2017 21:11:11 +0800
Message-ID: <1509541871-16196-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:38158 "EHLO m12-12.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750848AbdKANLj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 09:11:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 68f0ac1..969f6b1 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2669,7 +2669,6 @@ static inline u16 dpaa_get_headroom(struct dpaa_buffer_layout *bl)
 static int dpaa_eth_probe(struct platform_device *pdev)
 {
 	struct dpaa_bp *dpaa_bps[DPAA_BPS_NUM] = {NULL};
-	struct dpaa_percpu_priv *percpu_priv;
 	struct net_device *net_dev = NULL;
 	struct dpaa_fq *dpaa_fq, *tmp;
 	struct dpaa_priv *priv = NULL;
@@ -2815,10 +2814,6 @@ static int dpaa_eth_probe(struct platform_device *pdev)
 		err = -ENOMEM;
 		goto free_dpaa_fqs;
 	}
-	for_each_possible_cpu(i) {
-		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
-		memset(percpu_priv, 0, sizeof(*percpu_priv));
-	}
 
 	priv->num_tc = 1;
 	netif_set_real_num_tx_queues(net_dev, priv->num_tc * DPAA_TC_TXQ_NUM);
-- 
2.7.4
