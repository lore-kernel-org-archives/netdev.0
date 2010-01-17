From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Sun, 17 Jan 2010 23:57:03 +0100
Message-ID: <20100117225703.GB3161@del.dom.local>
References: <20100117003653.GA3073@del.dom.local>
 <C27F8246C663564A84BB7AB34397724218281B8382@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:40448 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139Ab0AQW5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 17:57:09 -0500
Received: by fxm25 with SMTP id 25so617534fxm.21
        for <netdev@vger.kernel.org>; Sun, 17 Jan 2010 14:57:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <C27F8246C663564A84BB7AB34397724218281B8382@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 17, 2010 at 08:56:28AM -0800, Michael Chan wrote:
> Jarek Poplawski wrote
> > On Sat, Jan 16, 2010 at 02:50:48PM -0800, Michael Chan wrote:
> > > The problem with the patch below is that
> > > dev->real_num_tx_queues can still be reduced during bnx2_open().
> > >
> >
> > I'm not sure I get your point, but there should be no problem with
> > changing dev->real_num_tx_queues during ->open(). The main intention
> > of realloc_netdev_mq() is to give drivers some official way to change
> > dev->num_tx_queues until register_netdev() with the main aim: not to
> > treat obviously non-mq chips as mq according to netif_is_multiqueue().
> > Additional gain is memory saved in the case fixed by the patch below
> > (which btw. waits for some refinement/verification).
> 
> Yes, the patch achieves what you describe.  dev->num_tx_queues will
> be set more accurately during ->probe based on chip type.  In ->open(),
> the dev->real_num_tx_queues will still be possibly reduced depending
> on the number of CPU cores and whether we can enable and allocate the
> MSI-X vectors.

I wondered, and Peter seemed to confirm, some check whether we can use
MSI-X could be done during ->probe as well?

...
> > > > + if (!((bp->flags & BNX2_FLAG_MSIX_CAP) ||
> > > > +      (bp->flags & BNX2_FLAG_MSI_CAP)) || disable_msi)
> > > > +         realloc_netdev_mq(dev, 1);
> > > > +
> 
> I think we can refine this a little:
> 
>         if (!(bp->flags & BNX2_FLAG_MSIX_CAP) || disable_msi)
>                 realloc_netdev_mq(dev, 1);
> 

Hmm... Probably I should use different words. I mentioned above the
main intention of realloc_netdev_mq() was to fix mq-ness for non-mq
chips, and this patch demonstrates this. But, there is no reason not
to fix/optimize more btw. So, I hoped the refinement could also
include some preliminary MSI-X test etc. Anyway, since I can't even
test it, I would be glad if you could author something based on this
stub (unless you think it's enough for now - then I'll send it as is,
no problem).

Thanks,
Jarek P.
