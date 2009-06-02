From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 3/4] net: skb->dst accessors
Date: Tue, 02 Jun 2009 17:19:30 +0200
Message-ID: <4A254302.9020006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40932 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbZFBPTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 11:19:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define three accessors to get/set dst attached to a skb

struct dst_entry *skb_dst(const struct sk_buff *skb)

void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)


void skb_dst_drop(struct sk_buff *skb)
This one should replace occurrences of :
dst_release(skb->dst)
skb->dst = NULL;

Delete skb->dst field

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_cm.c        |    4 -
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   30 +++----
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |   10 +-
 drivers/net/pppol2tp.c                         |   11 +-
 drivers/s390/net/qeth_core_main.c              |    4 -
 drivers/s390/net/qeth_l3_main.c                |    8 +-
 include/linux/skbuff.h                         |   13 ++-
 include/net/dst.h                              |   12 ++-
 include/net/inet6_hashtables.h                 |    2
 include/net/inet_hashtables.h                  |    2
 include/net/ip6_route.h                        |    2
 include/net/xfrm.h                             |    4 -
 net/atm/br2684.c                               |    2
 net/atm/clip.c                                 |   14 +--
 net/bridge/br_netfilter.c                      |   18 ++--
 net/core/dev.c                                 |    7 -
 net/core/neighbour.c                           |   11 +-
 net/core/skbuff.c                              |    4 -
 net/dccp/ipv4.c                                |    4 -
 net/dccp/ipv6.c                                |    8 +-
 net/dccp/output.c                              |    2
 net/decnet/af_decnet.c                         |    6 +
 net/decnet/dn_neigh.c                          |    8 +-
 net/decnet/dn_nsp_out.c                        |    6 -
 net/decnet/dn_route.c                          |   25 +++---
 net/ipv4/arp.c                                 |    2
 net/ipv4/icmp.c                                |   10 +-
 net/ipv4/igmp.c                                |    4 -
 net/ipv4/ip_forward.c                          |    4 -
 net/ipv4/ip_fragment.c                         |    2
 net/ipv4/ip_gre.c                              |   23 ++---
 net/ipv4/ip_input.c                            |    6 -
 net/ipv4/ip_options.c                          |    6 -
 net/ipv4/ip_output.c                           |   20 ++---
 net/ipv4/ipip.c                                |   13 +--
 net/ipv4/ipmr.c                                |   13 +--
 net/ipv4/netfilter.c                           |   28 ++++---
 net/ipv4/netfilter/ipt_REJECT.c                |    7 -
 net/ipv4/netfilter/nf_nat_standalone.c         |    7 -
 net/ipv4/raw.c                                 |    2
 net/ipv4/route.c                               |   14 +--
 net/ipv4/tcp_ipv4.c                            |    4 -
 net/ipv4/tcp_output.c                          |    2
 net/ipv4/udp.c                                 |    4 -
 net/ipv4/xfrm4_input.c                         |    2
 net/ipv4/xfrm4_mode_tunnel.c                   |    4 -
 net/ipv4/xfrm4_output.c                        |    6 -
 net/ipv6/exthdrs.c                             |   40 +++++-----
 net/ipv6/inet6_connection_sock.c               |    2
 net/ipv6/ip6_input.c                           |   12 +--
 net/ipv6/ip6_output.c                          |   60 +++++++--------
 net/ipv6/ip6_tunnel.c                          |   26 +++---
 net/ipv6/ip6mr.c                               |   13 +--
 net/ipv6/mcast.c                               |   17 ++--
 net/ipv6/ndisc.c                               |    4 -
 net/ipv6/netfilter.c                           |   16 ++--
 net/ipv6/netfilter/ip6t_REJECT.c               |    2
 net/ipv6/raw.c                                 |    2
 net/ipv6/reassembly.c                          |   22 ++---
 net/ipv6/route.c                               |   12 +--
 net/ipv6/sit.c                                 |   21 ++---
 net/ipv6/tcp_ipv6.c                            |    8 +-
 net/ipv6/udp.c                                 |    7 -
 net/ipv6/xfrm6_mode_tunnel.c                   |    4 -
 net/ipv6/xfrm6_output.c                        |    4 -
 net/netfilter/ipvs/ip_vs_xmit.c                |   48 ++++++------
 net/netfilter/nf_conntrack_proto_gre.c         |    2
 net/netfilter/xt_TCPMSS.c                      |    6 -
 net/netfilter/xt_policy.c                      |    2
 net/netfilter/xt_realm.c                       |    2
 net/packet/af_packet.c                         |    6 -
 net/sched/cls_flow.c                           |    8 +-
 net/sched/cls_route.c                          |    2
 net/sched/em_meta.c                            |    4 -
 net/sched/sch_sfq.c                            |    2
 net/sched/sch_teql.c                           |    6 -
 net/sctp/output.c                              |    6 -
 net/sunrpc/xprtsock.c                          |    2
 net/xfrm/xfrm_input.c                          |    3
 net/xfrm/xfrm_output.c                         |   21 ++---
 net/xfrm/xfrm_policy.c                         |    8 +-
 security/selinux/hooks.c                       |    2
 security/selinux/xfrm.c                        |    2
 83 files changed, 414 insertions(+), 390 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a3ae3c5..9ef6eb2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -323,7 +323,6 @@ struct sk_buff {
 	struct net_device	*dev;
 
 	union {
-		struct  dst_entry	*dst;
 		unsigned long		_skb_dst;
 	};
 #ifdef CONFIG_XFRM
@@ -426,9 +425,19 @@ extern void skb_dma_unmap(struct device *dev, struct sk_buff *skb,
 			  enum dma_data_direction dir);
 #endif
 
+static inline struct dst_entry *skb_dst(const struct sk_buff *skb)
+{
+	return (struct dst_entry *)skb->_skb_dst;
+}
+
+static inline void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)
+{
+	skb->_skb_dst = (unsigned long)dst;
+}
+
 static inline struct rtable *skb_rtable(const struct sk_buff *skb)
 {
-	return (struct rtable *)skb->_skb_dst;
+	return (struct rtable *)skb_dst(skb);
 }
 
 extern void kfree_skb(struct sk_buff *skb);
diff --git a/include/net/dst.h b/include/net/dst.h
index 6be3b08..7fc409c 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -195,6 +195,12 @@ struct dst_entry * dst_clone(struct dst_entry * dst)
 }
 
 extern void dst_release(struct dst_entry *dst);
+static inline void skb_dst_drop(struct sk_buff *skb)
+{
+	if (skb->_skb_dst)
+		dst_release(skb_dst(skb));
+	skb->_skb_dst = 0UL;
+}
 
 /* Children define the path of the packet through the
  * Linux networking.  Thus, destinations are stackable.
@@ -246,7 +252,7 @@ static inline void dst_negative_advice(struct dst_entry **dst_p)
 
 static inline void dst_link_failure(struct sk_buff *skb)
 {
-	struct dst_entry * dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	if (dst && dst->ops && dst->ops->link_failure)
 		dst->ops->link_failure(skb);
 }
@@ -265,13 +271,13 @@ static inline void dst_set_expires(struct dst_entry *dst, int timeout)
 /* Output packet to network from transport.  */
 static inline int dst_output(struct sk_buff *skb)
 {
-	return skb->dst->output(skb);
+	return skb_dst(skb)->output(skb);
 }
 
 /* Input packet from network to transport.  */
 static inline int dst_input(struct sk_buff *skb)
 {
-	return skb->dst->input(skb);
+	return skb_dst(skb)->input(skb);
 }
 
 static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index f74665d..22c73a7 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -100,7 +100,7 @@ static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
 
 	if (unlikely(sk = skb_steal_sock(skb)))
 		return sk;
