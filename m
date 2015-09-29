From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [MM PATCH V4 5/6] slub: support for bulk free with SLUB freelists
Date: Tue, 29 Sep 2015 10:20:20 -0700
Message-ID: <560AC854.6040601@gmail.com>
References: <20150929154605.14465.98995.stgit@canyon>
 <20150929154807.14465.76422.stgit@canyon> <560ABE86.9050508@gmail.com>
 <20150929190029.01ca01f2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35094 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934840AbbI2RUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 13:20:22 -0400
Received: by pacfv12 with SMTP id fv12so11964300pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 10:20:22 -0700 (PDT)
In-Reply-To: <20150929190029.01ca01f2@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2015 10:00 AM, Jesper Dangaard Brouer wrote:
> On Tue, 29 Sep 2015 09:38:30 -0700
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> On 09/29/2015 08:48 AM, Jesper Dangaard Brouer wrote:
>>> +#if defined(CONFIG_KMEMCHECK) ||		\
>>> +	defined(CONFIG_LOCKDEP)	||		\
>>> +	defined(CONFIG_DEBUG_KMEMLEAK) ||	\
>>> +	defined(CONFIG_DEBUG_OBJECTS_FREE) ||	\
>>> +	defined(CONFIG_KASAN)
>>> +static inline void slab_free_freelist_hook(struct kmem_cache *s,
>>> +					   void *head, void *tail)
>>> +{
>>> +	void *object = head;
>>> +	void *tail_obj = tail ? : head;
>>> +
>>> +	do {
>>> +		slab_free_hook(s, object);
>>> +	} while ((object != tail_obj) &&
>>> +		 (object = get_freepointer(s, object)));
>>> +}
>>> +#else
>>> +static inline void slab_free_freelist_hook(struct kmem_cache *s, void *obj_tail,
>>> +					   void *freelist_head) {}
>>> +#endif
>>> +
>> Instead of messing around with an #else you might just wrap the contents
>> of slab_free_freelist_hook in the #if/#endif instead of the entire
>> function declaration.
> I had it that way in an earlier version of the patch, but I liked
> better this way.

It would be nice if the argument names were the same for both cases.  
Having the names differ will make it more difficult to maintain when 
changes need to be made to the function.

- Alex
