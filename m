From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net/ipv4: EXPORT_SYMBOL cleanups
Date: Sat, 10 Jul 2010 09:22:10 +0200
Message-ID: <1278746530.2538.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48761 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab0GJHWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 03:22:15 -0400
Received: by wyf23 with SMTP id 23so2182506wyf.19
        for <netdev@vger.kernel.org>; Sat, 10 Jul 2010 00:22:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CodingStyle cleanups

EXPORT_SYMBOL should immediately follow the symbol declaration.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/arp.c                  |   18 ++++++---------
 net/ipv4/datagram.c             |    2 -
 net/ipv4/fib_frontend.c         |    7 ++----
 net/ipv4/icmp.c                 |    7 ++----
 net/ipv4/igmp.c                 |    9 +++----
 net/ipv4/inet_connection_sock.c |   19 ----------------
 net/ipv4/inet_fragment.c        |    1 
 net/ipv4/inet_hashtables.c      |    4 ---
 net/ipv4/ip_fragment.c          |    3 --
 net/ipv4/ip_output.c            |    9 ++-----
 net/ipv4/netfilter/ipt_REJECT.c |    2 -
 net/ipv4/protocol.c             |    3 --
 net/ipv4/route.c                |    7 +-----
 net/ipv4/tcp.c                  |   35 ++++++++++--------------------
 net/ipv4/tcp_input.c            |   18 ++++++---------
 net/ipv4/tcp_ipv4.c             |   35 ++++++++++--------------------
 net/ipv4/tcp_minisocks.c        |    9 ++-----
 net/ipv4/tcp_output.c           |   12 ++++------
 net/ipv4/tcp_timer.c            |    1 
 net/ipv4/tunnel4.c              |    2 -
 net/ipv4/udplite.c              |    3 --
 net/ipv4/xfrm4_input.c          |    1 
 22 files changed, 67 insertions(+), 140 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 09ead1b..96c1955 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -116,6 +116,7 @@
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 #include <net/atmclip.h>
 struct neigh_table *clip_tbl_hook;
+EXPORT_SYMBOL(clip_tbl_hook);
 #endif
 
 #include <asm/system.h>
@@ -169,6 +170,7 @@ const struct neigh_ops arp_broken_ops = {
 	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
+EXPORT_SYMBOL(arp_broken_ops);
 
 struct neigh_table arp_tbl = {
 	.family =	AF_INET,
@@ -198,6 +200,7 @@ struct neigh_table arp_tbl = {
 	.gc_thresh2 =	512,
 	.gc_thresh3 =	1024,
 };
+EXPORT_SYMBOL(arp_tbl);
 
 int arp_mc_map(__be32 addr, u8 *haddr, struct net_device *dev, int dir)
 {
@@ -499,6 +502,7 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 		kfree_skb(skb);
 	return 1;
 }
+EXPORT_SYMBOL(arp_find);
 
 /* END OF OBSOLETE FUNCTIONS */
 
@@ -700,6 +704,7 @@ out:
 	kfree_skb(skb);
 	return NULL;
 }
+EXPORT_SYMBOL(arp_create);
 
 /*
  *	Send an arp packet.
@@ -709,6 +714,7 @@ void arp_xmit(struct sk_buff *skb)
 	/* Send it off, maybe filter it using firewalling first.  */
 	NF_HOOK(NFPROTO_ARP, NF_ARP_OUT, skb, NULL, skb->dev, dev_queue_xmit);
 }
+EXPORT_SYMBOL(arp_xmit);
 
 /*
  *	Create and send an arp packet.
@@ -735,6 +741,7 @@ void arp_send(int type, int ptype, __be32 dest_ip,
 
 	arp_xmit(skb);
 }
+EXPORT_SYMBOL(arp_send);
 
 /*
  *	Process an arp request.
@@ -1452,14 +1459,3 @@ static int __init arp_proc_init(void)
 }
 
 #endif /* CONFIG_PROC_FS */
-
-EXPORT_SYMBOL(arp_broken_ops);
-EXPORT_SYMBOL(arp_find);
-EXPORT_SYMBOL(arp_create);
-EXPORT_SYMBOL(arp_xmit);
-EXPORT_SYMBOL(arp_send);
-EXPORT_SYMBOL(arp_tbl);
-
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-EXPORT_SYMBOL(clip_tbl_hook);
-#endif
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index fe3daa7..f055094 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -72,6 +72,4 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk_dst_set(sk, &rt->dst);
 	return(0);
 }
-
 EXPORT_SYMBOL(ip4_datagram_connect);
-
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index e830f7a..a439689 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -175,6 +175,7 @@ out:
 	fib_res_put(&res);
 	return dev;
 }
