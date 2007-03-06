From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [UDP]: Reread uh pointer after pskb_trim
Date: Tue, 6 Mar 2007 12:00:20 +1100
Message-ID: <20070306010020.GA25265@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4990 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752761AbXCFBAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 20:00:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[UDP]: Reread uh pointer after pskb_trim

The header may have moved when trimming.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ce6c460..fc620a7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1215,6 +1215,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 
 		if (ulen < sizeof(*uh) || pskb_trim_rcsum(skb, ulen))
 			goto short_packet;
+		uh = skb->h.uh;
 
 		udp4_csum_init(skb, uh);
 
