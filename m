From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/2] net: ipv4 and ipv6: Convert printk(KERN_DEBUG to pr_debug
Date: Tue, 15 May 2012 17:11:54 -0700
Message-ID: <1fd8285e798ec9b3817c790a67b2bb655ffc931b.1337126963.git.joe@perches.com>
References: <cover.1337126962.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38829 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S966737Ab2EPAMm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 20:12:42 -0400
In-Reply-To: <cover.1337126962.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the current debugging style and enable dynamic_debug.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/ah4.c                |    4 +-
 net/ipv4/arp.c                |    9 ++++---
 net/ipv4/devinet.c            |    5 +--
 net/ipv4/inet_timewait_sock.c |    4 +-
 net/ipv4/route.c              |    9 +++----
 net/ipv4/tcp_input.c          |   48 ++++++++++++++++++++--------------------
 net/ipv4/tcp_output.c         |    4 ++-
 net/ipv6/addrconf.c           |   17 ++++++-------
 net/ipv6/esp6.c               |    4 +-
 net/ipv6/ip6_fib.c            |    5 ++-
 net/ipv6/ip6_tunnel.c         |    2 +-
 net/ipv6/ipcomp6.c            |    4 +-
 12 files changed, 58 insertions(+), 57 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 3a28075..e8f2617 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -406,8 +406,8 @@ static void ah4_err(struct sk_buff *skb, u32 info)
 			      ah->spi, IPPROTO_AH, AF_INET);
 	if (!x)
 		return;
-	printk(KERN_DEBUG "pmtu discovery on SA AH/%08x/%08x\n",
-	       ntohl(ah->spi), ntohl(iph->daddr));
+	pr_debug("pmtu discovery on SA AH/%08x/%08x\n",
+		 ntohl(ah->spi), ntohl(iph->daddr));
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 373b56b..3e2bf3d 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -73,6 +73,8 @@
  *		Jesper D. Brouer:       Proxy ARP PVLAN RFC 3069 support.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/string.h>
