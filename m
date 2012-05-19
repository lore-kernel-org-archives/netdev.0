From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: bool/const conversions phase2
Date: Sat, 19 May 2012 06:57:34 +0200
Message-ID: <1337403454.7029.62.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:42144 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991Ab2ESE5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 00:57:40 -0400
Received: by wgbdr13 with SMTP id dr13so3334384wgb.1
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 21:57:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Mostly bool conversions, some inline removals and const additions.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/addrconf.h   |   18 +++++-----
 include/net/ip6_route.h  |    2 -
 include/net/ipv6.h       |    2 -
 include/net/rawv6.h      |    2 -
 net/ipv6/addrlabel.c     |   24 ++++++-------
 net/ipv6/ah6.c           |    6 +--
 net/ipv6/anycast.c       |   12 +++---
 net/ipv6/datagram.c      |    4 +-
 net/ipv6/exthdrs.c       |   54 +++++++++++++++---------------
 net/ipv6/exthdrs_core.c  |    2 -
 net/ipv6/icmp.c          |   14 +++----
 net/ipv6/ip6_flowlabel.c |   24 ++++++-------
 net/ipv6/ip6_input.c     |    9 ++---
 net/ipv6/mcast.c         |   66 ++++++++++++++++++-------------------
 net/ipv6/ndisc.c         |    4 +-
 net/ipv6/raw.c           |   10 ++---
 net/ipv6/route.c         |    8 ++--
 17 files changed, 131 insertions(+), 130 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 27f450b..f2b801c 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -131,9 +131,9 @@ extern int ipv6_sock_mc_join(struct sock *sk, int ifindex,
 extern int ipv6_sock_mc_drop(struct sock *sk, int ifindex,
 			     const struct in6_addr *addr);
 extern void ipv6_sock_mc_close(struct sock *sk);
-extern int inet6_mc_check(struct sock *sk,
-			  const struct in6_addr *mc_addr,
-			  const struct in6_addr *src_addr);
+extern bool inet6_mc_check(struct sock *sk,
+			   const struct in6_addr *mc_addr,
+			   const struct in6_addr *src_addr);
 
 extern int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr);
 extern int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr);
@@ -146,10 +146,10 @@ extern void ipv6_mc_init_dev(struct inet6_dev *idev);
 extern void ipv6_mc_destroy_dev(struct inet6_dev *idev);
 extern void addrconf_dad_failure(struct inet6_ifaddr *ifp);
 
-extern int ipv6_chk_mcast_addr(struct net_device *dev,
-			       const struct in6_addr *group,
-			       const struct in6_addr *src_addr);
-extern int ipv6_is_mld(struct sk_buff *skb, int nexthdr);
+extern bool ipv6_chk_mcast_addr(struct net_device *dev,
+				const struct in6_addr *group,
+				const struct in6_addr *src_addr);
+extern bool ipv6_is_mld(struct sk_buff *skb, int nexthdr);
 
 extern void addrconf_prefix_rcv(struct net_device *dev,
 				u8 *opt, int len, bool sllao);
@@ -163,8 +163,8 @@ extern void ipv6_sock_ac_close(struct sock *sk);
 
 extern int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr);
 extern int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
-extern int ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
-			       const struct in6_addr *addr);
+extern bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
+				const struct in6_addr *addr);
 
 
 /* Device notifier */
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index c062b67..37c1a1e 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -175,7 +175,7 @@ static inline void ip6_dst_store(struct sock *sk, struct dst_entry *dst,
 	spin_unlock(&sk->sk_dst_lock);
 }
 
