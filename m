From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] inet: constify ip headers and in6_addr
Date: Fri, 22 Apr 2011 16:53:02 +0200
Message-ID: <1303483982.3134.131.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64614 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755407Ab1DVOxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 10:53:09 -0400
Received: by wya21 with SMTP id 21so470865wya.19
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2011 07:53:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add const qualifiers to structs iphdr, ipv6hdr and in6_addr pointers
where possible, to make code intention more obvious.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/addrconf.h             |   22 +++++------
 include/net/if_inet6.h             |    4 +-
 include/net/inetpeer.h             |    2 -
 include/net/ip6_fib.h              |    8 ++--
 include/net/ip6_route.h            |   18 ++++-----
 include/net/ipv6.h                 |    4 +-
 include/net/ndisc.h                |    3 +
 include/net/route.h                |    3 +
 include/net/xfrm.h                 |    6 +--
 net/bridge/br_multicast.c          |   12 +++---
 net/bridge/br_netfilter.c          |    4 +-
 net/core/dev.c                     |    8 ++--
 net/core/netpoll.c                 |    2 -
 net/dccp/ipv6.c                    |    8 ++--
 net/ipv4/af_inet.c                 |    4 +-
 net/ipv4/ah4.c                     |    7 ++-
 net/ipv4/esp4.c                    |    7 ++-
 net/ipv4/icmp.c                    |   12 +++---
 net/ipv4/inet_diag.c               |    2 -
 net/ipv4/inet_lro.c                |    4 +-
 net/ipv4/ip_gre.c                  |   28 +++++++-------
 net/ipv4/ip_input.c                |    4 +-
 net/ipv4/ip_sockglue.c             |    2 -
 net/ipv4/ipcomp.c                  |    4 +-
 net/ipv4/ipip.c                    |    8 ++--
 net/ipv4/ipmr.c                    |    2 -
 net/ipv4/netfilter/nf_nat_helper.c |    2 -
 net/ipv4/raw.c                     |   10 ++---
 net/ipv4/route.c                   |    2 -
 net/ipv4/tcp_ipv4.c                |    8 ++--
 net/ipv4/udp.c                     |    2 -
 net/ipv4/xfrm4_policy.c            |    2 -
 net/ipv4/xfrm4_state.c             |    2 -
 net/ipv6/addrconf.c                |   16 ++++----
 net/ipv6/af_inet6.c                |    2 -
 net/ipv6/anycast.c                 |   16 ++++----
 net/ipv6/esp6.c                    |    5 +-
 net/ipv6/icmp.c                    |    8 ++--
 net/ipv6/ip6_fib.c                 |   16 ++++----
 net/ipv6/ip6_input.c               |    6 +--
 net/ipv6/ip6_output.c              |    8 ++--
 net/ipv6/ip6_tunnel.c              |   36 +++++++++---------
 net/ipv6/ip6mr.c                   |    4 +-
 net/ipv6/ipcomp6.c                 |    5 +-
 net/ipv6/mcast.c                   |   36 +++++++++---------
 net/ipv6/mip6.c                    |    8 ++--
 net/ipv6/ndisc.c                   |   18 ++++-----
 net/ipv6/netfilter.c               |   10 ++---
 net/ipv6/raw.c                     |   14 +++----
 net/ipv6/reassembly.c              |    4 +-
 net/ipv6/route.c                   |   52 +++++++++++++--------------
 net/ipv6/sit.c                     |   25 ++++++------
 net/ipv6/syncookies.c              |   13 +++---
 net/ipv6/tcp_ipv6.c                |   48 ++++++++++++------------
 net/ipv6/udp.c                     |   20 +++++-----
 net/ipv6/xfrm6_mode_beet.c         |    2 -
 net/ipv6/xfrm6_mode_tunnel.c       |    6 +--
 net/ipv6/xfrm6_policy.c            |    2 -
 net/ipv6/xfrm6_tunnel.c            |   10 ++---
 net/key/af_key.c                   |    2 -
 net/sched/sch_sfq.c                |    2 -
 net/sctp/input.c                   |    2 -
 net/sctp/ipv6.c                    |    2 -
 net/xfrm/xfrm_state.c              |   12 +++---
 64 files changed, 316 insertions(+), 310 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 23710aa..7c4d92c 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -61,16 +61,16 @@ extern int			addrconf_set_dstaddr(struct net *net,
 						     void __user *arg);
 
 extern int			ipv6_chk_addr(struct net *net,
-					      struct in6_addr *addr,
+					      const struct in6_addr *addr,
 					      struct net_device *dev,
 					      int strict);
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 extern int			ipv6_chk_home_addr(struct net *net,
-						   struct in6_addr *addr);
+						   const struct in6_addr *addr);
 #endif
 
-extern int			ipv6_chk_prefix(struct in6_addr *addr,
+extern int			ipv6_chk_prefix(const struct in6_addr *addr,
 						struct net_device *dev);
 
 extern struct inet6_ifaddr      *ipv6_get_ifaddr(struct net *net,
@@ -89,9 +89,9 @@ extern int			ipv6_get_lladdr(struct net_device *dev,
 extern int 			ipv6_rcv_saddr_equal(const struct sock *sk,
 						    const struct sock *sk2);
 extern void			addrconf_join_solict(struct net_device *dev,
-					struct in6_addr *addr);
+					const struct in6_addr *addr);
 extern void			addrconf_leave_solict(struct inet6_dev *idev,
-					struct in6_addr *addr);
+					const struct in6_addr *addr);
 
 static inline unsigned long addrconf_timeout_fixup(u32 timeout,
 						    unsigned unit)
@@ -158,15 +158,15 @@ extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);
 /*
  *	anycast prototypes (anycast.c)
  */
-extern int ipv6_sock_ac_join(struct sock *sk,int ifindex,struct in6_addr *addr);
-extern int ipv6_sock_ac_drop(struct sock *sk,int ifindex,struct in6_addr *addr);
+extern int ipv6_sock_ac_join(struct sock *sk,int ifindex, const struct in6_addr *addr);
+extern int ipv6_sock_ac_drop(struct sock *sk,int ifindex, const struct in6_addr *addr);
 extern void ipv6_sock_ac_close(struct sock *sk);
-extern int inet6_ac_check(struct sock *sk, struct in6_addr *addr, int ifindex);
+extern int inet6_ac_check(struct sock *sk, const struct in6_addr *addr, int ifindex);
 
-extern int ipv6_dev_ac_inc(struct net_device *dev, struct in6_addr *addr);
-extern int __ipv6_dev_ac_dec(struct inet6_dev *idev, struct in6_addr *addr);
+extern int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr);
+extern int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
 extern int ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
-			       struct in6_addr *addr);
+			       const struct in6_addr *addr);
 
 
 /* Device notifier */
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index fccc218..3d982f7 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -196,7 +196,7 @@ struct inet6_dev {
 	struct rcu_head		rcu;
 };
 
-static inline void ipv6_eth_mc_map(struct in6_addr *addr, char *buf)
+static inline void ipv6_eth_mc_map(const struct in6_addr *addr, char *buf)
 {
 	/*
 	 *	+-------+-------+-------+-------+-------+-------+
@@ -210,7 +210,7 @@ static inline void ipv6_eth_mc_map(struct in6_addr *addr, char *buf)
 	memcpy(buf + 2, &addr->s6_addr32[3], sizeof(__u32));
 }
 
-static inline void ipv6_tr_mc_map(struct in6_addr *addr, char *buf)
+static inline void ipv6_tr_mc_map(const struct in6_addr *addr, char *buf)
 {
 	/* All nodes FF01::1, FF02::1, FF02::1:FFxx:xxxx */
 
diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index e6dd8da..8a159cc 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -80,7 +80,7 @@ static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
 	return inet_getpeer(&daddr, create);
 }
 
-static inline struct inet_peer *inet_getpeer_v6(struct in6_addr *v6daddr, int create)
+static inline struct inet_peer *inet_getpeer_v6(const struct in6_addr *v6daddr, int create)
 {
 	struct inetpeer_addr daddr;
 
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 98348d5..aca8ef4 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -198,12 +198,12 @@ extern struct dst_entry         *fib6_rule_lookup(struct net *net,
 						  pol_lookup_t lookup);
 
 extern struct fib6_node		*fib6_lookup(struct fib6_node *root,
-					     struct in6_addr *daddr,
-					     struct in6_addr *saddr);
+					     const struct in6_addr *daddr,
+					     const struct in6_addr *saddr);
 
 struct fib6_node		*fib6_locate(struct fib6_node *root,
-					     struct in6_addr *daddr, int dst_len,
-					     struct in6_addr *saddr, int src_len);
+					     const struct in6_addr *daddr, int dst_len,
+					     const struct in6_addr *saddr, int src_len);
 
 extern void			fib6_clean_all(struct net *net,
 					       int (*func)(struct rt6_info *, void *arg),
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 86b1cb4..d5c21d4 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -86,7 +86,7 @@ extern int			ip6_del_rt(struct rt6_info *);
 
 extern int			ip6_route_get_saddr(struct net *net,
 						    struct rt6_info *rt,
-						    struct in6_addr *daddr,
+						    const struct in6_addr *daddr,
 						    unsigned int prefs,
 						    struct in6_addr *saddr);
 
@@ -112,9 +112,9 @@ extern int			ip6_dst_hoplimit(struct dst_entry *dst);
  *	support functions for ND
  *
  */
-extern struct rt6_info *	rt6_get_dflt_router(struct in6_addr *addr,
+extern struct rt6_info *	rt6_get_dflt_router(const struct in6_addr *addr,
 						    struct net_device *dev);
-extern struct rt6_info *	rt6_add_dflt_router(struct in6_addr *gwaddr,
+extern struct rt6_info *	rt6_add_dflt_router(const struct in6_addr *gwaddr,
 						    struct net_device *dev,
 						    unsigned int pref);
 
@@ -122,17 +122,17 @@ extern void			rt6_purge_dflt_routers(struct net *net);
 
 extern int			rt6_route_rcv(struct net_device *dev,
 					      u8 *opt, int len,
-					      struct in6_addr *gwaddr);
+					      const struct in6_addr *gwaddr);
 
-extern void			rt6_redirect(struct in6_addr *dest,
-					     struct in6_addr *src,
-					     struct in6_addr *saddr,
+extern void			rt6_redirect(const struct in6_addr *dest,
+					     const struct in6_addr *src,
+					     const struct in6_addr *saddr,
 					     struct neighbour *neigh,
 					     u8 *lladdr,
 					     int on_link);
 
-extern void			rt6_pmtu_discovery(struct in6_addr *daddr,
-						   struct in6_addr *saddr,
+extern void			rt6_pmtu_discovery(const struct in6_addr *daddr,
+						   const struct in6_addr *saddr,
 						   struct net_device *dev,
 						   u32 pmtu);
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 34200f9..5da1926 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -376,8 +376,8 @@ enum ip6_defrag_users {
 struct ip6_create_arg {
 	__be32 id;
 	u32 user;
-	struct in6_addr *src;
-	struct in6_addr *dst;
+	const struct in6_addr *src;
+	const struct in6_addr *dst;
 };
 
 void ip6_frag_init(struct inet_frag_queue *q, void *a);
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index e0e594f..6144685 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -102,7 +102,8 @@ extern void			ndisc_send_redirect(struct sk_buff *skb,
 						    struct neighbour *neigh,
 						    const struct in6_addr *target);
 
-extern int			ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *dev, int dir);
+extern int			ndisc_mc_map(const struct in6_addr *addr, char *buf,
+					     struct net_device *dev, int dir);
 
 extern struct sk_buff		*ndisc_build_skb(struct net_device *dev,
 						 const struct in6_addr *daddr,
diff --git a/include/net/route.h b/include/net/route.h
index 3782cdd..b3962e2 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -191,7 +191,8 @@ static inline int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 s
 	return ip_route_input_common(skb, dst, src, tos, devin, true);
 }
 
-extern unsigned short	ip_rt_frag_needed(struct net *net, struct iphdr *iph, unsigned short new_mtu, struct net_device *dev);
+extern unsigned short	ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
+					  unsigned short new_mtu, struct net_device *dev);
 extern void		ip_rt_send_redirect(struct sk_buff *skb);
 
 extern unsigned		inet_addr_type(struct net *net, __be32 addr);
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 65ea313..1cdd4b7 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1475,7 +1475,7 @@ extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family);
 extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family);
 extern __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr);
