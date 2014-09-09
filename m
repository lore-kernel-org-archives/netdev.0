From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] net: use kfree_skb_list() helper in more places
Date: Wed, 10 Sep 2014 01:08:46 +0200
Message-ID: <1410304126-1838-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39948 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752326AbaIIXJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 19:09:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/ip6_output.c  | 6 +-----
 net/xfrm/xfrm_output.c | 6 +-----
 2 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b7a3e7b..2e6a0db 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -701,11 +701,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			return 0;
 		}
 
-		while (frag) {
-			skb = frag->next;
-			kfree_skb(frag);
-			frag = skb;
-		}
+		kfree_skb_list(frag);
 
 		IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 			      IPSTATS_MIB_FRAGFAILS);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index c51e8f7b..499d6c1 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -166,11 +166,7 @@ static int xfrm_output_gso(struct sk_buff *skb)
 		err = xfrm_output2(segs);
 
 		if (unlikely(err)) {
-			while ((segs = nskb)) {
-				nskb = segs->next;
-				segs->next = NULL;
-				kfree_skb(segs);
-			}
+			kfree_skb_list(nskb);
 			return err;
 		}
 
-- 
1.8.1.5
