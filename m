From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Problem with "ESP: sha1 digestsize 20 != 0"
Date: Fri, 04 Feb 2005 07:39:38 +1100
Message-ID: <E1CwnlK-0001rv-00@gondolin.me.apana.org.au>
References: <1107461073.6833.8.camel@pegasus>
Cc: netdev@oss.sgi.com, davem@davemloft.net
To: marcel@holtmann.org (Marcel Holtmann)
In-Reply-To: <1107461073.6833.8.camel@pegasus>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Marcel Holtmann <marcel@holtmann.org> wrote:
> 
> when using my RAS account with 2.6.11-rc3, I see a lot of
> 
> 	ESP: sha1 digestsize 20 != 0
> 
> messages in my logs and the IPsec tunnel is not working. I tracked the
> problem down to the change below. After reverting this patch, everything
> works like before.

Sorry, my fault.

The name test in xfrm_get_byname is inverted.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/xfrm/xfrm_algo.c 1.16 vs edited =====
--- 1.16/net/xfrm/xfrm_algo.c	2005-01-26 16:53:19 +11:00
+++ edited/net/xfrm/xfrm_algo.c	2005-02-04 07:38:16 +11:00
@@ -357,7 +357,7 @@
 		return NULL;
 
 	for (i = 0; i < entries; i++) {
-		if (!strcmp(name, list[i].name))
+		if (strcmp(name, list[i].name))
 			continue;
 
 		if (list[i].available)
