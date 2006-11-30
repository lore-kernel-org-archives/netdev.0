From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
Date: Thu, 30 Nov 2006 19:55:15 +0100
Message-ID: <1164912915.6588.153.camel@twins>
References: <20061130101451.495412000@chello.nl> >
	 <20061130101921.113055000@chello.nl> >
	  <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep19-int.chello.nl ([213.46.243.16]:34922 "EHLO
	amsfep17-int.chello.nl") by vger.kernel.org with ESMTP
	id S967886AbWK3THy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 14:07:54 -0500
To: Christoph Lameter <clameter@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-30 at 10:52 -0800, Christoph Lameter wrote:
> On Thu, 30 Nov 2006, Peter Zijlstra wrote:
> 
> > The slab has some unfairness wrt gfp flags; when the slab is grown the gfp 
> > flags are used to allocate more memory, however when there is slab space 
> > available, gfp flags are ignored. Thus it is possible for less critical 
> > slab allocations to succeed and gobble up precious memory.
> 
> The gfpflags are ignored if there are
> 
> 1) objects in the per cpu, shared or alien caches
> 
> 2) objects are in partial or free slabs in the per node queues.

Yeah, basically as long as free objects can be found. No matter how
'hard' is was to obtain these objects.

> > This patch avoids this by keeping track of the allocation hardness when 
> > growing. This is then compared to the current slab alloc's gfp flags.
> 
> The approach is to force the allocation of additional slab to increase the 
> number of free slabs? The next free will drop the number of free slabs 
> back again to the allowed amount.

No, the forced allocation is to test the allocation hardness at that
point in time. I could not think of another way to test that than to
actually to an allocation.