+EXPORT_SYMBOL(ip_dev_find);
 
 /*
  * Find address type as if only "dev" was present in the system. If
@@ -214,12 +215,14 @@ unsigned int inet_addr_type(struct net *net, __be32 addr)
 {
 	return __inet_dev_addr_type(net, NULL, addr);
 }
+EXPORT_SYMBOL(inet_addr_type);
 
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr)
 {
        return __inet_dev_addr_type(net, dev, addr);
 }
+EXPORT_SYMBOL(inet_dev_addr_type);
 
 /* Given (packet source, input interface) and optional (dst, oif, tos):
    - (main) check, that source is valid i.e. not broadcast or our local
@@ -1077,7 +1080,3 @@ void __init ip_fib_init(void)
 
 	fib_hash_init();
 }
-
-EXPORT_SYMBOL(inet_addr_type);
-EXPORT_SYMBOL(inet_dev_addr_type);
-EXPORT_SYMBOL(ip_dev_find);
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 7569b21..a0d847c 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -181,6 +181,7 @@ const struct icmp_err icmp_err_convert[] = {
 		.fatal = 1,
 	},
 };
+EXPORT_SYMBOL(icmp_err_convert);
 
 /*
  *	ICMP control array. This specifies what to do with each ICMP.
@@ -267,6 +268,7 @@ int xrlim_allow(struct dst_entry *dst, int timeout)
 	dst->rate_tokens = token;
 	return rc;
 }
+EXPORT_SYMBOL(xrlim_allow);
 
 static inline int icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 		int type, int code)
@@ -647,6 +649,7 @@ out_unlock:
 	icmp_xmit_unlock(sk);
 out:;
 }
+EXPORT_SYMBOL(icmp_send);
 
 
 /*
@@ -1214,7 +1217,3 @@ int __init icmp_init(void)
 {
 	return register_pernet_subsys(&icmp_sk_ops);
 }
-
-EXPORT_SYMBOL(icmp_err_convert);
-EXPORT_SYMBOL(icmp_send);
-EXPORT_SYMBOL(xrlim_allow);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index b5580d4..a1ad0e7 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1244,6 +1244,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 out:
 	return;
 }
+EXPORT_SYMBOL(ip_mc_inc_group);
 
 /*
  *	Resend IGMP JOIN report; used for bonding.
@@ -1266,6 +1267,7 @@ void ip_mc_rejoin_group(struct ip_mc_list *im)
 	igmp_ifc_event(in_dev);
 #endif
 }
+EXPORT_SYMBOL(ip_mc_rejoin_group);
 
 /*
  *	A socket has left a multicast group on device dev
@@ -1296,6 +1298,7 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 		}
 	}
 }
+EXPORT_SYMBOL(ip_mc_dec_group);
 
 /* Device changing type */
 
@@ -1804,6 +1807,7 @@ done:
 	rtnl_unlock();
 	return err;
 }
+EXPORT_SYMBOL(ip_mc_join_group);
 
 static void ip_sf_socklist_reclaim(struct rcu_head *rp)
 {
@@ -2676,8 +2680,3 @@ int __init igmp_mc_proc_init(void)
 	return register_pernet_subsys(&igmp_net_ops);
 }
 #endif
-
-EXPORT_SYMBOL(ip_mc_dec_group);
-EXPORT_SYMBOL(ip_mc_inc_group);
-EXPORT_SYMBOL(ip_mc_join_group);
-EXPORT_SYMBOL(ip_mc_rejoin_group);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 57c9e4d..7174370 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -84,7 +84,6 @@ int inet_csk_bind_conflict(const struct sock *sk,
 	}
 	return node != NULL;
 }
-
 EXPORT_SYMBOL_GPL(inet_csk_bind_conflict);
 
 /* Obtain a reference to a local port for the given sock,
@@ -212,7 +211,6 @@ fail:
 	local_bh_enable();
 	return ret;
 }
-
 EXPORT_SYMBOL_GPL(inet_csk_get_port);
 
 /*
@@ -305,7 +303,6 @@ out_err:
 	*err = error;
 	goto out;
 }
-
 EXPORT_SYMBOL(inet_csk_accept);
 
 /*
@@ -327,7 +324,6 @@ void inet_csk_init_xmit_timers(struct sock *sk,
 	setup_timer(&sk->sk_timer, keepalive_handler, (unsigned long)sk);
 	icsk->icsk_pending = icsk->icsk_ack.pending = 0;
 }
-
 EXPORT_SYMBOL(inet_csk_init_xmit_timers);
 
 void inet_csk_clear_xmit_timers(struct sock *sk)
@@ -340,21 +336,18 @@ void inet_csk_clear_xmit_timers(struct sock *sk)
 	sk_stop_timer(sk, &icsk->icsk_delack_timer);
 	sk_stop_timer(sk, &sk->sk_timer);
 }
-
 EXPORT_SYMBOL(inet_csk_clear_xmit_timers);
 
 void inet_csk_delete_keepalive_timer(struct sock *sk)
 {
 	sk_stop_timer(sk, &sk->sk_timer);
 }
-
 EXPORT_SYMBOL(inet_csk_delete_keepalive_timer);
 
 void inet_csk_reset_keepalive_timer(struct sock *sk, unsigned long len)
 {
 	sk_reset_timer(sk, &sk->sk_timer, jiffies + len);
 }
-
 EXPORT_SYMBOL(inet_csk_reset_keepalive_timer);
 
 struct dst_entry *inet_csk_route_req(struct sock *sk,
@@ -391,7 +384,6 @@ no_route:
 	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
 	return NULL;
 }
-
 EXPORT_SYMBOL_GPL(inet_csk_route_req);
 
 static inline u32 inet_synq_hash(const __be32 raddr, const __be16 rport,
@@ -433,7 +425,6 @@ struct request_sock *inet_csk_search_req(const struct sock *sk,
 
 	return req;
 }
-
 EXPORT_SYMBOL_GPL(inet_csk_search_req);
 
 void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
@@ -447,11 +438,11 @@ void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 	reqsk_queue_hash_req(&icsk->icsk_accept_queue, h, req, timeout);
 	inet_csk_reqsk_queue_added(sk, timeout);
 }
+EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
 
 /* Only thing we need from tcp.h */
 extern int sysctl_tcp_synack_retries;
 
-EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
 
 /* Decide when to expire the request and when to resend SYN-ACK */
 static inline void syn_ack_recalc(struct request_sock *req, const int thresh,
@@ -569,7 +560,6 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 	if (lopt->qlen)
 		inet_csk_reset_keepalive_timer(parent, interval);
 }
-
 EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_prune);
 
 struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
@@ -599,7 +589,6 @@ struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
 	}
 	return newsk;
 }
-
 EXPORT_SYMBOL_GPL(inet_csk_clone);
 
 /*
@@ -630,7 +619,6 @@ void inet_csk_destroy_sock(struct sock *sk)
 	percpu_counter_dec(sk->sk_prot->orphan_count);
 	sock_put(sk);
 }
-
 EXPORT_SYMBOL(inet_csk_destroy_sock);
 
 int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
@@ -665,7 +653,6 @@ int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
 	__reqsk_queue_destroy(&icsk->icsk_accept_queue);
 	return -EADDRINUSE;
 }
-
 EXPORT_SYMBOL_GPL(inet_csk_listen_start);
 
 /*
@@ -720,7 +707,6 @@ void inet_csk_listen_stop(struct sock *sk)
 	}
 	WARN_ON(sk->sk_ack_backlog);
 }
-
 EXPORT_SYMBOL_GPL(inet_csk_listen_stop);
 
 void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
@@ -732,7 +718,6 @@ void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
 	sin->sin_addr.s_addr	= inet->inet_daddr;
 	sin->sin_port		= inet->inet_dport;
 }
-
 EXPORT_SYMBOL_GPL(inet_csk_addr2sockaddr);
 
 #ifdef CONFIG_COMPAT
@@ -747,7 +732,6 @@ int inet_csk_compat_getsockopt(struct sock *sk, int level, int optname,
 	return icsk->icsk_af_ops->getsockopt(sk, level, optname,
 					     optval, optlen);
 }
-
 EXPORT_SYMBOL_GPL(inet_csk_compat_getsockopt);
 
 int inet_csk_compat_setsockopt(struct sock *sk, int level, int optname,
@@ -761,6 +745,5 @@ int inet_csk_compat_setsockopt(struct sock *sk, int level, int optname,
 	return icsk->icsk_af_ops->setsockopt(sk, level, optname,
 					     optval, optlen);
 }
-
 EXPORT_SYMBOL_GPL(inet_csk_compat_setsockopt);
 #endif
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index a2ca6ae..5ff2a51 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -114,7 +114,6 @@ void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
 		fq->last_in |= INET_FRAG_COMPLETE;
 	}
 }
-
 EXPORT_SYMBOL(inet_frag_kill);
 
 static inline void frag_kfree_skb(struct netns_frags *nf, struct inet_frags *f,
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index d3e160a..fb7ad5a 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -99,7 +99,6 @@ void inet_put_port(struct sock *sk)
 	__inet_put_port(sk);
 	local_bh_enable();
 }
-
 EXPORT_SYMBOL(inet_put_port);
 
 void __inet_inherit_port(struct sock *sk, struct sock *child)
@@ -116,7 +115,6 @@ void __inet_inherit_port(struct sock *sk, struct sock *child)
 	inet_csk(child)->icsk_bind_hash = tb;
 	spin_unlock(&head->lock);
 }
-
 EXPORT_SYMBOL_GPL(__inet_inherit_port);
 
 static inline int compute_score(struct sock *sk, struct net *net,
@@ -546,7 +544,6 @@ int inet_hash_connect(struct inet_timewait_death_row *death_row,
 	return __inet_hash_connect(death_row, sk, inet_sk_port_offset(sk),
 			__inet_check_established, __inet_hash_nolisten);
 }
-
 EXPORT_SYMBOL_GPL(inet_hash_connect);
 
 void inet_hashinfo_init(struct inet_hashinfo *h)
@@ -560,5 +557,4 @@ void inet_hashinfo_init(struct inet_hashinfo *h)
 				      i + LISTENING_NULLS_BASE);
 		}
 }
-
 EXPORT_SYMBOL_GPL(inet_hashinfo_init);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index dd0dbf0..b7c4165 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -632,6 +632,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 	kfree_skb(skb);
 	return -ENOMEM;
 }
+EXPORT_SYMBOL(ip_defrag);
 
 #ifdef CONFIG_SYSCTL
 static int zero;
@@ -785,5 +786,3 @@ void __init ipfrag_init(void)
 	ip4_frags.secret_interval = 10 * 60 * HZ;
 	inet_frags_init(&ip4_frags);
 }
-
-EXPORT_SYMBOL(ip_defrag);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 663cb2a..6652bd9 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -89,6 +89,7 @@ __inline__ void ip_send_check(struct iphdr *iph)
 	iph->check = 0;
 	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 }
+EXPORT_SYMBOL(ip_send_check);
 
 int __ip_local_out(struct sk_buff *skb)
 {
@@ -172,7 +173,6 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 	/* Send it out. */
 	return ip_local_out(skb);
 }
