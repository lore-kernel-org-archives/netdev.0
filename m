From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Wed, 20 Apr 2011 07:04:18 +0200
Message-ID: <1303275858.2756.8.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
	 <1303181466.4152.39.camel@edumazet-laptop>
	 <1303182557.4152.48.camel@edumazet-laptop>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191617070.23077@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45712 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab1DTFE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 01:04:26 -0400
Received: by wya21 with SMTP id 21so290698wya.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 22:04:25 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1104191617070.23077@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 avril 2011 =C3=A0 16:18 -0500, Christoph Lameter a =C3=A9cr=
it :
> On Tue, 19 Apr 2011, Eric Dumazet wrote:
>=20
> > > Ugg.. Isnt there some way to indicate to kmemcheck that a specula=
tive
> > > access is occurring?
> >
> > Yes, here is a totally untested patch (only compiled here), to keep
> > kmemcheck & cmpxchg_double together.
>=20
> Ok looks somewhat saner. Why does DEBUG_PAGEALLOC need this? Pages ar=
e
> never freed as long as a page is frozen and a page needs to be frozen=
 to
> be allocated from. I dont see how we could reference a free page.

We run lockless and IRQ enabled, are you sure we cannot at this point :

CPU0 - Receive an IRQ
CPU0 - Allocate this same object consume the page(s) containing this ob=
ject
CPU0 - Pass this object/memory to another cpu1
CPU1 - Free memory and free the page(s)
CPU0 - Return from IRQ
CPU0 - Access now unreachable memory ?



