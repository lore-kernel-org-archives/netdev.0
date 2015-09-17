From: Christoph Lameter <cl@linux.com>
Subject: Re: Experiences with slub bulk use-case for network stack
Date: Thu, 17 Sep 2015 18:57:17 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1509171854480.5696@east.gentwo.org>
References: <20150824005727.2947.36065.stgit@localhost> <20150904165944.4312.32435.stgit@devil> <20150916120230.4ca75217@redhat.com> <alpine.DEB.2.11.1509161009420.21859@east.gentwo.org> <20150917221702.734a42dc@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
    Alexander Duyck <alexander.duyck@gmail.com>, iamjoonsoo.kim@lge.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150917221702.734a42dc@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Sep 2015, Jesper Dangaard Brouer wrote:

> What I'm proposing is keeping interrupts on, and then simply cmpxchg
> e.g 2 slab-pages out of the SLUB allocator (which the SLUB code calls
> freelist's). The bulk call now owns these freelists, and returns them
> to the caller.  The API caller gets some helpers/macros to access
> objects, to shield him from the details (of SLUB freelist's).
>
> The pitfall with this API is we don't know how many objects are on a
> SLUB freelist.  And we cannot walk the freelist and count them, because
> then we hit the problem of memory/cache stalls (that we are trying so
> hard to avoid).

If you get a fresh page from the page allocator then you know how many
objects are available in a slab page.

There is also a counter in each slab page for the objects allocated. The
number of free object is page->objects - page->inuse.

This is only true for a lockec cmpxchg. The unlocked cmpxchg used for the
per cpu freelist does not use the counters in the page struct.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
