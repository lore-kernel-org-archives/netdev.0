From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/17] ipvs: remove unnecessary assignment in __ip_vs_get_out_rt
Date: Mon, 24 Nov 2014 14:27:41 +0100
Message-ID: <1416835674-11871-5-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex Gartrell <agartrell@fb.com>

It is a precondition of the function that daddr be equal to dest->addr.ip
if dest is non-NULL, so this additional assignment is just confusing for
stupid engineers like me.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 91f17c1..5efa597 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -293,7 +293,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 				  &dest->addr.ip, &dest_dst->dst_saddr.ip,
 				  atomic_read(&rt->dst.__refcnt));
 		}
-		daddr = dest->addr.ip;
 		if (ret_saddr)
 			*ret_saddr = dest_dst->dst_saddr.ip;
 	} else {
-- 
1.7.10.4

