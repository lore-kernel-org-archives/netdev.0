From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6 badness continues
Date: Sun, 9 Jan 2005 05:35:45 +1100
Message-ID: <20050108183545.GA6413@gondor.apana.org.au>
References: <41DA3A60.8050102@pobox.com> <20050108042509.GA1959@gondor.apana.org.au> <41E01746.3080501@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cNdxnHkX5QqsyA0e"
Cc: Netdev <netdev@oss.sgi.com>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41E01746.3080501@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jan 08, 2005 at 12:24:22PM -0500, Jeff Garzik wrote:
> Herbert Xu wrote:
> >===== net/ipv6/route.c 1.102 vs edited =====
> >--- 1.102/net/ipv6/route.c	2004-11-30 14:24:46 +11:00
> >+++ edited/net/ipv6/route.c	2005-01-08 15:23:24 +11:00
> >@@ -379,6 +379,7 @@
> > 	int err;
> > 
> > 	write_lock_bh(&rt6_lock);
> >+	WARN_ON(rt->u.dst->obsolete);
> > 	err = fib6_add(&ip6_routing_table, rt, nlh, _rtattr);
> > 	write_unlock_bh(&rt6_lock);
> 
> still broken:
> 
> net/ipv6/route.c: In function `ip6_ins_rt':
> net/ipv6/route.c:382: error: invalid type argument of `->'

Sorry, I thought you meant that it didn't apply :)

Here is the corrected version.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/route.c 1.102 vs edited =====
--- 1.102/net/ipv6/route.c	2004-11-30 14:24:46 +11:00
+++ edited/net/ipv6/route.c	2005-01-09 05:34:03 +11:00
@@ -379,6 +379,7 @@
 	int err;
 
 	write_lock_bh(&rt6_lock);
+	WARN_ON(rt->u.dst.obsolete);
 	err = fib6_add(&ip6_routing_table, rt, nlh, _rtattr);
 	write_unlock_bh(&rt6_lock);
 

--cNdxnHkX5QqsyA0e--
