From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/7] [CRYPTO] doc: Update documentation for hash and me
Date: Tue, 22 Aug 2006 00:27:56 +1000
Message-ID: <E1GFAku-00074W-00@gondolin.me.apana.org.au>
References: <20060821142407.GA26988@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42758 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751889AbWHUO17
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 10:27:59 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] doc: Update documentation for hash and me

This patch updates the documentation to reflect the switch from digest
to hash.  It also replaces notes about emailing James Morris to refer
to me instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 Documentation/crypto/api-intro.txt |   36 ++++++++++++++++++++++--------------
 1 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/Documentation/crypto/api-intro.txt b/Documentation/crypto/api-intro.txt
--- a/Documentation/crypto/api-intro.txt
+++ b/Documentation/crypto/api-intro.txt
@@ -19,15 +19,14 @@ At the lowest level are algorithms, whic
 API.
 
 'Transforms' are user-instantiated objects, which maintain state, handle all
-of the implementation logic (e.g. manipulating page vectors), provide an 
-abstraction to the underlying algorithms, and handle common logical 
-operations (e.g. cipher modes, HMAC for digests).  However, at the user 
+of the implementation logic (e.g. manipulating page vectors) and provide an 
+abstraction to the underlying algorithms.  However, at the user 
 level they are very simple.
 
 Conceptually, the API layering looks like this:
 
   [transform api]  (user interface)
-  [transform ops]  (per-type logic glue e.g. cipher.c, digest.c)
+  [transform ops]  (per-type logic glue e.g. cipher.c, compress.c)
   [algorithm api]  (for registering algorithms)
   
 The idea is to make the user interface and algorithm registration API
@@ -44,22 +43,27 @@ under development.
 Here's an example of how to use the API:
 
 	#include <linux/crypto.h>
+	#include <linux/err.h>
+	#include <linux/scatterlist.h>
 	
 	struct scatterlist sg[2];
 	char result[128];
-	struct crypto_tfm *tfm;
+	struct crypto_hash *tfm;
+	struct hash_desc desc;
 	
-	tfm = crypto_alloc_tfm("md5", 0);
-	if (tfm == NULL)
+	tfm = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
 		fail();
 		
 	/* ... set up the scatterlists ... */
+
+	desc.tfm = tfm;
+	desc.flags = 0;
 	
-	crypto_digest_init(tfm);
-	crypto_digest_update(tfm, &sg, 2);
-	crypto_digest_final(tfm, result);
+	if (crypto_hash_digest(&desc, &sg, 2, result))
+		fail();
 	
-	crypto_free_tfm(tfm);
+	crypto_free_hash(tfm);
 
     
 Many real examples are available in the regression test module (tcrypt.c).
@@ -126,7 +130,7 @@ might already be working on.
 BUGS
 
 Send bug reports to:
-James Morris <jmorris@redhat.com>
+Herbert Xu <herbert@gondor.apana.org.au>
 Cc: David S. Miller <davem@redhat.com>
 
 
@@ -134,13 +138,14 @@ FURTHER INFORMATION
 
 For further patches and various updates, including the current TODO
 list, see:
-http://samba.org/~jamesm/crypto/
+http://gondor.apana.org.au/~herbert/crypto/
 
 
 AUTHORS
 
 James Morris
 David S. Miller
+Herbert Xu
 
 
 CREDITS
@@ -238,8 +243,11 @@ Anubis algorithm contributors:
 Tiger algorithm contributors:
   Aaron Grothe
 
+VIA PadLock contributors:
+  Michal Ludvig
+
 Generic scatterwalk code by Adam J. Richter <adam@yggdrasil.com>
 
 Please send any credits updates or corrections to:
-James Morris <jmorris@redhat.com>
+Herbert Xu <herbert@gondor.apana.org.au>
 
