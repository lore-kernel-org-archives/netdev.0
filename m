From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ipv6: Fix tcp_v6_send_response checksum
Date: Wed, 21 Apr 2010 15:07:37 +0800
Message-ID: <20100421070737.GA30517@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:57352 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751611Ab0DUHHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 03:07:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

ipv6: Fix tcp_v6_send_response checksum

My recent patch to remove the open-coded checksum sequence in
tcp_v6_send_response broke it as we did not set the transport
header pointer on the new packet.

Instead we had set the transport header on the original packet,
which is unnecessary and unexpected.

So this patch removes that and instead sets the transport header
on the new packet.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c92ebe8..075f540 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1015,7 +1015,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + tot_len);
 
 	t1 = (struct tcphdr *) skb_push(buff, tot_len);
-	skb_reset_transport_header(skb);
+	skb_reset_transport_header(buff);
 
 	/* Swap the send and the receive. */
 	memset(t1, 0, sizeof(*t1));

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
