From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] ipv6: mark expected switch fall-throughs
Date: Mon, 16 Oct 2017 16:36:52 -0500
Message-ID: <20171016213652.GA9967@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway24.websitewelcome.com ([192.185.50.45]:41643 "EHLO
        gateway24.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755232AbdJPV5X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 17:57:23 -0400
Received: from cm16.websitewelcome.com (cm16.websitewelcome.com [100.42.49.19])
        by gateway24.websitewelcome.com (Postfix) with ESMTP id 6FD632A5E
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 16:36:53 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Notice that in some cases I placed the "fall through" comment
on its own line, which is what GCC is expecting to find.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/ipv6/ah6.c                           | 1 +
 net/ipv6/exthdrs.c                       | 1 +
 net/ipv6/icmp.c                          | 6 ++----
 net/ipv6/ip6_fib.c                       | 4 ++++
 net/ipv6/ip6_tunnel.c                    | 1 +
 net/ipv6/ip6mr.c                         | 1 +
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c | 3 ++-
 net/ipv6/raw.c                           | 4 ++++
 net/ipv6/tcp_ipv6.c                      | 3 ++-
 net/ipv6/xfrm6_policy.c                  | 1 +
 10 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 7802b72..37bb33f 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -271,6 +271,7 @@ static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len, int dir)
 		case NEXTHDR_DEST:
 			if (dir == XFRM_POLICY_OUT)
 				ipv6_rearrange_destopt(iph, exthdr.opth);
+			/* fall through */
 		case NEXTHDR_HOP:
 			if (!zero_out_mutable_opts(exthdr.opth)) {
 				net_dbg_ratelimited("overrun %sopts\n",
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 9551613..7835dea 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -89,6 +89,7 @@ static bool ip6_tlvopt_unknown(struct sk_buff *skb, int optoff)
 		 */
 		if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr))
 			break;
+		/* fall through */
 	case 2: /* send ICMP PARM PROB regardless and drop packet */
 		icmpv6_param_prob(skb, ICMPV6_UNK_OPTION, optoff);
 		return false;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 4e52d52..6ae5dd3 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -864,10 +864,8 @@ static int icmpv6_rcv(struct sk_buff *skb)
 			goto discard_it;
 		hdr = icmp6_hdr(skb);
 
-		/*
-		 *	Drop through to notify
-		 */
-
+		/* to notify */
+		/* fall through */
 	case ICMPV6_DEST_UNREACH:
 	case ICMPV6_TIME_EXCEED:
 	case ICMPV6_PARAMPROB:
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index c2ecd5e..dcb0649 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1777,6 +1777,7 @@ static int fib6_walk_continue(struct fib6_walker *w)
 			}
 			w->state = FWS_L;
 #endif
+			/* fall through */
 		case FWS_L:
 			left = rcu_dereference_protected(fn->left, 1);
 			if (left) {
@@ -1785,6 +1786,7 @@ static int fib6_walk_continue(struct fib6_walker *w)
 				continue;
 			}
 			w->state = FWS_R;
+			/* fall through */
 		case FWS_R:
 			right = rcu_dereference_protected(fn->right, 1);
 			if (right) {
@@ -1794,6 +1796,7 @@ static int fib6_walk_continue(struct fib6_walker *w)
 			}
 			w->state = FWS_C;
 			w->leaf = rcu_dereference_protected(fn->leaf, 1);
+			/* fall through */
 		case FWS_C:
 			if (w->leaf && fn->fn_flags & RTN_RTINFO) {
 				int err;
@@ -1812,6 +1815,7 @@ static int fib6_walk_continue(struct fib6_walker *w)
 			}
 skip:
 			w->state = FWS_U;
+			/* fall through */
 		case FWS_U:
 			if (fn == w->root)
 				return 0;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8255486..4212879 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -593,6 +593,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	case NDISC_REDIRECT:
 		rel_type = ICMP_REDIRECT;
 		rel_code = ICMP_REDIR_HOST;
+		/* fall through */
 	default:
 		return 0;
 	}
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f5500f5..59fad81 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1722,6 +1722,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	case MRT6_ADD_MFC:
 	case MRT6_DEL_MFC:
 		parent = -1;
+		/* fall through */
 	case MRT6_ADD_MFC_PROXY:
 	case MRT6_DEL_MFC_PROXY:
 		if (optlen < sizeof(mfc))
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index 46d6dba..1d2fb92 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -290,7 +290,8 @@ nf_nat_ipv6_fn(void *priv, struct sk_buff *skb,
 			else
 				return NF_ACCEPT;
 		}
-		/* Fall thru... (Only ICMPs can be IP_CT_IS_REPLY) */
+		/* Only ICMPs can be IP_CT_IS_REPLY: */
+		/* fall through */
 	case IP_CT_NEW:
 		/* Seen it before?  This can happen for loopback, retrans,
 		 * or local packets.
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 041d1cd..08a85fa 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1055,6 +1055,7 @@ static int rawv6_setsockopt(struct sock *sk, int level, int optname,
 		if (optname == IPV6_CHECKSUM ||
 		    optname == IPV6_HDRINCL)
 			break;
+		/* fall through */
 	default:
 		return ipv6_setsockopt(sk, level, optname, optval, optlen);
 	}
@@ -1077,6 +1078,7 @@ static int compat_rawv6_setsockopt(struct sock *sk, int level, int optname,
 		if (optname == IPV6_CHECKSUM ||
 		    optname == IPV6_HDRINCL)
 			break;
+		/* fall through */
 	default:
 		return compat_ipv6_setsockopt(sk, level, optname,
 					      optval, optlen);
@@ -1138,6 +1140,7 @@ static int rawv6_getsockopt(struct sock *sk, int level, int optname,
 		if (optname == IPV6_CHECKSUM ||
 		    optname == IPV6_HDRINCL)
 			break;
+		/* fall through */
 	default:
 		return ipv6_getsockopt(sk, level, optname, optval, optlen);
 	}
@@ -1160,6 +1163,7 @@ static int compat_rawv6_getsockopt(struct sock *sk, int level, int optname,
 		if (optname == IPV6_CHECKSUM ||
 		    optname == IPV6_HDRINCL)
 			break;
+		/* fall through */
 	default:
 		return compat_ipv6_getsockopt(sk, level, optname,
 					      optval, optlen);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 64d94af..ae83615 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1577,8 +1577,9 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 			refcounted = false;
 			goto process;
 		}
-		/* Fall through to ACK */
 	}
+		/* to ACK */
+		/* fall through */
 	case TCP_TW_ACK:
 		tcp_v6_timewait_ack(sk, skb);
 		break;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 11d1314..4ed9f8c 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -152,6 +152,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		switch (nexthdr) {
 		case NEXTHDR_FRAGMENT:
 			onlyproto = 1;
+			/* fall through */
 		case NEXTHDR_ROUTING:
 		case NEXTHDR_HOP:
 		case NEXTHDR_DEST:
-- 
2.7.4
