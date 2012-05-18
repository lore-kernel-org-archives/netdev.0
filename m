From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: bool conversions  phase1
Date: Fri, 18 May 2012 08:14:11 +0200
Message-ID: <1337321651.3403.92.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:57895 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755413Ab2ERGOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 02:14:16 -0400
Received: by wibhm6 with SMTP id hm6so556504wib.1
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 23:14:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ipv6_opt_accepted() returns a bool, and can use const pointers

ipv6_addr_equal(), ipv6_addr_any(), ipv6_addr_loopback(),
ipv6_addr_orchid() return a bool.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ipv6.h    |   30 +++++++++++++++---------------
 net/ipv6/af_inet6.c   |   10 +++++-----
 net/ipv6/ip6_tunnel.c |    2 +-
 3 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5f65e7c..1402139 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -263,7 +263,7 @@ extern struct ipv6_txoptions *	ipv6_renew_options(struct sock *sk, struct ipv6_t
 struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 					  struct ipv6_txoptions *opt);
 
-extern int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb);
+extern bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb);
 
 int ip6_frag_nqueues(struct net *net);
 int ip6_frag_mem(struct net *net);
@@ -332,8 +332,8 @@ static inline void ipv6_addr_set(struct in6_addr *addr,
 	addr->s6_addr32[3] = w4;
 }
 
-static inline int ipv6_addr_equal(const struct in6_addr *a1,
-				  const struct in6_addr *a2)
+static inline bool ipv6_addr_equal(const struct in6_addr *a1,
+				   const struct in6_addr *a2)
 {
 	return ((a1->s6_addr32[0] ^ a2->s6_addr32[0]) |
 		(a1->s6_addr32[1] ^ a2->s6_addr32[1]) |
@@ -341,27 +341,27 @@ static inline int ipv6_addr_equal(const struct in6_addr *a1,
 		(a1->s6_addr32[3] ^ a2->s6_addr32[3])) == 0;
 }
 
-static inline int __ipv6_prefix_equal(const __be32 *a1, const __be32 *a2,
-				      unsigned int prefixlen)
+static inline bool __ipv6_prefix_equal(const __be32 *a1, const __be32 *a2,
+				       unsigned int prefixlen)
 {
 	unsigned int pdw, pbi;
 
 	/* check complete u32 in prefix */
 	pdw = prefixlen >> 5;
 	if (pdw && memcmp(a1, a2, pdw << 2))
-		return 0;
+		return false;
 
 	/* check incomplete u32 in prefix */
 	pbi = prefixlen & 0x1f;
 	if (pbi && ((a1[pdw] ^ a2[pdw]) & htonl((0xffffffff) << (32 - pbi))))
-		return 0;
+		return false;
 
-	return 1;
+	return true;
 }
 
-static inline int ipv6_prefix_equal(const struct in6_addr *a1,
-				    const struct in6_addr *a2,
-				    unsigned int prefixlen)
+static inline bool ipv6_prefix_equal(const struct in6_addr *a1,
+				     const struct in6_addr *a2,
+				     unsigned int prefixlen)
 {
 	return __ipv6_prefix_equal(a1->s6_addr32, a2->s6_addr32,
 				   prefixlen);
@@ -389,19 +389,19 @@ struct ip6_create_arg {
 void ip6_frag_init(struct inet_frag_queue *q, void *a);
 bool ip6_frag_match(struct inet_frag_queue *q, void *a);
 
-static inline int ipv6_addr_any(const struct in6_addr *a)
+static inline bool ipv6_addr_any(const struct in6_addr *a)
 {
 	return (a->s6_addr32[0] | a->s6_addr32[1] |
 		a->s6_addr32[2] | a->s6_addr32[3]) == 0;
 }
 
-static inline int ipv6_addr_loopback(const struct in6_addr *a)
+static inline bool ipv6_addr_loopback(const struct in6_addr *a)
 {
 	return (a->s6_addr32[0] | a->s6_addr32[1] |
 		a->s6_addr32[2] | (a->s6_addr32[3] ^ htonl(1))) == 0;
 }
 
-static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
+static inline bool ipv6_addr_v4mapped(const struct in6_addr *a)
 {
 	return (a->s6_addr32[0] | a->s6_addr32[1] |
 		 (a->s6_addr32[2] ^ htonl(0x0000ffff))) == 0;
@@ -411,7 +411,7 @@ static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
  * Check for a RFC 4843 ORCHID address
  * (Overlay Routable Cryptographic Hash Identifiers)
  */
-static inline int ipv6_addr_orchid(const struct in6_addr *a)
+static inline bool ipv6_addr_orchid(const struct in6_addr *a)
 {
 	return (a->s6_addr32[0] & htonl(0xfffffff0)) == htonl(0x20010010);
 }
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 138d498..e22e6d8 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -678,10 +678,10 @@ int inet6_sk_rebuild_header(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(inet6_sk_rebuild_header);
 
-int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb)
+bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb)
 {
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct inet6_skb_parm *opt = IP6CB(skb);
+	const struct ipv6_pinfo *np = inet6_sk(sk);
+	const struct inet6_skb_parm *opt = IP6CB(skb);
 
 	if (np->rxopt.all) {
 		if ((opt->hop && (np->rxopt.bits.hopopts ||
@@ -693,9 +693,9 @@ int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb)
 		     np->rxopt.bits.osrcrt)) ||
 		    ((opt->dst1 || opt->dst0) &&
 		     (np->rxopt.bits.dstopts || np->rxopt.bits.odstopts)))
-			return 1;
+			return true;
 	}
-	return 0;
+	return false;
 }
 EXPORT_SYMBOL_GPL(ipv6_opt_accepted);
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index e65c560..c9015fa 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -818,7 +818,7 @@ static void init_tel_txopt(struct ipv6_tel_txoption *opt, __u8 encap_limit)
  *   0 else
  **/
 
-static inline int
+static inline bool
 ip6_tnl_addr_conflict(const struct ip6_tnl *t, const struct ipv6hdr *hdr)
 {
 	return ipv6_addr_equal(&t->parms.raddr, &hdr->saddr);