-extern __be32 xfrm6_tunnel_spi_lookup(struct net *net, xfrm_address_t *saddr);
+extern __be32 xfrm6_tunnel_spi_lookup(struct net *net, const xfrm_address_t *saddr);
 extern int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_output(struct sk_buff *skb);
@@ -1569,8 +1569,8 @@ static inline int xfrm_addr_cmp(const xfrm_address_t *a,
 	case AF_INET:
 		return (__force u32)a->a4 - (__force u32)b->a4;
 	case AF_INET6:
-		return ipv6_addr_cmp((struct in6_addr *)a,
-				     (struct in6_addr *)b);
+		return ipv6_addr_cmp((const struct in6_addr *)a,
+				     (const struct in6_addr *)b);
 	}
 }
 
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 59660c9..2f14eaf 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -413,7 +413,7 @@ out:
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
-						    struct in6_addr *group)
+						    const struct in6_addr *group)
 {
 	struct sk_buff *skb;
 	struct ipv6hdr *ip6h;
@@ -1115,7 +1115,7 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 				  struct net_bridge_port *port,
 				  struct sk_buff *skb)
 {
-	struct iphdr *iph = ip_hdr(skb);
+	const struct iphdr *iph = ip_hdr(skb);
 	struct igmphdr *ih = igmp_hdr(skb);
 	struct net_bridge_mdb_entry *mp;
 	struct igmpv3_query *ih3;
@@ -1190,7 +1190,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 				  struct net_bridge_port *port,
 				  struct sk_buff *skb)
 {
-	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct mld_msg *mld = (struct mld_msg *) icmp6_hdr(skb);
 	struct net_bridge_mdb_entry *mp;
 	struct mld2_query *mld2q;
@@ -1198,7 +1198,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	struct net_bridge_port_group __rcu **pp;
 	unsigned long max_delay;
 	unsigned long now = jiffies;
-	struct in6_addr *group = NULL;
+	const struct in6_addr *group = NULL;
 	int err = 0;
 
 	spin_lock(&br->multicast_lock);
@@ -1356,7 +1356,7 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 struct sk_buff *skb)
 {
 	struct sk_buff *skb2 = skb;
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	struct igmphdr *ih;
 	unsigned len;
 	unsigned offset;
@@ -1452,7 +1452,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 				 struct sk_buff *skb)
 {
 	struct sk_buff *skb2;
-	struct ipv6hdr *ip6h;
+	const struct ipv6hdr *ip6h;
 	struct icmp6hdr *icmp6h;
 	u8 nexthdr;
 	unsigned len;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index f3bc322..5614907 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -219,7 +219,7 @@ static inline void nf_bridge_update_protocol(struct sk_buff *skb)
 static int br_parse_ip_options(struct sk_buff *skb)
 {
 	struct ip_options *opt;
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	struct net_device *dev = skb->dev;
 	u32 len;
 
@@ -554,7 +554,7 @@ static unsigned int br_nf_pre_routing_ipv6(unsigned int hook,
 					   const struct net_device *out,
 					   int (*okfn)(struct sk_buff *))
 {
-	struct ipv6hdr *hdr;
+	const struct ipv6hdr *hdr;
 	u32 pkt_len;
 
 	if (skb->len < sizeof(struct ipv6hdr))
diff --git a/net/core/dev.c b/net/core/dev.c
index 3871bf6..379c993 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2502,8 +2502,8 @@ static inline void ____napi_schedule(struct softnet_data *sd,
 __u32 __skb_get_rxhash(struct sk_buff *skb)
 {
 	int nhoff, hash = 0, poff;
-	struct ipv6hdr *ip6;
-	struct iphdr *ip;
+	const struct ipv6hdr *ip6;
+	const struct iphdr *ip;
 	u8 ip_proto;
 	u32 addr1, addr2, ihl;
 	union {
@@ -2518,7 +2518,7 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 		if (!pskb_may_pull(skb, sizeof(*ip) + nhoff))
 			goto done;
 
-		ip = (struct iphdr *) (skb->data + nhoff);
+		ip = (const struct iphdr *) (skb->data + nhoff);
 		if (ip->frag_off & htons(IP_MF | IP_OFFSET))
 			ip_proto = 0;
 		else
@@ -2531,7 +2531,7 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 		if (!pskb_may_pull(skb, sizeof(*ip6) + nhoff))
 			goto done;
 
-		ip6 = (struct ipv6hdr *) (skb->data + nhoff);
+		ip6 = (const struct ipv6hdr *) (skb->data + nhoff);
 		ip_proto = ip6->nexthdr;
 		addr1 = (__force u32) ip6->saddr.s6_addr32[3];
 		addr2 = (__force u32) ip6->daddr.s6_addr32[3];
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 06be243..46d9c3a 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -539,7 +539,7 @@ int __netpoll_rx(struct sk_buff *skb)
 {
 	int proto, len, ulen;
 	int hits = 0;
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	struct udphdr *uh;
 	struct netpoll_info *npinfo = skb->dev->npinfo;
 	struct netpoll *np, *tmp;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index de1b7e3..73add23 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -54,8 +54,8 @@ static void dccp_v6_hash(struct sock *sk)
 
 /* add pseudo-header to DCCP checksum stored in skb->csum */
 static inline __sum16 dccp_v6_csum_finish(struct sk_buff *skb,
-				      struct in6_addr *saddr,
-				      struct in6_addr *daddr)
+				      const struct in6_addr *saddr,
+				      const struct in6_addr *daddr)
 {
 	return csum_ipv6_magic(saddr, daddr, skb->len, IPPROTO_DCCP, skb->csum);
 }
@@ -87,7 +87,7 @@ static inline __u32 dccp_v6_init_sequence(struct sk_buff *skb)
 static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			u8 type, u8 code, int offset, __be32 info)
 {
-	struct ipv6hdr *hdr = (struct ipv6hdr *)skb->data;
+	const struct ipv6hdr *hdr = (const struct ipv6hdr *)skb->data;
 	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data + offset);
 	struct dccp_sock *dp;
 	struct ipv6_pinfo *np;
@@ -296,7 +296,7 @@ static void dccp_v6_reqsk_destructor(struct request_sock *req)
 
 static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 {
-	struct ipv6hdr *rxip6h;
+	const struct ipv6hdr *rxip6h;
 	struct sk_buff *skb;
 	struct flowi6 fl6;
 	struct net *net = dev_net(skb_dst(rxskb)->dev);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 807d83c..cae75ef 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1186,7 +1186,7 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
 
 static int inet_gso_send_check(struct sk_buff *skb)
 {
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	const struct net_protocol *ops;
 	int proto;
 	int ihl;
@@ -1293,7 +1293,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	const struct net_protocol *ops;
 	struct sk_buff **pp = NULL;
 	struct sk_buff *p;
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	unsigned int hlen;
 	unsigned int off;
 	unsigned int id;
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 4286fd3..c1f4154 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -73,7 +73,7 @@ static inline struct scatterlist *ah_req_sg(struct crypto_ahash *ahash,
  * into IP header for icv calculation. Options are already checked
  * for validity, so paranoia is not required. */
 
-static int ip_clear_mutable_options(struct iphdr *iph, __be32 *daddr)
+static int ip_clear_mutable_options(const struct iphdr *iph, __be32 *daddr)
 {
 	unsigned char * optptr = (unsigned char*)(iph+1);
 	int  l = iph->ihl*4 - sizeof(struct iphdr);
@@ -396,7 +396,7 @@ out:
 static void ah4_err(struct sk_buff *skb, u32 info)
 {
 	struct net *net = dev_net(skb->dev);
-	struct iphdr *iph = (struct iphdr *)skb->data;
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
 	struct ip_auth_hdr *ah = (struct ip_auth_hdr *)(skb->data+(iph->ihl<<2));
 	struct xfrm_state *x;
 
@@ -404,7 +404,8 @@ static void ah4_err(struct sk_buff *skb, u32 info)
 	    icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
 		return;
 
-	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET);
+	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
+			      ah->spi, IPPROTO_AH, AF_INET);
 	if (!x)
 		return;
 	printk(KERN_DEBUG "pmtu discovery on SA AH/%08x/%08x\n",
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 03f994b..a5b4134 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -276,7 +276,7 @@ error:
 
 static int esp_input_done2(struct sk_buff *skb, int err)
 {
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	struct xfrm_state *x = xfrm_input_state(skb);
 	struct esp_data *esp = x->data;
 	struct crypto_aead *aead = esp->aead;
@@ -484,7 +484,7 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 static void esp4_err(struct sk_buff *skb, u32 info)
 {
 	struct net *net = dev_net(skb->dev);
-	struct iphdr *iph = (struct iphdr *)skb->data;
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
 	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)(skb->data+(iph->ihl<<2));
 	struct xfrm_state *x;
 
@@ -492,7 +492,8 @@ static void esp4_err(struct sk_buff *skb, u32 info)
 	    icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
 		return;
 
-	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET);
+	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
+			      esph->spi, IPPROTO_ESP, AF_INET);
 	if (!x)
 		return;
 	NETDEBUG(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%08x\n",
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index e5f8a71..74e35e5 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -373,7 +373,7 @@ out_unlock:
 }
 
 static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
-					struct iphdr *iph,
+					const struct iphdr *iph,
 					__be32 saddr, u8 tos,
 					int type, int code,
 					struct icmp_bxm *param)
@@ -637,7 +637,7 @@ EXPORT_SYMBOL(icmp_send);
 
 static void icmp_unreach(struct sk_buff *skb)
 {
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	struct icmphdr *icmph;
 	int hash, protocol;
 	const struct net_protocol *ipprot;
@@ -656,7 +656,7 @@ static void icmp_unreach(struct sk_buff *skb)
 		goto out_err;
 
 	icmph = icmp_hdr(skb);
-	iph   = (struct iphdr *)skb->data;
+	iph   = (const struct iphdr *)skb->data;
 
 	if (iph->ihl < 5) /* Mangled header, drop. */
 		goto out_err;
@@ -729,7 +729,7 @@ static void icmp_unreach(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, iph->ihl * 4 + 8))
 		goto out;
 
-	iph = (struct iphdr *)skb->data;
+	iph = (const struct iphdr *)skb->data;
 	protocol = iph->protocol;
 
 	/*
@@ -758,7 +758,7 @@ out_err:
 
 static void icmp_redirect(struct sk_buff *skb)
 {
-	struct iphdr *iph;
+	const struct iphdr *iph;
 
 	if (skb->len < sizeof(struct iphdr))
 		goto out_err;
@@ -769,7 +769,7 @@ static void icmp_redirect(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto out;
 
-	iph = (struct iphdr *)skb->data;
+	iph = (const struct iphdr *)skb->data;
 
 	switch (icmp_hdr(skb)->code & 7) {
 	case ICMP_REDIR_NET:
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 2ada171..6ffe94c 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -124,7 +124,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 	if (r->idiag_family == AF_INET6) {
-		struct ipv6_pinfo *np = inet6_sk(sk);
+		const struct ipv6_pinfo *np = inet6_sk(sk);
 
 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_src,
 			       &np->rcv_saddr);
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 47038cb..85a0f75 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -51,8 +51,8 @@ MODULE_DESCRIPTION("Large Receive Offload (ipv4 / tcp)");
  * Basic tcp checks whether packet is suitable for LRO
  */
 
-static int lro_tcp_ip_check(struct iphdr *iph, struct tcphdr *tcph,
-			    int len, struct net_lro_desc *lro_desc)
+static int lro_tcp_ip_check(const struct iphdr *iph, const struct tcphdr *tcph,
+			    int len, const struct net_lro_desc *lro_desc)
 {
         /* check ip header: don't aggregate padded frames */
 	if (ntohs(iph->tot_len) != len)
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index da5941f..24efd35 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -462,7 +462,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
    by themself???
  */
 
-	struct iphdr *iph = (struct iphdr *)skb->data;
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
 	__be16	     *p = (__be16*)(skb->data+(iph->ihl<<2));
 	int grehlen = (iph->ihl<<2) + 4;
 	const int type = icmp_hdr(skb)->type;
@@ -534,7 +534,7 @@ out:
 	rcu_read_unlock();
 }
 
-static inline void ipgre_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
+static inline void ipgre_ecn_decapsulate(const struct iphdr *iph, struct sk_buff *skb)
 {
 	if (INET_ECN_is_ce(iph->tos)) {
 		if (skb->protocol == htons(ETH_P_IP)) {
@@ -546,19 +546,19 @@ static inline void ipgre_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
 }
 
 static inline u8
-ipgre_ecn_encapsulate(u8 tos, struct iphdr *old_iph, struct sk_buff *skb)
+ipgre_ecn_encapsulate(u8 tos, const struct iphdr *old_iph, struct sk_buff *skb)
 {
 	u8 inner = 0;
 	if (skb->protocol == htons(ETH_P_IP))
 		inner = old_iph->tos;
 	else if (skb->protocol == htons(ETH_P_IPV6))
-		inner = ipv6_get_dsfield((struct ipv6hdr *)old_iph);
+		inner = ipv6_get_dsfield((const struct ipv6hdr *)old_iph);
 	return INET_ECN_encapsulate(tos, inner);
 }
 
 static int ipgre_rcv(struct sk_buff *skb)
 {
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	u8     *h;
 	__be16    flags;
 	__sum16   csum = 0;
@@ -697,8 +697,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct pcpu_tstats *tstats;
-	struct iphdr  *old_iph = ip_hdr(skb);
-	struct iphdr  *tiph;
+	const struct iphdr  *old_iph = ip_hdr(skb);
+	const struct iphdr  *tiph;
 	u8     tos;
 	__be16 df;
 	struct rtable *rt;     			/* Route to the other host */
@@ -714,7 +714,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 
 	if (dev->header_ops && dev->type == ARPHRD_IPGRE) {
 		gre_hlen = 0;
-		tiph = (struct iphdr *)skb->data;
+		tiph = (const struct iphdr *)skb->data;
 	} else {
 		gre_hlen = tunnel->hlen;
 		tiph = &tunnel->parms.iph;
@@ -735,14 +735,14 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (skb->protocol == htons(ETH_P_IPV6)) {
-			struct in6_addr *addr6;
+			const struct in6_addr *addr6;
 			int addr_type;
 			struct neighbour *neigh = skb_dst(skb)->neighbour;
 
 			if (neigh == NULL)
 				goto tx_error;
 
-			addr6 = (struct in6_addr *)&neigh->primary_key;
+			addr6 = (const struct in6_addr *)&neigh->primary_key;
 			addr_type = ipv6_addr_type(addr6);
 
 			if (addr_type == IPV6_ADDR_ANY) {
@@ -766,7 +766,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		if (skb->protocol == htons(ETH_P_IP))
 			tos = old_iph->tos;
 		else if (skb->protocol == htons(ETH_P_IPV6))
-			tos = ipv6_get_dsfield((struct ipv6hdr *)old_iph);
+			tos = ipv6_get_dsfield((const struct ipv6hdr *)old_iph);
 	}
 
 	rt = ip_route_output_gre(dev_net(dev), dst, tiph->saddr,
@@ -881,7 +881,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			iph->ttl = old_iph->ttl;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (skb->protocol == htons(ETH_P_IPV6))
-			iph->ttl = ((struct ipv6hdr *)old_iph)->hop_limit;
+			iph->ttl = ((const struct ipv6hdr *)old_iph)->hop_limit;
 #endif
 		else
 			iph->ttl = ip4_dst_hoplimit(&rt->dst);
@@ -927,7 +927,7 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
 	struct ip_tunnel *tunnel;
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	int hlen = LL_MAX_HEADER;
 	int mtu = ETH_DATA_LEN;
 	int addend = sizeof(struct iphdr) + 4;
@@ -1180,7 +1180,7 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 
 static int ipgre_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
-	struct iphdr *iph = (struct iphdr *) skb_mac_header(skb);
+	const struct iphdr *iph = (const struct iphdr *) skb_mac_header(skb);
 	memcpy(haddr, &iph->saddr, 4);
 	return 4;
 }
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index d7b2b09..c8f48ef 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -268,7 +268,7 @@ int ip_local_deliver(struct sk_buff *skb)
 static inline int ip_rcv_options(struct sk_buff *skb)
 {
 	struct ip_options *opt;
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	struct net_device *dev = skb->dev;
 
 	/* It looks as overkill, because not all
@@ -374,7 +374,7 @@ drop:
  */
 int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	u32 len;
 
 	/* When the interface is in promisc. mode, drop all the crap
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 3948c86..9640900 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -131,7 +131,7 @@ static void ip_cmsg_recv_security(struct msghdr *msg, struct sk_buff *skb)
 static void ip_cmsg_recv_dstaddr(struct msghdr *msg, struct sk_buff *skb)
 {
 	struct sockaddr_in sin;
-	struct iphdr *iph = ip_hdr(skb);
+	const struct iphdr *iph = ip_hdr(skb);
 	__be16 *ports = (__be16 *)skb_transport_header(skb);
 
 	if (skb_transport_offset(skb) + 4 > skb->len)
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 6290675..c857f6f 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -27,7 +27,7 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	__be32 spi;
-	struct iphdr *iph = (struct iphdr *)skb->data;
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
 	struct ip_comp_hdr *ipch = (struct ip_comp_hdr *)(skb->data+(iph->ihl<<2));
 	struct xfrm_state *x;
 
@@ -36,7 +36,7 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 		return;
 
 	spi = htonl(ntohs(ipch->cpi));
-	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr,
+	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
 			      spi, IPPROTO_COMP, AF_INET);
 	if (!x)
 		return;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index bfc17c5..ef16377 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -319,7 +319,7 @@ static int ipip_err(struct sk_buff *skb, u32 info)
    8 bytes of packet payload. It means, that precise relaying of
    ICMP in the real Internet is absolutely infeasible.
  */
-	struct iphdr *iph = (struct iphdr *)skb->data;
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct ip_tunnel *t;
@@ -433,12 +433,12 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct pcpu_tstats *tstats;
-	struct iphdr  *tiph = &tunnel->parms.iph;
+	const struct iphdr  *tiph = &tunnel->parms.iph;
 	u8     tos = tunnel->parms.iph.tos;
 	__be16 df = tiph->frag_off;
 	struct rtable *rt;     			/* Route to the other host */
 	struct net_device *tdev;		/* Device to other host */
-	struct iphdr  *old_iph = ip_hdr(skb);
+	const struct iphdr  *old_iph = ip_hdr(skb);
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	__be32 dst = tiph->daddr;
@@ -572,7 +572,7 @@ static void ipip_tunnel_bind_dev(struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
 	struct ip_tunnel *tunnel;
-	struct iphdr *iph;
+	const struct iphdr *iph;
 
 	tunnel = netdev_priv(dev);
 	iph = &tunnel->parms.iph;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 1f62eae..c81b9b6 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1549,7 +1549,7 @@ static struct notifier_block ip_mr_notifier = {
 static void ip_encap(struct sk_buff *skb, __be32 saddr, __be32 daddr)
 {
 	struct iphdr *iph;
-	struct iphdr *old_iph = ip_hdr(skb);
+	const struct iphdr *old_iph = ip_hdr(skb);
 
 	skb_push(skb, sizeof(struct iphdr));
 	skb->transport_header = skb->network_header;
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 31427fb..99cfa28 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -153,7 +153,7 @@ void nf_nat_set_seq_adjust(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 }
 EXPORT_SYMBOL_GPL(nf_nat_set_seq_adjust);
 
-static void nf_nat_csum(struct sk_buff *skb, struct iphdr *iph, void *data,
+static void nf_nat_csum(struct sk_buff *skb, const struct iphdr *iph, void *data,
 			int datalen, __sum16 *check, int oldlen)
 {
 	struct rtable *rt = skb_rtable(skb);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2b50cc2..abf14db 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -154,7 +154,7 @@ static __inline__ int icmp_filter(struct sock *sk, struct sk_buff *skb)
  * RFC 1122: SHOULD pass TOS value up to the transport layer.
  * -> It does. And not only TOS, but all IP header.
  */
-static int raw_v4_input(struct sk_buff *skb, struct iphdr *iph, int hash)
+static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 {
 	struct sock *sk;
 	struct hlist_head *head;
@@ -247,7 +247,7 @@ static void raw_err(struct sock *sk, struct sk_buff *skb, u32 info)
 	}
 
 	if (inet->recverr) {
-		struct iphdr *iph = (struct iphdr *)skb->data;
+		const struct iphdr *iph = (const struct iphdr *)skb->data;
 		u8 *payload = skb->data + (iph->ihl << 2);
 
 		if (inet->hdrincl)
@@ -265,7 +265,7 @@ void raw_icmp_error(struct sk_buff *skb, int protocol, u32 info)
 {
 	int hash;
 	struct sock *raw_sk;
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	struct net *net;
 
 	hash = protocol & (RAW_HTABLE_SIZE - 1);
@@ -273,7 +273,7 @@ void raw_icmp_error(struct sk_buff *skb, int protocol, u32 info)
 	read_lock(&raw_v4_hashinfo.lock);
 	raw_sk = sk_head(&raw_v4_hashinfo.ht[hash]);
 	if (raw_sk != NULL) {
-		iph = (struct iphdr *)skb->data;
+		iph = (const struct iphdr *)skb->data;
 		net = dev_net(skb->dev);
 
 		while ((raw_sk = __raw_v4_lookup(net, raw_sk, protocol,
@@ -281,7 +281,7 @@ void raw_icmp_error(struct sk_buff *skb, int protocol, u32 info)
 						skb->dev->ifindex)) != NULL) {
 			raw_err(raw_sk, skb, info);
 			raw_sk = sk_next(raw_sk);
-			iph = (struct iphdr *)skb->data;
+			iph = (const struct iphdr *)skb->data;
 		}
 	}
 	read_unlock(&raw_v4_hashinfo.lock);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e9aee81..f4b7f80 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1507,7 +1507,7 @@ static inline unsigned short guess_mtu(unsigned short old_mtu)
 	return 68;
 }
 
-unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
+unsigned short ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
 				 unsigned short new_mtu,
 				 struct net_device *dev)
 {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f7e6c2c..edf18bd 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -279,7 +279,7 @@ EXPORT_SYMBOL(tcp_v4_connect);
 /*
  * This routine does path mtu discovery as defined in RFC1191.
  */
-static void do_pmtu_discovery(struct sock *sk, struct iphdr *iph, u32 mtu)
+static void do_pmtu_discovery(struct sock *sk, const struct iphdr *iph, u32 mtu)
 {
 	struct dst_entry *dst;
 	struct inet_sock *inet = inet_sk(sk);
@@ -341,7 +341,7 @@ static void do_pmtu_discovery(struct sock *sk, struct iphdr *iph, u32 mtu)
 
 void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 {
-	struct iphdr *iph = (struct iphdr *)icmp_skb->data;
+	const struct iphdr *iph = (const struct iphdr *)icmp_skb->data;
 	struct tcphdr *th = (struct tcphdr *)(icmp_skb->data + (iph->ihl << 2));
 	struct inet_connection_sock *icsk;
 	struct tcp_sock *tp;
@@ -2527,7 +2527,7 @@ void tcp4_proc_exit(void)
 
 struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
-	struct iphdr *iph = skb_gro_network_header(skb);
+	const struct iphdr *iph = skb_gro_network_header(skb);
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
@@ -2548,7 +2548,7 @@ struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 int tcp4_gro_complete(struct sk_buff *skb)
 {
-	struct iphdr *iph = ip_hdr(skb);
+	const struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
 
 	th->check = ~tcp_v4_check(skb->len - skb_transport_offset(skb),
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index a15c8fb..bc0dab2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -578,7 +578,7 @@ found:
 void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 {
 	struct inet_sock *inet;
-	struct iphdr *iph = (struct iphdr *)skb->data;
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
 	struct udphdr *uh = (struct udphdr *)(skb->data+(iph->ihl<<2));
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index d20a05e..59b1340 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -102,7 +102,7 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 static void
 _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 {
-	struct iphdr *iph = ip_hdr(skb);
+	const struct iphdr *iph = ip_hdr(skb);
 	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
 	struct flowi4 *fl4 = &fl->u.ip4;
 
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 1717c64..ea983ae 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -55,7 +55,7 @@ xfrm4_init_temprop(struct xfrm_state *x, const struct xfrm_tmpl *tmpl,
 
 int xfrm4_extract_header(struct sk_buff *skb)
 {
-	struct iphdr *iph = ip_hdr(skb);
+	const struct iphdr *iph = ip_hdr(skb);
 
 	XFRM_MODE_SKB_CB(skb)->ihl = sizeof(*iph);
 	XFRM_MODE_SKB_CB(skb)->id = iph->id;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 129d7e1..c663a3b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1283,7 +1283,7 @@ static int ipv6_count_addresses(struct inet6_dev *idev)
 	return cnt;
 }
 
-int ipv6_chk_addr(struct net *net, struct in6_addr *addr,
+int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 		  struct net_device *dev, int strict)
 {
 	struct inet6_ifaddr *ifp;
@@ -1326,7 +1326,7 @@ static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 	return false;
 }
 
-int ipv6_chk_prefix(struct in6_addr *addr, struct net_device *dev)
+int ipv6_chk_prefix(const struct in6_addr *addr, struct net_device *dev)
 {
 	struct inet6_dev *idev;
 	struct inet6_ifaddr *ifa;
@@ -1457,7 +1457,7 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 
 /* Join to solicited addr multicast group. */
 
-void addrconf_join_solict(struct net_device *dev, struct in6_addr *addr)
+void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct in6_addr maddr;
 
@@ -1468,7 +1468,7 @@ void addrconf_join_solict(struct net_device *dev, struct in6_addr *addr)
 	ipv6_dev_mc_inc(dev, &maddr);
 }
 
-void addrconf_leave_solict(struct inet6_dev *idev, struct in6_addr *addr)
+void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr)
 {
 	struct in6_addr maddr;
 
@@ -2113,7 +2113,7 @@ err_exit:
 /*
  *	Manual configuration of address on an interface
  */
-static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
+static int inet6_addr_add(struct net *net, int ifindex, const struct in6_addr *pfx,
 			  unsigned int plen, __u8 ifa_flags, __u32 prefered_lft,
 			  __u32 valid_lft)
 {
@@ -2187,7 +2187,7 @@ static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
 	return PTR_ERR(ifp);
 }
 
-static int inet6_addr_del(struct net *net, int ifindex, struct in6_addr *pfx,
+static int inet6_addr_del(struct net *net, int ifindex, const struct in6_addr *pfx,
 			  unsigned int plen)
 {
 	struct inet6_ifaddr *ifp;
@@ -2350,7 +2350,7 @@ static void init_loopback(struct net_device *dev)
 	add_addr(idev, &in6addr_loopback, 128, IFA_HOST);
 }
 
-static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr)
+static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr *addr)
 {
 	struct inet6_ifaddr * ifp;
 	u32 addr_flags = IFA_F_PERMANENT;
@@ -3121,7 +3121,7 @@ void if6_proc_exit(void)
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 /* Check if address is a home address configured on any interface. */
-int ipv6_chk_home_addr(struct net *net, struct in6_addr *addr)
+int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr)
 {
 	int ret = 0;
 	struct inet6_ifaddr *ifp = NULL;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index afcc709..b7919f9 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -740,7 +740,7 @@ static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
 
 static int ipv6_gso_send_check(struct sk_buff *skb)
 {
-	struct ipv6hdr *ipv6h;
+	const struct ipv6hdr *ipv6h;
 	const struct inet6_protocol *ops;
 	int err = -EINVAL;
 
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 0e5e943..674255f 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -44,7 +44,7 @@
 
 #include <net/checksum.h>
 
-static int ipv6_dev_ac_dec(struct net_device *dev, struct in6_addr *addr);
+static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr);
 
 /* Big ac list lock for all the sockets */
 static DEFINE_RWLOCK(ipv6_sk_ac_lock);
@@ -54,7 +54,7 @@ static DEFINE_RWLOCK(ipv6_sk_ac_lock);
  *	socket join an anycast group
  */
 
-int ipv6_sock_ac_join(struct sock *sk, int ifindex, struct in6_addr *addr)
+int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct net_device *dev = NULL;
@@ -145,7 +145,7 @@ error:
 /*
  *	socket leave an anycast group
  */
-int ipv6_sock_ac_drop(struct sock *sk, int ifindex, struct in6_addr *addr)
+int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct net_device *dev;
@@ -252,7 +252,7 @@ static void aca_put(struct ifacaddr6 *ac)
 /*
  *	device anycast group inc (add if not found)
  */
-int ipv6_dev_ac_inc(struct net_device *dev, struct in6_addr *addr)
+int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct ifacaddr6 *aca;
 	struct inet6_dev *idev;
@@ -324,7 +324,7 @@ out:
 /*
  *	device anycast group decrement
  */
-int __ipv6_dev_ac_dec(struct inet6_dev *idev, struct in6_addr *addr)
+int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr)
 {
 	struct ifacaddr6 *aca, *prev_aca;
 
@@ -358,7 +358,7 @@ int __ipv6_dev_ac_dec(struct inet6_dev *idev, struct in6_addr *addr)
 }
 
 /* called with rcu_read_lock() */
-static int ipv6_dev_ac_dec(struct net_device *dev, struct in6_addr *addr)
+static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct inet6_dev *idev = __in6_dev_get(dev);
 
@@ -371,7 +371,7 @@ static int ipv6_dev_ac_dec(struct net_device *dev, struct in6_addr *addr)
  *	check if the interface has this anycast address
  *	called with rcu_read_lock()
  */
-static int ipv6_chk_acast_dev(struct net_device *dev, struct in6_addr *addr)
+static int ipv6_chk_acast_dev(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct inet6_dev *idev;
 	struct ifacaddr6 *aca;
@@ -392,7 +392,7 @@ static int ipv6_chk_acast_dev(struct net_device *dev, struct in6_addr *addr)
  *	check if given interface (or any, if dev==0) has this anycast address
  */
 int ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
-			struct in6_addr *addr)
+			const struct in6_addr *addr)
 {
 	int found = 0;
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 5aa8ec8..e97b4b7 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -430,7 +430,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		     u8 type, u8 code, int offset, __be32 info)
 {
 	struct net *net = dev_net(skb->dev);
-	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
+	const struct ipv6hdr *iph = (const struct ipv6hdr *)skb->data;
 	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)(skb->data + offset);
 	struct xfrm_state *x;
 
@@ -438,7 +438,8 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	    type != ICMPV6_PKT_TOOBIG)
 		return;
 
-	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET6);
+	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
+			      esph->spi, IPPROTO_ESP, AF_INET6);
 	if (!x)
 		return;
 	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%pI6\n",
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 83cb4f9..1190041 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -372,7 +372,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct sock *sk;
 	struct ipv6_pinfo *np;
-	struct in6_addr *saddr = NULL;
+	const struct in6_addr *saddr = NULL;
 	struct dst_entry *dst;
 	struct icmp6hdr tmp_hdr;
 	struct flowi6 fl6;
@@ -521,7 +521,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	struct sock *sk;
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *np;
-	struct in6_addr *saddr = NULL;
+	const struct in6_addr *saddr = NULL;
 	struct icmp6hdr *icmph = icmp6_hdr(skb);
 	struct icmp6hdr tmp_hdr;
 	struct flowi6 fl6;
@@ -645,8 +645,8 @@ static int icmpv6_rcv(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct inet6_dev *idev = __in6_dev_get(dev);
-	struct in6_addr *saddr, *daddr;
-	struct ipv6hdr *orig_hdr;
+	const struct in6_addr *saddr, *daddr;
+	const struct ipv6hdr *orig_hdr;
 	struct icmp6hdr *hdr;
 	u8 type;
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 7548905..dd88df0 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -134,9 +134,9 @@ static __inline__ u32 fib6_new_sernum(void)
 # define BITOP_BE32_SWIZZLE	0
 #endif
 
-static __inline__ __be32 addr_bit_set(void *token, int fn_bit)
+static __inline__ __be32 addr_bit_set(const void *token, int fn_bit)
 {
-	__be32 *addr = token;
+	const __be32 *addr = token;
 	/*
 	 * Here,
 	 * 	1 << ((~fn_bit ^ BITOP_BE32_SWIZZLE) & 0x1f)
@@ -822,7 +822,7 @@ st_failure:
 
 struct lookup_args {
 	int		offset;		/* key offset on rt6_info	*/
-	struct in6_addr	*addr;		/* search key			*/
+	const struct in6_addr	*addr;		/* search key			*/
 };
 
 static struct fib6_node * fib6_lookup_1(struct fib6_node *root,
@@ -881,8 +881,8 @@ static struct fib6_node * fib6_lookup_1(struct fib6_node *root,
 	return NULL;
 }
 
-struct fib6_node * fib6_lookup(struct fib6_node *root, struct in6_addr *daddr,
-			       struct in6_addr *saddr)
+struct fib6_node * fib6_lookup(struct fib6_node *root, const struct in6_addr *daddr,
+			       const struct in6_addr *saddr)
 {
 	struct fib6_node *fn;
 	struct lookup_args args[] = {
@@ -916,7 +916,7 @@ struct fib6_node * fib6_lookup(struct fib6_node *root, struct in6_addr *daddr,
 
 
 static struct fib6_node * fib6_locate_1(struct fib6_node *root,
-					struct in6_addr *addr,
+					const struct in6_addr *addr,
 					int plen, int offset)
 {
 	struct fib6_node *fn;
@@ -946,8 +946,8 @@ static struct fib6_node * fib6_locate_1(struct fib6_node *root,
 }
 
 struct fib6_node * fib6_locate(struct fib6_node *root,
-			       struct in6_addr *daddr, int dst_len,
-			       struct in6_addr *saddr, int src_len)
+			       const struct in6_addr *daddr, int dst_len,
+			       const struct in6_addr *saddr, int src_len)
 {
 	struct fib6_node *fn;
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index a83e920..027c7ff 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -57,7 +57,7 @@ inline int ip6_rcv_finish( struct sk_buff *skb)
 
 int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct ipv6hdr *hdr;
+	const struct ipv6hdr *hdr;
 	u32 		pkt_len;
 	struct inet6_dev *idev;
 	struct net *net = dev_net(skb->dev);
@@ -186,7 +186,7 @@ resubmit:
 		int ret;
 
 		if (ipprot->flags & INET6_PROTO_FINAL) {
-			struct ipv6hdr *hdr;
+			const struct ipv6hdr *hdr;
 
 			/* Free reference early: we don't need it any more,
 			   and it may hold ip_conntrack module loaded
@@ -242,7 +242,7 @@ int ip6_input(struct sk_buff *skb)
 
 int ip6_mc_input(struct sk_buff *skb)
 {
-	struct ipv6hdr *hdr;
+	const struct ipv6hdr *hdr;
 	int deliver;
 
 	IP6_UPD_PO_STATS_BH(dev_net(skb_dst(skb)->dev),
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c614d02..4cfbb24 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -869,9 +869,9 @@ fail:
 	return err;
 }
 
-static inline int ip6_rt_check(struct rt6key *rt_key,
-			       struct in6_addr *fl_addr,
-			       struct in6_addr *addr_cache)
+static inline int ip6_rt_check(const struct rt6key *rt_key,
+			       const struct in6_addr *fl_addr,
+			       const struct in6_addr *addr_cache)
 {
 	return (rt_key->plen != 128 || !ipv6_addr_equal(fl_addr, &rt_key->addr)) &&
 		(addr_cache == NULL || !ipv6_addr_equal(fl_addr, addr_cache));
@@ -879,7 +879,7 @@ static inline int ip6_rt_check(struct rt6key *rt_key,
 
 static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 					  struct dst_entry *dst,
-					  struct flowi6 *fl6)
+					  const struct flowi6 *fl6)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct rt6_info *rt = (struct rt6_info *)dst;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index c1b1bd3..9dd0e96 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -162,7 +162,7 @@ static inline void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
 	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
 static struct ip6_tnl *
-ip6_tnl_lookup(struct net *net, struct in6_addr *remote, struct in6_addr *local)
+ip6_tnl_lookup(struct net *net, const struct in6_addr *remote, const struct in6_addr *local)
 {
 	unsigned int h0 = HASH(remote);
 	unsigned int h1 = HASH(local);
@@ -194,10 +194,10 @@ ip6_tnl_lookup(struct net *net, struct in6_addr *remote, struct in6_addr *local)
  **/
 
 static struct ip6_tnl __rcu **
-ip6_tnl_bucket(struct ip6_tnl_net *ip6n, struct ip6_tnl_parm *p)
+ip6_tnl_bucket(struct ip6_tnl_net *ip6n, const struct ip6_tnl_parm *p)
 {
-	struct in6_addr *remote = &p->raddr;
-	struct in6_addr *local = &p->laddr;
+	const struct in6_addr *remote = &p->raddr;
+	const struct in6_addr *local = &p->laddr;
 	unsigned h = 0;
 	int prio = 0;
 
@@ -321,8 +321,8 @@ failed:
 static struct ip6_tnl *ip6_tnl_locate(struct net *net,
 		struct ip6_tnl_parm *p, int create)
 {
-	struct in6_addr *remote = &p->raddr;
-	struct in6_addr *local = &p->laddr;
+	const struct in6_addr *remote = &p->raddr;
+	const struct in6_addr *local = &p->laddr;
 	struct ip6_tnl __rcu **tp;
 	struct ip6_tnl *t;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
@@ -374,7 +374,7 @@ ip6_tnl_dev_uninit(struct net_device *dev)
 static __u16
 parse_tlv_tnl_enc_lim(struct sk_buff *skb, __u8 * raw)
 {
-	struct ipv6hdr *ipv6h = (struct ipv6hdr *) raw;
+	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *) raw;
 	__u8 nexthdr = ipv6h->nexthdr;
 	__u16 off = sizeof (*ipv6h);
 
@@ -435,7 +435,7 @@ static int
 ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 	    u8 *type, u8 *code, int *msg, __u32 *info, int offset)
 {
-	struct ipv6hdr *ipv6h = (struct ipv6hdr *) skb->data;
+	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *) skb->data;
 	struct ip6_tnl *t;
 	int rel_msg = 0;
 	u8 rel_type = ICMPV6_DEST_UNREACH;
@@ -535,7 +535,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	__u32 rel_info = ntohl(info);
 	int err;
 	struct sk_buff *skb2;
-	struct iphdr *eiph;
+	const struct iphdr *eiph;
 	struct rtable *rt;
 
 	err = ip6_tnl_err(skb, IPPROTO_IPIP, opt, &rel_type, &rel_code,
@@ -669,8 +669,8 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	return 0;
 }
 
-static void ip4ip6_dscp_ecn_decapsulate(struct ip6_tnl *t,
-					struct ipv6hdr *ipv6h,
+static void ip4ip6_dscp_ecn_decapsulate(const struct ip6_tnl *t,
+					const struct ipv6hdr *ipv6h,
 					struct sk_buff *skb)
 {
 	__u8 dsfield = ipv6_get_dsfield(ipv6h) & ~INET_ECN_MASK;
@@ -682,8 +682,8 @@ static void ip4ip6_dscp_ecn_decapsulate(struct ip6_tnl *t,
 		IP_ECN_set_ce(ip_hdr(skb));
 }
 
-static void ip6ip6_dscp_ecn_decapsulate(struct ip6_tnl *t,
-					struct ipv6hdr *ipv6h,
+static void ip6ip6_dscp_ecn_decapsulate(const struct ip6_tnl *t,
+					const struct ipv6hdr *ipv6h,
 					struct sk_buff *skb)
 {
 	if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
@@ -726,12 +726,12 @@ static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t)
 
 static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		       __u8 ipproto,
-		       void (*dscp_ecn_decapsulate)(struct ip6_tnl *t,
-						    struct ipv6hdr *ipv6h,
+		       void (*dscp_ecn_decapsulate)(const struct ip6_tnl *t,
+						    const struct ipv6hdr *ipv6h,
 						    struct sk_buff *skb))
 {
 	struct ip6_tnl *t;
-	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 
 	rcu_read_lock();
 
@@ -828,7 +828,7 @@ static void init_tel_txopt(struct ipv6_tel_txoption *opt, __u8 encap_limit)
  **/
 
 static inline int
-ip6_tnl_addr_conflict(struct ip6_tnl *t, struct ipv6hdr *hdr)
+ip6_tnl_addr_conflict(const struct ip6_tnl *t, const struct ipv6hdr *hdr)
 {
 	return ipv6_addr_equal(&t->parms.raddr, &hdr->saddr);
 }
@@ -1005,7 +1005,7 @@ static inline int
 ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	struct iphdr  *iph = ip_hdr(skb);
+	const struct iphdr  *iph = ip_hdr(skb);
 	int encap_limit = -1;
 	struct flowi6 fl6;
 	__u8 dsfield;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 29e4859..82a8099 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -989,8 +989,8 @@ static int mif6_add(struct net *net, struct mr6_table *mrt,
 }
 
 static struct mfc6_cache *ip6mr_cache_find(struct mr6_table *mrt,
-					   struct in6_addr *origin,
-					   struct in6_addr *mcastgrp)
+					   const struct in6_addr *origin,
+					   const struct in6_addr *mcastgrp)
 {
 	int line = MFC6_HASH(mcastgrp, origin);
 	struct mfc6_cache *c;
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 85cccd6..bba658d 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -55,7 +55,7 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 {
 	struct net *net = dev_net(skb->dev);
 	__be32 spi;
-	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
+	const struct ipv6hdr *iph = (const struct ipv6hdr *)skb->data;
 	struct ip_comp_hdr *ipcomph =
 		(struct ip_comp_hdr *)(skb->data + offset);
 	struct xfrm_state *x;
@@ -64,7 +64,8 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 
 	spi = htonl(ntohs(ipcomph->cpi));
-	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, spi, IPPROTO_COMP, AF_INET6);
+	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
+			      spi, IPPROTO_COMP, AF_INET6);
 	if (!x)
 		return;
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 76b8937..ff62e33 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -92,16 +92,16 @@ static void mld_gq_timer_expire(unsigned long data);
 static void mld_ifc_timer_expire(unsigned long data);
 static void mld_ifc_event(struct inet6_dev *idev);
 static void mld_add_delrec(struct inet6_dev *idev, struct ifmcaddr6 *pmc);
-static void mld_del_delrec(struct inet6_dev *idev, struct in6_addr *addr);
+static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *addr);
 static void mld_clear_delrec(struct inet6_dev *idev);
 static int sf_setstate(struct ifmcaddr6 *pmc);
 static void sf_markstate(struct ifmcaddr6 *pmc);
 static void ip6_mc_clear_src(struct ifmcaddr6 *pmc);
-static int ip6_mc_del_src(struct inet6_dev *idev, struct in6_addr *pmca,
-			  int sfmode, int sfcount, struct in6_addr *psfsrc,
+static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
+			  int sfmode, int sfcount, const struct in6_addr *psfsrc,
 			  int delta);
-static int ip6_mc_add_src(struct inet6_dev *idev, struct in6_addr *pmca,
-			  int sfmode, int sfcount, struct in6_addr *psfsrc,
+static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
+			  int sfmode, int sfcount, const struct in6_addr *psfsrc,
 			  int delta);
 static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 			    struct inet6_dev *idev);
@@ -250,7 +250,7 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 /* called with rcu_read_lock() */
 static struct inet6_dev *ip6_mc_find_dev_rcu(struct net *net,
-					     struct in6_addr *group,
+					     const struct in6_addr *group,
 					     int ifindex)
 {
 	struct net_device *dev = NULL;
@@ -451,7 +451,7 @@ done:
 
 int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 {
-	struct in6_addr *group;
+	const struct in6_addr *group;
 	struct ipv6_mc_socklist *pmc;
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
@@ -542,7 +542,7 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	struct group_filter __user *optval, int __user *optlen)
 {
 	int err, i, count, copycount;
-	struct in6_addr *group;
+	const struct in6_addr *group;
 	struct ipv6_mc_socklist *pmc;
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
@@ -752,7 +752,7 @@ static void mld_add_delrec(struct inet6_dev *idev, struct ifmcaddr6 *im)
 	spin_unlock_bh(&idev->mc_lock);
 }
 
-static void mld_del_delrec(struct inet6_dev *idev, struct in6_addr *pmca)
+static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *pmca)
 {
 	struct ifmcaddr6 *pmc, *pmc_prev;
 	struct ip6_sf_list *psf, *psf_next;
@@ -1052,7 +1052,7 @@ static void igmp6_group_queried(struct ifmcaddr6 *ma, unsigned long resptime)
 
 /* mark EXCLUDE-mode sources */
 static int mld_xmarksources(struct ifmcaddr6 *pmc, int nsrcs,
-	struct in6_addr *srcs)
+	const struct in6_addr *srcs)
 {
 	struct ip6_sf_list *psf;
 	int i, scount;
@@ -1080,7 +1080,7 @@ static int mld_xmarksources(struct ifmcaddr6 *pmc, int nsrcs,
 }
 
 static int mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
-	struct in6_addr *srcs)
+	const struct in6_addr *srcs)
 {
 	struct ip6_sf_list *psf;
 	int i, scount;
@@ -1115,7 +1115,7 @@ int igmp6_event_query(struct sk_buff *skb)
 {
 	struct mld2_query *mlh2 = NULL;
 	struct ifmcaddr6 *ma;
-	struct in6_addr *group;
+	const struct in6_addr *group;
 	unsigned long max_delay;
 	struct inet6_dev *idev;
 	struct mld_msg *mld;
@@ -1821,7 +1821,7 @@ err_out:
 }
 
 static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
-	struct in6_addr *psfsrc)
+	const struct in6_addr *psfsrc)
 {
 	struct ip6_sf_list *psf, *psf_prev;
 	int rv = 0;
@@ -1857,8 +1857,8 @@ static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
 	return rv;
 }
 
-static int ip6_mc_del_src(struct inet6_dev *idev, struct in6_addr *pmca,
-			  int sfmode, int sfcount, struct in6_addr *psfsrc,
+static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
+			  int sfmode, int sfcount, const struct in6_addr *psfsrc,
 			  int delta)
 {
 	struct ifmcaddr6 *pmc;
@@ -1918,7 +1918,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, struct in6_addr *pmca,
  * Add multicast single-source filter to the interface list
  */
 static int ip6_mc_add1_src(struct ifmcaddr6 *pmc, int sfmode,
-	struct in6_addr *psfsrc, int delta)
+	const struct in6_addr *psfsrc, int delta)
 {
 	struct ip6_sf_list *psf, *psf_prev;
 
@@ -2021,8 +2021,8 @@ static int sf_setstate(struct ifmcaddr6 *pmc)
 /*
  * Add multicast source filter list to the interface list
  */
-static int ip6_mc_add_src(struct inet6_dev *idev, struct in6_addr *pmca,
-			  int sfmode, int sfcount, struct in6_addr *psfsrc,
+static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
+			  int sfmode, int sfcount, const struct in6_addr *psfsrc,
 			  int delta)
 {
 	struct ifmcaddr6 *pmc;
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 9b21048..43242e6 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -126,7 +126,7 @@ static struct mip6_report_rate_limiter mip6_report_rl = {
 
 static int mip6_destopt_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct ipv6_destopt_hdr *destopt = (struct ipv6_destopt_hdr *)skb->data;
 	int err = destopt->nexthdr;
 
@@ -181,8 +181,8 @@ static int mip6_destopt_output(struct xfrm_state *x, struct sk_buff *skb)
 }
 
 static inline int mip6_report_rl_allow(struct timeval *stamp,
-				       struct in6_addr *dst,
-				       struct in6_addr *src, int iif)
+				       const struct in6_addr *dst,
+				       const struct in6_addr *src, int iif)
 {
 	int allow = 0;
 
@@ -349,7 +349,7 @@ static const struct xfrm_type mip6_destopt_type =
 
 static int mip6_rthdr_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct rt2_hdr *rt2 = (struct rt2_hdr *)skb->data;
 	int err = rt2->rt_hdr.nexthdr;
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 01a0ffc..69aacd1 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -324,7 +324,7 @@ static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
 	return lladdr + prepad;
 }
 
-int ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *dev, int dir)
+int ndisc_mc_map(const struct in6_addr *addr, char *buf, struct net_device *dev, int dir)
 {
 	switch (dev->type) {
 	case ARPHRD_ETHER:
@@ -748,8 +748,8 @@ static int pndisc_is_router(const void *pkey,
 static void ndisc_recv_ns(struct sk_buff *skb)
 {
 	struct nd_msg *msg = (struct nd_msg *)skb_transport_header(skb);
-	struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
-	struct in6_addr *daddr = &ipv6_hdr(skb)->daddr;
+	const struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
+	const struct in6_addr *daddr = &ipv6_hdr(skb)->daddr;
 	u8 *lladdr = NULL;
 	u32 ndoptlen = skb->tail - (skb->transport_header +
 				    offsetof(struct nd_msg, opt));
@@ -924,8 +924,8 @@ out:
 static void ndisc_recv_na(struct sk_buff *skb)
 {
 	struct nd_msg *msg = (struct nd_msg *)skb_transport_header(skb);
-	struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
-	struct in6_addr *daddr = &ipv6_hdr(skb)->daddr;
+	const struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
+	const struct in6_addr *daddr = &ipv6_hdr(skb)->daddr;
 	u8 *lladdr = NULL;
 	u32 ndoptlen = skb->tail - (skb->transport_header +
 				    offsetof(struct nd_msg, opt));
@@ -1038,7 +1038,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 	unsigned long ndoptlen = skb->len - sizeof(*rs_msg);
 	struct neighbour *neigh;
 	struct inet6_dev *idev;
-	struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
+	const struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
 	struct ndisc_options ndopts;
 	u8 *lladdr = NULL;
 
@@ -1435,8 +1435,8 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 {
 	struct inet6_dev *in6_dev;
 	struct icmp6hdr *icmph;
-	struct in6_addr *dest;
-	struct in6_addr *target;	/* new first hop to destination */
+	const struct in6_addr *dest;
+	const struct in6_addr *target;	/* new first hop to destination */
 	struct neighbour *neigh;
 	int on_link = 0;
 	struct ndisc_options ndopts;
@@ -1469,7 +1469,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	}
 
 	icmph = icmp6_hdr(skb);
-	target = (struct in6_addr *) (icmph + 1);
+	target = (const struct in6_addr *) (icmph + 1);
 	dest = target + 1;
 
 	if (ipv6_addr_is_multicast(dest)) {
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 28bc1f6..30fcee4 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -13,7 +13,7 @@
 int ip6_route_me_harder(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct dst_entry *dst;
 	struct flowi6 fl6 = {
 		.flowi6_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0,
@@ -67,7 +67,7 @@ static void nf_ip6_saveroute(const struct sk_buff *skb,
 	struct ip6_rt_info *rt_info = nf_queue_entry_reroute(entry);
 
 	if (entry->hook == NF_INET_LOCAL_OUT) {
-		struct ipv6hdr *iph = ipv6_hdr(skb);
+		const struct ipv6hdr *iph = ipv6_hdr(skb);
 
 		rt_info->daddr = iph->daddr;
 		rt_info->saddr = iph->saddr;
@@ -81,7 +81,7 @@ static int nf_ip6_reroute(struct sk_buff *skb,
 	struct ip6_rt_info *rt_info = nf_queue_entry_reroute(entry);
 
 	if (entry->hook == NF_INET_LOCAL_OUT) {
-		struct ipv6hdr *iph = ipv6_hdr(skb);
+		const struct ipv6hdr *iph = ipv6_hdr(skb);
 		if (!ipv6_addr_equal(&iph->daddr, &rt_info->daddr) ||
 		    !ipv6_addr_equal(&iph->saddr, &rt_info->saddr) ||
 		    skb->mark != rt_info->mark)
@@ -108,7 +108,7 @@ static int nf_ip6_route(struct net *net, struct dst_entry **dst,
 __sum16 nf_ip6_checksum(struct sk_buff *skb, unsigned int hook,
 			     unsigned int dataoff, u_int8_t protocol)
 {
-	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	__sum16 csum = 0;
 
 	switch (skb->ip_summed) {
@@ -142,7 +142,7 @@ static __sum16 nf_ip6_checksum_partial(struct sk_buff *skb, unsigned int hook,
 				       unsigned int dataoff, unsigned int len,
 				       u_int8_t protocol)
 {
-	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	__wsum hsum;
 	__sum16 csum = 0;
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 4a1c3b4..e5e5425 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -67,8 +67,8 @@ static struct raw_hashinfo raw_v6_hashinfo = {
 };
 
 static struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
-		unsigned short num, struct in6_addr *loc_addr,
-		struct in6_addr *rmt_addr, int dif)
+		unsigned short num, const struct in6_addr *loc_addr,
+		const struct in6_addr *rmt_addr, int dif)
 {
 	struct hlist_node *node;
 	int is_multicast = ipv6_addr_is_multicast(loc_addr);
@@ -154,8 +154,8 @@ EXPORT_SYMBOL(rawv6_mh_filter_unregister);
  */
 static int ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 {
-	struct in6_addr *saddr;
-	struct in6_addr *daddr;
+	const struct in6_addr *saddr;
+	const struct in6_addr *daddr;
 	struct sock *sk;
 	int delivered = 0;
 	__u8 hash;
@@ -348,7 +348,7 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 {
 	struct sock *sk;
 	int hash;
-	struct in6_addr *saddr, *daddr;
+	const struct in6_addr *saddr, *daddr;
 	struct net *net;
 
 	hash = nexthdr & (RAW_HTABLE_SIZE - 1);
@@ -357,7 +357,7 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 	sk = sk_head(&raw_v6_hashinfo.ht[hash]);
 	if (sk != NULL) {
 		/* Note: ipv6_hdr(skb) != skb->data */
-		struct ipv6hdr *ip6h = (struct ipv6hdr *)skb->data;
+		const struct ipv6hdr *ip6h = (const struct ipv6hdr *)skb->data;
 		saddr = &ip6h->saddr;
 		daddr = &ip6h->daddr;
 		net = dev_net(skb->dev);
@@ -1231,7 +1231,7 @@ struct proto rawv6_prot = {
 static void raw6_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 {
 	struct ipv6_pinfo *np = inet6_sk(sp);
-	struct in6_addr *dest, *src;
+	const struct in6_addr *dest, *src;
 	__u16 destp, srcp;
 
 	dest  = &np->daddr;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 07beeb0..7b954e2 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -224,7 +224,7 @@ out:
 }
 
 static __inline__ struct frag_queue *
-fq_find(struct net *net, __be32 id, struct in6_addr *src, struct in6_addr *dst)
+fq_find(struct net *net, __be32 id, const struct in6_addr *src, const struct in6_addr *dst)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
@@ -535,7 +535,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 {
 	struct frag_hdr *fhdr;
 	struct frag_queue *fq;
-	struct ipv6hdr *hdr = ipv6_hdr(skb);
+	const struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMREQDS);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index af26cc1..852fc28 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -89,12 +89,12 @@ static void		ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
 static struct rt6_info *rt6_add_route_info(struct net *net,
-					   struct in6_addr *prefix, int prefixlen,
-					   struct in6_addr *gwaddr, int ifindex,
+					   const struct in6_addr *prefix, int prefixlen,
+					   const struct in6_addr *gwaddr, int ifindex,
 					   unsigned pref);
 static struct rt6_info *rt6_get_route_info(struct net *net,
-					   struct in6_addr *prefix, int prefixlen,
-					   struct in6_addr *gwaddr, int ifindex);
+					   const struct in6_addr *prefix, int prefixlen,
+					   const struct in6_addr *gwaddr, int ifindex);
 #endif
 
 static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
@@ -283,7 +283,7 @@ static __inline__ int rt6_check_expired(const struct rt6_info *rt)
 		time_after(jiffies, rt->rt6i_expires);
 }
 
-static inline int rt6_need_strict(struct in6_addr *daddr)
+static inline int rt6_need_strict(const struct in6_addr *daddr)
 {
 	return ipv6_addr_type(daddr) &
 		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
@@ -295,7 +295,7 @@ static inline int rt6_need_strict(struct in6_addr *daddr)
 
 static inline struct rt6_info *rt6_device_match(struct net *net,
 						    struct rt6_info *rt,
-						    struct in6_addr *saddr,
+						    const struct in6_addr *saddr,
 						    int oif,
 						    int flags)
 {
@@ -507,7 +507,7 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
 int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
-		  struct in6_addr *gwaddr)
+		  const struct in6_addr *gwaddr)
 {
 	struct net *net = dev_net(dev);
 	struct route_info *rinfo = (struct route_info *) opt;
@@ -670,8 +670,8 @@ int ip6_ins_rt(struct rt6_info *rt)
 	return __ip6_ins_rt(rt, &info);
 }
 
-static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, struct in6_addr *daddr,
-				      struct in6_addr *saddr)
+static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, const struct in6_addr *daddr,
+				      const struct in6_addr *saddr)
 {
 	struct rt6_info *rt;
 
@@ -739,7 +739,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, struct in6_addr *dad
 	return rt;
 }
 
-static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, struct in6_addr *daddr)
+static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, const struct in6_addr *daddr)
 {
 	struct rt6_info *rt = ip6_rt_copy(ort);
 	if (rt) {
@@ -830,7 +830,7 @@ static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *
 
 void ip6_route_input(struct sk_buff *skb)
 {
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct net *net = dev_net(skb->dev);
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
 	struct flowi6 fl6 = {
@@ -1272,7 +1272,7 @@ int ip6_route_add(struct fib6_config *cfg)
 	}
 
 	if (cfg->fc_flags & RTF_GATEWAY) {
-		struct in6_addr *gw_addr;
+		const struct in6_addr *gw_addr;
 		int gwa_type;
 
 		gw_addr = &cfg->fc_gateway;
@@ -1512,9 +1512,9 @@ out:
 	return rt;
 };
 
-static struct rt6_info *ip6_route_redirect(struct in6_addr *dest,
-					   struct in6_addr *src,
-					   struct in6_addr *gateway,
+static struct rt6_info *ip6_route_redirect(const struct in6_addr *dest,
+					   const struct in6_addr *src,
+					   const struct in6_addr *gateway,
 					   struct net_device *dev)
 {
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
@@ -1536,8 +1536,8 @@ static struct rt6_info *ip6_route_redirect(struct in6_addr *dest,
 						   flags, __ip6_route_redirect);
 }
 
-void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
-		  struct in6_addr *saddr,
+void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
+		  const struct in6_addr *saddr,
 		  struct neighbour *neigh, u8 *lladdr, int on_link)
 {
 	struct rt6_info *rt, *nrt = NULL;
@@ -1611,7 +1611,7 @@ out:
  *	i.e. Path MTU discovery
  */
 
-static void rt6_do_pmtu_disc(struct in6_addr *daddr, struct in6_addr *saddr,
+static void rt6_do_pmtu_disc(const struct in6_addr *daddr, const struct in6_addr *saddr,
 			     struct net *net, u32 pmtu, int ifindex)
 {
 	struct rt6_info *rt, *nrt;
@@ -1696,7 +1696,7 @@ out:
 	dst_release(&rt->dst);
 }
 
-void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr,
+void rt6_pmtu_discovery(const struct in6_addr *daddr, const struct in6_addr *saddr,
 			struct net_device *dev, u32 pmtu)
 {
 	struct net *net = dev_net(dev);
@@ -1756,8 +1756,8 @@ static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
 static struct rt6_info *rt6_get_route_info(struct net *net,
-					   struct in6_addr *prefix, int prefixlen,
-					   struct in6_addr *gwaddr, int ifindex)
+					   const struct in6_addr *prefix, int prefixlen,
+					   const struct in6_addr *gwaddr, int ifindex)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt = NULL;
@@ -1788,8 +1788,8 @@ out:
 }
 
 static struct rt6_info *rt6_add_route_info(struct net *net,
-					   struct in6_addr *prefix, int prefixlen,
-					   struct in6_addr *gwaddr, int ifindex,
+					   const struct in6_addr *prefix, int prefixlen,
+					   const struct in6_addr *gwaddr, int ifindex,
 					   unsigned pref)
 {
 	struct fib6_config cfg = {
@@ -1817,7 +1817,7 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 }
 #endif
 
-struct rt6_info *rt6_get_dflt_router(struct in6_addr *addr, struct net_device *dev)
+struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_device *dev)
 {
 	struct rt6_info *rt;
 	struct fib6_table *table;
@@ -1839,7 +1839,7 @@ struct rt6_info *rt6_get_dflt_router(struct in6_addr *addr, struct net_device *d
 	return rt;
 }
 
-struct rt6_info *rt6_add_dflt_router(struct in6_addr *gwaddr,
+struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 				     struct net_device *dev,
 				     unsigned int pref)
 {
@@ -2049,7 +2049,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 
 int ip6_route_get_saddr(struct net *net,
 			struct rt6_info *rt,
-			struct in6_addr *daddr,
+			const struct in6_addr *daddr,
 			unsigned int prefs,
 			struct in6_addr *saddr)
 {
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 43b3337..34d8964 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -452,7 +452,7 @@ out:
 }
 
 static int
-isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
+isatap_chksrc(struct sk_buff *skb, const struct iphdr *iph, struct ip_tunnel *t)
 {
 	struct ip_tunnel_prl_entry *p;
 	int ok = 1;
@@ -465,7 +465,8 @@ isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
 		else
 			skb->ndisc_nodetype = NDISC_NODETYPE_NODEFAULT;
 	} else {
-		struct in6_addr *addr6 = &ipv6_hdr(skb)->saddr;
+		const struct in6_addr *addr6 = &ipv6_hdr(skb)->saddr;
+
 		if (ipv6_addr_is_isatap(addr6) &&
 		    (addr6->s6_addr32[3] == iph->saddr) &&
 		    ipv6_chk_prefix(addr6, t->dev))
@@ -499,7 +500,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
    8 bytes of packet payload. It means, that precise relaying of
    ICMP in the real Internet is absolutely infeasible.
  */
-	struct iphdr *iph = (struct iphdr*)skb->data;
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct ip_tunnel *t;
@@ -557,7 +558,7 @@ out:
 	return err;
 }
 
-static inline void ipip6_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
+static inline void ipip6_ecn_decapsulate(const struct iphdr *iph, struct sk_buff *skb)
 {
 	if (INET_ECN_is_ce(iph->tos))
 		IP6_ECN_set_ce(ipv6_hdr(skb));
@@ -565,7 +566,7 @@ static inline void ipip6_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
 
 static int ipip6_rcv(struct sk_buff *skb)
 {
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	struct ip_tunnel *tunnel;
 
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
@@ -621,7 +622,7 @@ out:
  * comes from 6rd / 6to4 (RFC 3056) addr space.
  */
 static inline
-__be32 try_6rd(struct in6_addr *v6dst, struct ip_tunnel *tunnel)
+__be32 try_6rd(const struct in6_addr *v6dst, struct ip_tunnel *tunnel)
 {
 	__be32 dst = 0;
 
@@ -664,8 +665,8 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct pcpu_tstats *tstats;
-	struct iphdr  *tiph = &tunnel->parms.iph;
-	struct ipv6hdr *iph6 = ipv6_hdr(skb);
+	const struct iphdr  *tiph = &tunnel->parms.iph;
+	const struct ipv6hdr *iph6 = ipv6_hdr(skb);
 	u8     tos = tunnel->parms.iph.tos;
 	__be16 df = tiph->frag_off;
 	struct rtable *rt;     			/* Route to the other host */
@@ -674,7 +675,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	unsigned int max_headroom;		/* The extra header space needed */
 	__be32 dst = tiph->daddr;
 	int    mtu;
-	struct in6_addr *addr6;
+	const struct in6_addr *addr6;
 	int addr_type;
 
 	if (skb->protocol != htons(ETH_P_IPV6))
@@ -693,7 +694,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			goto tx_error;
 		}
 
-		addr6 = (struct in6_addr*)&neigh->primary_key;
+		addr6 = (const struct in6_addr*)&neigh->primary_key;
 		addr_type = ipv6_addr_type(addr6);
 
 		if ((addr_type & IPV6_ADDR_UNICAST) &&
@@ -718,7 +719,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			goto tx_error;
 		}
 
-		addr6 = (struct in6_addr*)&neigh->primary_key;
+		addr6 = (const struct in6_addr*)&neigh->primary_key;
 		addr_type = ipv6_addr_type(addr6);
 
 		if (addr_type == IPV6_ADDR_ANY) {
@@ -849,7 +850,7 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
 	struct ip_tunnel *tunnel;
-	struct iphdr *iph;
+	const struct iphdr *iph;
 
 	tunnel = netdev_priv(dev);
 	iph = &tunnel->parms.iph;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 352c260..8b9644a 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -66,7 +66,7 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
 		      ipv6_cookie_scratch);
 
-static u32 cookie_hash(struct in6_addr *saddr, struct in6_addr *daddr,
+static u32 cookie_hash(const struct in6_addr *saddr, const struct in6_addr *daddr,
 		       __be16 sport, __be16 dport, u32 count, int c)
 {
 	__u32 *tmp = __get_cpu_var(ipv6_cookie_scratch);
@@ -86,7 +86,8 @@ static u32 cookie_hash(struct in6_addr *saddr, struct in6_addr *daddr,
 	return tmp[17];
 }
 
-static __u32 secure_tcp_syn_cookie(struct in6_addr *saddr, struct in6_addr *daddr,
+static __u32 secure_tcp_syn_cookie(const struct in6_addr *saddr,
+				   const struct in6_addr *daddr,
 				   __be16 sport, __be16 dport, __u32 sseq,
 				   __u32 count, __u32 data)
 {
@@ -96,8 +97,8 @@ static __u32 secure_tcp_syn_cookie(struct in6_addr *saddr, struct in6_addr *dadd
 		& COOKIEMASK));
 }
 
-static __u32 check_tcp_syn_cookie(__u32 cookie, struct in6_addr *saddr,
-				  struct in6_addr *daddr, __be16 sport,
+static __u32 check_tcp_syn_cookie(__u32 cookie, const struct in6_addr *saddr,
+				  const struct in6_addr *daddr, __be16 sport,
 				  __be16 dport, __u32 sseq, __u32 count,
 				  __u32 maxdiff)
 {
@@ -116,7 +117,7 @@ static __u32 check_tcp_syn_cookie(__u32 cookie, struct in6_addr *saddr,
 
 __u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 {
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	const struct tcphdr *th = tcp_hdr(skb);
 	int mssind;
 	const __u16 mss = *mssp;
@@ -138,7 +139,7 @@ __u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 
 static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 {
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	const struct tcphdr *th = tcp_hdr(skb);
 	__u32 seq = ntohl(th->seq) - 1;
 	__u32 mssind = check_tcp_syn_cookie(cookie, &iph->saddr, &iph->daddr,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4f49e5d..cb7658a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -76,8 +76,8 @@ static void	tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 
 static int	tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb);
 static void	__tcp_v6_send_check(struct sk_buff *skb,
-				    struct in6_addr *saddr,
-				    struct in6_addr *daddr);
+				    const struct in6_addr *saddr,
+				    const struct in6_addr *daddr);
 
 static const struct inet_connection_sock_af_ops ipv6_mapped;
 static const struct inet_connection_sock_af_ops ipv6_specific;
@@ -86,7 +86,7 @@ static const struct tcp_sock_af_ops tcp_sock_ipv6_specific;
 static const struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
 #else
 static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
-						   struct in6_addr *addr)
+						   const struct in6_addr *addr)
 {
 	return NULL;
 }
@@ -106,8 +106,8 @@ static void tcp_v6_hash(struct sock *sk)
 }
 
 static __inline__ __sum16 tcp_v6_check(int len,
-				   struct in6_addr *saddr,
-				   struct in6_addr *daddr,
+				   const struct in6_addr *saddr,
+				   const struct in6_addr *daddr,
 				   __wsum base)
 {
 	return csum_ipv6_magic(saddr, daddr, len, IPPROTO_TCP, base);
@@ -331,7 +331,7 @@ failure:
 static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		u8 type, u8 code, int offset, __be32 info)
 {
-	struct ipv6hdr *hdr = (struct ipv6hdr*)skb->data;
+	const struct ipv6hdr *hdr = (const struct ipv6hdr*)skb->data;
 	const struct tcphdr *th = (struct tcphdr *)(skb->data+offset);
 	struct ipv6_pinfo *np;
 	struct sock *sk;
@@ -551,7 +551,7 @@ static void tcp_v6_reqsk_destructor(struct request_sock *req)
 
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
-						   struct in6_addr *addr)
+						   const struct in6_addr *addr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int i;
@@ -580,7 +580,7 @@ static struct tcp_md5sig_key *tcp_v6_reqsk_md5_lookup(struct sock *sk,
 	return tcp_v6_md5_do_lookup(sk, &inet6_rsk(req)->rmt_addr);
 }
 
-static int tcp_v6_md5_do_add(struct sock *sk, struct in6_addr *peer,
+static int tcp_v6_md5_do_add(struct sock *sk, const struct in6_addr *peer,
 			     char *newkey, u8 newkeylen)
 {
 	/* Add key to the list */
@@ -645,7 +645,7 @@ static int tcp_v6_md5_add_func(struct sock *sk, struct sock *addr_sk,
 				 newkey, newkeylen);
 }
 
-static int tcp_v6_md5_do_del(struct sock *sk, struct in6_addr *peer)
+static int tcp_v6_md5_do_del(struct sock *sk, const struct in6_addr *peer)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int i;
@@ -753,8 +753,8 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 }
 
 static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
-					struct in6_addr *daddr,
-					struct in6_addr *saddr, int nbytes)
+					const struct in6_addr *daddr,
+					const struct in6_addr *saddr, int nbytes)
 {
 	struct tcp6_pseudohdr *bp;
 	struct scatterlist sg;
@@ -771,7 +771,7 @@ static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 }
 
 static int tcp_v6_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
-			       struct in6_addr *daddr, struct in6_addr *saddr,
+			       const struct in6_addr *daddr, struct in6_addr *saddr,
 			       struct tcphdr *th)
 {
 	struct tcp_md5sig_pool *hp;
@@ -807,7 +807,7 @@ static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 			       struct sock *sk, struct request_sock *req,
 			       struct sk_buff *skb)
 {
-	struct in6_addr *saddr, *daddr;
+	const struct in6_addr *saddr, *daddr;
 	struct tcp_md5sig_pool *hp;
 	struct hash_desc *desc;
 	struct tcphdr *th = tcp_hdr(skb);
@@ -819,7 +819,7 @@ static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 		saddr = &inet6_rsk(req)->loc_addr;
 		daddr = &inet6_rsk(req)->rmt_addr;
 	} else {
-		struct ipv6hdr *ip6h = ipv6_hdr(skb);
+		const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 		saddr = &ip6h->saddr;
 		daddr = &ip6h->daddr;
 	}
@@ -857,7 +857,7 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 {
 	__u8 *hash_location = NULL;
 	struct tcp_md5sig_key *hash_expected;
-	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
 	int genhash;
 	u8 newhash[16];
@@ -915,7 +915,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 #endif
 
 static void __tcp_v6_send_check(struct sk_buff *skb,
-				struct in6_addr *saddr, struct in6_addr *daddr)
+				const struct in6_addr *saddr, const struct in6_addr *daddr)
 {
 	struct tcphdr *th = tcp_hdr(skb);
 
@@ -939,7 +939,7 @@ static void tcp_v6_send_check(struct sock *sk, struct sk_buff *skb)
 
 static int tcp_v6_gso_send_check(struct sk_buff *skb)
 {
-	struct ipv6hdr *ipv6h;
+	const struct ipv6hdr *ipv6h;
 	struct tcphdr *th;
 
 	if (!pskb_may_pull(skb, sizeof(*th)))
@@ -957,7 +957,7 @@ static int tcp_v6_gso_send_check(struct sk_buff *skb)
 static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
-	struct ipv6hdr *iph = skb_gro_network_header(skb);
+	const struct ipv6hdr *iph = skb_gro_network_header(skb);
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
@@ -978,7 +978,7 @@ static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
 
 static int tcp6_gro_complete(struct sk_buff *skb)
 {
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
 
 	th->check = ~tcp_v6_check(skb->len - skb_transport_offset(skb),
@@ -1702,7 +1702,7 @@ ipv6_pktoptions:
 static int tcp_v6_rcv(struct sk_buff *skb)
 {
 	struct tcphdr *th;
-	struct ipv6hdr *hdr;
+	const struct ipv6hdr *hdr;
 	struct sock *sk;
 	int ret;
 	struct net *net = dev_net(skb->dev);
@@ -2028,8 +2028,8 @@ static void get_openreq6(struct seq_file *seq,
 			 struct sock *sk, struct request_sock *req, int i, int uid)
 {
 	int ttd = req->expires - jiffies;
-	struct in6_addr *src = &inet6_rsk(req)->loc_addr;
-	struct in6_addr *dest = &inet6_rsk(req)->rmt_addr;
+	const struct in6_addr *src = &inet6_rsk(req)->loc_addr;
+	const struct in6_addr *dest = &inet6_rsk(req)->rmt_addr;
 
 	if (ttd < 0)
 		ttd = 0;
@@ -2057,7 +2057,7 @@ static void get_openreq6(struct seq_file *seq,
 
 static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 {
-	struct in6_addr *dest, *src;
+	const struct in6_addr *dest, *src;
 	__u16 destp, srcp;
 	int timer_active;
 	unsigned long timer_expires;
@@ -2114,7 +2114,7 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 static void get_timewait6_sock(struct seq_file *seq,
 			       struct inet_timewait_sock *tw, int i)
 {
-	struct in6_addr *dest, *src;
+	const struct in6_addr *dest, *src;
 	__u16 destp, srcp;
 	struct inet6_timewait_sock *tw6 = inet6_twsk((struct sock *)tw);
 	int ttd = tw->tw_ttd - jiffies;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 15c3774..1bdc5f0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -311,7 +311,7 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 					  struct udp_table *udptable)
 {
 	struct sock *sk;
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
 
 	if (unlikely(sk = skb_steal_sock(skb)))
 		return sk;
@@ -463,9 +463,9 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		    struct udp_table *udptable)
 {
 	struct ipv6_pinfo *np;
-	struct ipv6hdr *hdr = (struct ipv6hdr*)skb->data;
-	struct in6_addr *saddr = &hdr->saddr;
-	struct in6_addr *daddr = &hdr->daddr;
+	const struct ipv6hdr *hdr = (const struct ipv6hdr *)skb->data;
+	const struct in6_addr *saddr = &hdr->saddr;
+	const struct in6_addr *daddr = &hdr->daddr;
 	struct udphdr *uh = (struct udphdr*)(skb->data+offset);
 	struct sock *sk;
 	int err;
@@ -553,8 +553,8 @@ drop_no_sk_drops_inc:
 }
 
 static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
-				      __be16 loc_port, struct in6_addr *loc_addr,
-				      __be16 rmt_port, struct in6_addr *rmt_addr,
+				      __be16 loc_port, const struct in6_addr *loc_addr,
+				      __be16 rmt_port, const struct in6_addr *rmt_addr,
 				      int dif)
 {
 	struct hlist_nulls_node *node;
@@ -633,7 +633,7 @@ drop:
  * so we don't need to lock the hashes.
  */
 static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
-		struct in6_addr *saddr, struct in6_addr *daddr,
+		const struct in6_addr *saddr, const struct in6_addr *daddr,
 		struct udp_table *udptable)
 {
 	struct sock *sk, *stack[256 / sizeof(struct sock *)];
@@ -716,7 +716,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	struct net *net = dev_net(skb->dev);
 	struct sock *sk;
 	struct udphdr *uh;
-	struct in6_addr *saddr, *daddr;
+	const struct in6_addr *saddr, *daddr;
 	u32 ulen = 0;
 
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
@@ -1278,7 +1278,7 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 
 static int udp6_ufo_send_check(struct sk_buff *skb)
 {
-	struct ipv6hdr *ipv6h;
+	const struct ipv6hdr *ipv6h;
 	struct udphdr *uh;
 
 	if (!pskb_may_pull(skb, sizeof(*uh)))
@@ -1382,7 +1382,7 @@ static void udp6_sock_seq_show(struct seq_file *seq, struct sock *sp, int bucket
 {
 	struct inet_sock *inet = inet_sk(sp);
 	struct ipv6_pinfo *np = inet6_sk(sp);
-	struct in6_addr *dest, *src;
+	const struct in6_addr *dest, *src;
 	__u16 destp, srcp;
 
 	dest  = &np->daddr;
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index bbd48b1..3437d7d 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -41,10 +41,8 @@ static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *top_iph;
 	struct ip_beet_phdr *ph;
-	struct iphdr *iphv4;
 	int optlen, hdr_len;
 
-	iphv4 = ip_hdr(skb);
 	hdr_len = 0;
 	optlen = XFRM_MODE_SKB_CB(skb)->optlen;
 	if (unlikely(optlen))
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 645cb96..4d6edff 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -20,7 +20,7 @@
 
 static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
 {
-	struct ipv6hdr *outer_iph = ipv6_hdr(skb);
+	const struct ipv6hdr *outer_iph = ipv6_hdr(skb);
 	struct ipv6hdr *inner_iph = ipipv6_hdr(skb);
 
 	if (INET_ECN_is_ce(ipv6_get_dsfield(outer_iph)))
@@ -55,8 +55,8 @@ static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 		dsfield &= ~INET_ECN_MASK;
 	ipv6_change_dsfield(top_iph, 0, dsfield);
 	top_iph->hop_limit = ip6_dst_hoplimit(dst->child);
-	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
-	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
+	ipv6_addr_copy(&top_iph->saddr, (const struct in6_addr *)&x->props.saddr);
+	ipv6_addr_copy(&top_iph->daddr, (const struct in6_addr *)&x->id.daddr);
 	return 0;
 }
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 05e34c8..d879f7e 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -124,7 +124,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	struct flowi6 *fl6 = &fl->u.ip6;
 	int onlyproto = 0;
 	u16 offset = skb_network_header_len(skb);
-	struct ipv6hdr *hdr = ipv6_hdr(skb);
+	const struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct ipv6_opt_hdr *exthdr;
 	const unsigned char *nh = skb_network_header(skb);
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 2969cad..a6770a0 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -68,7 +68,7 @@ static DEFINE_SPINLOCK(xfrm6_tunnel_spi_lock);
 
 static struct kmem_cache *xfrm6_tunnel_spi_kmem __read_mostly;
 
-static inline unsigned xfrm6_tunnel_spi_hash_byaddr(xfrm_address_t *addr)
+static inline unsigned xfrm6_tunnel_spi_hash_byaddr(const xfrm_address_t *addr)
 {
 	unsigned h;
 
@@ -85,7 +85,7 @@ static inline unsigned xfrm6_tunnel_spi_hash_byspi(u32 spi)
 	return spi % XFRM6_TUNNEL_SPI_BYSPI_HSIZE;
 }
 
-static struct xfrm6_tunnel_spi *__xfrm6_tunnel_spi_lookup(struct net *net, xfrm_address_t *saddr)
+static struct xfrm6_tunnel_spi *__xfrm6_tunnel_spi_lookup(struct net *net, const xfrm_address_t *saddr)
 {
 	struct xfrm6_tunnel_net *xfrm6_tn = xfrm6_tunnel_pernet(net);
 	struct xfrm6_tunnel_spi *x6spi;
@@ -101,7 +101,7 @@ static struct xfrm6_tunnel_spi *__xfrm6_tunnel_spi_lookup(struct net *net, xfrm_
 	return NULL;
 }
 
-__be32 xfrm6_tunnel_spi_lookup(struct net *net, xfrm_address_t *saddr)
+__be32 xfrm6_tunnel_spi_lookup(struct net *net, const xfrm_address_t *saddr)
 {
 	struct xfrm6_tunnel_spi *x6spi;
 	u32 spi;
@@ -237,10 +237,10 @@ static int xfrm6_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 static int xfrm6_tunnel_rcv(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	__be32 spi;
 
-	spi = xfrm6_tunnel_spi_lookup(net, (xfrm_address_t *)&iph->saddr);
+	spi = xfrm6_tunnel_spi_lookup(net, (const xfrm_address_t *)&iph->saddr);
 	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi) > 0 ? : 0;
 }
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 7db86ff..d62401c 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -712,7 +712,7 @@ static unsigned int pfkey_sockaddr_fill(const xfrm_address_t *xaddr, __be16 port
 		sin6->sin6_family = AF_INET6;
 		sin6->sin6_port = port;
 		sin6->sin6_flowinfo = 0;
-		ipv6_addr_copy(&sin6->sin6_addr, (struct in6_addr *)xaddr->a6);
+		ipv6_addr_copy(&sin6->sin6_addr, (const struct in6_addr *)xaddr->a6);
 		sin6->sin6_scope_id = 0;
 		return 128;
 	    }
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index c2e628d..7ef87f9 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -169,7 +169,7 @@ static unsigned int sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 	}
 	case htons(ETH_P_IPV6):
 	{
-		struct ipv6hdr *iph;
+		const struct ipv6hdr *iph;
 		int poff;
 
 		if (!pskb_network_may_pull(skb, sizeof(*iph)))
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 3a8eb79..741ed16 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -565,7 +565,7 @@ void sctp_err_finish(struct sock *sk, struct sctp_association *asoc)
  */
 void sctp_v4_err(struct sk_buff *skb, __u32 info)
 {
-	struct iphdr *iph = (struct iphdr *)skb->data;
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
 	const int ihlen = iph->ihl * 4;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 865ce7b..321f175 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -531,7 +531,7 @@ static int sctp_v6_is_any(const union sctp_addr *addr)
 static int sctp_v6_available(union sctp_addr *addr, struct sctp_sock *sp)
 {
 	int type;
-	struct in6_addr *in6 = (struct in6_addr *)&addr->v6.sin6_addr;
+	const struct in6_addr *in6 = (const struct in6_addr *)&addr->v6.sin6_addr;
 
 	type = ipv6_addr_type(in6);
 	if (IPV6_ADDR_ANY == type)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index dd78536..d70f85e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1036,15 +1036,15 @@ static struct xfrm_state *__find_acq_core(struct net *net, struct xfrm_mark *m,
 
 		case AF_INET6:
 			ipv6_addr_copy((struct in6_addr *)x->sel.daddr.a6,
-				       (struct in6_addr *)daddr);
+				       (const struct in6_addr *)daddr);
 			ipv6_addr_copy((struct in6_addr *)x->sel.saddr.a6,
-				       (struct in6_addr *)saddr);
+				       (const struct in6_addr *)saddr);
 			x->sel.prefixlen_d = 128;
 			x->sel.prefixlen_s = 128;
 			ipv6_addr_copy((struct in6_addr *)x->props.saddr.a6,
-				       (struct in6_addr *)saddr);
+				       (const struct in6_addr *)saddr);
 			ipv6_addr_copy((struct in6_addr *)x->id.daddr.a6,
-				       (struct in6_addr *)daddr);
+				       (const struct in6_addr *)daddr);
 			break;
 		}
 
@@ -2092,8 +2092,8 @@ static void xfrm_audit_helper_sainfo(struct xfrm_state *x,
 static void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
 				      struct audit_buffer *audit_buf)
 {
-	struct iphdr *iph4;
-	struct ipv6hdr *iph6;
+	const struct iphdr *iph4;
+	const struct ipv6hdr *iph6;
 
 	switch (family) {
 	case AF_INET:


