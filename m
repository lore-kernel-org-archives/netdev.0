From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Set truesize in pskb_expand_head
Date: Sat, 25 Sep 2004 09:20:53 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924232053.GA7807@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

In order for the skb trimming to work, we need to set truesize in
pskb_expand_head.  This patch does exactly that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/core/skbuff.c 1.37 vs edited =====
--- 1.37/net/core/skbuff.c	2004-08-03 12:20:05 +10:00
+++ edited/net/core/skbuff.c	2004-09-25 09:15:23 +10:00
@@ -541,6 +541,7 @@
 
 	off = (data + nhead) - skb->head;
 
+	skb->truesize = size + sizeof(struct sk_buff);
 	skb->head     = data;
 	skb->end      = data + size;
 	skb->data    += off;

--+HP7ph2BbKc20aGI--
