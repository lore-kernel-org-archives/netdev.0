From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Thu, 6 Mar 2008 21:11:39 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803062108210.1143@schroedinger.engr.sgi.com>
References: <20080303093449.GA15091@wotan.suse.de> <20080303093529.GB15091@wotan.suse.de>
 <Pine.LNX.4.64.0803031104570.6917@schroedinger.engr.sgi.com>
 <20080303200355.GB8974@wotan.suse.de> <Pine.LNX.4.64.0803031208400.16049@schroedinger.engr.sgi.com>
 <20080303201211.GE8974@wotan.suse.de> <Pine.LNX.4.64.0803031216430.3110@schroedinger.engr.sgi.com>
 <20080303202411.GH8974@wotan.suse.de> <Pine.LNX.4.64.0803031327330.4375@schroedinger.engr.sgi.com>
 <20080307043700.GI21185@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:40716 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750932AbYCGFL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 00:11:57 -0500
In-Reply-To: <20080307043700.GI21185@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Mar 2008, Nick Piggin wrote:

> > No the slab allocators were optimized for VSMP so that the 
> > internode_alignment is not necessary there. That was actually one of the 
> > requirements that triggered the slab numa work.
> 
> BTW. can you explain this incredible claim that the slab allocators
> do not need internode_alignment to avoid false sharing of allocated
> objects on VSMP? I don't understand how that would work at all.

The queues are per node which means that pages from which we allocate are 
distinct per node. As long as processes allocate and free object on a 
single node all is fine. Problems can arise though if objects are used 
across node. The earlier incarnation of SLAB had a single global queue for 
slab pages and objects could be allocated from an arbitrary processor. 
Objects from the same page were allocated from all processors.

