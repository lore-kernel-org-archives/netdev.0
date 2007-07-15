From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH try#2] Blackfin ethernet driver: on chip ethernet MAC controller driver
Date: Sun, 15 Jul 2007 11:53:58 +0100
Message-ID: <20070715105358.GA18177@infradead.org>
References: <1184491629.3140.59.camel@roc-laptop> <200707151236.51779.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bryan.wu@analog.com, Mike Frysinger <vapier.adi@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760130AbXGOKy3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200707151236.51779.mb@bu3sch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 15, 2007 at 12:36:51PM +0200, Michael Buesch wrote:
> On Sunday 15 July 2007 11:27:09 Bryan Wu wrote:
> > +#if defined(CONFIG_BFIN_MAC_USE_L1)
> > +# define bfin_mac_alloc(dma_handle, size)  l1_data_sram_zalloc(size)
> > +# define bfin_mac_free(dma_handle, ptr)    l1_data_sram_free(ptr)
> > +#else
> > +# define bfin_mac_alloc(dma_handle, size) \
> > +	 dma_alloc_coherent(NULL, size, dma_handle, GFP_NORMAL)
> 
> What is GFP_NORMAL? It's not defined in latest linus' tree.
> I think you should use GFP_KERNEL, if you can sleep, or GFP_ATOMIC,
> if you can't.

Actually this whole thing looks fishy.  There should be a struct device
for the dma allocation, through a platform_device.  And the
CONFIG_BFIN_MAC_USE_L1 should go away, the l1 sram should have a dma
provider so this can be handled through the dma api.
