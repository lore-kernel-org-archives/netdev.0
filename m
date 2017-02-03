From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/27] netfilter: pkttype: unnecessary to check ipv6 multicast address
Date: Fri,  3 Feb 2017 13:25:26 +0100
Message-ID: <1486124738-3013-16-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

Since there's no broadcast address in IPV6, so in ipv6 family, the
PACKET_LOOPBACK must be multicast packets, there's no need to check
it again.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_meta.c   | 5 +----
 net/netfilter/xt_pkttype.c | 3 +--
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 66c7f4b4c49b..9a22b24346b8 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -154,10 +154,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 				*dest = PACKET_BROADCAST;
 			break;
 		case NFPROTO_IPV6:
-			if (ipv6_hdr(skb)->daddr.s6_addr[0] == 0xFF)
-				*dest = PACKET_MULTICAST;
-			else
-				*dest = PACKET_BROADCAST;
+			*dest = PACKET_MULTICAST;
 			break;
 		default:
 			WARN_ON(1);
diff --git a/net/netfilter/xt_pkttype.c b/net/netfilter/xt_pkttype.c
index 57efb703ff18..1ef99151b3ba 100644
--- a/net/netfilter/xt_pkttype.c
+++ b/net/netfilter/xt_pkttype.c
@@ -33,8 +33,7 @@ pkttype_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	else if (xt_family(par) == NFPROTO_IPV4 &&
 	    ipv4_is_multicast(ip_hdr(skb)->daddr))
 		type = PACKET_MULTICAST;
-	else if (xt_family(par) == NFPROTO_IPV6 &&
-	    ipv6_hdr(skb)->daddr.s6_addr[0] == 0xFF)
+	else if (xt_family(par) == NFPROTO_IPV6)
 		type = PACKET_MULTICAST;
 	else
 		type = PACKET_BROADCAST;
-- 
2.1.4

