From: Changli Gao <xiaosuo@gmail.com>
Subject: [RFC] net-next: remove useless union keyword
Date: Mon,  3 May 2010 05:53:26 +0800
Message-ID: <1272837206-13223-1-git-send-email-xiaosuo@gmail.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36699 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757042Ab0ECGp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 02:45:26 -0400
Received: by pva4 with SMTP id 4so370957pva.19
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 23:45:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove useless union keyword in rtable, rt6_info and dn_route.

Since there is only one member in a union, the union keyword isn't useful.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 drivers/infiniband/core/addr.c          |    2 
 drivers/infiniband/hw/cxgb3/iwch_cm.c   |    4 
 drivers/infiniband/hw/nes/nes_cm.c      |    2 
 drivers/net/bonding/bond_main.c         |    6 
 drivers/net/cnic.c                      |    2 
 drivers/scsi/cxgb3i/cxgb3i_offload.c    |    4 
 include/net/dn_route.h                  |    4 
 include/net/ip6_fib.h                   |   10 
 include/net/ipip.h                      |    2 
 include/net/route.h                     |    6 
 net/atm/clip.c                          |    2 
 net/bridge/br_device.c                  |    2 
 net/bridge/br_netfilter.c               |   20 -
 net/dccp/ipv4.c                         |    4 
 net/decnet/dn_route.c                   |  158 ++++++------
 net/ipv4/af_inet.c                      |    4 
 net/ipv4/arp.c                          |   12 
 net/ipv4/datagram.c                     |    2 
 net/ipv4/icmp.c                         |   18 -
 net/ipv4/igmp.c                         |   10 
 net/ipv4/inet_connection_sock.c         |    2 
 net/ipv4/ip_forward.c                   |   10 
 net/ipv4/ip_gre.c                       |   14 -
 net/ipv4/ip_input.c                     |    4 
 net/ipv4/ip_options.c                   |    2 
 net/ipv4/ip_output.c                    |   60 ++--
 net/ipv4/ipip.c                         |    8 
 net/ipv4/ipmr.c                         |    8 
 net/ipv4/netfilter.c                    |    8 
 net/ipv4/raw.c                          |   16 -
 net/ipv4/route.c                        |  416 ++++++++++++++++----------------
 net/ipv4/syncookies.c                   |    6 
 net/ipv4/tcp_ipv4.c                     |    2 
 net/ipv4/udp.c                          |    4 
 net/ipv4/xfrm4_policy.c                 |    2 
 net/ipv6/addrconf.c                     |   10 
 net/ipv6/anycast.c                      |    6 
 net/ipv6/fib6_rules.c                   |   10 
 net/ipv6/ip6_fib.c                      |   30 +-
 net/ipv6/ip6_output.c                   |   38 +-
 net/ipv6/ip6_tunnel.c                   |    8 
 net/ipv6/mcast.c                        |    4 
 net/ipv6/ndisc.c                        |    8 
 net/ipv6/raw.c                          |   12 
 net/ipv6/route.c                        |  246 +++++++++---------
 net/ipv6/sit.c                          |    8 
 net/l2tp/l2tp_ip.c                      |    6 
 net/netfilter/ipvs/ip_vs_xmit.c         |   86 +++---
 net/netfilter/nf_conntrack_h323_main.c  |   12 
 net/netfilter/nf_conntrack_netbios_ns.c |    2 
 net/netfilter/xt_TCPMSS.c               |    4 
 net/rxrpc/ar-peer.c                     |    4 
 net/sctp/protocol.c                     |    4 
 53 files changed, 664 insertions(+), 670 deletions(-)
diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 0b926e4..a5ea1bc 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -215,7 +215,7 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 
 	neigh = neigh_lookup(&arp_tbl, &rt->rt_gateway, rt->idev->dev);
 	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
-		neigh_event_send(rt->u.dst.neighbour, NULL);
+		neigh_event_send(rt->dst.neighbour, NULL);
 		ret = -ENODATA;
 		if (neigh)
 			goto release;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 4fef032..b3ab07e 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1388,7 +1388,7 @@ static int pass_accept_req(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 		       __func__);
 		goto reject;
 	}
-	dst = &rt->u.dst;
+	dst = &rt->dst;
 	l2t = t3_l2t_get(tdev, dst->neighbour, dst->neighbour->dev);
 	if (!l2t) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
@@ -1956,7 +1956,7 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 		err = -EHOSTUNREACH;
 		goto fail3;
 	}
-	ep->dst = &rt->u.dst;
+	ep->dst = &rt->dst;
 
 	/* get a l2t entry */
 	ep->l2t = t3_l2t_get(ep->com.tdev, ep->dst->neighbour,
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 986d6f3..d876d04 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1146,7 +1146,7 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 	}
 
 	if ((neigh == NULL) || (!(neigh->nud_state & NUD_VALID)))
-		neigh_event_send(rt->u.dst.neighbour, NULL);
+		neigh_event_send(rt->dst.neighbour, NULL);
 
 	ip_rt_put(rt);
 	return rc;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 85e813c..cc50969 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2464,7 +2464,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		/*
 		 * This target is not on a VLAN
 		 */