-static inline int ipv6_unicast_destination(struct sk_buff *skb)
+static inline bool ipv6_unicast_destination(const struct sk_buff *skb)
 {
 	struct rt6_info *rt = (struct rt6_info *) skb_dst(skb);
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 1402139..aecf884 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -559,7 +559,7 @@ extern void			ipv6_push_frag_opts(struct sk_buff *skb,
 extern int			ipv6_skip_exthdr(const struct sk_buff *, int start,
 					         u8 *nexthdrp, __be16 *frag_offp);
 
-extern int 			ipv6_ext_hdr(u8 nexthdr);
+extern bool			ipv6_ext_hdr(u8 nexthdr);
 
 extern int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
 
diff --git a/include/net/rawv6.h b/include/net/rawv6.h
index cf75772..e7ea660 100644
--- a/include/net/rawv6.h
+++ b/include/net/rawv6.h
@@ -5,7 +5,7 @@
 
 void raw6_icmp_error(struct sk_buff *, int nexthdr,
 		u8 type, u8 code, int inner_offset, __be32);
-int raw6_local_deliver(struct sk_buff *, int);
+bool raw6_local_deliver(struct sk_buff *, int);
 
 extern int			rawv6_rcv(struct sock *sk,
 					  struct sk_buff *skb);
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 95aea16..eb6a636 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -129,7 +129,7 @@ static void ip6addrlbl_free_rcu(struct rcu_head *h)
 	ip6addrlbl_free(container_of(h, struct ip6addrlbl_entry, rcu));
 }
 
-static inline int ip6addrlbl_hold(struct ip6addrlbl_entry *p)
+static bool ip6addrlbl_hold(struct ip6addrlbl_entry *p)
 {
 	return atomic_inc_not_zero(&p->refcnt);
 }
@@ -141,20 +141,20 @@ static inline void ip6addrlbl_put(struct ip6addrlbl_entry *p)
 }
 
 /* Find label */
-static int __ip6addrlbl_match(struct net *net,
-			      struct ip6addrlbl_entry *p,
-			      const struct in6_addr *addr,
-			      int addrtype, int ifindex)
+static bool __ip6addrlbl_match(struct net *net,
+			       const struct ip6addrlbl_entry *p,
+			       const struct in6_addr *addr,
+			       int addrtype, int ifindex)
 {
 	if (!net_eq(ip6addrlbl_net(p), net))
-		return 0;
+		return false;
 	if (p->ifindex && p->ifindex != ifindex)
-		return 0;
+		return false;
 	if (p->addrtype && p->addrtype != addrtype)
-		return 0;
+		return false;
 	if (!ipv6_prefix_equal(addr, &p->prefix, p->prefixlen))
-		return 0;
-	return 1;
+		return false;
+	return true;
 }
 
 static struct ip6addrlbl_entry *__ipv6_addr_label(struct net *net,
@@ -456,8 +456,8 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return err;
 }
 
-static inline void ip6addrlbl_putmsg(struct nlmsghdr *nlh,
-				     int prefixlen, int ifindex, u32 lseq)
+static void ip6addrlbl_putmsg(struct nlmsghdr *nlh,
+			      int prefixlen, int ifindex, u32 lseq)
 {
 	struct ifaddrlblmsg *ifal = nlmsg_data(nlh);
 	ifal->ifal_family = AF_INET6;
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 5d32e7a..f1a4a2c 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -113,7 +113,7 @@ static inline struct scatterlist *ah_req_sg(struct crypto_ahash *ahash,
 			     __alignof__(struct scatterlist));
 }
 
-static int zero_out_mutable_opts(struct ipv6_opt_hdr *opthdr)
+static bool zero_out_mutable_opts(struct ipv6_opt_hdr *opthdr)
 {
 	u8 *opt = (u8 *)opthdr;
 	int len = ipv6_optlen(opthdr);
@@ -145,10 +145,10 @@ static int zero_out_mutable_opts(struct ipv6_opt_hdr *opthdr)
 		len -= optlen;
 	}
 	if (len == 0)
-		return 1;
+		return true;
 
 bad:
-	return 0;
+	return false;
 }
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index db00d27..cdf02be 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -342,7 +342,7 @@ static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr)
  *	check if the interface has this anycast address
  *	called with rcu_read_lock()
  */
-static int ipv6_chk_acast_dev(struct net_device *dev, const struct in6_addr *addr)
+static bool ipv6_chk_acast_dev(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct inet6_dev *idev;
 	struct ifacaddr6 *aca;
@@ -356,16 +356,16 @@ static int ipv6_chk_acast_dev(struct net_device *dev, const struct in6_addr *add
 		read_unlock_bh(&idev->lock);
 		return aca != NULL;
 	}
-	return 0;
+	return false;
 }
 
 /*
  *	check if given interface (or any, if dev==0) has this anycast address
  */
