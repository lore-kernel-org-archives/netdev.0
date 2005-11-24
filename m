From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Thu, 24 Nov 2005 07:50:37 +0100
Message-ID: <20051124065037.GZ20775@brahms.suse.de>
References: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com> <4384E7F2.2030508@pobox.com> <20051123223007.GA5921@wotan.suse.de> <20051124001700.GC14246@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Jeff Garzik <jgarzik@pobox.com>,
	Andrew Grover <andrew.grover@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161023AbVKXGup@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20051124001700.GC14246@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2005 at 07:17:01PM -0500, Benjamin LaHaise wrote:
> On Wed, Nov 23, 2005 at 11:30:08PM +0100, Andi Kleen wrote:
> > The main problem I see is that it'll likely only pay off when you can keep 
> > the queue of copies long (to amortize the cost of 
> > talking to an external chip). At least for the standard recvmsg 
> > skb->user space, user space-> skb cases these queues are 
> > likely short in most cases. That's because most applications
> > do relatively small recvmsg or sendmsgs. 
> 
> Don't forget that there are benefits of not polluting the cache with the 
> traffic for the incoming skbs.

Is that a general benefit outside benchmarks? I would expect
most real programs to actually do something with the data
- and that usually involves needing it in cache.

> > But it's not clear it's a good idea: a lot of these applications prefer to 
> > have the target in cache. And IOAT will force it out of cache.
> 
> In the I/O AT case it might make sense to do a few prefetch()es of the 
> userland data on the return-to-userspace code path.  

Some prefetches for user space might be a good idea yes

> Similarly, we should 
> make sure that network drivers prefetch the header at the earliest possible 
> time, too.

It's done kind of already but tricky to get right because
the prefetch distances upto use are not really long enough


-Andi
