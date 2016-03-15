From: Aaron Young <Aaron.Young@oracle.com>
Subject: [PATCH net-next v2 4/4] ldmvsw: Checkpatch sunvnet.c and sunvnet_common.c
Date: Tue, 15 Mar 2016 11:35:40 -0700
Message-ID: <2f47a2e3a586aa7de3a56288d16c79277b2ba9fe.1458006737.git.Aaron.Young@oracle.com>
References: <cover.1458006737.git.Aaron.Young@oracle.com>
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	alexandre.chartre@oracle.com, rashmi.narasimhan@oracle.com,
	aaron.young@oracle.com, atish.patra@oracle.com,
	Aaron Young <Aaron.Young@oracle.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43884 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965619AbcCOSfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 14:35:21 -0400
In-Reply-To: <cover.1458006737.git.Aaron.Young@oracle.com>
In-Reply-To: <cover.1458006737.git.Aaron.Young@oracle.com>
References: <cover.1458006737.git.Aaron.Young@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  From: Aaron Young <aaron.young@oracle.com>

  Checkpatch updates for sunvnet.c and sunvnet_common.c.

  Signed-off-by: Aaron Young <aaron.young@oracle.com>
  Signed-off-by: Rashmi Narasimhan <rashmi.narasimhan@oracle.com>
  Reviewed-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
  Reviewed-by: Alexandre Chartre <Alexandre.Chartre@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c        |    6 +-
 drivers/net/ethernet/sun/sunvnet_common.c |  100 +++++++++++++++--------------
 2 files changed, 56 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 98c5f16..a2f9b47 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -66,12 +66,14 @@ static void vnet_get_drvinfo(struct net_device *dev,
 static u32 vnet_get_msglevel(struct net_device *dev)
 {
 	struct vnet *vp = netdev_priv(dev);
+
 	return vp->msg_enable;
 }
 
 static void vnet_set_msglevel(struct net_device *dev, u32 value)
 {
 	struct vnet *vp = netdev_priv(dev);
+
 	vp->msg_enable = value;
 }
 
@@ -359,7 +361,7 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	INIT_LIST_HEAD(&port->list);
 
 	switch_port = 0;
-	if (mdesc_get_property(hp, vdev->mp, "switch-port", NULL) != NULL)
+	if (mdesc_get_property(hp, vdev->mp, "switch-port", NULL))
 		switch_port = 1;
 	port->switch_port = switch_port;
 	port->tso = true;
@@ -403,7 +405,6 @@ static int vnet_port_remove(struct vio_dev *vdev)
 	struct vnet_port *port = dev_get_drvdata(&vdev->dev);
 
 	if (port) {
-
 		del_timer_sync(&port->vio.timer);
 
 		napi_disable(&port->napi);
@@ -421,7 +422,6 @@ static int vnet_port_remove(struct vio_dev *vdev)
 		dev_set_drvdata(&vdev->dev, NULL);
 
 		kfree(port);
-
 	}
 	return 0;
 }
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 083f41c..904a5a1 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -119,7 +119,6 @@ int sunvnet_send_attr_common(struct vio_driver_state *vio)
 	       pkt.ack_freq, pkt.plnk_updt, pkt.options,
 	       (unsigned long long)pkt.mtu, pkt.cflags, pkt.ipv4_lso_maxlen);
 
-
 	return vio_ldc_send(vio, &pkt, sizeof(pkt));
 }
 EXPORT_SYMBOL_GPL(sunvnet_send_attr_common);
@@ -197,24 +196,23 @@ static int handle_attr_info(struct vio_driver_state *vio,
 
 		pkt->tag.stype = VIO_SUBTYPE_NACK;
 
-		(void) vio_ldc_send(vio, pkt, sizeof(*pkt));
+		(void)vio_ldc_send(vio, pkt, sizeof(*pkt));
 
 		return -ECONNRESET;
-	} else {
-		viodbg(HS, "SEND NET ATTR ACK xmode[0x%x] atype[0x%x] "
-		       "addr[%llx] ackfreq[%u] plnk_updt[0x%02x] opts[0x%02x] "
-		       "mtu[%llu] (rmtu[%llu]) cflags[0x%04x] lso_max[%u]\n",
-		       pkt->xfer_mode, pkt->addr_type,
-		       (unsigned long long)pkt->addr,
-		       pkt->ack_freq, pkt->plnk_updt, pkt->options,
-		       (unsigned long long)pkt->mtu, port->rmtu, pkt->cflags,
-		       pkt->ipv4_lso_maxlen);
-
-		pkt->tag.stype = VIO_SUBTYPE_ACK;
-
-		return vio_ldc_send(vio, pkt, sizeof(*pkt));
 	}
 
