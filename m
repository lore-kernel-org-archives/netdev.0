From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ESP] Only one algorithm is required
Date: Sat, 14 Aug 2004 20:52:45 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814105245.GA20646@gondor.apana.org.au>
References: <20040814104807.GA20572@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040814104807.GA20572@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I wrote the wrong subject for the last patch.  It was really
meant for this one :)

Both encryption and authentication are optional for ESP.  However, at
least one of them must be present.  The following patch changes init_state
to match that specification.  It also changes the IPv6 ESP check to allow
zero-length authentication keys as is the case with the IPv4 version.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=esp-alg-check

===== net/ipv4/esp4.c 1.55 vs edited =====
--- 1.55/net/ipv4/esp4.c	2004-08-12 19:59:52 +10:00
+++ edited/net/ipv4/esp4.c	2004-08-14 09:33:05 +10:00
@@ -372,8 +372,7 @@
 	if (x->aalg) {
 		if (x->aalg->alg_key_len > 512)
 			goto error;
-	}
-	if (x->ealg == NULL)
+	} else if (x->ealg == NULL)
 		goto error;
 
 	esp = kmalloc(sizeof(*esp), GFP_KERNEL);
===== net/ipv6/esp6.c 1.36 vs edited =====
--- 1.36/net/ipv6/esp6.c	2004-08-12 19:59:52 +10:00
+++ edited/net/ipv6/esp6.c	2004-08-14 09:33:25 +10:00
@@ -302,11 +302,11 @@
 {
 	struct esp_data *esp = NULL;
 
+	/* null auth and encryption can have zero length keys */
 	if (x->aalg) {
-		if (x->aalg->alg_key_len == 0 || x->aalg->alg_key_len > 512)
+		if (x->aalg->alg_key_len > 512)
 			goto error;
-	}
-	if (x->ealg == NULL)
+	} else if (x->ealg == NULL)
 		goto error;
 
 	if (x->encap)

--DocE+STaALJfprDB--
