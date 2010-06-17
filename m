From: James Bottomley <JBottomley@Novell.com>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Thu, 17 Jun 2010 08:36:51 -0500
Message-ID: <1276781811.7285.4.camel@mulgrave.site>
References: <C27F8246C663564A84BB7AB3439772421B79CBCA21@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'FUJITA Tomonori' <fujita.tomonori@lab.ntt.co.jp>,
	"vapier@gentoo.org" <vapier@gentoo.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B79CBCA21@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-06-17 at 06:30 -0700, Michael Chan wrote: 
> James Bottomley wrote:
> 
> > On Thu, 2010-06-17 at 05:54 -0700, Michael Chan wrote:
> > > This prefetch improves performance noticeably when the driver is
> > > handling incoming 64-byte packets at a sustained rate.
> >
> > So why not do it unconditionally?  The worst that can happen
> > is that you
> > pull in a stale cache line which will get cleaned in the
> > dma_sync, thus
> > slightly degrading performance on incoherent architectures.
> 
> The original patch was an unconditional prefetch.  There was
> some discussion that it might not be correct if the DMA wasn't
> sync'ed yet on some archs.  If the concensus is that it is ok to
> do so, that would be the simplest solution.

It's definitely not "correct" in that it may pull in stale data.  But it
should be harmless in that if it does, the subsequent sync will destroy
the cache line (even if it actually pulled in correct data) and prevent
the actual use of the prefetched data being wrong (or indeed being
prefetched at all).

James
