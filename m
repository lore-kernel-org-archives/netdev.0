From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Wed, 16 Jun 2010 21:10:57 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B79CBCA1D@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20100617040356.GA8105@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'Mike Frysinger'" <vapier@gentoo.org>,
	"James Bottomley" <JBottomley@novell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"FUJITA Tomonori" <fujita.tomonori@lab.ntt.co.jp>
To: "'Paul Mundt'" <lethal@linux-sh.org>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20100617040356.GA8105@linux-sh.org>
Content-Language: en-US
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Mundt wrote:

> On Wed, Jun 16, 2010 at 08:53:57PM -0700, Michael Chan wrote:
> > If sync_single is not defined, that means the CPU has a consistent
> > view of next_rx_buf and so it makes sense to prefetch it.
> >
> Except that's not a valid assertion, there are platforms that
> implement
> it for sanity checks yet still have consistent DMA. You are making
> inherently non-portable assumptions for a PCI driver, which is a good
> example of why drivers should never be side-stepping the API
> in the first
> place. If you want to have a micro-optimization for the consistent DMA
> case, you can check dma_is_consistent(), which is part of the API and
> will be variable on certain platform configurations (ie, some may be
> consistent with PCI but not on other busses, etc.)
>
>

Thanks for the tip.  I didn't know about the dma_is_consistent() API.
I'll use this to fix it then.