-		if (rt->u.dst.dev == bond->dev) {
+		if (rt->dst.dev == bond->dev) {
 			ip_rt_put(rt);
 			pr_debug("basa: rtdev == bond->dev: arp_send\n");
 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
@@ -2475,7 +2475,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		vlan_id = 0;
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
-			if (vlan_dev == rt->u.dst.dev) {
+			if (vlan_dev == rt->dst.dev) {
 				vlan_id = vlan->vlan_id;
 				pr_debug("basa: vlan match on %s %d\n",
 				       vlan_dev->name, vlan_id);
@@ -2493,7 +2493,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		if (net_ratelimit()) {
 			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
 				   bond->dev->name, &fl.fl4_dst,
-				   rt->u.dst.dev ? rt->u.dst.dev->name : "NULL");
+				   rt->dst.dev ? rt->dst.dev->name : "NULL");
 		}
 		ip_rt_put(rt);
 	}
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 4b451a7..691160f 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2787,7 +2787,7 @@ static int cnic_get_v4_route(struct sockaddr_in *dst_addr,
 
 	err = ip_route_output_key(&init_net, &rt, &fl);
 	if (!err)
-		*dst = &rt->u.dst;
+		*dst = &rt->dst;
 	return err;
 #else
 	return -ENETUNREACH;
diff --git a/drivers/scsi/cxgb3i/cxgb3i_offload.c b/drivers/scsi/cxgb3i/cxgb3i_offload.c
index a175be9..3b6a06e 100644
--- a/drivers/scsi/cxgb3i/cxgb3i_offload.c
+++ b/drivers/scsi/cxgb3i/cxgb3i_offload.c
@@ -1587,7 +1587,7 @@ cxgb3i_find_dev(struct net_device *dev, __be32 ipaddr)
 
 	err = ip_route_output_key(dev ? dev_net(dev) : &init_net, &rt, &fl);
 	if (!err)
-		return (&rt->u.dst)->dev;
+		return (&rt->dst)->dev;
 
 	return NULL;
 }
@@ -1649,7 +1649,7 @@ int cxgb3i_c3cn_connect(struct net_device *dev, struct s3_conn *c3cn,
 		c3cn->saddr.sin_addr.s_addr = rt->rt_src;
 
 	/* now commit destination to connection */
-	c3cn->dst_cache = &rt->u.dst;
+	c3cn->dst_cache = &rt->dst;
 
 	/* try to establish an offloaded connection */
 	dev = cxgb3_egress_dev(c3cn->dst_cache->dev, c3cn, 0);
diff --git a/include/net/dn_route.h b/include/net/dn_route.h
index 60c9f22..ccadab3 100644
--- a/include/net/dn_route.h
+++ b/include/net/dn_route.h
@@ -65,9 +65,7 @@ extern void dn_rt_cache_flush(int delay);
  * packets to the originating host.
  */
 struct dn_route {
-	union {
-		struct dst_entry dst;
-	} u;
+	struct dst_entry dst;
 
 	struct flowi fl;
 
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 4b1dc11..062a823 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -84,13 +84,11 @@ struct rt6key {
 struct fib6_table;
 
 struct rt6_info {
-	union {
-		struct dst_entry	dst;
-	} u;
+	struct dst_entry		dst;
 
-#define rt6i_dev			u.dst.dev
-#define rt6i_nexthop			u.dst.neighbour
-#define rt6i_expires			u.dst.expires
+#define rt6i_dev			dst.dev
+#define rt6i_nexthop			dst.neighbour
+#define rt6i_expires			dst.expires
 
 	/*
 	 * Tail elements of dst_entry (__refcnt etc.)
diff --git a/include/net/ipip.h b/include/net/ipip.h
index 11e8513..65caea8 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -50,7 +50,7 @@ struct ip_tunnel_prl_entry {
 	int pkt_len = skb->len - skb_transport_offset(skb);		\
 									\
 	skb->ip_summed = CHECKSUM_NONE;					\
-	ip_select_ident(iph, &rt->u.dst, NULL);				\
+	ip_select_ident(iph, &rt->dst, NULL);				\
 									\
 	err = ip_local_out(skb);					\
 	if (likely(net_xmit_eval(err) == 0)) {				\
diff --git a/include/net/route.h b/include/net/route.h
index 2c9fba7..09a88f7 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -50,9 +50,7 @@
 struct fib_nh;
 struct inet_peer;
 struct rtable {
-	union {
-		struct dst_entry	dst;
-	} u;
+	struct dst_entry	dst;
 
 	/* Cache lookup keys */
 	struct flowi		fl;
@@ -129,7 +127,7 @@ extern void fib_add_ifaddr(struct in_ifaddr *);
 static inline void ip_rt_put(struct rtable * rt)
 {
 	if (rt)
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 }
 
 #define IPTOS_RT_MASK	(IPTOS_TOS_MASK & ~3)
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 313aba1..95fdd11 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -522,7 +522,7 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 	error = ip_route_output_key(&init_net, &rt, &fl);
 	if (error)
 		return error;
-	neigh = __neigh_lookup(&clip_tbl, &ip, rt->u.dst.dev, 1);
+	neigh = __neigh_lookup(&clip_tbl, &ip, rt->dst.dev, 1);
 	ip_rt_put(rt);
 	if (!neigh)
 		return -ENOMEM;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 8259940..ea95fc0 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -117,7 +117,7 @@ static int br_change_mtu(struct net_device *dev, int new_mtu)
 
 #ifdef CONFIG_BRIDGE_NETFILTER
 	/* remember the MTU in the rtable for PMTU */
-	br->fake_rtable.u.dst.metrics[RTAX_MTU - 1] = new_mtu;
+	br->fake_rtable.dst.metrics[RTAX_MTU - 1] = new_mtu;
 #endif
 
 	return 0;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4c4977d..badd4f2 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -124,12 +124,12 @@ void br_netfilter_rtable_init(struct net_bridge *br)
 {
 	struct rtable *rt = &br->fake_rtable;
 
-	atomic_set(&rt->u.dst.__refcnt, 1);
-	rt->u.dst.dev = br->dev;
-	rt->u.dst.path = &rt->u.dst;
-	rt->u.dst.metrics[RTAX_MTU - 1] = 1500;
-	rt->u.dst.flags	= DST_NOXFRM;
-	rt->u.dst.ops = &fake_dst_ops;
+	atomic_set(&rt->dst.__refcnt, 1);
+	rt->dst.dev = br->dev;
+	rt->dst.path = &rt->dst;
+	rt->dst.metrics[RTAX_MTU - 1] = 1500;
+	rt->dst.flags	= DST_NOXFRM;
+	rt->dst.ops = &fake_dst_ops;
 }
 
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
@@ -242,8 +242,8 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 		kfree_skb(skb);
 		return 0;
 	}
-	dst_hold(&rt->u.dst);
-	skb_dst_set(skb, &rt->u.dst);
+	dst_hold(&rt->dst);
+	skb_dst_set(skb, &rt->dst);
 
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_push_encap_header(skb);
@@ -412,8 +412,8 @@ bridged_dnat:
 			kfree_skb(skb);
 			return 0;
 		}
-		dst_hold(&rt->u.dst);
-		skb_dst_set(skb, &rt->u.dst);
+		dst_hold(&rt->dst);
+		skb_dst_set(skb, &rt->dst);
 	}
 
 	skb->dev = nf_bridge->physindev;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index d9b11ef..d4a166f 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -105,7 +105,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		goto failure;
 
 	/* OK, now commit destination to socket.  */
-	sk_setup_caps(sk, &rt->u.dst);
+	sk_setup_caps(sk, &rt->dst);
 
 	dp->dccps_iss = secure_dccp_sequence_number(inet->inet_saddr,
 						    inet->inet_daddr,
@@ -475,7 +475,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 		return NULL;
 	}
 
-	return &rt->u.dst;
+	return &rt->dst;
 }
 
 static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 70ebe74..53e777d 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -146,13 +146,13 @@ static __inline__ unsigned dn_hash(__le16 src, __le16 dst)
 
 static inline void dnrt_free(struct dn_route *rt)
 {
-	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
+	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
 }
 
 static inline void dnrt_drop(struct dn_route *rt)
 {
-	dst_release(&rt->u.dst);
-	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
+	dst_release(&rt->dst);
+	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
 }
 
 static void dn_dst_check_expire(unsigned long dummy)
@@ -167,13 +167,13 @@ static void dn_dst_check_expire(unsigned long dummy)
 
 		spin_lock(&dn_rt_hash_table[i].lock);
 		while((rt=*rtp) != NULL) {
-			if (atomic_read(&rt->u.dst.__refcnt) ||
-					(now - rt->u.dst.lastuse) < expire) {
-				rtp = &rt->u.dst.dn_next;
+			if (atomic_read(&rt->dst.__refcnt) ||
+					(now - rt->dst.lastuse) < expire) {
+				rtp = &rt->dst.dn_next;
 				continue;
 			}
-			*rtp = rt->u.dst.dn_next;
-			rt->u.dst.dn_next = NULL;
+			*rtp = rt->dst.dn_next;
+			rt->dst.dn_next = NULL;
 			dnrt_free(rt);
 		}
 		spin_unlock(&dn_rt_hash_table[i].lock);
@@ -198,13 +198,13 @@ static int dn_dst_gc(struct dst_ops *ops)
 		rtp = &dn_rt_hash_table[i].chain;
 
 		while((rt=*rtp) != NULL) {
-			if (atomic_read(&rt->u.dst.__refcnt) ||
-					(now - rt->u.dst.lastuse) < expire) {
-				rtp = &rt->u.dst.dn_next;
+			if (atomic_read(&rt->dst.__refcnt) ||
+					(now - rt->dst.lastuse) < expire) {
+				rtp = &rt->dst.dn_next;
 				continue;
 			}
-			*rtp = rt->u.dst.dn_next;
-			rt->u.dst.dn_next = NULL;
+			*rtp = rt->dst.dn_next;
+			rt->dst.dn_next = NULL;
 			dnrt_drop(rt);
 			break;
 		}
@@ -288,25 +288,25 @@ static int dn_insert_route(struct dn_route *rt, unsigned hash, struct dn_route *
 	while((rth = *rthp) != NULL) {
 		if (compare_keys(&rth->fl, &rt->fl)) {
 			/* Put it first */
-			*rthp = rth->u.dst.dn_next;
-			rcu_assign_pointer(rth->u.dst.dn_next,
+			*rthp = rth->dst.dn_next;
+			rcu_assign_pointer(rth->dst.dn_next,
 					   dn_rt_hash_table[hash].chain);
 			rcu_assign_pointer(dn_rt_hash_table[hash].chain, rth);
 
-			dst_use(&rth->u.dst, now);
+			dst_use(&rth->dst, now);
 			spin_unlock_bh(&dn_rt_hash_table[hash].lock);
 
 			dnrt_drop(rt);
 			*rp = rth;
 			return 0;
 		}
-		rthp = &rth->u.dst.dn_next;
+		rthp = &rth->dst.dn_next;
 	}
 
-	rcu_assign_pointer(rt->u.dst.dn_next, dn_rt_hash_table[hash].chain);
+	rcu_assign_pointer(rt->dst.dn_next, dn_rt_hash_table[hash].chain);
 	rcu_assign_pointer(dn_rt_hash_table[hash].chain, rt);
 
-	dst_use(&rt->u.dst, now);
+	dst_use(&rt->dst, now);
 	spin_unlock_bh(&dn_rt_hash_table[hash].lock);
 	*rp = rt;
 	return 0;
@@ -324,8 +324,8 @@ static void dn_run_flush(unsigned long dummy)
 			goto nothing_to_declare;
 
 		for(; rt; rt=next) {
-			next = rt->u.dst.dn_next;
-			rt->u.dst.dn_next = NULL;
+			next = rt->dst.dn_next;
+			rt->dst.dn_next = NULL;
 			dst_free((struct dst_entry *)rt);
 		}
 
@@ -733,7 +733,7 @@ static int dn_forward(struct sk_buff *skb)
 	/* Ensure that we have enough space for headers */
 	rt = (struct dn_route *)skb_dst(skb);
 	header_len = dn_db->use_long ? 21 : 6;
-	if (skb_cow(skb, LL_RESERVED_SPACE(rt->u.dst.dev)+header_len))
+	if (skb_cow(skb, LL_RESERVED_SPACE(rt->dst.dev)+header_len))
 		goto drop;
 
 	/*
@@ -742,7 +742,7 @@ static int dn_forward(struct sk_buff *skb)
 	if (++cb->hops > 30)
 		goto drop;
 
-	skb->dev = rt->u.dst.dev;
+	skb->dev = rt->dst.dev;
 
 	/*
 	 * If packet goes out same interface it came in on, then set
@@ -781,7 +781,7 @@ static int dn_rt_bug(struct sk_buff *skb)
 static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 {
 	struct dn_fib_info *fi = res->fi;
-	struct net_device *dev = rt->u.dst.dev;
+	struct net_device *dev = rt->dst.dev;
 	struct neighbour *n;
 	unsigned mss;
 
@@ -789,25 +789,25 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 		if (DN_FIB_RES_GW(*res) &&
 		    DN_FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = DN_FIB_RES_GW(*res);
-		memcpy(rt->u.dst.metrics, fi->fib_metrics,
-		       sizeof(rt->u.dst.metrics));
+		memcpy(rt->dst.metrics, fi->fib_metrics,
+		       sizeof(rt->dst.metrics));
 	}
 	rt->rt_type = res->type;
 
-	if (dev != NULL && rt->u.dst.neighbour == NULL) {
+	if (dev != NULL && rt->dst.neighbour == NULL) {
 		n = __neigh_lookup_errno(&dn_neigh_table, &rt->rt_gateway, dev);
 		if (IS_ERR(n))
 			return PTR_ERR(n);
-		rt->u.dst.neighbour = n;
+		rt->dst.neighbour = n;
 	}
 
-	if (dst_metric(&rt->u.dst, RTAX_MTU) == 0 ||
-	    dst_metric(&rt->u.dst, RTAX_MTU) > rt->u.dst.dev->mtu)
-		rt->u.dst.metrics[RTAX_MTU-1] = rt->u.dst.dev->mtu;
-	mss = dn_mss_from_pmtu(dev, dst_mtu(&rt->u.dst));
-	if (dst_metric(&rt->u.dst, RTAX_ADVMSS) == 0 ||
-	    dst_metric(&rt->u.dst, RTAX_ADVMSS) > mss)
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = mss;
+	if (dst_metric(&rt->dst, RTAX_MTU) == 0 ||
+	    dst_metric(&rt->dst, RTAX_MTU) > rt->dst.dev->mtu)
+		rt->dst.metrics[RTAX_MTU-1] = rt->dst.dev->mtu;
+	mss = dn_mss_from_pmtu(dev, dst_mtu(&rt->dst));
+	if (dst_metric(&rt->dst, RTAX_ADVMSS) == 0 ||
+	    dst_metric(&rt->dst, RTAX_ADVMSS) > mss)
+		rt->dst.metrics[RTAX_ADVMSS-1] = mss;
 	return 0;
 }
 
@@ -1085,8 +1085,8 @@ make_route:
 	if (rt == NULL)
 		goto e_nobufs;
 
-	atomic_set(&rt->u.dst.__refcnt, 1);
-	rt->u.dst.flags   = DST_HOST;
+	atomic_set(&rt->dst.__refcnt, 1);
+	rt->dst.flags   = DST_HOST;
 
 	rt->fl.fld_src    = oldflp->fld_src;
 	rt->fl.fld_dst    = oldflp->fld_dst;
@@ -1102,17 +1102,17 @@ make_route:
 	rt->rt_dst_map    = fl.fld_dst;
 	rt->rt_src_map    = fl.fld_src;
 
-	rt->u.dst.dev = dev_out;
+	rt->dst.dev = dev_out;
 	dev_hold(dev_out);
-	rt->u.dst.neighbour = neigh;
+	rt->dst.neighbour = neigh;
 	neigh = NULL;
 
-	rt->u.dst.lastuse = jiffies;
-	rt->u.dst.output  = dn_output;
-	rt->u.dst.input   = dn_rt_bug;
+	rt->dst.lastuse = jiffies;
+	rt->dst.output  = dn_output;
+	rt->dst.input   = dn_rt_bug;
 	rt->rt_flags      = flags;
 	if (flags & RTCF_LOCAL)
-		rt->u.dst.input = dn_nsp_rx;
+		rt->dst.input = dn_nsp_rx;
 
 	err = dn_rt_set_next_hop(rt, &res);
 	if (err)
@@ -1141,7 +1141,7 @@ e_nobufs:
 	err = -ENOBUFS;
 	goto done;
 e_neighbour:
-	dst_free(&rt->u.dst);
+	dst_free(&rt->dst);
 	goto e_nobufs;
 }
 
@@ -1157,15 +1157,15 @@ static int __dn_route_output_key(struct dst_entry **pprt, const struct flowi *fl
 	if (!(flags & MSG_TRYHARD)) {
 		rcu_read_lock_bh();
 		for (rt = rcu_dereference_bh(dn_rt_hash_table[hash].chain); rt;
-			rt = rcu_dereference_bh(rt->u.dst.dn_next)) {
+			rt = rcu_dereference_bh(rt->dst.dn_next)) {
 			if ((flp->fld_dst == rt->fl.fld_dst) &&
 			    (flp->fld_src == rt->fl.fld_src) &&
 			    (flp->mark == rt->fl.mark) &&
 			    (rt->fl.iif == 0) &&
 			    (rt->fl.oif == flp->oif)) {
-				dst_use(&rt->u.dst, jiffies);
+				dst_use(&rt->dst, jiffies);
 				rcu_read_unlock_bh();
-				*pprt = &rt->u.dst;
+				*pprt = &rt->dst;
 				return 0;
 			}
 		}
@@ -1364,29 +1364,29 @@ make_route:
 	rt->fl.iif        = in_dev->ifindex;
 	rt->fl.mark       = fl.mark;
 
-	rt->u.dst.flags = DST_HOST;
-	rt->u.dst.neighbour = neigh;
-	rt->u.dst.dev = out_dev;
-	rt->u.dst.lastuse = jiffies;
-	rt->u.dst.output = dn_rt_bug;
+	rt->dst.flags = DST_HOST;
+	rt->dst.neighbour = neigh;
+	rt->dst.dev = out_dev;
+	rt->dst.lastuse = jiffies;
+	rt->dst.output = dn_rt_bug;
 	switch(res.type) {
 		case RTN_UNICAST:
-			rt->u.dst.input = dn_forward;
+			rt->dst.input = dn_forward;
 			break;
 		case RTN_LOCAL:
-			rt->u.dst.output = dn_output;
-			rt->u.dst.input = dn_nsp_rx;
-			rt->u.dst.dev = in_dev;
+			rt->dst.output = dn_output;
+			rt->dst.input = dn_nsp_rx;
+			rt->dst.dev = in_dev;
 			flags |= RTCF_LOCAL;
 			break;
 		default:
 		case RTN_UNREACHABLE:
 		case RTN_BLACKHOLE:
-			rt->u.dst.input = dst_discard;
+			rt->dst.input = dst_discard;
 	}
 	rt->rt_flags = flags;
-	if (rt->u.dst.dev)
-		dev_hold(rt->u.dst.dev);
+	if (rt->dst.dev)
+		dev_hold(rt->dst.dev);
 
 	err = dn_rt_set_next_hop(rt, &res);
 	if (err)
@@ -1394,7 +1394,7 @@ make_route:
 
 	hash = dn_hash(rt->fl.fld_src, rt->fl.fld_dst);
 	dn_insert_route(rt, hash, &rt);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 done:
 	if (neigh)
@@ -1416,7 +1416,7 @@ e_nobufs:
 	goto done;
 
 e_neighbour:
-	dst_free(&rt->u.dst);
+	dst_free(&rt->dst);
 	goto done;
 }
 
@@ -1431,13 +1431,13 @@ static int dn_route_input(struct sk_buff *skb)
 
 	rcu_read_lock();
 	for(rt = rcu_dereference(dn_rt_hash_table[hash].chain); rt != NULL;
-	    rt = rcu_dereference(rt->u.dst.dn_next)) {
+	    rt = rcu_dereference(rt->dst.dn_next)) {
 		if ((rt->fl.fld_src == cb->src) &&
 		    (rt->fl.fld_dst == cb->dst) &&
 		    (rt->fl.oif == 0) &&
 		    (rt->fl.mark == skb->mark) &&
 		    (rt->fl.iif == cb->iif)) {
-			dst_use(&rt->u.dst, jiffies);
+			dst_use(&rt->dst, jiffies);
 			rcu_read_unlock();
 			skb_dst_set(skb, (struct dst_entry *)rt);
 			return 0;
@@ -1476,8 +1476,8 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 		r->rtm_src_len = 16;
 		RTA_PUT(skb, RTA_SRC, 2, &rt->fl.fld_src);
 	}
-	if (rt->u.dst.dev)
-		RTA_PUT(skb, RTA_OIF, sizeof(int), &rt->u.dst.dev->ifindex);
+	if (rt->dst.dev)
+		RTA_PUT(skb, RTA_OIF, sizeof(int), &rt->dst.dev->ifindex);
 	/*
 	 * Note to self - change this if input routes reverse direction when
 	 * they deal only with inputs and not with replies like they do
@@ -1486,11 +1486,11 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	RTA_PUT(skb, RTA_PREFSRC, 2, &rt->rt_local_src);
 	if (rt->rt_daddr != rt->rt_gateway)
 		RTA_PUT(skb, RTA_GATEWAY, 2, &rt->rt_gateway);
-	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
+	if (rtnetlink_put_metrics(skb, rt->dst.metrics) < 0)
 		goto rtattr_failure;
-	expires = rt->u.dst.expires ? rt->u.dst.expires - jiffies : 0;
-	if (rtnl_put_cacheinfo(skb, &rt->u.dst, 0, 0, 0, expires,
-			       rt->u.dst.error) < 0)
+	expires = rt->dst.expires ? rt->dst.expires - jiffies : 0;
+	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, 0, 0, expires,
+			       rt->dst.error) < 0)
 		goto rtattr_failure;
 	if (rt->fl.iif)
 		RTA_PUT(skb, RTA_IIF, sizeof(int), &rt->fl.iif);
@@ -1557,8 +1557,8 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 		local_bh_enable();
 		memset(cb, 0, sizeof(struct dn_skb_cb));
 		rt = (struct dn_route *)skb_dst(skb);
-		if (!err && -rt->u.dst.error)
-			err = rt->u.dst.error;
+		if (!err && -rt->dst.error)
+			err = rt->dst.error;
 	} else {
 		int oif = 0;
 		if (rta[RTA_OIF - 1])
@@ -1572,7 +1572,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	skb->dev = NULL;
 	if (err)
 		goto out_free;
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
@@ -1621,10 +1621,10 @@ int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		rcu_read_lock_bh();
 		for(rt = rcu_dereference_bh(dn_rt_hash_table[h].chain), idx = 0;
 			rt;
-			rt = rcu_dereference_bh(rt->u.dst.dn_next), idx++) {
+			rt = rcu_dereference_bh(rt->dst.dn_next), idx++) {
 			if (idx < s_idx)
 				continue;
-			skb_dst_set(skb, dst_clone(&rt->u.dst));
+			skb_dst_set(skb, dst_clone(&rt->dst));
 			if (dn_rt_fill_info(skb, NETLINK_CB(cb->skb).pid,
 					cb->nlh->nlmsg_seq, RTM_NEWROUTE,
 					1, NLM_F_MULTI) <= 0) {
@@ -1667,7 +1667,7 @@ static struct dn_route *dn_rt_cache_get_next(struct seq_file *seq, struct dn_rou
 {
 	struct dn_rt_cache_iter_state *s = seq->private;
 
-	rt = rt->u.dst.dn_next;
+	rt = rt->dst.dn_next;
 	while(!rt) {
 		rcu_read_unlock_bh();
 		if (--s->bucket < 0)
@@ -1708,12 +1708,12 @@ static int dn_rt_cache_seq_show(struct seq_file *seq, void *v)
 	char buf1[DN_ASCBUF_LEN], buf2[DN_ASCBUF_LEN];
 
 	seq_printf(seq, "%-8s %-7s %-7s %04d %04d %04d\n",
-			rt->u.dst.dev ? rt->u.dst.dev->name : "*",
+			rt->dst.dev ? rt->dst.dev->name : "*",
 			dn_addr2asc(le16_to_cpu(rt->rt_daddr), buf1),
 			dn_addr2asc(le16_to_cpu(rt->rt_saddr), buf2),
-			atomic_read(&rt->u.dst.__refcnt),
-			rt->u.dst.__use,
-			(int) dst_metric(&rt->u.dst, RTAX_RTT));
+			atomic_read(&rt->dst.__refcnt),
+			rt->dst.__use,
+			(int) dst_metric(&rt->dst, RTAX_RTT));
 	return 0;
 }
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c6c43bc..affaa4b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1100,7 +1100,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 	if (err)
 		return err;
 
-	sk_setup_caps(sk, &rt->u.dst);
+	sk_setup_caps(sk, &rt->dst);
 
 	new_saddr = rt->rt_src;
 
@@ -1166,7 +1166,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 	err = ip_route_output_flow(sock_net(sk), &rt, &fl, sk, 0);
 }
 	if (!err)
-		sk_setup_caps(sk, &rt->u.dst);
+		sk_setup_caps(sk, &rt->dst);
 	else {
 		/* Routing failed... */
 		sk->sk_route_caps = 0;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 6e74706..3a12fbc 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -427,7 +427,7 @@ static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 
 	if (ip_route_output_key(net, &rt, &fl) < 0)
 		return 1;
-	if (rt->u.dst.dev != dev) {
+	if (rt->dst.dev != dev) {
 		NET_INC_STATS_BH(net, LINUX_MIB_ARPFILTER);
 		flag = 1;
 	}
@@ -532,7 +532,7 @@ static inline int arp_fwd_proxy(struct in_device *in_dev,
 	struct in_device *out_dev;
 	int imi, omi = -1;
 
-	if (rt->u.dst.dev == dev)
+	if (rt->dst.dev == dev)
 		return 0;
 
 	if (!IN_DEV_PROXY_ARP(in_dev))
@@ -545,7 +545,7 @@ static inline int arp_fwd_proxy(struct in_device *in_dev,
 
 	/* place to check for proxy_arp for routes */
 
-	if ((out_dev = in_dev_get(rt->u.dst.dev)) != NULL) {
+	if ((out_dev = in_dev_get(rt->dst.dev)) != NULL) {
 		omi = IN_DEV_MEDIUM_ID(out_dev);
 		in_dev_put(out_dev);
 	}
@@ -576,7 +576,7 @@ static inline int arp_fwd_pvlan(struct in_device *in_dev,
 				__be32 sip, __be32 tip)
 {
 	/* Private VLAN is only concerned about the same ethernet segment */
-	if (rt->u.dst.dev != dev)
+	if (rt->dst.dev != dev)
 		return 0;
 
 	/* Don't reply on self probes (often done by windowz boxes)*/
@@ -1045,7 +1045,7 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 		struct rtable * rt;
 		if ((err = ip_route_output_key(net, &rt, &fl)) != 0)
 			return err;
-		dev = rt->u.dst.dev;
+		dev = rt->dst.dev;
 		ip_rt_put(rt);
 		if (!dev)
 			return -EINVAL;
@@ -1152,7 +1152,7 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 		struct rtable * rt;
 		if ((err = ip_route_output_key(net, &rt, &fl)) != 0)
 			return err;
-		dev = rt->u.dst.dev;
+		dev = rt->dst.dev;
 		ip_rt_put(rt);
 		if (!dev)
 			return -EINVAL;
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index fb24658..fe3daa7 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -69,7 +69,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk->sk_state = TCP_ESTABLISHED;
 	inet->inet_id = jiffies;
 
-	sk_dst_set(sk, &rt->u.dst);
+	sk_dst_set(sk, &rt->dst);
 	return(0);
 }
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f3d339f..cf6f0eb 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -271,7 +271,7 @@ int xrlim_allow(struct dst_entry *dst, int timeout)
 static inline int icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 		int type, int code)
 {
-	struct dst_entry *dst = &rt->u.dst;
+	struct dst_entry *dst = &rt->dst;
 	int rc = 1;
 
 	if (type > NR_ICMP_TYPES)
@@ -327,7 +327,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 	struct sock *sk;
 	struct sk_buff *skb;
 
-	sk = icmp_sk(dev_net((*rt)->u.dst.dev));
+	sk = icmp_sk(dev_net((*rt)->dst.dev));
 	if (ip_append_data(sk, icmp_glue_bits, icmp_param,
 			   icmp_param->data_len+icmp_param->head_len,
 			   icmp_param->head_len,
@@ -359,7 +359,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 {
 	struct ipcm_cookie ipc;
 	struct rtable *rt = skb_rtable(skb);
-	struct net *net = dev_net(rt->u.dst.dev);
+	struct net *net = dev_net(rt->dst.dev);
 	struct sock *sk;
 	struct inet_sock *inet;
 	__be32 daddr;
@@ -427,7 +427,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 
 	if (!rt)
 		goto out;
-	net = dev_net(rt->u.dst.dev);
+	net = dev_net(rt->dst.dev);
 
 	/*
 	 *	Find the original header. It is expected to be valid, of course.
@@ -596,9 +596,9 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 			/* Ugh! */
 			odst = skb_dst(skb_in);
 			err = ip_route_input(skb_in, fl.fl4_dst, fl.fl4_src,
-					     RT_TOS(tos), rt2->u.dst.dev);
+					     RT_TOS(tos), rt2->dst.dev);
 
-			dst_release(&rt2->u.dst);
+			dst_release(&rt2->dst);
 			rt2 = skb_rtable(skb_in);
 			skb_dst_set(skb_in, odst);
 		}
@@ -610,7 +610,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 				  XFRM_LOOKUP_ICMP);
 		switch (err) {
 		case 0:
-			dst_release(&rt->u.dst);
+			dst_release(&rt->dst);
 			rt = rt2;
 			break;
 		case -EPERM:
@@ -629,7 +629,7 @@ route_done:
 
 	/* RFC says return as much as we can without exceeding 576 bytes. */
 
-	room = dst_mtu(&rt->u.dst);
+	room = dst_mtu(&rt->dst);
 	if (room > 576)
 		room = 576;
 	room -= sizeof(struct iphdr) + icmp_param.replyopts.optlen;
@@ -974,7 +974,7 @@ int icmp_rcv(struct sk_buff *skb)
 {
 	struct icmphdr *icmph;
 	struct rtable *rt = skb_rtable(skb);
-	struct net *net = dev_net(rt->u.dst.dev);
+	struct net *net = dev_net(rt->dst.dev);
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 		struct sec_path *sp = skb_sec_path(skb);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 5fff865..46c7f97 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -312,7 +312,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 		return NULL;
 	}
 
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 	skb->dev = dev;
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
@@ -330,7 +330,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	pip->saddr    = rt->rt_src;
 	pip->protocol = IPPROTO_IGMP;
 	pip->tot_len  = 0;	/* filled in later */
-	ip_select_ident(pip, &rt->u.dst, NULL);
+	ip_select_ident(pip, &rt->dst, NULL);
 	((u8*)&pip[1])[0] = IPOPT_RA;
 	((u8*)&pip[1])[1] = 4;
 	((u8*)&pip[1])[2] = 0;
@@ -660,7 +660,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 		return -1;
 	}
 
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 
@@ -676,7 +676,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	iph->daddr    = dst;
 	iph->saddr    = rt->rt_src;
 	iph->protocol = IPPROTO_IGMP;
-	ip_select_ident(iph, &rt->u.dst, NULL);
+	ip_select_ident(iph, &rt->dst, NULL);
 	((u8*)&iph[1])[0] = IPOPT_RA;
 	((u8*)&iph[1])[1] = 4;
 	((u8*)&iph[1])[2] = 0;
@@ -1427,7 +1427,7 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 	}
 
 	if (!dev && !ip_route_output_key(net, &rt, &fl)) {
-		dev = rt->u.dst.dev;
+		dev = rt->dst.dev;
 		ip_rt_put(rt);
 	}
 	if (dev) {
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 78cbc39..6a5f235 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -383,7 +383,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 		goto no_route;
 	if (opt && opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
 		goto route_err;
-	return &rt->u.dst;
+	return &rt->dst;
 
 route_err:
 	ip_rt_put(rt);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index af10942..c0d9104 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -87,16 +87,16 @@ int ip_forward(struct sk_buff *skb)
 	if (opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
 		goto sr_failed;
 
-	if (unlikely(skb->len > dst_mtu(&rt->u.dst) && !skb_is_gso(skb) &&
+	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
 		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
-		IP_INC_STATS(dev_net(rt->u.dst.dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
-			  htonl(dst_mtu(&rt->u.dst)));
+			  htonl(dst_mtu(&rt->dst)));
 		goto drop;
 	}
 
 	/* We are about to mangle packet. Copy it! */
-	if (skb_cow(skb, LL_RESERVED_SPACE(rt->u.dst.dev)+rt->u.dst.header_len))
+	if (skb_cow(skb, LL_RESERVED_SPACE(rt->dst.dev)+rt->dst.header_len))
 		goto drop;
 	iph = ip_hdr(skb);
 
@@ -112,7 +112,7 @@ int ip_forward(struct sk_buff *skb)
 
 	skb->priority = rt_tos2priority(iph->tos);
 
-	return NF_HOOK(PF_INET, NF_INET_FORWARD, skb, skb->dev, rt->u.dst.dev,
+	return NF_HOOK(PF_INET, NF_INET_FORWARD, skb, skb->dev, rt->dst.dev,
 		       ip_forward_finish);
 
 sr_failed:
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fe381d1..539245b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -753,7 +753,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			goto tx_error;
 		}
 	}
-	tdev = rt->u.dst.dev;
+	tdev = rt->dst.dev;
 
 	if (tdev == dev) {
 		ip_rt_put(rt);
@@ -763,7 +763,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 
 	df = tiph->frag_off;
 	if (df)
-		mtu = dst_mtu(&rt->u.dst) - dev->hard_header_len - tunnel->hlen;
+		mtu = dst_mtu(&rt->dst) - dev->hard_header_len - tunnel->hlen;
 	else
 		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
 
@@ -811,7 +811,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			tunnel->err_count = 0;
 	}
 
-	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + rt->u.dst.header_len;
+	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + rt->dst.header_len;
 
 	if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
 	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
@@ -838,7 +838,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	/*
 	 *	Push down and install the IPIP header.
@@ -861,7 +861,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			iph->ttl = ((struct ipv6hdr *)old_iph)->hop_limit;
 #endif
 		else
-			iph->ttl = dst_metric(&rt->u.dst, RTAX_HOPLIMIT);
+			iph->ttl = dst_metric(&rt->dst, RTAX_HOPLIMIT);
 	}
 
 	((__be16 *)(iph + 1))[0] = tunnel->parms.o_flags;
@@ -923,7 +923,7 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 				    .proto = IPPROTO_GRE };
 		struct rtable *rt;
 		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
-			tdev = rt->u.dst.dev;
+			tdev = rt->dst.dev;
 			ip_rt_put(rt);
 		}
 
@@ -1182,7 +1182,7 @@ static int ipgre_open(struct net_device *dev)
 		struct rtable *rt;
 		if (ip_route_output_key(dev_net(dev), &rt, &fl))
 			return -EADDRNOTAVAIL;
-		dev = rt->u.dst.dev;
+		dev = rt->dst.dev;
 		ip_rt_put(rt);
 		if (__in_dev_get_rtnl(dev) == NULL)
 			return -EADDRNOTAVAIL;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index f8ab7a3..b368b78 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -360,10 +360,10 @@ static int ip_rcv_finish(struct sk_buff *skb)
 
 	rt = skb_rtable(skb);
 	if (rt->rt_type == RTN_MULTICAST) {
-		IP_UPD_PO_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INMCAST,
+		IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), IPSTATS_MIB_INMCAST,
 				skb->len);
 	} else if (rt->rt_type == RTN_BROADCAST)
-		IP_UPD_PO_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INBCAST,
+		IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), IPSTATS_MIB_INBCAST,
 				skb->len);
 
 	return dst_input(skb);
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 4c09a31..8e27f11 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -630,7 +630,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 		rt2 = skb_rtable(skb);
 		if (err || (rt2->rt_type != RTN_UNICAST && rt2->rt_type != RTN_LOCAL)) {
 			ip_rt_put(rt2);
-			skb_dst_set(skb, &rt->u.dst);
+			skb_dst_set(skb, &rt->dst);
 			return -EINVAL;
 		}
 		ip_rt_put(rt);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f039219..fa1358a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -151,15 +151,15 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 	iph->version  = 4;
 	iph->ihl      = 5;
 	iph->tos      = inet->tos;
-	if (ip_dont_fragment(sk, &rt->u.dst))
+	if (ip_dont_fragment(sk, &rt->dst))
 		iph->frag_off = htons(IP_DF);
 	else
 		iph->frag_off = 0;
-	iph->ttl      = ip_select_ttl(inet, &rt->u.dst);
+	iph->ttl      = ip_select_ttl(inet, &rt->dst);
 	iph->daddr    = rt->rt_dst;
 	iph->saddr    = rt->rt_src;
 	iph->protocol = sk->sk_protocol;
-	ip_select_ident(iph, &rt->u.dst, sk);
+	ip_select_ident(iph, &rt->dst, sk);
 
 	if (opt && opt->optlen) {
 		iph->ihl += opt->optlen>>2;
@@ -240,7 +240,7 @@ int ip_mc_output(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 	struct rtable *rt = skb_rtable(skb);
-	struct net_device *dev = rt->u.dst.dev;
+	struct net_device *dev = rt->dst.dev;
 
 	/*
 	 *	If the indicated interface is up and running, send the packet.
@@ -357,9 +357,9 @@ int ip_queue_xmit(struct sk_buff *skb)
 			if (ip_route_output_flow(sock_net(sk), &rt, &fl, sk, 0))
 				goto no_route;
 		}
-		sk_setup_caps(sk, &rt->u.dst);
+		sk_setup_caps(sk, &rt->dst);
 	}
-	skb_dst_set(skb, dst_clone(&rt->u.dst));
+	skb_dst_set(skb, dst_clone(&rt->dst));
 
 packet_routed:
 	if (opt && opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
@@ -370,11 +370,11 @@ packet_routed:
 	skb_reset_network_header(skb);
 	iph = ip_hdr(skb);
 	*((__be16 *)iph) = htons((4 << 12) | (5 << 8) | (inet->tos & 0xff));
-	if (ip_dont_fragment(sk, &rt->u.dst) && !skb->local_df)
+	if (ip_dont_fragment(sk, &rt->dst) && !skb->local_df)
 		iph->frag_off = htons(IP_DF);
 	else
 		iph->frag_off = 0;
-	iph->ttl      = ip_select_ttl(inet, &rt->u.dst);
+	iph->ttl      = ip_select_ttl(inet, &rt->dst);
 	iph->protocol = sk->sk_protocol;
 	iph->saddr    = rt->rt_src;
 	iph->daddr    = rt->rt_dst;
@@ -385,7 +385,7 @@ packet_routed:
 		ip_options_build(skb, opt, inet->inet_daddr, rt, 0);
 	}
 
-	ip_select_ident_more(iph, &rt->u.dst, sk,
+	ip_select_ident_more(iph, &rt->dst, sk,
 			     (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 
 	skb->priority = sk->sk_priority;
@@ -447,7 +447,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	struct rtable *rt = skb_rtable(skb);
 	int err = 0;
 
-	dev = rt->u.dst.dev;
+	dev = rt->dst.dev;
 
 	/*
 	 *	Point into the IP datagram header.
@@ -468,7 +468,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	 */
 
 	hlen = iph->ihl * 4;
-	mtu = dst_mtu(&rt->u.dst) - hlen;	/* Size of data space */
+	mtu = dst_mtu(&rt->dst) - hlen;	/* Size of data space */
 	IPCB(skb)->flags |= IPSKB_FRAG_COMPLETE;
 
 	/* When frag_list is given, use it. First, check its validity:
@@ -577,7 +577,7 @@ slow_path:
 	 * we need to make room for the encapsulating header
 	 */
 	pad = nf_bridge_pad(skb);
-	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->u.dst.dev, pad);
+	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, pad);
 	mtu -= pad;
 
 	/*
@@ -824,13 +824,13 @@ int ip_append_data(struct sock *sk,
 		 */
 		*rtp = NULL;
 		inet->cork.fragsize = mtu = inet->pmtudisc == IP_PMTUDISC_PROBE ?
-					    rt->u.dst.dev->mtu :
-					    dst_mtu(rt->u.dst.path);
-		inet->cork.dst = &rt->u.dst;
+					    rt->dst.dev->mtu :
+					    dst_mtu(rt->dst.path);
+		inet->cork.dst = &rt->dst;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
-		if ((exthdrlen = rt->u.dst.header_len) != 0) {
+		if ((exthdrlen = rt->dst.header_len) != 0) {
 			length += exthdrlen;
 			transhdrlen += exthdrlen;
 		}
@@ -843,7 +843,7 @@ int ip_append_data(struct sock *sk,
 		exthdrlen = 0;
 		mtu = inet->cork.fragsize;
 	}
-	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
+	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
@@ -860,14 +860,14 @@ int ip_append_data(struct sock *sk,
 	 */
 	if (transhdrlen &&
 	    length + fragheaderlen <= mtu &&
-	    rt->u.dst.dev->features & NETIF_F_V4_CSUM &&
+	    rt->dst.dev->features & NETIF_F_V4_CSUM &&
 	    !exthdrlen)
 		csummode = CHECKSUM_PARTIAL;
 
 	inet->cork.length += length;
 	if (((length> mtu) || !skb_queue_empty(&sk->sk_write_queue)) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
+	    (rt->dst.dev->features & NETIF_F_UFO)) {
 		err = ip_ufo_append_data(sk, getfrag, from, length, hh_len,
 					 fragheaderlen, transhdrlen, mtu,
 					 flags);
@@ -915,7 +915,7 @@ alloc_new_skb:
 			fraglen = datalen + fragheaderlen;
 
 			if ((flags & MSG_MORE) &&
-			    !(rt->u.dst.dev->features&NETIF_F_SG))
+			    !(rt->dst.dev->features&NETIF_F_SG))
 				alloclen = mtu;
 			else
 				alloclen = datalen + fragheaderlen;
@@ -926,7 +926,7 @@ alloc_new_skb:
 			 * the last.
 			 */
 			if (datalen == length + fraggap)
-				alloclen += rt->u.dst.trailer_len;
+				alloclen += rt->dst.trailer_len;
 
 			if (transhdrlen) {
 				skb = sock_alloc_send_skb(sk,
@@ -999,7 +999,7 @@ alloc_new_skb:
 		if (copy > length)
 			copy = length;
 
-		if (!(rt->u.dst.dev->features&NETIF_F_SG)) {
+		if (!(rt->dst.dev->features&NETIF_F_SG)) {
 			unsigned int off;
 
 			off = skb->len;
@@ -1094,10 +1094,10 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 	if (inet->cork.flags & IPCORK_OPT)
 		opt = inet->cork.opt;
 
-	if (!(rt->u.dst.dev->features&NETIF_F_SG))
+	if (!(rt->dst.dev->features&NETIF_F_SG))
 		return -EOPNOTSUPP;
 
-	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
+	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
 	mtu = inet->cork.fragsize;
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
@@ -1113,7 +1113,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 
 	inet->cork.length += size;
 	if ((sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
+	    (rt->dst.dev->features & NETIF_F_UFO)) {
 		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 	}
@@ -1265,8 +1265,8 @@ int ip_push_pending_frames(struct sock *sk)
 	 * If local_df is set too, we still allow to fragment this frame
 	 * locally. */
 	if (inet->pmtudisc >= IP_PMTUDISC_DO ||
-	    (skb->len <= dst_mtu(&rt->u.dst) &&
-	     ip_dont_fragment(sk, &rt->u.dst)))
+	    (skb->len <= dst_mtu(&rt->dst) &&
+	     ip_dont_fragment(sk, &rt->dst)))
 		df = htons(IP_DF);
 
 	if (inet->cork.flags & IPCORK_OPT)
@@ -1275,7 +1275,7 @@ int ip_push_pending_frames(struct sock *sk)
 	if (rt->rt_type == RTN_MULTICAST)
 		ttl = inet->mc_ttl;
 	else
-		ttl = ip_select_ttl(inet, &rt->u.dst);
+		ttl = ip_select_ttl(inet, &rt->dst);
 
 	iph = (struct iphdr *)skb->data;
 	iph->version = 4;
@@ -1286,7 +1286,7 @@ int ip_push_pending_frames(struct sock *sk)
 	}
 	iph->tos = inet->tos;
 	iph->frag_off = df;
-	ip_select_ident(iph, &rt->u.dst, sk);
+	ip_select_ident(iph, &rt->dst, sk);
 	iph->ttl = ttl;
 	iph->protocol = sk->sk_protocol;
 	iph->saddr = rt->rt_src;
@@ -1299,7 +1299,7 @@ int ip_push_pending_frames(struct sock *sk)
 	 * on dst refcount
 	 */
 	inet->cork.dst = NULL;
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	if (iph->protocol == IPPROTO_ICMP)
 		icmp_out_count(net, ((struct icmphdr *)
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 0b27b14..f6f7b56 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -438,7 +438,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto tx_error_icmp;
 		}
 	}
-	tdev = rt->u.dst.dev;
+	tdev = rt->dst.dev;
 
 	if (tdev == dev) {
 		ip_rt_put(rt);
@@ -449,7 +449,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	df |= old_iph->frag_off & htons(IP_DF);
 
 	if (df) {
-		mtu = dst_mtu(&rt->u.dst) - sizeof(struct iphdr);
+		mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
 
 		if (mtu < 68) {
 			stats->collisions++;
@@ -506,7 +506,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	/*
 	 *	Push down and install the IPIP header.
@@ -555,7 +555,7 @@ static void ipip_tunnel_bind_dev(struct net_device *dev)
 				    .proto = IPPROTO_IPIP };
 		struct rtable *rt;
 		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
-			tdev = rt->u.dst.dev;
+			tdev = rt->dst.dev;
 			ip_rt_put(rt);
 		}
 		dev->flags |= IFF_POINTOPOINT;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index eddfd12..4598488 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1550,9 +1550,9 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 			goto out_free;
 	}
 
-	dev = rt->u.dst.dev;
+	dev = rt->dst.dev;
 
-	if (skb->len+encap > dst_mtu(&rt->u.dst) && (ntohs(iph->frag_off) & IP_DF)) {
+	if (skb->len+encap > dst_mtu(&rt->dst) && (ntohs(iph->frag_off) & IP_DF)) {
 		/* Do not fragment multicasts. Alas, IPv4 does not
 		   allow to send ICMP, so that packets will disappear
 		   to blackhole.
@@ -1563,7 +1563,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 		goto out_free;
 	}
 
-	encap += LL_RESERVED_SPACE(dev) + rt->u.dst.header_len;
+	encap += LL_RESERVED_SPACE(dev) + rt->dst.header_len;
 
 	if (skb_cow(skb, encap)) {
 		ip_rt_put(rt);
@@ -1574,7 +1574,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 	vif->bytes_out += skb->len;
 
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 	ip_decrease_ttl(ip_hdr(skb));
 
 	/* FIXME: forward and output firewalls used to be called here.
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 82fb43c..5c5105b 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -43,7 +43,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 
 		/* Drop old route. */
 		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->u.dst);
+		skb_dst_set(skb, &rt->dst);
 	} else {
 		/* non-local src, find valid iif to satisfy
 		 * rp-filter when calling ip_route_input. */
@@ -53,11 +53,11 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 
 		odst = skb_dst(skb);
 		if (ip_route_input(skb, iph->daddr, iph->saddr,
-				   RT_TOS(iph->tos), rt->u.dst.dev) != 0) {
-			dst_release(&rt->u.dst);
+				   RT_TOS(iph->tos), rt->dst.dev) != 0) {
+			dst_release(&rt->dst);
 			return -1;
 		}
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 		dst_release(odst);
 	}
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 52ef5af..8323395 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -324,24 +324,24 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	unsigned int iphlen;
 	int err;
 
-	if (length > rt->u.dst.dev->mtu) {
+	if (length > rt->dst.dev->mtu) {
 		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->inet_dport,
-			       rt->u.dst.dev->mtu);
+			       rt->dst.dev->mtu);
 		return -EMSGSIZE;
 	}
 	if (flags&MSG_PROBE)
 		goto out;
 
 	skb = sock_alloc_send_skb(sk,
-				  length + LL_ALLOCATED_SPACE(rt->u.dst.dev) + 15,
+				  length + LL_ALLOCATED_SPACE(rt->dst.dev) + 15,
 				  flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto error;
-	skb_reserve(skb, LL_RESERVED_SPACE(rt->u.dst.dev));
+	skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
-	skb_dst_set(skb, dst_clone(&rt->u.dst));
+	skb_dst_set(skb, dst_clone(&rt->dst));
 
 	skb_reset_network_header(skb);
 	iph = ip_hdr(skb);
@@ -373,7 +373,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 		iph->check   = 0;
 		iph->tot_len = htons(length);
 		if (!iph->id)
-			ip_select_ident(iph, &rt->u.dst, NULL);
+			ip_select_ident(iph, &rt->dst, NULL);
 
 		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 	}
@@ -381,7 +381,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 		icmp_out_count(net, ((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
-	err = NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
+	err = NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->dst.dev,
 		      dst_output);
 	if (err > 0)
 		err = net_xmit_errno(err);
@@ -604,7 +604,7 @@ out:
 	return len;
 
 do_confirm:
-	dst_confirm(&rt->u.dst);
+	dst_confirm(&rt->dst);
 	if (!(msg->msg_flags & MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a947428..31e3e63 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -288,10 +288,10 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
 		rcu_read_lock_bh();
 		r = rcu_dereference_bh(rt_hash_table[st->bucket].chain);
 		while (r) {
-			if (dev_net(r->u.dst.dev) == seq_file_net(seq) &&
+			if (dev_net(r->dst.dev) == seq_file_net(seq) &&
 			    r->rt_genid == st->genid)
 				return r;
-			r = rcu_dereference_bh(r->u.dst.rt_next);
+			r = rcu_dereference_bh(r->dst.rt_next);
 		}
 		rcu_read_unlock_bh();
 	}
@@ -303,7 +303,7 @@ static struct rtable *__rt_cache_get_next(struct seq_file *seq,
 {
 	struct rt_cache_iter_state *st = seq->private;
 
-	r = r->u.dst.rt_next;
+	r = r->dst.rt_next;
 	while (!r) {
 		rcu_read_unlock_bh();
 		do {
@@ -321,7 +321,7 @@ static struct rtable *rt_cache_get_next(struct seq_file *seq,
 {
 	struct rt_cache_iter_state *st = seq->private;
 	while ((r = __rt_cache_get_next(seq, r)) != NULL) {
-		if (dev_net(r->u.dst.dev) != seq_file_net(seq))
+		if (dev_net(r->dst.dev) != seq_file_net(seq))
 			continue;
 		if (r->rt_genid == st->genid)
 			break;
@@ -379,19 +379,19 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 
 		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
 			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
-			r->u.dst.dev ? r->u.dst.dev->name : "*",
+			r->dst.dev ? r->dst.dev->name : "*",
 			(__force u32)r->rt_dst,
 			(__force u32)r->rt_gateway,
-			r->rt_flags, atomic_read(&r->u.dst.__refcnt),
-			r->u.dst.__use, 0, (__force u32)r->rt_src,
-			(dst_metric(&r->u.dst, RTAX_ADVMSS) ?
-			     (int)dst_metric(&r->u.dst, RTAX_ADVMSS) + 40 : 0),
-			dst_metric(&r->u.dst, RTAX_WINDOW),
-			(int)((dst_metric(&r->u.dst, RTAX_RTT) >> 3) +
-			      dst_metric(&r->u.dst, RTAX_RTTVAR)),
+			r->rt_flags, atomic_read(&r->dst.__refcnt),
+			r->dst.__use, 0, (__force u32)r->rt_src,
+			(dst_metric(&r->dst, RTAX_ADVMSS) ?
+			     (int)dst_metric(&r->dst, RTAX_ADVMSS) + 40 : 0),
+			dst_metric(&r->dst, RTAX_WINDOW),
+			(int)((dst_metric(&r->dst, RTAX_RTT) >> 3) +
+			      dst_metric(&r->dst, RTAX_RTTVAR)),
 			r->fl.fl4_tos,
-			r->u.dst.hh ? atomic_read(&r->u.dst.hh->hh_refcnt) : -1,
-			r->u.dst.hh ? (r->u.dst.hh->hh_output ==
+			r->dst.hh ? atomic_read(&r->dst.hh->hh_refcnt) : -1,
+			r->dst.hh ? (r->dst.hh->hh_output ==
 				       dev_queue_xmit) : 0,
 			r->rt_spec_dst, &len);
 
@@ -610,13 +610,13 @@ static inline int ip_rt_proc_init(void)
 
 static inline void rt_free(struct rtable *rt)
 {
-	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
+	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
 }
 
 static inline void rt_drop(struct rtable *rt)
 {
 	ip_rt_put(rt);
-	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
+	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
 }
 
 static inline int rt_fast_clean(struct rtable *rth)
@@ -624,13 +624,13 @@ static inline int rt_fast_clean(struct rtable *rth)
 	/* Kill broadcast/multicast entries very aggresively, if they
 	   collide in hash table with more useful entries */
 	return (rth->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST)) &&
-		rth->fl.iif && rth->u.dst.rt_next;
+		rth->fl.iif && rth->dst.rt_next;
 }
 
 static inline int rt_valuable(struct rtable *rth)
 {
 	return (rth->rt_flags & (RTCF_REDIRECTED | RTCF_NOTIFY)) ||
-		rth->u.dst.expires;
+		rth->dst.expires;
 }
 
 static int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long tmo2)
@@ -638,15 +638,15 @@ static int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long t
 	unsigned long age;
 	int ret = 0;
 
-	if (atomic_read(&rth->u.dst.__refcnt))
+	if (atomic_read(&rth->dst.__refcnt))
 		goto out;
 
 	ret = 1;
-	if (rth->u.dst.expires &&
-	    time_after_eq(jiffies, rth->u.dst.expires))
+	if (rth->dst.expires &&
+	    time_after_eq(jiffies, rth->dst.expires))
 		goto out;
 
-	age = jiffies - rth->u.dst.lastuse;
+	age = jiffies - rth->dst.lastuse;
 	ret = 0;
 	if ((age <= tmo1 && !rt_fast_clean(rth)) ||
 	    (age <= tmo2 && rt_valuable(rth)))
@@ -662,7 +662,7 @@ out:	return ret;
  */
 static inline u32 rt_score(struct rtable *rt)
 {
-	u32 score = jiffies - rt->u.dst.lastuse;
+	u32 score = jiffies - rt->dst.lastuse;
 
 	score = ~score & ~(3<<30);
 
@@ -702,12 +702,12 @@ static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 
 static inline int compare_netns(struct rtable *rt1, struct rtable *rt2)
 {
-	return net_eq(dev_net(rt1->u.dst.dev), dev_net(rt2->u.dst.dev));
+	return net_eq(dev_net(rt1->dst.dev), dev_net(rt2->dst.dev));
 }
 
 static inline int rt_is_expired(struct rtable *rth)
 {
-	return rth->rt_genid != rt_genid(dev_net(rth->u.dst.dev));
+	return rth->rt_genid != rt_genid(dev_net(rth->dst.dev));
 }
 
 /*
@@ -736,7 +736,7 @@ static void rt_do_flush(int process_context)
 		rth = rt_hash_table[i].chain;
 
 		/* defer releasing the head of the list after spin_unlock */
-		for (tail = rth; tail; tail = tail->u.dst.rt_next)
+		for (tail = rth; tail; tail = tail->dst.rt_next)
 			if (!rt_is_expired(tail))
 				break;
 		if (rth != tail)
@@ -745,9 +745,9 @@ static void rt_do_flush(int process_context)
 		/* call rt_free on entries after the tail requiring flush */
 		prev = &rt_hash_table[i].chain;
 		for (p = *prev; p; p = next) {
-			next = p->u.dst.rt_next;
+			next = p->dst.rt_next;
 			if (!rt_is_expired(p)) {
-				prev = &p->u.dst.rt_next;
+				prev = &p->dst.rt_next;
 			} else {
 				*prev = next;
 				rt_free(p);
@@ -762,7 +762,7 @@ static void rt_do_flush(int process_context)
 		spin_unlock_bh(rt_hash_lock_addr(i));
 
 		for (; rth != tail; rth = next) {
-			next = rth->u.dst.rt_next;
+			next = rth->dst.rt_next;
 			rt_free(rth);
 		}
 	}
@@ -793,7 +793,7 @@ static int has_noalias(const struct rtable *head, const struct rtable *rth)
 	while (aux != rth) {
 		if (compare_hash_inputs(&aux->fl, &rth->fl))
 			return 0;
-		aux = aux->u.dst.rt_next;
+		aux = aux->dst.rt_next;
 	}
 	return ONE;
 }
@@ -833,18 +833,18 @@ static void rt_check_expire(void)
 		length = 0;
 		spin_lock_bh(rt_hash_lock_addr(i));
 		while ((rth = *rthp) != NULL) {
-			prefetch(rth->u.dst.rt_next);
+			prefetch(rth->dst.rt_next);
 			if (rt_is_expired(rth)) {
-				*rthp = rth->u.dst.rt_next;
+				*rthp = rth->dst.rt_next;
 				rt_free(rth);
 				continue;
 			}
-			if (rth->u.dst.expires) {
+			if (rth->dst.expires) {
 				/* Entry is expired even if it is in use */
-				if (time_before_eq(jiffies, rth->u.dst.expires)) {
+				if (time_before_eq(jiffies, rth->dst.expires)) {
 nofree:
 					tmo >>= 1;
-					rthp = &rth->u.dst.rt_next;
+					rthp = &rth->dst.rt_next;
 					/*
 					 * We only count entries on
 					 * a chain with equal hash inputs once
@@ -860,7 +860,7 @@ nofree:
 				goto nofree;
 
 			/* Cleanup aged off entries. */
-			*rthp = rth->u.dst.rt_next;
+			*rthp = rth->dst.rt_next;
 			rt_free(rth);
 		}
 		spin_unlock_bh(rt_hash_lock_addr(i));
@@ -1022,10 +1022,10 @@ static int rt_garbage_collect(struct dst_ops *ops)
 				if (!rt_is_expired(rth) &&
 					!rt_may_expire(rth, tmo, expire)) {
 					tmo >>= 1;
-					rthp = &rth->u.dst.rt_next;
+					rthp = &rth->dst.rt_next;
 					continue;
 				}
-				*rthp = rth->u.dst.rt_next;
+				*rthp = rth->dst.rt_next;
 				rt_free(rth);
 				goal--;
 			}
@@ -1091,7 +1091,7 @@ static int slow_chain_length(const struct rtable *head)
 
 	while (rth) {
 		length += has_noalias(head, rth);
-		rth = rth->u.dst.rt_next;
+		rth = rth->dst.rt_next;
 	}
 	return length >> FRACT_BITS;
 }
@@ -1113,7 +1113,7 @@ restart:
 	candp = NULL;
 	now = jiffies;
 
-	if (!rt_caching(dev_net(rt->u.dst.dev))) {
+	if (!rt_caching(dev_net(rt->dst.dev))) {
 		/*
 		 * If we're not caching, just tell the caller we
 		 * were successful and don't touch the route.  The
@@ -1131,7 +1131,7 @@ restart:
 		 */
 
 		if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
-			int err = arp_bind_neighbour(&rt->u.dst);
+			int err = arp_bind_neighbour(&rt->dst);
 			if (err) {
 				if (net_ratelimit())
 					printk(KERN_WARNING
@@ -1150,19 +1150,19 @@ restart:
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	while ((rth = *rthp) != NULL) {
 		if (rt_is_expired(rth)) {
-			*rthp = rth->u.dst.rt_next;
+			*rthp = rth->dst.rt_next;
 			rt_free(rth);
 			continue;
 		}
 		if (compare_keys(&rth->fl, &rt->fl) && compare_netns(rth, rt)) {
 			/* Put it first */
-			*rthp = rth->u.dst.rt_next;
+			*rthp = rth->dst.rt_next;
 			/*
 			 * Since lookup is lockfree, the deletion
 			 * must be visible to another weakly ordered CPU before
 			 * the insertion at the start of the hash chain.
 			 */
-			rcu_assign_pointer(rth->u.dst.rt_next,
+			rcu_assign_pointer(rth->dst.rt_next,
 					   rt_hash_table[hash].chain);
 			/*
 			 * Since lookup is lockfree, the update writes
@@ -1170,18 +1170,18 @@ restart:
 			 */
 			rcu_assign_pointer(rt_hash_table[hash].chain, rth);
 
-			dst_use(&rth->u.dst, now);
+			dst_use(&rth->dst, now);
 			spin_unlock_bh(rt_hash_lock_addr(hash));
 
 			rt_drop(rt);
 			if (rp)
 				*rp = rth;
 			else
-				skb_dst_set(skb, &rth->u.dst);
+				skb_dst_set(skb, &rth->dst);
 			return 0;
 		}
 
-		if (!atomic_read(&rth->u.dst.__refcnt)) {
+		if (!atomic_read(&rth->dst.__refcnt)) {
 			u32 score = rt_score(rth);
 
 			if (score <= min_score) {
@@ -1193,7 +1193,7 @@ restart:
 
 		chain_length++;
 
-		rthp = &rth->u.dst.rt_next;
+		rthp = &rth->dst.rt_next;
 	}
 
 	if (cand) {
@@ -1204,17 +1204,17 @@ restart:
 		 * only 2 entries per bucket. We will see.
 		 */
 		if (chain_length > ip_rt_gc_elasticity) {
-			*candp = cand->u.dst.rt_next;
+			*candp = cand->dst.rt_next;
 			rt_free(cand);
 		}
 	} else {
 		if (chain_length > rt_chain_length_max &&
 		    slow_chain_length(rt_hash_table[hash].chain) > rt_chain_length_max) {
-			struct net *net = dev_net(rt->u.dst.dev);
+			struct net *net = dev_net(rt->dst.dev);
 			int num = ++net->ipv4.current_rt_cache_rebuild_count;
 			if (!rt_caching(net)) {
 				printk(KERN_WARNING "%s: %d rebuilds is over limit, route caching disabled\n",
-					rt->u.dst.dev->name, num);
+					rt->dst.dev->name, num);
 			}
 			rt_emergency_hash_rebuild(net);
 			spin_unlock_bh(rt_hash_lock_addr(hash));
@@ -1229,7 +1229,7 @@ restart:
 	   route or unicast forwarding path.
 	 */
 	if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
-		int err = arp_bind_neighbour(&rt->u.dst);
+		int err = arp_bind_neighbour(&rt->dst);
 		if (err) {
 			spin_unlock_bh(rt_hash_lock_addr(hash));
 
@@ -1260,14 +1260,14 @@ restart:
 		}
 	}
 
-	rt->u.dst.rt_next = rt_hash_table[hash].chain;
+	rt->dst.rt_next = rt_hash_table[hash].chain;
 
 #if RT_CACHE_DEBUG >= 2
-	if (rt->u.dst.rt_next) {
+	if (rt->dst.rt_next) {
 		struct rtable *trt;
 		printk(KERN_DEBUG "rt_cache @%02x: %pI4",
 		       hash, &rt->rt_dst);
-		for (trt = rt->u.dst.rt_next; trt; trt = trt->u.dst.rt_next)
+		for (trt = rt->dst.rt_next; trt; trt = trt->dst.rt_next)
 			printk(" . %pI4", &trt->rt_dst);
 		printk("\n");
 	}
@@ -1285,7 +1285,7 @@ skip_hashing:
 	if (rp)
 		*rp = rt;
 	else
-		skb_dst_set(skb, &rt->u.dst);
+		skb_dst_set(skb, &rt->dst);
 	return 0;
 }
 
@@ -1357,11 +1357,11 @@ static void rt_del(unsigned hash, struct rtable *rt)
 	ip_rt_put(rt);
 	while ((aux = *rthp) != NULL) {
 		if (aux == rt || rt_is_expired(aux)) {
-			*rthp = aux->u.dst.rt_next;
+			*rthp = aux->dst.rt_next;
 			rt_free(aux);
 			continue;
 		}
-		rthp = &aux->u.dst.rt_next;
+		rthp = &aux->dst.rt_next;
 	}
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
@@ -1415,19 +1415,19 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				    rth->fl.oif != ikeys[k] ||
 				    rth->fl.iif != 0 ||
 				    rt_is_expired(rth) ||
-				    !net_eq(dev_net(rth->u.dst.dev), net)) {
-					rthp = &rth->u.dst.rt_next;
+				    !net_eq(dev_net(rth->dst.dev), net)) {
+					rthp = &rth->dst.rt_next;
 					continue;
 				}
 
 				if (rth->rt_dst != daddr ||
 				    rth->rt_src != saddr ||
-				    rth->u.dst.error ||
+				    rth->dst.error ||
 				    rth->rt_gateway != old_gw ||
-				    rth->u.dst.dev != dev)
+				    rth->dst.dev != dev)
 					break;
 
-				dst_hold(&rth->u.dst);
+				dst_hold(&rth->dst);
 				rcu_read_unlock();
 
 				rt = dst_alloc(&ipv4_dst_ops);
@@ -1439,20 +1439,20 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 
 				/* Copy all the information. */
 				*rt = *rth;
-				rt->u.dst.__use		= 1;
-				atomic_set(&rt->u.dst.__refcnt, 1);
-				rt->u.dst.child		= NULL;
-				if (rt->u.dst.dev)
-					dev_hold(rt->u.dst.dev);
+				rt->dst.__use		= 1;
+				atomic_set(&rt->dst.__refcnt, 1);
+				rt->dst.child		= NULL;
+				if (rt->dst.dev)
+					dev_hold(rt->dst.dev);
 				if (rt->idev)
 					in_dev_hold(rt->idev);
-				rt->u.dst.obsolete	= -1;
-				rt->u.dst.lastuse	= jiffies;
-				rt->u.dst.path		= &rt->u.dst;
-				rt->u.dst.neighbour	= NULL;
-				rt->u.dst.hh		= NULL;
+				rt->dst.obsolete	= -1;
+				rt->dst.lastuse	= jiffies;
+				rt->dst.path		= &rt->dst;
+				rt->dst.neighbour	= NULL;
+				rt->dst.hh		= NULL;
 #ifdef CONFIG_XFRM
-				rt->u.dst.xfrm		= NULL;
+				rt->dst.xfrm		= NULL;
 #endif
 				rt->rt_genid		= rt_genid(net);
 				rt->rt_flags		|= RTCF_REDIRECTED;
@@ -1461,23 +1461,23 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				rt->rt_gateway		= new_gw;
 
 				/* Redirect received -> path was valid */
-				dst_confirm(&rth->u.dst);
+				dst_confirm(&rth->dst);
 
 				if (rt->peer)
 					atomic_inc(&rt->peer->refcnt);
 
-				if (arp_bind_neighbour(&rt->u.dst) ||
-				    !(rt->u.dst.neighbour->nud_state &
+				if (arp_bind_neighbour(&rt->dst) ||
+				    !(rt->dst.neighbour->nud_state &
 					    NUD_VALID)) {
-					if (rt->u.dst.neighbour)
-						neigh_event_send(rt->u.dst.neighbour, NULL);
+					if (rt->dst.neighbour)
+						neigh_event_send(rt->dst.neighbour, NULL);
 					ip_rt_put(rth);
 					rt_drop(rt);
 					goto do_next;
 				}
 
-				netevent.old = &rth->u.dst;
-				netevent.new = &rt->u.dst;
+				netevent.old = &rth->dst;
+				netevent.new = &rt->dst;
 				call_netevent_notifiers(NETEVENT_REDIRECT,
 							&netevent);
 
@@ -1515,8 +1515,8 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 			ip_rt_put(rt);
 			ret = NULL;
 		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
-			   (rt->u.dst.expires &&
-			    time_after_eq(jiffies, rt->u.dst.expires))) {
+			   (rt->dst.expires &&
+			    time_after_eq(jiffies, rt->dst.expires))) {
 			unsigned hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
 						rt->fl.oif,
 						rt_genid(dev_net(dst->dev)));
@@ -1554,7 +1554,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	int log_martians;
 
 	rcu_read_lock();
-	in_dev = __in_dev_get_rcu(rt->u.dst.dev);
+	in_dev = __in_dev_get_rcu(rt->dst.dev);
 	if (!in_dev || !IN_DEV_TX_REDIRECTS(in_dev)) {
 		rcu_read_unlock();
 		return;
@@ -1565,30 +1565,30 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	/* No redirected packets during ip_rt_redirect_silence;
 	 * reset the algorithm.
 	 */
-	if (time_after(jiffies, rt->u.dst.rate_last + ip_rt_redirect_silence))
-		rt->u.dst.rate_tokens = 0;
+	if (time_after(jiffies, rt->dst.rate_last + ip_rt_redirect_silence))
+		rt->dst.rate_tokens = 0;
 
 	/* Too many ignored redirects; do not send anything
-	 * set u.dst.rate_last to the last seen redirected packet.
+	 * set dst.rate_last to the last seen redirected packet.
 	 */
-	if (rt->u.dst.rate_tokens >= ip_rt_redirect_number) {
-		rt->u.dst.rate_last = jiffies;
+	if (rt->dst.rate_tokens >= ip_rt_redirect_number) {
+		rt->dst.rate_last = jiffies;
 		return;
 	}
 
 	/* Check for load limit; set rate_last to the latest sent
 	 * redirect.
 	 */
-	if (rt->u.dst.rate_tokens == 0 ||
+	if (rt->dst.rate_tokens == 0 ||
 	    time_after(jiffies,
-		       (rt->u.dst.rate_last +
-			(ip_rt_redirect_load << rt->u.dst.rate_tokens)))) {
+		       (rt->dst.rate_last +
+			(ip_rt_redirect_load << rt->dst.rate_tokens)))) {
 		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);
-		rt->u.dst.rate_last = jiffies;
-		++rt->u.dst.rate_tokens;
+		rt->dst.rate_last = jiffies;
+		++rt->dst.rate_tokens;
 #ifdef CONFIG_IP_ROUTE_VERBOSE
 		if (log_martians &&
-		    rt->u.dst.rate_tokens == ip_rt_redirect_number &&
+		    rt->dst.rate_tokens == ip_rt_redirect_number &&
 		    net_ratelimit())
 			printk(KERN_WARNING "host %pI4/if%d ignores redirects for %pI4 to %pI4.\n",
 				&rt->rt_src, rt->rt_iif,
@@ -1603,7 +1603,7 @@ static int ip_error(struct sk_buff *skb)
 	unsigned long now;
 	int code;
 
-	switch (rt->u.dst.error) {
+	switch (rt->dst.error) {
 		case EINVAL:
 		default:
 			goto out;
@@ -1612,7 +1612,7 @@ static int ip_error(struct sk_buff *skb)
 			break;
 		case ENETUNREACH:
 			code = ICMP_NET_UNREACH;
-			IP_INC_STATS_BH(dev_net(rt->u.dst.dev),
+			IP_INC_STATS_BH(dev_net(rt->dst.dev),
 					IPSTATS_MIB_INNOROUTES);
 			break;
 		case EACCES:
@@ -1621,12 +1621,12 @@ static int ip_error(struct sk_buff *skb)
 	}
 
 	now = jiffies;
-	rt->u.dst.rate_tokens += now - rt->u.dst.rate_last;
-	if (rt->u.dst.rate_tokens > ip_rt_error_burst)
-		rt->u.dst.rate_tokens = ip_rt_error_burst;
-	rt->u.dst.rate_last = now;
-	if (rt->u.dst.rate_tokens >= ip_rt_error_cost) {
-		rt->u.dst.rate_tokens -= ip_rt_error_cost;
+	rt->dst.rate_tokens += now - rt->dst.rate_last;
+	if (rt->dst.rate_tokens > ip_rt_error_burst)
+		rt->dst.rate_tokens = ip_rt_error_burst;
+	rt->dst.rate_last = now;
+	if (rt->dst.rate_tokens >= ip_rt_error_cost) {
+		rt->dst.rate_tokens -= ip_rt_error_cost;
 		icmp_send(skb, ICMP_DEST_UNREACH, code, 0);
 	}
 
@@ -1671,7 +1671,7 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 
 			rcu_read_lock();
 			for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
-			     rth = rcu_dereference(rth->u.dst.rt_next)) {
+			     rth = rcu_dereference(rth->dst.rt_next)) {
 				unsigned short mtu = new_mtu;
 
 				if (rth->fl.fl4_dst != daddr ||
@@ -1680,8 +1680,8 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 				    rth->rt_src != iph->saddr ||
 				    rth->fl.oif != ikeys[k] ||
 				    rth->fl.iif != 0 ||
-				    dst_metric_locked(&rth->u.dst, RTAX_MTU) ||
-				    !net_eq(dev_net(rth->u.dst.dev), net) ||
+				    dst_metric_locked(&rth->dst, RTAX_MTU) ||
+				    !net_eq(dev_net(rth->dst.dev), net) ||
 				    rt_is_expired(rth))
 					continue;
 
@@ -1689,22 +1689,22 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 
 					/* BSD 4.2 compatibility hack :-( */
 					if (mtu == 0 &&
-					    old_mtu >= dst_mtu(&rth->u.dst) &&
+					    old_mtu >= dst_mtu(&rth->dst) &&
 					    old_mtu >= 68 + (iph->ihl << 2))
 						old_mtu -= iph->ihl << 2;
 
 					mtu = guess_mtu(old_mtu);
 				}
-				if (mtu <= dst_mtu(&rth->u.dst)) {
-					if (mtu < dst_mtu(&rth->u.dst)) {
-						dst_confirm(&rth->u.dst);
+				if (mtu <= dst_mtu(&rth->dst)) {
+					if (mtu < dst_mtu(&rth->dst)) {
+						dst_confirm(&rth->dst);
 						if (mtu < ip_rt_min_pmtu) {
 							mtu = ip_rt_min_pmtu;
-							rth->u.dst.metrics[RTAX_LOCK-1] |=
+							rth->dst.metrics[RTAX_LOCK-1] |=
 								(1 << RTAX_MTU);
 						}
-						rth->u.dst.metrics[RTAX_MTU-1] = mtu;
-						dst_set_expires(&rth->u.dst,
+						rth->dst.metrics[RTAX_MTU-1] = mtu;
+						dst_set_expires(&rth->dst,
 							ip_rt_mtu_expires);
 					}
 					est_mtu = mtu;
@@ -1777,7 +1777,7 @@ static void ipv4_link_failure(struct sk_buff *skb)
 
 	rt = skb_rtable(skb);
 	if (rt)
-		dst_set_expires(&rt->u.dst, 0);
+		dst_set_expires(&rt->dst, 0);
 }
 
 static int ip_rt_bug(struct sk_buff *skb)
@@ -1805,11 +1805,11 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 
 	if (rt->fl.iif == 0)
 		src = rt->rt_src;
-	else if (fib_lookup(dev_net(rt->u.dst.dev), &rt->fl, &res) == 0) {
+	else if (fib_lookup(dev_net(rt->dst.dev), &rt->fl, &res) == 0) {
 		src = FIB_RES_PREFSRC(res);
 		fib_res_put(&res);
 	} else
-		src = inet_select_addr(rt->u.dst.dev, rt->rt_gateway,
+		src = inet_select_addr(rt->dst.dev, rt->rt_gateway,
 					RT_SCOPE_UNIVERSE);
 	memcpy(addr, &src, 4);
 }
@@ -1817,10 +1817,10 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 #ifdef CONFIG_NET_CLS_ROUTE
 static void set_class_tag(struct rtable *rt, u32 tag)
 {
-	if (!(rt->u.dst.tclassid & 0xFFFF))
-		rt->u.dst.tclassid |= tag & 0xFFFF;
-	if (!(rt->u.dst.tclassid & 0xFFFF0000))
-		rt->u.dst.tclassid |= tag & 0xFFFF0000;
+	if (!(rt->dst.tclassid & 0xFFFF))
+		rt->dst.tclassid |= tag & 0xFFFF;
+	if (!(rt->dst.tclassid & 0xFFFF0000))
+		rt->dst.tclassid |= tag & 0xFFFF0000;
 }
 #endif
 
@@ -1832,30 +1832,30 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 		if (FIB_RES_GW(*res) &&
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
-		memcpy(rt->u.dst.metrics, fi->fib_metrics,
-		       sizeof(rt->u.dst.metrics));
+		memcpy(rt->dst.metrics, fi->fib_metrics,
+		       sizeof(rt->dst.metrics));
 		if (fi->fib_mtu == 0) {
-			rt->u.dst.metrics[RTAX_MTU-1] = rt->u.dst.dev->mtu;
-			if (dst_metric_locked(&rt->u.dst, RTAX_MTU) &&
+			rt->dst.metrics[RTAX_MTU-1] = rt->dst.dev->mtu;
+			if (dst_metric_locked(&rt->dst, RTAX_MTU) &&
 			    rt->rt_gateway != rt->rt_dst &&
-			    rt->u.dst.dev->mtu > 576)
-				rt->u.dst.metrics[RTAX_MTU-1] = 576;
+			    rt->dst.dev->mtu > 576)
+				rt->dst.metrics[RTAX_MTU-1] = 576;
 		}
 #ifdef CONFIG_NET_CLS_ROUTE
-		rt->u.dst.tclassid = FIB_RES_NH(*res).nh_tclassid;
+		rt->dst.tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
 	} else
-		rt->u.dst.metrics[RTAX_MTU-1]= rt->u.dst.dev->mtu;
-
-	if (dst_metric(&rt->u.dst, RTAX_HOPLIMIT) == 0)
-		rt->u.dst.metrics[RTAX_HOPLIMIT-1] = sysctl_ip_default_ttl;
-	if (dst_mtu(&rt->u.dst) > IP_MAX_MTU)
-		rt->u.dst.metrics[RTAX_MTU-1] = IP_MAX_MTU;
-	if (dst_metric(&rt->u.dst, RTAX_ADVMSS) == 0)
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = max_t(unsigned int, rt->u.dst.dev->mtu - 40,
+		rt->dst.metrics[RTAX_MTU-1]= rt->dst.dev->mtu;
+
+	if (dst_metric(&rt->dst, RTAX_HOPLIMIT) == 0)
+		rt->dst.metrics[RTAX_HOPLIMIT-1] = sysctl_ip_default_ttl;
+	if (dst_mtu(&rt->dst) > IP_MAX_MTU)
+		rt->dst.metrics[RTAX_MTU-1] = IP_MAX_MTU;
+	if (dst_metric(&rt->dst, RTAX_ADVMSS) == 0)
+		rt->dst.metrics[RTAX_ADVMSS-1] = max_t(unsigned int, rt->dst.dev->mtu - 40,
 				       ip_rt_min_advmss);
-	if (dst_metric(&rt->u.dst, RTAX_ADVMSS) > 65535 - 40)
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = 65535 - 40;
+	if (dst_metric(&rt->dst, RTAX_ADVMSS) > 65535 - 40)
+		rt->dst.metrics[RTAX_ADVMSS-1] = 65535 - 40;
 
 #ifdef CONFIG_NET_CLS_ROUTE
 #ifdef CONFIG_IP_MULTIPLE_TABLES
@@ -1896,13 +1896,13 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (!rth)
 		goto e_nobufs;
 
-	rth->u.dst.output = ip_rt_bug;
-	rth->u.dst.obsolete = -1;
+	rth->dst.output = ip_rt_bug;
+	rth->dst.obsolete = -1;
 
-	atomic_set(&rth->u.dst.__refcnt, 1);
-	rth->u.dst.flags= DST_HOST;
+	atomic_set(&rth->dst.__refcnt, 1);
+	rth->dst.flags= DST_HOST;
 	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
-		rth->u.dst.flags |= DST_NOPOLICY;
+		rth->dst.flags |= DST_NOPOLICY;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
@@ -1910,13 +1910,13 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->fl.fl4_src	= saddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_NET_CLS_ROUTE
-	rth->u.dst.tclassid = itag;
+	rth->dst.tclassid = itag;
 #endif
 	rth->rt_iif	=
 	rth->fl.iif	= dev->ifindex;
-	rth->u.dst.dev	= init_net.loopback_dev;
-	dev_hold(rth->u.dst.dev);
-	rth->idev	= in_dev_get(rth->u.dst.dev);
+	rth->dst.dev	= init_net.loopback_dev;
+	dev_hold(rth->dst.dev);
+	rth->idev	= in_dev_get(rth->dst.dev);
 	rth->fl.oif	= 0;
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
@@ -1924,13 +1924,13 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
 	if (our) {
-		rth->u.dst.input= ip_local_deliver;
+		rth->dst.input= ip_local_deliver;
 		rth->rt_flags |= RTCF_LOCAL;
 	}
 
 #ifdef CONFIG_IP_MROUTE
 	if (!ipv4_is_local_multicast(daddr) && IN_DEV_MFORWARD(in_dev))
-		rth->u.dst.input = ip_mr_input;
+		rth->dst.input = ip_mr_input;
 #endif
 	RT_CACHE_STAT_INC(in_slow_mc);
 
@@ -2042,12 +2042,12 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
-	atomic_set(&rth->u.dst.__refcnt, 1);
-	rth->u.dst.flags= DST_HOST;
+	atomic_set(&rth->dst.__refcnt, 1);
+	rth->dst.flags= DST_HOST;
 	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
-		rth->u.dst.flags |= DST_NOPOLICY;
+		rth->dst.flags |= DST_NOPOLICY;
 	if (IN_DEV_CONF_GET(out_dev, NOXFRM))
-		rth->u.dst.flags |= DST_NOXFRM;
+		rth->dst.flags |= DST_NOXFRM;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
@@ -2057,16 +2057,16 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_gateway	= daddr;
 	rth->rt_iif 	=
 		rth->fl.iif	= in_dev->dev->ifindex;
-	rth->u.dst.dev	= (out_dev)->dev;
-	dev_hold(rth->u.dst.dev);
-	rth->idev	= in_dev_get(rth->u.dst.dev);
+	rth->dst.dev	= (out_dev)->dev;
+	dev_hold(rth->dst.dev);
+	rth->idev	= in_dev_get(rth->dst.dev);
 	rth->fl.oif 	= 0;
 	rth->rt_spec_dst= spec_dst;
 
-	rth->u.dst.obsolete = -1;
-	rth->u.dst.input = ip_forward;
-	rth->u.dst.output = ip_output;
-	rth->rt_genid = rt_genid(dev_net(rth->u.dst.dev));
+	rth->dst.obsolete = -1;
+	rth->dst.input = ip_forward;
+	rth->dst.output = ip_output;
+	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
 
 	rt_set_nexthop(rth, res, itag);
 
@@ -2102,7 +2102,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 
 	/* put it into the cache */
 	hash = rt_hash(daddr, saddr, fl->iif,
-		       rt_genid(dev_net(rth->u.dst.dev)));
+		       rt_genid(dev_net(rth->dst.dev)));
 	return rt_intern_hash(hash, rth, NULL, skb, fl->iif);
 }
 
@@ -2227,14 +2227,14 @@ local_input:
 	if (!rth)
 		goto e_nobufs;
 
-	rth->u.dst.output= ip_rt_bug;
-	rth->u.dst.obsolete = -1;
+	rth->dst.output= ip_rt_bug;
+	rth->dst.obsolete = -1;
 	rth->rt_genid = rt_genid(net);
 
-	atomic_set(&rth->u.dst.__refcnt, 1);
-	rth->u.dst.flags= DST_HOST;
+	atomic_set(&rth->dst.__refcnt, 1);
+	rth->dst.flags= DST_HOST;
 	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
-		rth->u.dst.flags |= DST_NOPOLICY;
+		rth->dst.flags |= DST_NOPOLICY;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
@@ -2242,20 +2242,20 @@ local_input:
 	rth->fl.fl4_src	= saddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_NET_CLS_ROUTE
-	rth->u.dst.tclassid = itag;
+	rth->dst.tclassid = itag;
 #endif
 	rth->rt_iif	=
 	rth->fl.iif	= dev->ifindex;
-	rth->u.dst.dev	= net->loopback_dev;
-	dev_hold(rth->u.dst.dev);
-	rth->idev	= in_dev_get(rth->u.dst.dev);
+	rth->dst.dev	= net->loopback_dev;
+	dev_hold(rth->dst.dev);
+	rth->idev	= in_dev_get(rth->dst.dev);
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
-	rth->u.dst.input= ip_local_deliver;
+	rth->dst.input= ip_local_deliver;
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	if (res.type == RTN_UNREACHABLE) {
-		rth->u.dst.input= ip_error;
-		rth->u.dst.error= -err;
+		rth->dst.input= ip_error;
+		rth->dst.error= -err;
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
 	rth->rt_type	= res.type;
@@ -2317,19 +2317,19 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	rcu_read_lock();
 	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
-	     rth = rcu_dereference(rth->u.dst.rt_next)) {
+	     rth = rcu_dereference(rth->dst.rt_next)) {
 		if ((((__force u32)rth->fl.fl4_dst ^ (__force u32)daddr) |
 		     ((__force u32)rth->fl.fl4_src ^ (__force u32)saddr) |
 		     (rth->fl.iif ^ iif) |
 		     rth->fl.oif |
 		     (rth->fl.fl4_tos ^ tos)) == 0 &&
 		    rth->fl.mark == skb->mark &&
-		    net_eq(dev_net(rth->u.dst.dev), net) &&
+		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
-			dst_use(&rth->u.dst, jiffies);
+			dst_use(&rth->dst, jiffies);
 			RT_CACHE_STAT_INC(in_hit);
 			rcu_read_unlock();
-			skb_dst_set(skb, &rth->u.dst);
+			skb_dst_set(skb, &rth->dst);
 			return 0;
 		}
 		RT_CACHE_STAT_INC(in_hlist_search);
@@ -2431,12 +2431,12 @@ static int __mkroute_output(struct rtable **result,
 		goto cleanup;
 	}
 
-	atomic_set(&rth->u.dst.__refcnt, 1);
-	rth->u.dst.flags= DST_HOST;
+	atomic_set(&rth->dst.__refcnt, 1);
+	rth->dst.flags= DST_HOST;
 	if (IN_DEV_CONF_GET(in_dev, NOXFRM))
-		rth->u.dst.flags |= DST_NOXFRM;
+		rth->dst.flags |= DST_NOXFRM;
 	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
-		rth->u.dst.flags |= DST_NOPOLICY;
+		rth->dst.flags |= DST_NOPOLICY;
 
 	rth->fl.fl4_dst	= oldflp->fl4_dst;
 	rth->fl.fl4_tos	= tos;
@@ -2448,35 +2448,35 @@ static int __mkroute_output(struct rtable **result,
 	rth->rt_iif	= oldflp->oif ? : dev_out->ifindex;
 	/* get references to the devices that are to be hold by the routing
 	   cache entry */
-	rth->u.dst.dev	= dev_out;
+	rth->dst.dev	= dev_out;
 	dev_hold(dev_out);
 	rth->idev	= in_dev_get(dev_out);
 	rth->rt_gateway = fl->fl4_dst;
 	rth->rt_spec_dst= fl->fl4_src;
 
-	rth->u.dst.output=ip_output;
-	rth->u.dst.obsolete = -1;
+	rth->dst.output=ip_output;
+	rth->dst.obsolete = -1;
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 
 	RT_CACHE_STAT_INC(out_slow_tot);
 
 	if (flags & RTCF_LOCAL) {
-		rth->u.dst.input = ip_local_deliver;
+		rth->dst.input = ip_local_deliver;
 		rth->rt_spec_dst = fl->fl4_dst;
 	}
 	if (flags & (RTCF_BROADCAST | RTCF_MULTICAST)) {
 		rth->rt_spec_dst = fl->fl4_src;
 		if (flags & RTCF_LOCAL &&
 		    !(dev_out->flags & IFF_LOOPBACK)) {
-			rth->u.dst.output = ip_mc_output;
+			rth->dst.output = ip_mc_output;
 			RT_CACHE_STAT_INC(out_slow_mc);
 		}
 #ifdef CONFIG_IP_MROUTE
 		if (res->type == RTN_MULTICAST) {
 			if (IN_DEV_MFORWARD(in_dev) &&
 			    !ipv4_is_local_multicast(oldflp->fl4_dst)) {
-				rth->u.dst.input = ip_mr_input;
-				rth->u.dst.output = ip_mc_output;
+				rth->dst.input = ip_mr_input;
+				rth->dst.output = ip_mc_output;
 			}
 		}
 #endif
@@ -2731,7 +2731,7 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 
 	rcu_read_lock_bh();
 	for (rth = rcu_dereference_bh(rt_hash_table[hash].chain); rth;
-		rth = rcu_dereference_bh(rth->u.dst.rt_next)) {
+		rth = rcu_dereference_bh(rth->dst.rt_next)) {
 		if (rth->fl.fl4_dst == flp->fl4_dst &&
 		    rth->fl.fl4_src == flp->fl4_src &&
 		    rth->fl.iif == 0 &&
@@ -2739,9 +2739,9 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 		    rth->fl.mark == flp->mark &&
 		    !((rth->fl.fl4_tos ^ flp->fl4_tos) &
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
-		    net_eq(dev_net(rth->u.dst.dev), net) &&
+		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
-			dst_use(&rth->u.dst, jiffies);
+			dst_use(&rth->dst, jiffies);
 			RT_CACHE_STAT_INC(out_hit);
 			rcu_read_unlock_bh();
 			*rp = rth;
@@ -2778,15 +2778,15 @@ static int ipv4_dst_blackhole(struct net *net, struct rtable **rp, struct flowi
 		dst_alloc(&ipv4_dst_blackhole_ops);
 
 	if (rt) {
-		struct dst_entry *new = &rt->u.dst;
+		struct dst_entry *new = &rt->dst;
 
 		atomic_set(&new->__refcnt, 1);
 		new->__use = 1;
 		new->input = dst_discard;
 		new->output = dst_discard;
-		memcpy(new->metrics, ort->u.dst.metrics, RTAX_MAX*sizeof(u32));
+		memcpy(new->metrics, ort->dst.metrics, RTAX_MAX*sizeof(u32));
 
-		new->dev = ort->u.dst.dev;
+		new->dev = ort->dst.dev;
 		if (new->dev)
 			dev_hold(new->dev);
 
@@ -2810,7 +2810,7 @@ static int ipv4_dst_blackhole(struct net *net, struct rtable **rp, struct flowi
 		dst_free(new);
 	}
 
-	dst_release(&(*rp)->u.dst);
+	dst_release(&(*rp)->dst);
 	*rp = rt;
 	return (rt ? 0 : -ENOMEM);
 }
@@ -2880,11 +2880,11 @@ static int rt_fill_info(struct net *net,
 		r->rtm_src_len = 32;
 		NLA_PUT_BE32(skb, RTA_SRC, rt->fl.fl4_src);
 	}
-	if (rt->u.dst.dev)
-		NLA_PUT_U32(skb, RTA_OIF, rt->u.dst.dev->ifindex);
+	if (rt->dst.dev)
+		NLA_PUT_U32(skb, RTA_OIF, rt->dst.dev->ifindex);
 #ifdef CONFIG_NET_CLS_ROUTE
-	if (rt->u.dst.tclassid)
-		NLA_PUT_U32(skb, RTA_FLOW, rt->u.dst.tclassid);
+	if (rt->dst.tclassid)
+		NLA_PUT_U32(skb, RTA_FLOW, rt->dst.tclassid);
 #endif
 	if (rt->fl.iif)
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_spec_dst);
@@ -2894,11 +2894,11 @@ static int rt_fill_info(struct net *net,
 	if (rt->rt_dst != rt->rt_gateway)
 		NLA_PUT_BE32(skb, RTA_GATEWAY, rt->rt_gateway);
 
-	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
+	if (rtnetlink_put_metrics(skb, rt->dst.metrics) < 0)
 		goto nla_put_failure;
 
-	error = rt->u.dst.error;
-	expires = rt->u.dst.expires ? rt->u.dst.expires - jiffies : 0;
+	error = rt->dst.error;
+	expires = rt->dst.expires ? rt->dst.expires - jiffies : 0;
 	if (rt->peer) {
 		id = atomic_read(&rt->peer->ip_id_count) & 0xffff;
 		if (rt->peer->tcp_ts_stamp) {
@@ -2930,7 +2930,7 @@ static int rt_fill_info(struct net *net,
 			NLA_PUT_U32(skb, RTA_IIF, rt->fl.iif);
 	}
 
-	if (rtnl_put_cacheinfo(skb, &rt->u.dst, id, ts, tsage,
+	if (rtnl_put_cacheinfo(skb, &rt->dst, id, ts, tsage,
 			       expires, error) < 0)
 		goto nla_put_failure;
 
@@ -2995,8 +2995,8 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 		local_bh_enable();
 
 		rt = skb_rtable(skb);
-		if (err == 0 && rt->u.dst.error)
-			err = -rt->u.dst.error;
+		if (err == 0 && rt->dst.error)
+			err = -rt->dst.error;
 	} else {
 		struct flowi fl = {
 			.nl_u = {
@@ -3014,7 +3014,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	if (err)
 		goto errout_free;
 
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
@@ -3050,12 +3050,12 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 			continue;
 		rcu_read_lock_bh();
 		for (rt = rcu_dereference_bh(rt_hash_table[h].chain), idx = 0; rt;
-		     rt = rcu_dereference_bh(rt->u.dst.rt_next), idx++) {
-			if (!net_eq(dev_net(rt->u.dst.dev), net) || idx < s_idx)
+		     rt = rcu_dereference_bh(rt->dst.rt_next), idx++) {
+			if (!net_eq(dev_net(rt->dst.dev), net) || idx < s_idx)
 				continue;
 			if (rt_is_expired(rt))
 				continue;
-			skb_dst_set(skb, dst_clone(&rt->u.dst));
+			skb_dst_set(skb, dst_clone(&rt->dst));
 			if (rt_fill_info(net, skb, NETLINK_CB(cb->skb).pid,
 					 cb->nlh->nlmsg_seq, RTM_NEWROUTE,
 					 1, NLM_F_MULTI) <= 0) {
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 5c24db4..0aabcea 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -354,15 +354,15 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	}
 
 	/* Try to redo what tcp_v4_send_synack did. */
-	req->window_clamp = tp->window_clamp ? :dst_metric(&rt->u.dst, RTAX_WINDOW);
+	req->window_clamp = tp->window_clamp ? :dst_metric(&rt->dst, RTAX_WINDOW);
 
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rcv_wnd, &req->window_clamp,
 				  ireq->wscale_ok, &rcv_wscale,
-				  dst_metric(&rt->u.dst, RTAX_INITRWND));
+				  dst_metric(&rt->dst, RTAX_INITRWND));
 
 	ireq->rcv_wscale  = rcv_wscale;
 
-	ret = get_cookie_sock(sk, skb, req, &rt->u.dst);
+	ret = get_cookie_sock(sk, skb, req, &rt->dst);
 out:	return ret;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 771f814..a8ece90 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -237,7 +237,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	/* OK, now commit destination to socket.  */
 	sk->sk_gso_type = SKB_GSO_TCPV4;
-	sk_setup_caps(sk, &rt->u.dst);
+	sk_setup_caps(sk, &rt->dst);
 
 	if (!tp->write_seq)
 		tp->write_seq = secure_tcp_sequence_number(inet->inet_saddr,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4560b29..8ba1a33 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -913,7 +913,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		    !sock_flag(sk, SOCK_BROADCAST))
 			goto out;
 		if (connected)
-			sk_dst_set(sk, dst_clone(&rt->u.dst));
+			sk_dst_set(sk, dst_clone(&rt->dst));
 	}
 
 	if (msg->msg_flags&MSG_CONFIRM)
@@ -977,7 +977,7 @@ out:
 	return err;
 
 do_confirm:
-	dst_confirm(&rt->u.dst);
+	dst_confirm(&rt->dst);
 	if (!(msg->msg_flags&MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 1705476..3493270 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -37,7 +37,7 @@ static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
 		fl.fl4_src = saddr->a4;
 
 	err = __ip_route_output_key(net, &rt, &fl);
-	dst = &rt->u.dst;
+	dst = &rt->dst;
 	if (err)
 		dst = ERR_PTR(err);
 	return dst;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 34d2d64..0f0e57a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -557,7 +557,7 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 		pr_warning("Freeing alive inet6 address %p\n", ifp);
 		return;
 	}
-	dst_release(&ifp->rt->u.dst);
+	dst_release(&ifp->rt->dst);
 
 	call_rcu(&ifp->rcu, inet6_ifa_finish_destroy_rcu);
 }
@@ -815,7 +815,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 				rt->rt6i_flags |= RTF_EXPIRES;
 			}
 		}
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 	}
 
 	in6_ifa_put(ifp);
@@ -1836,7 +1836,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 					      dev, expires, flags);
 		}
 		if (rt)
-			dst_release(&rt->u.dst);
+			dst_release(&rt->dst);
 	}
 
 	/* Try to figure out our local address for this prefix */
@@ -4047,10 +4047,10 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 		if (ifp->idev->cnf.forwarding)
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
-		dst_hold(&ifp->rt->u.dst);
+		dst_hold(&ifp->rt->dst);
 
 		if (ifp->dead && ip6_del_rt(ifp->rt))
-			dst_free(&ifp->rt->u.dst);
+			dst_free(&ifp->rt->dst);
 		break;
 	}
 }
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index b5b0705..db4e0f5 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -84,7 +84,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, struct in6_addr *addr)
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
-			dst_release(&rt->u.dst);
+			dst_release(&rt->dst);
 		} else if (ishost) {
 			err = -EADDRNOTAVAIL;
 			goto out_free_pac;
@@ -250,7 +250,7 @@ static void aca_put(struct ifacaddr6 *ac)
 {
 	if (atomic_dec_and_test(&ac->aca_refcnt)) {
 		in6_dev_put(ac->aca_idev);
-		dst_release(&ac->aca_rt->u.dst);
+		dst_release(&ac->aca_rt->dst);
 		kfree(ac);
 	}
 }
@@ -356,7 +356,7 @@ int __ipv6_dev_ac_dec(struct inet6_dev *idev, struct in6_addr *addr)
 	write_unlock_bh(&idev->lock);
 	addrconf_leave_solict(idev, &aca->aca_addr);
 
-	dst_hold(&aca->aca_rt->u.dst);
+	dst_hold(&aca->aca_rt->dst);
 	ip6_del_rt(aca->aca_rt);
 
 	aca_put(aca);
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 8e44f8f..b1108ed 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -43,8 +43,8 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
 	if (arg.result)
 		return arg.result;
 
-	dst_hold(&net->ipv6.ip6_null_entry->u.dst);
-	return &net->ipv6.ip6_null_entry->u.dst;
+	dst_hold(&net->ipv6.ip6_null_entry->dst);
+	return &net->ipv6.ip6_null_entry->dst;
 }
 
 static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
@@ -86,7 +86,7 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 			struct in6_addr saddr;
 
 			if (ipv6_dev_get_saddr(net,
-					       ip6_dst_idev(&rt->u.dst)->dev,
+					       ip6_dst_idev(&rt->dst)->dev,
 					       &flp->fl6_dst,
 					       rt6_flags2srcprefs(flags),
 					       &saddr))
@@ -99,12 +99,12 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 		goto out;
 	}
 again:
-	dst_release(&rt->u.dst);
+	dst_release(&rt->dst);
 	rt = NULL;
 	goto out;
 
 discard_pkt:
-	dst_hold(&rt->u.dst);
+	dst_hold(&rt->dst);
 out:
 	arg->result = rt;
 	return rt == NULL ? -EAGAIN : 0;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 92a122b..b6a5859 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -165,7 +165,7 @@ static __inline__ void node_free(struct fib6_node * fn)
 static __inline__ void rt6_release(struct rt6_info *rt)
 {
 	if (atomic_dec_and_test(&rt->rt6i_ref))
-		dst_free(&rt->u.dst);
+		dst_free(&rt->dst);
 }
 
 static void fib6_link_table(struct net *net, struct fib6_table *tb)
@@ -278,7 +278,7 @@ static int fib6_dump_node(struct fib6_walker_t *w)
 	int res;
 	struct rt6_info *rt;
 
-	for (rt = w->leaf; rt; rt = rt->u.dst.rt6_next) {
+	for (rt = w->leaf; rt; rt = rt->dst.rt6_next) {
 		res = rt6_dump_route(rt, w->args);
 		if (res < 0) {
 			/* Frame is full, suspend walking */
@@ -619,7 +619,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 
 	ins = &fn->leaf;
 
-	for (iter = fn->leaf; iter; iter=iter->u.dst.rt6_next) {
+	for (iter = fn->leaf; iter; iter=iter->dst.rt6_next) {
 		/*
 		 *	Search for duplicates
 		 */
@@ -647,7 +647,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		if (iter->rt6i_metric > rt->rt6i_metric)
 			break;
 
-		ins = &iter->u.dst.rt6_next;
+		ins = &iter->dst.rt6_next;
 	}
 
 	/* Reset round-robin state, if necessary */
@@ -658,7 +658,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 	 *	insert node
 	 */
 
-	rt->u.dst.rt6_next = iter;
+	rt->dst.rt6_next = iter;
 	*ins = rt;
 	rt->rt6i_node = fn;
 	atomic_inc(&rt->rt6i_ref);
@@ -799,7 +799,7 @@ out:
 			atomic_inc(&pn->leaf->rt6i_ref);
 		}
 #endif
-		dst_free(&rt->u.dst);
+		dst_free(&rt->dst);
 	}
 	return err;
 
@@ -810,7 +810,7 @@ out:
 st_failure:
 	if (fn && !(fn->fn_flags & (RTN_RTINFO|RTN_ROOT)))
 		fib6_repair_tree(info->nl_net, fn);
-	dst_free(&rt->u.dst);
+	dst_free(&rt->dst);
 	return err;
 #endif
 }
@@ -1108,7 +1108,7 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 	RT6_TRACE("fib6_del_route\n");
 
 	/* Unlink it */
-	*rtp = rt->u.dst.rt6_next;
+	*rtp = rt->dst.rt6_next;
 	rt->rt6i_node = NULL;
 	net->ipv6.rt6_stats->fib_rt_entries--;
 	net->ipv6.rt6_stats->fib_discarded_routes++;
@@ -1122,14 +1122,14 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 	FOR_WALKERS(w) {
 		if (w->state == FWS_C && w->leaf == rt) {
 			RT6_TRACE("walker %p adjusted by delroute\n", w);
-			w->leaf = rt->u.dst.rt6_next;
+			w->leaf = rt->dst.rt6_next;
 			if (w->leaf == NULL)
 				w->state = FWS_U;
 		}
 	}
 	read_unlock(&fib6_walker_lock);
 
-	rt->u.dst.rt6_next = NULL;
+	rt->dst.rt6_next = NULL;
 
 	/* If it was last route, expunge its radix tree node */
 	if (fn->leaf == NULL) {
@@ -1168,7 +1168,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 	struct rt6_info **rtp;
 
 #if RT6_DEBUG >= 2
-	if (rt->u.dst.obsolete>0) {
+	if (rt->dst.obsolete>0) {
 		WARN_ON(fn != NULL);
 		return -ENOENT;
 	}
@@ -1195,7 +1195,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 	 *	Walk the leaf entries looking for ourself
 	 */
 
-	for (rtp = &fn->leaf; *rtp; rtp = &(*rtp)->u.dst.rt6_next) {
+	for (rtp = &fn->leaf; *rtp; rtp = &(*rtp)->dst.rt6_next) {
 		if (*rtp == rt) {
 			fib6_del_route(fn, rtp, info);
 			return 0;
@@ -1334,7 +1334,7 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 		.nl_net = c->net,
 	};
 
-	for (rt = w->leaf; rt; rt = rt->u.dst.rt6_next) {
+	for (rt = w->leaf; rt; rt = rt->dst.rt6_next) {
 		res = c->func(rt, c->arg);
 		if (res < 0) {
 			w->leaf = rt;
@@ -1448,8 +1448,8 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 		}
 		gc_args.more++;
 	} else if (rt->rt6i_flags & RTF_CACHE) {
-		if (atomic_read(&rt->u.dst.__refcnt) == 0 &&
-		    time_after_eq(now, rt->u.dst.lastuse + gc_args.timeout)) {
+		if (atomic_read(&rt->dst.__refcnt) == 0 &&
+		    time_after_eq(now, rt->dst.lastuse + gc_args.timeout)) {
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
 		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e7a5f17..7ec9202 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -700,7 +700,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		ipv6_hdr(skb)->payload_len = htons(first_len -
 						   sizeof(struct ipv6hdr));
 
-		dst_hold(&rt->u.dst);
+		dst_hold(&rt->dst);
 
 		for (;;) {
 			/* Prepare header of the next frame,
@@ -728,7 +728,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 			err = output(skb);
 			if(!err)
-				IP6_INC_STATS(net, ip6_dst_idev(&rt->u.dst),
+				IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 					      IPSTATS_MIB_FRAGCREATES);
 
 			if (err || !frag)
@@ -742,9 +742,9 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		kfree(tmp_hdr);
 
 		if (err == 0) {
-			IP6_INC_STATS(net, ip6_dst_idev(&rt->u.dst),
+			IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 				      IPSTATS_MIB_FRAGOKS);
-			dst_release(&rt->u.dst);
+			dst_release(&rt->dst);
 			return 0;
 		}
 
@@ -754,9 +754,9 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			frag = skb;
 		}
 
-		IP6_INC_STATS(net, ip6_dst_idev(&rt->u.dst),
+		IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 			      IPSTATS_MIB_FRAGFAILS);
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 		return err;
 	}
 
@@ -787,7 +787,7 @@ slow_path:
 		 *	Allocate buffer.
 		 */
 
-		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_ALLOCATED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
+		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_ALLOCATED_SPACE(rt->dst.dev), GFP_ATOMIC)) == NULL) {
 			NETDEBUG(KERN_INFO "IPv6: frag: no memory for new fragment!\n");
 			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 				      IPSTATS_MIB_FRAGFAILS);
@@ -800,7 +800,7 @@ slow_path:
 		 */
 
 		ip6_copy_metadata(frag, skb);
-		skb_reserve(frag, LL_RESERVED_SPACE(rt->u.dst.dev));
+		skb_reserve(frag, LL_RESERVED_SPACE(rt->dst.dev));
 		skb_put(frag, len + hlen + sizeof(struct frag_hdr));
 		skb_reset_network_header(frag);
 		fh = (struct frag_hdr *)(skb_network_header(frag) + hlen);
@@ -1158,24 +1158,24 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 
 			/* need source address above miyazawa*/
 		}
-		dst_hold(&rt->u.dst);
-		inet->cork.dst = &rt->u.dst;
+		dst_hold(&rt->dst);
+		inet->cork.dst = &rt->dst;
 		inet->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
 		mtu = np->pmtudisc == IPV6_PMTUDISC_PROBE ?
-		      rt->u.dst.dev->mtu : dst_mtu(rt->u.dst.path);
+		      rt->dst.dev->mtu : dst_mtu(rt->dst.path);
 		if (np->frag_size < mtu) {
 			if (np->frag_size)
 				mtu = np->frag_size;
 		}
 		inet->cork.fragsize = mtu;
-		if (dst_allfrag(rt->u.dst.path))
+		if (dst_allfrag(rt->dst.path))
 			inet->cork.flags |= IPCORK_ALLFRAG;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
-		exthdrlen = rt->u.dst.header_len + (opt ? opt->opt_flen : 0) -
+		exthdrlen = rt->dst.header_len + (opt ? opt->opt_flen : 0) -
 			    rt->rt6i_nfheader_len;
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
@@ -1188,7 +1188,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		mtu = inet->cork.fragsize;
 	}
 
-	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
+	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
 
 	fragheaderlen = sizeof(struct ipv6hdr) + rt->rt6i_nfheader_len +
 			(opt ? opt->opt_nflen : 0);
@@ -1226,7 +1226,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		}
 
 		if (proto == IPPROTO_UDP &&
-		    (rt->u.dst.dev->features & NETIF_F_UFO)) {
+		    (rt->dst.dev->features & NETIF_F_UFO)) {
 
 			err = ip6_ufo_append_data(sk, getfrag, from, length,
 						  hh_len, fragheaderlen,
@@ -1272,7 +1272,7 @@ alloc_new_skb:
 
 			fraglen = datalen + fragheaderlen;
 			if ((flags & MSG_MORE) &&
-			    !(rt->u.dst.dev->features&NETIF_F_SG))
+			    !(rt->dst.dev->features&NETIF_F_SG))
 				alloclen = mtu;
 			else
 				alloclen = datalen + fragheaderlen;
@@ -1283,7 +1283,7 @@ alloc_new_skb:
 			 * because we have no idea if we're the last one.
 			 */
 			if (datalen == length + fraggap)
-				alloclen += rt->u.dst.trailer_len;
+				alloclen += rt->dst.trailer_len;
 
 			/*
 			 * We just reserve space for fragment header.
@@ -1360,7 +1360,7 @@ alloc_new_skb:
 		if (copy > length)
 			copy = length;
 
-		if (!(rt->u.dst.dev->features&NETIF_F_SG)) {
+		if (!(rt->dst.dev->features&NETIF_F_SG)) {
 			unsigned int off;
 
 			off = skb->len;
@@ -1505,7 +1505,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
-	skb_dst_set(skb, dst_clone(&rt->u.dst));
+	skb_dst_set(skb, dst_clone(&rt->dst));
 	IP6_UPD_PO_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
 	if (proto == IPPROTO_ICMPV6) {
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2599870..0b6443b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -552,7 +552,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (ip_route_output_key(dev_net(skb->dev), &rt, &fl))
 		goto out;
 
-	skb2->dev = rt->u.dst.dev;
+	skb2->dev = rt->dst.dev;
 
 	/* route "incoming" packet */
 	if (rt->rt_flags & RTCF_LOCAL) {
@@ -562,7 +562,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		fl.fl4_src = eiph->saddr;
 		fl.fl4_tos = eiph->tos;
 		if (ip_route_output_key(dev_net(skb->dev), &rt, &fl) ||
-		    rt->u.dst.dev->type != ARPHRD_TUNNEL) {
+		    rt->dst.dev->type != ARPHRD_TUNNEL) {
 			ip_rt_put(rt);
 			goto out;
 		}
@@ -626,7 +626,7 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		icmpv6_send(skb2, rel_type, rel_code, rel_info);
 
 		if (rt)
-			dst_release(&rt->u.dst);
+			dst_release(&rt->dst);
 
 		kfree_skb(skb2);
 	}
@@ -1139,7 +1139,7 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 			if (dev->mtu < IPV6_MIN_MTU)
 				dev->mtu = IPV6_MIN_MTU;
 		}
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 	}
 }
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 006aee6..423c971 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -158,7 +158,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
-			dst_release(&rt->u.dst);
+			dst_release(&rt->dst);
 		}
 	} else
 		dev = dev_get_by_index(net, ifindex);
@@ -248,7 +248,7 @@ static struct inet6_dev *ip6_mc_find_dev(struct net *net,
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
-			dst_release(&rt->u.dst);
+			dst_release(&rt->dst);
 		}
 	} else
 		dev = dev_get_by_index(net, ifindex);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index da0a4d2..80bf00f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1231,7 +1231,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			ND_PRINTK0(KERN_ERR
 				   "ICMPv6 RA: %s() got default router without neighbour.\n",
 				   __func__);
-			dst_release(&rt->u.dst);
+			dst_release(&rt->dst);
 			in6_dev_put(in6_dev);
 			return;
 		}
@@ -1246,7 +1246,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	if (ra_msg->icmph.icmp6_hop_limit) {
 		in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
 		if (rt)
-			rt->u.dst.metrics[RTAX_HOPLIMIT-1] = ra_msg->icmph.icmp6_hop_limit;
+			rt->dst.metrics[RTAX_HOPLIMIT-1] = ra_msg->icmph.icmp6_hop_limit;
 	}
 
 skip_defrtr:
@@ -1365,7 +1365,7 @@ skip_linkparms:
 			in6_dev->cnf.mtu6 = mtu;
 
 			if (rt)
-				rt->u.dst.metrics[RTAX_MTU-1] = mtu;
+				rt->dst.metrics[RTAX_MTU-1] = mtu;
 
 			rt6_mtu_change(skb->dev, mtu);
 		}
@@ -1386,7 +1386,7 @@ skip_linkparms:
 	}
 out:
 	if (rt)
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 	else if (neigh)
 		neigh_release(neigh);
 	in6_dev_put(in6_dev);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 0e3d2dd..1b59ef0 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -610,23 +610,23 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	struct sk_buff *skb;
 	int err;
 
-	if (length > rt->u.dst.dev->mtu) {
-		ipv6_local_error(sk, EMSGSIZE, fl, rt->u.dst.dev->mtu);
+	if (length > rt->dst.dev->mtu) {
+		ipv6_local_error(sk, EMSGSIZE, fl, rt->dst.dev->mtu);
 		return -EMSGSIZE;
 	}
 	if (flags&MSG_PROBE)
 		goto out;
 
 	skb = sock_alloc_send_skb(sk,
-				  length + LL_ALLOCATED_SPACE(rt->u.dst.dev) + 15,
+				  length + LL_ALLOCATED_SPACE(rt->dst.dev) + 15,
 				  flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto error;
-	skb_reserve(skb, LL_RESERVED_SPACE(rt->u.dst.dev));
+	skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
-	skb_dst_set(skb, dst_clone(&rt->u.dst));
+	skb_dst_set(skb, dst_clone(&rt->dst));
 
 	skb_put(skb, length);
 	skb_reset_network_header(skb);
@@ -640,7 +640,7 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 		goto error_fault;
 
 	IP6_UPD_PO_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
-	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
+	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, rt->dst.dev,
 		      dst_output);
 	if (err > 0)
 		err = net_xmit_errno(err);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 05ebd78..413d8c4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -249,7 +249,7 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 	if (!oif && ipv6_addr_any(saddr))
 		goto out;
 
-	for (sprt = rt; sprt; sprt = sprt->u.dst.rt6_next) {
+	for (sprt = rt; sprt; sprt = sprt->dst.rt6_next) {
 		struct net_device *dev = sprt->rt6i_dev;
 
 		if (oif) {
@@ -408,10 +408,10 @@ static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
 
 	match = NULL;
 	for (rt = rr_head; rt && rt->rt6i_metric == metric;
-	     rt = rt->u.dst.rt6_next)
+	     rt = rt->dst.rt6_next)
 		match = find_match(rt, oif, strict, &mpri, match);
 	for (rt = fn->leaf; rt && rt != rr_head && rt->rt6i_metric == metric;
-	     rt = rt->u.dst.rt6_next)
+	     rt = rt->dst.rt6_next)
 		match = find_match(rt, oif, strict, &mpri, match);
 
 	return match;
@@ -433,7 +433,7 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 
 	if (!match &&
 	    (strict & RT6_LOOKUP_F_REACHABLE)) {
-		struct rt6_info *next = rt0->u.dst.rt6_next;
+		struct rt6_info *next = rt0->dst.rt6_next;
 
 		/* no entries matched; do round-robin */
 		if (!next || next->rt6i_metric != rt0->rt6i_metric)
@@ -518,7 +518,7 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 			rt->rt6i_expires = jiffies + HZ * lifetime;
 			rt->rt6i_flags |= RTF_EXPIRES;
 		}
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 	}
 	return 0;
 }
@@ -556,7 +556,7 @@ restart:
 	rt = rt6_device_match(net, rt, &fl->fl6_src, fl->oif, flags);
 	BACKTRACK(net, &fl->fl6_src);
 out:
-	dst_use(&rt->u.dst, jiffies);
+	dst_use(&rt->dst, jiffies);
 	read_unlock_bh(&table->tb6_lock);
 	return rt;
 
@@ -644,7 +644,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, struct in6_addr *dad
 		ipv6_addr_copy(&rt->rt6i_dst.addr, daddr);
 		rt->rt6i_dst.plen = 128;
 		rt->rt6i_flags |= RTF_CACHE;
-		rt->u.dst.flags |= DST_HOST;
+		rt->dst.flags |= DST_HOST;
 
 #ifdef CONFIG_IPV6_SUBTREES
 		if (rt->rt6i_src.plen && saddr) {
@@ -678,7 +678,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, struct in6_addr *dad
 			if (net_ratelimit())
 				printk(KERN_WARNING
 				       "Neighbour table overflow.\n");
-			dst_free(&rt->u.dst);
+			dst_free(&rt->dst);
 			return NULL;
 		}
 		rt->rt6i_nexthop = neigh;
@@ -695,7 +695,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, struct in6_addr *d
 		ipv6_addr_copy(&rt->rt6i_dst.addr, daddr);
 		rt->rt6i_dst.plen = 128;
 		rt->rt6i_flags |= RTF_CACHE;
-		rt->u.dst.flags |= DST_HOST;
+		rt->dst.flags |= DST_HOST;
 		rt->rt6i_nexthop = neigh_clone(ort->rt6i_nexthop);
 	}
 	return rt;
@@ -727,7 +727,7 @@ restart:
 	    rt->rt6i_flags & RTF_CACHE)
 		goto out;
 
-	dst_hold(&rt->u.dst);
+	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
@@ -740,10 +740,10 @@ restart:
 #endif
 	}
 
-	dst_release(&rt->u.dst);
+	dst_release(&rt->dst);
 	rt = nrt ? : net->ipv6.ip6_null_entry;
 
-	dst_hold(&rt->u.dst);
+	dst_hold(&rt->dst);
 	if (nrt) {
 		err = ip6_ins_rt(nrt);
 		if (!err)
@@ -757,7 +757,7 @@ restart:
 	 * Race condition! In the gap, when table->tb6_lock was
 	 * released someone could insert this route.  Relookup.
 	 */
-	dst_release(&rt->u.dst);
+	dst_release(&rt->dst);
 	goto relookup;
 
 out:
@@ -765,11 +765,11 @@ out:
 		reachable = 0;
 		goto restart_2;
 	}
-	dst_hold(&rt->u.dst);
+	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 out2:
-	rt->u.dst.lastuse = jiffies;
-	rt->u.dst.__use++;
+	rt->dst.lastuse = jiffies;
+	rt->dst.__use++;
 
 	return rt;
 }
@@ -836,15 +836,15 @@ int ip6_dst_blackhole(struct sock *sk, struct dst_entry **dstp, struct flowi *fl
 	struct dst_entry *new = NULL;
 
 	if (rt) {
-		new = &rt->u.dst;
+		new = &rt->dst;
 
 		atomic_set(&new->__refcnt, 1);
 		new->__use = 1;
 		new->input = dst_discard;
 		new->output = dst_discard;
 
-		memcpy(new->metrics, ort->u.dst.metrics, RTAX_MAX*sizeof(u32));
-		new->dev = ort->u.dst.dev;
+		memcpy(new->metrics, ort->dst.metrics, RTAX_MAX*sizeof(u32));
+		new->dev = ort->dst.dev;
 		if (new->dev)
 			dev_hold(new->dev);
 		rt->rt6i_idev = ort->rt6i_idev;
@@ -913,7 +913,7 @@ static void ip6_link_failure(struct sk_buff *skb)
 	rt = (struct rt6_info *) skb_dst(skb);
 	if (rt) {
 		if (rt->rt6i_flags&RTF_CACHE) {
-			dst_set_expires(&rt->u.dst, 0);
+			dst_set_expires(&rt->dst, 0);
 			rt->rt6i_flags |= RTF_EXPIRES;
 		} else if (rt->rt6i_node && (rt->rt6i_flags & RTF_DEFAULT))
 			rt->rt6i_node->fn_sernum = -1;
@@ -987,14 +987,14 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt->rt6i_dev	  = dev;
 	rt->rt6i_idev     = idev;
 	rt->rt6i_nexthop  = neigh;
-	atomic_set(&rt->u.dst.__refcnt, 1);
-	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = 255;
-	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
-	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->u.dst));
-	rt->u.dst.output  = ip6_output;
+	atomic_set(&rt->dst.__refcnt, 1);
+	rt->dst.metrics[RTAX_HOPLIMIT-1] = 255;
+	rt->dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
+	rt->dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->dst));
+	rt->dst.output  = ip6_output;
 
 #if 0	/* there's no chance to use these for ndisc */
-	rt->u.dst.flags   = ipv6_addr_type(addr) & IPV6_ADDR_UNICAST
+	rt->dst.flags   = ipv6_addr_type(addr) & IPV6_ADDR_UNICAST
 				? DST_HOST
 				: 0;
 	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
@@ -1002,14 +1002,14 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 #endif
 
 	spin_lock_bh(&icmp6_dst_lock);
-	rt->u.dst.next = icmp6_dst_gc_list;
-	icmp6_dst_gc_list = &rt->u.dst;
+	rt->dst.next = icmp6_dst_gc_list;
+	icmp6_dst_gc_list = &rt->dst;
 	spin_unlock_bh(&icmp6_dst_lock);
 
 	fib6_force_start_gc(net);
 
 out:
-	return &rt->u.dst;
+	return &rt->dst;
 }
 
 int icmp6_dst_gc(void)
@@ -1160,7 +1160,7 @@ int ip6_route_add(struct fib6_config *cfg)
 		goto out;
 	}
 
-	rt->u.dst.obsolete = -1;
+	rt->dst.obsolete = -1;
 	rt->rt6i_expires = (cfg->fc_flags & RTF_EXPIRES) ?
 				jiffies + clock_t_to_jiffies(cfg->fc_expires) :
 				0;
@@ -1172,16 +1172,16 @@ int ip6_route_add(struct fib6_config *cfg)
 	addr_type = ipv6_addr_type(&cfg->fc_dst);
 
 	if (addr_type & IPV6_ADDR_MULTICAST)
-		rt->u.dst.input = ip6_mc_input;
+		rt->dst.input = ip6_mc_input;
 	else
-		rt->u.dst.input = ip6_forward;
+		rt->dst.input = ip6_forward;
 
-	rt->u.dst.output = ip6_output;
+	rt->dst.output = ip6_output;
 
 	ipv6_addr_prefix(&rt->rt6i_dst.addr, &cfg->fc_dst, cfg->fc_dst_len);
 	rt->rt6i_dst.plen = cfg->fc_dst_len;
 	if (rt->rt6i_dst.plen == 128)
-	       rt->u.dst.flags = DST_HOST;
+	       rt->dst.flags = DST_HOST;
 
 #ifdef CONFIG_IPV6_SUBTREES
 	ipv6_addr_prefix(&rt->rt6i_src.addr, &cfg->fc_src, cfg->fc_src_len);
@@ -1209,9 +1209,9 @@ int ip6_route_add(struct fib6_config *cfg)
 				goto out;
 			}
 		}
-		rt->u.dst.output = ip6_pkt_discard_out;
-		rt->u.dst.input = ip6_pkt_discard;
-		rt->u.dst.error = -ENETUNREACH;
+		rt->dst.output = ip6_pkt_discard_out;
+		rt->dst.input = ip6_pkt_discard;
+		rt->dst.error = -ENETUNREACH;
 		rt->rt6i_flags = RTF_REJECT|RTF_NONEXTHOP;
 		goto install_route;
 	}
@@ -1245,7 +1245,7 @@ int ip6_route_add(struct fib6_config *cfg)
 				goto out;
 			if (dev) {
 				if (dev != grt->rt6i_dev) {
-					dst_release(&grt->u.dst);
+					dst_release(&grt->dst);
 					goto out;
 				}
 			} else {
@@ -1256,7 +1256,7 @@ int ip6_route_add(struct fib6_config *cfg)
 			}
 			if (!(grt->rt6i_flags&RTF_GATEWAY))
 				err = 0;
-			dst_release(&grt->u.dst);
+			dst_release(&grt->dst);
 
 			if (err)
 				goto out;
@@ -1295,18 +1295,18 @@ install_route:
 					goto out;
 				}
 
-				rt->u.dst.metrics[type - 1] = nla_get_u32(nla);
+				rt->dst.metrics[type - 1] = nla_get_u32(nla);
 			}
 		}
 	}
 
-	if (dst_metric(&rt->u.dst, RTAX_HOPLIMIT) == 0)
-		rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
-	if (!dst_mtu(&rt->u.dst))
-		rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(dev);
-	if (!dst_metric(&rt->u.dst, RTAX_ADVMSS))
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->u.dst));
-	rt->u.dst.dev = dev;
+	if (dst_metric(&rt->dst, RTAX_HOPLIMIT) == 0)
+		rt->dst.metrics[RTAX_HOPLIMIT-1] = -1;
+	if (!dst_mtu(&rt->dst))
+		rt->dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(dev);
+	if (!dst_metric(&rt->dst, RTAX_ADVMSS))
+		rt->dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->dst));
+	rt->dst.dev = dev;
 	rt->rt6i_idev = idev;
 	rt->rt6i_table = table;
 
@@ -1320,7 +1320,7 @@ out:
 	if (idev)
 		in6_dev_put(idev);
 	if (rt)
-		dst_free(&rt->u.dst);
+		dst_free(&rt->dst);
 	return err;
 }
 
@@ -1337,7 +1337,7 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 	write_lock_bh(&table->tb6_lock);
 
 	err = fib6_del(rt, info);
-	dst_release(&rt->u.dst);
+	dst_release(&rt->dst);
 
 	write_unlock_bh(&table->tb6_lock);
 
@@ -1370,7 +1370,7 @@ static int ip6_route_del(struct fib6_config *cfg)
 			 &cfg->fc_src, cfg->fc_src_len);
 
 	if (fn) {
-		for (rt = fn->leaf; rt; rt = rt->u.dst.rt6_next) {
+		for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
 			if (cfg->fc_ifindex &&
 			    (rt->rt6i_dev == NULL ||
 			     rt->rt6i_dev->ifindex != cfg->fc_ifindex))
@@ -1380,7 +1380,7 @@ static int ip6_route_del(struct fib6_config *cfg)
 				continue;
 			if (cfg->fc_metric && cfg->fc_metric != rt->rt6i_metric)
 				continue;
-			dst_hold(&rt->u.dst);
+			dst_hold(&rt->dst);
 			read_unlock_bh(&table->tb6_lock);
 
 			return __ip6_del_rt(rt, &cfg->fc_nlinfo);
@@ -1422,7 +1422,7 @@ static struct rt6_info *__ip6_route_redirect(struct net *net,
 	read_lock_bh(&table->tb6_lock);
 	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 restart:
-	for (rt = fn->leaf; rt; rt = rt->u.dst.rt6_next) {
+	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
 		/*
 		 * Current route is on-link; redirect is always invalid.
 		 *
@@ -1446,7 +1446,7 @@ restart:
 		rt = net->ipv6.ip6_null_entry;
 	BACKTRACK(net, &fl->fl6_src);
 out:
-	dst_hold(&rt->u.dst);
+	dst_hold(&rt->dst);
 
 	read_unlock_bh(&table->tb6_lock);
 
@@ -1514,10 +1514,10 @@ void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
 	 * Look, redirects are sent only in response to data packets,
 	 * so that this nexthop apparently is reachable. --ANK
 	 */
-	dst_confirm(&rt->u.dst);
+	dst_confirm(&rt->dst);
 
 	/* Duplicate redirect: silently ignore. */
-	if (neigh == rt->u.dst.neighbour)
+	if (neigh == rt->dst.neighbour)
 		goto out;
 
 	nrt = ip6_rt_copy(rt);
@@ -1530,20 +1530,20 @@ void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
 
 	ipv6_addr_copy(&nrt->rt6i_dst.addr, dest);
 	nrt->rt6i_dst.plen = 128;
-	nrt->u.dst.flags |= DST_HOST;
+	nrt->dst.flags |= DST_HOST;
 
 	ipv6_addr_copy(&nrt->rt6i_gateway, (struct in6_addr*)neigh->primary_key);
 	nrt->rt6i_nexthop = neigh_clone(neigh);
 	/* Reset pmtu, it may be better */
-	nrt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(neigh->dev);
-	nrt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dev_net(neigh->dev),
-							dst_mtu(&nrt->u.dst));
+	nrt->dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(neigh->dev);
+	nrt->dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dev_net(neigh->dev),
+							dst_mtu(&nrt->dst));
 
 	if (ip6_ins_rt(nrt))
 		goto out;
 
-	netevent.old = &rt->u.dst;
-	netevent.new = &nrt->u.dst;
+	netevent.old = &rt->dst;
+	netevent.new = &nrt->dst;
 	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
 
 	if (rt->rt6i_flags&RTF_CACHE) {
@@ -1552,7 +1552,7 @@ void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
 	}
 
 out:
-	dst_release(&rt->u.dst);
+	dst_release(&rt->dst);
 	return;
 }
 
@@ -1572,7 +1572,7 @@ void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr,
 	if (rt == NULL)
 		return;
 
-	if (pmtu >= dst_mtu(&rt->u.dst))
+	if (pmtu >= dst_mtu(&rt->dst))
 		goto out;
 
 	if (pmtu < IPV6_MIN_MTU) {
@@ -1590,7 +1590,7 @@ void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr,
 	   They are sent only in response to data packets,
 	   so that this nexthop apparently is reachable. --ANK
 	 */
-	dst_confirm(&rt->u.dst);
+	dst_confirm(&rt->dst);
 
 	/* Host route. If it is static, it would be better
 	   not to override it, but add new one, so that
@@ -1598,10 +1598,10 @@ void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr,
 	   would return automatically.
 	 */
 	if (rt->rt6i_flags & RTF_CACHE) {
-		rt->u.dst.metrics[RTAX_MTU-1] = pmtu;
+		rt->dst.metrics[RTAX_MTU-1] = pmtu;
 		if (allfrag)
-			rt->u.dst.metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
-		dst_set_expires(&rt->u.dst, net->ipv6.sysctl.ip6_rt_mtu_expires);
+			rt->dst.metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
+		dst_set_expires(&rt->dst, net->ipv6.sysctl.ip6_rt_mtu_expires);
 		rt->rt6i_flags |= RTF_MODIFIED|RTF_EXPIRES;
 		goto out;
 	}
@@ -1617,9 +1617,9 @@ void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr,
 		nrt = rt6_alloc_clone(rt, daddr);
 
 	if (nrt) {
-		nrt->u.dst.metrics[RTAX_MTU-1] = pmtu;
+		nrt->dst.metrics[RTAX_MTU-1] = pmtu;
 		if (allfrag)
-			nrt->u.dst.metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
+			nrt->dst.metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
 
 		/* According to RFC 1981, detecting PMTU increase shouldn't be
 		 * happened within 5 mins, the recommended timer is 10 mins.
@@ -1627,13 +1627,13 @@ void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr,
 		 * which is 10 mins. After 10 mins the decreased pmtu is expired
 		 * and detecting PMTU increase will be automatically happened.
 		 */
-		dst_set_expires(&nrt->u.dst, net->ipv6.sysctl.ip6_rt_mtu_expires);
+		dst_set_expires(&nrt->dst, net->ipv6.sysctl.ip6_rt_mtu_expires);
 		nrt->rt6i_flags |= RTF_DYNAMIC|RTF_EXPIRES;
 
 		ip6_ins_rt(nrt);
 	}
 out:
-	dst_release(&rt->u.dst);
+	dst_release(&rt->dst);
 }
 
 /*
@@ -1646,18 +1646,18 @@ static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
 
 	if (rt) {
-		rt->u.dst.input = ort->u.dst.input;
-		rt->u.dst.output = ort->u.dst.output;
-
-		memcpy(rt->u.dst.metrics, ort->u.dst.metrics, RTAX_MAX*sizeof(u32));
-		rt->u.dst.error = ort->u.dst.error;
-		rt->u.dst.dev = ort->u.dst.dev;
-		if (rt->u.dst.dev)
-			dev_hold(rt->u.dst.dev);
+		rt->dst.input = ort->dst.input;
+		rt->dst.output = ort->dst.output;
+
+		memcpy(rt->dst.metrics, ort->dst.metrics, RTAX_MAX*sizeof(u32));
+		rt->dst.error = ort->dst.error;
+		rt->dst.dev = ort->dst.dev;
+		if (rt->dst.dev)
+			dev_hold(rt->dst.dev);
 		rt->rt6i_idev = ort->rt6i_idev;
 		if (rt->rt6i_idev)
 			in6_dev_hold(rt->rt6i_idev);
-		rt->u.dst.lastuse = jiffies;
+		rt->dst.lastuse = jiffies;
 		rt->rt6i_expires = 0;
 
 		ipv6_addr_copy(&rt->rt6i_gateway, &ort->rt6i_gateway);
@@ -1691,14 +1691,14 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 	if (!fn)
 		goto out;
 
-	for (rt = fn->leaf; rt; rt = rt->u.dst.rt6_next) {
+	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
 		if (rt->rt6i_dev->ifindex != ifindex)
 			continue;
 		if ((rt->rt6i_flags & (RTF_ROUTEINFO|RTF_GATEWAY)) != (RTF_ROUTEINFO|RTF_GATEWAY))
 			continue;
 		if (!ipv6_addr_equal(&rt->rt6i_gateway, gwaddr))
 			continue;
-		dst_hold(&rt->u.dst);
+		dst_hold(&rt->dst);
 		break;
 	}
 out:
@@ -1746,14 +1746,14 @@ struct rt6_info *rt6_get_dflt_router(struct in6_addr *addr, struct net_device *d
 		return NULL;
 
 	write_lock_bh(&table->tb6_lock);
-	for (rt = table->tb6_root.leaf; rt; rt=rt->u.dst.rt6_next) {
+	for (rt = table->tb6_root.leaf; rt; rt=rt->dst.rt6_next) {
 		if (dev == rt->rt6i_dev &&
 		    ((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT)) == (RTF_ADDRCONF | RTF_DEFAULT)) &&
 		    ipv6_addr_equal(&rt->rt6i_gateway, addr))
 			break;
 	}
 	if (rt)
-		dst_hold(&rt->u.dst);
+		dst_hold(&rt->dst);
 	write_unlock_bh(&table->tb6_lock);
 	return rt;
 }
@@ -1792,9 +1792,9 @@ void rt6_purge_dflt_routers(struct net *net)
 
 restart:
 	read_lock_bh(&table->tb6_lock);
-	for (rt = table->tb6_root.leaf; rt; rt = rt->u.dst.rt6_next) {
+	for (rt = table->tb6_root.leaf; rt; rt = rt->dst.rt6_next) {
 		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) {
-			dst_hold(&rt->u.dst);
+			dst_hold(&rt->dst);
 			read_unlock_bh(&table->tb6_lock);
 			ip6_del_rt(rt);
 			goto restart;
@@ -1932,15 +1932,15 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	dev_hold(net->loopback_dev);
 	in6_dev_hold(idev);
 
-	rt->u.dst.flags = DST_HOST;
-	rt->u.dst.input = ip6_input;
-	rt->u.dst.output = ip6_output;
+	rt->dst.flags = DST_HOST;
+	rt->dst.input = ip6_input;
+	rt->dst.output = ip6_output;
 	rt->rt6i_dev = net->loopback_dev;
 	rt->rt6i_idev = idev;
-	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
-	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->u.dst));
-	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
-	rt->u.dst.obsolete = -1;
+	rt->dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
+	rt->dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->dst));
+	rt->dst.metrics[RTAX_HOPLIMIT-1] = -1;
+	rt->dst.obsolete = -1;
 
 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;
 	if (anycast)
@@ -1949,7 +1949,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 		rt->rt6i_flags |= RTF_LOCAL;
 	neigh = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
 	if (IS_ERR(neigh)) {
-		dst_free(&rt->u.dst);
+		dst_free(&rt->dst);
 
 		/* We are casting this because that is the return
 		 * value type.  But an errno encoded pointer is the
@@ -1964,7 +1964,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_table = fib6_get_table(net, RT6_TABLE_LOCAL);
 
-	atomic_set(&rt->u.dst.__refcnt, 1);
+	atomic_set(&rt->dst.__refcnt, 1);
 
 	return rt;
 }
@@ -2035,12 +2035,12 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 	   PMTU discouvery.
 	 */
 	if (rt->rt6i_dev == arg->dev &&
-	    !dst_metric_locked(&rt->u.dst, RTAX_MTU) &&
-	    (dst_mtu(&rt->u.dst) >= arg->mtu ||
-	     (dst_mtu(&rt->u.dst) < arg->mtu &&
-	      dst_mtu(&rt->u.dst) == idev->cnf.mtu6))) {
-		rt->u.dst.metrics[RTAX_MTU-1] = arg->mtu;
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, arg->mtu);
+	    !dst_metric_locked(&rt->dst, RTAX_MTU) &&
+	    (dst_mtu(&rt->dst) >= arg->mtu ||
+	     (dst_mtu(&rt->dst) < arg->mtu &&
+	      dst_mtu(&rt->dst) == idev->cnf.mtu6))) {
+		rt->dst.metrics[RTAX_MTU-1] = arg->mtu;
+		rt->dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, arg->mtu);
 	}
 	return 0;
 }
@@ -2254,20 +2254,20 @@ static int rt6_fill_node(struct net *net,
 #endif
 			NLA_PUT_U32(skb, RTA_IIF, iif);
 	} else if (dst) {
-		struct inet6_dev *idev = ip6_dst_idev(&rt->u.dst);
+		struct inet6_dev *idev = ip6_dst_idev(&rt->dst);
 		struct in6_addr saddr_buf;
 		if (ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
 				       dst, 0, &saddr_buf) == 0)
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
 
-	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
+	if (rtnetlink_put_metrics(skb, rt->dst.metrics) < 0)
 		goto nla_put_failure;
 
-	if (rt->u.dst.neighbour)
-		NLA_PUT(skb, RTA_GATEWAY, 16, &rt->u.dst.neighbour->primary_key);
+	if (rt->dst.neighbour)
+		NLA_PUT(skb, RTA_GATEWAY, 16, &rt->dst.neighbour->primary_key);
 
-	if (rt->u.dst.dev)
+	if (rt->dst.dev)
 		NLA_PUT_U32(skb, RTA_OIF, rt->rt6i_dev->ifindex);
 
 	NLA_PUT_U32(skb, RTA_PRIORITY, rt->rt6i_metric);
@@ -2279,8 +2279,8 @@ static int rt6_fill_node(struct net *net,
 	else
 		expires = INT_MAX;
 
-	if (rtnl_put_cacheinfo(skb, &rt->u.dst, 0, 0, 0,
-			       expires, rt->u.dst.error) < 0)
+	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, 0, 0,
+			       expires, rt->dst.error) < 0)
 		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
@@ -2366,7 +2366,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
 
 	rt = (struct rt6_info*) ip6_route_output(net, NULL, &fl);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	err = rt6_fill_node(net, skb, rt, &fl.fl6_dst, &fl.fl6_src, iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
@@ -2418,12 +2418,12 @@ static int ip6_route_dev_notify(struct notifier_block *this,
 	struct net *net = dev_net(dev);
 
 	if (event == NETDEV_REGISTER && (dev->flags & IFF_LOOPBACK)) {
-		net->ipv6.ip6_null_entry->u.dst.dev = dev;
+		net->ipv6.ip6_null_entry->dst.dev = dev;
 		net->ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(dev);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-		net->ipv6.ip6_prohibit_entry->u.dst.dev = dev;
+		net->ipv6.ip6_prohibit_entry->dst.dev = dev;
 		net->ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(dev);
-		net->ipv6.ip6_blk_hole_entry->u.dst.dev = dev;
+		net->ipv6.ip6_blk_hole_entry->dst.dev = dev;
 		net->ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(dev);
 #endif
 	}
@@ -2466,8 +2466,8 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 		seq_puts(m, "00000000000000000000000000000000");
 	}
 	seq_printf(m, " %08x %08x %08x %08x %8s\n",
-		   rt->rt6i_metric, atomic_read(&rt->u.dst.__refcnt),
-		   rt->u.dst.__use, rt->rt6i_flags,
+		   rt->rt6i_metric, atomic_read(&rt->dst.__refcnt),
+		   rt->dst.__use, rt->rt6i_flags,
 		   rt->rt6i_dev ? rt->rt6i_dev->name : "");
 	return 0;
 }
@@ -2648,9 +2648,9 @@ static int __net_init ip6_route_net_init(struct net *net)
 					   GFP_KERNEL);
 	if (!net->ipv6.ip6_null_entry)
 		goto out_ip6_dst_ops;
-	net->ipv6.ip6_null_entry->u.dst.path =
+	net->ipv6.ip6_null_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_null_entry;
-	net->ipv6.ip6_null_entry->u.dst.ops = &net->ipv6.ip6_dst_ops;
+	net->ipv6.ip6_null_entry->dst.ops = &net->ipv6.ip6_dst_ops;
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	net->ipv6.ip6_prohibit_entry = kmemdup(&ip6_prohibit_entry_template,
@@ -2658,18 +2658,18 @@ static int __net_init ip6_route_net_init(struct net *net)
 					       GFP_KERNEL);
 	if (!net->ipv6.ip6_prohibit_entry)
 		goto out_ip6_null_entry;
-	net->ipv6.ip6_prohibit_entry->u.dst.path =
+	net->ipv6.ip6_prohibit_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_prohibit_entry;
-	net->ipv6.ip6_prohibit_entry->u.dst.ops = &net->ipv6.ip6_dst_ops;
+	net->ipv6.ip6_prohibit_entry->dst.ops = &net->ipv6.ip6_dst_ops;
 
 	net->ipv6.ip6_blk_hole_entry = kmemdup(&ip6_blk_hole_entry_template,
 					       sizeof(*net->ipv6.ip6_blk_hole_entry),
 					       GFP_KERNEL);
 	if (!net->ipv6.ip6_blk_hole_entry)
 		goto out_ip6_prohibit_entry;
-	net->ipv6.ip6_blk_hole_entry->u.dst.path =
+	net->ipv6.ip6_blk_hole_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_blk_hole_entry;
-	net->ipv6.ip6_blk_hole_entry->u.dst.ops = &net->ipv6.ip6_dst_ops;
+	net->ipv6.ip6_blk_hole_entry->dst.ops = &net->ipv6.ip6_dst_ops;
 #endif
 
 	net->ipv6.sysctl.flush_delay = 0;
@@ -2744,12 +2744,12 @@ int __init ip6_route_init(void)
 	/* Registering of the loopback is done before this portion of code,
 	 * the loopback reference in rt6_info will not be taken, do it
 	 * manually for init_net */
-	init_net.ipv6.ip6_null_entry->u.dst.dev = init_net.loopback_dev;
+	init_net.ipv6.ip6_null_entry->dst.dev = init_net.loopback_dev;
 	init_net.ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
   #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	init_net.ipv6.ip6_prohibit_entry->u.dst.dev = init_net.loopback_dev;
+	init_net.ipv6.ip6_prohibit_entry->dst.dev = init_net.loopback_dev;
 	init_net.ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
-	init_net.ipv6.ip6_blk_hole_entry->u.dst.dev = init_net.loopback_dev;
+	init_net.ipv6.ip6_blk_hole_entry->dst.dev = init_net.loopback_dev;
 	init_net.ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
   #endif
 	ret = fib6_init();
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 5abae10..f3b2d3b 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -718,7 +718,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		stats->tx_carrier_errors++;
 		goto tx_error_icmp;
 	}
-	tdev = rt->u.dst.dev;
+	tdev = rt->dst.dev;
 
 	if (tdev == dev) {
 		ip_rt_put(rt);
@@ -727,7 +727,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 
 	if (df) {
-		mtu = dst_mtu(&rt->u.dst) - sizeof(struct iphdr);
+		mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
 
 		if (mtu < 68) {
 			stats->collisions++;
@@ -786,7 +786,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags = 0;
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	/*
 	 *	Push down and install the IPIP header.
@@ -835,7 +835,7 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 				    .proto = IPPROTO_IPV6 };
 		struct rtable *rt;
 		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
-			tdev = rt->u.dst.dev;
+			tdev = rt->dst.dev;
 			ip_rt_put(rt);
 		}
 		dev->flags |= IFF_POINTOPOINT;
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 0852512..226a0ae 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -348,7 +348,7 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	sk->sk_state = TCP_ESTABLISHED;
 	inet->inet_id = jiffies;
 
-	sk_dst_set(sk, &rt->u.dst);
+	sk_dst_set(sk, &rt->dst);
 
 	write_lock_bh(&l2tp_ip_lock);
 	hlist_del_init(&sk->sk_bind_node);
@@ -496,9 +496,9 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 			if (ip_route_output_flow(sock_net(sk), &rt, &fl, sk, 0))
 				goto no_route;
 		}
-		sk_setup_caps(sk, &rt->u.dst);
+		sk_setup_caps(sk, &rt->dst);
 	}
-	skb_dst_set(skb, dst_clone(&rt->u.dst));
+	skb_dst_set(skb, dst_clone(&rt->dst));
 
 	/* Queue the packet to IP for output */
 	rc = ip_queue_xmit(skb);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index e450cd6..cf1314f 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -90,10 +90,10 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 					     &dest->addr.ip);
 				return NULL;
 			}
-			__ip_vs_dst_set(dest, rtos, dst_clone(&rt->u.dst));
+			__ip_vs_dst_set(dest, rtos, dst_clone(&rt->dst));
 			IP_VS_DBG(10, "new dst %pI4, refcnt=%d, rtos=%X\n",
 				  &dest->addr.ip,
-				  atomic_read(&rt->u.dst.__refcnt), rtos);
+				  atomic_read(&rt->dst.__refcnt), rtos);
 		}
 		spin_unlock(&dest->dst_lock);
 	} else {
@@ -148,10 +148,10 @@ __ip_vs_get_out_rt_v6(struct ip_vs_conn *cp)
 					     &dest->addr.in6);
 				return NULL;
 			}
-			__ip_vs_dst_set(dest, 0, dst_clone(&rt->u.dst));
+			__ip_vs_dst_set(dest, 0, dst_clone(&rt->dst));
 			IP_VS_DBG(10, "new dst %pI6, refcnt=%d\n",
 				  &dest->addr.in6,
-				  atomic_read(&rt->u.dst.__refcnt));
+				  atomic_read(&rt->dst.__refcnt));
 		}
 		spin_unlock(&dest->dst_lock);
 	} else {
@@ -198,7 +198,7 @@ do {							\
 	(skb)->ipvs_property = 1;			\
 	skb_forward_csum(skb);				\
 	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
-		(rt)->u.dst.dev, dst_output);		\
+		(rt)->dst.dev, dst_output);		\
 } while (0)
 
 
@@ -245,7 +245,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	/* MTU checking */
-	mtu = dst_mtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->dst);
 	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
@@ -265,7 +265,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -309,9 +309,9 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	/* MTU checking */
-	mtu = dst_mtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->dst);
 	if (skb->len > mtu) {
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
@@ -323,13 +323,13 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(skb == NULL)) {
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 		return NF_STOLEN;
 	}
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -376,7 +376,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_icmp;
 
 	/* MTU checking */
-	mtu = dst_mtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->dst);
 	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