-
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
 
 static inline int ip_finish_output2(struct sk_buff *skb)
@@ -403,6 +403,7 @@ no_route:
 	kfree_skb(skb);
 	return -EHOSTUNREACH;
 }
+EXPORT_SYMBOL(ip_queue_xmit);
 
 
 static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
@@ -696,7 +697,6 @@ fail:
 	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 	return err;
 }
-
 EXPORT_SYMBOL(ip_fragment);
 
 int
@@ -715,6 +715,7 @@ ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk
 	}
 	return 0;
 }
+EXPORT_SYMBOL(ip_generic_getfrag);
 
 static inline __wsum
 csum_page(struct page *page, int offset, int copy)
@@ -1447,7 +1448,3 @@ void __init ip_init(void)
 	igmp_mc_proc_init();
 #endif
 }
-
-EXPORT_SYMBOL(ip_generic_getfrag);
-EXPORT_SYMBOL(ip_queue_xmit);
-EXPORT_SYMBOL(ip_send_check);
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index f5f4a88..bbbd273 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -109,7 +109,7 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 		addr_type = RTN_LOCAL;
 
 	/* ip_route_me_harder expects skb->dst to be set */
-	skb_dst_set(nskb, dst_clone(skb_dst(oldskb)));
+	skb_dst_set_noref(nskb, skb_dst(oldskb));
 
 	if (ip_route_me_harder(nskb, addr_type))
 		goto free_nskb;
diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index 542f22f..f2d2973 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -52,6 +52,7 @@ int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 
 	return ret;
 }
+EXPORT_SYMBOL(inet_add_protocol);
 
 /*
  *	Remove a protocol from the hash tables.
@@ -76,6 +77,4 @@ int inet_del_protocol(const struct net_protocol *prot, unsigned char protocol)
 
 	return ret;
 }
-
-EXPORT_SYMBOL(inet_add_protocol);
 EXPORT_SYMBOL(inet_del_protocol);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 03430de..562ce92 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1324,6 +1324,7 @@ void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
 
 	ip_select_fb_ident(iph);
 }
+EXPORT_SYMBOL(__ip_select_ident);
 
 static void rt_del(unsigned hash, struct rtable *rt)
 {
@@ -2735,7 +2736,6 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 slow_output:
 	return ip_route_output_slow(net, rp, flp);
 }
-
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
 static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
@@ -2819,13 +2819,13 @@ int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
 
 	return 0;
 }
-
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
 int ip_route_output_key(struct net *net, struct rtable **rp, struct flowi *flp)
 {
 	return ip_route_output_flow(net, rp, flp, NULL, 0);
 }
+EXPORT_SYMBOL(ip_route_output_key);
 
 static int rt_fill_info(struct net *net,
 			struct sk_buff *skb, u32 pid, u32 seq, int event,
@@ -3363,6 +3363,3 @@ void __init ip_static_sysctl_init(void)
 	register_sysctl_paths(ipv4_path, ipv4_skeleton);
 }
 #endif
-
-EXPORT_SYMBOL(__ip_select_ident);
-EXPORT_SYMBOL(ip_route_output_key);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4e6ddfb..b8601b7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -315,7 +315,6 @@ struct tcp_splice_state {
  * is strict, actions are advisory and have some latency.
  */
 int tcp_memory_pressure __read_mostly;
-
 EXPORT_SYMBOL(tcp_memory_pressure);
 
 void tcp_enter_memory_pressure(struct sock *sk)
@@ -325,7 +324,6 @@ void tcp_enter_memory_pressure(struct sock *sk)
 		tcp_memory_pressure = 1;
 	}
 }
-
 EXPORT_SYMBOL(tcp_enter_memory_pressure);
 
 /* Convert seconds to retransmits based on initial and max timeout */
@@ -460,6 +458,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	}
 	return mask;
 }
+EXPORT_SYMBOL(tcp_poll);
 
 int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
@@ -508,6 +507,7 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 
 	return put_user(answ, (int __user *)arg);
 }
