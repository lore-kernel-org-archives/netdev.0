From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: atl1 64-bit => 32-bit DMA borkage (reproducible, bisected)
Date: Mon, 28 Apr 2008 10:42:38 +0400
Message-ID: <20080428064238.GA4768@martell.zuzino.mipt.ru>
References: <20080419111719.GA6724@martell.zuzino.mipt.ru> <20080419144535.GA4814@martell.zuzino.mipt.ru> <20080419215444.2d4623f5@osprey.hogchain.net> <20080420111453.GA4902@martell.zuzino.mipt.ru> <20080420060607.2b1be48b@osprey.hogchain.net> <20080420122631.GA4761@martell.zuzino.mipt.ru> <20080420133704.63f5cc10@osprey.hogchain.net> <20080420205500.GA4762@martell.zuzino.mipt.ru> <20080421210821.28053a92@osprey.hogchain.net> <20080425195743.2bfe66ee@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Chris Snook <csnook@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:12650 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbYD1FrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 01:47:16 -0400
Received: by ug-out-1314.google.com with SMTP id z38so713238ugc.16
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2008 22:47:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080425195743.2bfe66ee@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2008 at 07:57:43PM -0500, Jay Cliburn wrote:
> On Mon, 21 Apr 2008 21:08:21 -0500
> Jay Cliburn <jacliburn@bellsouth.net> wrote:
> 
> > 
> > Alexey, can you please try this (very minimally tested) patch?
> 
> Alexey, have you found time to try this patch yet?

I've tried it and it doesn't help.
http://marc.info/?l=linux-netdev&m=120888791230434&w=2

> > --- a/drivers/net/atlx/atl1.c
> > +++ b/drivers/net/atlx/atl1.c
> > @@ -1115,9 +1115,6 @@ static void atl1_free_ring_resources(struct
> > atl1_adapter *adapter) struct atl1_rrd_ring *rrd_ring =
> > &adapter->rrd_ring; struct atl1_ring_header *ring_header =
> > &adapter->ring_header; 
> > -	atl1_clean_tx_ring(adapter);
> > -	atl1_clean_rx_ring(adapter);
> > -
> >  	kfree(tpd_ring->buffer_info);
> >  	pci_free_consistent(pdev, ring_header->size,
> > ring_header->desc, ring_header->dma);
> > @@ -3423,6 +3420,8 @@ static int atl1_set_ringparam(struct net_device
> > *netdev, adapter->rrd_ring = rrd_old;
> >  		adapter->tpd_ring = tpd_old;
> >  		adapter->ring_header = rhdr_old;
> > +		atl1_clean_tx_ring(adapter);
> > +		atl1_clean_rx_ring(adapter);
> >  		atl1_free_ring_resources(adapter);
> >  		adapter->rfd_ring = rfd_new;
> >  		adapter->rrd_ring = rrd_new;

