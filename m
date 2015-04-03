From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 2/2] ipv4: coding style: comparison for inequality with NULL
Date: Fri,  3 Apr 2015 09:17:27 +0100
Message-ID: <1428049047-14783-3-git-send-email-ipm@chirality.org.uk>
References: <1428049047-14783-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:48373 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752725AbbDCIRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 04:17:39 -0400
In-Reply-To: <1428049047-14783-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv4 code uses a mixture of coding styles. In some instances check
for non-NULL pointer is done as x != NULL and sometimes as x. x is
preferred according to checkpatch and this patch makes the code
consistent by adopting the latter form.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv4/af_inet.c              |  2 +-
 net/ipv4/arp.c                  |  2 +-
 net/ipv4/cipso_ipv4.c           |  6 +++---
 net/ipv4/devinet.c              |  2 +-
 net/ipv4/fib_trie.c             |  4 ++--
 net/ipv4/geneve.c               |  2 +-
 net/ipv4/gre_offload.c          |  2 +-
 net/ipv4/igmp.c                 |  8 ++++----
 net/ipv4/inet_connection_sock.c |  8 ++++----
 net/ipv4/inet_hashtables.c      |  2 +-
 net/ipv4/inet_timewait_sock.c   |  2 +-
 net/ipv4/ip_fragment.c          |  3 ++-
 net/ipv4/ip_input.c             |  2 +-
 net/ipv4/ip_options.c           |  2 +-
 net/ipv4/ip_output.c            |  6 +++---
 net/ipv4/ip_sockglue.c          |  2 +-
 net/ipv4/ip_tunnel.c            |  2 +-
 net/ipv4/ip_vti.c               |  2 +-
 net/ipv4/ipmr.c                 |  2 +-
 net/ipv4/ping.c                 |  2 +-
 net/ipv4/raw.c                  |  4 ++--
 net/ipv4/route.c                |  2 +-
 net/ipv4/tcp.c                  | 12 ++++++------
 net/ipv4/tcp_diag.c             |  2 +-
 net/ipv4/tcp_input.c            | 12 ++++++------
 net/ipv4/tcp_ipv4.c             |  4 ++--
 net/ipv4/tcp_minisocks.c        |  6 +++---
 net/ipv4/tcp_output.c           | 14 +++++++-------
 net/ipv4/udp.c                  |  4 ++--
 net/ipv4/udp_offload.c          |  4 ++--
 30 files changed, 64 insertions(+), 63 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7d3b00c..8b47a4d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1269,7 +1269,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		if (udpfrag) {
 			iph->id = htons(id);
 			iph->frag_off = htons(offset >> 3);
-			if (skb->next != NULL)
+			if (skb->next)
 				iph->frag_off |= htons(IP_MF);
 			offset += skb->len - nhoff - ihl;
 		} else {
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index ffe8422..c6e67aa 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -569,7 +569,7 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 		break;
 #endif
 	default:
-		if (target_hw != NULL)
+		if (target_hw)
 			memcpy(arp_ptr, target_hw, dev->addr_len);
 		else
 			memset(arp_ptr, 0, dev->addr_len);
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 1b28e11..bdb2a07 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -502,7 +502,7 @@ int cipso_v4_doi_add(struct cipso_v4_doi *doi_def,
 	atomic_set(&doi_def->refcount, 1);
 
 	spin_lock(&cipso_v4_doi_list_lock);
-	if (cipso_v4_doi_search(doi_def->doi) != NULL) {
+	if (cipso_v4_doi_search(doi_def->doi)) {
 		spin_unlock(&cipso_v4_doi_list_lock);
 		ret_val = -EEXIST;
 		goto doi_add_return;
@@ -513,7 +513,7 @@ int cipso_v4_doi_add(struct cipso_v4_doi *doi_def,
 
 doi_add_return:
 	audit_buf = netlbl_audit_start(AUDIT_MAC_CIPSOV4_ADD, audit_info);
-	if (audit_buf != NULL) {
+	if (audit_buf) {
 		const char *type_str;
 		switch (doi_type) {
 		case CIPSO_V4_MAP_TRANS:
@@ -617,7 +617,7 @@ int cipso_v4_doi_remove(u32 doi, struct netlbl_audit *audit_info)
 
 doi_remove_return:
 	audit_buf = netlbl_audit_start(AUDIT_MAC_CIPSOV4_DEL, audit_info);
-	if (audit_buf != NULL) {
+	if (audit_buf) {
 		audit_log_format(audit_buf,
 				 " cipso_doi=%u res=%u",
 				 doi, ret_val == 0 ? 1 : 0);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 0ee2168..419d23c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1290,7 +1290,7 @@ __be32 inet_confirm_addr(struct net *net, struct in_device *in_dev,
 	__be32 addr = 0;
 	struct net_device *dev;
 
-	if (in_dev != NULL)
+	if (in_dev)
 		return confirm_addr_indev(in_dev, dst, local, scope);
 
 	rcu_read_lock();
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 9e4a3e3..e13fcc6 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -391,9 +391,9 @@ static void put_child(struct key_vector *tn, unsigned long i,
 	BUG_ON(i >= child_length(tn));
 
 	/* update emptyChildren, overflow into fullChildren */
-	if (!n && chi != NULL)
+	if (!n && chi)
 		empty_child_inc(tn);
-	if (n != NULL && !chi)
+	if (n && !chi)
 		empty_child_dec(tn);
 
 	/* update fullChildren */
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index a7d8be3..e64f8e9 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -230,7 +230,7 @@ static int geneve_gro_complete(struct sk_buff *skb, int nhoff,
 
 	rcu_read_lock();
 	ptype = gro_find_complete_by_type(type);
-	if (ptype != NULL)
+	if (ptype)
 		err = ptype->callbacks.gro_complete(skb, nhoff + gh_len);
 
 	rcu_read_unlock();
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 9358f11..5aa46d4 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -243,7 +243,7 @@ static int gre_gro_complete(struct sk_buff *skb, int nhoff)
 
 	rcu_read_lock();
 	ptype = gro_find_complete_by_type(type);
-	if (ptype != NULL)
+	if (ptype)
 		err = ptype->callbacks.gro_complete(skb, nhoff + grehlen);
 
 	rcu_read_unlock();
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 27d204b..a3a697f 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2370,7 +2370,7 @@ void ip_mc_drop_socket(struct sock *sk)
 		inet->mc_list = iml->next_rcu;
 		in_dev = inetdev_by_index(net, iml->multi.imr_ifindex);
 		(void) ip_mc_leave_src(sk, iml, in_dev);
-		if (in_dev != NULL)
+		if (in_dev)
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
@@ -2590,10 +2590,10 @@ static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
 		if (unlikely(!idev))
 			continue;
 		im = rcu_dereference(idev->mc_list);
-		if (likely(im != NULL)) {
+		if (likely(im)) {
 			spin_lock_bh(&im->lock);
 			psf = im->sources;
-			if (likely(psf != NULL)) {
+			if (likely(psf)) {
 				state->im = im;
 				state->idev = idev;
 				break;
@@ -2663,7 +2663,7 @@ static void igmp_mcf_seq_stop(struct seq_file *seq, void *v)
 	__releases(rcu)
 {
 	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
-	if (likely(state->im != NULL)) {
+	if (likely(state->im)) {
 		spin_unlock_bh(&state->im->lock);
 		state->im = NULL;
 	}
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 79c0c94..5c3dd62 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -673,7 +673,7 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
 {
 	struct sock *newsk = sk_clone_lock(sk, priority);
 
-	if (newsk != NULL) {
+	if (newsk) {
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 
 		newsk->sk_state = TCP_SYN_RECV;
@@ -843,7 +843,7 @@ void inet_csk_listen_stop(struct sock *sk)
 		sk_acceptq_removed(sk);
 		reqsk_put(req);
 	}
-	if (queue->fastopenq != NULL) {
+	if (queue->fastopenq) {
 		/* Free all the reqs queued in rskq_rst_head. */
 		spin_lock_bh(&queue->fastopenq->lock);
 		acc_req = queue->fastopenq->rskq_rst_head;
@@ -875,7 +875,7 @@ int inet_csk_compat_getsockopt(struct sock *sk, int level, int optname,
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 
-	if (icsk->icsk_af_ops->compat_getsockopt != NULL)
+	if (icsk->icsk_af_ops->compat_getsockopt)
 		return icsk->icsk_af_ops->compat_getsockopt(sk, level, optname,
 							    optval, optlen);
 	return icsk->icsk_af_ops->getsockopt(sk, level, optname,
@@ -888,7 +888,7 @@ int inet_csk_compat_setsockopt(struct sock *sk, int level, int optname,
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 
-	if (icsk->icsk_af_ops->compat_setsockopt != NULL)
+	if (icsk->icsk_af_ops->compat_setsockopt)
 		return icsk->icsk_af_ops->compat_setsockopt(sk, level, optname,
 							    optval, optlen);
 	return icsk->icsk_af_ops->setsockopt(sk, level, optname,
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 0fb841b..d4630bf 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -64,7 +64,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 {
 	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
 
-	if (tb != NULL) {
+	if (tb) {
 		write_pnet(&tb->ib_net, net);
 		tb->port      = snum;
 		tb->fastreuse = 0;
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index f38e387..118f0f1 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -173,7 +173,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 	struct inet_timewait_sock *tw =
 		kmem_cache_alloc(sk->sk_prot_creator->twsk_prot->twsk_slab,
 				 GFP_ATOMIC);
-	if (tw != NULL) {
+	if (tw) {
 		const struct inet_sock *inet = inet_sk(sk);
 
 		kmemcheck_annotate_bitfield(tw, flags);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 5a6cf86..cc1da6d 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -639,7 +639,8 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
 
 	/* Lookup (or create) queue header */
-	if ((qp = ip_find(net, ip_hdr(skb), user)) != NULL) {
+	qp = ip_find(net, ip_hdr(skb), user);
+	if (qp) {
 		int ret;
 
 		spin_lock(&qp->q.lock);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 00bed6f..2e0410e 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -203,7 +203,7 @@ static int ip_local_deliver_finish(struct sk_buff *skb)
 		raw = raw_local_deliver(skb, protocol);
 
 		ipprot = rcu_dereference(inet_protos[protocol]);
-		if (ipprot != NULL) {
+		if (ipprot) {
 			int ret;
 
 			if (!ipprot->no_policy) {
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 5b3d91b..bd24679 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -264,7 +264,7 @@ int ip_options_compile(struct net *net,
 	unsigned char *iph;
 	int optlen, l;
 
-	if (skb != NULL) {
+	if (skb) {
 		rt = skb_rtable(skb);
 		optptr = (unsigned char *)&(ip_hdr(skb)[1]);
 	} else
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 561d67b..26f6f79 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -257,7 +257,7 @@ static int ip_finish_output(struct sk_buff *skb)
 {
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */
-	if (skb_dst(skb)->xfrm != NULL) {
+	if (skb_dst(skb)->xfrm) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
 		return dst_output(skb);
 	}
@@ -376,7 +376,7 @@ int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 	inet_opt = rcu_dereference(inet->inet_opt);
 	fl4 = &fl->u.ip4;
 	rt = skb_rtable(skb);
-	if (rt != NULL)
+	if (rt)
 		goto packet_routed;
 
 	/* Make sure we can route this packet. */
@@ -587,7 +587,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 					ip_options_fragment(frag);
 				offset += skb->len - hlen;
 				iph->frag_off = htons(offset>>3);
-				if (frag->next != NULL)
+				if (frag->next)
 					iph->frag_off |= htons(IP_MF);
 				/* Ready, complete checksum */
 				ip_send_check(iph);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index f64b1b2..7cfb089 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -387,7 +387,7 @@ void ip_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
 				   skb_network_header(skb);
 	serr->port = port;
 
-	if (skb_pull(skb, payload - skb->data) != NULL) {
+	if (skb_pull(skb, payload - skb->data)) {
 		skb_reset_transport_header(skb);
 		if (sock_queue_err_skb(sk, skb) == 0)
 			return;
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 4356a1d..e005198 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -877,7 +877,7 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 			break;
 		}
 		if (dev != itn->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
-			if (t != NULL) {
+			if (t) {
 				if (t->dev != dev) {
 					err = -EEXIST;
 					break;
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 5a6e270..988ae43 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -60,7 +60,7 @@ static int vti_input(struct sk_buff *skb, int nexthdr, __be32 spi,
 
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
 				  iph->saddr, iph->daddr, 0);
-	if (tunnel != NULL) {
+	if (tunnel) {
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 7e15ef6..316ca8f 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -316,7 +316,7 @@ static struct mr_table *ipmr_new_table(struct net *net, u32 id)
 	unsigned int i;
 
 	mrt = ipmr_get_table(net, id);
-	if (mrt != NULL)
+	if (mrt)
 		return mrt;
 
 	mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 2dcd2e6..a93f260 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -971,7 +971,7 @@ bool ping_rcv(struct sk_buff *skb)
 	skb_push(skb, skb->data - (u8 *)icmph);
 
 	sk = ping_lookup(net, skb, ntohs(icmph->un.echo.id));
-	if (sk != NULL) {
+	if (sk) {
 		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
 		pr_debug("rcv on socket %p\n", sk);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 46a7820..6d0fa8f 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -293,7 +293,7 @@ void raw_icmp_error(struct sk_buff *skb, int protocol, u32 info)
 
 	read_lock(&raw_v4_hashinfo.lock);
 	raw_sk = sk_head(&raw_v4_hashinfo.ht[hash]);
-	if (raw_sk != NULL) {
+	if (raw_sk) {
 		iph = (const struct iphdr *)skb->data;
 		net = dev_net(skb->dev);
 
@@ -872,7 +872,7 @@ static int raw_ioctl(struct sock *sk, int cmd, unsigned long arg)
 
 		spin_lock_bh(&sk->sk_receive_queue.lock);
 		skb = skb_peek(&sk->sk_receive_queue);
-		if (skb != NULL)
+		if (skb)
 			amount = skb->len;
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
 		return put_user(amount, (int __user *)arg);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 26a1cb3..a78540f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1591,7 +1591,7 @@ static int __mkroute_input(struct sk_buff *skb,
 
 	fnhe = find_exception(&FIB_RES_NH(*res), daddr);
 	if (do_cache) {
-		if (fnhe != NULL)
+		if (fnhe)
 			rth = rcu_dereference(fnhe->fnhe_rth_input);
 		else
 			rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5bd809b..094a682 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -496,7 +496,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 
 	/* Connected or passive Fast Open socket? */
 	if (sk->sk_state != TCP_SYN_SENT &&
-	    (sk->sk_state != TCP_SYN_RECV || tp->fastopen_rsk != NULL)) {
+	    (sk->sk_state != TCP_SYN_RECV || tp->fastopen_rsk)) {
 		int target = sock_rcvlowat(sk, 0, INT_MAX);
 
 		if (tp->urg_seq == tp->copied_seq &&
@@ -1028,7 +1028,7 @@ static inline int select_size(const struct sock *sk, bool sg)
 
 void tcp_free_fastopen_req(struct tcp_sock *tp)
 {
-	if (tp->fastopen_req != NULL) {
+	if (tp->fastopen_req) {
 		kfree(tp->fastopen_req);
 		tp->fastopen_req = NULL;
 	}
@@ -1042,7 +1042,7 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 
 	if (!(sysctl_tcp_fastopen & TFO_CLIENT_ENABLE))
 		return -EOPNOTSUPP;
-	if (tp->fastopen_req != NULL)
+	if (tp->fastopen_req)
 		return -EALREADY; /* Another Fast Open is in progress */
 
 	tp->fastopen_req = kzalloc(sizeof(struct tcp_fastopen_request),
@@ -2138,7 +2138,7 @@ adjudge_to_death:
 		 * aborted (e.g., closed with unread data) before 3WHS
 		 * finishes.
 		 */
-		if (req != NULL)
+		if (req)
 			reqsk_fastopen_remove(sk, req, false);
 		inet_csk_destroy_sock(sk);
 	}
@@ -2776,7 +2776,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		break;
 
 	case TCP_FASTOPEN:
-		if (icsk->icsk_accept_queue.fastopenq != NULL)
+		if (icsk->icsk_accept_queue.fastopenq)
 			val = icsk->icsk_accept_queue.fastopenq->max_qlen;
 		else
 			val = 0;
@@ -2960,7 +2960,7 @@ void tcp_done(struct sock *sk)
 
 	tcp_set_state(sk, TCP_CLOSE);
 	tcp_clear_xmit_timers(sk);
-	if (req != NULL)
+	if (req)
 		reqsk_fastopen_remove(sk, req, false);
 
 	sk->sk_shutdown = SHUTDOWN_MASK;
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 86dc119..79b34a0 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -29,7 +29,7 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 		r->idiag_rqueue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 		r->idiag_wqueue = tp->write_seq - tp->snd_una;
 	}
-	if (info != NULL)
+	if (info)
 		tcp_get_info(sk, info);
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1fd2836..df7e7fa 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1256,7 +1256,7 @@ static u8 tcp_sacktag_one(struct sock *sk,
 		fack_count += pcount;
 
 		/* Lost marker hint past SACKed? Tweak RFC3517 cnt */
-		if (!tcp_is_fack(tp) && (tp->lost_skb_hint != NULL) &&
+		if (!tcp_is_fack(tp) && tp->lost_skb_hint &&
 		    before(start_seq, TCP_SKB_CB(tp->lost_skb_hint)->seq))
 			tp->lost_cnt_hint += pcount;
 
@@ -1535,7 +1535,7 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 		if (!before(TCP_SKB_CB(skb)->seq, end_seq))
 			break;
 
-		if ((next_dup != NULL) &&
+		if (next_dup  &&
 		    before(TCP_SKB_CB(skb)->seq, next_dup->end_seq)) {
 			in_sack = tcp_match_skb_to_sack(sk, skb,
 							next_dup->start_seq,
@@ -1551,7 +1551,7 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 		if (in_sack <= 0) {
 			tmp = tcp_shift_skb_data(sk, skb, state,
 						 start_seq, end_seq, dup_sack);
-			if (tmp != NULL) {
+			if (tmp) {
 				if (tmp != skb) {
 					skb = tmp;
 					continue;
@@ -5321,7 +5321,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 
 	tcp_set_state(sk, TCP_ESTABLISHED);
 
-	if (skb != NULL) {
+	if (skb) {
 		icsk->icsk_af_ops->sk_rx_dst_set(sk, skb);
 		security_inet_conn_established(sk, skb);
 	}
@@ -5690,7 +5690,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 	}
 
 	req = tp->fastopen_rsk;
-	if (req != NULL) {
+	if (req) {
 		WARN_ON_ONCE(sk->sk_state != TCP_SYN_RECV &&
 		    sk->sk_state != TCP_FIN_WAIT1);
 
@@ -5780,7 +5780,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		 * ACK we have received, this would have acknowledged
 		 * our SYNACK so stop the SYNACK timer.
 		 */
-		if (req != NULL) {
+		if (req) {
 			/* Return RST if ack_seq is invalid.
 			 * Note that RFC793 only says to generate a
 			 * DUPACK for it but for TCP Fast Open it seems
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8018f17..ffe1f8e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1305,7 +1305,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	/* Copy over the MD5 key from the original socket */
 	key = tcp_md5_do_lookup(sk, (union tcp_md5_addr *)&newinet->inet_daddr,
 				AF_INET);
-	if (key != NULL) {
+	if (key) {
 		/*
 		 * We're using one, so create a matching key
 		 * on the newsk structure. If we fail to get
@@ -1797,7 +1797,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	if (inet_csk(sk)->icsk_bind_hash)
 		inet_put_port(sk);
 
-	BUG_ON(tp->fastopen_rsk != NULL);
+	BUG_ON(tp->fastopen_rsk);
 
 	/* If socket is aborted during connect operation */
 	tcp_free_fastopen_req(tp);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f0db159..d700391 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -294,7 +294,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 	if (tcp_death_row.tw_count < tcp_death_row.sysctl_max_tw_buckets)
 		tw = inet_twsk_alloc(sk, state);
 
-	if (tw != NULL) {
+	if (tw) {
 		struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 		const int rto = (icsk->icsk_rto << 2) - (icsk->icsk_rto >> 1);
 		struct inet_sock *inet = inet_sk(sk);
@@ -332,7 +332,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 			struct tcp_md5sig_key *key;
 			tcptw->tw_md5_key = NULL;
 			key = tp->af_specific->md5_lookup(sk, sk);
-			if (key != NULL) {
+			if (key) {
 				tcptw->tw_md5_key = kmemdup(key, sizeof(*key), GFP_ATOMIC);
 				if (tcptw->tw_md5_key && !tcp_alloc_md5sig_pool())
 					BUG();
@@ -454,7 +454,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 {
 	struct sock *newsk = inet_csk_clone_lock(sk, req, GFP_ATOMIC);
 
-	if (newsk != NULL) {
+	if (newsk) {
 		const struct inet_request_sock *ireq = inet_rsk(req);
 		struct tcp_request_sock *treq = tcp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bdc8073..7404e52 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -641,7 +641,7 @@ static unsigned int tcp_synack_options(struct sock *sk,
 		if (unlikely(!ireq->tstamp_ok))
 			remaining -= TCPOLEN_SACKPERM_ALIGNED;
 	}
-	if (foc != NULL && foc->len >= 0) {
+	if (foc && foc->len >= 0) {
 		u32 need = TCPOLEN_EXP_FASTOPEN_BASE + foc->len;
 		need = (need + 3) & ~3U;  /* Align to 32 bits */
 		if (remaining >= need) {
@@ -2224,7 +2224,7 @@ void tcp_send_loss_probe(struct sock *sk)
 	int mss = tcp_current_mss(sk);
 	int err = -1;
 
-	if (tcp_send_head(sk) != NULL) {
+	if (tcp_send_head(sk)) {
 		err = tcp_write_xmit(sk, mss, TCP_NAGLE_OFF, 2, GFP_ATOMIC);
 		goto rearm_timer;
 	}
@@ -2758,7 +2758,7 @@ begin_fwd:
 			if (!tcp_can_forward_retransmit(sk))
 				break;
 			/* Backtrack if necessary to non-L'ed skb */
-			if (hole != NULL) {
+			if (hole) {
 				skb = hole;
 				hole = NULL;
 			}
@@ -2811,7 +2811,7 @@ void tcp_send_fin(struct sock *sk)
 	 */
 	mss_now = tcp_current_mss(sk);
 
-	if (tcp_send_head(sk) != NULL) {
+	if (tcp_send_head(sk)) {
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_FIN;
 		TCP_SKB_CB(skb)->end_seq++;
 		tp->write_seq++;
@@ -3015,7 +3015,7 @@ static void tcp_connect_init(struct sock *sk)
 		(sysctl_tcp_timestamps ? TCPOLEN_TSTAMP_ALIGNED : 0);
 
 #ifdef CONFIG_TCP_MD5SIG
-	if (tp->af_specific->md5_lookup(sk, sk) != NULL)
+	if (tp->af_specific->md5_lookup(sk, sk))
 		tp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
 #endif
 
@@ -3376,8 +3376,8 @@ int tcp_write_wakeup(struct sock *sk)
 	if (sk->sk_state == TCP_CLOSE)
 		return -1;
 
-	if ((skb = tcp_send_head(sk)) != NULL &&
-	    before(TCP_SKB_CB(skb)->seq, tcp_wnd_end(tp))) {
+	skb = tcp_send_head(sk);
+	if (skb && before(TCP_SKB_CB(skb)->seq, tcp_wnd_end(tp))) {
 		int err;
 		unsigned int mss = tcp_current_mss(sk);
 		unsigned int seg_size = tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9f525a2..2162fc6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1522,7 +1522,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 		/* if we're overly short, let UDP handle it */
 		encap_rcv = ACCESS_ONCE(up->encap_rcv);
-		if (skb->len > sizeof(struct udphdr) && encap_rcv != NULL) {
+		if (skb->len > sizeof(struct udphdr) && encap_rcv) {
 			int ret;
 
 			/* Verify checksum before giving to encap */
@@ -1802,7 +1802,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 						saddr, daddr, udptable, proto);
 
 	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
-	if (sk != NULL) {
+	if (sk) {
 		int ret;
 
 		if (inet_get_convert_csum(sk) && uh->check && !IS_UDPLITE(sk))
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 4915d82..f938616 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -285,7 +285,7 @@ void udp_del_offload(struct udp_offload *uo)
 	pr_warn("udp_del_offload: didn't find offload for port %d\n", ntohs(uo->port));
 unlock:
 	spin_unlock(&udp_offload_lock);
-	if (uo_priv != NULL)
+	if (uo_priv)
 		call_rcu(&uo_priv->rcu, udp_offload_free_routine);
 }
 EXPORT_SYMBOL(udp_del_offload);
@@ -394,7 +394,7 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
 			break;
 	}
 
-	if (uo_priv != NULL) {
+	if (uo_priv) {
 		NAPI_GRO_CB(skb)->proto = uo_priv->offload->ipproto;
 		err = uo_priv->offload->callbacks.gro_complete(skb,
 				nhoff + sizeof(struct udphdr),
-- 
1.9.1
