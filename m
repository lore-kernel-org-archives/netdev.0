From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/14] tcp: Optimise len/mss comparison
Date: Wed, 27 May 2009 14:50:26 +1000
Message-ID: <E1M9B5u-0001SI-Jj@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37536 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751182AbZE0Eu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 00:50:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp: Optimise len/mss comparison

Instead of checking len > mss || len == 0, we can accomplish
both by checking (len - 1) > mss using the unsigned wraparound.
At nearly a million times a second, this might just help.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/tcp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 313960e..68342d4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2566,7 +2566,7 @@ found:
 
 	mss = skb_shinfo(p)->gso_size;
 
-	flush |= (len > mss) | !len;
+	flush |= (len - 1) >= mss;
 	flush |= (ntohl(th2->seq) + skb_gro_len(p)) ^ ntohl(th->seq);
 
 	if (flush || skb_gro_receive(head, skb)) {
