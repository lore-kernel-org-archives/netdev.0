From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 1/2] net: dpaa: fix maybe uninitialized var in dpaa_open()
Date: Wed,  1 Nov 2017 21:10:32 +0800
Message-ID: <1509541832-16125-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:50061 "EHLO m12-14.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752254AbdKANK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 09:10:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index a8d0be8..68f0ac1 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2468,7 +2468,8 @@ static int dpaa_open(struct net_device *net_dev)
 	mac_dev = priv->mac_dev;
 	dpaa_eth_napi_enable(priv);
 
-	if (dpaa_phy_init(net_dev))
+	err = dpaa_phy_init(net_dev);
+	if (err)
 		goto phy_init_failed;
 
 	for (i = 0; i < ARRAY_SIZE(mac_dev->port); i++) {
-- 
2.7.4
