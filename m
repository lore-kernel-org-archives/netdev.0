From: James Bottomley <JBottomley@Novell.com>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Thu, 17 Jun 2010 08:12:16 -0500
Message-ID: <1276780336.2789.6.camel@mulgrave.site>
References: <C27F8246C663564A84BB7AB3439772421B79CBCA1F@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'FUJITA Tomonori' <fujita.tomonori@lab.ntt.co.jp>,
	"vapier@gentoo.org" <vapier@gentoo.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B79CBCA1F@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-06-17 at 05:54 -0700, Michael Chan wrote:
> FUJITA Tomonori wrote:
> 
> > From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> > Date: Thu, 17 Jun 2010 13:06:15 +0900
> > Subject: [PATCH] bnx2: fix dma_get_ops compilation breakage
> >
> > This removes dma_get_ops() prefetch optimization in bnx2.
> >
> > bnx2 uses dma_get_ops() to see if dma_sync_single_for_cpu() is
> > noop. bnx2 does prefetch if it's noop.
> >
> > But dma_get_ops() isn't available on all the architectures (only the
> > architectures that uses dma_map_ops struct have it). Using
> > dma_get_ops() in drivers leads to compilation breakage on many
> > archtectures.
> >
> > Currently, we don't have a way to see if dma_sync_single_for_cpu() is
> > noop. If it can improve the performance notably, we can add the new
> > DMA API for it.
> 
> This prefetch improves performance noticeably when the driver is
> handling incoming 64-byte packets at a sustained rate.

So why not do it unconditionally?  The worst that can happen is that you
pull in a stale cache line which will get cleaned in the dma_sync, thus
slightly degrading performance on incoherent architectures.

Alternatively, come up with a dma prefetch infrastructure ... all you're
really doing is hinting to the architecture that you'll sync this region
next.

James


