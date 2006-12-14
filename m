From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 1/14] Spidernet DMA coalescing
Date: Thu, 14 Dec 2006 11:07:37 -0600
Message-ID: <20061214170737.GS4329@austin.ibm.com>
References: <20061213210010.GR4329@austin.ibm.com> <20061213210659.GA1915@austin.ibm.com> <20061214110517.GA13377@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	James K Lewis <jim@jklewis.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:39245 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956AbWLNRHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 12:07:49 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBEH8DGL017827
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 12:08:13 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBEH7jni296110
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 12:07:45 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBEH7iYe025784
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 12:07:45 -0500
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20061214110517.GA13377@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 14, 2006 at 11:05:17AM +0000, Christoph Hellwig wrote:
> On Wed, Dec 13, 2006 at 03:06:59PM -0600, Linas Vepstas wrote:
> > 
> > The current driver code performs 512 DMA mappings of a bunch of 
> > 32-byte ring descriptor structures. This is silly, as they are 
> > all in contiguous memory. This patch changes the code to 
> > dma_map_coherent() each rx/tx ring as a whole.
> 
> It's acutally dma_alloc_coherent now that you updated the patch :)
> 
> > +	chain->ring = dma_alloc_coherent(&card->pdev->dev, alloc_size,
> > +		&chain->dma_addr, GFP_KERNEL);
> >  
> > +	if (!chain->ring)
> > +		return -ENOMEM;
> >  
> > +	descr = chain->ring;
> > +	memset(descr, 0, alloc_size);
> 
> dma_alloc_coherent is defined to zero the allocated memory, so you
> won't need this memset.

Being unclear on the concept, should a send a new version of this patch,
or should I send a new patch that removes this?

--linas
