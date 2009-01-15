From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH 03/16] dma-debug: add hash functions for
	dma_debug_entries
Date: Thu, 15 Jan 2009 12:44:35 +0900
Message-ID: <20090115124441V.fujita.tomonori@lab.ntt.co.jp>
References: <20090114114347.GG8625@elte.hu>
	<20090114093918.e7b0ae46.akpm@linux-foundation.org>
	<20090114174804.GB31983@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, joerg.roedel@amd.com,
	linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:55758 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915AbZAODpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 22:45:30 -0500
In-Reply-To: <20090114174804.GB31983@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jan 2009 18:48:04 +0100
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Wed, 14 Jan 2009 12:43:47 +0100 Ingo Molnar <mingo@elte.hu> wrote:
> > 
> > > 
> > > * Andrew Morton <akpm@linux-foundation.org> wrote:
> > > 
> > > > On Fri, 9 Jan 2009 17:19:17 +0100 Joerg Roedel <joerg.roedel@amd.com> wrote:
> > > > 
> > > > > +struct hash_bucket {
> > > > > +	struct list_head list;
> > > > > +	spinlock_t lock;
> > > > > +} ____cacheline_aligned;
> > > > 
> > > > __cacheline_aligned_in_smp.
> > > > 
> > > > This all looks like an exotically large amount of code for a debug 
> > > > thingy?
> > > 
> > > this code checks the DMA usage of ~1 million lines of kernel code - all 
> > > the DMA using drivers. I think Joerg's feature is hugely relevant as DMA 
> > > scribbles are one of the hardest to debug kernel bugs: they can end up in 
> > > permanent data corruption or other hard to find bugs. In fact i think his 
> > > patchset is rather simple and even having 10 times as much debug code 
> > > would pay for its existence in the long run.
> > > 
> > 
> > Have we previously found bugs by other means which this facility would 
> > have detected?  I don't recall any...
> 
> btw., during the past decade we have had countless very ugly driver DMA 
> bugs in the past that took vendors months and specialized equipment to 
> track down.
> 
> I cannot give you a number breakdown, only an impression: storage drivers 
> tended to be the hardest hit (due to the severity of the bugs and due to 
> their inherent complexity) - but DMA bugs in networking drivers can be 
> hard to track down too.

We have had ugly DMA bugs in scsi drivers but I think that this new
feature can find very few of them. I can't think of any SCSI driver
bugs that this could find. This feature can't find any popular DMA
bugs in scsi drivers, such as messing up driver's dma descriptor from
a scatter gather list.

But this can find some kinds of DMA bugs and it's is just about 1,000
lines. I don't see any problem about merging this. 1,000 lines it too
large? Maybe cutting just 1,000 lines up into too many pieces is
deceptive.
