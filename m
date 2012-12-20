From: Stefan Hasko <hasko.stevo@gmail.com>
Subject: [PATCH] net: ipv4: route: fix coding style issues net: ipv4: tcp: fix coding style issues
Date: Thu, 20 Dec 2012 15:28:05 +0100
Message-ID: <1356013685-31649-1-git-send-email-hasko.stevo@gmail.com>
Cc: linux-kernel@vger.kernel.org, Stefan Hasko <hasko.stevo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a coding style issues.

Signed-off-by: Stefan Hasko <hasko.stevo@gmail.com>
---
 net/ipv4/route.c |  119 ++++++++++++++++-------------
 net/ipv4/tcp.c   |  218 +++++++++++++++++++++++++++++++-----------------------
 2 files changed, 194 insertions(+), 143 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 844a9ef..29678e5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -20,7 +20,7 @@
  *		Alan Cox	:	Added BSD route gw semantics
  *		Alan Cox	:	Super /proc >4K
  *		Alan Cox	:	MTU in route table
- *		Alan Cox	: 	MSS actually. Also added the window
+ *		Alan Cox	:	MSS actually. Also added the window
  *					clamper.
  *		Sam Lantinga	:	Fixed route matching in rt_del()
  *		Alan Cox	:	Routing cache support.
@@ -31,30 +31,35 @@
  *	Miquel van Smoorenburg	:	BSD API fixes.
  *	Miquel van Smoorenburg	:	Metrics.
  *		Alan Cox	:	Use __u32 properly
- *		Alan Cox	:	Aligned routing errors more closely with BSD
+ *		Alan Cox	:	Aligned routing errors more
+ *					closely with BSD
  *					our system is still very different.
  *		Alan Cox	:	Faster /proc handling
- *	Alexey Kuznetsov	:	Massive rework to support tree based routing,
+ *	Alexey Kuznetsov	:	Massive rework to support
+ *					tree based routing,
  *					routing caches and better behaviour.
  *
  *		Olaf Erb	:	irtt wasn't being copied right.
  *		Bjorn Ekwall	:	Kerneld route support.
  *		Alan Cox	:	Multicast fixed (I hope)
- * 		Pavel Krauz	:	Limited broadcast fixed
+ *		Pavel Krauz	:	Limited broadcast fixed
  *		Mike McLagan	:	Routing by source
  *	Alexey Kuznetsov	:	End of old history. Split to fib.c and
  *					route.c and rewritten from scratch.
  *		Andi Kleen	:	Load-limit warning messages.
- *	Vitaly E. Lavrov	:	Transparent proxy revived after year coma.
+ *	Vitaly E. Lavrov	:	Transparent proxy revived
+ *					after year coma.
  *	Vitaly E. Lavrov	:	Race condition in ip_route_input_slow.
- *	Tobias Ringstrom	:	Uninitialized res.type in ip_route_output_slow.
+ *	Tobias Ringstrom	:	Uninitialized res.type in
+ *					ip_route_output_slow.
  *	Vladimir V. Ivanov	:	IP rule info (flowid) is really useful.
  *		Marc Boucher	:	routing by fwmark
  *	Robert Olsson		:	Added rt_cache statistics
  *	Arnaldo C. Melo		:	Convert proc stuff to seq_file
- *	Eric Dumazet		:	hashed spinlocks and rt_check_expire() fixes.
- * 	Ilia Sotnikov		:	Ignore TOS on PMTUD and Redirect
- * 	Ilia Sotnikov		:	Removed TOS from hash calculations
+ *	Eric Dumazet		:	hashed spinlocks and
+ *					rt_check_expire() fixes.
+ *	Ilia Sotnikov		:	Ignore TOS on PMTUD and Redirect
+ *	Ilia Sotnikov		:	Removed TOS from hash calculations
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -65,7 +70,7 @@
 #define pr_fmt(fmt) "IPv4: " fmt
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
@@ -139,7 +144,8 @@ static unsigned int	 ipv4_default_advmss(const struct dst_entry *dst);
 static unsigned int	 ipv4_mtu(const struct dst_entry *dst);
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
-static void		 ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
+static void		 ip_rt_update_pmtu(struct dst_entry *dst,
+					   struct sock *sk,
 					   struct sk_buff *skb, u32 mtu);
 static void		 ip_do_redirect(struct dst_entry *dst, struct sock *sk,
 					struct sk_buff *skb);
@@ -291,12 +297,11 @@ static int rt_cpu_seq_show(struct seq_file *seq, void *v)
 	struct rt_cache_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  in_hit in_slow_tot in_slow_mc in_no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