+EXPORT_SYMBOL(tcp_ioctl);
 
 static inline void tcp_mark_push(struct tcp_sock *tp, struct sk_buff *skb)
 {
@@ -675,6 +675,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 
 	return ret;
 }
+EXPORT_SYMBOL(tcp_splice_read);
 
 struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 {
@@ -873,6 +874,7 @@ ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
 	release_sock(sk);
 	return res;
 }
+EXPORT_SYMBOL(tcp_sendpage);
 
 #define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
 #define TCP_OFF(sk)	(sk->sk_sndmsg_off)
@@ -1121,6 +1123,7 @@ out_err:
 	release_sock(sk);
 	return err;
 }
+EXPORT_SYMBOL(tcp_sendmsg);
 
 /*
  *	Handle reading urgent data. BSD has very simple semantics for
@@ -1380,6 +1383,7 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 		tcp_cleanup_rbuf(sk, copied);
 	return copied;
 }
+EXPORT_SYMBOL(tcp_read_sock);
 
 /*
  *	This routine copies from a sock struct into the user buffer.
@@ -1774,6 +1778,7 @@ recv_urg:
 	err = tcp_recv_urg(sk, msg, len, flags);
 	goto out;
 }
+EXPORT_SYMBOL(tcp_recvmsg);
 
 void tcp_set_state(struct sock *sk, int state)
 {
@@ -1866,6 +1871,7 @@ void tcp_shutdown(struct sock *sk, int how)
 			tcp_send_fin(sk);
 	}
 }
+EXPORT_SYMBOL(tcp_shutdown);
 
 void tcp_close(struct sock *sk, long timeout)
 {
@@ -2029,6 +2035,7 @@ out:
 	local_bh_enable();
 	sock_put(sk);
 }
+EXPORT_SYMBOL(tcp_close);
 
 /* These states need RST on ABORT according to RFC793 */
 
@@ -2102,6 +2109,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 	sk->sk_error_report(sk);
 	return err;
 }
