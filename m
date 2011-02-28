From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/5] net: Remove unused sk_sndmsg_* from UFO
Date: Mon, 28 Feb 2011 19:41:00 +0800
Message-ID: <E1Pu1TI-0005Qa-KA@gondolin.me.apana.org.au>
References: <20110227110614.GA6246@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51323 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753399Ab1B1LlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 06:41:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net: Remove unused sk_sndmsg_* from UFO

UFO doesn't really use the sk_sndmsg_* parameters so touching
them is pointless.  It can't use them anyway since the whole
point of UFO is to use the original pages without copying.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/skbuff.c     |    3 ---
 net/ipv4/ip_output.c  |    1 -
 net/ipv6/ip6_output.c |    1 -
 3 files changed, 5 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d883dcc..97011a7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2434,8 +2434,6 @@ int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 			return -ENOMEM;
 
 		/* initialize the next frag */
-		sk->sk_sndmsg_page = page;
-		sk->sk_sndmsg_off = 0;
 		skb_fill_page_desc(skb, frg_cnt, page, 0, 0);
 		skb->truesize += PAGE_SIZE;
 		atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
@@ -2455,7 +2453,6 @@ int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 			return -EFAULT;
 
 		/* copy was successful so update the size parameters */
-		sk->sk_sndmsg_off += copy;
 		frag->size += copy;
 		skb->len += copy;
 		skb->data_len += copy;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 04c7b3b..d3a4540 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -767,7 +767,6 @@ static inline int ip_ufo_append_data(struct sock *sk,
 
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
-		sk->sk_sndmsg_off = 0;
 
 		/* specify the length of each IP datagram fragment */
 		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 5f8d242..9965182 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1061,7 +1061,6 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
-		sk->sk_sndmsg_off = 0;
 	}
 
 	err = skb_append_datato_frags(sk,skb, getfrag, from,
