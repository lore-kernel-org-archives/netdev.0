From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH mm] slab: implement bulking for SLAB allocator
Date: Tue, 8 Sep 2015 12:10:54 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1509081209180.25526@east.gentwo.org>
References: <20150908142147.22804.37717.stgit@devil> <alpine.DEB.2.11.1509081020510.25292@east.gentwo.org> <20150908175451.2ce83a0b@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org,
    netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150908175451.2ce83a0b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Sep 2015, Jesper Dangaard Brouer wrote:

> This test was a single CPU benchmark with no congestion or concurrency.
> But the code was compiled with CONFIG_NUMA=y.
>
> I don't know the slAb code very well, but the kmem_cache_node->list_lock
> looks like a scalability issue.  I guess that is what you are referring
> to ;-)

That lock can be mitigated like in SLUB by increasing per cpu resources.
The problem in SLAB is the categorization of objects on free as to which
node they came from and the use of arrays of pointers to avoid freeing the
object to the object tracking metadata structures in the slab page.

The arrays of pointers have to be replicated for each node, each slab and
each processor.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
