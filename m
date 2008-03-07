From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Fri, 7 Mar 2008 03:25:37 +0100
Message-ID: <20080307022537.GC21185@wotan.suse.de>
References: <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com> <84144f020803031330i2c0ea1f6kc5b02c8b26145797@mail.gmail.com> <Pine.LNX.4.64.0803031331340.4375@schroedinger.engr.sgi.com> <47CC6F30.50802@cs.helsinki.fi> <20080305002821.GD1510@wotan.suse.de> <Pine.LNX.4.64.0803051254570.30742@schroedinger.engr.sgi.com> <20080306024904.GA27150@wotan.suse.de> <Pine.LNX.4.64.0803061451230.16212@schroedinger.engr.sgi.com> <20080307020443.GA21185@wotan.suse.de> <Pine.LNX.4.64.0803061816430.28976@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:42865 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757253AbYCGCZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 21:25:39 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803061816430.28976@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 06:20:40PM -0800, Christoph Lameter wrote:
> On Fri, 7 Mar 2008, Nick Piggin wrote:
> 
> > > Do you have a case in mind where that would be useful? We had a 
> > 
> > Patch 3/3
> 
> Those already have SLAB_HWCACHE_ALIGN.
> 
> The point is to switch off alignment for UP? Cant we do that with 
> SLAB_HWCACHE_ALIGN too since SLOB seemed to work successfully without it 
> in the past?

See my next post to correct your understanding of HWCACHE_ALIGN.

 
> > > Note that there is also KMEM_CACHE which picks up the alignment from 
> > > the compiler.
> > 
> > Yeah, that's not quite as good either. My allocation flag is dynamic, so
> > it will not bloat things for no reason on UP machines and SMP kernels. 
> > It also aligns to the detected machine cacheline size rather than a
> > compile time constant.
> 
> Is that really a noteworthy effect?

Yes.

