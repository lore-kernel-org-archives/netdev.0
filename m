From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 03/16] dma-debug: add hash functions for
 dma_debug_entries
Date: Wed, 14 Jan 2009 17:48:15 +0000
Message-ID: <1231955295.25018.5631.camel@macbook.infradead.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
	 <1231517970-20288-4-git-send-email-joerg.roedel@amd.com>
	 <20090113005118.82f5037b.akpm@linux-foundation.org>
	 <20090114114347.GG8625@elte.hu>
	 <20090114093918.e7b0ae46.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Joerg Roedel <joerg.roedel@amd.com>,
	linux-kernel@vger.kernel.org, mingo@redhat.com,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40298 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921AbZANRs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 12:48:29 -0500
In-Reply-To: <20090114093918.e7b0ae46.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 09:39 -0800, Andrew Morton wrote:
> > this code checks the DMA usage of ~1 million lines of kernel code - all 
> > the DMA using drivers. I think Joerg's feature is hugely relevant as DMA 
> > scribbles are one of the hardest to debug kernel bugs: they can end up in 
> > permanent data corruption or other hard to find bugs. In fact i think his 
> > patchset is rather simple and even having 10 times as much debug code 
> > would pay for its existence in the long run.
> > 
> 
> Have we previously found bugs by other means which this facility would
> have detected?  I don't recall any...

Yes. We've found network driver bugs which only showed up when an IOMMU
has been active -- and were painful to diagnose because they involved
DMA going wrong. It happens when drivers make mistakes with the DMA
mapping APIs.

With this debug facility, we can find such problems on _any_ hardware,
and get a sane report about what's wrong.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

