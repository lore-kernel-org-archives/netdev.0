From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: bnx2 fails to compile on parisc because of missing get_dma_ops()
Date: Thu, 17 Jun 2010 13:03:57 +0900
Message-ID: <20100617040356.GA8105@linux-sh.org>
References: <AANLkTilSfOwwT87mgDcWBogL4gPnM7VBTOALKpZv_upN@mail.gmail.com> <C27F8246C663564A84BB7AB3439772421B79CBCA1C@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Mike Frysinger' <vapier@gentoo.org>,
	James Bottomley <JBottomley@novell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B79CBCA1C@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2010 at 08:53:57PM -0700, Michael Chan wrote:
> Mike Frysinger wrote:
> 
> > On Wed, Jun 16, 2010 at 9:13 PM, James Bottomley wrote:
> > > I'm not quite sure whose fault this one is.
> > >
> > > However, this code in bnx2.c:
> > >
> > >                if (!get_dma_ops(&pdev->dev)->sync_single_for_cpu) {
> > >                        next_rx_buf =
> > >                                &rxr->rx_buf_ring[
> > >                                        RX_RING_IDX(NEXT_RX_BD(sw_cons))];
> > >                        prefetch(next_rx_buf->desc);
> > >                }
> > >
> > > Looks remarkably fragile: what exactly is it trying to do?
> 
> If sync_single is not defined, that means the CPU has a consistent
> view of next_rx_buf and so it makes sense to prefetch it.
> 
Except that's not a valid assertion, there are platforms that implement
it for sanity checks yet still have consistent DMA. You are making
inherently non-portable assumptions for a PCI driver, which is a good
example of why drivers should never be side-stepping the API in the first
place. If you want to have a micro-optimization for the consistent DMA
case, you can check dma_is_consistent(), which is part of the API and
will be variable on certain platform configurations (ie, some may be
consistent with PCI but not on other busses, etc.) 
