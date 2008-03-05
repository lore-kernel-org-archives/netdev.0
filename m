From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Wed, 5 Mar 2008 01:16:21 +0100
Message-ID: <20080305001621.GC1510@wotan.suse.de>
References: <20080303093449.GA15091@wotan.suse.de> <20080303093529.GB15091@wotan.suse.de> <Pine.LNX.4.64.0803031104570.6917@schroedinger.engr.sgi.com> <20080303200355.GB8974@wotan.suse.de> <Pine.LNX.4.64.0803031208400.16049@schroedinger.engr.sgi.com> <20080303201211.GE8974@wotan.suse.de> <Pine.LNX.4.64.0803031216430.3110@schroedinger.engr.sgi.com> <20080303202411.GH8974@wotan.suse.de> <Pine.LNX.4.64.0803031327330.4375@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:47586 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197AbYCEAQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 19:16:26 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803031327330.4375@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 01:31:14PM -0800, Christoph Lameter wrote:
> On Mon, 3 Mar 2008, Nick Piggin wrote:
> 
> > On Mon, Mar 03, 2008 at 12:17:20PM -0800, Christoph Lameter wrote:
> > > On Mon, 3 Mar 2008, Nick Piggin wrote:
> > > 
> > > > > You want two ways of specifying alignments?
> > > > 
> > > > I want a way to ask for SMP friendly allocation.
> > > 
> > > Then align the objects at cacheline boundaries by providing a value for 
> > > the align parameter to kmem_cache_create().
> > 
> > max(num_possible_cpus() > 1 ? cache_line_size() : 0, mandatory_alignment)?
> 
> The mandatory alignment is applied anyways. You do not need to max() on 
> that.

No that's the caller's required alignment.

 
> One could simply specify cache_line_size() with Pekka's patch. 
> cache_line_size() could default to 0 if !SMP.

That's totally wrong and stupid.

 
> > Then suppose we want a CONFIG_TINY option to eliminate it?
> 
> No slab allocator supports that right now.

That's way I said suppose we want it. Which is not unreasonable.


> However, SLOB in the past has 
> ignored the alignment in order to reduce memory use. So maybe Matt wants 
> to introduce this?
> 
> > And maybe the VSMP guys will want to blow this out to their internode
> > alignment?
> > 
> > max(!CONFIG_TINY && num_possible_cpus() > 1 ? (is_vsmp ? internode_alignemnt : cache_line_size()) : 0, mandatory_alignment)
> 
> No the slab allocators were optimized for VSMP so that the 
> internode_alignment is not necessary there. That was actually one of the 
> requirements that triggered the slab numa work.

What do you mean internode_alignment is not necessary there? This is
about memory returned by the allocator to the caller, and the caller
does not want any false sharing of the cacheline on SMP systems. How
can internode alignemnt be not necessary?

