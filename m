From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV6] Close small race in ip6_del_rt
Date: Sat, 6 Nov 2004 21:34:49 +1100
Message-ID: <20041106103449.GA18569@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

There is a small SMP race in ip6_del_rt where we maybe dereferencing a dst
that has been freed.  This patch fixes it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/route.c 1.99 vs edited =====
--- 1.99/net/ipv6/route.c	2004-10-26 14:27:49 +10:00
+++ edited/net/ipv6/route.c	2004-11-06 16:40:11 +11:00
@@ -979,9 +979,9 @@
 
 	rt6_reset_dflt_pointer(NULL);
 
+	err = fib6_del(rt, nlh, _rtattr);
 	dst_release(&rt->u.dst);
 
-	err = fib6_del(rt, nlh, _rtattr);
 	write_unlock_bh(&rt6_lock);
 
 	return err;

--Kj7319i9nmIyA2yE--
