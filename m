From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH] slub: RFC: Improving SLUB performance with 38% on
 NO-PREEMPT
Date: Mon, 8 Jun 2015 11:23:59 +0200
Message-ID: <20150608112359.04a3750e@redhat.com>
References: <20150604103159.4744.75870.stgit@ivy>
	<1433471877.1895.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
        netdev@vger.kernel.org, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1433471877.1895.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 04 Jun 2015 19:37:57 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2015-06-04 at 12:31 +0200, Jesper Dangaard Brouer wrote:
> > This patch improves performance of SLUB allocator fastpath with 38% by
> > avoiding the call to this_cpu_cmpxchg_double() for NO-PREEMPT kernels.
> > 
> > Reviewers please point out why this change is wrong, as such a large
> > improvement should not be possible ;-)
> 
> I am not sure if anyone already answered, but the cmpxchg_double()
> is needed to avoid the ABA problem.
> 
> This is the whole point using tid _and_ freelist
> 
> Preemption is not the only thing that could happen here, think of
> interrupts.

Yes, I sort of already knew this.

My real question is if disabling local interrupts is enough to avoid this?

And, does local irq disabling also stop preemption?

Questions relate to this patch:
 http://ozlabs.org/~akpm/mmots/broken-out/slub-bulk-alloc-extract-objects-from-the-per-cpu-slab.patch

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
