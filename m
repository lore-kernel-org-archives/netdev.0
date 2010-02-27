From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [RFC PATCH] fix problems with NETIF_F_HIGHDMA in networking
	drivers
Date: Sun, 28 Feb 2010 03:38:19 +0900
Message-ID: <20100228033706G.fujita.tomonori@lab.ntt.co.jp>
References: <201002271259.31596.bzolnier@gmail.com>
	<20100227.040502.182574085.davem@davemloft.net>
	<51f3faa71002271015i7c9ec45j18381b1269bfd799@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bzolnier@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: hancockrwd@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51f3faa71002271015i7c9ec45j18381b1269bfd799@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 27 Feb 2010 12:15:19 -0600
Robert Hancock <hancockrwd@gmail.com> wrote:

> On Sat, Feb 27, 2010 at 6:05 AM, David Miller <davem@davemloft.net> wrote:
> > From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> > Date: Sat, 27 Feb 2010 12:59:31 +0100
> >
> >> Having IOMMU (even if it is only a software one, i.e. this would
> >> mean swiotlb for x86-32/highmem) always in place would simplify
> >> things greatly..
> >
> > I agree, things would be a lot simpler.
> 
> Yeah, the situation kind of sucks on the platforms that don't have any
> IOMMU support, since it means that the DMA API can't handle anything
> over 4GB properly and you need all these hacks in the block layer,
> networking layer, etc. It would be nice if some kind of IOMMU support
> could be relied upon always.

When I proposed such approach (always use swiotlb) before, IIRC,
the objections were:

- better to make allocation respect dma_mask. (I don't think that this
  approach is possible since we don't know which device handles data
  later when we allocate memory).

- swiotlb is not good for small systems since it allocates too much
  memory (we can fix this though).

There might be more.
