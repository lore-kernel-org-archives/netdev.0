From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 2/2] ipv6: coding style: comparison for inequality with NULL
Date: Sun, 29 Mar 2015 14:00:05 +0100
Message-ID: <1427634005-4313-3-git-send-email-ipm@chirality.org.uk>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:43484 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752879AbbC2NAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 09:00:10 -0400
In-Reply-To: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv6 code uses a mixture of coding styles. In some instances check for NULL
pointer is done as x != NULL and sometimes as x. x is preferred according to
checkpatch and this patch makes the code consistent by adopting the latter
form.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/addrconf_core.c |  2 +-
 net/ipv6/af_inet6.c      |  6 +++---
 net/ipv6/ip6_fib.c       |  4 ++--
 net/ipv6/ip6_flowlabel.c |  6 +++---
 net/ipv6/ip6_gre.c       |  6 +++---
 net/ipv6/ip6_input.c     |  2 +-
 net/ipv6/ip6_offload.c   |  2 +-
 net/ipv6/ip6_output.c    |  2 +-
 net/ipv6/ip6_tunnel.c    |  4 ++--
 net/ipv6/ip6_vti.c       |  6 +++---
 net/ipv6/ip6mr.c         |  2 +-
 net/ipv6/mcast.c         | 16 ++++++++--------
 net/ipv6/raw.c           |  4 ++--
 net/ipv6/reassembly.c    |  2 +-
 net/ipv6/sit.c           | 10 +++++-----
 net/ipv6/tcp_ipv6.c      |  8 ++++----
 net/ipv6/udp.c           |  4 ++--
 17 files changed, 43 insertions(+), 43 deletions(-)

diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index 98cc4cd..d873cee 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -140,7 +140,7 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 	struct net_device *dev = idev->dev;
 
 	WARN_ON(!list_empty(&idev->addr_list));
-	WARN_ON(idev->mc_list != NULL);
+	WARN_ON(idev->mc_list);
 	WARN_ON(timer_pending(&idev->rs_timer));
 
 #ifdef NET_REFCNT_DEBUG
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 0e48897..eef63b3 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -413,11 +413,11 @@ void inet6_destroy_sock(struct sock *sk)
 	/* Release rx options */
 
 	skb = xchg(&np->pktoptions, NULL);
-	if (skb != NULL)
+	if (skb)
 		kfree_skb(skb);
 
 	skb = xchg(&np->rxpmtu, NULL);
-	if (skb != NULL)
+	if (skb)
 		kfree_skb(skb);
 
 	/* Free flowlabels */
@@ -426,7 +426,7 @@ void inet6_destroy_sock(struct sock *sk)
 	/* Free tx options */
 
 	opt = xchg(&np->opt, NULL);
-	if (opt != NULL)
+	if (opt)
 		sock_kfree_s(sk, opt, opt->tot_len);
 }
 EXPORT_SYMBOL_GPL(inet6_destroy_sock);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 263ef41..96dbfff 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1206,7 +1206,7 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 
 		WARN_ON(fn->fn_flags & RTN_RTINFO);
 		WARN_ON(fn->fn_flags & RTN_TL_ROOT);
-		WARN_ON(fn->leaf != NULL);
+		WARN_ON(fn->leaf);
 
 		children = 0;
 		child = NULL;