+EXPORT_SYMBOL(tcp_disconnect);
 
 /*
  *	Socket option code for TCP.
@@ -2400,6 +2408,7 @@ int tcp_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
 						     optval, optlen);
 	return do_tcp_setsockopt(sk, level, optname, optval, optlen);
 }
+EXPORT_SYMBOL(tcp_setsockopt);
 
 #ifdef CONFIG_COMPAT
 int compat_tcp_setsockopt(struct sock *sk, int level, int optname,
@@ -2410,7 +2419,6 @@ int compat_tcp_setsockopt(struct sock *sk, int level, int optname,
 						  optval, optlen);
 	return do_tcp_setsockopt(sk, level, optname, optval, optlen);
 }
-
 EXPORT_SYMBOL(compat_tcp_setsockopt);
 #endif
 
@@ -2476,7 +2484,6 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 
 	info->tcpi_total_retrans = tp->total_retrans;
 }
-
 EXPORT_SYMBOL_GPL(tcp_get_info);
 
 static int do_tcp_getsockopt(struct sock *sk, int level,
@@ -2615,6 +2622,7 @@ int tcp_getsockopt(struct sock *sk, int level, int optname, char __user *optval,
 						     optval, optlen);
 	return do_tcp_getsockopt(sk, level, optname, optval, optlen);
 }
+EXPORT_SYMBOL(tcp_getsockopt);
 
 #ifdef CONFIG_COMPAT
 int compat_tcp_getsockopt(struct sock *sk, int level, int optname,
@@ -2625,7 +2633,6 @@ int compat_tcp_getsockopt(struct sock *sk, int level, int optname,
 						  optval, optlen);
 	return do_tcp_getsockopt(sk, level, optname, optval, optlen);
 }
-
 EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
 
@@ -2862,7 +2869,6 @@ void tcp_free_md5sig_pool(void)
 	if (pool)
 		__tcp_free_md5sig_pool(pool);
 }
-
 EXPORT_SYMBOL(tcp_free_md5sig_pool);
 
 static struct tcp_md5sig_pool * __percpu *
@@ -2938,7 +2944,6 @@ retry:
 	}
 	return pool;
 }
-
 EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
 
 
@@ -2990,7 +2995,6 @@ int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
 	th->check = old_checksum;
 	return err;
 }
-
 EXPORT_SYMBOL(tcp_md5_hash_header);
 
 int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
@@ -3024,7 +3028,6 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 
 	return 0;
 }
-
 EXPORT_SYMBOL(tcp_md5_hash_skb_data);
 
 int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, struct tcp_md5sig_key *key)
@@ -3034,7 +3037,6 @@ int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, struct tcp_md5sig_key *key)
 	sg_init_one(&sg, key->key, key->keylen);
 	return crypto_hash_update(&hp->md5_desc, &sg, key->keylen);
 }
-
 EXPORT_SYMBOL(tcp_md5_hash_key);
 
 #endif
@@ -3306,16 +3308,3 @@ void __init tcp_init(void)
 	tcp_secret_retiring = &tcp_secret_two;
 	tcp_secret_secondary = &tcp_secret_two;
 }
-
-EXPORT_SYMBOL(tcp_close);
-EXPORT_SYMBOL(tcp_disconnect);
-EXPORT_SYMBOL(tcp_getsockopt);
-EXPORT_SYMBOL(tcp_ioctl);
-EXPORT_SYMBOL(tcp_poll);
-EXPORT_SYMBOL(tcp_read_sock);
-EXPORT_SYMBOL(tcp_recvmsg);
-EXPORT_SYMBOL(tcp_sendmsg);
-EXPORT_SYMBOL(tcp_splice_read);
-EXPORT_SYMBOL(tcp_sendpage);
-EXPORT_SYMBOL(tcp_setsockopt);
-EXPORT_SYMBOL(tcp_shutdown);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0433466..3c426cb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -78,10 +78,13 @@ int sysctl_tcp_window_scaling __read_mostly = 1;
 int sysctl_tcp_sack __read_mostly = 1;
 int sysctl_tcp_fack __read_mostly = 1;
 int sysctl_tcp_reordering __read_mostly = TCP_FASTRETRANS_THRESH;
+EXPORT_SYMBOL(sysctl_tcp_reordering);
 int sysctl_tcp_ecn __read_mostly = 2;
+EXPORT_SYMBOL(sysctl_tcp_ecn);
 int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
 int sysctl_tcp_adv_win_scale __read_mostly = 2;
+EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 
 int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
@@ -419,6 +422,7 @@ void tcp_initialize_rcv_mss(struct sock *sk)
 
 	inet_csk(sk)->icsk_ack.rcv_mss = hint;
 }
+EXPORT_SYMBOL(tcp_initialize_rcv_mss);
 
 /* Receiver "autotuning" code.
  *
@@ -2938,6 +2942,7 @@ void tcp_simple_retransmit(struct sock *sk)
 	}
 	tcp_xmit_retransmit_queue(sk);
 }
+EXPORT_SYMBOL(tcp_simple_retransmit);
 
 /* Process an event, which can update packets-in-flight not trivially.
  * Main goal of this function is to calculate new estimate for left_out,
@@ -3858,6 +3863,7 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 		}
 	}
 }
+EXPORT_SYMBOL(tcp_parse_options);
 
 static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcphdr *th)
 {
@@ -3931,6 +3937,7 @@ u8 *tcp_parse_md5sig_option(struct tcphdr *th)
 	}
 	return NULL;
 }
+EXPORT_SYMBOL(tcp_parse_md5sig_option);
 #endif
 
 static inline void tcp_store_ts_recent(struct tcp_sock *tp)
@@ -5432,6 +5439,7 @@ discard:
 	__kfree_skb(skb);
 	return 0;
 }
+EXPORT_SYMBOL(tcp_rcv_established);
 
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 struct tcphdr *th, unsigned len)
@@ -5931,14 +5939,4 @@ discard:
 	}
 	return 0;
 }
-
-EXPORT_SYMBOL(sysctl_tcp_ecn);
-EXPORT_SYMBOL(sysctl_tcp_reordering);
-EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
-EXPORT_SYMBOL(tcp_parse_options);
-#ifdef CONFIG_TCP_MD5SIG
-EXPORT_SYMBOL(tcp_parse_md5sig_option);
-#endif
-EXPORT_SYMBOL(tcp_rcv_established);
 EXPORT_SYMBOL(tcp_rcv_state_process);
-EXPORT_SYMBOL(tcp_initialize_rcv_mss);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8fa32f5..44545e8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -84,6 +84,7 @@
 
 int sysctl_tcp_tw_reuse __read_mostly;
 int sysctl_tcp_low_latency __read_mostly;
+EXPORT_SYMBOL(sysctl_tcp_low_latency);
 
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -100,6 +101,7 @@ struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
 #endif
 
 struct inet_hashinfo tcp_hashinfo;
+EXPORT_SYMBOL(tcp_hashinfo);
 
 static inline __u32 tcp_v4_init_sequence(struct sk_buff *skb)
 {
@@ -139,7 +141,6 @@ int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
 
 	return 0;
 }
-
 EXPORT_SYMBOL_GPL(tcp_twsk_unique);
 
 /* This will initiate an outgoing connection. */
@@ -267,6 +268,7 @@ failure:
 	inet->inet_dport = 0;
 	return err;
 }
