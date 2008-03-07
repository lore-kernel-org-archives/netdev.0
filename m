From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Fri, 7 Mar 2008 03:04:43 +0100
Message-ID: <20080307020443.GA21185@wotan.suse.de>
References: <Pine.LNX.4.64.0803031209570.16049@schroedinger.engr.sgi.com> <20080303201701.GF8974@wotan.suse.de> <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com> <84144f020803031330i2c0ea1f6kc5b02c8b26145797@mail.gmail.com> <Pine.LNX.4.64.0803031331340.4375@schroedinger.engr.sgi.com> <47CC6F30.50802@cs.helsinki.fi> <20080305002821.GD1510@wotan.suse.de> <Pine.LNX.4.64.0803051254570.30742@schroedinger.engr.sgi.com> <20080306024904.GA27150@wotan.suse.de> <Pine.LNX.4.64.0803061451230.16212@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:49327 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754233AbYCGCEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 21:04:46 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803061451230.16212@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 02:53:11PM -0800, Christoph Lameter wrote:
> On Thu, 6 Mar 2008, Nick Piggin wrote:
> 
> > > That was due to SLUB's support for smaller allocation sizes. AFAICT has 
> > > nothing to do with alignment.
> > 
> > The smaller sizes meant objects were less often aligned on cacheline
> > boundaries.
> 
> Right since SLAB_HWCACHE_ALIGN does not align for very small objects.

It doesn't align small objects to cacheline boundaries in either allocator.
The regression is just because slub can support smaller sizes of objects
AFAIKS.

 
> > We could, but I'd rather just use the flag.
> 
> Do you have a case in mind where that would be useful? We had a 

Patch 3/3


> SLAB_HWCACHE_MUST_ALIGN or so at some point but it was rarely to never 
> used.

OK, but that's not the same thing.


> Note that there is also KMEM_CACHE which picks up the alignment from 
> the compiler.

Yeah, that's not quite as good either. My allocation flag is dynamic, so
it will not bloat things for no reason on UP machines and SMP kernels. 
It also aligns to the detected machine cacheline size rather than a
compile time constant.

