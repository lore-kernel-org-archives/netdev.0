From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Wed, 5 Mar 2008 01:08:20 +0100
Message-ID: <20080305000820.GB1510@wotan.suse.de>
References: <20080303093449.GA15091@wotan.suse.de> <Pine.LNX.4.64.0803031107130.6917@schroedinger.engr.sgi.com> <20080303200613.GC8974@wotan.suse.de> <Pine.LNX.4.64.0803031209570.16049@schroedinger.engr.sgi.com> <20080303201701.GF8974@wotan.suse.de> <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com> <84144f020803031330i2c0ea1f6kc5b02c8b26145797@mail.gmail.com> <Pine.LNX.4.64.0803031331340.4375@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:53993 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765531AbYCEAIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 19:08:21 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803031331340.4375@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 01:32:54PM -0800, Christoph Lameter wrote:
> On Mon, 3 Mar 2008, Pekka Enberg wrote:
> 
> > Well, not my definition either but SLAB has guaranteed that for small
> > objects in the past, so I think Nick has a point here. However, with
> > all this back and forth, I've lost track why this matters. I suppose
> > it causes regression on some workload?
> 
> Well the guarantee can only be exploited if you would check the cacheline 
> sizes and the object size from the code that creates the slab cache. 
> Basically you would have to guestimate what the slab allocator is doing.
> 
> So the guarantee is basically meaningless. If the object is larger than a 
> cacheline then this will never work.

Of course it works. It fits the object into the fewest number of cachelines
possible. If you need to be accessing such objects in a random manner, then
for highest performance you want to touch as few cachelines as possible.

