From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Verify key payload in verify_one_algo
Date: Thu, 19 May 2005 12:15:05 +1000
Message-ID: <20050519021505.GA20703@gondor.apana.org.au>
References: <20050519020302.GA20285@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="wac7ysb48OaltWcw"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050519020302.GA20285@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

We need to verify that the payload contains enough data so that
attach_one_algo can copy alg_key_len bits from the payload.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-user-2

--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -34,14 +34,21 @@ static int verify_one_alg(struct rtattr 
 {
 	struct rtattr *rt = xfrma[type - 1];
 	struct xfrm_algo *algp;
+	int len;
 
 	if (!rt)
 		return 0;
 
-	if ((rt->rta_len - sizeof(*rt)) < sizeof(*algp))
+	len = (rt->rta_len - sizeof(*rt)) - sizeof(*algp);
+	if (len < 0)
 		return -EINVAL;
 
 	algp = RTA_DATA(rt);
+
+	len -= (algp->alg_key_len + 7U) / 8; 
+	if (len < 0)
+		return -EINVAL;
+
 	switch (type) {
 	case XFRMA_ALG_AUTH:
 		if (!algp->alg_key_len &&

--wac7ysb48OaltWcw--