-	else return __inet6_lookup(dev_net(skb->dst->dev), hashinfo,
+	else return __inet6_lookup(dev_net(skb_dst(skb)->dev), hashinfo,
 				   &ipv6_hdr(skb)->saddr, sport,
 				   &ipv6_hdr(skb)->daddr, ntohs(dport),
 				   inet6_iif(skb));
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index a44e224..d522dcf 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -385,7 +385,7 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 	if (unlikely(sk = skb_steal_sock(skb)))
 		return sk;
 	else
-		return __inet_lookup(dev_net(skb->dst->dev), hashinfo,
+		return __inet_lookup(dev_net(skb_dst(skb)->dev), hashinfo,
 				     iph->saddr, sport,
 				     iph->daddr, dport, inet_iif(skb));
 }
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 5f53db7..0e1b8ae 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -142,7 +142,7 @@ static inline void ip6_dst_store(struct sock *sk, struct dst_entry *dst,
 
 static inline int ipv6_unicast_destination(struct sk_buff *skb)
 {
-	struct rt6_info *rt = (struct rt6_info *) skb->dst;
+	struct rt6_info *rt = (struct rt6_info *) skb_dst(skb);
 
 	return rt->rt6i_flags & RTF_LOCAL;
 }
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 2e9f5c0..736bca4 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -994,7 +994,7 @@ static inline int __xfrm_policy_check2(struct sock *sk, int dir,
 		return __xfrm_policy_check(sk, ndir, skb, family);
 
 	return	(!net->xfrm.policy_count[dir] && !skb->sp) ||
-		(skb->dst->flags & DST_NOPOLICY) ||
+		(skb_dst(skb)->flags & DST_NOPOLICY) ||
 		__xfrm_policy_check(sk, ndir, skb, family);
 }
 
@@ -1048,7 +1048,7 @@ static inline int xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 	struct net *net = dev_net(skb->dev);
 
 	return	!net->xfrm.policy_count[XFRM_POLICY_OUT] ||
-		(skb->dst->flags & DST_NOXFRM) ||
+		(skb_dst(skb)->flags & DST_NOXFRM) ||
 		__xfrm_route_forward(skb, family);
 }
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 4248c31..181b1f3 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -1394,8 +1394,8 @@ void ipoib_cm_skb_too_long(struct net_device *dev, struct sk_buff *skb,
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	int e = skb_queue_empty(&priv->cm.skb_queue);
 
-	if (skb->dst)
-		skb->dst->ops->update_pmtu(skb->dst, mtu);
+	if (skb_dst(skb))
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 
 	skb_queue_tail(&priv->cm.skb_queue, skb);
 	if (e)
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 69c6304..e319d91 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -561,7 +561,7 @@ static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 	struct ipoib_neigh *neigh;
 	unsigned long flags;
 
-	neigh = ipoib_neigh_alloc(skb->dst->neighbour, skb->dev);
+	neigh = ipoib_neigh_alloc(skb_dst(skb)->neighbour, skb->dev);
 	if (!neigh) {
 		++dev->stats.tx_dropped;
 		dev_kfree_skb_any(skb);
@@ -570,9 +570,9 @@ static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&priv->lock, flags);
 
-	path = __path_find(dev, skb->dst->neighbour->ha + 4);
+	path = __path_find(dev, skb_dst(skb)->neighbour->ha + 4);
 	if (!path) {
-		path = path_rec_create(dev, skb->dst->neighbour->ha + 4);
+		path = path_rec_create(dev, skb_dst(skb)->neighbour->ha + 4);
 		if (!path)
 			goto err_path;
 
@@ -605,7 +605,7 @@ static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 				goto err_drop;
 			}
 		} else
-			ipoib_send(dev, skb, path->ah, IPOIB_QPN(skb->dst->neighbour->ha));
+			ipoib_send(dev, skb, path->ah, IPOIB_QPN(skb_dst(skb)->neighbour->ha));
 	} else {
 		neigh->ah  = NULL;
 
@@ -635,15 +635,15 @@ static void ipoib_path_lookup(struct sk_buff *skb, struct net_device *dev)
 	struct ipoib_dev_priv *priv = netdev_priv(skb->dev);
 
 	/* Look up path record for unicasts */
-	if (skb->dst->neighbour->ha[4] != 0xff) {
+	if (skb_dst(skb)->neighbour->ha[4] != 0xff) {
 		neigh_add_path(skb, dev);
 		return;
 	}
 
 	/* Add in the P_Key for multicasts */
-	skb->dst->neighbour->ha[8] = (priv->pkey >> 8) & 0xff;
-	skb->dst->neighbour->ha[9] = priv->pkey & 0xff;
-	ipoib_mcast_send(dev, skb->dst->neighbour->ha + 4, skb);
+	skb_dst(skb)->neighbour->ha[8] = (priv->pkey >> 8) & 0xff;
+	skb_dst(skb)->neighbour->ha[9] = priv->pkey & 0xff;
+	ipoib_mcast_send(dev, skb_dst(skb)->neighbour->ha + 4, skb);
 }
 
 static void unicast_arp_send(struct sk_buff *skb, struct net_device *dev,
@@ -708,16 +708,16 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct ipoib_neigh *neigh;
 	unsigned long flags;
 
-	if (likely(skb->dst && skb->dst->neighbour)) {
-		if (unlikely(!*to_ipoib_neigh(skb->dst->neighbour))) {
+	if (likely(skb_dst(skb) && skb_dst(skb)->neighbour)) {
+		if (unlikely(!*to_ipoib_neigh(skb_dst(skb)->neighbour))) {
 			ipoib_path_lookup(skb, dev);
 			return NETDEV_TX_OK;
 		}
 
-		neigh = *to_ipoib_neigh(skb->dst->neighbour);
+		neigh = *to_ipoib_neigh(skb_dst(skb)->neighbour);
 
 		if (unlikely((memcmp(&neigh->dgid.raw,
-				     skb->dst->neighbour->ha + 4,
+				     skb_dst(skb)->neighbour->ha + 4,
 				     sizeof(union ib_gid))) ||
 			     (neigh->dev != dev))) {
 			spin_lock_irqsave(&priv->lock, flags);
@@ -743,7 +743,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				return NETDEV_TX_OK;
 			}
 		} else if (neigh->ah) {
-			ipoib_send(dev, skb, neigh->ah, IPOIB_QPN(skb->dst->neighbour->ha));
+			ipoib_send(dev, skb, neigh->ah, IPOIB_QPN(skb_dst(skb)->neighbour->ha));
 			return NETDEV_TX_OK;
 		}
 
@@ -772,7 +772,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			if ((be16_to_cpup((__be16 *) skb->data) != ETH_P_ARP) &&
 			    (be16_to_cpup((__be16 *) skb->data) != ETH_P_RARP)) {
 				ipoib_warn(priv, "Unicast, no %s: type %04x, QPN %06x %pI6\n",
-					   skb->dst ? "neigh" : "dst",
+					   skb_dst(skb) ? "neigh" : "dst",
 					   be16_to_cpup((__be16 *) skb->data),
 					   IPOIB_QPN(phdr->hwaddr),
 					   phdr->hwaddr + 4);
@@ -817,7 +817,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
 	 * destination address onto the front of the skb so we can
 	 * figure out where to send the packet later.
 	 */
-	if ((!skb->dst || !skb->dst->neighbour) && daddr) {
+	if ((!skb_dst(skb) || !skb_dst(skb)->neighbour) && daddr) {
 		struct ipoib_pseudoheader *phdr =
 			(struct ipoib_pseudoheader *) skb_push(skb, sizeof *phdr);
 		memcpy(phdr->hwaddr, daddr, INFINIBAND_ALEN);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 425e311..a0e9753 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -261,7 +261,7 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 
 		skb->dev = dev;
 
-		if (!skb->dst || !skb->dst->neighbour) {
+		if (!skb_dst(skb) || !skb_dst(skb)->neighbour) {
 			/* put pseudoheader back on for next time */
 			skb_push(skb, sizeof (struct ipoib_pseudoheader));
 		}
@@ -707,10 +707,10 @@ void ipoib_mcast_send(struct net_device *dev, void *mgid, struct sk_buff *skb)
 
 out:
 	if (mcast && mcast->ah) {
-		if (skb->dst		&&
-		    skb->dst->neighbour &&
-		    !*to_ipoib_neigh(skb->dst->neighbour)) {
-			struct ipoib_neigh *neigh = ipoib_neigh_alloc(skb->dst->neighbour,
+		if (skb_dst(skb)		&&
+		    skb_dst(skb)->neighbour &&
+		    !*to_ipoib_neigh(skb_dst(skb)->neighbour)) {
+			struct ipoib_neigh *neigh = ipoib_neigh_alloc(skb_dst(skb)->neighbour,
 									skb->dev);
 
 			if (neigh) {
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 5981deb..e7935d0 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -433,8 +433,7 @@ static void pppol2tp_recv_dequeue_skb(struct pppol2tp_session *session, struct s
 		 *   to the inner packet either
 		 */
 		secpath_reset(skb);
-		dst_release(skb->dst);
-		skb->dst = NULL;
+		skb_dst_drop(skb);
 		nf_reset(skb);
 
 		po = pppox_sk(session_sock);
@@ -976,7 +975,7 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msgh
 	/* Calculate UDP checksum if configured to do so */
 	if (sk_tun->sk_no_check == UDP_CSUM_NOXMIT)
 		skb->ip_summed = CHECKSUM_NONE;
-	else if (!(skb->dst->dev->features & NETIF_F_V4_CSUM)) {
+	else if (!(skb_dst(skb)->dev->features & NETIF_F_V4_CSUM)) {
 		skb->ip_summed = CHECKSUM_COMPLETE;
 		csum = skb_checksum(skb, 0, udp_len, 0);
 		uh->check = csum_tcpudp_magic(inet->saddr, inet->daddr,
@@ -1172,14 +1171,14 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	nf_reset(skb);
 
 	/* Get routing info from the tunnel socket */
-	dst_release(skb->dst);
-	skb->dst = dst_clone(__sk_dst_get(sk_tun));
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst_clone(__sk_dst_get(sk_tun)));
 	pppol2tp_skb_set_owner_w(skb, sk_tun);
 
 	/* Calculate UDP checksum if configured to do so */
 	if (sk_tun->sk_no_check == UDP_CSUM_NOXMIT)
 		skb->ip_summed = CHECKSUM_NONE;
-	else if (!(skb->dst->dev->features & NETIF_F_V4_CSUM)) {
+	else if (!(skb_dst(skb)->dev->features & NETIF_F_V4_CSUM)) {
 		skb->ip_summed = CHECKSUM_COMPLETE;
 		csum = skb_checksum(skb, 0, udp_len, 0);
 		uh->check = csum_tcpudp_magic(inet->saddr, inet->daddr,
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 2994aa1..74c49d9 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2937,8 +2937,8 @@ int qeth_get_cast_type(struct qeth_card *card, struct sk_buff *skb)
 	if (card->info.type == QETH_CARD_TYPE_OSN)
 		return cast_type;
 
-	if (skb->dst && skb->dst->neighbour) {
-		cast_type = skb->dst->neighbour->type;
+	if (skb_dst(skb) && skb_dst(skb)->neighbour) {
+		cast_type = skb_dst(skb)->neighbour->type;
 		if ((cast_type == RTN_BROADCAST) ||
 		    (cast_type == RTN_MULTICAST) ||
 		    (cast_type == RTN_ANYCAST))
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index cb64b0b..6f2386e 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2549,9 +2549,9 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 		/* IPv4 */
 		hdr->hdr.l3.flags = qeth_l3_get_qeth_hdr_flags4(cast_type);
 		memset(hdr->hdr.l3.dest_addr, 0, 12);
-		if ((skb->dst) && (skb->dst->neighbour)) {
+		if ((skb_dst(skb)) && (skb_dst(skb)->neighbour)) {
 			*((u32 *) (&hdr->hdr.l3.dest_addr[12])) =
-			    *((u32 *) skb->dst->neighbour->primary_key);
+			    *((u32 *) skb_dst(skb)->neighbour->primary_key);
 		} else {
 			/* fill in destination address used in ip header */
 			*((u32 *) (&hdr->hdr.l3.dest_addr[12])) =
@@ -2562,9 +2562,9 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 		hdr->hdr.l3.flags = qeth_l3_get_qeth_hdr_flags6(cast_type);
 		if (card->info.type == QETH_CARD_TYPE_IQD)
 			hdr->hdr.l3.flags &= ~QETH_HDR_PASSTHRU;
-		if ((skb->dst) && (skb->dst->neighbour)) {
+		if ((skb_dst(skb)) && (skb_dst(skb)->neighbour)) {
 			memcpy(hdr->hdr.l3.dest_addr,
-			       skb->dst->neighbour->primary_key, 16);
+			       skb_dst(skb)->neighbour->primary_key, 16);
 		} else {
 			/* fill in destination address used in ip header */
 			memcpy(hdr->hdr.l3.dest_addr,
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index bfa8fa9..2912665 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -228,7 +228,7 @@ static int br2684_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct br2684_dev *brdev = BRPRIV(dev);
 	struct br2684_vcc *brvcc;
 
-	pr_debug("br2684_start_xmit, skb->dst=%p\n", skb->dst);
+	pr_debug("br2684_start_xmit, skb_dst(skb)=%p\n", skb_dst(skb));
 	read_lock(&devs_lock);
 	brvcc = pick_outgoing_vcc(skb, brdev);
 	if (brvcc == NULL) {
diff --git a/net/atm/clip.c b/net/atm/clip.c
index fb7623c..e65a3b1 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -369,16 +369,16 @@ static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 
 	pr_debug("clip_start_xmit (skb %p)\n", skb);
-	if (!skb->dst) {
-		printk(KERN_ERR "clip_start_xmit: skb->dst == NULL\n");
+	if (!skb_dst(skb)) {
+		printk(KERN_ERR "clip_start_xmit: skb_dst(skb) == NULL\n");
 		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
 		return 0;
 	}
-	if (!skb->dst->neighbour) {
+	if (!skb_dst(skb)->neighbour) {
 #if 0
-		skb->dst->neighbour = clip_find_neighbour(skb->dst, 1);
-		if (!skb->dst->neighbour) {
+		skb_dst(skb)->neighbour = clip_find_neighbour(skb_dst(skb), 1);
+		if (!skb_dst(skb)->neighbour) {
 			dev_kfree_skb(skb);	/* lost that one */
 			dev->stats.tx_dropped++;
 			return 0;
@@ -389,7 +389,7 @@ static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev->stats.tx_dropped++;
 		return 0;
 	}
-	entry = NEIGH2ENTRY(skb->dst->neighbour);
+	entry = NEIGH2ENTRY(skb_dst(skb)->neighbour);
 	if (!entry->vccs) {
 		if (time_after(jiffies, entry->expires)) {
 			/* should be resolved */
@@ -406,7 +406,7 @@ static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	pr_debug("neigh %p, vccs %p\n", entry, entry->vccs);
 	ATM_SKB(skb)->vcc = vcc = entry->vccs->vcc;
-	pr_debug("using neighbour %p, vcc %p\n", skb->dst->neighbour, vcc);
+	pr_debug("using neighbour %p, vcc %p\n", skb_dst(skb)->neighbour, vcc);
 	if (entry->vccs->encap) {
 		void *here;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index e0ceb66..d22f611 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -242,7 +242,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 		return 0;
 	}
 	dst_hold(&rt->u.dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_set(skb, &rt->u.dst);
 
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_push_encap_header(skb);
@@ -322,7 +322,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 
 	skb->dev = bridge_parent(skb->dev);
 	if (skb->dev) {
-		struct dst_entry *dst = skb->dst;
+		struct dst_entry *dst = skb_dst(skb);
 
 		nf_bridge_pull_encap_header(skb);
 
@@ -375,7 +375,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 				/* - Bridged-and-DNAT'ed traffic doesn't
 				 *   require ip_forwarding. */
 				if (((struct dst_entry *)rt)->dev == dev) {
-					skb->dst = (struct dst_entry *)rt;
+					skb_dst_set(skb, (struct dst_entry *)rt);
 					goto bridged_dnat;
 				}
 				/* we are sure that forwarding is disabled, so printing
@@ -389,7 +389,7 @@ free_skb:
 			kfree_skb(skb);
 			return 0;
 		} else {
-			if (skb->dst->dev == dev) {
+			if (skb_dst(skb)->dev == dev) {
 bridged_dnat:
 				/* Tell br_nf_local_out this is a
 				 * bridged frame */
@@ -412,7 +412,7 @@ bridged_dnat:
 			return 0;
 		}
 		dst_hold(&rt->u.dst);
-		skb->dst = &rt->u.dst;
+		skb_dst_set(skb, &rt->u.dst);
 	}
 
 	skb->dev = nf_bridge->physindev;
@@ -633,10 +633,8 @@ static unsigned int br_nf_local_in(unsigned int hook, struct sk_buff *skb,
 {
 	struct rtable *rt = skb_rtable(skb);
 
-	if (rt && rt == bridge_parent_rtable(in)) {
-		dst_release(&rt->u.dst);
-		skb->dst = NULL;
-	}
+	if (rt && rt == bridge_parent_rtable(in))
+		skb_dst_drop(skb);
 
 	return NF_ACCEPT;
 }
@@ -851,7 +849,7 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 #ifdef CONFIG_NETFILTER_DEBUG
-	if (skb->dst == NULL) {
+	if (skb_dst(skb) == NULL) {
 		printk(KERN_INFO "br_netfilter post_routing: skb->dst == NULL\n");
 		goto print_error;
 	}
diff --git a/net/core/dev.c b/net/core/dev.c
index e2fcc5f..34b49a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1693,10 +1693,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		 * If device doesnt need skb->dst, release it right now while
 		 * its hot in this cpu cache
 		 */
-		if ((dev->priv_flags & IFF_XMIT_DST_RELEASE) && skb->dst) {
-			dst_release(skb->dst);
-			skb->dst = NULL;
-		}
+		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
+			skb_dst_drop(skb);
+
 		rc = ops->ndo_start_xmit(skb, dev);
 		if (rc == 0)
 			txq_trans_update(txq);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index a1cbce7..c54229b 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1088,8 +1088,8 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 			struct neighbour *n1 = neigh;
 			write_unlock_bh(&neigh->lock);
 			/* On shaper/eql skb->dst->neighbour != neigh :( */
-			if (skb->dst && skb->dst->neighbour)
-				n1 = skb->dst->neighbour;
+			if (skb_dst(skb) && skb_dst(skb)->neighbour)
+				n1 = skb_dst(skb)->neighbour;
 			n1->output(skb);
 			write_lock_bh(&neigh->lock);
 		}
@@ -1182,7 +1182,7 @@ EXPORT_SYMBOL(neigh_compat_output);
 
 int neigh_resolve_output(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct neighbour *neigh;
 	int rc = 0;
 
@@ -1229,7 +1229,7 @@ EXPORT_SYMBOL(neigh_resolve_output);
 int neigh_connected_output(struct sk_buff *skb)
 {
 	int err;
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct neighbour *neigh = dst->neighbour;
 	struct net_device *dev = neigh->dev;
 
@@ -1298,8 +1298,7 @@ void pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 		if (time_before(tbl->proxy_timer.expires, sched_next))
 			sched_next = tbl->proxy_timer.expires;
 	}
-	dst_release(skb->dst);
-	skb->dst = NULL;
+	skb_dst_drop(skb);
 	dev_hold(skb->dev);
 	__skb_queue_tail(&tbl->proxy_queue, skb);
 	mod_timer(&tbl->proxy_timer, sched_next);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8e815e6..6adf19e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -381,7 +381,7 @@ static void kfree_skbmem(struct sk_buff *skb)
 
 static void skb_release_head_state(struct sk_buff *skb)
 {
-	dst_release(skb->dst);
+	skb_dst_drop(skb);
 #ifdef CONFIG_XFRM
 	secpath_put(skb->sp);
 #endif
@@ -521,7 +521,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->transport_header	= old->transport_header;
 	new->network_header	= old->network_header;
 	new->mac_header		= old->mac_header;
-	new->dst		= dst_clone(old->dst);
+	skb_dst_set(new, dst_clone(skb_dst(old)));
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 2cf48ba..a0a36c9 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -507,7 +507,7 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	const struct iphdr *rxiph;
 	struct sk_buff *skb;
 	struct dst_entry *dst;
-	struct net *net = dev_net(rxskb->dst->dev);
+	struct net *net = dev_net(skb_dst(rxskb)->dev);
 	struct sock *ctl_sk = net->dccp.v4_ctl_sk;
 
 	/* Never send a reset in response to a reset. */
@@ -528,7 +528,7 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	rxiph = ip_hdr(rxskb);
 	dccp_hdr(skb)->dccph_checksum = dccp_v4_csum_finish(skb, rxiph->saddr,
 								 rxiph->daddr);
-	skb->dst = dst_clone(dst);
+	skb_dst_set(skb, dst_clone(dst));
 
 	bh_lock_sock(ctl_sk);
 	err = ip_build_and_send_pkt(skb, ctl_sk,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index b963f35..05ea744 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -314,8 +314,9 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	struct ipv6hdr *rxip6h;
 	struct sk_buff *skb;
 	struct flowi fl;
-	struct net *net = dev_net(rxskb->dst->dev);
+	struct net *net = dev_net(skb_dst(rxskb)->dev);
 	struct sock *ctl_sk = net->dccp.v6_ctl_sk;
+	struct dst_entry *dst;
 
 	if (dccp_hdr(rxskb)->dccph_type == DCCP_PKT_RESET)
 		return;
@@ -342,8 +343,9 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	security_skb_classify_flow(rxskb, &fl);
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
-	if (!ip6_dst_lookup(ctl_sk, &skb->dst, &fl)) {
-		if (xfrm_lookup(net, &skb->dst, &fl, NULL, 0) >= 0) {
+	if (!ip6_dst_lookup(ctl_sk, &dst, &fl)) {
+		if (xfrm_lookup(net, &dst, &fl, NULL, 0) >= 0) {
+			skb_dst_set(skb, dst);
 			ip6_xmit(ctl_sk, skb, &fl, NULL, 0);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 36bcc00..c0e88c1 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -350,7 +350,7 @@ struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
 	/* Reserve space for headers. */
 	skb_reserve(skb, sk->sk_prot->max_header);
 
-	skb->dst = dst_clone(dst);
+	skb_dst_set(skb, dst_clone(dst));
 
 	dreq = dccp_rsk(req);
 	if (inet_rsk(req)->acked)	/* increase ISS upon retransmission */
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index bccb388..a5e3a59 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1075,6 +1075,7 @@ static int dn_accept(struct socket *sock, struct socket *newsock, int flags)
 	int err = 0;
 	unsigned char type;
 	long timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
+	struct dst_entry *dst;
 
 	lock_sock(sk);
 
@@ -1102,8 +1103,9 @@ static int dn_accept(struct socket *sock, struct socket *newsock, int flags)
 	}
 	release_sock(sk);
 
-	dst_release(xchg(&newsk->sk_dst_cache, skb->dst));
-	skb->dst = NULL;
+	dst = skb_dst(skb);
+	dst_release(xchg(&newsk->sk_dst_cache, dst));
+	skb_dst_set(skb, NULL);
 
 	DN_SK(newsk)->state        = DN_CR;
 	DN_SK(newsk)->addrrem      = cb->src_port;
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 05b5aa0..923786b 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -204,7 +204,7 @@ static void dn_short_error_report(struct neighbour *neigh, struct sk_buff *skb)
 
 static int dn_neigh_output_packet(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *)dst;
 	struct neighbour *neigh = dst->neighbour;
 	struct net_device *dev = neigh->dev;
@@ -224,7 +224,7 @@ static int dn_neigh_output_packet(struct sk_buff *skb)
 
 static int dn_long_output(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct neighbour *neigh = dst->neighbour;
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_long_packet) + 3;
@@ -270,7 +270,7 @@ static int dn_long_output(struct sk_buff *skb)
 
 static int dn_short_output(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct neighbour *neigh = dst->neighbour;
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_short_packet) + 2;
@@ -313,7 +313,7 @@ static int dn_short_output(struct sk_buff *skb)
  */
 static int dn_phase3_output(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct neighbour *neigh = dst->neighbour;
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_short_packet) + 2;
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index da04f45..a65e929 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -85,7 +85,7 @@ static void dn_nsp_send(struct sk_buff *skb)
 	dst = sk_dst_check(sk, 0);
 	if (dst) {
 try_again:
-		skb->dst = dst;
+		skb_dst_set(skb, dst);
 		dst_output(skb);
 		return;
 	}
@@ -582,7 +582,7 @@ static __inline__ void dn_nsp_do_disc(struct sock *sk, unsigned char msgflg,
 	 * to be able to send disc packets out which have no socket
 	 * associations.
 	 */
-	skb->dst = dst_clone(dst);
+	skb_dst_set(skb, dst_clone(dst));
 	dst_output(skb);
 }
 
@@ -611,7 +611,7 @@ void dn_nsp_return_disc(struct sk_buff *skb, unsigned char msgflg,
 	int ddl = 0;
 	gfp_t gfp = GFP_ATOMIC;
 
-	dn_nsp_do_disc(NULL, msgflg, reason, gfp, skb->dst, ddl,
+	dn_nsp_do_disc(NULL, msgflg, reason, gfp, skb_dst(skb), ddl,
 			NULL, cb->src_port, cb->dst_port);
 }
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 0cc4394..1d6ca8a 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -678,7 +678,7 @@ out:
 
 static int dn_output(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *)dst;
 	struct net_device *dev = dst->dev;
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
@@ -717,7 +717,7 @@ error:
 static int dn_forward(struct sk_buff *skb)
 {
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct dn_dev *dn_db = dst->dev->dn_ptr;
 	struct dn_route *rt;
 	struct neighbour *neigh = dst->neighbour;
@@ -730,7 +730,7 @@ static int dn_forward(struct sk_buff *skb)
 		goto drop;
 
 	/* Ensure that we have enough space for headers */
-	rt = (struct dn_route *)skb->dst;
+	rt = (struct dn_route *)skb_dst(skb);
 	header_len = dn_db->use_long ? 21 : 6;
 	if (skb_cow(skb, LL_RESERVED_SPACE(rt->u.dst.dev)+header_len))
 		goto drop;
@@ -1392,7 +1392,8 @@ make_route:
 		goto e_neighbour;
 
 	hash = dn_hash(rt->fl.fld_src, rt->fl.fld_dst);
-	dn_insert_route(rt, hash, (struct dn_route **)&skb->dst);
+	dn_insert_route(rt, hash, &rt);
+	skb_dst_set(skb, &rt->u.dst);
 
 done:
 	if (neigh)
@@ -1424,7 +1425,7 @@ static int dn_route_input(struct sk_buff *skb)
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
 	unsigned hash = dn_hash(cb->src, cb->dst);
 
-	if (skb->dst)
+	if (skb_dst(skb))
 		return 0;
 
 	rcu_read_lock();
@@ -1437,7 +1438,7 @@ static int dn_route_input(struct sk_buff *skb)
 		    (rt->fl.iif == cb->iif)) {
 			dst_use(&rt->u.dst, jiffies);
 			rcu_read_unlock();
-			skb->dst = (struct dst_entry *)rt;
+			skb_dst_set(skb, (struct dst_entry *)rt);
 			return 0;
 		}
 	}
@@ -1449,7 +1450,7 @@ static int dn_route_input(struct sk_buff *skb)
 static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 			   int event, int nowait, unsigned int flags)
 {
-	struct dn_route *rt = (struct dn_route *)skb->dst;
+	struct dn_route *rt = (struct dn_route *)skb_dst(skb);
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
@@ -1554,7 +1555,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 		err = dn_route_input(skb);
 		local_bh_enable();
 		memset(cb, 0, sizeof(struct dn_skb_cb));
-		rt = (struct dn_route *)skb->dst;
+		rt = (struct dn_route *)skb_dst(skb);
 		if (!err && -rt->u.dst.error)
 			err = rt->u.dst.error;
 	} else {
@@ -1570,7 +1571,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	skb->dev = NULL;
 	if (err)
 		goto out_free;
-	skb->dst = &rt->u.dst;
+	skb_dst_set(skb, &rt->u.dst);
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
@@ -1622,15 +1623,15 @@ int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			rt = rcu_dereference(rt->u.dst.dn_next), idx++) {
 			if (idx < s_idx)
 				continue;
-			skb->dst = dst_clone(&rt->u.dst);
+			skb_dst_set(skb, dst_clone(&rt->u.dst));
 			if (dn_rt_fill_info(skb, NETLINK_CB(cb->skb).pid,
 					cb->nlh->nlmsg_seq, RTM_NEWROUTE,
 					1, NLM_F_MULTI) <= 0) {
-				dst_release(xchg(&skb->dst, NULL));
+				skb_dst_drop(skb);
 				rcu_read_unlock_bh();
 				goto done;
 			}
-			dst_release(xchg(&skb->dst, NULL));
+			skb_dst_drop(skb);
 		}
 		rcu_read_unlock_bh();
 	}
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 816494f..8a3881e 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -468,7 +468,7 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 	__be32 paddr;
 	struct neighbour *n;
 
-	if (!skb->dst) {
+	if (!skb_dst(skb)) {
 		printk(KERN_DEBUG "arp_find is called with dst==NULL\n");
 		kfree_skb(skb);
 		return 1;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 94f75ef..97c410e 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -591,13 +591,13 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 				goto relookup_failed;
 
 			/* Ugh! */
-			odst = skb_in->dst;
+			odst = skb_dst(skb_in);
 			err = ip_route_input(skb_in, fl.fl4_dst, fl.fl4_src,
 					     RT_TOS(tos), rt2->u.dst.dev);
 
 			dst_release(&rt2->u.dst);
 			rt2 = skb_rtable(skb_in);
-			skb_in->dst = odst;
+			skb_dst_set(skb_in, odst);
 		}
 
 		if (err)
@@ -659,7 +659,7 @@ static void icmp_unreach(struct sk_buff *skb)
 	u32 info = 0;
 	struct net *net;
 
-	net = dev_net(skb->dst->dev);
+	net = dev_net(skb_dst(skb)->dev);
 
 	/*
 	 *	Incomplete header ?
@@ -822,7 +822,7 @@ static void icmp_echo(struct sk_buff *skb)
 {
 	struct net *net;
 
-	net = dev_net(skb->dst->dev);
+	net = dev_net(skb_dst(skb)->dev);
 	if (!net->ipv4.sysctl_icmp_echo_ignore_all) {
 		struct icmp_bxm icmp_param;
 
@@ -873,7 +873,7 @@ static void icmp_timestamp(struct sk_buff *skb)
 out:
 	return;
 out_err:
-	ICMP_INC_STATS_BH(dev_net(skb->dst->dev), ICMP_MIB_INERRORS);
+	ICMP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ICMP_MIB_INERRORS);
 	goto out;
 }
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index afabd27..01b4284 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -311,7 +311,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 		return NULL;
 	}
 
-	skb->dst = &rt->u.dst;
+	skb_dst_set(skb, &rt->u.dst);
 	skb->dev = dev;
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
@@ -659,7 +659,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 		return -1;
 	}
 
-	skb->dst = &rt->u.dst;
+	skb_dst_set(skb, &rt->u.dst);
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 0761cd9..a2991bc 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -42,7 +42,7 @@ static int ip_forward_finish(struct sk_buff *skb)
 {
 	struct ip_options * opt	= &(IPCB(skb)->opt);
 
-	IP_INC_STATS_BH(dev_net(skb->dst->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
@@ -123,7 +123,7 @@ sr_failed:
 
 too_many_hops:
 	/* Tell the sender its packet died... */
-	IP_INC_STATS_BH(dev_net(skb->dst->dev), IPSTATS_MIB_INHDRERRORS);
+	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_INHDRERRORS);
 	icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
 drop:
 	kfree_skb(skb);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 7985346..1f1b824 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -573,7 +573,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 	struct ipq *qp;
 	struct net *net;
 
-	net = skb->dev ? dev_net(skb->dev) : dev_net(skb->dst->dev);
+	net = skb->dev ? dev_net(skb->dev) : dev_net(skb_dst(skb)->dev);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
 
 	/* Start by cleaning up the memory. */
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 85ddad4..44e2a3d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -643,8 +643,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 		stats->rx_packets++;
 		stats->rx_bytes += len;
 		skb->dev = tunnel->dev;
-		dst_release(skb->dst);
-		skb->dst = NULL;
+		skb_dst_drop(skb);
 		nf_reset(skb);
 
 		skb_reset_network_header(skb);
@@ -698,7 +697,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if ((dst = tiph->daddr) == 0) {
 		/* NBMA tunnel */
 
-		if (skb->dst == NULL) {
+		if (skb_dst(skb) == NULL) {
 			stats->tx_fifo_errors++;
 			goto tx_error;
 		}
@@ -712,7 +711,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		else if (skb->protocol == htons(ETH_P_IPV6)) {
 			struct in6_addr *addr6;
 			int addr_type;
-			struct neighbour *neigh = skb->dst->neighbour;
+			struct neighbour *neigh = skb_dst(skb)->neighbour;
 
 			if (neigh == NULL)
 				goto tx_error;
@@ -766,10 +765,10 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (df)
 		mtu = dst_mtu(&rt->u.dst) - dev->hard_header_len - tunnel->hlen;
 	else
-		mtu = skb->dst ? dst_mtu(skb->dst) : dev->mtu;
+		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
 
-	if (skb->dst)
-		skb->dst->ops->update_pmtu(skb->dst, mtu);
+	if (skb_dst(skb))
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 
 	if (skb->protocol == htons(ETH_P_IP)) {
 		df |= (old_iph->frag_off&htons(IP_DF));
@@ -783,14 +782,14 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 #ifdef CONFIG_IPV6
 	else if (skb->protocol == htons(ETH_P_IPV6)) {
-		struct rt6_info *rt6 = (struct rt6_info *)skb->dst;
+		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
 
-		if (rt6 && mtu < dst_mtu(skb->dst) && mtu >= IPV6_MIN_MTU) {
+		if (rt6 && mtu < dst_mtu(skb_dst(skb)) && mtu >= IPV6_MIN_MTU) {
 			if ((tunnel->parms.iph.daddr &&
 			     !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
 			    rt6->rt6i_dst.plen == 128) {
 				rt6->rt6i_flags |= RTF_MODIFIED;
-				skb->dst->metrics[RTAX_MTU-1] = mtu;
+				skb_dst(skb)->metrics[RTAX_MTU-1] = mtu;
 			}
 		}
 
@@ -837,8 +836,8 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	/*
 	 *	Push down and install the IPIP header.
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index cea784b..490ce20 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -329,7 +329,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	 *	Initialise the virtual path cache for the packet. It describes
 	 *	how the packet travels inside Linux networking.
 	 */
-	if (skb->dst == NULL) {
+	if (skb_dst(skb) == NULL) {
 		int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
 					 skb->dev);
 		if (unlikely(err)) {
@@ -344,9 +344,9 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	}
 
 #ifdef CONFIG_NET_CLS_ROUTE
-	if (unlikely(skb->dst->tclassid)) {
+	if (unlikely(skb_dst(skb)->tclassid)) {
 		struct ip_rt_acct *st = per_cpu_ptr(ip_rt_acct, smp_processor_id());
-		u32 idx = skb->dst->tclassid;
+		u32 idx = skb_dst(skb)->tclassid;
 		st[idx&0xFF].o_packets++;
 		st[idx&0xFF].o_bytes += skb->len;
 		st[(idx>>16)&0xFF].i_packets++;
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 7e1074f..94bf105 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -143,7 +143,7 @@ int ip_options_echo(struct ip_options * dopt, struct sk_buff * skb)
 						__be32 addr;
 
 						memcpy(&addr, sptr+soffset-1, 4);
-						if (inet_addr_type(dev_net(skb->dst->dev), addr) != RTN_LOCAL) {
+						if (inet_addr_type(dev_net(skb_dst(skb)->dev), addr) != RTN_LOCAL) {
 							dopt->ts_needtime = 1;
 							soffset += 8;
 						}
@@ -624,12 +624,12 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 		memcpy(&nexthop, &optptr[srrptr-1], 4);
 
 		rt = skb_rtable(skb);
-		skb->dst = NULL;
+		skb_dst_set(skb, NULL);
 		err = ip_route_input(skb, nexthop, iph->saddr, iph->tos, skb->dev);
 		rt2 = skb_rtable(skb);
 		if (err || (rt2->rt_type != RTN_UNICAST && rt2->rt_type != RTN_LOCAL)) {
 			ip_rt_put(rt2);
-			skb->dst = &rt->u.dst;
+			skb_dst_set(skb, &rt->u.dst);
 			return -EINVAL;
 		}
 		ip_rt_put(rt);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8d845eb..3d6167f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -95,7 +95,7 @@ int __ip_local_out(struct sk_buff *skb)
 
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
-	return nf_hook(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, skb->dst->dev,
+	return nf_hook(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
 		       dst_output);
 }
 
@@ -118,7 +118,7 @@ static int ip_dev_loopback_xmit(struct sk_buff *newskb)
 	__skb_pull(newskb, skb_network_offset(newskb));
 	newskb->pkt_type = PACKET_LOOPBACK;
 	newskb->ip_summed = CHECKSUM_UNNECESSARY;
-	WARN_ON(!newskb->dst);
+	WARN_ON(!skb_dst(newskb));
 	netif_rx(newskb);
 	return 0;
 }
@@ -176,7 +176,7 @@ EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
 
 static inline int ip_finish_output2(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct rtable *rt = (struct rtable *)dst;
 	struct net_device *dev = dst->dev;
 	unsigned int hh_len = LL_RESERVED_SPACE(dev);
@@ -217,14 +217,14 @@ static inline int ip_skb_dst_mtu(struct sk_buff *skb)
 	struct inet_sock *inet = skb->sk ? inet_sk(skb->sk) : NULL;
 
 	return (inet && inet->pmtudisc == IP_PMTUDISC_PROBE) ?
-	       skb->dst->dev->mtu : dst_mtu(skb->dst);
+	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
 }
 
 static int ip_finish_output(struct sk_buff *skb)
 {
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */
-	if (skb->dst->xfrm != NULL) {
+	if (skb_dst(skb)->xfrm != NULL) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
 		return dst_output(skb);
 	}
@@ -296,7 +296,7 @@ int ip_mc_output(struct sk_buff *skb)
 
 int ip_output(struct sk_buff *skb)
 {
-	struct net_device *dev = skb->dst->dev;
+	struct net_device *dev = skb_dst(skb)->dev;
 
 	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
 
@@ -355,7 +355,7 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 		}
 		sk_setup_caps(sk, &rt->u.dst);
 	}
-	skb->dst = dst_clone(&rt->u.dst);
+	skb_dst_set(skb, dst_clone(&rt->u.dst));
 
 packet_routed:
 	if (opt && opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
@@ -401,8 +401,8 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	to->pkt_type = from->pkt_type;
 	to->priority = from->priority;
 	to->protocol = from->protocol;
-	dst_release(to->dst);
-	to->dst = dst_clone(from->dst);
+	skb_dst_drop(to);
+	skb_dst_set(to, dst_clone(skb_dst(from)));
 	to->dev = from->dev;
 	to->mark = from->mark;
 
@@ -1294,7 +1294,7 @@ int ip_push_pending_frames(struct sock *sk)
 	 * on dst refcount
 	 */
 	inet->cork.dst = NULL;
-	skb->dst = &rt->u.dst;
+	skb_dst_set(skb, &rt->u.dst);
 
 	if (iph->protocol == IPPROTO_ICMP)
 		icmp_out_count(net, ((struct icmphdr *)
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 0c6e7bf..93e2b78 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -370,8 +370,7 @@ static int ipip_rcv(struct sk_buff *skb)
 		tunnel->dev->stats.rx_packets++;
 		tunnel->dev->stats.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
-		dst_release(skb->dst);
-		skb->dst = NULL;
+		skb_dst_drop(skb);
 		nf_reset(skb);
 		ipip_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
@@ -447,15 +446,15 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (tiph->frag_off)
 		mtu = dst_mtu(&rt->u.dst) - sizeof(struct iphdr);
 	else
-		mtu = skb->dst ? dst_mtu(skb->dst) : dev->mtu;
+		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
 
 	if (mtu < 68) {
 		stats->collisions++;
 		ip_rt_put(rt);
 		goto tx_error;
 	}
-	if (skb->dst)
-		skb->dst->ops->update_pmtu(skb->dst, mtu);
+	if (skb_dst(skb))
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 
 	df |= (old_iph->frag_off&htons(IP_DF));
 
@@ -502,8 +501,8 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	/*
 	 *	Push down and install the IPIP header.
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 69dd058..ffd9861 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -651,7 +651,7 @@ static int ipmr_cache_report(struct net *net,
 	ip_hdr(skb)->protocol = 0;			/* Flag to the kernel this is a route add */
 	msg = (struct igmpmsg *)skb_network_header(skb);
 	msg->im_vif = vifi;
-	skb->dst = dst_clone(pkt->dst);
+	skb_dst_set(skb, dst_clone(skb_dst(pkt)));
 
 	/*
 	 *	Add our header
@@ -1201,7 +1201,7 @@ static void ip_encap(struct sk_buff *skb, __be32 saddr, __be32 daddr)
 	iph->protocol	=	IPPROTO_IPIP;
 	iph->ihl	=	5;
 	iph->tot_len	=	htons(skb->len);
-	ip_select_ident(iph, skb->dst, NULL);
+	ip_select_ident(iph, skb_dst(skb), NULL);
 	ip_send_check(iph);
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
@@ -1212,7 +1212,7 @@ static inline int ipmr_forward_finish(struct sk_buff *skb)
 {
 	struct ip_options * opt	= &(IPCB(skb)->opt);
 
-	IP_INC_STATS_BH(dev_net(skb->dst->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
@@ -1290,8 +1290,8 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 	vif->pkt_out++;
 	vif->bytes_out += skb->len;
 
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 	ip_decrease_ttl(ip_hdr(skb));
 
 	/* FIXME: forward and output firewalls used to be called here.
@@ -1543,8 +1543,7 @@ static int __pim_rcv(struct sk_buff *skb, unsigned int pimlen)
 	skb->protocol = htons(ETH_P_IP);
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
-	dst_release(skb->dst);
-	skb->dst = NULL;
+	skb_dst_drop(skb);
 	reg_dev->stats.rx_bytes += skb->len;
 	reg_dev->stats.rx_packets++;
 	nf_reset(skb);
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index fdf6811..1725dc0 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -12,7 +12,7 @@
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
 int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 {
-	struct net *net = dev_net(skb->dst->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 	struct flowi fl = {};
@@ -41,8 +41,8 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 			return -1;
 
 		/* Drop old route. */
-		dst_release(skb->dst);
-		skb->dst = &rt->u.dst;
+		skb_dst_drop(skb);
+		skb_dst_set(skb, &rt->u.dst);
 	} else {
 		/* non-local src, find valid iif to satisfy
 		 * rp-filter when calling ip_route_input. */
@@ -50,7 +50,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		if (ip_route_output_key(net, &rt, &fl) != 0)
 			return -1;
 
-		odst = skb->dst;
+		odst = skb_dst(skb);
 		if (ip_route_input(skb, iph->daddr, iph->saddr,
 				   RT_TOS(iph->tos), rt->u.dst.dev) != 0) {
 			dst_release(&rt->u.dst);
@@ -60,18 +60,22 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		dst_release(odst);
 	}
 
-	if (skb->dst->error)
+	if (skb_dst(skb)->error)
 		return -1;
 
 #ifdef CONFIG_XFRM
 	if (!(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
-	    xfrm_decode_session(skb, &fl, AF_INET) == 0)
-		if (xfrm_lookup(net, &skb->dst, &fl, skb->sk, 0))
+	    xfrm_decode_session(skb, &fl, AF_INET) == 0) {
+		struct dst_entry *dst = skb_dst(skb);
+		skb_dst_set(skb, NULL);
+		if (xfrm_lookup(net, &dst, &fl, skb->sk, 0))
 			return -1;
+		skb_dst_set(skb, dst);
+	}
 #endif
 
 	/* Change in oif may mean change in hh_len. */
-	hh_len = skb->dst->dev->hard_header_len;
+	hh_len = skb_dst(skb)->dev->hard_header_len;
 	if (skb_headroom(skb) < hh_len &&
 	    pskb_expand_head(skb, hh_len - skb_headroom(skb), 0, GFP_ATOMIC))
 		return -1;
@@ -92,7 +96,7 @@ int ip_xfrm_me_harder(struct sk_buff *skb)
 	if (xfrm_decode_session(skb, &fl, AF_INET) < 0)
 		return -1;
 
-	dst = skb->dst;
+	dst = skb_dst(skb);
 	if (dst->xfrm)
 		dst = ((struct xfrm_dst *)dst)->route;
 	dst_hold(dst);
@@ -100,11 +104,11 @@ int ip_xfrm_me_harder(struct sk_buff *skb)
 	if (xfrm_lookup(dev_net(dst->dev), &dst, &fl, skb->sk, 0) < 0)
 		return -1;
 
-	dst_release(skb->dst);
-	skb->dst = dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst);
 
 	/* Change in oif may mean change in hh_len. */
-	hh_len = skb->dst->dev->hard_header_len;
+	hh_len = skb_dst(skb)->dev->hard_header_len;
 	if (skb_headroom(skb) < hh_len &&
 	    pskb_expand_head(skb, hh_len - skb_headroom(skb), 0, GFP_ATOMIC))
 		return -1;
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 0b4b6e0..c93ae44 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -108,17 +108,16 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 		addr_type = RTN_LOCAL;
 
 	/* ip_route_me_harder expects skb->dst to be set */
-	dst_hold(oldskb->dst);
-	nskb->dst = oldskb->dst;
+	skb_dst_set(nskb, dst_clone(skb_dst(oldskb)));
 
 	if (ip_route_me_harder(nskb, addr_type))
 		goto free_nskb;
 
-	niph->ttl	= dst_metric(nskb->dst, RTAX_HOPLIMIT);
+	niph->ttl	= dst_metric(skb_dst(nskb), RTAX_HOPLIMIT);
 	nskb->ip_summed = CHECKSUM_NONE;
 
 	/* "Never happens" */
-	if (nskb->len > dst_mtu(nskb->dst))
+	if (nskb->len > dst_mtu(skb_dst(nskb)))
 		goto free_nskb;
 
 	nf_ct_attach(nskb, oldskb);
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index b7dd695..5567bd0 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -167,10 +167,9 @@ nf_nat_in(unsigned int hooknum,
 
 	ret = nf_nat_fn(hooknum, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
-	    daddr != ip_hdr(skb)->daddr) {
-		dst_release(skb->dst);
-		skb->dst = NULL;
-	}
+	    daddr != ip_hdr(skb)->daddr)
+		skb_dst_drop(skb);
+
 	return ret;
 }
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index f774651..3dc9171 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -343,7 +343,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
-	skb->dst = dst_clone(&rt->u.dst);
+	skb_dst_set(skb, dst_clone(&rt->u.dst));
 
 	skb_reset_network_header(skb);
 	iph = ip_hdr(skb);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f20060a..a849bb1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1118,7 +1118,7 @@ restart:
 			if (rp)
 				*rp = rth;
 			else
-				skb->dst = &rth->u.dst;
+				skb_dst_set(skb, &rth->u.dst);
 			return 0;
 		}
 
@@ -1217,7 +1217,7 @@ restart:
 	if (rp)
 		*rp = rt;
 	else
-		skb->dst = &rt->u.dst;
+		skb_dst_set(skb, &rt->u.dst);
 	return 0;
 }
 
@@ -2251,7 +2251,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			dst_use(&rth->u.dst, jiffies);
 			RT_CACHE_STAT_INC(in_hit);
 			rcu_read_unlock();
-			skb->dst = &rth->u.dst;
+			skb_dst_set(skb, &rth->u.dst);
 			return 0;
 		}
 		RT_CACHE_STAT_INC(in_hlist_search);
@@ -2934,7 +2934,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	if (err)
 		goto errout_free;
 
-	skb->dst = &rt->u.dst;
+	skb_dst_set(skb, &rt->u.dst);
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
@@ -2975,15 +2975,15 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 				continue;
 			if (rt_is_expired(rt))
 				continue;
-			skb->dst = dst_clone(&rt->u.dst);
+			skb_dst_set(skb, dst_clone(&rt->u.dst));
 			if (rt_fill_info(net, skb, NETLINK_CB(cb->skb).pid,
 					 cb->nlh->nlmsg_seq, RTM_NEWROUTE,
 					 1, NLM_F_MULTI) <= 0) {
-				dst_release(xchg(&skb->dst, NULL));
+				skb_dst_drop(skb);
 				rcu_read_unlock_bh();
 				goto done;
 			}
-			dst_release(xchg(&skb->dst, NULL));
+			skb_dst_drop(skb);
 		}
 		rcu_read_unlock_bh();
 	}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 319c885..5a1ca26 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -590,7 +590,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
 
-	net = dev_net(skb->dst->dev);
+	net = dev_net(skb_dst(skb)->dev);
 	ip_send_reply(net->ipv4.tcp_sock, skb,
 		      &arg, arg.iov[0].iov_len);
 
@@ -617,7 +617,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			];
 	} rep;
 	struct ip_reply_arg arg;
-	struct net *net = dev_net(skb->dst->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	memset(&rep.th, 0, sizeof(struct tcphdr));
 	memset(&arg, 0, sizeof(arg));
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 79c39dc..416fc4c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2202,7 +2202,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	/* Reserve space for headers. */
 	skb_reserve(skb, MAX_TCP_HEADER);
 
-	skb->dst = dst_clone(dst);
+	skb_dst_set(skb, dst_clone(dst));
 
 	mss = dst_metric(dst, RTAX_ADVMSS);
 	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < mss)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7a1d1ce..8f4158d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -328,7 +328,7 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 	if (unlikely(sk = skb_steal_sock(skb)))
 		return sk;
 	else
-		return __udp4_lib_lookup(dev_net(skb->dst->dev), iph->saddr, sport,
+		return __udp4_lib_lookup(dev_net(skb_dst(skb)->dev), iph->saddr, sport,
 					 iph->daddr, dport, inet_iif(skb),
 					 udptable);
 }
@@ -1237,7 +1237,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	struct sock *sk;
 	struct udphdr *uh;
 	unsigned short ulen;
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = skb_rtable(skb);
 	__be32 saddr, daddr;
 	struct net *net = dev_net(skb->dev);
 
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 4ec2162..f9f922a 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -23,7 +23,7 @@ int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 
 static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
 {
-	if (skb->dst == NULL) {
+	if (skb_dst(skb) == NULL) {
 		const struct iphdr *iph = ip_hdr(skb);
 
 		if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 7135279..3444f3b 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -28,7 +28,7 @@ static inline void ipip_ecn_decapsulate(struct sk_buff *skb)
  */
 static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct iphdr *top_iph;
 	int flags;
 
@@ -41,7 +41,7 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	top_iph->ihl = 5;
 	top_iph->version = 4;
 
-	top_iph->protocol = xfrm_af2proto(skb->dst->ops->family);
+	top_iph->protocol = xfrm_af2proto(skb_dst(skb)->ops->family);
 
 	/* DS disclosed */
 	top_iph->tos = INET_ECN_encapsulate(XFRM_MODE_SKB_CB(skb)->tos,
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 8c3180a..c908bd9 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -29,7 +29,7 @@ static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 	if (!(ip_hdr(skb)->frag_off & htons(IP_DF)) || skb->local_df)
 		goto out;
 
-	dst = skb->dst;
+	dst = skb_dst(skb);
 	mtu = dst_mtu(dst);
 	if (skb->len > mtu) {
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
@@ -72,7 +72,7 @@ EXPORT_SYMBOL(xfrm4_prepare_output);
 static int xfrm4_output_finish(struct sk_buff *skb)
 {
 #ifdef CONFIG_NETFILTER
-	if (!skb->dst->xfrm) {
+	if (!skb_dst(skb)->xfrm) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
 		return dst_output(skb);
 	}
@@ -87,6 +87,6 @@ static int xfrm4_output_finish(struct sk_buff *skb)
 int xfrm4_output(struct sk_buff *skb)
 {
 	return NF_HOOK_COND(PF_INET, NF_INET_POST_ROUTING, skb,
-			    NULL, skb->dst->dev, xfrm4_output_finish,
+			    NULL, skb_dst(skb)->dev, xfrm4_output_finish,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 1c7f400..4aae658 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -277,7 +277,7 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
-		IP6_INC_STATS_BH(dev_net(skb->dst->dev), ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(skb)),
 				 IPSTATS_MIB_INHDRERRORS);
 		kfree_skb(skb);
 		return -1;
@@ -288,7 +288,7 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 	dstbuf = opt->dst1;
 #endif
 
-	dst = dst_clone(skb->dst);
+	dst = dst_clone(skb_dst(skb));
 	if (ip6_parse_tlv(tlvprocdestopt_lst, skb)) {
 		dst_release(dst);
 		skb->transport_header += (skb_transport_header(skb)[1] + 1) << 3;
@@ -333,7 +333,7 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 				 IPSTATS_MIB_INHDRERRORS);
 		kfree_skb(skb);
 		return -1;
@@ -343,7 +343,7 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr) ||
 	    skb->pkt_type != PACKET_HOST) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 				 IPSTATS_MIB_INADDRERRORS);
 		kfree_skb(skb);
 		return -1;
@@ -358,7 +358,7 @@ looped_back:
 			 * processed by own
 			 */
 			if (!addr) {
-				IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+				IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 						 IPSTATS_MIB_INADDRERRORS);
 				kfree_skb(skb);
 				return -1;
@@ -384,7 +384,7 @@ looped_back:
 			goto unknown_rh;
 		/* Silently discard invalid RTH type 2 */
 		if (hdr->hdrlen != 2 || hdr->segments_left != 1) {
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 					 IPSTATS_MIB_INHDRERRORS);
 			kfree_skb(skb);
 			return -1;
@@ -403,7 +403,7 @@ looped_back:
 	n = hdr->hdrlen >> 1;
 
 	if (hdr->segments_left > n) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 				 IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 				  ((&hdr->segments_left) -
@@ -417,7 +417,7 @@ looped_back:
 	if (skb_cloned(skb)) {
 		/* the copy is a forwarded packet */
 		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 					 IPSTATS_MIB_OUTDISCARDS);
 			kfree_skb(skb);
 			return -1;
@@ -440,13 +440,13 @@ looped_back:
 		if (xfrm6_input_addr(skb, (xfrm_address_t *)addr,
 				     (xfrm_address_t *)&ipv6_hdr(skb)->saddr,
 				     IPPROTO_ROUTING) < 0) {
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 					 IPSTATS_MIB_INADDRERRORS);
 			kfree_skb(skb);
 			return -1;
 		}
-		if (!ipv6_chk_home_addr(dev_net(skb->dst->dev), addr)) {
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+		if (!ipv6_chk_home_addr(dev_net(skb_dst(skb)->dev), addr)) {
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 					 IPSTATS_MIB_INADDRERRORS);
 			kfree_skb(skb);
 			return -1;
@@ -458,7 +458,7 @@ looped_back:
 	}
 
 	if (ipv6_addr_is_multicast(addr)) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 				 IPSTATS_MIB_INADDRERRORS);
 		kfree_skb(skb);
 		return -1;
@@ -468,17 +468,17 @@ looped_back:
 	ipv6_addr_copy(addr, &ipv6_hdr(skb)->daddr);
 	ipv6_addr_copy(&ipv6_hdr(skb)->daddr, &daddr);
 
-	dst_release(xchg(&skb->dst, NULL));
+	skb_dst_drop(skb);
 	ip6_route_input(skb);
-	if (skb->dst->error) {
+	if (skb_dst(skb)->error) {
 		skb_push(skb, skb->data - skb_network_header(skb));
 		dst_input(skb);
 		return -1;
 	}
 
-	if (skb->dst->dev->flags&IFF_LOOPBACK) {
+	if (skb_dst(skb)->dev->flags&IFF_LOOPBACK) {
 		if (ipv6_hdr(skb)->hop_limit <= 1) {
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 					 IPSTATS_MIB_INHDRERRORS);
 			icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
 				    0, skb->dev);
@@ -494,7 +494,7 @@ looped_back:
 	return -1;
 
 unknown_rh:
-	IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
+	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_INHDRERRORS);
 	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 			  (&hdr->type) - skb_network_header(skb));
 	return -1;
@@ -552,11 +552,11 @@ void ipv6_exthdrs_exit(void)
  **********************************/
 
 /*
- * Note: we cannot rely on skb->dst before we assign it in ip6_route_input().
+ * Note: we cannot rely on skb_dst(skb) before we assign it in ip6_route_input().
  */
 static inline struct inet6_dev *ipv6_skb_idev(struct sk_buff *skb)
 {
-	return skb->dst ? ip6_dst_idev(skb->dst) : __in6_dev_get(skb->dev);
+	return skb_dst(skb) ? ip6_dst_idev(skb_dst(skb)) : __in6_dev_get(skb->dev);
 }
 
 /* Router Alert as of RFC 2711 */
@@ -581,7 +581,7 @@ static int ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
 {
 	const unsigned char *nh = skb_network_header(skb);
 	u32 pkt_len;
-	struct net *net = dev_net(skb->dst->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	if (nh[optoff + 1] != 4 || (optoff & 3) != 2) {
 		LIMIT_NETDEBUG(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n",
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 3c3732d..cc4797d 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -228,7 +228,7 @@ int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
 		__inet6_csk_dst_store(sk, dst, NULL, NULL);
 	}
 
-	skb->dst = dst_clone(dst);
+	skb_dst_set(skb, dst_clone(dst));
 
 	/* Restore final destination back after routing done */
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index bc1a920..c3a07d7 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -48,7 +48,7 @@
 
 inline int ip6_rcv_finish( struct sk_buff *skb)
 {
-	if (skb->dst == NULL)
+	if (skb_dst(skb) == NULL)
 		ip6_route_input(skb);
 
 	return dst_input(skb);
@@ -91,7 +91,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	 * arrived via the sending interface (ethX), because of the
 	 * nature of scoping architecture. --yoshfuji
 	 */
-	IP6CB(skb)->iif = skb->dst ? ip6_dst_idev(skb->dst)->dev->ifindex : dev->ifindex;
+	IP6CB(skb)->iif = skb_dst(skb) ? ip6_dst_idev(skb_dst(skb))->dev->ifindex : dev->ifindex;
 
 	if (unlikely(!pskb_may_pull(skb, sizeof(*hdr))))
 		goto err;
@@ -161,7 +161,7 @@ static int ip6_input_finish(struct sk_buff *skb)
 	int nexthdr, raw;
 	u8 hash;
 	struct inet6_dev *idev;
-	struct net *net = dev_net(skb->dst->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	/*
 	 *	Parse extension headers
@@ -169,7 +169,7 @@ static int ip6_input_finish(struct sk_buff *skb)
 
 	rcu_read_lock();
 resubmit:
-	idev = ip6_dst_idev(skb->dst);
+	idev = ip6_dst_idev(skb_dst(skb));
 	if (!pskb_pull(skb, skb_transport_offset(skb)))
 		goto discard;
 	nhoff = IP6CB(skb)->nhoff;
@@ -242,8 +242,8 @@ int ip6_mc_input(struct sk_buff *skb)
 	struct ipv6hdr *hdr;
 	int deliver;
 
-	IP6_UPD_PO_STATS_BH(dev_net(skb->dst->dev),
-			 ip6_dst_idev(skb->dst), IPSTATS_MIB_INMCAST,
+	IP6_UPD_PO_STATS_BH(dev_net(skb_dst(skb)->dev),
+			 ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_INMCAST,
 			 skb->len);
 
 	hdr = ipv6_hdr(skb);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 735a2bf..c8dc8e5 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -78,7 +78,7 @@ int __ip6_local_out(struct sk_buff *skb)
 		len = 0;
 	ipv6_hdr(skb)->payload_len = htons(len);
 
-	return nf_hook(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, skb->dst->dev,
+	return nf_hook(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
 		       dst_output);
 }
 
@@ -96,7 +96,7 @@ EXPORT_SYMBOL_GPL(ip6_local_out);
 
 static int ip6_output_finish(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 
 	if (dst->hh)
 		return neigh_hh_output(dst->hh, skb);
@@ -117,7 +117,7 @@ static int ip6_dev_loopback_xmit(struct sk_buff *newskb)
 	__skb_pull(newskb, skb_network_offset(newskb));
 	newskb->pkt_type = PACKET_LOOPBACK;
 	newskb->ip_summed = CHECKSUM_UNNECESSARY;
-	WARN_ON(!newskb->dst);
+	WARN_ON(!skb_dst(newskb));
 
 	netif_rx(newskb);
 	return 0;
@@ -126,7 +126,7 @@ static int ip6_dev_loopback_xmit(struct sk_buff *newskb)
 
 static int ip6_output2(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *dev = dst->dev;
 
 	skb->protocol = htons(ETH_P_IPV6);
@@ -134,7 +134,7 @@ static int ip6_output2(struct sk_buff *skb)
 
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr)) {
 		struct ipv6_pinfo* np = skb->sk ? inet6_sk(skb->sk) : NULL;
-		struct inet6_dev *idev = ip6_dst_idev(skb->dst);
+		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
 		if (!(dev->flags & IFF_LOOPBACK) && (!np || np->mc_loop) &&
 		    ((mroute6_socket(dev_net(dev)) &&
@@ -172,21 +172,21 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
 
 	return (np && np->pmtudisc == IPV6_PMTUDISC_PROBE) ?
-	       skb->dst->dev->mtu : dst_mtu(skb->dst);
+	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
 }
 
 int ip6_output(struct sk_buff *skb)
 {
-	struct inet6_dev *idev = ip6_dst_idev(skb->dst);
+	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 	if (unlikely(idev->cnf.disable_ipv6)) {
-		IP6_INC_STATS(dev_net(skb->dst->dev), idev,
+		IP6_INC_STATS(dev_net(skb_dst(skb)->dev), idev,
 			      IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
 		return 0;
 	}
 
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
-				dst_allfrag(skb->dst))
+				dst_allfrag(skb_dst(skb)))
 		return ip6_fragment(skb, ip6_output2);
 	else
 		return ip6_output2(skb);
@@ -202,7 +202,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	struct net *net = sock_net(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_addr *first_hop = &fl->fl6_dst;
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct ipv6hdr *hdr;
 	u8  proto = fl->proto;
 	int seg_len = skb->len;
@@ -222,7 +222,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 		if (skb_headroom(skb) < head_room) {
 			struct sk_buff *skb2 = skb_realloc_headroom(skb, head_room);
 			if (skb2 == NULL) {
-				IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
+				IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 					      IPSTATS_MIB_OUTDISCARDS);
 				kfree_skb(skb);
 				return -ENOBUFS;
@@ -276,7 +276,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 
 	mtu = dst_mtu(dst);
 	if ((skb->len <= mtu) || skb->local_df || skb_is_gso(skb)) {
-		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb->dst),
+		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_OUT, skb->len);
 		return NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 				dst_output);
@@ -286,7 +286,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 		printk(KERN_DEBUG "IPv6: sending pkt_too_big to self\n");
 	skb->dev = dst->dev;
 	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
-	IP6_INC_STATS(net, ip6_dst_idev(skb->dst), IPSTATS_MIB_FRAGFAILS);
+	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_FRAGFAILS);
 	kfree_skb(skb);
 	return -EMSGSIZE;
 }
@@ -416,7 +416,7 @@ static inline int ip6_forward_finish(struct sk_buff *skb)
 
 int ip6_forward(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct inet6_skb_parm *opt = IP6CB(skb);
 	struct net *net = dev_net(dst->dev);
@@ -485,7 +485,7 @@ int ip6_forward(struct sk_buff *skb)
 		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
-	dst = skb->dst;
+	dst = skb_dst(skb);
 
 	/* IPv6 specs say nothing about it, but it is clear that we cannot
 	   send redirects to source routed frames.
@@ -566,8 +566,8 @@ static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	to->pkt_type = from->pkt_type;
 	to->priority = from->priority;
 	to->protocol = from->protocol;
-	dst_release(to->dst);
-	to->dst = dst_clone(from->dst);
+	skb_dst_drop(to);
+	skb_dst_set(to, dst_clone(skb_dst(from)));
 	to->dev = from->dev;
 	to->mark = from->mark;
 
@@ -624,7 +624,7 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
 	struct sk_buff *frag;
-	struct rt6_info *rt = (struct rt6_info*)skb->dst;
+	struct rt6_info *rt = (struct rt6_info*)skb_dst(skb);
 	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
 	struct ipv6hdr *tmp_hdr;
 	struct frag_hdr *fh;
@@ -632,7 +632,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	__be32 frag_id = 0;
 	int ptr, offset = 0, err=0;
 	u8 *prevhdr, nexthdr = 0;
-	struct net *net = dev_net(skb->dst->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	hlen = ip6_find_1stfragopt(skb, &prevhdr);
 	nexthdr = *prevhdr;
@@ -644,9 +644,9 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	 * check should be redundant, but it's free.)
 	 */
 	if (!skb->local_df) {
-		skb->dev = skb->dst->dev;
+		skb->dev = skb_dst(skb)->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
-		IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
+		IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_FRAGFAILS);
 		kfree_skb(skb);
 		return -EMSGSIZE;
@@ -696,7 +696,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		*prevhdr = NEXTHDR_FRAGMENT;
 		tmp_hdr = kmemdup(skb_network_header(skb), hlen, GFP_ATOMIC);
 		if (!tmp_hdr) {
-			IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
+			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 				      IPSTATS_MIB_FRAGFAILS);
 			return -ENOMEM;
 		}
@@ -809,7 +809,7 @@ slow_path:
 
 		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_ALLOCATED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
 			NETDEBUG(KERN_INFO "IPv6: frag: no memory for new fragment!\n");
-			IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
+			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 				      IPSTATS_MIB_FRAGFAILS);
 			err = -ENOMEM;
 			goto fail;
@@ -873,16 +873,16 @@ slow_path:
 		if (err)
 			goto fail;
 
-		IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
+		IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_FRAGCREATES);
 	}
-	IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
+	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 		      IPSTATS_MIB_FRAGOKS);
 	kfree_skb(skb);
 	return err;
 
 fail:
-	IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
+	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 		      IPSTATS_MIB_FRAGFAILS);
 	kfree_skb(skb);
 	return err;
@@ -1516,10 +1516,10 @@ int ip6_push_pending_frames(struct sock *sk)
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
-	skb->dst = dst_clone(&rt->u.dst);
+	skb_dst_set(skb, dst_clone(&rt->u.dst));
 	IP6_UPD_PO_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
 	if (proto == IPPROTO_ICMPV6) {
-		struct inet6_dev *idev = ip6_dst_idev(skb->dst);
+		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
 		ICMP6MSGOUT_INC_STATS_BH(net, idev, icmp6_hdr(skb)->icmp6_type);
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
@@ -1545,8 +1545,8 @@ void ip6_flush_pending_frames(struct sock *sk)
 	struct sk_buff *skb;
 
 	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
-		if (skb->dst)
-			IP6_INC_STATS(sock_net(sk), ip6_dst_idev(skb->dst),
+		if (skb_dst(skb))
+			IP6_INC_STATS(sock_net(sk), ip6_dst_idev(skb_dst(skb)),
 				      IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
 	}
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index af256d4..404d16a 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -532,8 +532,8 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!skb2)
 		return 0;
 
-	dst_release(skb2->dst);
-	skb2->dst = NULL;
+	skb_dst_drop(skb2);
+
 	skb_pull(skb2, offset);
 	skb_reset_network_header(skb2);
 	eiph = ip_hdr(skb2);
@@ -560,21 +560,21 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			ip_rt_put(rt);
 			goto out;
 		}
-		skb2->dst = (struct dst_entry *)rt;
+		skb_dst_set(skb2, (struct dst_entry *)rt);
 	} else {
 		ip_rt_put(rt);
 		if (ip_route_input(skb2, eiph->daddr, eiph->saddr, eiph->tos,
 				   skb2->dev) ||
-		    skb2->dst->dev->type != ARPHRD_TUNNEL)
+		    skb_dst(skb2)->dev->type != ARPHRD_TUNNEL)
 			goto out;
 	}
 
 	/* change mtu on this route */
 	if (rel_type == ICMP_DEST_UNREACH && rel_code == ICMP_FRAG_NEEDED) {
-		if (rel_info > dst_mtu(skb2->dst))
+		if (rel_info > dst_mtu(skb_dst(skb2)))
 			goto out;
 
-		skb2->dst->ops->update_pmtu(skb2->dst, rel_info);
+		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), rel_info);
 	}
 
 	icmp_send(skb2, rel_type, rel_code, htonl(rel_info));
@@ -606,8 +606,7 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		if (!skb2)
 			return 0;
 
-		dst_release(skb2->dst);
-		skb2->dst = NULL;
+		skb_dst_drop(skb2);
 		skb_pull(skb2, offset);
 		skb_reset_network_header(skb2);
 
@@ -720,8 +719,7 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		skb->pkt_type = PACKET_HOST;
 		memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
 		skb->dev = t->dev;
-		dst_release(skb->dst);
-		skb->dst = NULL;
+		skb_dst_drop(skb);
 		nf_reset(skb);
 
 		dscp_ecn_decapsulate(t, ipv6h, skb);
@@ -885,8 +883,8 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	}
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
-	if (skb->dst)
-		skb->dst->ops->update_pmtu(skb->dst, mtu);
+	if (skb_dst(skb))
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 	if (skb->len > mtu) {
 		*pmtu = mtu;
 		err = -EMSGSIZE;
@@ -910,8 +908,8 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		kfree_skb(skb);
 		skb = new_skb;
 	}
-	dst_release(skb->dst);
-	skb->dst = dst_clone(dst);
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst_clone(dst));
 
 	skb->transport_header = skb->network_header;
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 228be55..a35d8fc 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -398,10 +398,9 @@ static int pim6_rcv(struct sk_buff *skb)
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
-	dst_release(skb->dst);
+	skb_dst_drop(skb);
 	reg_dev->stats.rx_bytes += skb->len;
 	reg_dev->stats.rx_packets++;
-	skb->dst = NULL;
 	nf_reset(skb);
 	netif_rx(skb);
 	dev_put(reg_dev);
@@ -849,7 +848,7 @@ static int ip6mr_cache_report(struct net *net, struct sk_buff *pkt, mifi_t mifi,
 	ipv6_addr_copy(&msg->im6_src, &ipv6_hdr(pkt)->saddr);
 	ipv6_addr_copy(&msg->im6_dst, &ipv6_hdr(pkt)->daddr);
 
-	skb->dst = dst_clone(pkt->dst);
+	skb_dst_set(skb, dst_clone(skb_dst(pkt)));
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
@@ -1487,7 +1486,7 @@ int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg)
 
 static inline int ip6mr_forward2_finish(struct sk_buff *skb)
 {
-	IP6_INC_STATS_BH(dev_net(skb->dst->dev), ip6_dst_idev(skb->dst),
+	IP6_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(skb)),
 			 IPSTATS_MIB_OUTFORWDATAGRAMS);
 	return dst_output(skb);
 }
@@ -1532,8 +1531,8 @@ static int ip6mr_forward2(struct sk_buff *skb, struct mfc6_cache *c, int vifi)
 	if (!dst)
 		goto out_free;
 
-	dst_release(skb->dst);
-	skb->dst = dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst);
 
 	/*
 	 * RFC1584 teaches, that DVMRP/PIM router must deliver packets locally
@@ -1722,7 +1721,7 @@ int ip6mr_get_route(struct net *net,
 {
 	int err;
 	struct mfc6_cache *cache;
-	struct rt6_info *rt = (struct rt6_info *)skb->dst;
+	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
 
 	read_lock(&mrt_lock);
 	cache = ip6mr_cache_find(net, &rt->rt6i_src.addr, &rt->rt6i_dst.addr);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 4b48819..4b264ed 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1448,6 +1448,7 @@ static void mld_sendpack(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	int err;
 	struct flowi fl;
+	struct dst_entry *dst;
 
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 
@@ -1459,9 +1460,9 @@ static void mld_sendpack(struct sk_buff *skb)
 		IPPROTO_ICMPV6, csum_partial(skb_transport_header(skb),
 					     mldlen, 0));
 
-	skb->dst = icmp6_dst_alloc(skb->dev, NULL, &ipv6_hdr(skb)->daddr);
+	dst = icmp6_dst_alloc(skb->dev, NULL, &ipv6_hdr(skb)->daddr);
 
-	if (!skb->dst) {
+	if (!dst) {
 		err = -ENOMEM;
 		goto err_out;
 	}
@@ -1470,7 +1471,8 @@ static void mld_sendpack(struct sk_buff *skb)
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
 
-	err = xfrm_lookup(net, &skb->dst, &fl, NULL, 0);
+	err = xfrm_lookup(net, &dst, &fl, NULL, 0);
+	skb_dst_set(skb, dst);
 	if (err)
 		goto err_out;
 
@@ -1775,6 +1777,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 		     IPV6_TLV_ROUTERALERT, 2, 0, 0,
 		     IPV6_TLV_PADN, 0 };
 	struct flowi fl;
+	struct dst_entry *dst;
 
 	if (type == ICMPV6_MGM_REDUCTION)
 		snd_addr = &in6addr_linklocal_allrouters;
@@ -1828,8 +1831,8 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
 	idev = in6_dev_get(skb->dev);
 
-	skb->dst = icmp6_dst_alloc(skb->dev, NULL, &ipv6_hdr(skb)->daddr);
-	if (!skb->dst) {
+	dst = icmp6_dst_alloc(skb->dev, NULL, &ipv6_hdr(skb)->daddr);
+	if (!dst) {
 		err = -ENOMEM;
 		goto err_out;
 	}
@@ -1838,11 +1841,11 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
 
-	err = xfrm_lookup(net, &skb->dst, &fl, NULL, 0);
+	err = xfrm_lookup(net, &dst, &fl, NULL, 0);
 	if (err)
 		goto err_out;
 
-
+	skb_dst_set(skb, dst);
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
 		      dst_output);
 out:
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 1d13d99..9eb68e9 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -530,7 +530,7 @@ void ndisc_send_skb(struct sk_buff *skb,
 		return;
 	}
 
-	skb->dst = dst;
+	skb_dst_set(skb, dst);
 
 	idev = in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
@@ -1612,7 +1612,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 					     len, IPPROTO_ICMPV6,
 					     csum_partial(icmph, len, 0));
 
-	buff->dst = dst;
+	skb_dst_set(buff, dst);
 	idev = in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 834cea6..d5ed92b 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -12,7 +12,7 @@
 
 int ip6_route_me_harder(struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb->dst->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct dst_entry *dst;
 	struct flowi fl = {
@@ -28,9 +28,15 @@ int ip6_route_me_harder(struct sk_buff *skb)
 
 #ifdef CONFIG_XFRM
 	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
-	    xfrm_decode_session(skb, &fl, AF_INET6) == 0)
-		if (xfrm_lookup(net, &skb->dst, &fl, skb->sk, 0))
+	    xfrm_decode_session(skb, &fl, AF_INET6) == 0) {
+		struct dst_entry *dst2 = skb_dst(skb);
+
+		if (xfrm_lookup(net, &dst2, &fl, skb->sk, 0)) {
+			skb_dst_set(skb, NULL);
 			return -1;
+		}
+		skb_dst_set(skb, dst2);
+	}
 #endif
 
 	if (dst->error) {
@@ -41,9 +47,9 @@ int ip6_route_me_harder(struct sk_buff *skb)
 	}
 
 	/* Drop old route. */
-	dst_release(skb->dst);
+	skb_dst_drop(skb);
 
-	skb->dst = dst;
+	skb_dst_set(skb, dst);
 	return 0;
 }
 EXPORT_SYMBOL(ip6_route_me_harder);
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 5a2d0a4..5a7f00c 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -112,7 +112,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 		return;
 	}
 
-	nskb->dst = dst;
+	skb_dst_set(nskb, dst);
 
 	skb_reserve(nskb, hh_len + dst->header_len);
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index e99307f..36a090d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -625,7 +625,7 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
-	skb->dst = dst_clone(&rt->u.dst);
+	skb_dst_set(skb, dst_clone(&rt->u.dst));
 
 	skb_put(skb, length);
 	skb_reset_network_header(skb);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e9ac7a1..54a387d 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -267,7 +267,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	struct sk_buff *prev, *next;
 	struct net_device *dev;
 	int offset, end;
-	struct net *net = dev_net(skb->dst->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	if (fq->q.last_in & INET_FRAG_COMPLETE)
 		goto err;
@@ -277,7 +277,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 			((u8 *)(fhdr + 1) - (u8 *)(ipv6_hdr(skb) + 1)));
 
 	if ((unsigned int)end > IPV6_MAXPLEN) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 				 IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 				  ((u8 *)&fhdr->frag_off -
@@ -310,7 +310,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 			/* RFC2460 says always send parameter problem in
 			 * this case. -DaveM
 			 */
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 					 IPSTATS_MIB_INHDRERRORS);
 			icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 					  offsetof(struct ipv6hdr, payload_len));
@@ -434,7 +434,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	return -1;
 
 err:
-	IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
+	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 		      IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -1;
@@ -576,9 +576,9 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	struct frag_hdr *fhdr;
 	struct frag_queue *fq;
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
-	struct net *net = dev_net(skb->dst->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
 
-	IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMREQDS);
+	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMREQDS);
 
 	/* Jumbo payload inhibits frag. header */
 	if (hdr->payload_len==0)
@@ -595,17 +595,17 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		/* It is not a fragmented frame */
 		skb->transport_header += sizeof(struct frag_hdr);
 		IP6_INC_STATS_BH(net,
-				 ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMOKS);
+				 ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMOKS);
 
 		IP6CB(skb)->nhoff = (u8 *)fhdr - skb_network_header(skb);
 		return 1;
 	}
 
 	if (atomic_read(&net->ipv6.frags.mem) > net->ipv6.frags.high_thresh)
-		ip6_evictor(net, ip6_dst_idev(skb->dst));
+		ip6_evictor(net, ip6_dst_idev(skb_dst(skb)));
 
 	if ((fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr,
-			  ip6_dst_idev(skb->dst))) != NULL) {
+			  ip6_dst_idev(skb_dst(skb)))) != NULL) {
 		int ret;
 
 		spin_lock(&fq->q.lock);
@@ -617,12 +617,12 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		return ret;
 	}
 
-	IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMFAILS);
+	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -1;
 
 fail_hdr:
-	IP6_INC_STATS(net, ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
+	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_INHDRERRORS);
 	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb_network_header_len(skb));
 	return -1;
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 032a5ec..658293e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -800,7 +800,7 @@ void ip6_route_input(struct sk_buff *skb)
 	if (rt6_need_strict(&iph->daddr) && skb->dev->type != ARPHRD_PIMREG)
 		flags |= RT6_LOOKUP_F_IFACE;
 
-	skb->dst = fib6_rule_lookup(net, &fl, flags, ip6_pol_route_input);
+	skb_dst_set(skb, fib6_rule_lookup(net, &fl, flags, ip6_pol_route_input));
 }
 
 static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
@@ -911,7 +911,7 @@ static void ip6_link_failure(struct sk_buff *skb)
 
 	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0, skb->dev);
 
-	rt = (struct rt6_info *) skb->dst;
+	rt = (struct rt6_info *) skb_dst(skb);
 	if (rt) {
 		if (rt->rt6i_flags&RTF_CACHE) {
 			dst_set_expires(&rt->u.dst, 0);
@@ -1868,7 +1868,7 @@ int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 static int ip6_pkt_drop(struct sk_buff *skb, int code, int ipstats_mib_noroutes)
 {
 	int type;
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	switch (ipstats_mib_noroutes) {
 	case IPSTATS_MIB_INNOROUTES:
 		type = ipv6_addr_type(&ipv6_hdr(skb)->daddr);
@@ -1895,7 +1895,7 @@ static int ip6_pkt_discard(struct sk_buff *skb)
 
 static int ip6_pkt_discard_out(struct sk_buff *skb)
 {
-	skb->dev = skb->dst->dev;
+	skb->dev = skb_dst(skb)->dev;
 	return ip6_pkt_drop(skb, ICMPV6_NOROUTE, IPSTATS_MIB_OUTNOROUTES);
 }
 
@@ -1908,7 +1908,7 @@ static int ip6_pkt_prohibit(struct sk_buff *skb)
 
 static int ip6_pkt_prohibit_out(struct sk_buff *skb)
 {
-	skb->dev = skb->dst->dev;
+	skb->dev = skb_dst(skb)->dev;
 	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED, IPSTATS_MIB_OUTNOROUTES);
 }
 
@@ -2366,7 +2366,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
 
 	rt = (struct rt6_info*) ip6_route_output(net, NULL, &fl);
-	skb->dst = &rt->u.dst;
+	skb_dst_set(skb, &rt->u.dst);
 
 	err = rt6_fill_node(net, skb, rt, &fl.fl6_dst, &fl.fl6_src, iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b3a59bd..68e5230 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -575,8 +575,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 		tunnel->dev->stats.rx_packets++;
 		tunnel->dev->stats.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
-		dst_release(skb->dst);
-		skb->dst = NULL;
+		skb_dst_drop(skb);
 		nf_reset(skb);
 		ipip6_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
@@ -638,8 +637,8 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (dev->priv_flags & IFF_ISATAP) {
 		struct neighbour *neigh = NULL;
 
-		if (skb->dst)
-			neigh = skb->dst->neighbour;
+		if (skb_dst(skb))
+			neigh = skb_dst(skb)->neighbour;
 
 		if (neigh == NULL) {
 			if (net_ratelimit())
@@ -663,8 +662,8 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!dst) {
 		struct neighbour *neigh = NULL;
 
-		if (skb->dst)
-			neigh = skb->dst->neighbour;
+		if (skb_dst(skb))
+			neigh = skb_dst(skb)->neighbour;
 
 		if (neigh == NULL) {
 			if (net_ratelimit())
@@ -714,7 +713,7 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (tiph->frag_off)
 		mtu = dst_mtu(&rt->u.dst) - sizeof(struct iphdr);
 	else
-		mtu = skb->dst ? dst_mtu(skb->dst) : dev->mtu;
+		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
 
 	if (mtu < 68) {
 		stats->collisions++;
@@ -723,8 +722,8 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
-	if (tunnel->parms.iph.daddr && skb->dst)
-		skb->dst->ops->update_pmtu(skb->dst, mtu);
+	if (tunnel->parms.iph.daddr && skb_dst(skb))
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 
 	if (skb->len > mtu) {
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
@@ -768,8 +767,8 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_reset_network_header(skb);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags = 0;
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	/*
 	 *	Push down and install the IPIP header.
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ea37741..53b6a41 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -981,9 +981,10 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
 	struct flowi fl;
-	struct net *net = dev_net(skb->dst->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct sock *ctl_sk = net->ipv6.tcp_sk;
 	unsigned int tot_len = sizeof(struct tcphdr);
+	struct dst_entry *dst;
 	__be32 *topt;
 
 	if (ts)
@@ -1052,8 +1053,9 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	 * Underlying function will use this to retrieve the network
 	 * namespace
 	 */
-	if (!ip6_dst_lookup(ctl_sk, &buff->dst, &fl)) {
-		if (xfrm_lookup(net, &buff->dst, &fl, NULL, 0) >= 0) {
+	if (!ip6_dst_lookup(ctl_sk, &dst, &fl)) {
+		if (xfrm_lookup(net, &dst, &fl, NULL, 0) >= 0) {
+			skb_dst_set(buff, dst);
 			ip6_xmit(ctl_sk, buff, &fl, NULL, 0);
 			TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 			if (rst)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8905712..fc333d8 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -177,10 +177,9 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 
 	if (unlikely(sk = skb_steal_sock(skb)))
 		return sk;
-	else
-		return __udp6_lib_lookup(dev_net(skb->dst->dev), &iph->saddr, sport,
-					 &iph->daddr, dport, inet6_iif(skb),
-					 udptable);
+	return __udp6_lib_lookup(dev_net(skb_dst(skb)->dev), &iph->saddr, sport,
+				 &iph->daddr, dport, inet6_iif(skb),
+				 udptable);
 }
 
 /*
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index e20529b..3927832 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -31,7 +31,7 @@ static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
  */
 static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct ipv6hdr *top_iph;
 	int dsfield;
 
@@ -45,7 +45,7 @@ static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	memcpy(top_iph->flow_lbl, XFRM_MODE_SKB_CB(skb)->flow_lbl,
 	       sizeof(top_iph->flow_lbl));
-	top_iph->nexthdr = xfrm_af2proto(skb->dst->ops->family);
+	top_iph->nexthdr = xfrm_af2proto(skb_dst(skb)->ops->family);
 
 	dsfield = XFRM_MODE_SKB_CB(skb)->tos;
 	dsfield = INET_ECN_encapsulate(dsfield, dsfield);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 5ee5a03..c4f4eef 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -30,7 +30,7 @@ EXPORT_SYMBOL(xfrm6_find_1stfragopt);
 static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 {
 	int mtu, ret = 0;
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 
 	mtu = dst_mtu(dst);
 	if (mtu < IPV6_MIN_MTU)
@@ -90,6 +90,6 @@ static int xfrm6_output_finish(struct sk_buff *skb)
 
 int xfrm6_output(struct sk_buff *skb)
 {
-	return NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, skb, NULL, skb->dst->dev,
+	return NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, skb, NULL, skb_dst(skb)->dev,
 		       xfrm6_output_finish);
 }
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 425ab14..5874657 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -260,8 +260,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	ip_send_check(ip_hdr(skb));
 
 	/* drop old route */
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -324,8 +324,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	/* drop old route */
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -388,8 +388,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 
 	/* drop old route */
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	/* mangle the packet */
 	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
@@ -465,8 +465,8 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 
 	/* drop old route */
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	/* mangle the packet */
 	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
@@ -553,8 +553,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG_RL("ip_vs_tunnel_xmit(): mtu less than 68\n");
 		goto tx_error;
 	}
-	if (skb->dst)
-		skb->dst->ops->update_pmtu(skb->dst, mtu);
+	if (skb_dst(skb))
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 
 	df |= (old_iph->frag_off & htons(IP_DF));
 
@@ -596,8 +596,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 
 	/* drop old route */
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	/*
 	 *	Push down and install the IPIP header.
@@ -665,8 +665,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG_RL("ip_vs_tunnel_xmit_v6(): mtu less than 1280\n");
 		goto tx_error;
 	}
-	if (skb->dst)
-		skb->dst->ops->update_pmtu(skb->dst, mtu);
+	if (skb_dst(skb))
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 
 	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)) {
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
@@ -702,8 +702,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 
 	/* drop old route */
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	/*
 	 *	Push down and install the IPIP header.
@@ -775,8 +775,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	ip_send_check(ip_hdr(skb));
 
 	/* drop old route */
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -828,8 +828,8 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	/* drop old route */
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
@@ -900,8 +900,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 
 	/* drop the old route when skb is not shared */
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	ip_vs_nat_icmp(skb, pp, cp, 0);
 
@@ -975,8 +975,8 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 
 	/* drop the old route when skb is not shared */
-	dst_release(skb->dst);
-	skb->dst = &rt->u.dst;
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
 
 	ip_vs_nat_icmp_v6(skb, pp, cp, 0);
 
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 117b801..a6d6ec3 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -176,7 +176,7 @@ static bool gre_invert_tuple(struct nf_conntrack_tuple *tuple,
 static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 			     struct nf_conntrack_tuple *tuple)
 {
-	struct net *net = dev_net(skb->dev ? skb->dev : skb->dst->dev);
+	struct net *net = dev_net(skb->dev ? skb->dev : skb_dst(skb)->dev);
 	const struct gre_hdr_pptp *pgrehdr;
 	struct gre_hdr_pptp _pgrehdr;
 	__be16 srckey;
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 4f3b1f8..eda64c1 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -73,11 +73,11 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	}
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
-		if (dst_mtu(skb->dst) <= minlen) {
+		if (dst_mtu(skb_dst(skb)) <= minlen) {
 			if (net_ratelimit())
 				printk(KERN_ERR "xt_TCPMSS: "
 				       "unknown or invalid path-MTU (%u)\n",
-				       dst_mtu(skb->dst));
+				       dst_mtu(skb_dst(skb)));
 			return -1;
 		}
 		if (in_mtu <= minlen) {
@@ -86,7 +86,7 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 				       "invalid path-MTU (%u)\n", in_mtu);
 			return -1;
 		}
-		newmss = min(dst_mtu(skb->dst), in_mtu) - minlen;
+		newmss = min(dst_mtu(skb_dst(skb)), in_mtu) - minlen;
 	} else
 		newmss = info->mss;
 
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index 328bd20..4cbfebd 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -86,7 +86,7 @@ match_policy_out(const struct sk_buff *skb, const struct xt_policy_info *info,
 		 unsigned short family)
 {
 	const struct xt_policy_elem *e;
-	const struct dst_entry *dst = skb->dst;
+	const struct dst_entry *dst = skb_dst(skb);
 	int strict = info->flags & XT_POLICY_MATCH_STRICT;
 	int i, pos;
 
diff --git a/net/netfilter/xt_realm.c b/net/netfilter/xt_realm.c
index 6741928..484d168 100644
--- a/net/netfilter/xt_realm.c
+++ b/net/netfilter/xt_realm.c
@@ -25,7 +25,7 @@ static bool
 realm_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
 	const struct xt_realm_info *info = par->matchinfo;
-	const struct dst_entry *dst = skb->dst;
+	const struct dst_entry *dst = skb_dst(skb);
 
 	return (info->id == (dst->tclassid & info->mask)) ^ info->invert;
 }
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6da9f38..4f76e55 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -372,8 +372,7 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,  struct
 		goto oom;
 
 	/* drop any routing info */
-	dst_release(skb->dst);
-	skb->dst = NULL;
+	skb_dst_drop(skb);
 
 	/* drop conntrack reference */
 	nf_reset(skb);
@@ -621,8 +620,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 
 	skb_set_owner_r(skb, sk);
 	skb->dev = NULL;
-	dst_release(skb->dst);
-	skb->dst = NULL;
+	skb_dst_drop(skb);
 
 	/* drop conntrack reference */
 	nf_reset(skb);
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 0ef4e30..9402a7f 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -84,7 +84,7 @@ static u32 flow_get_dst(const struct sk_buff *skb)
 	case htons(ETH_P_IPV6):
 		return ntohl(ipv6_hdr(skb)->daddr.s6_addr32[3]);
 	default:
-		return addr_fold(skb->dst) ^ (__force u16)skb->protocol;
+		return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
 	}
 }
 
@@ -163,7 +163,7 @@ static u32 flow_get_proto_dst(const struct sk_buff *skb)
 		break;
 	}
 	default:
-		res = addr_fold(skb->dst) ^ (__force u16)skb->protocol;
+		res = addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
 	}
 
 	return res;
@@ -251,8 +251,8 @@ fallback:
 static u32 flow_get_rtclassid(const struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_CLS_ROUTE
-	if (skb->dst)
-		return skb->dst->tclassid;
+	if (skb_dst(skb))
+		return skb_dst(skb)->tclassid;
 #endif
 	return 0;
 }
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index bdf1f41..dd872d5 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -137,7 +137,7 @@ static int route4_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	u32 id, h;
 	int iif, dont_cache = 0;
 
-	if ((dst = skb->dst) == NULL)
+	if ((dst = skb_dst(skb)) == NULL)
 		goto failure;
 
 	id = dst->tclassid;
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index b6b588b..266151a 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -246,11 +246,11 @@ META_COLLECTOR(int_tcindex)
 
 META_COLLECTOR(int_rtclassid)
 {
-	if (unlikely(skb->dst == NULL))
+	if (unlikely(skb_dst(skb) == NULL))
 		*err = -1;
 	else
 #ifdef CONFIG_NET_CLS_ROUTE
-		dst->value = skb->dst->tclassid;
+		dst->value = skb_dst(skb)->tclassid;
 #else
 		dst->value = 0;
 #endif
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 33133d2..8706920 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -149,7 +149,7 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 		break;
 	}
 	default:
-		h = (unsigned long)skb->dst ^ skb->protocol;
+		h = (unsigned long)skb_dst(skb) ^ skb->protocol;
 		h2 = (unsigned long)skb->sk;
 	}
 
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index a886496..cb1cb1e 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -222,7 +222,7 @@ __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *
 {
 	struct netdev_queue *dev_queue = netdev_get_tx_queue(dev, 0);
 	struct teql_sched_data *q = qdisc_priv(dev_queue->qdisc);
-	struct neighbour *mn = skb->dst->neighbour;
+	struct neighbour *mn = skb_dst(skb)->neighbour;
 	struct neighbour *n = q->ncache;
 
 	if (mn->tbl == NULL)
@@ -262,8 +262,8 @@ static inline int teql_resolve(struct sk_buff *skb,
 		return -ENODEV;
 
 	if (dev->header_ops == NULL ||
-	    skb->dst == NULL ||
-	    skb->dst->neighbour == NULL)
+	    skb_dst(skb) == NULL ||
+	    skb_dst(skb)->neighbour == NULL)
 		return 0;
 	return __teql_resolve(skb, skb_res, dev);
 }
diff --git a/net/sctp/output.c b/net/sctp/output.c
index f0c91df..b764114 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -405,10 +405,10 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 			sctp_assoc_sync_pmtu(asoc);
 		}
 	}
-	nskb->dst = dst_clone(tp->dst);
-	if (!nskb->dst)
+	dst = dst_clone(tp->dst);
+	skb_dst_set(nskb, dst);
+	if (dst)
 		goto no_route;
-	dst = nskb->dst;
 
 	/* Build the SCTP header.  */
 	sh = (struct sctphdr *)skb_push(nskb, sizeof(struct sctphdr));
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index e185961..6c2d615 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -918,7 +918,7 @@ static void xs_udp_data_ready(struct sock *sk, int len)
 	UDPX_INC_STATS_BH(sk, UDP_MIB_INDATAGRAMS);
 
 	/* Something worked... */
-	dst_confirm(skb->dst);
+	dst_confirm(skb_dst(skb));
 
 	xprt_adjust_cwnd(task, copied);
 	xprt_update_rtt(task);
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index b4a1317..e0009c1 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -251,8 +251,7 @@ resume:
 	nf_reset(skb);
 
 	if (decaps) {
-		dst_release(skb->dst);
-		skb->dst = NULL;
+		skb_dst_drop(skb);
 		netif_rx(skb);
 		return 0;
 	} else {
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index c235597..b9fe131 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -22,7 +22,7 @@ static int xfrm_output2(struct sk_buff *skb);
 
 static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	int nhead = dst->header_len + LL_RESERVED_SPACE(dst->dev)
 		- skb_headroom(skb);
 	int ntail = dst->dev->needed_tailroom - skb_tailroom(skb);
@@ -39,7 +39,7 @@ static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
 
 static int xfrm_output_one(struct sk_buff *skb, int err)
 {
-	struct dst_entry *dst = skb->dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_state *x = dst->xfrm;
 	struct net *net = xs_net(x);
 
@@ -94,12 +94,13 @@ resume:
 			goto error_nolock;
 		}
 
-		if (!(skb->dst = dst_pop(dst))) {
+		dst = dst_pop(dst);
+		if (!dst) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
 			err = -EHOSTUNREACH;
 			goto error_nolock;
 		}
-		dst = skb->dst;
+		skb_dst_set(skb, dst);
 		x = dst->xfrm;
 	} while (x && !(x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL));
 
@@ -119,16 +120,16 @@ int xfrm_output_resume(struct sk_buff *skb, int err)
 	while (likely((err = xfrm_output_one(skb, err)) == 0)) {
 		nf_reset(skb);
 
-		err = skb->dst->ops->local_out(skb);
+		err = skb_dst(skb)->ops->local_out(skb);
 		if (unlikely(err != 1))
 			goto out;
 
-		if (!skb->dst->xfrm)
+		if (!skb_dst(skb)->xfrm)
 			return dst_output(skb);
 
-		err = nf_hook(skb->dst->ops->family,
+		err = nf_hook(skb_dst(skb)->ops->family,
 			      NF_INET_POST_ROUTING, skb,
-			      NULL, skb->dst->dev, xfrm_output2);
+			      NULL, skb_dst(skb)->dev, xfrm_output2);
 		if (unlikely(err != 1))
 			goto out;
 	}
@@ -179,7 +180,7 @@ static int xfrm_output_gso(struct sk_buff *skb)
 
 int xfrm_output(struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb->dst->dev);
+	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
 
 	if (skb_is_gso(skb))
@@ -202,7 +203,7 @@ int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct xfrm_mode *inner_mode;
 	if (x->sel.family == AF_UNSPEC)
 		inner_mode = xfrm_ip2inner_mode(x,
-				xfrm_af2proto(skb->dst->ops->family));
+				xfrm_af2proto(skb_dst(skb)->ops->family));
 	else
 		inner_mode = x->inner_mode;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 9c068ab..cb81ca3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2027,6 +2027,8 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 {
 	struct net *net = dev_net(skb->dev);
 	struct flowi fl;
+	struct dst_entry *dst;
+	int res;
 
 	if (xfrm_decode_session(skb, &fl, family) < 0) {
 		/* XXX: we should have something like FWDHDRERROR here. */
@@ -2034,7 +2036,11 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 		return 0;
 	}
 
-	return xfrm_lookup(net, &skb->dst, &fl, NULL, 0) == 0;
+	dst = skb_dst(skb);
+
+	res = xfrm_lookup(net, &dst, &fl, NULL, 0) == 0;
+	skb_dst_set(skb, dst);
+	return res;
 }
 EXPORT_SYMBOL(__xfrm_route_forward);
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 2fcad7c..4bfc615 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4503,7 +4503,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
 	 * when the packet is on it's final way out.
 	 * NOTE: there appear to be some IPv6 multicast cases where skb->dst
 	 *       is NULL, in this case go ahead and apply access control. */
-	if (skb->dst != NULL && skb->dst->xfrm != NULL)
+	if (skb_dst(skb) != NULL && skb_dst(skb)->xfrm != NULL)
 		return NF_ACCEPT;
 #endif
 	secmark_active = selinux_secmark_enabled();
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index c0eb720..72b1845 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -447,7 +447,7 @@ int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
 	struct dst_entry *dst;
 	int rc = 0;
 
-	dst = skb->dst;
+	dst = skb_dst(skb);
 
 	if (dst) {
 		struct dst_entry *dst_test;
