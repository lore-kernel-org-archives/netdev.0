From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next v2] ipv6: coding style improvements (remove assignment in if statements)
Date: Sun, 23 Nov 2014 21:28:43 +0000
Message-ID: <1416778123-5803-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:52856 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752299AbaKWV3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 16:29:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change has no functional impact and simply addresses some coding
style issues detected by checkpatch. Specifically this change
adjusts "if" statements which also include the assignment of a
variable.

No changes to the resultant object files result as determined by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/addrconf.c      | 12 ++++++++----
 net/ipv6/ah6.c           |  7 ++++---
 net/ipv6/esp6.c          |  3 ++-
 net/ipv6/icmp.c          |  3 ++-
 net/ipv6/ip6_flowlabel.c |  6 +++++-
 net/ipv6/ip6_input.c     |  3 ++-
 net/ipv6/ip6_output.c    | 12 ++++++++----
 net/ipv6/ip6_tunnel.c    | 15 ++++++++-------
 net/ipv6/ip6_vti.c       |  4 ++--
 net/ipv6/ndisc.c         |  7 ++++---
 net/ipv6/reassembly.c    |  3 ++-
 net/ipv6/sit.c           |  7 ++++---
 net/ipv6/udp.c           |  6 ++++--
 13 files changed, 55 insertions(+), 33 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 251fcb4..9eac3a7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2543,7 +2543,8 @@ static int inet6_addr_del(struct net *net, int ifindex, u32 ifa_flags,
 	if (!dev)
 		return -ENODEV;
 
-	if ((idev = __in6_dev_get(dev)) == NULL)
+	idev = __in6_dev_get(dev);
+	if (idev == NULL)
 		return -ENXIO;
 
 	read_lock_bh(&idev->lock);
@@ -2690,7 +2691,8 @@ static void init_loopback(struct net_device *dev)
 
 	ASSERT_RTNL();
 
-	if ((idev = ipv6_find_idev(dev)) == NULL) {
+	idev = ipv6_find_idev(dev);
+	if (idev == NULL) {
 		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
@@ -2813,7 +2815,8 @@ static void addrconf_sit_config(struct net_device *dev)
 	 * our v4 addrs in the tunnel
 	 */
 
-	if ((idev = ipv6_find_idev(dev)) == NULL) {
+	idev = ipv6_find_idev(dev);
+	if (idev == NULL) {
 		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
@@ -2837,7 +2840,8 @@ static void addrconf_gre_config(struct net_device *dev)
 
 	ASSERT_RTNL();
 
-	if ((idev = ipv6_find_idev(dev)) == NULL) {
+	idev = ipv6_find_idev(dev);
+	if (idev == NULL) {
 		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 8ab1989..a6727ad 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -353,7 +353,8 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	ahp = x->data;
 	ahash = ahp->ahash;
 
-	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
+	err = skb_cow_data(skb, 0, &trailer);
+	if (err < 0)
 		goto out;
 	nfrags = err;
 
@@ -559,8 +560,8 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, ah_hlen))
 		goto out;
 
-
-	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
+	err = skb_cow_data(skb, 0, &trailer);
+	if (err < 0)
 		goto out;
 	nfrags = err;
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index d2c2d74..e48f2c7 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -345,7 +345,8 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 		goto out;
 	}
 
-	if ((nfrags = skb_cow_data(skb, 0, &trailer)) < 0) {
+	nfrags = skb_cow_data(skb, 0, &trailer);
+	if (nfrags < 0) {
 		ret = -EINVAL;
 		goto out;
 	}
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 39b3ff9..d674152 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -243,7 +243,8 @@ int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 	struct icmp6hdr *icmp6h;
 	int err = 0;
 
-	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
+	skb = skb_peek(&sk->sk_write_queue);
+	if (skb == NULL)
 		goto out;
 
 	icmp6h = icmp6_hdr(skb);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 7221021..2f780cb 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -654,7 +654,11 @@ release:
 			goto done;
 
 		err = -ENOMEM;
-		if (sfl1 == NULL || (err = mem_check(sk)) != 0)
+		if (sfl1 == NULL)
+			goto done;
+
+		err = mem_check(sk);
+		if (err != 0)
 			goto done;
 
 		fl1 = fl_intern(net, fl, freq.flr_label);
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index a3084ab..aacdcb4 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -220,7 +220,8 @@ resubmit:
 	nexthdr = skb_network_header(skb)[nhoff];
 
 	raw = raw6_local_deliver(skb, nexthdr);
-	if ((ipprot = rcu_dereference(inet6_protos[nexthdr])) != NULL) {
+	ipprot = rcu_dereference(inet6_protos[nexthdr]);
+	if (ipprot != NULL) {
 		int ret;
 
 		if (ipprot->flags & INET6_PROTO_FINAL) {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 916d2a1..ce69a12 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -898,7 +898,8 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	if (*dst == NULL)
 		*dst = ip6_route_output(net, sk, fl6);
 
-	if ((err = (*dst)->error))
+	err = (*dst)->error;
+	if (err)
 		goto out_err_release;
 
 	if (ipv6_addr_any(&fl6->saddr)) {
@@ -946,7 +947,8 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 			memcpy(&fl_gw6, fl6, sizeof(struct flowi6));
 			memset(&fl_gw6.daddr, 0, sizeof(struct in6_addr));
 			*dst = ip6_route_output(net, sk, &fl_gw6);
-			if ((err = (*dst)->error))
+			err = (*dst)->error;
+			if (err)
 				goto out_err_release;
 		}
 	}
@@ -1054,7 +1056,8 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 	 * device, so create one single skb packet containing complete
 	 * udp datagram
 	 */
-	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL) {
+	skb = skb_peek_tail(&sk->sk_write_queue);
+	if (skb == NULL) {
 		skb = sock_alloc_send_skb(sk,
 			hh_len + fragheaderlen + transhdrlen + 20,
 			(flags & MSG_DONTWAIT), &err);
@@ -1534,7 +1537,8 @@ int ip6_push_pending_frames(struct sock *sk)
 	unsigned char proto = fl6->flowi6_proto;
 	int err = 0;
 
-	if ((skb = __skb_dequeue(&sk->sk_write_queue)) == NULL)
+	skb = __skb_dequeue(&sk->sk_write_queue);
+	if (skb == NULL)
 		goto out;
 	tail_skb = &(skb_shinfo(skb)->frag_list);
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index e2b6cfb..92b3da5 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -501,8 +501,8 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 	   processing of the error. */
 
 	rcu_read_lock();
-	if ((t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->daddr,
-					&ipv6h->saddr)) == NULL)
+	t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->daddr, &ipv6h->saddr);
+	if (t == NULL)
 		goto out;
 
 	tproto = ACCESS_ONCE(t->parms.proto);
@@ -550,7 +550,8 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 			mtu = IPV6_MIN_MTU;
 		t->dev->mtu = mtu;
 
-		if ((len = sizeof(*ipv6h) + ntohs(ipv6h->payload_len)) > mtu) {
+		len = sizeof(*ipv6h) + ntohs(ipv6h->payload_len);
+		if (len > mtu) {
 			rel_type = ICMPV6_PKT_TOOBIG;
 			rel_code = 0;
 			rel_info = mtu;
@@ -811,9 +812,8 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 	int err;
 
 	rcu_read_lock();
-
-	if ((t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr,
-					&ipv6h->daddr)) != NULL) {
+	t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr, &ipv6h->daddr);
+	if (t != NULL) {
 		struct pcpu_sw_netstats *tstats;
 
 		tproto = ACCESS_ONCE(t->parms.proto);
@@ -1069,7 +1069,8 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
 		struct sk_buff *new_skb;
 
-		if (!(new_skb = skb_realloc_headroom(skb, max_headroom)))
+		new_skb = skb_realloc_headroom(skb, max_headroom);
+		if (!new_skb)
 			goto tx_err_dst_release;
 
 		if (skb->sk)
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index ec84d03..8308216 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -287,8 +287,8 @@ static int vti6_rcv(struct sk_buff *skb)
 	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 
 	rcu_read_lock();
-	if ((t = vti6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr,
-				 &ipv6h->daddr)) != NULL) {
+	t = vti6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr, &ipv6h->daddr);
+	if (t != NULL) {
 		if (t->parms.proto != IPPROTO_IPV6 && t->parms.proto != 0) {
 			rcu_read_unlock();
 			goto discard;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2c9f6bf..6828667 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -162,7 +162,8 @@ static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
 	memcpy(opt+2, data, data_len);
 	data_len += 2;
 	opt += data_len;
-	if ((space -= data_len) > 0)
+	space -= data_len;
+	if (space > 0)
 		memset(opt, 0, space);
 }
 
@@ -656,8 +657,8 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 	if (skb && ipv6_chk_addr(dev_net(dev), &ipv6_hdr(skb)->saddr, dev, 1))
 		saddr = &ipv6_hdr(skb)->saddr;
-
-	if ((probes -= NEIGH_VAR(neigh->parms, UCAST_PROBES)) < 0) {
+	probes -= NEIGH_VAR(neigh->parms, UCAST_PROBES);
+	if (probes < 0) {
 		if (!(neigh->nud_state & NUD_VALID)) {
 			ND_PRINTK(1, dbg,
 				  "%s: trying to ucast probe in NUD_INVALID: %pI6\n",
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 51ab096..d7d70e6 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -429,7 +429,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		struct sk_buff *clone;
 		int i, plen = 0;
 
-		if ((clone = alloc_skb(0, GFP_ATOMIC)) == NULL)
+		clone = alloc_skb(0, GFP_ATOMIC);
+		if (clone == NULL)
 			goto out_oom;
 		clone->next = head->next;
 		head->next = clone;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 660496d..213546b 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1241,7 +1241,8 @@ ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				goto done;
 			err = -ENOENT;
-			if ((t = ipip6_tunnel_locate(net, &p, 0)) == NULL)
+			t = ipip6_tunnel_locate(net, &p, 0);
+			if (t == NULL)
 				goto done;
 			err = -EPERM;
 			if (t == netdev_priv(sitn->fb_tunnel_dev))
@@ -1836,8 +1837,8 @@ static int __net_init sit_init_net(struct net *net)
 		goto err_dev_free;
 
 	ipip6_tunnel_clone_6rd(sitn->fb_tunnel_dev, sitn);
-
-	if ((err = register_netdev(sitn->fb_tunnel_dev)))
+	err = register_netdev(sitn->fb_tunnel_dev);
+	if (err)
 		goto err_reg_dev;
 
 	t = netdev_priv(sitn->fb_tunnel_dev);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 0ba3de4..dbc0b04 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -357,7 +357,8 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 	struct sock *sk;
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
 
-	if (unlikely(sk = skb_steal_sock(skb)))
+	sk = skb_steal_sock(skb);
+	if (unlikely(sk))
 		return sk;
 	return __udp6_lib_lookup(dev_net(skb_dst(skb)->dev), &iph->saddr, sport,
 				 &iph->daddr, dport, inet6_iif(skb),
@@ -1026,7 +1027,8 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 	fl6 = &inet->cork.fl.u.ip6;
 
 	/* Grab the skbuff where UDP header space exists. */
-	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
+	skb = skb_peek(&sk->sk_write_queue);
+	if (skb == NULL)
 		goto out;
 
 	/*
-- 
1.9.1
