From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6 badness continues
Date: Sun, 9 Jan 2005 21:31:12 +1100
Message-ID: <20050109103112.GA30653@gondor.apana.org.au>
References: <41DA3A60.8050102@pobox.com> <20050108042509.GA1959@gondor.apana.org.au> <41E01746.3080501@pobox.com> <20050108183545.GA6413@gondor.apana.org.au> <41E084E0.9070709@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Cc: Netdev <netdev@oss.sgi.com>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41E084E0.9070709@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jan 08, 2005 at 08:12:00PM -0500, Jeff Garzik wrote:
> 
> I applied the patch and tried it out.  The kernel was practically 
> unusable, as the warning hit as soon as the kernel booted:

Sorry.  Should've tested it first.  Please try this one instead.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/route.c 1.102 vs edited =====
--- 1.102/net/ipv6/route.c	2004-11-30 14:24:46 +11:00
+++ edited/net/ipv6/route.c	2005-01-09 21:28:05 +11:00
@@ -379,6 +379,7 @@
 	int err;
 
 	write_lock_bh(&rt6_lock);
+	WARN_ON(rt->u.dst.obsolete > 0);
 	err = fib6_add(&ip6_routing_table, rt, nlh, _rtattr);
 	write_unlock_bh(&rt6_lock);
 

--oyUTqETQ0mS9luUI--
