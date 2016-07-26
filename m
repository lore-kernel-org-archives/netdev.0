From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/3] virtio: whitespace cleanups
Date: Tue, 26 Jul 2016 09:20:09 -0700
Message-ID: <20160726162033.986756992@networkplumber.org>
References: <20160726162008.310530368@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33128 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756800AbcGZQUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 12:20:20 -0400
Received: by mail-pa0-f46.google.com with SMTP id ks6so1221376pab.0
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 09:20:19 -0700 (PDT)
Content-Disposition: inline; filename=virtio-style.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjust whitespace to match current favored style.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/virtio_net.c	2016-07-20 08:12:24.035656119 -0700
+++ b/drivers/net/virtio_net.c	2016-07-26 09:11:06.988788668 -0700
@@ -201,7 +201,9 @@ static void give_pages(struct receive_qu
 	struct page *end;
 
 	/* Find end of list, sew whole thing into vi->rq.pages. */
-	for (end = page; end->private; end = (struct page *)end->private);
+	for (end = page; end->private; end = (struct page *)end->private)
+		continue;
+
 	end->private = (unsigned long)rq->pages;
 	rq->pages = page;
 }
@@ -233,13 +235,13 @@ static void skb_xmit_done(struct virtque
 static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
 {
 	unsigned int truesize = mrg_ctx & (MERGEABLE_BUFFER_ALIGN - 1);
+
 	return (truesize + 1) * MERGEABLE_BUFFER_ALIGN;
 }
 
 static void *mergeable_ctx_to_buf_address(unsigned long mrg_ctx)
 {
 	return (void *)(mrg_ctx & -MERGEABLE_BUFFER_ALIGN);
-
 }
 
 static unsigned long mergeable_buf_to_ctx(void *buf, unsigned int truesize)
@@ -310,6 +312,7 @@ static struct sk_buff *page_to_skb(struc
 	BUG_ON(offset >= PAGE_SIZE);
 	while (len) {
 		unsigned int frag_size = min((unsigned)PAGE_SIZE - offset, len);
+
 		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page, offset,
 				frag_size, truesize);
 		len -= frag_size;
@@ -323,9 +326,10 @@ static struct sk_buff *page_to_skb(struc
 	return skb;
 }
 
-static struct sk_buff *receive_small(struct virtnet_info *vi, void *buf, unsigned int len)
+static struct sk_buff *receive_small(struct virtnet_info *vi,
+				     void *buf, unsigned int len)
 {
-	struct sk_buff * skb = buf;
+	struct sk_buff *skb = buf;
 
 	len -= vi->hdr_len;
 	skb_trim(skb, len);
@@ -455,6 +459,7 @@ static void receive_buf(struct virtnet_i
 		if (vi->mergeable_rx_bufs) {
 			unsigned long ctx = (unsigned long)buf;
 			void *base = mergeable_ctx_to_buf_address(ctx);
+
 			put_page(virt_to_head_page(base));
 		} else if (vi->big_packets) {
 			give_pages(rq, buf);
@@ -699,7 +704,7 @@ static void refill_work(struct work_stru
 		 * we will *never* try to fill again.
 		 */
 		if (still_empty)
-			schedule_delayed_work(&vi->refill, HZ/2);
+			schedule_delayed_work(&vi->refill, HZ / 2);
 	}
 }
 
@@ -901,12 +906,12 @@ static netdev_tx_t start_xmit(struct sk_
 	 * Since most packets only take 1 or 2 ring slots, stopping the queue
 	 * early means 16 slots are typically wasted.
 	 */
-	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
+	if (sq->vq->num_free < 2 + MAX_SKB_FRAGS) {
 		netif_stop_subqueue(dev, qnum);
 		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
 			/* More just got used, free them then recheck. */
 			free_old_xmit_skbs(sq);
-			if (sq->vq->num_free >= 2+MAX_SKB_FRAGS) {
+			if (sq->vq->num_free >= 2 + MAX_SKB_FRAGS) {
 				netif_start_subqueue(dev, qnum);
 				virtqueue_disable_cb(sq->vq);
 			}
@@ -1238,11 +1243,11 @@ static void virtnet_set_affinity(struct
 }
 
 static int virtnet_cpu_callback(struct notifier_block *nfb,
-			        unsigned long action, void *hcpu)
+				unsigned long action, void *hcpu)
 {
 	struct virtnet_info *vi = container_of(nfb, struct virtnet_info, nb);
 
-	switch(action & ~CPU_TASKS_FROZEN) {
+	switch (action & ~CPU_TASKS_FROZEN) {
 	case CPU_ONLINE:
 	case CPU_DOWN_FAILED:
 	case CPU_DEAD:
@@ -1259,7 +1264,7 @@ static int virtnet_cpu_callback(struct n
 }
 
 static void virtnet_get_ringparam(struct net_device *dev,
-				struct ethtool_ringparam *ring)
+				  struct ethtool_ringparam *ring)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
@@ -1269,7 +1274,6 @@ static void virtnet_get_ringparam(struct
 	ring->tx_pending = ring->tx_max_pending;
 }
 
-
 static void virtnet_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
@@ -1279,7 +1283,6 @@ static void virtnet_get_drvinfo(struct n
 	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
 	strlcpy(info->version, VIRTNET_DRIVER_VERSION, sizeof(info->version));
 	strlcpy(info->bus_info, virtio_bus_name(vdev), sizeof(info->bus_info));
-
 }
 
 /* TODO: Eliminate OOO packets during switching */
@@ -1402,9 +1405,9 @@ static int virtnet_change_mtu(struct net
 }
 
 static const struct net_device_ops virtnet_netdev = {
-	.ndo_open            = virtnet_open,
-	.ndo_stop   	     = virtnet_close,
-	.ndo_start_xmit      = start_xmit,
+	.ndo_open	     = virtnet_open,
+	.ndo_stop	     = virtnet_close,
+	.ndo_start_xmit	     = start_xmit,
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_set_mac_address = virtnet_set_mac_address,
 	.ndo_set_rx_mode     = virtnet_set_rx_mode,
@@ -1485,6 +1488,7 @@ static void free_receive_bufs(struct vir
 static void free_receive_page_frags(struct virtnet_info *vi)
 {
 	int i;
+
 	for (i = 0; i < vi->max_queue_pairs; i++)
 		if (vi->rq[i].alloc_frag.page)
 			put_page(vi->rq[i].alloc_frag.page);
@@ -1497,6 +1501,7 @@ static void free_unused_bufs(struct virt
 
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		struct virtqueue *vq = vi->sq[i].vq;
+
 		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL)
 			dev_kfree_skb(buf);
 	}
@@ -1508,6 +1513,7 @@ static void free_unused_bufs(struct virt
 			if (vi->mergeable_rx_bufs) {
 				unsigned long ctx = (unsigned long)buf;
 				void *base = mergeable_ctx_to_buf_address(ctx);
+
 				put_page(virt_to_head_page(base));
 			} else if (vi->big_packets) {
 				give_pages(&vi->rq[i], buf);
@@ -1660,7 +1666,8 @@ err:
 
 #ifdef CONFIG_SYSFS
 static ssize_t mergeable_rx_buffer_size_show(struct netdev_rx_queue *queue,
-		struct rx_queue_attribute *attribute, char *buf)
+					     struct rx_queue_attribute *attribute,
+					     char *buf)
 {
 	struct virtnet_info *vi = netdev_priv(queue->dev);
 	unsigned int queue_index = get_netdev_rx_queue_index(queue);
@@ -1784,7 +1791,8 @@ static int virtnet_probe(struct virtio_d
 		dev->features |= NETIF_F_GSO_ROBUST;
 
 		if (gso)
-			dev->features |= dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
+			dev->features |= dev->hw_features
+				& (NETIF_F_ALL_TSO | NETIF_F_UFO);
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
@@ -1811,8 +1819,9 @@ static int virtnet_probe(struct virtio_d
 		goto free;
 
 	for_each_possible_cpu(i) {
-		struct virtnet_stats *virtnet_stats;
-		virtnet_stats = per_cpu_ptr(vi->stats, i);
+		struct virtnet_stats *virtnet_stats
+			= per_cpu_ptr(vi->stats, i);
+
 		u64_stats_init(&virtnet_stats->tx_syncp);
 		u64_stats_init(&virtnet_stats->rx_syncp);
 	}
