From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ESP] Only one algorithm is required
Date: Sun, 15 Aug 2004 05:56:39 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814195639.GA25009@gondor.apana.org.au>
References: <20040814105245.GA20646@gondor.apana.org.au> <Xine.LNX.4.44.0408141012510.26617-100000@dhcp83-76.boston.redhat.com> <20040814192412.GA24399@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k+w/mQv8wyuph6w0"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040814192412.GA24399@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Aug 15, 2004 at 05:24:12AM +1000, herbert wrote:
>
> > This is userland level policy and I don't think the kernel should be
> > enforcing this.
> 
> We should remove the ealg check altogether then?

Please disregard the esp alg check patch altogether.  It's comletely
bogus.

The way to get null algorithms through is to attach a non-null algorithm
with the name set to cipher_null/digest_null.

However, we should fix IPv6 to allow null authentication algorithms.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/esp6.c 1.36 vs edited =====
--- 1.36/net/ipv6/esp6.c	2004-08-12 19:59:52 +10:00
+++ edited/net/ipv6/esp6.c	2004-08-15 05:54:35 +10:00
@@ -302,8 +302,9 @@
 {
 	struct esp_data *esp = NULL;
 
+	/* null auth and encryption can have zero length keys */
 	if (x->aalg) {
-		if (x->aalg->alg_key_len == 0 || x->aalg->alg_key_len > 512)
+		if (x->aalg->alg_key_len > 512)
 			goto error;
 	}
 	if (x->ealg == NULL)

--k+w/mQv8wyuph6w0--
