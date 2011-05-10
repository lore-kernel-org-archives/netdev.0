From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 10 May 2011 16:22:05 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105101619430.4023@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <1303183217.4152.49.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>  <1305022632.2614.18.camel@edumazet-laptop>
  <4DC91137.4030109@cs.helsinki.fi>  <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>  <alpine.DEB.2.00.1105101133440.2611@router.home>  <1305047682.2758.1.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101226460.2875@router.home>  <alpine.DEB.2.00.1105101242420.2875@router.home>
  <1305050754.2758.12.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101323290.4023@router.home>  <1305055948.2437.13.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101435480.4023@router.home>  <1305057989.2437.18.camel@edumazet-laptop>
 <alpine.DEB.2.00.1105101531160.4023@router.home> <1305060353.2437.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.prem.mail.ac4.yahoo.com ([76.13.13.40]:31750 "HELO
	smtp101.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752161Ab1EJVWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 17:22:09 -0400
In-Reply-To: <1305060353.2437.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2011, Eric Dumazet wrote:

> > No the other cpu cannot free the page since the page is pinned by
> > the current cpu (see PageFrozen()).
> >
>
> What happens then ? Other cpu calls kfree() on last nonfreed object for
> this slab, and yet the page stay frozen ? How this page is going to be
> freed at all ?

Yes the page stays frozen. The freed objects are used to replenish the
percpu free list when it becomes empty.

The page is going to be freed when a kmalloc() finds that the per cpu
freelist is empty and that the freelist of the page is also empty. Then
interrupts are disabled, the old page is unfrozen and a new
page is acquired for allocation.

> > > Maybe I am just tired tonight, this seems very obvious, I must miss
> > > something.
> >
> > Yeah you are way off thinking about cpu to cpu concurrency issues that do
> > not apply here.
>
> I fail to understand how current cpu can assert page ownership, if IRQs
> are enabled, this seems obvious it cannot.

The cpu sets a page flag called PageFrozen() and points a per cpu pointer
to the page.


