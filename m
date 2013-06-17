From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 0/7] Fixing dma mask setting in various network drivers
Date: Mon, 17 Jun 2013 21:45:05 +0100
Message-ID: <20130617204505.GT2718@n2100.arm.linux.org.uk>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk> <20130611111230.000062d2@unknown> <20130617140145.GH2718@n2100.arm.linux.org.uk> <1371501341.2133.130.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Rasesh Mody <rmody@brocade.com>,
	Tushar Dave <tushar.n.dave@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:43264 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244Ab3FQUpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 16:45:50 -0400
Content-Disposition: inline
In-Reply-To: <1371501341.2133.130.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 17, 2013 at 01:35:41PM -0700, Jeff Kirsher wrote:
> On Mon, 2013-06-17 at 15:01 +0100, Russell King - ARM Linux wrote:
> > On Tue, Jun 11, 2013 at 11:12:30AM -0700, Jesse Brandeburg wrote:
> > > This is my proposed change to the intel drivers.  Comments?
> > > 
> > > +	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
> > > +		pci_using_dac = true;
> > > +		/* coherent mask for the same size will always succeed if
> > > +		 * dma_set_mask does
> > > +		 */
> > > +		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
> > > +	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
> > > +		pci_using_dac = false;
> > > +		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
> > > +	} else {
> > > +		dev_err(&pdev->dev, "%s: DMA configuration failed: %d\n",
> > > +			 __func__, err);
> > > +		err = -EIO;
> > > +		goto err_dma;
> > >  	}
> > > 
> > 
> > So, will you be going with this change rather than mine, which apparantly
> > Jeff queued?  Please let me know what you decide so I can keep my private
> > git tree in sync with what you've decided to avoid conflicting with
> > further dma-mask changes which I'm working on.
> > 
> > Thanks.
> 
> I thought the kernel helper function dma_set_mask_and_coherent(...) was
> the best solution.
> 
> I dropped your original series of patches from my queue since it
> appeared that there was a better alternative to this solution.

Such a helper doesn't exist yet, and I'm not sure these changes should
wait for that.  Hmm, okay, it's probably too late in the -rc cycle
anyway for these changes now.

I'll respin them according to Jesse's patch above, but as I have already
mentioned, this will be part of a much larger series, and I was hoping
to get those trivial fixes in for 3.10 to avoid that kind of dependency.
Instead, they'll be stuck at the bottom of a much larger series, which
will depend on these changes.  Bah.
