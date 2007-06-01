From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET] gso: Fix GSO feature mask in sk_setup_caps
Date: Fri, 1 Jun 2007 15:13:49 +1000
Message-ID: <20070601051349.GA13244@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3659 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752908AbXFAFNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 01:13:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[NET] gso: Fix GSO feature mask in sk_setup_caps

This isn't a bug just yet as only TCP uses sk_setup_caps for GSO.
However, if and when UDP or something else starts using it this is
likely to cause a problem if we forget to add software emulation
for it at the same time.

The problem is that right now we translate GSO emulation to the
bitmask NETIF_F_GSO_MASK, which includes every protocol, even
ones that we cannot emulate.

This patch makes it provide only the ones that we can emulate.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/sock.c b/net/core/sock.c
index 7e51d3a..c14ce01 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -998,7 +998,7 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 	__sk_dst_set(sk, dst);
 	sk->sk_route_caps = dst->dev->features;
 	if (sk->sk_route_caps & NETIF_F_GSO)
-		sk->sk_route_caps |= NETIF_F_GSO_MASK;
+		sk->sk_route_caps |= NETIF_F_GSO_SOFTWARE;
 	if (sk_can_gso(sk)) {
 		if (dst->header_len)
 			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
