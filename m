From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Use digest_null directly for auth
Date: Sun, 27 Apr 2008 15:17:47 +0800
Message-ID: <20080427071747.GA2317@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54794 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758971AbYD0HRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 03:17:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This patch is a minor optimisation to avoid using hmac on null
authentication when explicitly specified by the user.

[IPSEC]: Use digest_null directly for auth

Previously digest_null had no setkey function which meant that
we used hmac(digest_null) for IPsec since IPsec always calls
setkey.  Now that digest_null has a setkey we no longer need to
do that.

In fact when only confidentiality is specified for ESP we already
use digest_null directly.  However, when the null algorithm is
explicitly specified by the user we still opt for hmac(digest_null).

This patch removes this discrepancy.  I have not added a new compat
name for it because by chance it wasn't actualy possible for the user
to specify the name hmac(digest_null) due to a key length check in
xfrm_user (which I found out when testing that compat name :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 8aa6440..ac765dd 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -129,8 +129,7 @@ static struct xfrm_algo_desc aead_list[] = {
 
 static struct xfrm_algo_desc aalg_list[] = {
 {
-	.name = "hmac(digest_null)",
-	.compat = "digest_null",
+	.name = "digest_null",
 
 	.uinfo = {
 		.auth = {
