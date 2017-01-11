From: Keerthy <j-keerthy@ti.com>
Subject: [PATCH v2] net: netcp: correct netcp_get_stats function signature
Date: Wed, 11 Jan 2017 09:03:29 +0530
Message-ID: <1484105609-8647-1-git-send-email-j-keerthy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <stephen@networkplumber.org>, <m-scherban@ti.com>,
        <j-keerthy@ti.com>
To: <w-kwok2@ti.com>, <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit: bc1f44709cf2 - net: make ndo_get_stats64 a void function
and
Commit: 6a8162e99ef3 - net: netcp: store network statistics in 64 bits.

The commit 6a8162e99ef3 adds ndo_get_stats64 function as per old
signature which causes compilation error:

drivers/net/ethernet/ti/netcp_core.c:1951:28: error:
initialization from incompatible pointer type
  .ndo_get_stats64        = netcp_get_stats,

Hence correct netcp_get_stats function signature as per
the latest definition.

Signed-off-by: Keerthy <j-keerthy@ti.com>
Fixes: 6a8162e99ef344fc("net: netcp: store network statistics in 64 bits")
---

Changes in v2:

  * Added the static in the function definition.

This is due patches crossing at the same time.
Fixes the compilation error. Only build tested. It would be
good if someone can boot test.

Applies on top of latest next branch.

 drivers/net/ethernet/ti/netcp_core.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 68a75cc..34852f2 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1909,7 +1909,7 @@ static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	return 0;
 }
 
-static struct rtnl_link_stats64 *
+static void
 netcp_get_stats(struct net_device *ndev, struct rtnl_link_stats64 *stats)
 {
 	struct netcp_intf *netcp = netdev_priv(ndev);
@@ -1938,8 +1938,6 @@ static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	stats->rx_errors = p->rx_errors;
 	stats->rx_dropped = p->rx_dropped;
 	stats->tx_dropped = p->tx_dropped;
-
-	return stats;
 }
 
 static const struct net_device_ops netcp_netdev_ops = {
-- 
1.9.1