+		seq_printf(seq, "entries in_hit in_slow_tot in_slow_mc in_no_route in_brd in_martian_dst in_martian_src out_hit out_slow_tot out_slow_mc gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
 		return 0;
 	}
 
-	seq_printf(seq,"%08x  %08x %08x %08x %08x %08x %08x %08x "
-		   " %08x %08x %08x %08x %08x %08x %08x %08x %08x \n",
+		seq_printf(seq, "%08x  %08x %08x %08x %08x %08x %08x %08x  %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
 		   dst_entries_get_slow(&ipv4_dst_ops),
 		   st->in_hit,
 		   st->in_slow_tot,
@@ -657,8 +662,8 @@ out_unlock:
 	return;
 }
 
-static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flowi4 *fl4,
-			     bool kill_route)
+static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb,
+			     struct flowi4 *fl4, bool kill_route)
 {
 	__be32 new_gw = icmp_hdr(skb)->un.gateway;
 	__be32 old_gw = ip_hdr(skb)->saddr;
@@ -695,7 +700,8 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 	if (!IN_DEV_SHARED_MEDIA(in_dev)) {
 		if (!inet_addr_onlink(in_dev, new_gw, old_gw))
 			goto reject_redirect;
-		if (IN_DEV_SEC_REDIRECTS(in_dev) && ip_fib_check_default(new_gw, dev))
+		if (IN_DEV_SEC_REDIRECTS(in_dev) &&
+		    ip_fib_check_default(new_gw, dev))
 			goto reject_redirect;
 	} else {
 		if (inet_addr_type(net, new_gw) != RTN_UNICAST)
@@ -737,7 +743,8 @@ reject_redirect:
 	;
 }
 
-static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buff *skb)
+static void ip_do_redirect(struct dst_entry *dst, struct sock *sk,
+			   struct sk_buff *skb)
 {
 	struct rtable *rt;
 	struct flowi4 fl4;
@@ -1202,11 +1209,11 @@ static bool rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 	struct rtable *orig, *prev, **p;
 	bool ret = true;
 
-	if (rt_is_input_route(rt)) {
+	if (rt_is_input_route(rt))
 		p = (struct rtable **)&nh->nh_rth_input;
-	} else {
+	else
 		p = (struct rtable **)__this_cpu_ptr(nh->nh_pcpu_rth_output);
-	}
+
 	orig = *p;
 
 	prev = cmpxchg(p, orig, rt);
@@ -1359,17 +1366,17 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 #endif
 	rth->dst.output = ip_rt_bug;
 
-	rth->rt_genid	= rt_genid(dev_net(dev));
-	rth->rt_flags	= RTCF_MULTICAST;
-	rth->rt_type	= RTN_MULTICAST;
-	rth->rt_is_input= 1;
-	rth->rt_iif	= 0;
-	rth->rt_pmtu	= 0;
-	rth->rt_gateway	= 0;
+	rth->rt_genid = rt_genid(dev_net(dev));
+	rth->rt_flags = RTCF_MULTICAST;
+	rth->rt_type = RTN_MULTICAST;
+	rth->rt_is_input = 1;
+	rth->rt_iif = 0;
+	rth->rt_pmtu = 0;
+	rth->rt_gateway = 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
 	if (our) {
-		rth->dst.input= ip_local_deliver;
+		rth->dst.input = ip_local_deliver;
 		rth->rt_flags |= RTCF_LOCAL;
 	}
 
@@ -1488,8 +1495,8 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
 	rth->rt_is_input = 1;
-	rth->rt_iif 	= 0;
-	rth->rt_pmtu	= 0;
+	rth->rt_iif = 0;
+	rth->rt_pmtu = 0;
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
@@ -1649,25 +1656,25 @@ local_input:
 	if (!rth)
 		goto e_nobufs;
 
-	rth->dst.input= ip_local_deliver;
-	rth->dst.output= ip_rt_bug;
+	rth->dst.input = ip_local_deliver;
+	rth->dst.output = ip_rt_bug;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
 
 	rth->rt_genid = rt_genid(net);
-	rth->rt_flags 	= flags|RTCF_LOCAL;
-	rth->rt_type	= res.type;
+	rth->rt_flags = flags|RTCF_LOCAL;
+	rth->rt_type = res.type;
 	rth->rt_is_input = 1;
-	rth->rt_iif	= 0;
-	rth->rt_pmtu	= 0;
+	rth->rt_iif = 0;
+	rth->rt_pmtu = 0;
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
 	if (res.type == RTN_UNREACHABLE) {
-		rth->dst.input= ip_error;
-		rth->dst.error= -err;
-		rth->rt_flags 	&= ~RTCF_LOCAL;
+		rth->dst.input = ip_error;
+		rth->dst.error = -err;
+		rth->rt_flags &= ~RTCF_LOCAL;
 	}
 	if (do_cache)
 		rt_cache_route(&FIB_RES_NH(res), rth);
@@ -1772,7 +1779,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		return ERR_PTR(-EINVAL);
 
 	if (likely(!IN_DEV_ROUTE_LOCALNET(in_dev)))
-		if (ipv4_is_loopback(fl4->saddr) && !(dev_out->flags & IFF_LOOPBACK))
+		if (ipv4_is_loopback(fl4->saddr) &&
+		    !(dev_out->flags & IFF_LOOPBACK))
 			return ERR_PTR(-EINVAL);
 
 	if (ipv4_is_lbcast(fl4->daddr))
@@ -1919,7 +1927,9 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		if (fl4->flowi4_oif == 0 &&
 		    (ipv4_is_multicast(fl4->daddr) ||
 		     ipv4_is_lbcast(fl4->daddr))) {
-			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
+			/* It is equivalent to
+			 * inet_addr_type(saddr) == RTN_LOCAL
+			 */
 			dev_out = __ip_dev_find(net, fl4->saddr, false);
 			if (dev_out == NULL)
 				goto out;
@@ -1944,7 +1954,9 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		}
 
 		if (!(fl4->flowi4_flags & FLOWI_FLAG_ANYSRC)) {
-			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
+			/* It is equivalent to
+			 * inet_addr_type(saddr) == RTN_LOCAL
+			 */
 			if (!__ip_dev_find(net, fl4->saddr, false))
 				goto out;
 		}
@@ -1972,7 +1984,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		if (fl4->saddr) {
 			if (ipv4_is_multicast(fl4->daddr))
 				fl4->saddr = inet_select_addr(dev_out, 0,
-							      fl4->flowi4_scope);
+							     fl4->flowi4_scope);
 			else if (!fl4->daddr)
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_HOST);
@@ -2061,7 +2073,8 @@ out:
 }
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
-static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *dst, u32 cookie)
+static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *dst,
+						  u32 cookie)
 {
 	return NULL;
 }
