From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6 "badness" in recent releases
Date: Mon, 15 Nov 2004 07:35:17 +1100
Message-ID: <E1CTR5h-0006ac-00@gondolin.me.apana.org.au>
References: <4197AC20.6020707@pobox.com>
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com (Jeff Garzik)
In-Reply-To: <4197AC20.6020707@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> I login (same machine that used to have the "BUG: dst underflow" 
> problems) and see
> 
> [first one I can find in log]
> Badness in dst_release at include/net/dst.h:149

Thanks.  This is what "dst underflow" looks like in the new kernels.
Unfortunately whatever caused this has already happened so we can
only guess about where the bug is.

Could you please apply this patch and see if the warning triggers
before the underflows start coming in? We already know that if it
does then it can cause underflows but I want to make sure that
this is what's causing your problems.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/ipv6/addrconf.c 1.115 vs edited =====
--- 1.115/net/ipv6/addrconf.c	2004-10-26 14:11:35 +10:00
+++ edited/net/ipv6/addrconf.c	2004-11-09 22:44:35 +11:00
@@ -2989,6 +2989,7 @@
 		dst_hold(&ifp->rt->u.dst);
 		if (ip6_ins_rt(ifp->rt, NULL, NULL))
 			dst_release(&ifp->rt->u.dst);
+		WARN_ON(ifp->dead);
 		if (ifp->idev->cnf.forwarding)
 			addrconf_join_anycast(ifp);
 		break;
