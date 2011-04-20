From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Wed, 20 Apr 2011 09:04:08 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1104200901010.8634@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <20110418153852.153d3ed3.akpm@linux-foundation.org>  <1303181466.4152.39.camel@edumazet-laptop>  <1303182557.4152.48.camel@edumazet-laptop>  <1303183217.4152.49.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191617070.23077@router.home> <1303275858.2756.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-68727899-1303308250=:8634"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.prem.mail.ac4.yahoo.com ([76.13.13.92]:26486 "HELO
	smtp109.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752240Ab1DTOEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 10:04:13 -0400
In-Reply-To: <1303275858.2756.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-68727899-1303308250=:8634
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 20 Apr 2011, Eric Dumazet wrote:

> Le mardi 19 avril 2011 =C3=A0 16:18 -0500, Christoph Lameter a =C3=A9crit=
 :
> > On Tue, 19 Apr 2011, Eric Dumazet wrote:
> >
> > > > Ugg.. Isnt there some way to indicate to kmemcheck that a speculati=
ve
> > > > access is occurring?
> > >
> > > Yes, here is a totally untested patch (only compiled here), to keep
> > > kmemcheck & cmpxchg_double together.
> >
> > Ok looks somewhat saner. Why does DEBUG_PAGEALLOC need this? Pages are
> > never freed as long as a page is frozen and a page needs to be frozen t=
o
> > be allocated from. I dont see how we could reference a free page.
>
> We run lockless and IRQ enabled, are you sure we cannot at this point :
>
> CPU0 - Receive an IRQ
> CPU0 - Allocate this same object consume the page(s) containing this obje=
ct
> CPU0 - Pass this object/memory to another cpu1
> CPU1 - Free memory and free the page(s)
> CPU0 - Return from IRQ
> CPU0 - Access now unreachable memory ?

True this can occur.

---1463811839-68727899-1303308250=:8634--
