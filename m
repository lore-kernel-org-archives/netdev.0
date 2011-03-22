From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] net: remove useless comments in net/core/dev.c
Date: Tue, 22 Mar 2011 19:59:47 +0800
Message-ID: <1300795189-24655-1-git-send-email-amwang@redhat.com>
Cc: WANG Cong <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code itself can explain what it is doing, no need these comments.

Signed-off-by: WANG Cong <amwang@redhat.com>

---
 net/core/dev.c |   54 ------------------------------------------------------
 1 files changed, 0 insertions(+), 54 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0b88eba..2c2f243 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1140,9 +1140,6 @@ static int __dev_open(struct net_device *dev)
 
 	ASSERT_RTNL();
 
-	/*
-	 *	Is it even present?
-	 */
 	if (!netif_device_present(dev))
 		return -ENODEV;
 
@@ -1151,9 +1148,6 @@ static int __dev_open(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	/*
-	 *	Call device private open method
-	 */
 	set_bit(__LINK_STATE_START, &dev->state);
 
 	if (ops->ndo_validate_addr)
@@ -1162,31 +1156,12 @@ static int __dev_open(struct net_device *dev)
 	if (!ret && ops->ndo_open)
 		ret = ops->ndo_open(dev);
 
-	/*
-	 *	If it went open OK then:
-	 */
-
 	if (ret)
 		clear_bit(__LINK_STATE_START, &dev->state);
 	else {
-		/*
-		 *	Set the flags.
-		 */
 		dev->flags |= IFF_UP;
-
-		/*
-		 *	Enable NET_DMA
-		 */
 		net_dmaengine_get();
-
-		/*
-		 *	Initialize multicasting status
-		 */
 		dev_set_rx_mode(dev);
-
-		/*
-		 *	Wakeup transmit queue engine
-		 */
 		dev_activate(dev);
 	}
 
@@ -1209,22 +1184,13 @@ int dev_open(struct net_device *dev)
 {
 	int ret;
 
-	/*
-	 *	Is it already up?
-	 */
 	if (dev->flags & IFF_UP)
 		return 0;
 
-	/*
-	 *	Open device
-	 */
 	ret = __dev_open(dev);
 	if (ret < 0)
 		return ret;
 
-	/*
-	 *	... and announce new interface.
-	 */
 	rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
 	call_netdevice_notifiers(NETDEV_UP, dev);
 
@@ -1240,10 +1206,6 @@ static int __dev_close_many(struct list_head *head)
 	might_sleep();
 
 	list_for_each_entry(dev, head, unreg_list) {
-		/*
-		 *	Tell people we are going down, so that they can
-		 *	prepare to death, when device is still operating.
-		 */
 		call_netdevice_notifiers(NETDEV_GOING_DOWN, dev);
 
 		clear_bit(__LINK_STATE_START, &dev->state);
@@ -1272,15 +1234,7 @@ static int __dev_close_many(struct list_head *head)
 		if (ops->ndo_stop)
 			ops->ndo_stop(dev);
 
-		/*
-		 *	Device is now down.
-		 */
-
 		dev->flags &= ~IFF_UP;
-
-		/*
-		 *	Shutdown NET_DMA
-		 */
 		net_dmaengine_put();
 	}
 
@@ -1309,9 +1263,6 @@ static int dev_close_many(struct list_head *head)
 
 	__dev_close_many(head);
 
-	/*
-	 * Tell people we are down
-	 */
 	list_for_each_entry(dev, head, unreg_list) {
 		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
 		call_netdevice_notifiers(NETDEV_DOWN, dev);
@@ -1368,11 +1319,6 @@ EXPORT_SYMBOL(dev_disable_lro);
 
 static int dev_boot_phase = 1;
 
-/*
- *	Device change register/unregister. These are not inline or static
- *	as we export them to the world.
- */
-
 /**
  *	register_netdevice_notifier - register a network notifier block
  *	@nb: notifier
