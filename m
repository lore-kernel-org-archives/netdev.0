From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6 badness continues
Date: Sat, 8 Jan 2005 15:25:09 +1100
Message-ID: <20050108042509.GA1959@gondor.apana.org.au>
References: <41DA3A60.8050102@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
Cc: Netdev <netdev@oss.sgi.com>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41DA3A60.8050102@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jan 04, 2005 at 01:40:32AM -0500, Jeff Garzik wrote:
> 
> This problem seems to be appearing much sooner, in 2.6.10 and 2.6.10-bk 
> kernels.  Herbert, your patch did not apply to recent kernels, so I did 
> not boot with it.

Here is that patch rediffed against the current bk.  BTW, I'd like
to access the machine with the problem.  However, in order for it
to be useful I also need access to the build directory of your kernel
so that I can match things up.  Please mail me privately to set it up.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/route.c 1.102 vs edited =====
--- 1.102/net/ipv6/route.c	2004-11-30 14:24:46 +11:00
+++ edited/net/ipv6/route.c	2005-01-08 15:23:24 +11:00
@@ -379,6 +379,7 @@
 	int err;
 
 	write_lock_bh(&rt6_lock);
+	WARN_ON(rt->u.dst->obsolete);
 	err = fib6_add(&ip6_routing_table, rt, nlh, _rtattr);
 	write_unlock_bh(&rt6_lock);
 

--/04w6evG8XlLl3ft--