+EXPORT_SYMBOL(tcp_v4_connect);
 
 /*
  * This routine does path mtu discovery as defined in RFC1191.
@@ -545,6 +547,7 @@ void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb)
 
 	__tcp_v4_send_check(skb, inet->inet_saddr, inet->inet_daddr);
 }
+EXPORT_SYMBOL(tcp_v4_send_check);
 
 int tcp_v4_gso_send_check(struct sk_buff *skb)
 {
@@ -860,7 +863,6 @@ struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
 {
 	return tcp_v4_md5_do_lookup(sk, inet_sk(addr_sk)->inet_daddr);
 }
-
 EXPORT_SYMBOL(tcp_v4_md5_lookup);
 
 static struct tcp_md5sig_key *tcp_v4_reqsk_md5_lookup(struct sock *sk,
@@ -927,7 +929,6 @@ int tcp_v4_md5_do_add(struct sock *sk, __be32 addr,
 	}
 	return 0;
 }
-
 EXPORT_SYMBOL(tcp_v4_md5_do_add);
 
 static int tcp_v4_md5_add_func(struct sock *sk, struct sock *addr_sk,
@@ -965,7 +966,6 @@ int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
 	}
 	return -ENOENT;
 }
-
 EXPORT_SYMBOL(tcp_v4_md5_do_del);
 
 static void tcp_v4_clear_md5_list(struct sock *sk)
@@ -1138,7 +1138,6 @@ clear_hash_noput:
 	memset(md5_hash, 0, 16);
 	return 1;
 }
-
 EXPORT_SYMBOL(tcp_v4_md5_hash_skb);
 
 static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
@@ -1396,6 +1395,7 @@ drop_and_free:
 drop:
 	return 0;
 }
+EXPORT_SYMBOL(tcp_v4_conn_request);
 
 
 /*
@@ -1481,6 +1481,7 @@ exit:
 	dst_release(dst);
 	return NULL;
 }
+EXPORT_SYMBOL(tcp_v4_syn_recv_sock);
 
 static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 {
@@ -1610,6 +1611,7 @@ csum_err:
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 	goto discard;
 }
+EXPORT_SYMBOL(tcp_v4_do_rcv);
 
 /*
  *	From tcp_input.c
@@ -1796,6 +1798,7 @@ int tcp_v4_remember_stamp(struct sock *sk)
 
 	return 0;
 }
+EXPORT_SYMBOL(tcp_v4_remember_stamp);
 
 int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw)
 {
@@ -1835,6 +1838,7 @@ const struct inet_connection_sock_af_ops ipv4_specific = {
 	.compat_getsockopt = compat_ip_getsockopt,
 #endif
 };
+EXPORT_SYMBOL(ipv4_specific);
 
 #ifdef CONFIG_TCP_MD5SIG
 static const struct tcp_sock_af_ops tcp_sock_ipv4_specific = {
@@ -1963,7 +1967,6 @@ void tcp_v4_destroy_sock(struct sock *sk)
 
 	percpu_counter_dec(&tcp_sockets_allocated);
 }
-
 EXPORT_SYMBOL(tcp_v4_destroy_sock);
 
 #ifdef CONFIG_PROC_FS
@@ -2367,11 +2370,13 @@ int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 		rc = -ENOMEM;
 	return rc;
 }
+EXPORT_SYMBOL(tcp_proc_register);
 
 void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo)
 {
 	proc_net_remove(net, afinfo->name);
 }
+EXPORT_SYMBOL(tcp_proc_unregister);
 
 static void get_openreq4(struct sock *sk, struct request_sock *req,
 			 struct seq_file *f, int i, int uid, int *len)
@@ -2618,6 +2623,7 @@ struct proto tcp_prot = {
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
 };
+EXPORT_SYMBOL(tcp_prot);
 
 
 static int __net_init tcp_sk_init(struct net *net)
@@ -2648,20 +2654,3 @@ void __init tcp_v4_init(void)
 	if (register_pernet_subsys(&tcp_sk_ops))
 		panic("Failed to create the TCP control socket.\n");
 }
-
-EXPORT_SYMBOL(ipv4_specific);
-EXPORT_SYMBOL(tcp_hashinfo);
-EXPORT_SYMBOL(tcp_prot);
-EXPORT_SYMBOL(tcp_v4_conn_request);
-EXPORT_SYMBOL(tcp_v4_connect);
-EXPORT_SYMBOL(tcp_v4_do_rcv);
-EXPORT_SYMBOL(tcp_v4_remember_stamp);
-EXPORT_SYMBOL(tcp_v4_send_check);
-EXPORT_SYMBOL(tcp_v4_syn_recv_sock);
-
-#ifdef CONFIG_PROC_FS
-EXPORT_SYMBOL(tcp_proc_register);
-EXPORT_SYMBOL(tcp_proc_unregister);
-#endif
-EXPORT_SYMBOL(sysctl_tcp_low_latency);
-
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 794c2e1..f25b56c 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -47,7 +47,6 @@ struct inet_timewait_death_row tcp_death_row = {
 	.twcal_timer	= TIMER_INITIALIZER(inet_twdr_twcal_tick, 0,
 					    (unsigned long)&tcp_death_row),
 };
-
 EXPORT_SYMBOL_GPL(tcp_death_row);
 
 static __inline__ int tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
@@ -262,6 +261,7 @@ kill:
 	inet_twsk_put(tw);
 	return TCP_TW_SUCCESS;
 }
+EXPORT_SYMBOL(tcp_timewait_state_process);
 
 /*
  * Move a socket to time-wait or dead fin-wait-2 state.
@@ -362,7 +362,6 @@ void tcp_twsk_destructor(struct sock *sk)
 		tcp_free_md5sig_pool();
 #endif
 }
-
 EXPORT_SYMBOL_GPL(tcp_twsk_destructor);
 
 static inline void TCP_ECN_openreq_child(struct tcp_sock *tp,
@@ -510,6 +509,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 	}
 	return newsk;
 }
+EXPORT_SYMBOL(tcp_create_openreq_child);
 
 /*
  *	Process an incoming packet for SYN_RECV sockets represented
@@ -706,6 +706,7 @@ embryonic_reset:
 	inet_csk_reqsk_queue_drop(sk, req, prev);
 	return NULL;
 }
+EXPORT_SYMBOL(tcp_check_req);
 
 /*
  * Queue segment on the new socket if the new socket is active,
@@ -737,8 +738,4 @@ int tcp_child_process(struct sock *parent, struct sock *child,
 	sock_put(child);
 	return ret;
 }
-
-EXPORT_SYMBOL(tcp_check_req);
 EXPORT_SYMBOL(tcp_child_process);
-EXPORT_SYMBOL(tcp_create_openreq_child);
-EXPORT_SYMBOL(tcp_timewait_state_process);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 25ff62e..b3f6f09 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -247,6 +247,7 @@ void tcp_select_initial_window(int __space, __u32 mss,
 	/* Set the clamp no higher than max representable value */
 	(*window_clamp) = min(65535U << (*rcv_wscale), *window_clamp);
 }
