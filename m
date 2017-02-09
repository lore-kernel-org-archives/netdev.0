From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 4/4] net: Fix checkpatch, Missing a blank line after declarations
Date: Thu,  9 Feb 2017 17:56:07 +1100
Message-ID: <1486623367-28861-5-git-send-email-me@tobin.cc>
References: <1486623367-28861-1-git-send-email-me@tobin.cc>
Cc: Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        stephen hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Tobin C. Harding" <me@tobin.cc>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486623367-28861-1-git-send-email-me@tobin.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes multiple occurrences of checkpatch WARNING: Missing
a blank line after declarations.

Signed-off-by: Tobin C. Harding <me@tobin.cc>
---
 net/core/dev.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6a076a1..fa63485 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2520,6 +2520,7 @@ u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
 
 	if (dev->num_tc) {
 		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
+
 		qoffset = dev->tc_to_txq[tc].offset;
 		qcount = dev->tc_to_txq[tc].count;
 	}
@@ -2734,9 +2735,11 @@ static int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_HIGHMEM
 	int i;
+
 	if (!(dev->features & NETIF_F_HIGHDMA)) {
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
 			if (PageHighMem(skb_frag_page(frag)))
 				return 1;
 		}
@@ -2750,6 +2753,7 @@ static int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 			dma_addr_t addr = page_to_phys(skb_frag_page(frag));
+
 			if (!pdev->dma_mask || addr + PAGE_SIZE - 1 > *pdev->dma_mask)
 				return 1;
 		}
@@ -3227,6 +3231,7 @@ static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
 	if (queue_index < 0 || skb->ooo_okay ||
 	    queue_index >= dev->real_num_tx_queues) {
 		int new_index = get_xps_queue(dev, skb);
+
 		if (new_index < 0)
 			new_index = skb_tx_hash(dev, skb);
 
@@ -3256,6 +3261,7 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 
 	if (dev->real_num_tx_queues != 1) {
 		const struct net_device_ops *ops = dev->netdev_ops;
+
 		if (ops->ndo_select_queue)
 			queue_index = ops->ndo_select_queue(dev, skb, accel_priv,
 							    __netdev_pick_tx);
@@ -3781,6 +3787,7 @@ static int netif_rx_internal(struct sk_buff *skb)
 #endif
 	{
 		unsigned int qtail;
+
 		ret = enqueue_to_backlog(skb, get_cpu(), &qtail);
 		put_cpu();
 	}
@@ -3840,6 +3847,7 @@ static __latent_entropy void net_tx_action(struct softirq_action *h)
 
 		while (clist) {
 			struct sk_buff *skb = clist;
+
 			clist = clist->next;
 
 			WARN_ON(atomic_read(&skb->users));
@@ -5708,6 +5716,7 @@ static int netdev_adjacent_sysfs_add(struct net_device *dev,
 			      struct list_head *dev_list)
 {
 	char linkname[IFNAMSIZ+7];
+
 	sprintf(linkname, dev_list == &dev->adj_list.upper ?
 		"upper_%s" : "lower_%s", adj_dev->name);
 	return sysfs_create_link(&(dev->dev.kobj), &(adj_dev->dev.kobj),
@@ -5718,6 +5727,7 @@ static void netdev_adjacent_sysfs_del(struct net_device *dev,
 			       struct list_head *dev_list)
 {
 	char linkname[IFNAMSIZ+7];
+
 	sprintf(linkname, dev_list == &dev->adj_list.upper ?
 		"upper_%s" : "lower_%s", name);
 	sysfs_remove_link(&(dev->dev.kobj), linkname);
@@ -5987,6 +5997,7 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 			     struct net_device *upper_dev)
 {
 	struct netdev_notifier_changeupper_info changeupper_info;
+
 	ASSERT_RTNL();
 
 	changeupper_info.upper_dev = upper_dev;
@@ -6748,6 +6759,7 @@ EXPORT_SYMBOL(dev_change_xdp_fd);
 static int dev_new_index(struct net *net)
 {
 	int ifindex = net->ifindex;
+
 	for (;;) {
 		if (++ifindex <= 0)
 			ifindex = 1;
@@ -7168,6 +7180,7 @@ void netif_tx_stop_all_queues(struct net_device *dev)
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+
 		netif_tx_stop_queue(txq);
 	}
 }
-- 
2.7.4