+	viodbg(HS, "SEND NET ATTR ACK xmode[0x%x] atype[0x%x] "
+	       "addr[%llx] ackfreq[%u] plnk_updt[0x%02x] opts[0x%02x] "
+	       "mtu[%llu] (rmtu[%llu]) cflags[0x%04x] lso_max[%u]\n",
+	       pkt->xfer_mode, pkt->addr_type,
+	       (unsigned long long)pkt->addr,
+	       pkt->ack_freq, pkt->plnk_updt, pkt->options,
+	       (unsigned long long)pkt->mtu, port->rmtu, pkt->cflags,
+	       pkt->ipv4_lso_maxlen);
+
+	pkt->tag.stype = VIO_SUBTYPE_ACK;
+
+	return vio_ldc_send(vio, pkt, sizeof(*pkt));
 }
 
 static int handle_attr_ack(struct vio_driver_state *vio,
@@ -258,10 +256,12 @@ void sunvnet_handshake_complete_common(struct vio_driver_state *vio)
 	struct vio_dring_state *dr;
 
 	dr = &vio->drings[VIO_DRIVER_RX_RING];
-	dr->snd_nxt = dr->rcv_nxt = 1;
+	dr->rcv_nxt = 1;
+	dr->snd_nxt = 1;
 
 	dr = &vio->drings[VIO_DRIVER_TX_RING];
-	dr->snd_nxt = dr->rcv_nxt = 1;
+	dr->rcv_nxt = 1;
+	dr->snd_nxt = 1;
 }
 EXPORT_SYMBOL_GPL(sunvnet_handshake_complete_common);
 
