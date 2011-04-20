From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Wed, 20 Apr 2011 09:42:59 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1104200942020.9266@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <20110418153852.153d3ed3.akpm@linux-foundation.org>  <1303181466.4152.39.camel@edumazet-laptop>  <1303182557.4152.48.camel@edumazet-laptop>  <1303183217.4152.49.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>  <1303279470.2756.17.camel@edumazet-laptop>  <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>
 <1303286998.3186.18.camel@edumazet-laptop>  <1303290464.3186.32.camel@edumazet-laptop>  <1303293765.3186.74.camel@edumazet-laptop>  <alpine.DEB.2.00.1104200904440.8634@router.home> <1303309591.3186.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-473264312-1303310580=:9266"
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.prem.mail.ac4.yahoo.com ([76.13.13.93]:34453 "HELO
	smtp110.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753139Ab1DTOnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 10:43:03 -0400
In-Reply-To: <1303309591.3186.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-473264312-1303310580=:9266
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 20 Apr 2011, Eric Dumazet wrote:

> Le mercredi 20 avril 2011 =C3=A0 09:05 -0500, Christoph Lameter a =C3=A9c=
rit :
> > On Wed, 20 Apr 2011, Eric Dumazet wrote:
> >
> > > > Then, just disable SLUB_CMPXCHG_DOUBLE if KMEMCHECK is defined, as =
I did in my first patch.
> >
> > Ok your first patch seems to be the sanest approach.
> >
> > >  {
> > > @@ -1889,16 +1895,18 @@ static __always_inline void *slab_alloc(struc=
t kmem_cache *s,
> > >  =09struct kmem_cache_cpu *c;
> > >  #ifdef CONFIG_CMPXCHG_LOCAL
> > >  =09unsigned long tid;
> > > -#else
> > > +#endif
> > > +#ifdef MASK_IRQ_IN_SLAB_ALLOC
> > >  =09unsigned long flags;
> > >  #endif
> > >
> >
> > Yea well that does not bring us much.
>
> Well, we keep the fast free path ?
>
> only slab_alloc() would have to disable irqs for ~20 instructions.

Avoiding the irq handling yields the savings that improve the fastpath. if
you do both then there is only a regression left. So lets go with
disabling the CMPXCHG_LOCAL.

---1463811839-473264312-1303310580=:9266--
