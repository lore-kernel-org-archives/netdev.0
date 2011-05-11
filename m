From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Wed, 11 May 2011 05:12:23 +0200
Message-ID: <1305083543.2437.39.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>
	 <1305022632.2614.18.camel@edumazet-laptop>
	 <4DC91137.4030109@cs.helsinki.fi>
	 <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>
	 <alpine.DEB.2.00.1105101133440.2611@router.home>
	 <1305047682.2758.1.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101226460.2875@router.home>
	 <alpine.DEB.2.00.1105101242420.2875@router.home>
	 <1305050754.2758.12.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101323290.4023@router.home>
	 <1305055948.2437.13.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101435480.4023@router.home>
	 <1305057989.2437.18.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101531160.4023@router.home>
	 <1305060353.2437.26.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101619430.4023@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60385 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab1EKDMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 23:12:31 -0400
Received: by wya21 with SMTP id 21so55141wya.19
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 20:12:29 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1105101619430.4023@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 10 mai 2011 =C3=A0 16:22 -0500, Christoph Lameter a =C3=A9crit=
 :
> On Tue, 10 May 2011, Eric Dumazet wrote:
>=20
> > > No the other cpu cannot free the page since the page is pinned by
> > > the current cpu (see PageFrozen()).
> > >
> >
> > What happens then ? Other cpu calls kfree() on last nonfreed object=
 for
> > this slab, and yet the page stay frozen ? How this page is going to=
 be
> > freed at all ?
>=20
> Yes the page stays frozen. The freed objects are used to replenish th=
e
> percpu free list when it becomes empty.
>=20
> The page is going to be freed when a kmalloc() finds that the per cpu
> freelist is empty and that the freelist of the page is also empty. Th=
en
> interrupts are disabled, the old page is unfrozen and a new
> page is acquired for allocation.
>=20
> > > > Maybe I am just tired tonight, this seems very obvious, I must =
miss
> > > > something.
> > >
> > > Yeah you are way off thinking about cpu to cpu concurrency issues=
 that do
> > > not apply here.
> >
> > I fail to understand how current cpu can assert page ownership, if =
IRQs
> > are enabled, this seems obvious it cannot.
>=20
> The cpu sets a page flag called PageFrozen() and points a per cpu poi=
nter
> to the page.
>=20
>=20

So, if I understand you, there is no problem at all and no patch even
needed ? I can start a stress test and you guarantee there wont be a
crash ?

Sorry, its 5h11 in the morning here ;)



