From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/9] net: Rename dst_get_neighbour{,_raw} to
 dst_get_neighbour_noref{,_raw}.
Date: Fri, 02 Dec 2011 21:52:08 -0500 (EST)
Message-ID: <20111202.215208.2048429167657194854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754904Ab1LCCwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 21:52:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To reflect the fact that a refrence is not obtained to the
resulting neighbour entry.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/core/addr.c                     |    4 ++--
 drivers/infiniband/hw/cxgb3/iwch_cm.c              |    4 ++--
 drivers/infiniband/hw/cxgb4/cm.c                   |    6 +++---
 drivers/infiniband/hw/nes/nes_cm.c                 |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c          |    8 ++++----
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c     |    4 ++--
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |    8 ++++----
 drivers/s390/net/qeth_l3_main.c                    |    4 ++--
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c                 |    2 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 |    2 +-
 drivers/scsi/cxgbi/libcxgbi.c                      |    4 ++--
 include/net/dst.h                                  |    6 +++---
 net/atm/clip.c                                     |    2 +-
 net/bridge/br_netfilter.c                          |    2 +-
 net/core/dst.c                                     |    2 +-
 net/core/neighbour.c                               |    2 +-
 net/decnet/dn_neigh.c                              |    2 +-
 net/decnet/dn_route.c                              |    8 ++++----
 net/ipv4/ip_gre.c                                  |    2 +-
 net/ipv4/ip_output.c                               |    2 +-
 net/ipv4/route.c                                   |    2 +-
 net/ipv6/addrconf.c                                |    2 +-
 net/ipv6/ip6_fib.c                                 |    2 +-
 net/ipv6/ip6_output.c                              |    6 +++---
 net/ipv6/ndisc.c                                   |    4 ++--
 net/ipv6/route.c                                   |   16 ++++++++--------
 net/ipv6/sit.c                                     |    4 ++--
 net/sched/sch_teql.c                               |    2 +-
 net/xfrm/xfrm_policy.c                             |    2 +-
 29 files changed, 58 insertions(+), 58 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index a20c3c8..70154f7 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -217,7 +217,7 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 	neigh = neigh_lookup(&arp_tbl, &rt->rt_gateway, rt->dst.dev);
 	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
 		rcu_read_lock();
-		neigh_event_send(dst_get_neighbour(&rt->dst), NULL);
+		neigh_event_send(dst_get_neighbour_noref(&rt->dst), NULL);
 		rcu_read_unlock();
 		ret = -ENODATA;
 		if (neigh)
@@ -277,7 +277,7 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
 	}
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour(dst);
+	neigh = dst_get_neighbour_noref(dst);
 	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
 		if (neigh)
 			neigh_event_send(neigh, NULL);
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index c88b12b..23686df 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1376,7 +1376,7 @@ static int pass_accept_req(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 	}
 	dst = &rt->dst;
 	rcu_read_lock();
-	neigh = dst_get_neighbour(dst);
+	neigh = dst_get_neighbour_noref(dst);
 	l2t = t3_l2t_get(tdev, neigh, neigh->dev);
 	rcu_read_unlock();
 	if (!l2t) {
@@ -1949,7 +1949,7 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	ep->dst = &rt->dst;
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour(ep->dst);
+	neigh = dst_get_neighbour_noref(ep->dst);
 
 	/* get a l2t entry */
 	ep->l2t = t3_l2t_get(ep->com.tdev, neigh, neigh->dev);
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 0747004..e61c802 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1597,7 +1597,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 	}
 	dst = &rt->dst;
 	rcu_read_lock();