-int ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
-			const struct in6_addr *addr)
+bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
+			 const struct in6_addr *addr)
 {
-	int found = 0;
+	bool found = false;
 
 	rcu_read_lock();
 	if (dev)
@@ -373,7 +373,7 @@ int ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 	else
 		for_each_netdev_rcu(net, dev)
 			if (ipv6_chk_acast_dev(dev, addr)) {
-				found = 1;
+				found = true;
 				break;
 			}
 	rcu_read_unlock();
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index b8b61ac..be2b67d6 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -34,9 +34,9 @@
 #include <linux/errqueue.h>
 #include <asm/uaccess.h>
 
-static inline int ipv6_mapped_addr_any(const struct in6_addr *a)
+static bool ipv6_mapped_addr_any(const struct in6_addr *a)
 {
-	return (ipv6_addr_v4mapped(a) && (a->s6_addr32[3] == 0));
+	return ipv6_addr_v4mapped(a) && (a->s6_addr32[3] == 0);
 }
 
 int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index a3cded6..50ec95f 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -96,14 +96,14 @@ EXPORT_SYMBOL_GPL(ipv6_find_tlv);
 /*
  *	Parsing tlv encoded headers.
  *
- *	Parsing function "func" returns 1, if parsing succeed
- *	and 0, if it failed.
+ *	Parsing function "func" returns true, if parsing succeed
+ *	and false, if it failed.
  *	It MUST NOT touch skb->h.
  */
 
 struct tlvtype_proc {
 	int	type;
-	int	(*func)(struct sk_buff *skb, int offset);
+	bool	(*func)(struct sk_buff *skb, int offset);
 };
 
 /*********************
@@ -112,11 +112,11 @@ struct tlvtype_proc {
 
 /* An unknown option is detected, decide what to do */
 
-static int ip6_tlvopt_unknown(struct sk_buff *skb, int optoff)
+static bool ip6_tlvopt_unknown(struct sk_buff *skb, int optoff)
 {
 	switch ((skb_network_header(skb)[optoff] & 0xC0) >> 6) {
 	case 0: /* ignore */
-		return 1;
+		return true;
 
 	case 1: /* drop packet */
 		break;
@@ -129,18 +129,18 @@ static int ip6_tlvopt_unknown(struct sk_buff *skb, int optoff)
 			break;
 	case 2: /* send ICMP PARM PROB regardless and drop packet */
 		icmpv6_param_prob(skb, ICMPV6_UNK_OPTION, optoff);
-		return 0;
+		return false;
 	}
 
 	kfree_skb(skb);
-	return 0;
+	return false;
 }
 
 /* Parse tlv encoded option header (hop-by-hop or destination) */
 
-static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff *skb)
+static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
 {
-	struct tlvtype_proc *curr;
+	const struct tlvtype_proc *curr;
 	const unsigned char *nh = skb_network_header(skb);
 	int off = skb_network_header_len(skb);
 	int len = (skb_transport_header(skb)[1] + 1) << 3;
@@ -186,14 +186,14 @@ static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff *skb)
 					/* type specific length/alignment
 					   checks will be performed in the
 					   func(). */
-					if (curr->func(skb, off) == 0)
-						return 0;
+					if (curr->func(skb, off) == false)
+						return false;
 					break;
 				}
 			}
 			if (curr->type < 0) {
 				if (ip6_tlvopt_unknown(skb, off) == 0)
-					return 0;
+					return false;
 			}
 			break;
 		}
@@ -201,10 +201,10 @@ static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff *skb)
 		len -= optlen;
 	}
 	if (len == 0)
-		return 1;
+		return true;
 bad:
 	kfree_skb(skb);
-	return 0;
+	return false;
 }
 
 /*****************************
@@ -212,7 +212,7 @@ bad:
  *****************************/
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
-static int ipv6_dest_hao(struct sk_buff *skb, int optoff)
+static bool ipv6_dest_hao(struct sk_buff *skb, int optoff)
 {
 	struct ipv6_destopt_hao *hao;
 	struct inet6_skb_parm *opt = IP6CB(skb);
@@ -266,15 +266,15 @@ static int ipv6_dest_hao(struct sk_buff *skb, int optoff)
 	if (skb->tstamp.tv64 == 0)
 		__net_timestamp(skb);
 
-	return 1;
+	return true;
 
  discard:
 	kfree_skb(skb);
-	return 0;
+	return false;
 }
 #endif
 
