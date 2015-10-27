From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] net: mitigating kmem_cache slowpath for network
 stack in NAPI context
Date: Mon, 26 Oct 2015 18:09:39 -0700 (PDT)
Message-ID: <20151026.180939.2097997471080843310.davem@davemloft.net>
References: <20151023124451.17364.14594.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com, linux-mm@kvack.org,
 iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, cl@linux.com
To: brouer@redhat.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20151023124451.17364.14594.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 23 Oct 2015 14:46:01 +0200

> It have been a long road. Back in July 2014 I realized that network
> stack were hitting the kmem_cache/SLUB slowpath when freeing SKBs, but
> had no solution.  In Dec 2014 I had implemented a solution called
> qmempool[1], that showed it was possible to improve this, but got
> rejected due to being a cache on top of kmem_cache.  In July 2015
> improvements to kmem_cache were proposed, and recently Oct 2015 my
> kmem_cache (SLAB+SLUB) patches for bulk alloc and free have been
> accepted into the AKPM quilt tree.
> 
> This patchset is the first real use-case kmem_cache bulk alloc and free.
> And is joint work with Alexander Duyck while still at Red Hat.
> 
> Using bulk free to avoid the SLUB slowpath shows the full potential.
> In this patchset it is realized in NAPI/softirq context.  1. During
> DMA TX completion bulk free is optimal and does not introduce any
> added latency. 2. bulk free of SKBs delay free'ed due to IRQ context
> in net_tx_action softirq completion queue.
> 
> Using bulk alloc is showing minor improvements for SLUB(+0.9%), but a
> very slight slowdown for SLAB(-0.1%).
> 
> [1] http://thread.gmane.org/gmane.linux.network/342347/focus=126138
> 
> 
> This patchset is based on net-next (commit 26440c835), BUT I've
> applied several patches from AKPMs MM-tree.
> 
> Cherrypick some commits from MMOTM tree on branch/tag mmotm-2015-10-06-16-30
> from git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> (Below commit IDs are obviously not stable)

Logically I'm fine with this series, but as you mention there are
dependencies that need to hit upstream before I can merge any of
this stuff into my tree.

I also think that patch #4 is a net-win, and also will expose the
bulking code to more testing since it will be used more often.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
