From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] net: make skb_truesize_bug() call WARN()
Date: Tue, 25 Nov 2008 09:54:32 -0800
Message-ID: <20081125095432.04d73b01@infradead.org>
References: <20081125083250.2ad7d75d@infradead.org>
	<1227631323.3109.7.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41154 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbYKYRxd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:53:33 -0500
In-Reply-To: <1227631323.3109.7.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Nov 2008 16:42:03 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Tue, 2008-11-25 at 08:32 -0800, Arjan van de Ven wrote:
> > From 97a8ab520c378568e172c555a156b469137a3828 Mon Sep 17 00:00:00
> > 2001 From: Arjan van de Ven <arjan@linux.intel.com>
> > Date: Tue, 25 Nov 2008 08:30:04 -0800
> > Subject: [PATCH] net: make skb_truesize_bug() call WARN()
> >=20
> > The truesize message check is important enough to make it print
> > "BUG" to the user console... lets also make it important enough to
> > spit a backtrace/module list etc so that kerneloops.org can track
> > them.
> >=20
> > Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> > ---
> >  net/core/skbuff.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 391be91..1a1f4d1 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -149,7 +149,7 @@ void skb_under_panic(struct sk_buff *skb, int
> > sz, void *here)=20
> >  void skb_truesize_bug(struct sk_buff *skb)
> >  {
> > -	printk(KERN_ERR "SKB BUG: Invalid truesize (%u) "
> > +	WARN(1, KERN_ERR "SKB BUG: Invalid truesize (%u) "
> >  	       "len=3D%u, sizeof(sk_buff)=3D%Zd\n",
> >  	       skb->truesize, skb->len, sizeof(struct sk_buff));
> >  }
>=20
> =EF=BB=BFThe bug reports I've seen (with my Debian hat on, not relati=
ng to
> sfc) show that configurations that trigger this warning are likely to
> trigger many times over and there's nothing the user can do about
> it.  So by all means do make the warning more obvious, but please
> make it WARN_ON_ONCE and then use printk qualified by net_ratelimit()=
=2E
>=20

if there's no value in those subsequent printk's.. why not just this?

=46rom 97a8ab520c378568e172c555a156b469137a3828 Mon Sep 17 00:00:00 200=
1
=46rom: Arjan van de Ven <arjan@linux.intel.com>
Date: Tue, 25 Nov 2008 08:30:04 -0800
Subject: [PATCH] net: make skb_truesize_bug() call WARN()

The truesize message check is important enough to make it print "BUG" t=
o the
user console... lets also make it important enough to spit a backtrace/=
module list
etc so that kerneloops.org can track them.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 net/core/skbuff.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 391be91..1a1f4d1 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -149,7 +149,7 @@ void skb_under_panic(struct sk_buff *skb, int sz, v=
oid *here)
=20
 void skb_truesize_bug(struct sk_buff *skb)
 {
-	printk(KERN_ERR "SKB BUG: Invalid truesize (%u) "
+	WARN_ONCE(1, KERN_ERR "SKB BUG: Invalid truesize (%u) "
 	       "len=3D%u, sizeof(sk_buff)=3D%Zd\n",
 	       skb->truesize, skb->len, sizeof(struct sk_buff));
 }
--=20
1.6.0.3

