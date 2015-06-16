From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/7] slub bulk alloc: extract objects from the per cpu
 slab
Date: Tue, 16 Jun 2015 10:05:06 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1506161003480.3496@east.gentwo.org>
References: <20150615155053.18824.617.stgit@devil> <20150615155207.18824.8674.stgit@devil> <20150616072107.GA13125@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org,
    Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
    Alexander Duyck <alexander.duyck@gmail.com>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150616072107.GA13125@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Jun 2015, Joonsoo Kim wrote:

> Now I found that we need to call slab_pre_alloc_hook() before any operation
> on kmem_cache to support kmemcg accounting. And, we need to call
> slab_post_alloc_hook() on every allocated objects to support many
> debugging features like as kasan and kmemleak

Use the fallback function for any debugging avoids that. This needs to be
fast. If the performance is not wanted (debugging etc active) then the
fallback should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
