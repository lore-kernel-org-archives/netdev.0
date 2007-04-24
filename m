From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Warn about GSO/checksum abuse
Date: Tue, 24 Apr 2007 13:55:42 +1000
Message-ID: <20070424035542.GA29189@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1218 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161569AbXDXDzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 23:55:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[NET]: Warn about GSO/checksum abuse

Now that Patrick has added the code to deal with GSO in netfilter,
we no longer need the crutch that computes partial checksums just
before transmission.

This patch turns this into a warning again.  If this goes OK, we
can then turn it into a BUG_ON and remove the gso_send_check cruft.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/dev.c b/net/core/dev.c
index 18c51b4..d82d00f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1202,7 +1202,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features)
 	skb->mac_len = skb->network_header - skb->mac_header;
 	__skb_pull(skb, skb->mac_len);
 
-	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
+	if (WARN_ON(skb->ip_summed != CHECKSUM_PARTIAL)) {
 		if (skb_header_cloned(skb) &&
 		    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
 			return ERR_PTR(err);
