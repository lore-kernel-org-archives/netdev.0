From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH] net: tsi108: Prevent compiler warning
Date: Wed, 18 Sep 2013 14:49:55 +0200
Message-ID: <1379508595-30252-1-git-send-email-treding@nvidia.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dump_eth_one() function is only used if DEBUG is enabled, so protect
it by a corresponding #ifdef DEBUG block.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 drivers/net/ethernet/tundra/tsi108_eth.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index c4dbf98..a452d93 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -168,6 +168,7 @@ static struct platform_driver tsi_eth_driver = {
 
 static void tsi108_timed_checker(unsigned long dev_ptr);
 
+#ifdef DEBUG
 static void dump_eth_one(struct net_device *dev)
 {
 	struct tsi108_prv_data *data = netdev_priv(dev);
@@ -192,6 +193,7 @@ static void dump_eth_one(struct net_device *dev)
 	       TSI_READ(TSI108_EC_RXESTAT),
 	       TSI_READ(TSI108_EC_RXERR), data->rxpending);
 }
+#endif
 
 /* Synchronization is needed between the thread and up/down events.
  * Note that the PHY is accessed through the same registers for both
-- 
1.8.4
