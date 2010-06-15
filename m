From: kaber@trash.net
Subject: [PATCH 15/17] netfilter: defrag: kill unused work parameter of frag_kfree_skb()
Date: Tue, 15 Jun 2010 17:38:41 +0200
Message-ID: <1276616323-20880-16-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42180 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932282Ab0FOP34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 11:29:56 -0400
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

The parameter (work) is unused, remove it.
Reported from Eric Dumazet.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index bc5b86d..9254008 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -114,10 +114,8 @@ static void nf_skb_free(struct sk_buff *skb)
 }
 
 /* Memory Tracking Functions. */
-static inline void frag_kfree_skb(struct sk_buff *skb, unsigned int *work)
+static void frag_kfree_skb(struct sk_buff *skb)
 {
-	if (work)
-		*work -= skb->truesize;
 	atomic_sub(skb->truesize, &nf_init_frags.mem);
 	nf_skb_free(skb);
 	kfree_skb(skb);
@@ -335,7 +333,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 				fq->q.fragments = next;
 
 			fq->q.meat -= free_it->len;
-			frag_kfree_skb(free_it, NULL);
+			frag_kfree_skb(free_it);
 		}
 	}
 
-- 
1.7.0.4

