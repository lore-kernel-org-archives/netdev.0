From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/40] mm: slab allocation fairness
Date: Wed, 16 May 2007 13:41:32 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705161338040.11168@schroedinger.engr.sgi.com>
References: <20070504102651.923946304@chello.nl> <20070504103155.813939525@chello.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:54348 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934140AbXEPUlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 16:41:35 -0400
In-Reply-To: <20070504103155.813939525@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 May 2007, Peter Zijlstra wrote:

> Page allocation rank is a scalar quantity connecting ALLOC_ and gfp flags which
> represents how deep we had to reach into our reserves when allocating a page. 
> Rank 0 is the deepest we can reach (ALLOC_NO_WATERMARK) and 16 is the most 
> shallow allocation possible (ALLOC_WMARK_HIGH).
> 
> When the slab space is grown the rank of the page allocation is stored. For
> each slab allocation we test the given gfp flags against this rank. Thereby
> asking the question: would these flags have allowed the slab to grow.
> 
> If not so, we need to test the current situation. This is done by forcing the
> growth of the slab space. (Just testing the free page limits will not work due
> to direct reclaim) Failing this we need to fail the slab allocation.

This implies that an allocation at time t2 must be aware of the result of 
an allocation at time t1. It assumes a linear ordering of allocations that 
is not possible on large systems. Ordering of events is a very expensive 
endeavor in particular on NUMA systems given the potentially large 
latencies between various portions of the system.

Maybe you need to restrict the ordering per cpu or per node? Per zone? 

Then we would need to store the ranks somewhere which raises scalability 
issues if these are global.


