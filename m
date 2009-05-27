From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/14] tcp: Remove unnecessary window comparisons for GRO
Date: Wed, 27 May 2009 14:50:25 +1000
Message-ID: <E1M9B5t-0001Rt-HK@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37533 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750695AbZE0Eu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 00:50:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp: Remove unnecessary window comparisons for GRO

The window has already been checked as part of the flag word
so there is no need to check it explicitly.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/tcp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ff6adec..313960e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2559,7 +2559,7 @@ found:
 	flush |= flags & TCP_FLAG_CWR;
 	flush |= (flags ^ tcp_flag_word(th2)) &
 		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH);
-	flush |= (th->ack_seq ^ th2->ack_seq) | (th->window ^ th2->window);
+	flush |= th->ack_seq ^ th2->ack_seq;
 	for (i = sizeof(*th); !flush && i < thlen; i += 4)
 		flush |= *(u32 *)((u8 *)th + i) ^
 			 *(u32 *)((u8 *)th2 + i);