@@ -388,12 +388,12 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (!skb_make_writable(skb, sizeof(struct iphdr)))
 		goto tx_error_put;
 
-	if (skb_cow(skb, rt->u.dst.dev->hard_header_len))
+	if (skb_cow(skb, rt->dst.dev->hard_header_len))
 		goto tx_error_put;
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	/* mangle the packet */
 	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
@@ -452,9 +452,9 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_icmp;
 
 	/* MTU checking */
-	mtu = dst_mtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->dst);
 	if (skb->len > mtu) {
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL_PKT(0, pp, skb, 0,
 				 "ip_vs_nat_xmit_v6(): frag needed for");
@@ -465,12 +465,12 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
 		goto tx_error_put;
 
-	if (skb_cow(skb, rt->u.dst.dev->hard_header_len))
+	if (skb_cow(skb, rt->dst.dev->hard_header_len))
 		goto tx_error_put;
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	/* mangle the packet */
 	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
@@ -498,7 +498,7 @@ tx_error:
 	kfree_skb(skb);
 	return NF_STOLEN;
 tx_error_put:
-	dst_release(&rt->u.dst);
+	dst_release(&rt->dst);
 	goto tx_error;
 }
 #endif
@@ -549,9 +549,9 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (!(rt = __ip_vs_get_out_rt(cp, RT_TOS(tos))))
 		goto tx_error_icmp;
 
