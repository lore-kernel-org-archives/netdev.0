From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: Was:  Re: [RFC PATCH] fix problems with NETIF_F_HIGHDMA in
	networking, Now: SWIOTLB dynamic allocation
Date: Tue, 2 Mar 2010 13:40:56 +0900
Message-ID: <20100302133736C.fujita.tomonori@lab.ntt.co.jp>
References: <20100228033706G.fujita.tomonori@lab.ntt.co.jp>
	<20100228.001628.48507956.davem@davemloft.net>
	<20100301163437.GE7881@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, fujita.tomonori@lab.ntt.co.jp,
	hancockrwd@gmail.com, bzolnier@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: konrad.wilk@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100301163437.GE7881@phenom.dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 1 Mar 2010 11:34:37 -0500
Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:

> On Sun, Feb 28, 2010 at 12:16:28AM -0800, David Miller wrote:
> > From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> > Date: Sun, 28 Feb 2010 03:38:19 +0900
> > 
> > > When I proposed such approach (always use swiotlb) before, IIRC,
> > > the objections were:
> > > 
> > > - better to make allocation respect dma_mask. (I don't think that this
> > >   approach is possible since we don't know which device handles data
> > >   later when we allocate memory).
> > 
> > And such objects might end up being processed by multiple devices with
> > different DMA restrictions.
> > 
> > > - swiotlb is not good for small systems since it allocates too much
> > >   memory (we can fix this though).
> > 
> > Indeed.
> 
> What would be a good mechanism for this? Enumerating all of the PCI
> devices to find out which ones are 32-bit and then allocate some chunk
> of memory based on the amount of them? say, 1MB per card?
> 
> Or maybe a simpler one - figure out how many pages we have an allocate
> based on some sliding rule (say, 8MB for under 512MB, 16MB between 512MB
> and 2GB, and 32MB for 2GB to 4GB, and after that the full 64MB?)

Hmm, have you read the above objection from embedded system people ? :)

We can't pre-allocate such lots of memory (several MB). And we don't
need to.

We have to pre-allocate some for the block layer (we have to guarantee
that we can handle one request at least), however we don't need to
pre-allocate for the rest (including the network stack).

This guarantee is a bit difficult since the dma_map_* doesn't know who
is at the upper layer; the dma_map_* cannot know if it needs to
allocate from the pre-allocated pool or not. I thought about adding
'dma attribute flag' to struct device (to be exact, struct
device_dma_parameters).
