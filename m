From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV4] Disable MULTIPATH_CACHED on input path
Date: Tue, 5 Apr 2005 23:04:41 +1000
Message-ID: <20050405130441.GA5604@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Since we're not doing multipath selection on the input path yet,
we should disable the code that inserts the multipath route
entries for the input path.

As it is we are inserting a whole bunch of useless entries as
well as breaking multipath routing for the input path (forwarded
packets) completely.

I left the code around since we're planning to do this at
some point.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

As this code is going to stick around, I'm going to fix it :)
Expect more patches soon.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/route.c 1.108 vs edited =====
--- 1.108/net/ipv4/route.c	2005-03-23 15:06:23 +11:00
+++ edited/net/ipv4/route.c	2005-04-05 23:00:28 +10:00
@@ -1720,7 +1720,7 @@
 	}
 
 	rth->u.dst.flags= DST_HOST;
-#ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
+#if 0
 	if (res->fi->fib_nhs > 1)
 		rth->u.dst.flags |= DST_BALANCED;
 #endif
@@ -1792,7 +1792,7 @@
 				   struct in_device *in_dev,
 				   u32 daddr, u32 saddr, u32 tos)
 {
-#ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
+#if 0
 	struct rtable* rth;
 	unsigned char hop, hopcount, lasthop;
 	int err = -EINVAL;

--NzB8fVQJ5HfG6fxh--