-	tdev = rt->u.dst.dev;
+	tdev = rt->dst.dev;
 
-	mtu = dst_mtu(&rt->u.dst) - sizeof(struct iphdr);
+	mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
 	if (mtu < 68) {
 		ip_rt_put(rt);
 		IP_VS_DBG_RL("%s(): mtu less than 68\n", __func__);
@@ -601,7 +601,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	/*
 	 *	Push down and install the IPIP header.
@@ -615,7 +615,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	iph->daddr		=	rt->rt_dst;
 	iph->saddr		=	rt->rt_src;
 	iph->ttl		=	old_iph->ttl;
-	ip_select_ident(iph, &rt->u.dst, NULL);
+	ip_select_ident(iph, &rt->dst, NULL);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -660,12 +660,12 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (!rt)
 		goto tx_error_icmp;
 
-	tdev = rt->u.dst.dev;
+	tdev = rt->dst.dev;
 
-	mtu = dst_mtu(&rt->u.dst) - sizeof(struct ipv6hdr);
+	mtu = dst_mtu(&rt->dst) - sizeof(struct ipv6hdr);
 	/* TODO IPv6: do we need this check in IPv6? */
 	if (mtu < 1280) {
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 		IP_VS_DBG_RL("%s(): mtu less than 1280\n", __func__);
 		goto tx_error;
 	}
@@ -674,7 +674,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)) {
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
 	}
