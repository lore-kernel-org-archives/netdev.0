From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Thu, 17 Jun 2010 06:30:39 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B79CBCA21@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1276780336.2789.6.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'FUJITA Tomonori'" <fujita.tomonori@lab.ntt.co.jp>,
	"vapier@gentoo.org" <vapier@gentoo.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "'James Bottomley'" <JBottomley@Novell.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <1276780336.2789.6.camel@mulgrave.site>
Content-Language: en-US
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Bottomley wrote:

> On Thu, 2010-06-17 at 05:54 -0700, Michael Chan wrote:
> > This prefetch improves performance noticeably when the driver is
> > handling incoming 64-byte packets at a sustained rate.
>
> So why not do it unconditionally?  The worst that can happen
> is that you
> pull in a stale cache line which will get cleaned in the
> dma_sync, thus
> slightly degrading performance on incoherent architectures.

The original patch was an unconditional prefetch.  There was
some discussion that it might not be correct if the DMA wasn't
sync'ed yet on some archs.  If the concensus is that it is ok to
do so, that would be the simplest solution.

>
> Alternatively, come up with a dma prefetch infrastructure ...
> all you're
> really doing is hinting to the architecture that you'll sync
> this region
> next.
>
> James
>
>
>
>

