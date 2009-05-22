From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: tcp: Unexport TCPv6 GRO functions
Date: Fri, 22 May 2009 17:19:44 +1000
Message-ID: <20090522071944.GA23355@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57825 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751250AbZEVHTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 03:19:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

tcp: Unexport TCPv6 GRO functions

Sinec the TCPv6 GRO functions are used in the same file where
they are defined, we do not need to export them.  This was a
cut-n-paste from the IPv4 code which does need to export them.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4b5aa18..6c59d1f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -941,7 +941,8 @@ static int tcp_v6_gso_send_check(struct sk_buff *skb)
 	return 0;
 }
 
-struct sk_buff **tcp6_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 
@@ -961,9 +962,8 @@ struct sk_buff **tcp6_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 	return tcp_gro_receive(head, skb);
 }
-EXPORT_SYMBOL(tcp6_gro_receive);
 
-int tcp6_gro_complete(struct sk_buff *skb)
+static int tcp6_gro_complete(struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
@@ -974,7 +974,6 @@ int tcp6_gro_complete(struct sk_buff *skb)
 
 	return tcp_gro_complete(skb);
 }
-EXPORT_SYMBOL(tcp6_gro_complete);
 
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 				 u32 ts, struct tcp_md5sig_key *key, int rst)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
