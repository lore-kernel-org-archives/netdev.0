From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
Date: Tue, 16 Jun 2015 10:10:25 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1506161008350.3496@east.gentwo.org>
References: <20150615155053.18824.617.stgit@devil> <20150615155256.18824.42651.stgit@devil> <20150616072806.GC13125@js1304-P5Q-DELUXE> <20150616102110.55208fdd@redhat.com> <20150616105732.2bc37714@redhat.com>
 <CAAmzW4OM-afGBZbWZzcH7O-mivNWvyeKpMVV4Os+i4Xb7GPgmg@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>,
    Linux Memory Management List <linux-mm@kvack.org>,
    Andrew Morton <akpm@linux-foundation.org>,
    Linux-Netdev <netdev@vger.kernel.org>,
    Alexander Duyck <alexander.duyck@gmail.com>
To: Joonsoo Kim <js1304@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CAAmzW4OM-afGBZbWZzcH7O-mivNWvyeKpMVV4Os+i4Xb7GPgmg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Jun 2015, Joonsoo Kim wrote:

> So, in your test, most of objects may come from one or two slabs and your
> algorithm is well optimized for this case. But, is this workload normal case?

It is normal if the objects were bulk allocated because SLUB ensures that
all objects are first allocated from one page before moving to another.

> If most of objects comes from many different slabs, bulk free API does
> enabling/disabling interrupt very much so I guess it work worse than
> just calling __kmem_cache_free_bulk(). Could you test this case?

In case of SLAB this would be an issue since the queueing mechanism
destroys spatial locality. This is much less an issue for SLUB.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
