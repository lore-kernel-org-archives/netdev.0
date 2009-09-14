From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/3] net: constify struct inet6_protocol
Date: Tue, 15 Sep 2009 02:22:28 +0400
Message-ID: <20090914222228.GB31565@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f217.google.com ([209.85.219.217]:58771 "EHLO
	mail-ew0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757347AbZINWbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 18:31:15 -0400
Received: by ewy17 with SMTP id 17so3373040ewy.39
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 15:31:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/protocol.h |    6 +++---
 net/dccp/ipv6.c        |    2 +-
 net/ipv6/af_inet6.c    |   10 +++++-----
 net/ipv6/ah6.c         |    2 +-
 net/ipv6/esp6.c        |    2 +-
 net/ipv6/exthdrs.c     |    6 +++---
 net/ipv6/icmp.c        |    4 ++--
 net/ipv6/ip6_input.c   |    2 +-
 net/ipv6/ip6mr.c       |    6 +-----
 net/ipv6/ipcomp6.c     |    2 +-
 net/ipv6/protocol.c    |    6 +++---
 net/ipv6/reassembly.c  |    2 +-
 net/ipv6/tcp_ipv6.c    |    2 +-
 net/ipv6/tunnel6.c     |    4 ++--
 net/ipv6/udp.c         |    2 +-
 net/ipv6/udplite.c     |    2 +-
 net/sctp/ipv6.c        |    2 +-
 17 files changed, 29 insertions(+), 33 deletions(-)

--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -97,7 +97,7 @@ struct inet_protosw {
 extern const struct net_protocol *inet_protos[MAX_INET_PROTOS];
 
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-extern struct inet6_protocol *inet6_protos[MAX_INET_PROTOS];
+extern const struct inet6_protocol *inet6_protos[MAX_INET_PROTOS];
 #endif
 
 extern int	inet_add_protocol(const struct net_protocol *prot, unsigned char num);
@@ -106,8 +106,8 @@ extern void	inet_register_protosw(struct inet_protosw *p);
 extern void	inet_unregister_protosw(struct inet_protosw *p);
 
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-extern int	inet6_add_protocol(struct inet6_protocol *prot, unsigned char num);
-extern int	inet6_del_protocol(struct inet6_protocol *prot, unsigned char num);
+extern int	inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
+extern int	inet6_del_protocol(const struct inet6_protocol *prot, unsigned char num);
 extern int	inet6_register_protosw(struct inet_protosw *p);
 extern void	inet6_unregister_protosw(struct inet_protosw *p);
 #endif
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1152,7 +1152,7 @@ static struct proto dccp_v6_prot = {
 #endif
 };
 
-static struct inet6_protocol dccp_v6_protocol = {
+static const struct inet6_protocol dccp_v6_protocol = {
 	.handler	= dccp_v6_rcv,
 	.err_handler	= dccp_v6_err,
 	.flags		= INET6_PROTO_NOPOLICY | INET6_PROTO_FINAL,
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -710,7 +710,7 @@ EXPORT_SYMBOL_GPL(ipv6_opt_accepted);
 
 static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
 {
-	struct inet6_protocol *ops = NULL;
+	const struct inet6_protocol *ops = NULL;
 
 	for (;;) {
 		struct ipv6_opt_hdr *opth;
@@ -745,7 +745,7 @@ static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
 static int ipv6_gso_send_check(struct sk_buff *skb)
 {
 	struct ipv6hdr *ipv6h;
-	struct inet6_protocol *ops;
+	const struct inet6_protocol *ops;
 	int err = -EINVAL;
 
 	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
@@ -773,7 +773,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct ipv6hdr *ipv6h;
-	struct inet6_protocol *ops;
+	const struct inet6_protocol *ops;
 	int proto;
 	struct frag_hdr *fptr;
 	unsigned int unfrag_ip6hlen;
@@ -840,7 +840,7 @@ struct ipv6_gro_cb {
 static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
-	struct inet6_protocol *ops;
+	const struct inet6_protocol *ops;
 	struct sk_buff **pp = NULL;
 	struct sk_buff *p;
 	struct ipv6hdr *iph;
@@ -926,7 +926,7 @@ out:
 
 static int ipv6_gro_complete(struct sk_buff *skb)
 {
-	struct inet6_protocol *ops;
+	const struct inet6_protocol *ops;
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	int err = -ENOSYS;
 
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -527,7 +527,7 @@ static const struct xfrm_type ah6_type =
 	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
-static struct inet6_protocol ah6_protocol = {
+static const struct inet6_protocol ah6_protocol = {
 	.handler	=	xfrm6_rcv,
 	.err_handler	=	ah6_err,
 	.flags		=	INET6_PROTO_NOPOLICY,
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -558,7 +558,7 @@ static const struct xfrm_type esp6_type =
 	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
-static struct inet6_protocol esp6_protocol = {
+static const struct inet6_protocol esp6_protocol = {
 	.handler 	=	xfrm6_rcv,
 	.err_handler	=	esp6_err,
 	.flags		=	INET6_PROTO_NOPOLICY,
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -500,17 +500,17 @@ unknown_rh:
 	return -1;
 }
 
-static struct inet6_protocol rthdr_protocol = {
+static const struct inet6_protocol rthdr_protocol = {
 	.handler	=	ipv6_rthdr_rcv,
 	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_GSO_EXTHDR,
 };
 
-static struct inet6_protocol destopt_protocol = {
+static const struct inet6_protocol destopt_protocol = {
 	.handler	=	ipv6_destopt_rcv,
 	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_GSO_EXTHDR,
 };
 
-static struct inet6_protocol nodata_protocol = {
+static const struct inet6_protocol nodata_protocol = {
 	.handler	=	dst_discard,
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -86,7 +86,7 @@ static inline struct sock *icmpv6_sk(struct net *net)
 
 static int icmpv6_rcv(struct sk_buff *skb);
 
-static struct inet6_protocol icmpv6_protocol = {
+static const struct inet6_protocol icmpv6_protocol = {
 	.handler	=	icmpv6_rcv,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
@@ -583,7 +583,7 @@ out:
 
 static void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info)
 {
-	struct inet6_protocol *ipprot;
+	const struct inet6_protocol *ipprot;
 	int inner_offset;
 	int hash;
 	u8 nexthdr;
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -159,7 +159,7 @@ drop:
 
 static int ip6_input_finish(struct sk_buff *skb)
 {
-	struct inet6_protocol *ipprot;
+	const struct inet6_protocol *ipprot;
 	unsigned int nhoff;
 	int nexthdr, raw;
 	u8 hash;
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -83,10 +83,6 @@ static int ip6mr_cache_report(struct net *net, struct sk_buff *pkt,
 static int ip6mr_fill_mroute(struct sk_buff *skb, struct mfc6_cache *c, struct rtmsg *rtm);
 static void mroute_clean_tables(struct net *net);
 
-#ifdef CONFIG_IPV6_PIMSM_V2
-static struct inet6_protocol pim6_protocol;
-#endif
-
 static struct timer_list ipmr_expire_timer;
 
 
@@ -410,7 +406,7 @@ static int pim6_rcv(struct sk_buff *skb)
 	return 0;
 }
 
-static struct inet6_protocol pim6_protocol = {
+static const struct inet6_protocol pim6_protocol = {
 	.handler	=	pim6_rcv,
 };
 
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -178,7 +178,7 @@ static const struct xfrm_type ipcomp6_type =
 	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
-static struct inet6_protocol ipcomp6_protocol =
+static const struct inet6_protocol ipcomp6_protocol =
 {
 	.handler	= xfrm6_rcv,
 	.err_handler	= ipcomp6_err,
--- a/net/ipv6/protocol.c
+++ b/net/ipv6/protocol.c
@@ -25,11 +25,11 @@
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 
-struct inet6_protocol *inet6_protos[MAX_INET_PROTOS];
+const struct inet6_protocol *inet6_protos[MAX_INET_PROTOS];
 static DEFINE_SPINLOCK(inet6_proto_lock);
 
 
-int inet6_add_protocol(struct inet6_protocol *prot, unsigned char protocol)
+int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char protocol)
 {
 	int ret, hash = protocol & (MAX_INET_PROTOS - 1);
 
@@ -53,7 +53,7 @@ EXPORT_SYMBOL(inet6_add_protocol);
  *	Remove a protocol from the hash tables.
  */
 
-int inet6_del_protocol(struct inet6_protocol *prot, unsigned char protocol)
+int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char protocol)
 {
 	int ret, hash = protocol & (MAX_INET_PROTOS - 1);
 
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -627,7 +627,7 @@ fail_hdr:
 	return -1;
 }
 
-static struct inet6_protocol frag_protocol =
+static const struct inet6_protocol frag_protocol =
 {
 	.handler	=	ipv6_frag_rcv,
 	.flags		=	INET6_PROTO_NOPOLICY,
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2093,7 +2093,7 @@ struct proto tcpv6_prot = {
 #endif
 };
 
-static struct inet6_protocol tcpv6_protocol = {
+static const struct inet6_protocol tcpv6_protocol = {
 	.handler	=	tcp_v6_rcv,
 	.err_handler	=	tcp_v6_err,
 	.gso_send_check	=	tcp_v6_gso_send_check,
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -133,13 +133,13 @@ static void tunnel6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			break;
 }
 
-static struct inet6_protocol tunnel6_protocol = {
+static const struct inet6_protocol tunnel6_protocol = {
 	.handler	= tunnel6_rcv,
 	.err_handler	= tunnel6_err,
 	.flags          = INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
-static struct inet6_protocol tunnel46_protocol = {
+static const struct inet6_protocol tunnel46_protocol = {
 	.handler	= tunnel46_rcv,
 	.err_handler	= tunnel6_err,
 	.flags          = INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1172,7 +1172,7 @@ out:
 	return segs;
 }
 
-static struct inet6_protocol udpv6_protocol = {
+static const struct inet6_protocol udpv6_protocol = {
 	.handler	=	udpv6_rcv,
 	.err_handler	=	udpv6_err,
 	.gso_send_check =	udp6_ufo_send_check,
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -25,7 +25,7 @@ static void udplitev6_err(struct sk_buff *skb,
 	__udp6_lib_err(skb, opt, type, code, offset, info, &udplite_table);
 }
 
-static struct inet6_protocol udplitev6_protocol = {
+static const struct inet6_protocol udplitev6_protocol = {
 	.handler	=	udplitev6_rcv,
 	.err_handler	=	udplitev6_err,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -949,7 +949,7 @@ static int sctp6_rcv(struct sk_buff *skb)
 	return sctp_rcv(skb) ? -1 : 0;
 }
 
-static struct inet6_protocol sctpv6_protocol = {
+static const struct inet6_protocol sctpv6_protocol = {
 	.handler      = sctp6_rcv,
 	.err_handler  = sctp_v6_err,
 	.flags        = INET6_PROTO_NOPOLICY | INET6_PROTO_FINAL,