@@ -689,7 +689,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct sk_buff *new_skb =
 			skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
-			dst_release(&rt->u.dst);
+			dst_release(&rt->dst);
 			kfree_skb(skb);
 			IP_VS_ERR_RL("%s(): no memory\n", __func__);
 			return NF_STOLEN;
@@ -707,7 +707,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	/*
 	 *	Push down and install the IPIP header.
@@ -760,7 +760,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_icmp;
 
 	/* MTU checking */
-	mtu = dst_mtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->dst);
 	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		ip_rt_put(rt);
@@ -780,7 +780,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -813,10 +813,10 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_icmp;
 
 	/* MTU checking */
-	mtu = dst_mtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->dst);
 	if (skb->len > mtu) {
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
 	}
@@ -827,13 +827,13 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(skb == NULL)) {
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 		return NF_STOLEN;
 	}
 
 	/* drop old route */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -888,7 +888,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_icmp;
 
 	/* MTU checking */
-	mtu = dst_mtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->dst);
 	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
@@ -900,12 +900,12 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (!skb_make_writable(skb, offset))
 		goto tx_error_put;
 
-	if (skb_cow(skb, rt->u.dst.dev->hard_header_len))
+	if (skb_cow(skb, rt->dst.dev->hard_header_len))
 		goto tx_error_put;
 
 	/* drop the old route when skb is not shared */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	ip_vs_nat_icmp(skb, pp, cp, 0);
 
