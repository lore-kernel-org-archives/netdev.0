From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Mon, 3 Mar 2008 13:31:14 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803031327330.4375@schroedinger.engr.sgi.com>
References: <20080303093449.GA15091@wotan.suse.de> <20080303093529.GB15091@wotan.suse.de>
 <Pine.LNX.4.64.0803031104570.6917@schroedinger.engr.sgi.com>
 <20080303200355.GB8974@wotan.suse.de> <Pine.LNX.4.64.0803031208400.16049@schroedinger.engr.sgi.com>
 <20080303201211.GE8974@wotan.suse.de> <Pine.LNX.4.64.0803031216430.3110@schroedinger.engr.sgi.com>
 <20080303202411.GH8974@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:47609 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762353AbYCCVbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 16:31:15 -0500
In-Reply-To: <20080303202411.GH8974@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Mar 2008, Nick Piggin wrote:

> On Mon, Mar 03, 2008 at 12:17:20PM -0800, Christoph Lameter wrote:
> > On Mon, 3 Mar 2008, Nick Piggin wrote:
> > 
> > > > You want two ways of specifying alignments?
> > > 
> > > I want a way to ask for SMP friendly allocation.
> > 
> > Then align the objects at cacheline boundaries by providing a value for 
> > the align parameter to kmem_cache_create().
> 
> max(num_possible_cpus() > 1 ? cache_line_size() : 0, mandatory_alignment)?

The mandatory alignment is applied anyways. You do not need to max() on 
that.

One could simply specify cache_line_size() with Pekka's patch. 
cache_line_size() could default to 0 if !SMP.

> Then suppose we want a CONFIG_TINY option to eliminate it?

No slab allocator supports that right now. However, SLOB in the past has 
ignored the alignment in order to reduce memory use. So maybe Matt wants 
to introduce this?

> And maybe the VSMP guys will want to blow this out to their internode
> alignment?
> 
> max(!CONFIG_TINY && num_possible_cpus() > 1 ? (is_vsmp ? internode_alignemnt : cache_line_size()) : 0, mandatory_alignment)

No the slab allocators were optimized for VSMP so that the 
internode_alignment is not necessary there. That was actually one of the 
requirements that triggered the slab numa work.

