From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next] openvswitch: Use eth_mac_addr() instead
 of duplicating it
Date: Mon, 3 Dec 2012 22:17:32 +0000
Message-ID: <20121203221732.GA14494@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org


bonus: if we ever are to use IFF_LIVE_ADDR_CHANGE for
anything further than to check availability in eth_mac_addr(),
Open vSwitch will be ready for that.

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
---
 net/openvswitch/vport-internal_dev.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 5d460c3..90816c7 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -63,17 +63,6 @@ static struct rtnl_link_stats64 *internal_dev_get_stats(struct net_device *netde
 	return stats;
 }
 
-static int internal_dev_mac_addr(struct net_device *dev, void *p)
-{
-	struct sockaddr *addr = p;
-
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
-	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
-	return 0;
-}
-
 /* Called with rcu_read_lock_bh. */
 static int internal_dev_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
@@ -127,7 +116,7 @@ static const struct net_device_ops internal_dev_netdev_ops = {
 	.ndo_open = internal_dev_open,
 	.ndo_stop = internal_dev_stop,
 	.ndo_start_xmit = internal_dev_xmit,
-	.ndo_set_mac_address = internal_dev_mac_addr,
+	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_change_mtu = internal_dev_change_mtu,
 	.ndo_get_stats64 = internal_dev_get_stats,
 };
@@ -139,6 +128,7 @@ static void do_setup(struct net_device *netdev)
 	netdev->netdev_ops = &internal_dev_netdev_ops;
 
 	netdev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 	netdev->destructor = internal_dev_destructor;
 	SET_ETHTOOL_OPS(netdev, &internal_dev_ethtool_ops);
 	netdev->tx_queue_len = 0;