@@ -963,9 +963,9 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_icmp;
 
 	/* MTU checking */
-	mtu = dst_mtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->dst);
 	if (skb->len > mtu) {
-		dst_release(&rt->u.dst);
+		dst_release(&rt->dst);
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
@@ -975,12 +975,12 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (!skb_make_writable(skb, offset))
 		goto tx_error_put;
 
-	if (skb_cow(skb, rt->u.dst.dev->hard_header_len))
+	if (skb_cow(skb, rt->dst.dev->hard_header_len))
 		goto tx_error_put;
 
 	/* drop the old route when skb is not shared */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set(skb, &rt->dst);
 
 	ip_vs_nat_icmp_v6(skb, pp, cp, 0);
 
@@ -1001,7 +1001,7 @@ out:
 	LeaveFunction(10);
 	return rc;
 tx_error_put:
-	dst_release(&rt->u.dst);
+	dst_release(&rt->dst);
 	goto tx_error;
 }
 #endif
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index a487c80..7300084 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -735,11 +735,11 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 		if (!afinfo->route((struct dst_entry **)&rt1, &fl1)) {
 			if (!afinfo->route((struct dst_entry **)&rt2, &fl2)) {
 				if (rt1->rt_gateway == rt2->rt_gateway &&
-				    rt1->u.dst.dev  == rt2->u.dst.dev)
+				    rt1->dst.dev  == rt2->dst.dev)
 					ret = 1;
-				dst_release(&rt2->u.dst);
+				dst_release(&rt2->dst);
 			}
