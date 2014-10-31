From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] ipvs: Avoid null-pointer deref in debug code
Date: Fri, 31 Oct 2014 13:18:27 +0100
Message-ID: <1414757912-29150-2-git-send-email-pablo@netfilter.org>
References: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex Gartrell <agartrell@fb.com>

Use daddr instead of reaching into dest.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 91f17c1..437a366 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -316,7 +316,7 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
 						  local))) {
 		IP_VS_DBG_RL("We are crossing local and non-local addresses"
-			     " daddr=%pI4\n", &dest->addr.ip);
+			     " daddr=%pI4\n", &daddr);
 		goto err_put;
 	}
 
@@ -458,7 +458,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
 						  local))) {
 		IP_VS_DBG_RL("We are crossing local and non-local addresses"
-			     " daddr=%pI6\n", &dest->addr.in6);
+			     " daddr=%pI6\n", daddr);
 		goto err_put;
 	}
 
-- 
1.7.10.4