-	neigh = dst_get_neighbour(dst);
+	neigh = dst_get_neighbour_noref(dst);
 	if (neigh->dev->flags & IFF_LOOPBACK) {
 		pdev = ip_dev_find(&init_net, peer_ip);
 		BUG_ON(!pdev);
@@ -1825,7 +1825,7 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 	ep->dst = &rt->dst;
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour(ep->dst);
+	neigh = dst_get_neighbour_noref(ep->dst);
 
 	/* get a l2t entry */
 	if (neigh->dev->flags & IFF_LOOPBACK) {
@@ -2308,7 +2308,7 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	ep->dst = &rt->dst;
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour(ep->dst);
+	neigh = dst_get_neighbour_noref(ep->dst);
 
 	/* get a l2t entry */
 	if (neigh->dev->flags & IFF_LOOPBACK) {
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 0a52d72..686667a 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1379,7 +1379,7 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 
 	if ((neigh == NULL) || (!(neigh->nud_state & NUD_VALID))) {
 		rcu_read_lock();
-		neigh_event_send(dst_get_neighbour(&rt->dst), NULL);
+		neigh_event_send(dst_get_neighbour_noref(&rt->dst), NULL);
 		rcu_read_unlock();
 	}
 	ip_rt_put(rt);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index d3ed89c..eef6786 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -564,7 +564,7 @@ static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 	struct neighbour *n;
 	unsigned long flags;
 
-	n = dst_get_neighbour(skb_dst(skb));
+	n = dst_get_neighbour_noref(skb_dst(skb));
 	neigh = ipoib_neigh_alloc(n, skb->dev);
 	if (!neigh) {
 		++dev->stats.tx_dropped;
@@ -645,7 +645,7 @@ static void ipoib_path_lookup(struct sk_buff *skb, struct net_device *dev)
 	struct neighbour *n;
 
 	/* Look up path record for unicasts */
-	n = dst_get_neighbour(dst);
+	n = dst_get_neighbour_noref(dst);
 	if (n->ha[4] != 0xff) {
 		neigh_add_path(skb, dev);
 		return;
@@ -724,7 +724,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	rcu_read_lock();
 	if (likely(skb_dst(skb)))
-		n = dst_get_neighbour(skb_dst(skb));
+		n = dst_get_neighbour_noref(skb_dst(skb));
 
 	if (likely(n)) {
 		if (unlikely(!*to_ipoib_neigh(n))) {
@@ -841,7 +841,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
 	dst = skb_dst(skb);
 	n = NULL;
 	if (dst)
-		n = dst_get_neighbour_raw(dst);
+		n = dst_get_neighbour_noref_raw(dst);
 	if ((!dst || !n) && daddr) {
 		struct ipoib_pseudoheader *phdr =
 			(struct ipoib_pseudoheader *) skb_push(skb, sizeof *phdr);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 873bff9..f7ff9dd 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -269,7 +269,7 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 
 		skb->dev = dev;
 		if (dst)
-			n = dst_get_neighbour_raw(dst);
+			n = dst_get_neighbour_noref_raw(dst);
 		if (!dst || !n) {
 			/* put pseudoheader back on for next time */
 			skb_push(skb, sizeof (struct ipoib_pseudoheader));
@@ -728,7 +728,7 @@ out:
 
 		rcu_read_lock();
 		if (dst)
-			n = dst_get_neighbour(dst);
+			n = dst_get_neighbour_noref(dst);
 		if (n && !*to_ipoib_neigh(n)) {
 			struct ipoib_neigh *neigh = ipoib_neigh_alloc(n,
 								      skb->dev);
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 7f7882d..6ed9f87 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -969,7 +969,7 @@ static int nb_callback(struct notifier_block *self, unsigned long event,
 	case (NETEVENT_REDIRECT):{
 		struct netevent_redirect *nr = ctx;
 		cxgb_redirect(nr->old, nr->new);
-		cxgb_neigh_update(dst_get_neighbour(nr->new));
+		cxgb_neigh_update(dst_get_neighbour_noref(nr->new));
 		break;
 	}
 	default:
@@ -1114,8 +1114,8 @@ static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 	struct l2t_entry *e;
 	struct t3c_tid_entry *te;
 
-	olddev = dst_get_neighbour(old)->dev;
-	newdev = dst_get_neighbour(new)->dev;
+	olddev = dst_get_neighbour_noref(old)->dev;
+	newdev = dst_get_neighbour_noref(new)->dev;
 	if (!is_offloading(olddev))
 		return;
 	if (!is_offloading(newdev)) {
@@ -1132,7 +1132,7 @@ static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 	}
 
 	/* Add new L2T entry */
-	e = t3_l2t_get(tdev, dst_get_neighbour(new), newdev);
+	e = t3_l2t_get(tdev, dst_get_neighbour_noref(new), newdev);
 	if (!e) {
 		printk(KERN_ERR "%s: couldn't allocate new l2t entry!\n",
 		       __func__);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 6357892..b2a55e3 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2759,7 +2759,7 @@ int inline qeth_l3_get_cast_type(struct qeth_card *card, struct sk_buff *skb)
 	rcu_read_lock();
 	dst = skb_dst(skb);
 	if (dst)
-		n = dst_get_neighbour(dst);
+		n = dst_get_neighbour_noref(dst);
 	if (n) {
 		cast_type = n->type;
 		rcu_read_unlock();
@@ -2855,7 +2855,7 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 	rcu_read_lock();
 	dst = skb_dst(skb);
 	if (dst)
-		n = dst_get_neighbour(dst);
+		n = dst_get_neighbour_noref(dst);
 	if (ipv == 4) {
 		/* IPv4 */
 		hdr->hdr.l3.flags = qeth_l3_get_qeth_hdr_flags4(cast_type);
diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index 000294a..88902d3 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -966,7 +966,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 		csk->saddr.sin_addr.s_addr = chba->ipv4addr;
 
 	csk->rss_qid = 0;
-	csk->l2t = t3_l2t_get(t3dev, dst_get_neighbour(dst), ndev);
+	csk->l2t = t3_l2t_get(t3dev, dst_get_neighbour_noref(dst), ndev);
 	if (!csk->l2t) {
 		pr_err("NO l2t available.\n");
 		return -EINVAL;
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index ac7a9b1..c8fd13a 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1141,7 +1141,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 	cxgbi_sock_set_flag(csk, CTPF_HAS_ATID);
 	cxgbi_sock_get(csk);
 
-	csk->l2t = cxgb4_l2t_get(lldi->l2t, dst_get_neighbour(csk->dst), ndev, 0);
+	csk->l2t = cxgb4_l2t_get(lldi->l2t, dst_get_neighbour_noref(csk->dst), ndev, 0);
 	if (!csk->l2t) {
 		pr_err("%s, cannot alloc l2t.\n", ndev->name);
 		goto rel_resource;
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index c10f74a..a026a2f 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -493,7 +493,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 		goto err_out;
 	}
 	dst = &rt->dst;
-	ndev = dst_get_neighbour(dst)->dev;
+	ndev = dst_get_neighbour_noref(dst)->dev;
 
 	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
 		pr_info("multi-cast route %pI4, port %u, dev %s.\n",
@@ -507,7 +507,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 		ndev = ip_dev_find(&init_net, daddr->sin_addr.s_addr);
 		mtu = ndev->mtu;
 		pr_info("rt dev %s, loopback -> %s, mtu %u.\n",
-			dst_get_neighbour(dst)->dev->name, ndev->name, mtu);
+			dst_get_neighbour_noref(dst)->dev->name, ndev->name, mtu);
 	}
 
 	cdev = cxgbi_device_find_by_netdev(ndev, &port);
diff --git a/include/net/dst.h b/include/net/dst.h
index 6faec1a..01343b0 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -86,12 +86,12 @@ struct dst_entry {
 	};
 };
 
-static inline struct neighbour *dst_get_neighbour(struct dst_entry *dst)
+static inline struct neighbour *dst_get_neighbour_noref(struct dst_entry *dst)
 {
 	return rcu_dereference(dst->_neighbour);
 }
 
-static inline struct neighbour *dst_get_neighbour_raw(struct dst_entry *dst)
+static inline struct neighbour *dst_get_neighbour_noref_raw(struct dst_entry *dst)
 {
 	return rcu_dereference_raw(dst->_neighbour);
 }
@@ -392,7 +392,7 @@ static inline void dst_confirm(struct dst_entry *dst)
 		struct neighbour *n;
 
 		rcu_read_lock();
-		n = dst_get_neighbour(dst);
+		n = dst_get_neighbour_noref(dst);
 		neigh_confirm(n);
 		rcu_read_unlock();
 	}
diff --git a/net/atm/clip.c b/net/atm/clip.c
index c84ce7f..c12c258 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -338,7 +338,7 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
 	}
-	n = dst_get_neighbour(dst);
+	n = dst_get_neighbour_noref(dst);
 	if (!n) {
 		pr_err("NO NEIGHBOUR !\n");
 		dev_kfree_skb(skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index d6ec372..834dfab 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -356,7 +356,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 	if (!skb->dev)
 		goto free_skb;
 	dst = skb_dst(skb);
-	neigh = dst_get_neighbour(dst);
+	neigh = dst_get_neighbour_noref(dst);
 	if (neigh->hh.hh_len) {
 		neigh_hh_bridge(&neigh->hh, skb);
 		skb->dev = nf_bridge->physindev;
diff --git a/net/core/dst.c b/net/core/dst.c
index d5e2c4c..43d94ce 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -366,7 +366,7 @@ static void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 		dev_hold(dst->dev);
 		dev_put(dev);
 		rcu_read_lock();
-		neigh = dst_get_neighbour(dst);
+		neigh = dst_get_neighbour_noref(dst);
 		if (neigh && neigh->dev == dev) {
 			neigh->dev = dst->dev;
 			dev_hold(dst->dev);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index cdf8dc3..4af151e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1190,7 +1190,7 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 
 			rcu_read_lock();
 			/* On shaper/eql skb->dst->neighbour != neigh :( */
-			if (dst && (n2 = dst_get_neighbour(dst)) != NULL)
+			if (dst && (n2 = dst_get_neighbour_noref(dst)) != NULL)
 				n1 = n2;
 			n1->output(n1, skb);
 			rcu_read_unlock();
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 3532ac6..7d2fff2 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -202,7 +202,7 @@ static int dn_neigh_output_packet(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *)dst;
-	struct neighbour *neigh = dst_get_neighbour(dst);
+	struct neighbour *neigh = dst_get_neighbour_noref(dst);
 	struct net_device *dev = neigh->dev;
 	char mac_addr[ETH_ALEN];
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 94f4ec0..f31ce72 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -244,7 +244,7 @@ static int dn_dst_gc(struct dst_ops *ops)
  */
 static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
-	struct neighbour *n = dst_get_neighbour(dst);
+	struct neighbour *n = dst_get_neighbour_noref(dst);
 	u32 min_mtu = 230;
 	struct dn_dev *dn;
 
@@ -713,7 +713,7 @@ out:
 static int dn_to_neigh_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *n = dst_get_neighbour(dst);
+	struct neighbour *n = dst_get_neighbour_noref(dst);
 
 	return n->output(n, skb);
 }
@@ -728,7 +728,7 @@ static int dn_output(struct sk_buff *skb)
 
 	int err = -EINVAL;
 
-	if ((neigh = dst_get_neighbour(dst)) == NULL)
+	if ((neigh = dst_get_neighbour_noref(dst)) == NULL)
 		goto error;
 
 	skb->dev = dev;
@@ -852,7 +852,7 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 	}
 	rt->rt_type = res->type;
 
-	if (dev != NULL && dst_get_neighbour(&rt->dst) == NULL) {
+	if (dev != NULL && dst_get_neighbour_noref(&rt->dst) == NULL) {
 		n = __neigh_lookup_errno(&dn_neigh_table, &rt->rt_gateway, dev);
 		if (IS_ERR(n))
 			return PTR_ERR(n);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 2b32296..fe070c1 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -731,7 +731,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (skb->protocol == htons(ETH_P_IPV6)) {
-			struct neighbour *neigh = dst_get_neighbour(skb_dst(skb));
+			struct neighbour *neigh = dst_get_neighbour_noref(skb_dst(skb));
 			const struct in6_addr *addr6;
 			int addr_type;
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0d5e567..ff302bd 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -206,7 +206,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	}
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour(dst);
+	neigh = dst_get_neighbour_noref(dst);
 	if (neigh) {
 		int res = neigh_output(neigh, skb);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7047069..90402a2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -419,7 +419,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 		int len, HHUptod;
 
 		rcu_read_lock();
-		n = dst_get_neighbour(&r->dst);
+		n = dst_get_neighbour_noref(&r->dst);
 		HHUptod = (n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0;
 		rcu_read_unlock();
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5860517..058cc22 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -657,7 +657,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	 * layer address of our nexhop router
 	 */
 
-	if (dst_get_neighbour_raw(&rt->dst) == NULL)
+	if (dst_get_neighbour_noref_raw(&rt->dst) == NULL)
 		ifa->flags &= ~IFA_F_OPTIMISTIC;
 
 	ifa->idev = idev;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 424f063..03d6916 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1536,7 +1536,7 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
 		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
-			   (!(dst_get_neighbour_raw(&rt->dst)->flags & NTF_ROUTER))) {
+			   (!(dst_get_neighbour_noref_raw(&rt->dst)->flags & NTF_ROUTER))) {
 			RT6_TRACE("purging route %p via non-router but gateway\n",
 				  rt);
 			return -1;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a24e155..d63fd1e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -136,7 +136,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	}
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour(dst);
+	neigh = dst_get_neighbour_noref(dst);
 	if (neigh) {
 		int res = neigh_output(neigh, skb);
 
@@ -462,7 +462,7 @@ int ip6_forward(struct sk_buff *skb)
 	   send redirects to source routed frames.
 	   We don't send redirects to frames decapsulated from IPsec.
 	 */
-	n = dst_get_neighbour(dst);
+	n = dst_get_neighbour_noref(dst);
 	if (skb->dev == dst->dev && n && opt->srcrt == 0 && !skb_sec_path(skb)) {
 		struct in6_addr *target = NULL;
 		struct rt6_info *rt;
@@ -982,7 +982,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 * dst entry of the nexthop router
 	 */
 	rcu_read_lock();
-	n = dst_get_neighbour(*dst);
+	n = dst_get_neighbour_noref(*dst);
 	if (n && !(n->nud_state & NUD_VALID)) {
 		struct inet6_ifaddr *ifp;
 		struct flowi6 fl_gw6;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index cfb9709..e72c8af 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1238,7 +1238,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	rt = rt6_get_dflt_router(&ipv6_hdr(skb)->saddr, skb->dev);
 
 	if (rt)
-		neigh = dst_get_neighbour(&rt->dst);
+		neigh = dst_get_neighbour_noref(&rt->dst);
 
 	if (rt && lifetime == 0) {
 		neigh_clone(neigh);
@@ -1258,7 +1258,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			return;
 		}
 
-		neigh = dst_get_neighbour(&rt->dst);
+		neigh = dst_get_neighbour_noref(&rt->dst);
 		if (neigh == NULL) {
 			ND_PRINTK0(KERN_ERR
 				   "ICMPv6 RA: %s() got default router without neighbour.\n",
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0e381bb..3cf5d75 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -385,7 +385,7 @@ static void rt6_probe(struct rt6_info *rt)
 	 * to no more than one per minute.
 	 */
 	rcu_read_lock();
-	neigh = rt ? dst_get_neighbour(&rt->dst) : NULL;
+	neigh = rt ? dst_get_neighbour_noref(&rt->dst) : NULL;
 	if (!neigh || (neigh->nud_state & NUD_VALID))
 		goto out;
 	read_lock_bh(&neigh->lock);
@@ -432,7 +432,7 @@ static inline int rt6_check_neigh(struct rt6_info *rt)
 	int m;
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour(&rt->dst);
+	neigh = dst_get_neighbour_noref(&rt->dst);
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
 		m = 1;
@@ -785,7 +785,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
 
 	if (rt) {
 		rt->rt6i_flags |= RTF_CACHE;
-		dst_set_neighbour(&rt->dst, neigh_clone(dst_get_neighbour_raw(&ort->dst)));
+		dst_set_neighbour(&rt->dst, neigh_clone(dst_get_neighbour_noref_raw(&ort->dst)));
 	}
 	return rt;
 }
@@ -819,7 +819,7 @@ restart:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	if (!dst_get_neighbour_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!dst_get_neighbour_noref_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
@@ -1627,7 +1627,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	dst_confirm(&rt->dst);
 
 	/* Duplicate redirect: silently ignore. */
-	if (neigh == dst_get_neighbour_raw(&rt->dst))
+	if (neigh == dst_get_neighbour_noref_raw(&rt->dst))
 		goto out;
 
 	nrt = ip6_rt_copy(rt, dest);
@@ -1719,7 +1719,7 @@ again:
 	   1. It is connected route. Action: COW
 	   2. It is gatewayed route or NONEXTHOP route. Action: clone it.
 	 */
-	if (!dst_get_neighbour_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!dst_get_neighbour_noref_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, daddr, saddr);
 	else
 		nrt = rt6_alloc_clone(rt, daddr);
@@ -2454,7 +2454,7 @@ static int rt6_fill_node(struct net *net,
 		goto nla_put_failure;
 
 	rcu_read_lock();
-	n = dst_get_neighbour(&rt->dst);
+	n = dst_get_neighbour_noref(&rt->dst);
 	if (n)
 		NLA_PUT(skb, RTA_GATEWAY, 16, &n->primary_key);
 	rcu_read_unlock();
@@ -2651,7 +2651,7 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
 	rcu_read_lock();
-	n = dst_get_neighbour(&rt->dst);
+	n = dst_get_neighbour_noref(&rt->dst);
 	if (n) {
 		seq_printf(m, "%pi6", n->primary_key);
 	} else {
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 50968f2..b7d14cc 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -680,7 +680,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		struct neighbour *neigh = NULL;
 
 		if (skb_dst(skb))
-			neigh = dst_get_neighbour(skb_dst(skb));
+			neigh = dst_get_neighbour_noref(skb_dst(skb));
 
 		if (neigh == NULL) {
 			if (net_ratelimit())
@@ -705,7 +705,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		struct neighbour *neigh = NULL;
 
 		if (skb_dst(skb))
-			neigh = dst_get_neighbour(skb_dst(skb));
+			neigh = dst_get_neighbour_noref(skb_dst(skb));
 
 		if (neigh == NULL) {
 			if (net_ratelimit())
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index ed1336e..4532659 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -277,7 +277,7 @@ static inline int teql_resolve(struct sk_buff *skb,
 		return 0;
 
 	rcu_read_lock();
-	mn = dst_get_neighbour(dst);
+	mn = dst_get_neighbour_noref(dst);
 	res = mn ? __teql_resolve(skb, skb_res, dev, txq, mn) : 0;
 	rcu_read_unlock();
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4fce1ce..82e803b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1499,7 +1499,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		goto free_dst;
 
 	/* Copy neighbour for reachability confirmation */
-	dst_set_neighbour(dst0, neigh_clone(dst_get_neighbour(dst)));
+	dst_set_neighbour(dst0, neigh_clone(dst_get_neighbour_noref(dst)));
 
 	xfrm_init_path((struct xfrm_dst *)dst0, dst, nfheader_len);
 	xfrm_init_pmtu(dst_prev);
-- 
1.7.7.3
