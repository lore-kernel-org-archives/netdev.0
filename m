From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPv4] Fix thinko in fib_find_alias
Date: Thu, 23 Sep 2004 14:15:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923041516.GA19252@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k+w/mQv8wyuph6w0"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

fib_find_alias is meant to return either an exact match or the
entry just before where it should be.  Currently it returns the
entry after that.  This patch fixes that.

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

===== net/ipv4/fib_hash.c 1.23 vs edited =====
--- 1.23/net/ipv4/fib_hash.c	2004-09-23 14:07:29 +10:00
+++ edited/net/ipv4/fib_hash.c	2004-09-23 14:08:42 +10:00
@@ -448,7 +448,7 @@
 			if (prio <= fa->fa_info->fib_priority)
 				break;
 		}
-		return fa;
+		return prev_fa;
 	}
 	return NULL;
 }

--k+w/mQv8wyuph6w0--
