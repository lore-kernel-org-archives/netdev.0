From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Fri, 7 Mar 2008 05:37:00 +0100
Message-ID: <20080307043700.GI21185@wotan.suse.de>
References: <20080303093449.GA15091@wotan.suse.de> <20080303093529.GB15091@wotan.suse.de> <Pine.LNX.4.64.0803031104570.6917@schroedinger.engr.sgi.com> <20080303200355.GB8974@wotan.suse.de> <Pine.LNX.4.64.0803031208400.16049@schroedinger.engr.sgi.com> <20080303201211.GE8974@wotan.suse.de> <Pine.LNX.4.64.0803031216430.3110@schroedinger.engr.sgi.com> <20080303202411.GH8974@wotan.suse.de> <Pine.LNX.4.64.0803031327330.4375@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55604 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758159AbYCGEhE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 23:37:04 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803031327330.4375@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 01:31:14PM -0800, Christoph Lameter wrote:
> On Mon, 3 Mar 2008, Nick Piggin wrote:
> 
> > And maybe the VSMP guys will want to blow this out to their internode
> > alignment?
> > 
> > max(!CONFIG_TINY && num_possible_cpus() > 1 ? (is_vsmp ? internode_alignemnt : cache_line_size()) : 0, mandatory_alignment)
> 
> No the slab allocators were optimized for VSMP so that the 
> internode_alignment is not necessary there. That was actually one of the 
> requirements that triggered the slab numa work.

BTW. can you explain this incredible claim that the slab allocators
do not need internode_alignment to avoid false sharing of allocated
objects on VSMP? I don't understand how that would work at all.

