From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6] ipfrag : frag_kfree_skb() cleanup
Date: Mon, 14 Jun 2010 22:01:39 +0800
Message-ID: <4C163643.1080906@cn.fujitsu.com>
References: <1276507363.2478.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60205 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753234Ab0FNOBp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jun 2010 10:01:45 -0400
In-Reply-To: <1276507363.2478.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, at 06/14/2010 05:22 PM:
> Third param (work) is unused, remove it.
> 
> Remove __inline__ and inline qualifiers.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

we also need to fix IPv6 netfilter.

[PATCH 2/2] netfilter: defrag: kill unused work parameter of frag_kfree_skb()

The parameter (work) is unused, remove it.
Reported from Eric Dumazet.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
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
1.6.3.3
