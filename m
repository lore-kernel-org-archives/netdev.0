From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Thu, 17 Jun 2010 21:21:13 +0900
Message-ID: <20100617211946A.fujita.tomonori@lab.ntt.co.jp>
References: <C27F8246C663564A84BB7AB3439772421B79CBCA1D@IRVEXCHCCR01.corp.ad.broadcom.com>
	<C27F8246C663564A84BB7AB3439772421B79CBCA1E@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, lethal@linux-sh.org, vapier@gentoo.org,
	JBottomley@novell.com, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org,
	fujita.tomonori@lab.ntt.co.jp
To: mchan@broadcom.com
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B79CBCA1E@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Jun 2010 23:24:44 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> Michael Chan wrote:
> >
> > Paul Mundt wrote:
> >
> > > If you want to have a micro-optimization for the consistent DMA
> > > case, you can check dma_is_consistent(), which is part of the API and
> > > will be variable on certain platform configurations (ie, some may be
> > > consistent with PCI but not on other busses, etc.)
> > >
> > >
> >
> > Thanks for the tip.  I didn't know about the dma_is_consistent() API.
> > I'll use this to fix it then.
> >
> 
> David, why is dma_is_consistent() always returning 1 on sparc?  The
> streaming DMA is not consistent.

I think that there are some confusion about dma_is_consistent(). Some
architectures think that dma_is_consistent() is supposed to return 1
if they can allocate coherent memory (note that some architectures
can't allocate coherent memory).
