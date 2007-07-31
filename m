From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Ensure that state inner family is set
Date: Tue, 31 Jul 2007 16:53:56 +0800
Message-ID: <20070731085356.GA22900@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4315 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752680AbXGaIyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 04:54:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[IPSEC]: Ensure that state inner family is set

Similar to the issue we had with template families which
specified the inner families of policies, we need to set
the inner families of states as the main xfrm user Openswan
leaves it as zero.

af_key is unaffected because the inner family is set by it
and not the KM.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index c06883b..61339e1 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -322,6 +322,13 @@ static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *
 	x->props.family = p->family;
 	memcpy(&x->props.saddr, &p->saddr, sizeof(x->props.saddr));
 	x->props.flags = p->flags;
+
+	/*
+	 * Set inner address family if the KM left it as zero.
+	 * See comment in validate_tmpl.
+	 */
+	if (!x->sel.family)
+		x->sel.family = p->family;
 }
 
 /*
