From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: unregister_netdevice(): negative refcnt, suggest patch against 2.6.11
Date: Mon, 18 Apr 2005 12:07:49 +1000
Message-ID: <E1DNLfx-0000yd-00@gondolin.me.apana.org.au>
References: <20050411125113.GL26731@postel.suug.ch>
Cc: fmp@palmen.homeip.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20050411125113.GL26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
> 
> OK, I think the problem is a few missing dev_hold() when the net_device
> handle is assigned to routes, probes, etc.

Indeed.  Here is a patch that adds the references that are held by
the routes.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/appletalk/ddp.c 1.58 vs edited =====
--- 1.58/net/appletalk/ddp.c	2005-03-27 09:04:35 +10:00
+++ edited/net/appletalk/ddp.c	2005-04-18 11:29:17 +10:00
@@ -573,6 +573,7 @@
 
 	/* Fill in the routing entry */
 	rt->target  = ta->sat_addr;
+	dev_hold(devhint);
 	rt->dev     = devhint;
 	rt->flags   = r->rt_flags;
 	rt->gateway = ga->sat_addr;