@@ -2073,7 +2086,8 @@ static unsigned int ipv4_blackhole_mtu(const struct dst_entry *dst)
 	return mtu ? : dst->dev->mtu;
 }
 
-static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, struct sock *sk,
+static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst,
+					  struct sock *sk,
 					  struct sk_buff *skb, u32 mtu)
 {
 }
@@ -2101,7 +2115,8 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.neigh_lookup		=	ipv4_neigh_lookup,
 };
 
-struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig)
+struct dst_entry *ipv4_blackhole_route(struct net *net,
+				       struct dst_entry *dst_orig)
 {
 	struct rtable *ort = (struct rtable *) dst_orig;
 	struct rtable *rt;
@@ -2265,7 +2280,8 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void *arg)
+static int inet_rtm_getroute(struct sk_buff *in_skb,
+			     struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct rtmsg *rtm;
@@ -2297,7 +2313,9 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 
-	/* Bugfix: need to give ip_route_input enough of an IP header to not gag. */
+	/* Bugfix: need to give ip_route_input enough
+	 * of an IP header to not gag.
+	 */
 	ip_hdr(skb)->protocol = IPPROTO_ICMP;
 	skb_reserve(skb, MAX_HEADER + sizeof(struct iphdr));
 
@@ -2596,7 +2614,8 @@ int __init ip_rt_init(void)
 	int rc = 0;
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
-	ip_rt_acct = __alloc_percpu(256 * sizeof(struct ip_rt_acct), __alignof__(struct ip_rt_acct));
+	ip_rt_acct = __alloc_percpu(256 * sizeof(struct ip_rt_acct),
+				    __alignof__(struct ip_rt_acct));
 	if (!ip_rt_acct)
 		panic("IP: failed to allocate ip_rt_acct\n");
 #endif
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1ca2536..12fadb2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -45,7 +45,7 @@
  *					escape still
  *		Alan Cox	:	Fixed another acking RST frame bug.
  *					Should stop LAN workplace lockups.
- *		Alan Cox	: 	Some tidyups using the new skb list
+ *		Alan Cox	:	Some tidyups using the new skb list
  *					facilities
  *		Alan Cox	:	sk->keepopen now seems to work
  *		Alan Cox	:	Pulls options out correctly on accepts
@@ -160,7 +160,8 @@
  *					generates them.
  *		Alan Cox	:	Cache last socket.
  *		Alan Cox	:	Per route irtt.
- *		Matt Day	:	poll()->select() match BSD precisely on error
+ *		Matt Day	:	poll()->select() match BSD precisely
+ *					on error
  *		Alan Cox	:	New buffers
  *		Marc Tamsky	:	Various sk->prot->retransmits and
  *					sk->retransmits misupdating fixed.
@@ -168,9 +169,9 @@
  *					and TCP syn retries gets used now.
  *		Mark Yarvis	:	In tcp_read_wakeup(), don't send an
  *					ack if state is TCP_CLOSED.
- *		Alan Cox	:	Look up device on a retransmit - routes may
- *					change. Doesn't yet cope with MSS shrink right
- *					but it's a start!
+ *		Alan Cox	:	Look up device on a retransmit - routes
+ *					may change. Doesn't yet cope with MSS
+ *					shrink right but it's a start!
  *		Marc Tamsky	:	Closing in closing fixes.
  *		Mike Shaver	:	RFC1122 verifications.
  *		Alan Cox	:	rcv_saddr errors.
@@ -199,7 +200,7 @@
  *					tcp_do_sendmsg to avoid burstiness.
  *		Eric Schenk	:	Fix fast close down bug with
  *					shutdown() followed by close().
- *		Andi Kleen 	:	Make poll agree with SIGIO
+ *		Andi Kleen	:	Make poll agree with SIGIO
  *	Salvatore Sanfilippo	:	Support SO_LINGER with linger == 1 and
  *					lingertime == 0 (RFC 793 ABORT Call)
  *	Hirokazu Takahashi	:	Use copy_from_user() instead of
@@ -268,6 +269,7 @@
 #include <linux/crypto.h>
 #include <linux/time.h>
 #include <linux/slab.h>
+#include <linux/uaccess.h>
 
 #include <net/icmp.h>
 #include <net/inet_common.h>
@@ -277,7 +279,6 @@
 #include <net/netdma.h>
 #include <net/sock.h>
 
-#include <asm/uaccess.h>
 #include <asm/ioctls.h>
 
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
@@ -286,22 +287,20 @@ struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
 
 int sysctl_tcp_wmem[3] __read_mostly;
-int sysctl_tcp_rmem[3] __read_mostly;
+EXPORT_SYMBOL(sysctl_tcp_wmem);
 
+int sysctl_tcp_rmem[3] __read_mostly;
 EXPORT_SYMBOL(sysctl_tcp_rmem);
-EXPORT_SYMBOL(sysctl_tcp_wmem);
 
 atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
 EXPORT_SYMBOL(tcp_memory_allocated);
 
-/*
- * Current number of TCP sockets.
+/* Current number of TCP sockets.
  */
 struct percpu_counter tcp_sockets_allocated;
 EXPORT_SYMBOL(tcp_sockets_allocated);
 
-/*
- * TCP splice context
+/* TCP splice context
  */
 struct tcp_splice_state {
 	struct pipe_inode_info *pipe;
@@ -309,8 +308,7 @@ struct tcp_splice_state {
 	unsigned int flags;
 };
 
-/*
- * Pressure flag: try to collapse.
+/* Pressure flag: try to collapse.
  * Technical note: it is used by multiple contexts non atomically.
  * All the __sk_mem_schedule() is of this nature: accounting
  * is strict, actions are advisory and have some latency.
@@ -430,8 +428,7 @@ void tcp_init_sock(struct sock *sk)
 }
 EXPORT_SYMBOL(tcp_init_sock);
 
-/*
- *	Wait for a TCP event.
+/*	Wait for a TCP event.
  *
  *	Note that we don't need to lock the socket, as the upper poll layers
  *	take care of normal races (between the test and the event) and we don't
@@ -454,8 +451,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 
 	mask = 0;
 
-	/*
-	 * POLLHUP is certainly not done right. But poll() doesn't
+	/* POLLHUP is certainly not done right. But poll() doesn't
 	 * have a notion of HUP in just one direction, and for a
 	 * socket the read side is more interesting.
 	 *
@@ -498,7 +494,8 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 
 		/* Potential race condition. If read of tp below will
 		 * escape above sk->sk_state, we can be illegally awaken
-		 * in SYN_* states. */
+		 * in SYN_* states.
+		 */
 		if (tp->rcv_nxt - tp->copied_seq >= target)
 			mask |= POLLIN | POLLRDNORM;
 
@@ -509,14 +506,15 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 				set_bit(SOCK_ASYNC_NOSPACE,
 					&sk->sk_socket->flags);
 				set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
-
-				/* Race breaker. If space is freed after
-				 * wspace test but before the flags are set,
-				 * IO signal will be lost.
-				 */
-				if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
-					mask |= POLLOUT | POLLWRNORM;
 			}
+
+			/* Race breaker. If space is freed after
+			 * wspace test but before the flags are set,
+			 * IO signal will be lost.
+			 */
+			if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)
+			 && sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
+				mask |= POLLOUT | POLLWRNORM;
 		} else
 			mask |= POLLOUT | POLLWRNORM;
 
