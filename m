From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Badness in dst_release
Date: Sat, 18 Dec 2004 18:24:01 +1100
Message-ID: <20041218072401.GA20492@gondor.apana.org.au>
References: <41C13D55.3070002@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="liOOAslEiF7prFVr"
Cc: Netdev <netdev@oss.sgi.com>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41C13D55.3070002@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Dec 16, 2004 at 02:46:29AM -0500, Jeff Garzik wrote:
> 
> After a week or more of uptime, the "Badness in dst_release" messages 
> started again.  Kernel 2.6.10-rc3-bk2.  The first message is below.

Could you please check your kern.log for any abnormal messages prior
to this badness?

> IMO, if you want additional debugging code, add some non-intrusive 
> checks in the upstream kernel.  Since this problem doesn't appear for a 
> while, additional checks would be useful.

Here's a check which might help.  Please apply it and see if it
produces anything.

BTW, there are still races left in addrconf.c.  However, they are
less likely to trigger compared to the one that's been fixed already.
The races are similar in nature to it.  For example, dad_complete
may race with dad_failure to lead to the sequence ip6_del_rt/ip6_ins_rt.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/route.c 1.102 vs edited =====
--- 1.102/net/ipv6/route.c	2004-11-30 14:24:46 +11:00
+++ edited/net/ipv6/route.c	2004-12-18 18:13:59 +11:00
@@ -379,6 +379,7 @@
 	int err;
 
 	write_lock_bh(&rt6_lock);
+	WARN_ON(rt->u.dst->obsolete);
 	err = fib6_add(&ip6_routing_table, rt, nlh, _rtattr);
 	write_unlock_bh(&rt6_lock);
 

--liOOAslEiF7prFVr--
