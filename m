From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 03/16] dma-debug: add hash functions for
	dma_debug_entries
Date: Wed, 14 Jan 2009 12:43:47 +0100
Message-ID: <20090114114347.GG8625@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-4-git-send-email-joerg.roedel@amd.com> <20090113005118.82f5037b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, linux-kernel@vger.kernel.org,
	mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:40305 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761799AbZANLon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 06:44:43 -0500
Content-Disposition: inline
In-Reply-To: <20090113005118.82f5037b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 9 Jan 2009 17:19:17 +0100 Joerg Roedel <joerg.roedel@amd.com> wrote:
> 
> > +struct hash_bucket {
> > +	struct list_head list;
> > +	spinlock_t lock;
> > +} ____cacheline_aligned;
> 
> __cacheline_aligned_in_smp.
> 
> This all looks like an exotically large amount of code for a debug 
> thingy?

this code checks the DMA usage of ~1 million lines of kernel code - all 
the DMA using drivers. I think Joerg's feature is hugely relevant as DMA 
scribbles are one of the hardest to debug kernel bugs: they can end up in 
permanent data corruption or other hard to find bugs. In fact i think his 
patchset is rather simple and even having 10 times as much debug code 
would pay for its existence in the long run.

	Ingo