@@ -634,7 +632,7 @@ static inline void tcp_push(struct sock *sk, int flags, int mss_now,
 
 		tcp_mark_urg(tp, flags);
 		__tcp_push_pending_frames(sk, mss_now,
-					  (flags & MSG_MORE) ? TCP_NAGLE_CORK : nonagle);
+				(flags & MSG_MORE) ? TCP_NAGLE_CORK : nonagle);
 	}
 }
 
@@ -839,6 +837,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 	int err;
 	ssize_t copied;
 	long timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
+	int ass_res = 0;
 
 	/* Wait for a connection to finish. One exception is TCP Fast Open
 	 * (passive side) where data is allowed to be sent before a connection
@@ -846,7 +845,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 	 */
 	if (((1 << sk->sk_state) & ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)) &&
 	    !tcp_passive_fastopen(sk)) {
-		if ((err = sk_stream_wait_connect(sk, &timeo)) != 0)
+		ass_res = (err = sk_stream_wait_connect(sk, &timeo));
+		if (ass_res != 0)
 			goto out_err;
 	}
 
@@ -864,7 +864,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 		int copy, i;
 		bool can_coalesce;
 
-		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
+		ass_res = (copy = size_goal - skb->len);
+		if (!tcp_send_head(sk) || ass_res <= 0) {
 new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
@@ -911,7 +912,9 @@ new_segment:
 
 		copied += copy;
 		offset += copy;
-		if (!(size -= copy))
+
+		ass_res = (size -= copy);
+		if (!ass_res)
 			goto out;
 
 		if (skb->len < size_goal || (flags & MSG_OOB))
@@ -929,7 +932,8 @@ wait_for_sndbuf:
 wait_for_memory:
 		tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
 
-		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
+		ass_res = (err = sk_stream_wait_memory(sk, &timeo));
+		if (ass_res != 0)
 			goto do_error;
 
 		mss_now = tcp_send_mss(sk, &size_goal, flags);
@@ -1029,6 +1033,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	int mss_now = 0, size_goal, copied_syn = 0, offset = 0;
 	bool sg;
 	long timeo;
+	int ass_res = 0;
 
 	lock_sock(sk);
 
@@ -1050,7 +1055,8 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 */
 	if (((1 << sk->sk_state) & ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)) &&
 	    !tcp_passive_fastopen(sk)) {
-		if ((err = sk_stream_wait_connect(sk, &timeo)) != 0)
+		ass_res = (err = sk_stream_wait_connect(sk, &timeo));
+		if (ass_res != 0)
 			goto do_error;
 	}
 