@@ -283,13 +283,14 @@ EXPORT_SYMBOL_GPL(sunvnet_handshake_complete_common);
 static struct sk_buff *alloc_and_align_skb(struct net_device *dev,
 					   unsigned int len)
 {
-	struct sk_buff *skb = netdev_alloc_skb(dev, len+VNET_PACKET_SKIP+8+8);
+	struct sk_buff *skb;
 	unsigned long addr, off;
 
+	skb = netdev_alloc_skb(dev, len + VNET_PACKET_SKIP + 8 + 8);
 	if (unlikely(!skb))
 		return NULL;
 
-	addr = (unsigned long) skb->data;
+	addr = (unsigned long)skb->data;
 	off = ((addr + 7UL) & ~7UL) - addr;
 	if (off)
 		skb_reserve(skb, off);
@@ -505,7 +506,7 @@ static int vnet_walk_rx_one(struct vnet_port *port,
 	struct vio_driver_state *vio = &port->vio;
 	int err;
 
-	BUG_ON(desc == NULL);
+	BUG_ON(!desc);
 	if (IS_ERR(desc))
 		return PTR_ERR(desc);
 
@@ -540,13 +541,14 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
 	int ack_start = -1, ack_end = -1;
 	bool send_ack = true;
 
-	end = (end == (u32) -1) ? vio_dring_prev(dr, start)
-				: vio_dring_next(dr, end);
+	end = (end == (u32)-1) ? vio_dring_prev(dr, start)
+			       : vio_dring_next(dr, end);
 
 	viodbg(DATA, "vnet_walk_rx start[%08x] end[%08x]\n", start, end);
 
 	while (start != end) {
 		int ack = 0, err = vnet_walk_rx_one(port, dr, start, &ack);
+
 		if (err == -ECONNRESET)
 			return err;
 		if (err != 0)
@@ -568,8 +570,10 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
 			break;
 		}
 	}
-	if (unlikely(ack_start == -1))
-		ack_start = ack_end = vio_dring_prev(dr, start);
+	if (unlikely(ack_start == -1)) {
+		ack_end = vio_dring_prev(dr, start);
+		ack_start = ack_end;
+	}
 	if (send_ack) {
 		port->napi_resume = false;
 		trace_vnet_tx_send_stopped_ack(port->vio._local_sid,
@@ -749,7 +753,7 @@ ldc_ctrl:
 	}
 	/* We may have multiple LDC events in rx_event. Unroll send_events() */
 	event = (port->rx_event & LDC_EVENT_UP);
-	port->rx_event &= ~(LDC_EVENT_RESET|LDC_EVENT_UP);
+	port->rx_event &= ~(LDC_EVENT_RESET | LDC_EVENT_UP);
 	if (event == LDC_EVENT_UP)
 		goto ldc_ctrl;
 	event = port->rx_event;
@@ -759,7 +763,8 @@ ldc_ctrl:
 	/* we dont expect any other bits than RESET, UP, DATA_READY */
 	BUG_ON(event != LDC_EVENT_DATA_READY);
 
-	tx_wakeup = err = 0;
+	err = 0;
+	tx_wakeup = 0;
 	while (1) {
 		union {
 			struct vio_msg_tag tag;
@@ -776,7 +781,8 @@ ldc_ctrl:
 			pkt->tag.stype = VIO_SUBTYPE_INFO;
 			pkt->tag.stype_env = VIO_DRING_DATA;
 			pkt->seq = dr->rcv_nxt;
-			pkt->start_idx = vio_dring_next(dr, port->napi_stop_idx);
+			pkt->start_idx = vio_dring_next(dr,
+							port->napi_stop_idx);
 			pkt->end_idx = -1;
 			goto napi_resume;
 		}
@@ -860,7 +866,6 @@ void sunvnet_event_common(void *arg, int event)
 	port->rx_event |= event;
 	vio_set_intr(vio->vdev->rx_ino, HV_INTR_DISABLED);
 	napi_schedule(&port->napi);
-
 }
 EXPORT_SYMBOL_GPL(sunvnet_event_common);
 
@@ -876,7 +881,7 @@ static int __vnet_tx_trigger(struct vnet_port *port, u32 start)
 		},
 		.dring_ident		= dr->ident,
 		.start_idx		= start,
-		.end_idx		= (u32) -1,
+		.end_idx		= (u32)-1,
 	};
 	int err, delay;
 	int retries = 0;
@@ -928,7 +933,7 @@ static struct sk_buff *vnet_clean_tx_ring(struct vnet_port *port,
 
 		--txi;
 		if (txi < 0)
-			txi = VNET_TX_RING_SIZE-1;
+			txi = VNET_TX_RING_SIZE - 1;
 
 		d = vio_dring_entry(dr, txi);
 
@@ -949,8 +954,9 @@ static struct sk_buff *vnet_clean_tx_ring(struct vnet_port *port,
 			ldc_unmap(port->vio.lp,
 				  port->tx_bufs[txi].cookies,
 				  port->tx_bufs[txi].ncookies);
-		} else if (d->hdr.state == VIO_DESC_FREE)
+		} else if (d->hdr.state == VIO_DESC_FREE) {
 			break;
+		}
 		d->hdr.state = VIO_DESC_FREE;
 	}
 	return skb;
