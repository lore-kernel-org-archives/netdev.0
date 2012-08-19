From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 01/16] hashtable: introduce a small and
	naive hashtable
Date: Sun, 19 Aug 2012 18:08:01 +0200
Message-ID: <50310F61.9030805@gmail.com>
References: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
	<1345337550-24304-2-git-send-email-levinsasha928@gmail.com>
	<20120819131637.GA8272@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20120819131637.GA8272@Krystal>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/19/2012 03:16 PM, Mathieu Desnoyers wrote:
> * Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
>> This hashtable implementation is using hlist buckets to provide a simple
>> hashtable to prevent it from getting reimplemented all over the kernel.
>>
>> Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>  include/linux/hashtable.h |  284 +++++++++++++++++++++++++++++++++++++++++++++
> [...]
> 
> Hi Sasha,
> 
> There are still a few API naming nits that I'd like to discuss:
> 
>> +
>> +/**
>> + * hash_for_each_size - iterate over a hashtable
>> + * @name: hashtable to iterate
>> + * @bits: bit count of hashing function of the hashtable
>> + * @bkt: integer to use as bucket loop cursor
>> + * @node: the &struct list_head to use as a loop cursor for each bucket
>> + * @obj: the type * to use as a loop cursor for each bucket
>> + * @member: the name of the hlist_node within the struct
>> + */
>> +#define hash_for_each_size(name, bits, bkt, node, obj, member)			\
> 
> What is the meaning of "for each size" ?
> 
> By looking at the implementation, I see that it takes an extra "bits"
> argument to specify the key width.
> 
> But in the other patches of this patchset, I cannot find a single user
> of the "*_size" API. If you do not typically expect users to specify
> this parameter by hand (thanks to use of HASH_BITS(name) in for_each
> functions that do not take the bits parameter), I would recommend to
> only expose hash_for_each() and similar defines, but n I'd ot the *_size
> variants.
> 
> So I recommend merging hash_for_each_size into hash_for_each (and
> doing similarly for other *_size variants). On the plus side, it will
> cut down the number of for_each macros from 12 down to 6, whiy och is more
> reasonable.

This is actually how the hashtable API was looking in the first place - without
the _size functions.

The story here is that when I've introduced the original API which used macro
magic to work out the size, one of the first comments was that there are several
dynamically allocated hashtables around the kernels, and all this macro magic
wouldn't work.

I've grepped around the code and indeed saw several places which k*alloc/vmalloc
their hashtable, so I agreed with that and happily went ahead to extend the API
to have _size functions.

When I started converting more kernel code to use this new API, I also converted
two modules which kmalloced the hashtable, but instead of using the _size API I
ended up removing the allocation completely because it was unnecessary and
wasteful. And this is why you don't see _size being used anywhere in any of the
patches.

Looking at the kernel code again, I see several places where removal of dynamic
allocation won't work (see 'new_tl_hash' in drivers/block/drbd/drbd_nl.c for
example).

So I'd rather leave it in at least until we finish converting, as I see several
places which will definitely need it.
