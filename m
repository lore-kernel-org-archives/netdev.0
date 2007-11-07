From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Possible BUG on net/ipv4/ipcomp.c, line 358 (fwd)
Date: Wed, 7 Nov 2007 09:11:24 +0800
Message-ID: <20071107011124.GA29479@gondor.apana.org.au>
References: <Xine.LNX.4.64.0711070751530.27327@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1378 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754915AbXKGBLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 20:11:31 -0500
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.64.0711070751530.27327@us.intercode.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 07, 2007 at 07:51:57AM +1100, James Morris wrote:
>
> ---------- Forwarded message ----------
> Date: Tue, 06 Nov 2007 14:53:30 +0100
> From: Vicen=E7 <vbeltran@ac.upc.edu>
> To: jmorris@intercode.com.au
> Subject: Possible BUG on net/ipv4/ipcomp.c, line 358
>=20
> Hi James,
>=20
> I think there is a bug on net/ipv4/ipcomp.c line 358. The trivial pat=
ch that
> should fix it is:

Thanks for the report! The same bug exists in IPv6 too and
this patch should fix both.

[IPSEC]: Fix crypto_alloc_comp error checking

The function crypto_alloc_comp returns an errno instead of NULL
to indicate error.  So it needs to be tested with IS_ERR.

This is based on a patch by Vicen=E7 Beltran Querol.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index ca1b5fd..2c44a94 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -16,6 +16,7 @@
 #include <linux/module.h>
 #include <asm/semaphore.h>
 #include <linux/crypto.h>
+#include <linux/err.h>
 #include <linux/pfkeyv2.h>
 #include <linux/percpu.h>
 #include <linux/smp.h>
@@ -344,7 +345,7 @@ static struct crypto_comp **ipcomp_alloc_tfms(const=
 char *alg_name)
 	for_each_possible_cpu(cpu) {
 		struct crypto_comp *tfm =3D crypto_alloc_comp(alg_name, 0,
 							    CRYPTO_ALG_ASYNC);
-		if (!tfm)
+		if (IS_ERR(tfm))
 			goto error;
 		*per_cpu_ptr(tfms, cpu) =3D tfm;
 	}
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 85eb479..0cd4056 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -36,6 +36,7 @@
 #include <net/ipcomp.h>
 #include <asm/semaphore.h>
 #include <linux/crypto.h>
+#include <linux/err.h>
 #include <linux/pfkeyv2.h>
 #include <linux/random.h>
 #include <linux/percpu.h>
@@ -358,7 +359,7 @@ static struct crypto_comp **ipcomp6_alloc_tfms(cons=
t char *alg_name)
 	for_each_possible_cpu(cpu) {
 		struct crypto_comp *tfm =3D crypto_alloc_comp(alg_name, 0,
 							    CRYPTO_ALG_ASYNC);
-		if (!tfm)
+		if (IS_ERR(tfm))
 			goto error;
 		*per_cpu_ptr(tfms, cpu) =3D tfm;
 	}
