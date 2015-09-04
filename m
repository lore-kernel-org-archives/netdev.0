From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache
 bulk free API.
Date: Fri, 4 Sep 2015 13:55:24 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1509041354560.993@east.gentwo.org>
References: <20150824005727.2947.36065.stgit@localhost> <20150904165944.4312.32435.stgit@devil> <55E9DE51.7090109@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
    akpm@linux-foundation.org, linux-mm@kvack.org, aravinda@linux.vnet.ibm.com,
    "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <55E9DE51.7090109@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Sep 2015, Alexander Duyck wrote:

> were to create a per-cpu pool for skbs that could be freed and allocated in
> NAPI context.  So for example we already have napi_alloc_skb, why not just add
> a napi_free_skb and then make the array of objects to be freed part of a pool
> that could be used for either allocation or freeing?  If the pool runs empty
> you just allocate something like 8 or 16 new skb heads, and if you fill it you
> just free half of the list?

The slab allocators provide something like a per cpu pool for you to
optimize object alloc and free.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
