From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 03/10] x86: add initialization code for DMA-API
	debugging
Date: Fri, 21 Nov 2008 18:27:07 +0100
Message-ID: <20081121172707.GA4336@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-4-git-send-email-joerg.roedel@amd.com> <20081121165628.GD733@elte.hu> <20081121171004.GE1386@amd.com> <20081121171952.GL733@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:38877 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750794AbYKUR1k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 12:27:40 -0500
Content-Disposition: inline
In-Reply-To: <20081121171952.GL733@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> > > We dont have a gfp flag passed in as all the DMA mapping APIs 
> > > really expect all allocations having been done in advance 
> > > already.
> > 
> > Hmm, I can change the code to pre-allocate a certain 
> > (configurable?) number of these entries and disble the checking if 
> > we run out of it.
> 
> yeah, that's a good approach too - that's what lockdep does. Perhaps 
> make the max entries nr a Kconfig entity - so it can be tuned 
> up/down depending on what type of iommu scheme is enabled.

there's another reason why we want to do that: this scheme covers all 
of DMA - not just the ones which need to go via an iommu and for which 
there's an IOTLB entry present. So the pool should probably be sized 
after RAM size, to be on the safe side.

	Ingo