+EXPORT_SYMBOL(tcp_select_initial_window);
 
 /* Chose a new window to advertise, update state in tcp_sock for the
  * socket, and return result with RFC1323 scaling applied.  The return
@@ -1189,6 +1190,7 @@ void tcp_mtup_init(struct sock *sk)
 	icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, sysctl_tcp_base_mss);
 	icsk->icsk_mtup.probe_size = 0;
 }
+EXPORT_SYMBOL(tcp_mtup_init);
 
 /* This function synchronize snd mss to current pmtu/exthdr set.
 
@@ -1232,6 +1234,7 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu)
 
 	return mss_now;
 }
+EXPORT_SYMBOL(tcp_sync_mss);
 
 /* Compute the current effective MSS, taking SACKs and IP options,
  * and even PMTU discovery events into account.
@@ -2514,6 +2517,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	return skb;
 }
+EXPORT_SYMBOL(tcp_make_synack);
 
 /* Do all connect socket setups that can be done AF independent. */
 static void tcp_connect_init(struct sock *sk)
@@ -2616,6 +2620,7 @@ int tcp_connect(struct sock *sk)
 				  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
 	return 0;
 }
+EXPORT_SYMBOL(tcp_connect);
 
 /* Send out a delayed ack, the caller does the policy checking
  * to see if we should even be here.  See tcp_input.c:tcp_ack_snd_check()
@@ -2820,10 +2825,3 @@ void tcp_send_probe0(struct sock *sk)
 					  TCP_RTO_MAX);
 	}
 }
-
-EXPORT_SYMBOL(tcp_select_initial_window);
-EXPORT_SYMBOL(tcp_connect);
-EXPORT_SYMBOL(tcp_make_synack);
-EXPORT_SYMBOL(tcp_simple_retransmit);
-EXPORT_SYMBOL(tcp_sync_mss);
-EXPORT_SYMBOL(tcp_mtup_init);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 440a5c6..808bb92 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -41,7 +41,6 @@ void tcp_init_xmit_timers(struct sock *sk)
 	inet_csk_init_xmit_timers(sk, &tcp_write_timer, &tcp_delack_timer,
 				  &tcp_keepalive_timer);
 }
-
 EXPORT_SYMBOL(tcp_init_xmit_timers);
 
 static void tcp_write_err(struct sock *sk)
diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 3b3813c..59186ca 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -48,7 +48,6 @@ err:
 
 	return ret;
 }
-
 EXPORT_SYMBOL(xfrm4_tunnel_register);
 
 int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family)
@@ -72,7 +71,6 @@ int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family)
 
 	return ret;
 }
-
 EXPORT_SYMBOL(xfrm4_tunnel_deregister);
 
 static int tunnel4_rcv(struct sk_buff *skb)
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 6610bf7..ab76aa9 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -58,6 +58,7 @@ struct proto 	udplite_prot = {
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
 };
+EXPORT_SYMBOL(udplite_prot);
 
 static struct inet_protosw udplite4_protosw = {
 	.type		=  SOCK_DGRAM,
@@ -127,5 +128,3 @@ out_unregister_proto:
 out_register_err:
 	printk(KERN_CRIT "%s: Cannot add UDP-Lite protocol.\n", __func__);
 }
-
-EXPORT_SYMBOL(udplite_prot);
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index ad8fbb8..06814b6 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -163,5 +163,4 @@ int xfrm4_rcv(struct sk_buff *skb)
 {
 	return xfrm4_rcv_spi(skb, ip_hdr(skb)->protocol, 0);
 }
-
 EXPORT_SYMBOL(xfrm4_rcv);