-			dst_release(&rt1->u.dst);
+			dst_release(&rt1->dst);
 		}
 		break;
 	}
@@ -754,11 +754,11 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 			if (!afinfo->route((struct dst_entry **)&rt2, &fl2)) {
 				if (!memcmp(&rt1->rt6i_gateway, &rt2->rt6i_gateway,
 					    sizeof(rt1->rt6i_gateway)) &&
-				    rt1->u.dst.dev == rt2->u.dst.dev)
+				    rt1->dst.dev == rt2->dst.dev)
 					ret = 1;
-				dst_release(&rt2->u.dst);
+				dst_release(&rt2->dst);
 			}
-			dst_release(&rt1->u.dst);
+			dst_release(&rt1->dst);
 		}
 		break;
 	}
diff --git a/net/netfilter/nf_conntrack_netbios_ns.c b/net/netfilter/nf_conntrack_netbios_ns.c
index 497b222..aadde01 100644
--- a/net/netfilter/nf_conntrack_netbios_ns.c
+++ b/net/netfilter/nf_conntrack_netbios_ns.c
@@ -61,7 +61,7 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 		goto out;
 
 	rcu_read_lock();
-	in_dev = __in_dev_get_rcu(rt->u.dst.dev);
+	in_dev = __in_dev_get_rcu(rt->dst.dev);
 	if (in_dev != NULL) {
 		for_primary_ifa(in_dev) {
 			if (ifa->ifa_broadcast == iph->daddr) {
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index c5f4b99..8e61144 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -166,8 +166,8 @@ static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
 	rcu_read_unlock();
 
 	if (rt != NULL) {
-		mtu = dst_mtu(&rt->u.dst);
-		dst_release(&rt->u.dst);
+		mtu = dst_mtu(&rt->dst);
+		dst_release(&rt->dst);
 	}
 	return mtu;
 }
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
index f0f85b0..9f1729b 100644
--- a/net/rxrpc/ar-peer.c
+++ b/net/rxrpc/ar-peer.c
@@ -64,8 +64,8 @@ static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 		return;
 	}
 
-	peer->if_mtu = dst_mtu(&rt->u.dst);
-	dst_release(&rt->u.dst);
+	peer->if_mtu = dst_mtu(&rt->dst);
+	dst_release(&rt->dst);
 
 	_leave(" [if_mtu %u]", peer->if_mtu);
 }
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 704298f..2be0439 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -486,7 +486,7 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 			  __func__, &fl.fl4_dst, &fl.fl4_src);
 
 	if (!ip_route_output_key(&init_net, &rt, &fl)) {
-		dst = &rt->u.dst;
+		dst = &rt->dst;
 	}
 
 	/* If there is no association or if a source address is passed, no
@@ -529,7 +529,7 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 		    (AF_INET == laddr->a.sa.sa_family)) {
 			fl.fl4_src = laddr->a.v4.sin_addr.s_addr;
 			if (!ip_route_output_key(&init_net, &rt, &fl)) {
-				dst = &rt->u.dst;
+				dst = &rt->dst;
 				goto out_unlock;
 			}
 		}