@@ -1099,7 +1105,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		}
 
 		while (seglen > 0) {
-			int copy = 0;
+			int copy = 0, ass_res = 0;
 			int max = size_goal;
 
 			skb = tcp_write_queue_tail(sk);
@@ -1123,8 +1129,7 @@ new_segment:
 				if (!skb)
 					goto wait_for_memory;
 
-				/*
-				 * Check whether we can use HW checksum.
+				/* Check whether we can use HW checksum.
 				 */
 				if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
 					skb->ip_summed = CHECKSUM_PARTIAL;
@@ -1162,7 +1167,8 @@ new_segment:
 					merge = false;
 				}
 
-				copy = min_t(int, copy, pfrag->size - pfrag->offset);
+				copy = min_t(int, copy,
+					pfrag->size - pfrag->offset);
 
 				if (!sk_wmem_schedule(sk, copy))
 					goto wait_for_memory;
@@ -1176,7 +1182,8 @@ new_segment:
 
 				/* Update the skb. */
 				if (merge) {
-					skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
+					skb_frag_size_add(
+					  &skb_shinfo(skb)->frags[i - 1], copy);
 				} else {
 					skb_fill_page_desc(skb, i, pfrag->page,
 							   pfrag->offset, copy);
@@ -1194,15 +1201,19 @@ new_segment:
 
 			from += copy;
 			copied += copy;
-			if ((seglen -= copy) == 0 && iovlen == 0)
+			ass_res = (seglen -= copy);
+			if (ass_res == 0 && iovlen == 0)
 				goto out;
 
-			if (skb->len < max || (flags & MSG_OOB) || unlikely(tp->repair))
+			if (skb->len < max ||
+			   (flags & MSG_OOB) ||
+			   unlikely(tp->repair))
 				continue;
 
 			if (forced_push(tp)) {
 				tcp_mark_push(tp, skb);
-				__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_PUSH);
+				__tcp_push_pending_frames(sk, mss_now,
+					TCP_NAGLE_PUSH);
 			} else if (skb == tcp_send_head(sk))
 				tcp_push_one(sk, mss_now);
 			continue;
