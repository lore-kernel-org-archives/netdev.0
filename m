From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netdev: remove more HAVE_ leftovers
Date: Wed, 27 Jan 2010 22:17:41 +0200
Message-ID: <20100127201741.GA4855@x200>
References: <10f740e81001260057h37f3494dvefa3a37b2e1453a5@mail.gmail.com>
 <20100126.051817.215651254.davem@davemloft.net>
 <20100126191727.GA5454@x200>
 <20100126.163256.196562963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: geert@linux-m68k.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100126.163256.196562963.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2010 at 04:32:56PM -0800, David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Tue, 26 Jan 2010 21:17:27 +0200
> 
> > On Tue, Jan 26, 2010 at 05:18:17AM -0800, David Miller wrote:
> >> Alexey, please go through at least drivers/net and look at the
> >> other stale references to these HAVE_* macros.
> > 
> > My apologies.
> > 
> > 
> > [PATCH] netdev: remove HAVE_ leftovers
> > 
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> What about HAVE_POLL_CONTROLLER and some other remaining stuff?

Ick, I thought I left some compile breakage :^)

> drivers/net/bnx2.c:#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
> drivers/net/bnx2x_main.c:#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
> drivers/net/ixgbevf/ixgbevf_main.c:#ifdef HAVE_TX_MQ
> drivers/net/ixgbevf/ixgbevf_main.c:#ifndef HAVE_NETDEV_NAPI_LIST
> drivers/net/ixgbevf/ixgbevf_main.c:#ifdef HAVE_NET_DEVICE_OPS

As for HAVE_TX_MQ and HAVE_NETDEV_NAPI_LIST, I have no clue what's going on.

[PATCH] netdev: remove more HAVE_ leftovers 

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/bnx2.c                     |    4 ++--
 drivers/net/bnx2x_main.c               |    4 ++--
 drivers/net/cassini.c                  |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c     |   18 ------------------
 drivers/net/meth.c                     |    3 ---
 drivers/staging/wlags49_h2/wl_netdev.c |    6 ------
 6 files changed, 5 insertions(+), 32 deletions(-)

--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7668,7 +7668,7 @@ bnx2_change_mtu(struct net_device *dev, int new_mtu)
 	return (bnx2_change_ring_size(bp, bp->rx_ring_size, bp->tx_ring_size));
 }
 
-#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
+#ifdef CONFIG_NET_POLL_CONTROLLER
 static void
 poll_bnx2(struct net_device *dev)
 {
@@ -8280,7 +8280,7 @@ static const struct net_device_ops bnx2_netdev_ops = {
 #ifdef BCM_VLAN
 	.ndo_vlan_rx_register	= bnx2_vlan_rx_register,
 #endif
-#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
+#ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= poll_bnx2,
 #endif
 };
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11731,7 +11731,7 @@ static void bnx2x_vlan_rx_register(struct net_device *dev,
 
 #endif
 
-#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
+#ifdef CONFIG_NET_POLL_CONTROLLER
 static void poll_bnx2x(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
@@ -11755,7 +11755,7 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 #ifdef BCM_VLAN
 	.ndo_vlan_rx_register	= bnx2x_vlan_rx_register,
 #endif
-#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
+#ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= poll_bnx2x,
 #endif
 };
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -106,7 +106,7 @@
 #define cas_page_unmap(x)    kunmap_atomic((x), KM_SKB_DATA_SOFTIRQ)
 #define CAS_NCPUS            num_online_cpus()
 
-#if defined(CONFIG_CASSINI_NAPI) && defined(HAVE_NETDEV_POLL)
+#ifdef CONFIG_CASSINI_NAPI
 #define USE_NAPI
 #define cas_skb_release(x)  netif_receive_skb(x)
 #else
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3262,7 +3262,6 @@ static void ixgbevf_shutdown(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-#ifdef HAVE_NET_DEVICE_OPS
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= &ixgbevf_open,
 	.ndo_stop		= &ixgbevf_close,
@@ -3278,29 +3277,12 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_vlan_rx_add_vid	= &ixgbevf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= &ixgbevf_vlan_rx_kill_vid,
 };
-#endif /* HAVE_NET_DEVICE_OPS */
 
 static void ixgbevf_assign_netdev_ops(struct net_device *dev)
 {
 	struct ixgbevf_adapter *adapter;
 	adapter = netdev_priv(dev);
-#ifdef HAVE_NET_DEVICE_OPS
 	dev->netdev_ops = &ixgbe_netdev_ops;
-#else /* HAVE_NET_DEVICE_OPS */
-	dev->open = &ixgbevf_open;
-	dev->stop = &ixgbevf_close;
-
-	dev->hard_start_xmit = &ixgbevf_xmit_frame;
-
-	dev->get_stats = &ixgbevf_get_stats;
-	dev->set_multicast_list = &ixgbevf_set_rx_mode;
-	dev->set_mac_address = &ixgbevf_set_mac;
-	dev->change_mtu = &ixgbevf_change_mtu;
-	dev->tx_timeout = &ixgbevf_tx_timeout;
-	dev->vlan_rx_register = &ixgbevf_vlan_rx_register;
-	dev->vlan_rx_add_vid = &ixgbevf_vlan_rx_add_vid;
-	dev->vlan_rx_kill_vid = &ixgbevf_vlan_rx_kill_vid;
-#endif /* HAVE_NET_DEVICE_OPS */
 	ixgbevf_set_ethtool_ops(dev);
 	dev->watchdog_timeo = 5 * HZ;
 }
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -51,14 +51,11 @@
 
 static const char *meth_str="SGI O2 Fast Ethernet";
 
-#define HAVE_TX_TIMEOUT
 /* The maximum time waited (in jiffies) before assuming a Tx failed. (400ms) */
 #define TX_TIMEOUT (400*HZ/1000)
 
-#ifdef HAVE_TX_TIMEOUT
 static int timeout = TX_TIMEOUT;
 module_param(timeout, int, 0);
-#endif
 
 /*
  * This structure is private to each device. It is used to pass
--- a/drivers/staging/wlags49_h2/wl_netdev.c
+++ b/drivers/staging/wlags49_h2/wl_netdev.c
@@ -1194,9 +1194,7 @@ static const struct net_device_ops wl_netdev_ops =
     .ndo_stop               = &wl_adapter_close,
     .ndo_do_ioctl           = &wl_ioctl,
 
-#ifdef HAVE_TX_TIMEOUT
     .ndo_tx_timeout         = &wl_tx_timeout,
-#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
     .ndo_poll_controller    = wl_poll,
@@ -1270,9 +1268,7 @@ struct net_device * wl_device_alloc( void )
     dev->stop               = &wl_adapter_close;
     dev->do_ioctl           = &wl_ioctl;
 
-#ifdef HAVE_TX_TIMEOUT
     dev->tx_timeout         = &wl_tx_timeout;
-#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
     dev->poll_controller = wl_poll;
@@ -1280,9 +1276,7 @@ struct net_device * wl_device_alloc( void )
 
 #endif // (LINUX_VERSION_CODE > KERNEL_VERSION(2,6,30))
 
-#ifdef HAVE_TX_TIMEOUT
     dev->watchdog_timeo     = TX_TIMEOUT;
-#endif
 
     dev->ethtool_ops	    = &wl_ethtool_ops;
 