-static struct tlvtype_proc tlvprocdestopt_lst[] = {
+static const struct tlvtype_proc tlvprocdestopt_lst[] = {
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	{
 		.type	= IPV6_TLV_HAO,
@@ -579,23 +579,23 @@ static inline struct net *ipv6_skb_net(struct sk_buff *skb)
 
 /* Router Alert as of RFC 2711 */
 
-static int ipv6_hop_ra(struct sk_buff *skb, int optoff)
+static bool ipv6_hop_ra(struct sk_buff *skb, int optoff)
 {
 	const unsigned char *nh = skb_network_header(skb);
 
 	if (nh[optoff + 1] == 2) {
 		IP6CB(skb)->ra = optoff;
-		return 1;
+		return true;
 	}
 	LIMIT_NETDEBUG(KERN_DEBUG "ipv6_hop_ra: wrong RA length %d\n",
 		       nh[optoff + 1]);
 	kfree_skb(skb);
-	return 0;
+	return false;
 }
 
 /* Jumbo payload */
 
-static int ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
+static bool ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
 {
 	const unsigned char *nh = skb_network_header(skb);
 	struct net *net = ipv6_skb_net(skb);
@@ -614,13 +614,13 @@ static int ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
 		IP6_INC_STATS_BH(net, ipv6_skb_idev(skb),
 				 IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff+2);
-		return 0;
+		return false;
 	}
 	if (ipv6_hdr(skb)->payload_len) {
 		IP6_INC_STATS_BH(net, ipv6_skb_idev(skb),
 				 IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff);
-		return 0;
+		return false;
 	}
 
 	if (pkt_len > skb->len - sizeof(struct ipv6hdr)) {
@@ -632,14 +632,14 @@ static int ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
 	if (pskb_trim_rcsum(skb, pkt_len + sizeof(struct ipv6hdr)))
 		goto drop;
 
-	return 1;
+	return true;
 
 drop:
 	kfree_skb(skb);
-	return 0;
+	return false;
 }
 
-static struct tlvtype_proc tlvprochopopt_lst[] = {
+static const struct tlvtype_proc tlvprochopopt_lst[] = {
 	{
 		.type	= IPV6_TLV_ROUTERALERT,
 		.func	= ipv6_hop_ra,
diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 7b1a884..f73d59a 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -9,7 +9,7 @@
  * find out if nexthdr is a well-known extension header or a protocol
  */
 
-int ipv6_ext_hdr(u8 nexthdr)
+bool ipv6_ext_hdr(u8 nexthdr)
 {
 	/*
 	 * find out if nexthdr is an extension header or a protocol
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 23c56ce..091a297 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -131,7 +131,7 @@ void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
  *	--ANK (980726)
  */
 
-static int is_ineligible(struct sk_buff *skb)
+static bool is_ineligible(const struct sk_buff *skb)
 {
 	int ptr = (u8 *)(ipv6_hdr(skb) + 1) - skb->data;
 	int len = skb->len - ptr;
@@ -139,11 +139,11 @@ static int is_ineligible(struct sk_buff *skb)
 	__be16 frag_off;
 
 	if (len < 0)
-		return 1;
+		return true;
 
 	ptr = ipv6_skip_exthdr(skb, ptr, &nexthdr, &frag_off);
 	if (ptr < 0)
-		return 0;
+		return false;
 	if (nexthdr == IPPROTO_ICMPV6) {
 		u8 _type, *tp;
 		tp = skb_header_pointer(skb,
@@ -151,9 +151,9 @@ static int is_ineligible(struct sk_buff *skb)
 			sizeof(_type), &_type);
 		if (tp == NULL ||
 		    !(*tp & ICMPV6_INFOMSG_MASK))
-			return 1;
+			return true;
 	}
-	return 0;
+	return false;
 }
 
 /*
@@ -208,14 +208,14 @@ static inline bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
  *	highest-order two bits set to 10
  */
 
-static __inline__ int opt_unrec(struct sk_buff *skb, __u32 offset)
+static bool opt_unrec(struct sk_buff *skb, __u32 offset)
 {
 	u8 _optval, *op;
 
 	offset += skb_network_offset(skb);
 	op = skb_header_pointer(skb, offset, sizeof(_optval), &_optval);
 	if (op == NULL)
-		return 1;
+		return true;
 	return (*op & 0xC0) == 0x80;
 }
 
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index cb43df6..9772fbd 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -433,32 +433,32 @@ static int mem_check(struct sock *sk)
 	return 0;
 }
 
-static int ipv6_hdr_cmp(struct ipv6_opt_hdr *h1, struct ipv6_opt_hdr *h2)
+static bool ipv6_hdr_cmp(struct ipv6_opt_hdr *h1, struct ipv6_opt_hdr *h2)
 {
 	if (h1 == h2)
-		return 0;
+		return false;
 	if (h1 == NULL || h2 == NULL)
-		return 1;
+		return true;
 	if (h1->hdrlen != h2->hdrlen)
-		return 1;
+		return true;
 	return memcmp(h1+1, h2+1, ((h1->hdrlen+1)<<3) - sizeof(*h1));
 }
 
-static int ipv6_opt_cmp(struct ipv6_txoptions *o1, struct ipv6_txoptions *o2)
+static bool ipv6_opt_cmp(struct ipv6_txoptions *o1, struct ipv6_txoptions *o2)
 {
 	if (o1 == o2)
-		return 0;
+		return false;
 	if (o1 == NULL || o2 == NULL)
-		return 1;
+		return true;
 	if (o1->opt_nflen != o2->opt_nflen)
-		return 1;
+		return true;
 	if (ipv6_hdr_cmp(o1->hopopt, o2->hopopt))
-		return 1;
+		return true;
 	if (ipv6_hdr_cmp(o1->dst0opt, o2->dst0opt))
-		return 1;
+		return true;
 	if (ipv6_hdr_cmp((struct ipv6_opt_hdr *)o1->srcrt, (struct ipv6_opt_hdr *)o2->srcrt))
-		return 1;
-	return 0;
+		return true;
+	return false;
 }
 
 static inline void fl_link(struct ipv6_pinfo *np, struct ipv6_fl_socklist *sfl,
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 1ca5d45..21a15df 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -170,7 +170,8 @@ static int ip6_input_finish(struct sk_buff *skb)
 {
 	const struct inet6_protocol *ipprot;
 	unsigned int nhoff;
-	int nexthdr, raw;
+	int nexthdr;
+	bool raw;
 	u8 hash;
 	struct inet6_dev *idev;
 	struct net *net = dev_net(skb_dst(skb)->dev);
@@ -251,7 +252,7 @@ int ip6_input(struct sk_buff *skb)
 int ip6_mc_input(struct sk_buff *skb)
 {
 	const struct ipv6hdr *hdr;
-	int deliver;
+	bool deliver;
 
 	IP6_UPD_PO_STATS_BH(dev_net(skb_dst(skb)->dev),
 			 ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_INMCAST,
@@ -287,7 +288,7 @@ int ip6_mc_input(struct sk_buff *skb)
 			 * is for MLD (0x0000).
 			 */
 			if ((ptr[2] | ptr[3]) == 0) {
-				deliver = 0;
+				deliver = false;
 
 				if (!ipv6_ext_hdr(nexthdr)) {
 					/* BUG */
@@ -312,7 +313,7 @@ int ip6_mc_input(struct sk_buff *skb)
 				case ICMPV6_MGM_REPORT:
 				case ICMPV6_MGM_REDUCTION:
 				case ICMPV6_MLD2_REPORT:
-					deliver = 1;
+					deliver = true;
 					break;
 				}
 				goto out;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 2a3a22c..6d0f5dc 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -606,13 +606,13 @@ done:
 	return err;
 }
 
-int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
-		   const struct in6_addr *src_addr)
+bool inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
+		    const struct in6_addr *src_addr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_mc_socklist *mc;
 	struct ip6_sf_socklist *psl;
-	int rv = 1;
+	bool rv = true;
 
 	rcu_read_lock();
 	for_each_pmc_rcu(np, mc) {
@@ -621,7 +621,7 @@ int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 	}
 	if (!mc) {
 		rcu_read_unlock();
-		return 1;
+		return true;
 	}
 	read_lock(&mc->sflock);
 	psl = mc->sflist;
@@ -635,9 +635,9 @@ int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 				break;
 		}
 		if (mc->sfmode == MCAST_INCLUDE && i >= psl->sl_count)
-			rv = 0;
+			rv = false;
 		if (mc->sfmode == MCAST_EXCLUDE && i < psl->sl_count)
-			rv = 0;
+			rv = false;
 	}
 	read_unlock(&mc->sflock);
 	rcu_read_unlock();
@@ -931,15 +931,15 @@ int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr)
 /*
  * identify MLD packets for MLD filter exceptions
  */
-int ipv6_is_mld(struct sk_buff *skb, int nexthdr)
+bool ipv6_is_mld(struct sk_buff *skb, int nexthdr)
 {
 	struct icmp6hdr *pic;
 
 	if (nexthdr != IPPROTO_ICMPV6)
-		return 0;
+		return false;
 
 	if (!pskb_may_pull(skb, sizeof(struct icmp6hdr)))
-		return 0;
+		return false;
 
 	pic = icmp6_hdr(skb);
 
@@ -948,22 +948,22 @@ int ipv6_is_mld(struct sk_buff *skb, int nexthdr)
 	case ICMPV6_MGM_REPORT:
 	case ICMPV6_MGM_REDUCTION:
 	case ICMPV6_MLD2_REPORT:
-		return 1;
+		return true;
 	default:
 		break;
 	}
-	return 0;
+	return false;
 }
 
 /*
  *	check if the interface/address pair is valid
  */
-int ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
-			const struct in6_addr *src_addr)
+bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
+			 const struct in6_addr *src_addr)
 {
 	struct inet6_dev *idev;
 	struct ifmcaddr6 *mc;
-	int rv = 0;
+	bool rv = false;
 
 	rcu_read_lock();
 	idev = __in6_dev_get(dev);
@@ -990,7 +990,7 @@ int ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 					rv = mc->mca_sfcount[MCAST_EXCLUDE] !=0;
 				spin_unlock_bh(&mc->mca_lock);
 			} else
-				rv = 1; /* don't filter unspecified source */
+				rv = true; /* don't filter unspecified source */
 		}
 		read_unlock_bh(&idev->lock);
 	}
@@ -1046,8 +1046,8 @@ static void igmp6_group_queried(struct ifmcaddr6 *ma, unsigned long resptime)
 }
 
 /* mark EXCLUDE-mode sources */
