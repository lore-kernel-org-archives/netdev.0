From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] gianfar: Fix crashes on RX path (Was Re: [Bugme-new]
	[Bug 19692] New: linux-2.6.36-rc5 crash with gianfar ethernet at
	full line rate traffic)
Date: Fri, 22 Oct 2010 08:52:48 +0000
Message-ID: <20101022085248.GA8571@ff.dom.local>
References: <20101010103236.GA1919@del.dom.local> <20101015085853.GA8091@ff.dom.local> <AANLkTinAj=9-RqNA6xKc_5ONz2hPMRGM8uJ2Xy7XJVdr@mail.gmail.com> <20101016194815.GA1894@del.dom.local> <AANLkTi=08Myz1=XOHkGJWTdyC8vK+y+zf0UQhjxUi=qC@mail.gmail.com> <20101019100636.GA9246@ff.dom.local> <1287727917.9059.117.camel@edumazet-laptop> <20101022065231.GA7036@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, emin ak <eminak71@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Anton Vorontsov <avorontsov@mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53124 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511Ab0JVIwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 04:52:53 -0400
Received: by fxm16 with SMTP id 16so446767fxm.19
        for <netdev@vger.kernel.org>; Fri, 22 Oct 2010 01:52:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101022065231.GA7036@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 22, 2010 at 06:52:31AM +0000, Jarek Poplawski wrote:
> On Fri, Oct 22, 2010 at 08:11:57AM +0200, Eric Dumazet wrote:
...
> > Gianfar claims to be multiqueue, but only one cpu can run gfar_poll()
> > and call gfar_clean_tx_ring() / gfar_clean_rx_ring()
> > 
> > If not, there would be more bugs than only rx_recycle thing
> 
> I didn't find what prevents running gfar_poll on many cpus and don't
> claim there is no more bugs around.

On the other hand, I don't see your point in the code below either.
These're only per gfargrp queues - not per device, aren't they?

Jarek P.

> 
> > 
> > vi +2822 drivers/net/gianfar.c
> > 
> >                 for_each_set_bit(i, &gfargrp->rx_bit_map, priv->num_rx_queues) {
> >                         if (test_bit(i, &serviced_queues))
> >                                 continue;
> >                         rx_queue = priv->rx_queue[i];
> >                         tx_queue = priv->tx_queue[rx_queue->qindex];
> > 
> >                         tx_cleaned += gfar_clean_tx_ring(tx_queue);
> >                         rx_cleaned_per_queue = gfar_clean_rx_ring(rx_queue,
> >                                                         budget_per_queue);
> >                         rx_cleaned += rx_cleaned_per_queue;
> >                         if(rx_cleaned_per_queue < budget_per_queue) {
> >                                 left_over_budget = left_over_budget +
> >                                         (budget_per_queue - rx_cleaned_per_queue);
> >                                 set_bit(i, &serviced_queues);
> >                                 num_queues--;
> >                         }
> >                 }
> > 
> > 
