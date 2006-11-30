From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
Date: Thu, 30 Nov 2006 10:52:52 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl>> <20061130101921.113055000@chello.nl>>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:46737 "EHLO omx2.sgi.com")
	by vger.kernel.org with ESMTP id S1031216AbWK3SxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 13:53:01 -0500
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20061130101921.113055000@chello.nl>>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Nov 2006, Peter Zijlstra wrote:

> The slab has some unfairness wrt gfp flags; when the slab is grown the gfp 
> flags are used to allocate more memory, however when there is slab space 
> available, gfp flags are ignored. Thus it is possible for less critical 
> slab allocations to succeed and gobble up precious memory.

The gfpflags are ignored if there are

1) objects in the per cpu, shared or alien caches

2) objects are in partial or free slabs in the per node queues.

> This patch avoids this by keeping track of the allocation hardness when 
> growing. This is then compared to the current slab alloc's gfp flags.

The approach is to force the allocation of additional slab to increase the 
number of free slabs? The next free will drop the number of free slabs 
back again to the allowed amount.

I would think that one would need a rank with each cached object and 
free slab in order to do this the right way.