-static int mld_xmarksources(struct ifmcaddr6 *pmc, int nsrcs,
-	const struct in6_addr *srcs)
+static bool mld_xmarksources(struct ifmcaddr6 *pmc, int nsrcs,
+			     const struct in6_addr *srcs)
 {
 	struct ip6_sf_list *psf;
 	int i, scount;
@@ -1070,12 +1070,12 @@ static int mld_xmarksources(struct ifmcaddr6 *pmc, int nsrcs,
 	}
 	pmc->mca_flags &= ~MAF_GSQUERY;
 	if (scount == nsrcs)	/* all sources excluded */
-		return 0;
-	return 1;
+		return false;
+	return true;
 }
 
-static int mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
-	const struct in6_addr *srcs)
+static bool mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
+			    const struct in6_addr *srcs)
 {
 	struct ip6_sf_list *psf;
 	int i, scount;
@@ -1099,10 +1099,10 @@ static int mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
 	}
 	if (!scount) {
 		pmc->mca_flags &= ~MAF_GSQUERY;
-		return 0;
+		return false;
 	}
 	pmc->mca_flags |= MAF_GSQUERY;
-	return 1;
+	return true;
 }
 
 /* called with rcu_read_lock() */
@@ -1276,17 +1276,17 @@ int igmp6_event_report(struct sk_buff *skb)
 	return 0;
 }
 
