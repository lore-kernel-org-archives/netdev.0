From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: bnx2 fails to compile on parisc because of missing get_dma_ops()
Date: Fri, 18 Jun 2010 00:30:51 +0900
Message-ID: <20100617153051.GB8964@linux-sh.org>
References: <C27F8246C663564A84BB7AB3439772421B79CBCA1E@IRVEXCHCCR01.corp.ad.broadcom.com> <20100617211946A.fujita.tomonori@lab.ntt.co.jp> <20100617.073653.193708702.davem@davemloft.net> <20100617234520S.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mchan@broadcom.com, vapier@gentoo.org,
	JBottomley@novell.com, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100617234520S.fujita.tomonori@lab.ntt.co.jp>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2010 at 11:50:35PM +0900, FUJITA Tomonori wrote:
> On Thu, 17 Jun 2010 07:36:53 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> > Date: Thu, 17 Jun 2010 21:21:13 +0900
> > 
> > > On Wed, 16 Jun 2010 23:24:44 -0700
> > > "Michael Chan" <mchan@broadcom.com> wrote:
> > > 
> > >> David, why is dma_is_consistent() always returning 1 on sparc?  The
> > >> streaming DMA is not consistent.
> > > 
> > > I think that there are some confusion about dma_is_consistent(). Some
> > > architectures think that dma_is_consistent() is supposed to return 1
> > > if they can allocate coherent memory (note that some architectures
> > > can't allocate coherent memory).
> > 
> > Right, and that's why it's defined this way.
> > 
> > If the desired meaning is different, just me know and I'll fix the
> > sparc definition.
> 
> I think that there are some other architectures do the same. We need
> to make sure that all the architectures define dma_is_consistent() in
> the same meaning if drivers need it. However, I'm not sure we really
> need dma_is_consistent(). There is only one user of it (and I think we
> could remove it).
> 
> In the bnx2 case, we can simply prefetch on all the archs (or just
> remove the optimization).

I think its worthwhile keeping, especially since the consistency can vary
on a per struct device level. If there's a benefit with these sorts of
prefetch micro-optimizations in drivers when it doesn't cost us that much
to provide the hint, I don't really see the harm. If dma_is_consistent()
is suddenly supposed to take on other meanings, or it's supposed to mean
something entirely different, then this is something we should deal with
separately.

I don't see any harm in letting drivers know whether we can support
consistent DMA allocs for a given struct device or not though, even if
the micro-optimization is marginal at best.

At least I've conditionalized the definition on SH, and it seems other
archictures have done so too. It's not clear what we'd gain from throwing
that away as long as they're generally in agreement on what it means.
