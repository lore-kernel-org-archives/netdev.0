From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH -net] net/ethernet: tundra: fix dump_eth_one warning in tsi108_eth
Date: Thu, 4 Aug 2016 16:07:58 -0400
Message-ID: <20160804200758.29835-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linuxppc-dev@lists.ozlabs.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:57622 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934014AbcHDUJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 16:09:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The call site for this function appears as:

  #ifdef DEBUG
        data->msg_enable = DEBUG;
        dump_eth_one(dev);
  #endif

...leading to the following warning for !DEBUG builds:

drivers/net/ethernet/tundra/tsi108_eth.c:169:13: warning: 'dump_eth_one' defined but not used [-Wunused-function]
 static void dump_eth_one(struct net_device *dev)
             ^

...when using the arch/powerpc/configs/mpc7448_hpc2_defconfig

Put the function definition under the same #ifdef as the call site
to avoid the warning.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/tundra/tsi108_eth.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 01a77145a0fa..8fd131207ee1 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -166,6 +166,7 @@ static struct platform_driver tsi_eth_driver = {
 
 static void tsi108_timed_checker(unsigned long dev_ptr);
 
+#ifdef DEBUG
 static void dump_eth_one(struct net_device *dev)
 {
 	struct tsi108_prv_data *data = netdev_priv(dev);
@@ -190,6 +191,7 @@ static void dump_eth_one(struct net_device *dev)
 	       TSI_READ(TSI108_EC_RXESTAT),
 	       TSI_READ(TSI108_EC_RXERR), data->rxpending);
 }
+#endif
 
 /* Synchronization is needed between the thread and up/down events.
  * Note that the PHY is accessed through the same registers for both
-- 
2.8.4