@@ -1361,7 +1361,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 
 #if RT6_DEBUG >= 2
 	if (rt->dst.obsolete > 0) {
-		WARN_ON(fn != NULL);
+		WARN_ON(fn);
 		return -ENOENT;
 	}
 #endif
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 3f54ac5..d491125 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -219,7 +219,7 @@ static struct ip6_flowlabel *fl_intern(struct net *net,
 		 * with the same label can only appear on another sock
 		 */
 		lfl = __fl_lookup(net, fl->label);
-		if (lfl != NULL) {
+		if (lfl) {
 			atomic_inc(&lfl->users);
 			spin_unlock_bh(&ip6_fl_lock);
 			return lfl;
@@ -300,7 +300,7 @@ struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions *opt_space,
 	if (!fopt || fopt->opt_flen == 0)
 		return fl_opt;
 
-	if (fl_opt != NULL) {
+	if (fl_opt) {
 		opt_space->hopopt = fl_opt->hopopt;
 		opt_space->dst0opt = fl_opt->dst0opt;
 		opt_space->srcrt = fl_opt->srcrt;
@@ -661,7 +661,7 @@ release:
 			goto done;
 
 		fl1 = fl_intern(net, fl, freq.flr_label);
-		if (fl1 != NULL)
+		if (fl1)
 			goto recheck;
 
 		if (!freq.flr_label) {
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index aa9ea6e..67e014d 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -223,7 +223,7 @@ static struct ip6_tnl *ip6gre_tunnel_lookup(struct net_device *dev,
 		}
 	}
 
-	if (cand != NULL)
+	if (cand)
 		return cand;
 
 	dev = ign->fb_tunnel_dev;
@@ -1105,7 +1105,7 @@ static int ip6gre_tunnel_ioctl(struct net_device *dev,
 		t = ip6gre_tunnel_locate(net, &p1, cmd == SIOCADDTUNNEL);
 
 		if (dev != ign->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
-			if (t != NULL) {
+			if (t) {
 				if (t->dev != dev) {
 					err = -EEXIST;
 					break;
@@ -1313,7 +1313,7 @@ static void ip6gre_destroy_tunnels(struct net *net, struct list_head *head)
 
 			t = rtnl_dereference(ign->tunnels[prio][h]);
 
-			while (t != NULL) {
+			while (t) {
 				/* If dev is in the same netns, it has already
 				 * been added to the list by the previous loop.
 				 */
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index aacdcb4..fb97f7f 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -221,7 +221,7 @@ resubmit:
 
 	raw = raw6_local_deliver(skb, nexthdr);
 	ipprot = rcu_dereference(inet6_protos[nexthdr]);
-	if (ipprot != NULL) {
+	if (ipprot) {
 		int ret;
 
 		if (ipprot->flags & INET6_PROTO_FINAL) {
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 46d452a..e893cd1 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -124,7 +124,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 			unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
 			fptr = (struct frag_hdr *)((u8 *)ipv6h + unfrag_ip6hlen);
 			fptr->frag_off = htons(offset);
-			if (skb->next != NULL)
+			if (skb->next)
 				fptr->frag_off |= htons(IP6_MF);
 			offset += (ntohs(ipv6h->payload_len) -
 				   sizeof(struct frag_hdr));
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 8b6d402..84c58da 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -657,7 +657,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 				fh->nexthdr = nexthdr;
 				fh->reserved = 0;
 				fh->frag_off = htons(offset);
-				if (frag->next != NULL)
+				if (frag->next)
 					fh->frag_off |= htons(IP6_MF);
 				fh->identification = frag_id;
 				ipv6_hdr(frag)->payload_len =
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 6740206..0c68012 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -807,7 +807,7 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 
 	rcu_read_lock();
 	t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr, &ipv6h->daddr);
-	if (t != NULL) {
+	if (t) {
 		struct pcpu_sw_netstats *tstats;
 
 		tproto = ACCESS_ONCE(t->parms.proto);
@@ -1815,7 +1815,7 @@ static void __net_exit ip6_tnl_destroy_tunnels(struct net *net)
 
 	for (h = 0; h < HASH_SIZE; h++) {
 		t = rtnl_dereference(ip6n->tnls_r_l[h]);
-		while (t != NULL) {
+		while (t) {
 			/* If dev is in the same netns, it has already
 			 * been added to the list by the previous loop.
 			 */
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index a045d54..1ec5b4a 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -305,7 +305,7 @@ static int vti6_rcv(struct sk_buff *skb)
 
 	rcu_read_lock();
 	t = vti6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr, &ipv6h->daddr);
-	if (t != NULL) {
+	if (t) {
 		if (t->parms.proto != IPPROTO_IPV6 && t->parms.proto != 0) {
 			rcu_read_unlock();
 			goto discard;
@@ -736,7 +736,7 @@ vti6_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		vti6_parm_from_user(&p1, &p);
 		t = vti6_locate(net, &p1, cmd == SIOCADDTUNNEL);
 		if (dev != ip6n->fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
-			if (t != NULL) {
+			if (t) {
 				if (t->dev != dev) {
 					err = -EEXIST;
 					break;
@@ -1027,7 +1027,7 @@ static void __net_exit vti6_destroy_tunnels(struct vti6_net *ip6n)
 
 	for (h = 0; h < HASH_SIZE; h++) {
 		t = rtnl_dereference(ip6n->tnls_r_l[h]);
-		while (t != NULL) {
+		while (t) {
 			unregister_netdevice_queue(t->dev, &list);
 			t = rtnl_dereference(t->next);
 		}
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index ebb0514..ff883c9 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -305,7 +305,7 @@ static struct mr6_table *ip6mr_new_table(struct net *net, u32 id)
 	unsigned int i;
 
 	mrt = ip6mr_get_table(net, id);
-	if (mrt != NULL)
+	if (mrt)
 		return mrt;
 
 	mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 3017c4a..fac1f27 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -226,7 +226,7 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 			*lnk = mc_lst->next;
 
 			dev = __dev_get_by_index(net, mc_lst->ifindex);
-			if (dev != NULL) {
+			if (dev) {
 				struct inet6_dev *idev = __in6_dev_get(dev);
 
 				(void) ip6_mc_leave_src(sk, mc_lst, idev);
@@ -2611,7 +2611,7 @@ static struct ifmcaddr6 *igmp6_mc_get_next(struct seq_file *seq, struct ifmcaddr
 
 	im = im->next;
 	while (!im) {
-		if (likely(state->idev != NULL))
+		if (likely(state->idev))
 			read_unlock_bh(&state->idev->lock);
 
 		state->dev = next_net_device_rcu(state->dev);
@@ -2657,7 +2657,7 @@ static void igmp6_mc_seq_stop(struct seq_file *seq, void *v)
 {
 	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
 
-	if (likely(state->idev != NULL)) {
+	if (likely(state->idev)) {
 		read_unlock_bh(&state->idev->lock);
 		state->idev = NULL;
 	}
@@ -2726,10 +2726,10 @@ static inline struct ip6_sf_list *igmp6_mcf_get_first(struct seq_file *seq)
 			continue;
 		read_lock_bh(&idev->lock);
 		im = idev->mc_list;
-		if (likely(im != NULL)) {
+		if (likely(im)) {
 			spin_lock_bh(&im->mca_lock);
 			psf = im->mca_sources;
-			if (likely(psf != NULL)) {
+			if (likely(psf)) {
 				state->im = im;
 				state->idev = idev;
 				break;
@@ -2750,7 +2750,7 @@ static struct ip6_sf_list *igmp6_mcf_get_next(struct seq_file *seq, struct ip6_s
 		spin_unlock_bh(&state->im->mca_lock);
 		state->im = state->im->next;
 		while (!state->im) {
-			if (likely(state->idev != NULL))
+			if (likely(state->idev))
 				read_unlock_bh(&state->idev->lock);
 
 			state->dev = next_net_device_rcu(state->dev);
@@ -2804,11 +2804,11 @@ static void igmp6_mcf_seq_stop(struct seq_file *seq, void *v)
 	__releases(RCU)
 {
 	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
-	if (likely(state->im != NULL)) {
+	if (likely(state->im)) {
 		spin_unlock_bh(&state->im->mca_lock);
 		state->im = NULL;
 	}
-	if (likely(state->idev != NULL)) {
+	if (likely(state->idev)) {
 		read_unlock_bh(&state->idev->lock);
 		state->idev = NULL;
 	}
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index e33576d..79ccdb4 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -367,7 +367,7 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 
 	read_lock(&raw_v6_hashinfo.lock);
 	sk = sk_head(&raw_v6_hashinfo.ht[hash]);
-	if (sk != NULL) {
+	if (sk) {
 		/* Note: ipv6_hdr(skb) != skb->data */
 		const struct ipv6hdr *ip6h = (const struct ipv6hdr *)skb->data;
 		saddr = &ip6h->saddr;
@@ -1130,7 +1130,7 @@ static int rawv6_ioctl(struct sock *sk, int cmd, unsigned long arg)
 
 		spin_lock_bh(&sk->sk_receive_queue.lock);
 		skb = skb_peek(&sk->sk_receive_queue);
-		if (skb != NULL)
+		if (skb)
 			amount = skb_tail_pointer(skb) -
 				skb_transport_header(skb);
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 24fbc0a..8ffa2c8 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -552,7 +552,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 
 	fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr,
 		     ip6_frag_ecn(hdr));
-	if (fq != NULL) {
+	if (fq) {
 		int ret;
 
 		spin_lock(&fq->q.lock);
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index c61ed24..92692a7 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -118,7 +118,7 @@ static struct ip_tunnel *ipip6_tunnel_lookup(struct net *net,
 			return t;
 	}
 	t = rcu_dereference(sitn->tunnels_wc[0]);
-	if ((t != NULL) && (t->dev->flags & IFF_UP))
+	if (t && (t->dev->flags & IFF_UP))
 		return t;
 	return NULL;
 }
@@ -671,7 +671,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
-	if (tunnel != NULL) {
+	if (tunnel) {
 		struct pcpu_sw_netstats *tstats;
 
 		if (tunnel->parms.iph.protocol != IPPROTO_IPV6 &&
@@ -733,7 +733,7 @@ static int ipip_rcv(struct sk_buff *skb)
 	iph = ip_hdr(skb);
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
-	if (tunnel != NULL) {
+	if (tunnel) {
 		if (tunnel->parms.iph.protocol != IPPROTO_IPIP &&
 		    tunnel->parms.iph.protocol != 0)
 			goto drop;
@@ -1206,7 +1206,7 @@ ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		t = ipip6_tunnel_locate(net, &p, cmd == SIOCADDTUNNEL);
 
 		if (dev != sitn->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
-			if (t != NULL) {
+			if (t) {
 				if (t->dev != dev) {
 					err = -EEXIST;
 					break;
@@ -1795,7 +1795,7 @@ static void __net_exit sit_destroy_tunnels(struct net *net,
 			struct ip_tunnel *t;
 
 			t = rtnl_dereference(sitn->tunnels[prio][h]);
-			while (t != NULL) {
+			while (t) {
 				/* If dev is in the same netns, it has already
 				 * been added to the list by the previous loop.
 				 */
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a8a74d3..7cdad84 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -460,7 +460,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 				    &ireq->ir_v6_rmt_addr);
 
 		fl6->daddr = ireq->ir_v6_rmt_addr;
-		if (np->repflow && (ireq->pktopts != NULL))
+		if (np->repflow && ireq->pktopts)
 			fl6->flowlabel = ip6_flowlabel(ipv6_hdr(ireq->pktopts));
 
 		skb_set_queue_mapping(skb, queue_mapping);
@@ -1107,7 +1107,7 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	/* Clone pktoptions received with SYN */
 	newnp->pktoptions = NULL;
-	if (ireq->pktopts != NULL) {
+	if (ireq->pktopts) {
 		newnp->pktoptions = skb_clone(ireq->pktopts,
 					      sk_gfp_atomic(sk, GFP_ATOMIC));
 		consume_skb(ireq->pktopts);
@@ -1152,7 +1152,7 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
 	key = tcp_v6_md5_do_lookup(sk, &newsk->sk_v6_daddr);
-	if (key != NULL) {
+	if (key) {
 		/* We're using one, so create a matching key
 		 * on the newsk structure. If we fail to get
 		 * memory, then we end up not copying the key
@@ -1475,7 +1475,7 @@ do_time_wait:
 					    &ipv6_hdr(skb)->saddr, th->source,
 					    &ipv6_hdr(skb)->daddr,
 					    ntohs(th->dest), tcp_v6_iif(skb));
-		if (sk2 != NULL) {
+		if (sk2) {
 			struct inet_timewait_sock *tw = inet_twsk(sk);
 			inet_twsk_deschedule(tw, &tcp_death_row);
 			inet_twsk_put(tw);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 58efd2c..120aff9 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -648,7 +648,7 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 		/* if we're overly short, let UDP handle it */
 		encap_rcv = ACCESS_ONCE(up->encap_rcv);
-		if (skb->len > sizeof(struct udphdr) && encap_rcv != NULL) {
+		if (skb->len > sizeof(struct udphdr) && encap_rcv) {
 			int ret;
 
 			/* Verify checksum before giving to encap */
@@ -899,7 +899,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	 * for sock caches... i'll skip this for now.
 	 */
 	sk = __udp6_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
-	if (sk != NULL) {
+	if (sk) {
 		int ret;
 
 		if (!uh->check && !udp_sk(sk)->no_check6_rx) {
-- 
1.9.1
