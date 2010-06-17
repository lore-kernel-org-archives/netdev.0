From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Thu, 17 Jun 2010 23:50:36 +0900
Message-ID: <20100617234855R.fujita.tomonori@lab.ntt.co.jp>
References: <1276780336.2789.6.camel@mulgrave.site>
	<C27F8246C663564A84BB7AB3439772421B79CBCA21@IRVEXCHCCR01.corp.ad.broadcom.com>
	<20100617230435J.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: JBottomley@novell.com, vapier@gentoo.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org
To: mchan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100617230435J.fujita.tomonori@lab.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oops, some typos.

On Thu, 17 Jun 2010 23:05:59 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> On Thu, 17 Jun 2010 06:30:39 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
> 
> > James Bottomley wrote:
> > 
> > > On Thu, 2010-06-17 at 05:54 -0700, Michael Chan wrote:
> > > > This prefetch improves performance noticeably when the driver is
> > > > handling incoming 64-byte packets at a sustained rate.
> > >
> > > So why not do it unconditionally?  The worst that can happen
> > > is that you
> > > pull in a stale cache line which will get cleaned in the
> > > dma_sync, thus
> > > slightly degrading performance on incoherent architectures.
> > 
> > The original patch was an unconditional prefetch.  There was
> > some discussion that it might not be correct if the DMA wasn't
> > sync'ed yet on some archs.  If the concensus is that it is ok to
> > do so, that would be the simplest solution.
> 
> As James said, it just adds useless prefetch on incoherent
> architectures. sync_single_for_cpu is called later so we can see the
> correct data. One useless prefetch is unlikely to lead performance
> drop.
> 
> You might prefer this v2.
> 
> =
> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Subject: [PATCH v2] bnx2: fix dma_get_ops compilation breakage
> 
> This removes dma_get_ops() prefetch optimization in bnx2.
> 
> bnx2 uses dma_get_ops() to see if dma_sync_single_for_cpu() is
> noop. bnx2 does prefetch if it's noop.
> 
> But dma_get_ops() isn't available on all the architectures (only the
> architectures that uses dma_map_ops struct have it). Using
> dma_get_ops() in drivers leads to compilation breakage on many
> archtectures.

s/archtectures/architectures/

> This patch removes dma_get_ops() and changes bnx2 to do prefetch on
> all the architectures. This adds useless prefetch on incoherent
                                                       ~~~~~~~~~~
                                             s/incoherent/non-coherent/
(thanks to Alan)

> architectures but this is harmless. It is also unlikely to cause the
> performance drop.
