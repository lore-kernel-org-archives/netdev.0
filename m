From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH] PA Semi PWRficient Ethernet driver
Date: Tue, 30 Jan 2007 22:52:09 -0600
Message-ID: <20070131045209.GA31095@lixom.net>
References: <20070129060852.GA7814@lixom.net> <20070129223506.GA29068@electric-eye.fr.zoreil.com> <20070130014116.GB18935@lixom.net> <20070130214518.GB3252@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:43591 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751987AbXAaEp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 23:45:26 -0500
Content-Disposition: inline
In-Reply-To: <20070130214518.GB3252@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 30, 2007 at 10:45:18PM +0100, Francois Romieu wrote:
> Olof Johansson <olof@lixom.net> :
> > On Mon, Jan 29, 2007 at 11:35:06PM +0100, Francois Romieu wrote:
> [...]
> > > - The driver does not contain a single SMP locking instruction but
> > >   http://www.pasemi.com claims the platform to be multicore.
> > >   Is the driver really designed to be lockless ?
> > 
> > Unless I misunderstood something, NAPI drivers that don't set NETIF_F_LLTX
> > will have all locking taken care of by higher layers, no?
> 
> It is not necessarily _that_ simple (it would be cool though :o) ).
> 
> For instance, what does prevent pasemi_mac_clean_tx() to be issued
> from IRQ context (pasemi_mac_tx_intr) and from the xmit handler
> (pasemi_mac_start_tx) at the same time ?

You're right. Bummer. I'll add locking on the rings.

> [...]
> > > unsigned int is supposed to save some cycles on ppc.
> > 
> > Who told you that? That's not true.
> 
> Jon D Mason <jonmason@us.ibm.com> on 25/08/2004 about ppc64 (not ppc, sorry).

Interesting, I hadn't thought about that before.

There's nothing architectural in PPC that makes signed math slower than
unsigned, but in the case of modulo operations (which we do alot on the
rings), unsigned is per definition more complex to do the operations on.

It's pretty much within the noise on the current implementation, but
still an interesting tidbit. Thanks.

> [...]
> > > > +#define DESCR(ring, i) ((ring)->desc[i % ((ring)->count)])
> > > > +#define BUFF(ring, i) ((ring)->buffers[i % ((ring)->count)])
> > > > +#define INFO(ring, i) ((ring)->desc_info[i % ((ring)->count)])
> > > 
> > > A bit ugly/obfuscating/name clash prone imvho.
> > > 
> > > Use local variables ?
> > 
> > I'm open for suggestions here, not sure how local variables will help though?
> 
> 	struct pas_dma_xct_descr *desc = ring->desc[i % ring->count];

That makes sense. Done.


-Olof
