From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] kthread: NUMA aware kthread_create_on_cpu()
Date: Mon, 29 Nov 2010 00:01:47 +0100
Message-ID: <20101128230146.GB12300@basil.fritz.box>
References: <1290972833.29196.90.camel@edumazet-laptop>
 <20101128224024.GA12300@basil.fritz.box>
 <1290984712.29196.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1290984712.29196.100.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 28, 2010 at 11:51:51PM +0100, Eric Dumazet wrote:
> > Also this messes up the policy of the caller process. You really
> > need to save/restore it.
> 
> Well, caller process duty is to create kthreads in a loop.

In this case any other allocations it may do are still on those
nodes.

> > Problem is that this ends up in architecture specific code
> > for the stack, so may be a larger patch.
> 
> I suggest arches that need slab to allocate kthread stacks do the
> appropriate changes, because I am not able to make them myself.
> 
> On x86, we use page allocator only, so NUMA mempolicy is used.

task_struct is always allocated from slab.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
