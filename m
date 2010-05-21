From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gro: Fix bogus gso_size on the first fraglist entry
Date: Fri, 21 May 2010 12:46:29 +1000
Message-ID: <20100521024629.GA24700@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Igor Zhang <yugzhang@redhat.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:54584 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753304Ab0EUCqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 22:46:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

gro: Fix bogus gso_size on the first fraglist entry

When GRO produces fraglist entries, and the resulting skb hits
an interface that is incapable of TSO but capable of FRAGLIST,
we end up producing a bogus packet with gso_size non-zero.

This was reported in the field with older versions of KVM that
did not set the TSO bits on tuntap.

This patch fixes that.

Reported-by: Igor Zhang <yugzhang@redhat.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 93c4e06..cad8e97 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2729,6 +2729,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	*NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);
 	skb_shinfo(nskb)->frag_list = p;
 	skb_shinfo(nskb)->gso_size = pinfo->gso_size;
+	pinfo->gso_size = 0;
 	skb_header_release(p);
 	nskb->prev = p;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
