From: Atis Elsts <atis@mikrotik.com>
Subject: [PATCH] net: Use routing mark from skb in multicast forwarding routing lookups
Date: Thu, 8 Oct 2009 16:19:44 +0300
Message-ID: <200910081619.44880.atis@mikrotik.com>
References: <200910051646.34770.atis@mikrotik.com> <200910071559.56526.atis@mikrotik.com> <20091007.135627.96995518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, panther@balabit.hu, eric.dumazet@gmail.com,
	brian.haley@hp.com, zenczykowski@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.196]:57869 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758137AbZJHNUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2009 09:20:06 -0400
In-Reply-To: <20091007.135627.96995518.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 07 October 2009 23:56:27 David Miller wrote:
> 
> Ok submit just the else part and we'll have a look at it.
> 
Here is a try.

Use routing mark from skb in routing lookup in IPv4 and IPv6 multicast forwarding code.
Signed-off-by: Atis Elsts <atis@mikrotik.com>
---
 net/ipv4/ipmr.c  |    1 +
 net/ipv6/ip6mr.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 630a56d..5522cf8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1248,6 +1248,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 		encap = sizeof(struct iphdr);
 	} else {
 		struct flowi fl = { .oif = vif->link,
+				    .mark = skb->mark,
 				    .nl_u = { .ip4_u =
 					      { .daddr = iph->daddr,
 						.tos = RT_TOS(iph->tos) } },
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 7161539..d98df54 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1523,6 +1523,7 @@ static int ip6mr_forward2(struct sk_buff *skb, struct mfc6_cache *c, int vifi)
 
 	fl = (struct flowi) {
 		.oif = vif->link,
+		.mark = skb->mark,
 		.nl_u = { .ip6_u =
 				{ .daddr = ipv6h->daddr, }
 		}
