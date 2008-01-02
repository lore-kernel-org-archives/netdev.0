From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Return EOVERFLOW when output sequence number overflows
Date: Wed, 2 Jan 2008 18:16:20 +1100
Message-ID: <20080102071619.GA23687@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1955 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756789AbYABHQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 02:16:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

[IPSEC]: Return EOVERFLOW when output sequence number overflows

Previously we made it an error on the output path if the sequence number
overflowed.  However we did not set the err variable accordingly.  This
patch sets err to -EOVERFLOW in that case.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 81ad8eb..f4a1047 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -66,6 +66,7 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 			if (unlikely(x->replay.oseq == 0)) {
 				x->replay.oseq--;
 				xfrm_audit_state_replay_overflow(x, skb);
+				err = -EOVERFLOW;
 				goto error;
 			}
 			if (xfrm_aevent_is_on())

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
