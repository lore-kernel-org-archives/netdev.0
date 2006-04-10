From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Mon, 10 Apr 2006 15:28:49 -0700 (PDT)
Message-ID: <20060410.152849.25734948.davem@davemloft.net>
References: <200604100628.01483.mb@bu3sch.de>
	<20060410134625.GA25360@tuxdriver.com>
	<20060410221359.GC27596@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	linux-kernel@vger.kernel.org, benh@kernel.crashing.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932156AbWDJW3L@vger.kernel.org>
To: benoit.boissinot@ens-lyon.org
In-Reply-To: <20060410221359.GC27596@ens-lyon.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Date: Tue, 11 Apr 2006 00:13:59 +0200

> On Mon, Apr 10, 2006 at 09:46:30AM -0400, John W. Linville wrote:
> > On Mon, Apr 10, 2006 at 06:28:00AM +0200, Michael Buesch wrote:
> > 
> > > To summerize: I actually added these messages, because people were
> > > hitting "this does not work with >1G" issues and did not get an error message.
> > > So I decided to insert warnings until the issue is fixed inside the arch code.
> > > I will remove them once the issue is fixed.
> > 
> > This sounds like the same sort of problems w/ the b44 driver.
> > I surmise that both use the same (broken) DMA engine from Broadcom.
> > 
> > Unfortunately, I don't know of any good solution to this.  There are
> > a few hacks in b44 that deal with the issue.  I don't like them,
> > although I am the perpetrator of at least one of them.  It might be
> > worth looking at what was done there?
> 
> The hacks i see there is reallocating a buffer with GFP_DMA, so that
> means that if the ppc dma_alloc_coherent did the same thing as the i386
> counterpart (adding GFP_DMA if dma_mask is less than 32bits) it should
> work, no ?

PowerPC doesn't have a seperate GFP_DMA page pool, so this won't work.
