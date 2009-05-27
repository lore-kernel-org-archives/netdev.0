From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 14/14] tcp: Do not check flush when comparing options for GRO
Date: Wed, 27 May 2009 14:50:34 +1000
Message-ID: <E1M9B62-0001Tq-8q@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45737 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759765AbZE0FTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:19:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp: Do not check flush when comparing options for GRO

There is no need to repeatedly check flush when comparing TCP
options for GRO as it will be false 99% of the time where it
matters.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/tcp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c3dcec5..0fb8b44 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2570,7 +2570,7 @@ found:
 	flush |= (flags ^ tcp_flag_word(th2)) &
 		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH);
 	flush |= th->ack_seq ^ th2->ack_seq;
-	for (i = sizeof(*th); !flush && i < thlen; i += 4)
+	for (i = sizeof(*th); i < thlen; i += 4)
 		flush |= *(u32 *)((u8 *)th + i) ^
 			 *(u32 *)((u8 *)th2 + i);
 
