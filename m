From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] PA Semi PWRficient Ethernet driver
Date: Tue, 30 Jan 2007 22:45:18 +0100
Message-ID: <20070130214518.GB3252@electric-eye.fr.zoreil.com>
References: <20070129060852.GA7814@lixom.net> <20070129223506.GA29068@electric-eye.fr.zoreil.com> <20070130014116.GB18935@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:49493 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751866AbXA3VtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 16:49:01 -0500
Content-Disposition: inline
In-Reply-To: <20070130014116.GB18935@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson <olof@lixom.net> :
> On Mon, Jan 29, 2007 at 11:35:06PM +0100, Francois Romieu wrote:
[...]
> > - The driver does not contain a single SMP locking instruction but
> >   http://www.pasemi.com claims the platform to be multicore.
> >   Is the driver really designed to be lockless ?
> 
> Unless I misunderstood something, NAPI drivers that don't set NETIF_F_LLTX
> will have all locking taken care of by higher layers, no?

It is not necessarily _that_ simple (it would be cool though :o) ).

For instance, what does prevent pasemi_mac_clean_tx() to be issued
from IRQ context (pasemi_mac_tx_intr) and from the xmit handler
(pasemi_mac_start_tx) at the same time ?

[...]
> > unsigned int is supposed to save some cycles on ppc.
> 
> Who told you that? That's not true.

Jon D Mason <jonmason@us.ibm.com> on 25/08/2004 about ppc64 (not ppc, sorry).

[...]
> > > +#define DESCR(ring, i) ((ring)->desc[i % ((ring)->count)])
> > > +#define BUFF(ring, i) ((ring)->buffers[i % ((ring)->count)])
> > > +#define INFO(ring, i) ((ring)->desc_info[i % ((ring)->count)])
> > 
> > A bit ugly/obfuscating/name clash prone imvho.
> > 
> > Use local variables ?
> 
> I'm open for suggestions here, not sure how local variables will help though?

	struct pas_dma_xct_descr *desc = ring->desc[i % ring->count];

-- 
Ueimor
