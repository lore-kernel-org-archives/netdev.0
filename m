From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP] Fixed mss in tcp_init_cwnd
Date: Mon, 27 Sep 2004 18:08:28 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927080828.GA12056@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0F1p//8PRICkK4MW"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

The MSS in tcp_init_cwnd should be the real one instead of the TSO value.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/tcp_input.c 1.73 vs edited =====
--- 1.73/net/ipv4/tcp_input.c	2004-09-13 10:30:58 +10:00
+++ edited/net/ipv4/tcp_input.c	2004-09-27 17:00:32 +10:00
@@ -799,10 +799,10 @@
 	__u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
 
 	if (!cwnd) {
-		if (tp->mss_cache > 1460)
+		if (tp->mss_cache_std > 1460)
 			cwnd = 2;
 		else
-			cwnd = (tp->mss_cache > 1095) ? 3 : 4;
+			cwnd = (tp->mss_cache_std > 1095) ? 3 : 4;
 	}
 	return min_t(__u32, cwnd, tp->snd_cwnd_clamp);
 }

--0F1p//8PRICkK4MW--