@@ -1001,7 +1007,7 @@ static inline int vnet_skb_map(struct ldc_channel *lp, struct sk_buff *skb,
 	blen += VNET_PACKET_SKIP;
 	blen += 8 - (blen & 7);
 
-	err = ldc_map_single(lp, skb->data-VNET_PACKET_SKIP, blen, cookies,
+	err = ldc_map_single(lp, skb->data - VNET_PACKET_SKIP, blen, cookies,
 			     ncookies, map_perm);
 	if (err < 0)
 		return err;
@@ -1061,7 +1067,7 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
 
 		len = skb->len > ETH_ZLEN ? skb->len : ETH_ZLEN;
 		nskb = alloc_and_align_skb(skb->dev, len);
-		if (nskb == NULL) {
+		if (!nskb) {
 			dev_kfree_skb(skb);
 			return NULL;
 		}
@@ -1138,11 +1144,11 @@ static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb,
 	else if (skb->protocol == htons(ETH_P_IPV6))
 		proto = ipv6_hdr(skb)->nexthdr;
 
-	if (proto == IPPROTO_TCP)
+	if (proto == IPPROTO_TCP) {
 		hlen += tcp_hdr(skb)->doff * 4;
-	else if (proto == IPPROTO_UDP)
+	} else if (proto == IPPROTO_UDP) {
 		hlen += sizeof(struct udphdr);
-	else {
+	} else {
 		pr_err("vnet_handle_offloads GSO with unknown transport "
 		       "protocol %d tproto %d\n", skb->protocol, proto);
 		hlen = 128; /* XXX */
@@ -1195,8 +1201,9 @@ static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb,
 			skb_shinfo(curr)->gso_type = gso_type;
 			skb_shinfo(curr)->gso_segs =
 				DIV_ROUND_UP(curr->len - hlen, gso_size);
-		} else
+		} else {
 			skb_shinfo(curr)->gso_size = 0;
+		}
 
 		skb_push(curr, maclen);
 		skb_reset_mac_header(curr);
@@ -1521,14 +1528,14 @@ static void __send_mc_list(struct vnet *vp, struct vnet_port *port)
 		if (++n_addrs == VNET_NUM_MCAST) {
 			info.count = n_addrs;
 
-			(void) vio_ldc_send(&port->vio, &info,
-					    sizeof(info));
+			(void)vio_ldc_send(&port->vio, &info,
+					   sizeof(info));
 			n_addrs = 0;
 		}
 	}
 	if (n_addrs) {
 		info.count = n_addrs;
-		(void) vio_ldc_send(&port->vio, &info, sizeof(info));
+		(void)vio_ldc_send(&port->vio, &info, sizeof(info));
 	}
 
 	info.set = 0;
@@ -1546,8 +1553,8 @@ static void __send_mc_list(struct vnet *vp, struct vnet_port *port)
 		       m->addr, ETH_ALEN);
 		if (++n_addrs == VNET_NUM_MCAST) {
 			info.count = n_addrs;
-			(void) vio_ldc_send(&port->vio, &info,
-					    sizeof(info));
+			(void)vio_ldc_send(&port->vio, &info,
+					   sizeof(info));
 			n_addrs = 0;
 		}
 
@@ -1556,7 +1563,7 @@ static void __send_mc_list(struct vnet *vp, struct vnet_port *port)
 	}
 	if (n_addrs) {
 		info.count = n_addrs;
-		(void) vio_ldc_send(&port->vio, &info, sizeof(info));
+		(void)vio_ldc_send(&port->vio, &info, sizeof(info));
 	}
 }
 
@@ -1566,7 +1573,6 @@ void sunvnet_set_rx_mode_common(struct net_device *dev, struct vnet *vp)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(port, &vp->port_list, list) {
-
 		if (port->switch_port) {
 			__update_mc_list(vp, dev);
 			__send_mc_list(vp, port);
@@ -1600,7 +1606,7 @@ void sunvnet_port_free_tx_bufs_common(struct vnet_port *port)
 
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
 
-	if (dr->base == NULL)
+	if (!dr->base)
 		return;
 
 	for (i = 0; i < VNET_TX_RING_SIZE; i++) {
@@ -1668,7 +1674,8 @@ static int vnet_port_alloc_tx_ring(struct vnet_port *port)
 	dr->base = dring;
 	dr->entry_size = elen;
 	dr->num_entries = VNET_TX_RING_SIZE;
-	dr->prod = dr->cons = 0;
+	dr->prod = 0;
+	dr->cons = 0;
 	port->start_cons  = true; /* need an initial trigger */
 	dr->pending = VNET_TX_RING_SIZE;
 	dr->ncookies = ncookies;
@@ -1713,7 +1720,6 @@ void sunvnet_port_add_txq_common(struct vnet_port *port)
 	port->q_index = n;
 	netif_tx_wake_queue(netdev_get_tx_queue(VNET_PORT_TO_NET_DEVICE(port),
 						port->q_index));
-
 }
 EXPORT_SYMBOL_GPL(sunvnet_port_add_txq_common);
 
-- 
1.7.1