@@ -1211,9 +1222,11 @@ wait_for_sndbuf:
 			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
 			if (copied)
-				tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
+				tcp_push(sk, flags & ~MSG_MORE,
+					mss_now, TCP_NAGLE_PUSH);
 
-			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
+			ass_res = (err = sk_stream_wait_memory(sk, &timeo));
+			if (ass_res != 0)
 				goto do_error;
 
 			mss_now = tcp_send_mss(sk, &size_goal, flags);
@@ -1246,8 +1259,7 @@ out_err:
 }
 EXPORT_SYMBOL(tcp_sendmsg);
 
-/*
- *	Handle reading urgent data. BSD has very simple semantics for
+/*	Handle reading urgent data. BSD has very simple semantics for
  *	this, no blocking and very strange errors 8)
  */
 
@@ -1333,7 +1345,8 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 	if (inet_csk_ack_scheduled(sk)) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
 		   /* Delayed ACKs frequently hit locked sockets during bulk
-		    * receive. */
+		    * receive.
+		    */
 		if (icsk->icsk_ack.blocked ||
 		    /* Once-per-two-segments ACK was not sent by tcp_input.c */
 		    tp->rcv_nxt - tp->rcv_wup > icsk->icsk_ack.rcv_mss ||
@@ -1366,7 +1379,8 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 
 			/* Send ACK now, if this read freed lots of space
 			 * in our buffer. Certainly, new_window is new window.
-			 * We can advertise it now, if it is not less than current one.
+			 * We can advertise it now, if it is not less than
+			 * current one.
 			 * "Lots" means "at least twice" here.
 			 */
 			if (new_window && new_window >= 2 * rcv_window_now)
@@ -1385,7 +1399,8 @@ static void tcp_prequeue_process(struct sock *sk)
 	NET_INC_STATS_USER(sock_net(sk), LINUX_MIB_TCPPREQUEUED);
 
 	/* RX process wants to run with disabled BHs, though it is not
-	 * necessary */
+	 * necessary
+	 */
 	local_bh_disable();
 	while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
 		sk_backlog_rcv(sk, skb);
@@ -1445,8 +1460,7 @@ static inline struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
 	return NULL;
 }
 
-/*
- * This routine provides an alternative to tcp_recvmsg() for routines
+/* This routine provides an alternative to tcp_recvmsg() for routines
  * that would like to handle copying from skbuffs directly in 'sendfile'
  * fashion.
  * Note:
@@ -1526,8 +1540,7 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 }
 EXPORT_SYMBOL(tcp_read_sock);
 
-/*
- *	This routine copies from a sock struct into the user buffer.
+/*	This routine copies from a sock struct into the user buffer.
  *
  *	Technical note: in 2.3 we work on _locked_ socket, so that
  *	tricks with *seq access order and skb->users are not required.
@@ -1610,12 +1623,15 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	do {
 		u32 offset;
 
-		/* Are we at urgent data? Stop if we have read anything or have SIGURG pending. */
+		/* Are we at urgent data? Stop if we have read
+		 * anything or have SIGURG pending.
+		 */
 		if (tp->urg_data && tp->urg_seq == *seq) {
 			if (copied)
 				break;
 			if (signal_pending(current)) {
-				copied = timeo ? sock_intr_errno(timeo) : -EAGAIN;
+				copied = timeo ?
+					sock_intr_errno(timeo) : -EAGAIN;
 				break;
 			}
 		}
@@ -1744,7 +1760,8 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				tcp_service_net_dma(sk, true);
 				tcp_cleanup_rbuf(sk, copied);
 			} else
