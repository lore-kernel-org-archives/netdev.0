From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache
 bulk free API.
Date: Fri, 4 Sep 2015 18:45:13 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1509041844190.2499@east.gentwo.org>
References: <20150824005727.2947.36065.stgit@localhost> <20150904165944.4312.32435.stgit@devil> <55E9DE51.7090109@gmail.com> <alpine.DEB.2.11.1509041354560.993@east.gentwo.org> <55EA0172.2040505@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
    akpm@linux-foundation.org, linux-mm@kvack.org, aravinda@linux.vnet.ibm.com,
    "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <55EA0172.2040505@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Sep 2015, Alexander Duyck wrote:
> Right, but one of the reasons for Jesper to implement the bulk alloc/free is
> to avoid the cmpxchg that is being used to get stuff into or off of the per
> cpu lists.

There is no full cmpxchg used for the per cpu lists. Its a cmpxchg without
lock semantics which is very cheap.

> In the case of network drivers they are running in softirq context almost
> exclusively.  As such it is useful to have a set of buffers that can be
> acquired or freed from this context without the need to use any
> synchronization primitives.  Then once the softirq context ends then we can
> free up some or all of the resources back to the slab allocator.

That is the case in the slab allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
