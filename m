From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [MM PATCH V4 5/6] slub: support for bulk free with SLUB
 freelists
Date: Tue, 29 Sep 2015 20:16:05 +0200
Message-ID: <20150929201605.18626b1b@redhat.com>
References: <20150929154605.14465.98995.stgit@canyon>
	<20150929154807.14465.76422.stgit@canyon>
	<560ABE86.9050508@gmail.com>
	<20150929190029.01ca01f2@redhat.com>
	<560AC854.6040601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
        Christoph
 Lameter <cl@linux.com>, netdev@vger.kernel.org,
        Pekka Enberg
 <penberg@kernel.org>,
        David Rientjes <rientjes@google.com>,
        Joonsoo Kim
 <iamjoonsoo.kim@lge.com>, brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <560AC854.6040601@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Sep 2015 10:20:20 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On 09/29/2015 10:00 AM, Jesper Dangaard Brouer wrote:
> > On Tue, 29 Sep 2015 09:38:30 -0700
> > Alexander Duyck <alexander.duyck@gmail.com> wrote:
> >
> >> On 09/29/2015 08:48 AM, Jesper Dangaard Brouer wrote:
> >>> +#if defined(CONFIG_KMEMCHECK) ||		\
> >>> +	defined(CONFIG_LOCKDEP)	||		\
> >>> +	defined(CONFIG_DEBUG_KMEMLEAK) ||	\
> >>> +	defined(CONFIG_DEBUG_OBJECTS_FREE) ||	\
> >>> +	defined(CONFIG_KASAN)
> >>> +static inline void slab_free_freelist_hook(struct kmem_cache *s,
> >>> +					   void *head, void *tail)
> >>> +{
> >>> +	void *object = head;
> >>> +	void *tail_obj = tail ? : head;
> >>> +
> >>> +	do {
> >>> +		slab_free_hook(s, object);
> >>> +	} while ((object != tail_obj) &&
> >>> +		 (object = get_freepointer(s, object)));
> >>> +}
> >>> +#else
> >>> +static inline void slab_free_freelist_hook(struct kmem_cache *s, void *obj_tail,
> >>> +					   void *freelist_head) {}
> >>> +#endif
> >>> +
> >> Instead of messing around with an #else you might just wrap the contents
> >> of slab_free_freelist_hook in the #if/#endif instead of the entire
> >> function declaration.
> >
> > I had it that way in an earlier version of the patch, but I liked
> > better this way.
> 
> It would be nice if the argument names were the same for both cases.  
> Having the names differ will make it more difficult to maintain when 
> changes need to be made to the function.

Nice spotted, I forgot to change arg names of the empty function, when
I updated the patch. Guess, it is an argument for moving the "if
defined()" into the function body.

It just looked strange to have such a big ifdef block inside the
function.  I also earlier had it define another def and use that inside
the function, but then the code-reader would not know if this new def
was/could-be used later (nitpicking alert...)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