-				dma_async_memcpy_issue_pending(tp->ucopy.dma_chan);
+				dma_async_memcpy_issue_pending(
+					tp->ucopy.dma_chan);
 		}
 #endif
 		if (copied >= target) {
@@ -1760,12 +1777,15 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 #endif
 
 		if (user_recv) {
-			int chunk;
+			int chunk, ass_res = 0;
 
 			/* __ Restore normal policy in scheduler __ */
 
-			if ((chunk = len - tp->ucopy.len) != 0) {
-				NET_ADD_STATS_USER(sock_net(sk), LINUX_MIB_TCPDIRECTCOPYFROMBACKLOG, chunk);
+			ass_res = (chunk = len - tp->ucopy.len);
+			if (ass_res != 0) {
+				NET_ADD_STATS_USER(sock_net(sk),
+					LINUX_MIB_TCPDIRECTCOPYFROMBACKLOG,
+					chunk);
 				len -= chunk;
 				copied += chunk;
 			}
@@ -1775,8 +1795,11 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 do_prequeue:
 				tcp_prequeue_process(sk);
 
-				if ((chunk = len - tp->ucopy.len) != 0) {
-					NET_ADD_STATS_USER(sock_net(sk), LINUX_MIB_TCPDIRECTCOPYFROMPREQUEUE, chunk);
+				ass_res = (chunk = len - tp->ucopy.len);
+				if (ass_res != 0) {
+					NET_ADD_STATS_USER(sock_net(sk),
+					    LINUX_MIB_TCPDIRECTCOPYFROMPREQUEUE,
+					    chunk);
 					len -= chunk;
 					copied += chunk;
 				}
@@ -1791,7 +1814,7 @@ do_prequeue:
 		}
 		continue;
 
-	found_ok_skb:
+found_ok_skb:
 		/* Ok so how much can we use? */
 		used = skb->len - offset;
 		if (len < used)
@@ -1800,19 +1823,18 @@ do_prequeue:
 		/* Do we have urgent data here? */
 		if (tp->urg_data) {
 			u32 urg_offset = tp->urg_seq - *seq;
-			if (urg_offset < used) {
-				if (!urg_offset) {
-					if (!sock_flag(sk, SOCK_URGINLINE)) {
-						++*seq;
-						urg_hole++;
-						offset++;
-						used--;
-						if (!used)
-							goto skip_copy;
-					}
-				} else
-					used = urg_offset;
+			if (urg_offset < used && !urg_offset) {
+				if (!sock_flag(sk, SOCK_URGINLINE)) {
+					++*seq;
+					urg_hole++;
+					offset++;
+					used--;
+					if (!used)
+						goto skip_copy;
+				}
 			}
+			if (urg_offset < used && urg_offset)
+				used = urg_offset;
 		}
 
 		if (!(flags & MSG_TRUNC)) {
@@ -1821,7 +1843,9 @@ do_prequeue:
 				tp->ucopy.dma_chan = net_dma_find_channel();
 
 			if (tp->ucopy.dma_chan) {
-				tp->ucopy.dma_cookie = dma_skb_copy_datagram_iovec(
+				tp->ucopy.dma_cookie =
+					dma_skb_copy_datagram_iovec(
+
 					tp->ucopy.dma_chan, skb, offset,
 					msg->msg_iov, used,
 					tp->ucopy.pinned_list);
@@ -1837,7 +1861,8 @@ do_prequeue:
 					break;
 				}
 
-				dma_async_memcpy_issue_pending(tp->ucopy.dma_chan);
+				dma_async_memcpy_issue_pending(
+					tp->ucopy.dma_chan);
 
 				if ((offset + used) == skb->len)
 					copied_early = true;
@@ -1878,7 +1903,7 @@ skip_copy:
 		}
 		continue;
 
-	found_fin_ok:
+found_fin_ok:
 		/* Process the FIN. */
 		++*seq;
 		if (!(flags & MSG_PEEK)) {
@@ -1890,14 +1915,17 @@ skip_copy:
 
 	if (user_recv) {
 		if (!skb_queue_empty(&tp->ucopy.prequeue)) {
-			int chunk;
+			int chunk, ass_res = 0;
 
 			tp->ucopy.len = copied > 0 ? len : 0;
 
 			tcp_prequeue_process(sk);
 
-			if (copied > 0 && (chunk = len - tp->ucopy.len) != 0) {
-				NET_ADD_STATS_USER(sock_net(sk), LINUX_MIB_TCPDIRECTCOPYFROMPREQUEUE, chunk);
+			ass_res = (chunk = len - tp->ucopy.len);
+			if (copied > 0 && ass_res != 0) {
+				NET_ADD_STATS_USER(sock_net(sk),
+					LINUX_MIB_TCPDIRECTCOPYFROMPREQUEUE,
+					chunk);
 				len -= chunk;
 				copied += chunk;
 			}
@@ -1971,13 +1999,13 @@ void tcp_set_state(struct sock *sk, int state)
 	sk->sk_state = state;
 
 #ifdef STATE_TRACE
-	SOCK_DEBUG(sk, "TCP sk=%p, State %s -> %s\n", sk, statename[oldstate], statename[state]);
+	SOCK_DEBUG(sk, "TCP sk=%p, State %s -> %s\n", sk,
+		statename[oldstate], statename[state]);
 #endif
 }
 EXPORT_SYMBOL_GPL(tcp_set_state);
 
-/*
- *	State processing on a close. This implements the state shift for
+/*	State processing on a close. This implements the state shift for
  *	sending our FIN frame. Note that we only send a FIN for some
  *	states. A shutdown() may have already sent the FIN, or we may be
  *	closed.
@@ -2009,8 +2037,7 @@ static int tcp_close_state(struct sock *sk)
 	return next & TCP_ACTION_FIN;
 }
 
-/*
- *	Shutdown the sending side of a connection. Much like close except
+/*	Shutdown the sending side of a connection. Much like close except
  *	that we don't receive shut down or sock_set_flag(sk, SOCK_DEAD).
  */
 
@@ -2125,7 +2152,7 @@ void tcp_close(struct sock *sk, long timeout)
 		 * required by specs (TCP_ESTABLISHED, TCP_CLOSE_WAIT, when
 		 * they look as CLOSING or LAST_ACK for Linux)
 		 * Probably, I missed some more holelets.
-		 * 						--ANK
+		 *                                             --ANK
 		 * XXX (TFO) - To start off we don't support SYN+ACK+FIN
 		 * in a single packet! (May consider it later but will
 		 * probably need API support or TCP_CORK SYN-ACK until
@@ -2235,6 +2262,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	int err = 0;
+	int ass_res = 0;
 	int old_state = sk->sk_state;
 
 	if (old_state != TCP_CLOSE)
@@ -2272,7 +2300,8 @@ int tcp_disconnect(struct sock *sk, int flags)
 	sk->sk_shutdown = 0;
 	sock_reset_flag(sk, SOCK_DONE);
 	tp->srtt = 0;
-	if ((tp->write_seq += tp->max_window + 2) == 0)
+	ass_res = (tp->write_seq += tp->max_window + 2);
+	if (ass_res == 0)
 		tp->write_seq = 1;
 	icsk->icsk_backoff = 0;
 	tp->snd_cwnd = 2;
@@ -2358,8 +2387,7 @@ static int tcp_repair_options_est(struct tcp_sock *tp,
 	return 0;
 }
 
-/*
- *	Socket option code for TCP.
+/*	Socket option code for TCP.
  */
 static int do_tcp_setsockopt(struct sock *sk, int level,
 		int optname, char __user *optval, unsigned int optlen)
@@ -2491,7 +2519,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_MAXSEG:
 		/* Values greater than interface MTU won't take effect. However
 		 * at the point when this call is done we typically don't yet
-		 * know which interface is going to be used */
+		 * know which interface is going to be used
+		 */
+
 		if (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW) {
 			err = -EINVAL;
 			break;
@@ -2509,6 +2539,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			 * an explicit push, which overrides even TCP_CORK
 			 * for currently queued segments.
 			 */
+
 			tp->nonagle |= TCP_NAGLE_OFF|TCP_NAGLE_PUSH;
 			tcp_push_pending_frames(sk);
 		} else {
@@ -2786,7 +2817,8 @@ void tcp_get_info(const struct sock *sk, struct tcp_info *info)
 	info->tcpi_fackets = tp->fackets_out;
 
 	info->tcpi_last_data_sent = jiffies_to_msecs(now - tp->lsndtime);
-	info->tcpi_last_data_recv = jiffies_to_msecs(now - icsk->icsk_ack.lrcvtime);
+	info->tcpi_last_data_recv =
+		 jiffies_to_msecs(now - icsk->icsk_ack.lrcvtime);
 	info->tcpi_last_ack_recv = jiffies_to_msecs(now - tp->rcv_tstamp);
 
 	info->tcpi_pmtu = icsk->icsk_pmtu_cookie;
@@ -3378,12 +3410,12 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 }
 EXPORT_SYMBOL(tcp_md5_hash_skb_data);
 
-int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, const struct tcp_md5sig_key *key)
+int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, const struct tcp_md5sig_key *k)
 {
 	struct scatterlist sg;
 
-	sg_init_one(&sg, key->key, key->keylen);
-	return crypto_hash_update(&hp->md5_desc, &sg, key->keylen);
+	sg_init_one(&sg, k->key, k->keylen);
+	return crypto_hash_update(&hp->md5_desc, &sg, k->keylen);
 }
 EXPORT_SYMBOL(tcp_md5_hash_key);
 
-- 
1.7.10.4
