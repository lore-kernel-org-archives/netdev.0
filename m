From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipfrag : frag_kfree_skb() cleanup
Date: Mon, 14 Jun 2010 11:22:43 +0200
Message-ID: <1276507363.2478.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41147 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755784Ab0FNJWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 05:22:46 -0400
Received: by wyb40 with SMTP id 40so3601154wyb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 02:22:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Third param (work) is unused, remove it.

Remove __inline__ and inline qualifiers.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_fragment.c |    9 +++------
 net/ipv6/reassembly.c  |    7 ++-----
 2 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 75347ea..7e660dd 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -124,11 +124,8 @@ static int ip4_frag_match(struct inet_frag_queue *q, void *a)
 }
 
 /* Memory Tracking Functions. */
-static __inline__ void frag_kfree_skb(struct netns_frags *nf,
-		struct sk_buff *skb, int *work)
+static void frag_kfree_skb(struct netns_frags *nf, struct sk_buff *skb)
 {
-	if (work)
-		*work -= skb->truesize;
 	atomic_sub(skb->truesize, &nf->mem);
 	kfree_skb(skb);
 }
@@ -309,7 +306,7 @@ static int ip_frag_reinit(struct ipq *qp)
 	fp = qp->q.fragments;
 	do {
 		struct sk_buff *xp = fp->next;
-		frag_kfree_skb(qp->q.net, fp, NULL);
+		frag_kfree_skb(qp->q.net, fp);
 		fp = xp;
 	} while (fp);
 
@@ -446,7 +443,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 				qp->q.fragments = next;
 
 			qp->q.meat -= free_it->len;
-			frag_kfree_skb(qp->q.net, free_it, NULL);
+			frag_kfree_skb(qp->q.net, free_it);
 		}
 	}
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 6d4292f..f967978 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -150,11 +150,8 @@ int ip6_frag_match(struct inet_frag_queue *q, void *a)
 EXPORT_SYMBOL(ip6_frag_match);
 
 /* Memory Tracking Functions. */
-static inline void frag_kfree_skb(struct netns_frags *nf,
-		struct sk_buff *skb, int *work)
+static void frag_kfree_skb(struct netns_frags *nf, struct sk_buff *skb)
 {
-	if (work)
-		*work -= skb->truesize;
 	atomic_sub(skb->truesize, &nf->mem);
 	kfree_skb(skb);
 }
@@ -392,7 +389,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 				fq->q.fragments = next;
 
 			fq->q.meat -= free_it->len;
-			frag_kfree_skb(fq->q.net, free_it, NULL);
+			frag_kfree_skb(fq->q.net, free_it);
 		}
 	}
 