-static int is_in(struct ifmcaddr6 *pmc, struct ip6_sf_list *psf, int type,
-	int gdeleted, int sdeleted)
+static bool is_in(struct ifmcaddr6 *pmc, struct ip6_sf_list *psf, int type,
+		  int gdeleted, int sdeleted)
 {
 	switch (type) {
 	case MLD2_MODE_IS_INCLUDE:
 	case MLD2_MODE_IS_EXCLUDE:
 		if (gdeleted || sdeleted)
-			return 0;
+			return false;
 		if (!((pmc->mca_flags & MAF_GSQUERY) && !psf->sf_gsresp)) {
 			if (pmc->mca_sfmode == MCAST_INCLUDE)
-				return 1;
+				return true;
 			/* don't include if this source is excluded
 			 * in all filters
 			 */
@@ -1295,29 +1295,29 @@ static int is_in(struct ifmcaddr6 *pmc, struct ip6_sf_list *psf, int type,
 			return pmc->mca_sfcount[MCAST_EXCLUDE] ==
 				psf->sf_count[MCAST_EXCLUDE];
 		}
-		return 0;
+		return false;
 	case MLD2_CHANGE_TO_INCLUDE:
 		if (gdeleted || sdeleted)
-			return 0;
+			return false;
 		return psf->sf_count[MCAST_INCLUDE] != 0;
 	case MLD2_CHANGE_TO_EXCLUDE:
 		if (gdeleted || sdeleted)
-			return 0;
+			return false;
 		if (pmc->mca_sfcount[MCAST_EXCLUDE] == 0 ||
 		    psf->sf_count[MCAST_INCLUDE])
-			return 0;
+			return false;
 		return pmc->mca_sfcount[MCAST_EXCLUDE] ==
 			psf->sf_count[MCAST_EXCLUDE];
 	case MLD2_ALLOW_NEW_SOURCES:
 		if (gdeleted || !psf->sf_crcount)
-			return 0;
+			return false;
 		return (pmc->mca_sfmode == MCAST_INCLUDE) ^ sdeleted;
 	case MLD2_BLOCK_OLD_SOURCES:
 		if (pmc->mca_sfmode == MCAST_INCLUDE)
 			return gdeleted || (psf->sf_crcount && sdeleted);
 		return psf->sf_crcount && !gdeleted && !sdeleted;
 	}
-	return 0;
+	return false;
 }
 
 static int
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index c7a27ac..54f62d3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -348,7 +348,7 @@ static int ndisc_constructor(struct neighbour *neigh)
 	struct net_device *dev = neigh->dev;
 	struct inet6_dev *in6_dev;
 	struct neigh_parms *parms;
-	int is_multicast = ipv6_addr_is_multicast(addr);
+	bool is_multicast = ipv6_addr_is_multicast(addr);
 
 	in6_dev = in6_dev_get(dev);
 	if (in6_dev == NULL) {
@@ -725,7 +725,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	struct inet6_dev *idev = NULL;
 	struct neighbour *neigh;
 	int dad = ipv6_addr_any(saddr);
-	int inc;
+	bool inc;
 	int is_router = -1;
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 5bddea7..93d6983 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -72,7 +72,7 @@ static struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 		const struct in6_addr *rmt_addr, int dif)
 {
 	struct hlist_node *node;
-	int is_multicast = ipv6_addr_is_multicast(loc_addr);
+	bool is_multicast = ipv6_addr_is_multicast(loc_addr);
 
 	sk_for_each_from(sk, node)
 		if (inet_sk(sk)->inet_num == num) {
@@ -153,12 +153,12 @@ EXPORT_SYMBOL(rawv6_mh_filter_unregister);
  *
  *	Caller owns SKB so we must make clones.
  */
-static int ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
+static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 {
 	const struct in6_addr *saddr;
 	const struct in6_addr *daddr;
 	struct sock *sk;
-	int delivered = 0;
+	bool delivered = false;
 	__u8 hash;
 	struct net *net;
 
@@ -179,7 +179,7 @@ static int ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 	while (sk) {
 		int filtered;
 
-		delivered = 1;
+		delivered = true;
 		switch (nexthdr) {
 		case IPPROTO_ICMPV6:
 			filtered = icmpv6_filter(sk, skb);
@@ -225,7 +225,7 @@ out:
 	return delivered;
 }
 
-int raw6_local_deliver(struct sk_buff *skb, int nexthdr)
+bool raw6_local_deliver(struct sk_buff *skb, int nexthdr)
 {
 	struct sock *raw_sk;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 90119a3..999a982 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -333,22 +333,22 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	}
 }
 
-static __inline__ int rt6_check_expired(const struct rt6_info *rt)
+static bool rt6_check_expired(const struct rt6_info *rt)
 {
 	struct rt6_info *ort = NULL;
 
 	if (rt->rt6i_flags & RTF_EXPIRES) {
 		if (time_after(jiffies, rt->dst.expires))
-			return 1;
+			return true;
 	} else if (rt->dst.from) {
 		ort = (struct rt6_info *) rt->dst.from;
 		return (ort->rt6i_flags & RTF_EXPIRES) &&
 			time_after(jiffies, ort->dst.expires);
 	}
-	return 0;
+	return false;
 }
 
-static inline int rt6_need_strict(const struct in6_addr *daddr)
+static bool rt6_need_strict(const struct in6_addr *daddr)
 {
 	return ipv6_addr_type(daddr) &
 		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
