From: David Miller <davem@davemloft.net>
Subject: netdevice: Kill 'feature' test macros.
Date: Tue, 12 Jul 2011 10:50:05 -0700 (PDT)
Message-ID: <20110712.105005.34046159802896038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458Ab1GLRuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 13:50:07 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6CHo5J7031717
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 10:50:06 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Almost all of these have long outstayed their welcome.

And for every one of these macros, there are 10 features for which we
didn't get macros added.

Let's just delete them all, and get out of habit of doing things this
way.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 011eb89..30f17e4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -60,11 +60,6 @@ struct wireless_dev;
 #define SET_ETHTOOL_OPS(netdev,ops) \
 	( (netdev)->ethtool_ops = (ops) )
 
-#define HAVE_ALLOC_NETDEV		/* feature macro: alloc_xxxdev
-					   functions are available. */
-#define HAVE_FREE_NETDEV		/* free_netdev() */
-#define HAVE_NETDEV_PRIV		/* netdev_priv() */
-
 /* hardware address assignment types */
 #define NET_ADDR_PERM		0	/* address is permanent (default) */
 #define NET_ADDR_RANDOM		1	/* address is generated randomly */
@@ -313,7 +308,6 @@ struct header_ops {
 			   const void *saddr, unsigned len);
 	int	(*parse)(const struct sk_buff *skb, unsigned char *haddr);
 	int	(*rebuild)(struct sk_buff *skb);
-#define HAVE_HEADER_CACHE
 	int	(*cache)(const struct neighbour *neigh, struct hh_cache *hh);
 	void	(*cache_update)(struct hh_cache *hh,
 				const struct net_device *dev,
@@ -887,7 +881,6 @@ struct netdev_tc_txq {
  *	Must return >0 or -errno if it changed dev->features itself.
  *
  */
-#define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
 	void			(*ndo_uninit)(struct net_device *dev);
@@ -1781,8 +1774,6 @@ static inline void input_queue_tail_incr_save(struct softnet_data *sd,
 
 DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
 
-#define HAVE_NETIF_QUEUE
-
 extern void __netif_schedule(struct Qdisc *q);
 
 static inline void netif_schedule_queue(struct netdev_queue *txq)
@@ -2058,10 +2049,8 @@ extern void dev_kfree_skb_irq(struct sk_buff *skb);
  */
 extern void dev_kfree_skb_any(struct sk_buff *skb);
 
-#define HAVE_NETIF_RX 1
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
-#define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
 					struct sk_buff *skb);
@@ -2241,7 +2230,6 @@ extern void netif_device_attach(struct net_device *dev);
 /*
  * Network interface message level settings
  */
-#define HAVE_NETIF_MSG 1
 
 enum {
 	NETIF_MSG_DRV		= 0x0001,
-- 
1.7.6