@@ -364,8 +366,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	probes -= neigh->parms->ucast_probes;
 	if (probes < 0) {
 		if (!(neigh->nud_state & NUD_VALID))
-			printk(KERN_DEBUG
-			       "trying to ucast probe in NUD_INVALID\n");
+			pr_debug("trying to ucast probe in NUD_INVALID\n");
 		dst_ha = neigh->ha;
 		read_lock_bh(&neigh->lock);
 	} else {
@@ -452,7 +453,7 @@ static int arp_set_predefined(int addr_hint, unsigned char *haddr,
 {
 	switch (addr_hint) {
 	case RTN_LOCAL:
-		printk(KERN_DEBUG "ARP: arp called for own IP address\n");
+		pr_debug("arp called for own IP address\n");
 		memcpy(haddr, dev->dev_addr, dev->addr_len);
 		return 1;
 	case RTN_MULTICAST:
@@ -473,7 +474,7 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 	struct neighbour *n;
 
 	if (!skb_dst(skb)) {
-		printk(KERN_DEBUG "arp_find is called with dst==NULL\n");
+		pr_debug("arp_find is called with dst==NULL\n");
 		kfree_skb(skb);
 		return 1;
 	}
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 88c9e3f..10e15a1 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -217,8 +217,7 @@ void in_dev_finish_destroy(struct in_device *idev)
 	WARN_ON(idev->ifa_list);
 	WARN_ON(idev->mc_list);
 #ifdef NET_REFCNT_DEBUG
-	printk(KERN_DEBUG "in_dev_finish_destroy: %p=%s\n",
-	       idev, dev ? dev->name : "NIL");
+	pr_debug("%s: %p=%s\n", __func__, idev, dev ? dev->name : "NIL");
 #endif
 	dev_put(dev);
 	if (!idev->dead)
@@ -1174,7 +1173,7 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 
 	switch (event) {
 	case NETDEV_REGISTER:
-		printk(KERN_DEBUG "inetdev_event: bug\n");
+		pr_debug("%s: bug\n", __func__);
 		RCU_INIT_POINTER(dev->ip_ptr, NULL);
 		break;
 	case NETDEV_UP:
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 543ef62..2784db3 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -89,8 +89,8 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 
 #ifdef SOCK_REFCNT_DEBUG
 	if (atomic_read(&tw->tw_refcnt) != 1) {
-		printk(KERN_DEBUG "%s timewait_sock %p refcnt=%d\n",
-		       tw->tw_prot->name, tw, atomic_read(&tw->tw_refcnt));
+		pr_debug("%s timewait_sock %p refcnt=%d\n",
+			 tw->tw_prot->name, tw, atomic_read(&tw->tw_refcnt));
 	}
 #endif
 	while (refcnt) {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 42d7644..76e5880 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1374,8 +1374,7 @@ void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
 			return;
 		}
 	} else if (!rt)
-		printk(KERN_DEBUG "rt_bind_peer(0) @%p\n",
-		       __builtin_return_address(0));
+		pr_debug("rt_bind_peer(0) @%p\n", __builtin_return_address(0));
 
 	ip_select_fb_ident(iph);
 }
@@ -1839,9 +1838,9 @@ static void ipv4_link_failure(struct sk_buff *skb)
 
 static int ip_rt_bug(struct sk_buff *skb)
 {
-	printk(KERN_DEBUG "ip_rt_bug: %pI4 -> %pI4, %s\n",
-		&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
-		skb->dev ? skb->dev->name : "?");
+	pr_debug("%s: %pI4 -> %pI4, %s\n",
+		 __func__, &ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
+		 skb->dev ? skb->dev->name : "?");
 	kfree_skb(skb);
 	WARN_ON(1);
 	return 0;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 100b242..eb97787 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -981,12 +981,12 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
 
 		NET_INC_STATS_BH(sock_net(sk), mib_idx);
 #if FASTRETRANS_DEBUG > 1
-		printk(KERN_DEBUG "Disorder%d %d %u f%u s%u rr%d\n",
-		       tp->rx_opt.sack_ok, inet_csk(sk)->icsk_ca_state,
-		       tp->reordering,
-		       tp->fackets_out,
-		       tp->sacked_out,
-		       tp->undo_marker ? tp->undo_retrans : 0);
+		pr_debug("Disorder%d %d %u f%u s%u rr%d\n",
+			 tp->rx_opt.sack_ok, inet_csk(sk)->icsk_ca_state,
+			 tp->reordering,
+			 tp->fackets_out,
+			 tp->sacked_out,
+			 tp->undo_marker ? tp->undo_retrans : 0);
 #endif
 		tcp_disable_fack(tp);
 	}
@@ -2716,22 +2716,22 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 	struct inet_sock *inet = inet_sk(sk);
 
 	if (sk->sk_family == AF_INET) {
-		printk(KERN_DEBUG "Undo %s %pI4/%u c%u l%u ss%u/%u p%u\n",
-		       msg,
-		       &inet->inet_daddr, ntohs(inet->inet_dport),
-		       tp->snd_cwnd, tcp_left_out(tp),
-		       tp->snd_ssthresh, tp->prior_ssthresh,
-		       tp->packets_out);
+		pr_debug("Undo %s %pI4/%u c%u l%u ss%u/%u p%u\n",
+			 msg,
+			 &inet->inet_daddr, ntohs(inet->inet_dport),
+			 tp->snd_cwnd, tcp_left_out(tp),
+			 tp->snd_ssthresh, tp->prior_ssthresh,
+			 tp->packets_out);
 	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (sk->sk_family == AF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
-		printk(KERN_DEBUG "Undo %s %pI6/%u c%u l%u ss%u/%u p%u\n",
-		       msg,
-		       &np->daddr, ntohs(inet->inet_dport),
-		       tp->snd_cwnd, tcp_left_out(tp),
-		       tp->snd_ssthresh, tp->prior_ssthresh,
-		       tp->packets_out);
+		pr_debug("Undo %s %pI6/%u c%u l%u ss%u/%u p%u\n",
+			 msg,
+			 &np->daddr, ntohs(inet->inet_dport),
+			 tp->snd_cwnd, tcp_left_out(tp),
+			 tp->snd_ssthresh, tp->prior_ssthresh,
+			 tp->packets_out);
 	}
 #endif
 }
@@ -3511,18 +3511,18 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	if (!tp->packets_out && tcp_is_sack(tp)) {
 		icsk = inet_csk(sk);
 		if (tp->lost_out) {
-			printk(KERN_DEBUG "Leak l=%u %d\n",
-			       tp->lost_out, icsk->icsk_ca_state);
+			pr_debug("Leak l=%u %d\n",
+				 tp->lost_out, icsk->icsk_ca_state);
 			tp->lost_out = 0;
 		}
 		if (tp->sacked_out) {
-			printk(KERN_DEBUG "Leak s=%u %d\n",
-			       tp->sacked_out, icsk->icsk_ca_state);
+			pr_debug("Leak s=%u %d\n",
+				 tp->sacked_out, icsk->icsk_ca_state);
 			tp->sacked_out = 0;
 		}
 		if (tp->retrans_out) {
-			printk(KERN_DEBUG "Leak r=%u %d\n",
-			       tp->retrans_out, icsk->icsk_ca_state);
+			pr_debug("Leak r=%u %d\n",
+				 tp->retrans_out, icsk->icsk_ca_state);
 			tp->retrans_out = 0;
 		}
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7979bfd..1a63082 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -34,6 +34,8 @@
  *
  */
 
+#define pr_fmt(fmt) "TCP: " fmt
+
 #include <net/tcp.h>
 
 #include <linux/compiler.h>
@@ -2415,7 +2417,7 @@ int tcp_send_synack(struct sock *sk)
 
 	skb = tcp_write_queue_head(sk);
 	if (skb == NULL || !(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)) {
-		printk(KERN_DEBUG "tcp_send_synack: wrong queue state\n");
+		pr_debug("%s: wrong queue state\n", __func__);
 		return -EFAULT;
 	}
 	if (!(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_ACK)) {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7079890..8ec009c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -329,7 +329,7 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 	WARN_ON(idev->mc_list != NULL);
 
 #ifdef NET_REFCNT_DEBUG
-	printk(KERN_DEBUG "%s: %s\n", __func__, dev ? dev->name : "NIL");
+	pr_debug("%s: %s\n", __func__, dev ? dev->name : "NIL");
 #endif
 	dev_put(dev);
 	if (!idev->dead) {
@@ -542,7 +542,7 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 	WARN_ON(!hlist_unhashed(&ifp->addr_lst));
 
 #ifdef NET_REFCNT_DEBUG
-	printk(KERN_DEBUG "inet6_ifa_finish_destroy\n");
+	pr_debug("%s\n", __func__);
 #endif
 
 	in6_dev_put(ifp->idev);
@@ -2405,7 +2405,7 @@ static void init_loopback(struct net_device *dev)
 	ASSERT_RTNL();
 
 	if ((idev = ipv6_find_idev(dev)) == NULL) {
-		printk(KERN_DEBUG "init loopback: add_dev failed\n");
+		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
 
@@ -2474,7 +2474,7 @@ static void addrconf_sit_config(struct net_device *dev)
 	 */
 
 	if ((idev = ipv6_find_idev(dev)) == NULL) {
-		printk(KERN_DEBUG "init sit: add_dev failed\n");
+		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
 
@@ -2509,7 +2509,7 @@ static void addrconf_gre_config(struct net_device *dev)
 	ASSERT_RTNL();
 
 	if ((idev = ipv6_find_idev(dev)) == NULL) {
-		printk(KERN_DEBUG "init gre: add_dev failed\n");
+		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
 
@@ -2549,7 +2549,7 @@ static void ip6_tnl_add_linklocal(struct inet6_dev *idev)
 		if (!ipv6_inherit_linklocal(idev, link_dev))
 			return;
 	}
-	printk(KERN_DEBUG "init ip6-ip6: add_linklocal failed\n");
+	pr_debug("init ip6-ip6: add_linklocal failed\n");
 }
 
 /*
@@ -2565,7 +2565,7 @@ static void addrconf_ip6_tnl_config(struct net_device *dev)
 
 	idev = addrconf_add_dev(dev);
 	if (IS_ERR(idev)) {
-		printk(KERN_DEBUG "init ip6-ip6: add_dev failed\n");
+		pr_debug("init ip6-ip6: add_dev failed\n");
 		return;
 	}
 	ip6_tnl_add_linklocal(idev);
@@ -2893,8 +2893,7 @@ static void addrconf_rs_timer(unsigned long data)
 		 * Note: we do not support deprecated "all on-link"
 		 * assumption any longer.
 		 */
-		printk(KERN_DEBUG "%s: no IPv6 routers present\n",
-		       idev->dev->name);
+		pr_debug("%s: no IPv6 routers present\n", idev->dev->name);
 	}
 
 out:
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 6697eb0..1e62b75 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -444,8 +444,8 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			      esph->spi, IPPROTO_ESP, AF_INET6);
 	if (!x)
 		return;
-	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%pI6\n",
-			ntohl(esph->spi), &iph->daddr);
+	pr_debug("pmtu discovery on SA ESP/%08x/%pI6\n",
+		 ntohl(esph->spi), &iph->daddr);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index e9846da..0c220a4 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -41,7 +41,7 @@
 #define RT6_DEBUG 2
 
 #if RT6_DEBUG >= 3
-#define RT6_TRACE(x...) printk(KERN_DEBUG x)
+#define RT6_TRACE(x...) pr_debug(x)
 #else
 #define RT6_TRACE(x...) do { ; } while (0)
 #endif
@@ -1420,7 +1420,8 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 			res = fib6_del(rt, &info);
 			if (res) {
 #if RT6_DEBUG >= 2
-				printk(KERN_DEBUG "fib6_clean_node: del failed: rt=%p@%p err=%d\n", rt, rt->rt6i_node, res);
+				pr_debug("%s: del failed: rt=%p@%p err=%d\n",
+					 __func__, rt, rt->rt6i_node, res);
 #endif
 				continue;
 			}
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 7962b3d..e65c560 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -62,7 +62,7 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS_NETDEV("ip6tnl0");
 
 #ifdef IP6_TNL_DEBUG
-#define IP6_TNL_TRACE(x...) printk(KERN_DEBUG "%s:" x "\n", __func__)
+#define IP6_TNL_TRACE(x...) pr_debug("%s:" x "\n", __func__)
 #else
 #define IP6_TNL_TRACE(x...) do {;} while(0)
 #endif
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 1addba5..5cb75bf 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -72,8 +72,8 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!x)
 		return;
 
-	printk(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/%pI6\n",
-			spi, &iph->daddr);
+	pr_debug("pmtu discovery on SA IPCOMP/%08x/%pI6\n",
+		 spi, &iph->daddr);
 	xfrm_state_put(x);
 }
 
-- 
1.7.8.111.gad25c.dirty
