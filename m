From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and
	naive	hashtable
Date: Tue, 30 Oct 2012 15:19:09 -0400
Message-ID: <20121030191909.GB9427@Krystal>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
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
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351622772-16400-1-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

* Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> This hashtable implementation is using hlist buckets to provide a simple
> hashtable to prevent it from getting reimplemented all over the kernel.
> 
> Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>

> ---
> 
> Changes from v8:
> 
>  - Addressed comments from Tejun Heo and Mathieu Desnoyers.
> 
> 
>  include/linux/hashtable.h | 196 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 196 insertions(+)
>  create mode 100644 include/linux/hashtable.h
> 
> diff --git a/include/linux/hashtable.h b/include/linux/hashtable.h
> new file mode 100644
> index 0000000..3c1a9cb
> --- /dev/null
> +++ b/include/linux/hashtable.h
> @@ -0,0 +1,196 @@
> +/*
> + * Statically sized hash table implementation
> + * (C) 2012  Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> + */
> +
> +#ifndef _LINUX_HASHTABLE_H
> +#define _LINUX_HASHTABLE_H
> +
> +#include <linux/list.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/hash.h>
> +#include <linux/rculist.h>
> +
> +#define DEFINE_HASHTABLE(name, bits)						\
> +	struct hlist_head name[1 << (bits)] =					\
> +			{ [0 ... ((1 << (bits)) - 1)] = HLIST_HEAD_INIT }
> +
> +#define DECLARE_HASHTABLE(name, bits)                                   	\
> +	struct hlist_head name[1 << (bits)]
> +
> +#define HASH_SIZE(name) (ARRAY_SIZE(name))
> +#define HASH_BITS(name) ilog2(HASH_SIZE(name))
> +
> +/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
> +#define hash_min(val, bits)							\
> +({										\
> +	sizeof(val) <= 4 ?							\
> +	hash_32(val, bits) :							\
> +	hash_long(val, bits);							\
> +})
> +
> +static inline void __hash_init(struct hlist_head *ht, unsigned int sz)
> +{
> +	unsigned int i;
> +
> +	for (i = 0; i < sz; i++)
> +		INIT_HLIST_HEAD(&ht[i]);
> +}
> +
> +/**
> + * hash_init - initialize a hash table
> + * @hashtable: hashtable to be initialized
> + *
> + * Calculates the size of the hashtable from the given parameter, otherwise
> + * same as hash_init_size.
> + *
> + * This has to be a macro since HASH_BITS() will not work on pointers since
> + * it calculates the size during preprocessing.
> + */
> +#define hash_init(hashtable) __hash_init(hashtable, HASH_SIZE(hashtable))
> +
> +/**
> + * hash_add - add an object to a hashtable
> + * @hashtable: hashtable to add to
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add(hashtable, node, key)						\
> +	hlist_add_head(node, &hashtable[hash_min(key, HASH_BITS(hashtable))])
> +
> +/**
> + * hash_add_rcu - add an object to a rcu enabled hashtable
> + * @hashtable: hashtable to add to
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add_rcu(hashtable, node, key)					\
> +	hlist_add_head_rcu(node, &hashtable[hash_min(key, HASH_BITS(hashtable))])
> +
> +/**
> + * hash_hashed - check whether an object is in any hashtable
> + * @node: the &struct hlist_node of the object to be checked
> + */
> +static inline bool hash_hashed(struct hlist_node *node)
> +{
> +	return !hlist_unhashed(node);
> +}
> +
> +static inline bool __hash_empty(struct hlist_head *ht, unsigned int sz)
> +{
> +	unsigned int i;
> +
> +	for (i = 0; i < sz; i++)
> +		if (!hlist_empty(&ht[i]))
> +			return false;
> +
> +	return true;
> +}
> +
> +/**
> + * hash_empty - check whether a hashtable is empty
> + * @hashtable: hashtable to check
> + *
> + * This has to be a macro since HASH_BITS() will not work on pointers since
> + * it calculates the size during preprocessing.
> + */
> +#define hash_empty(hashtable) __hash_empty(hashtable, HASH_SIZE(hashtable))
> +
> +/**
> + * hash_del - remove an object from a hashtable
> + * @node: &struct hlist_node of the object to remove
> + */
> +static inline void hash_del(struct hlist_node *node)
> +{
> +	hlist_del_init(node);
> +}
> +
> +/**
> + * hash_del_rcu - remove an object from a rcu enabled hashtable
> + * @node: &struct hlist_node of the object to remove
> + */
> +static inline void hash_del_rcu(struct hlist_node *node)
> +{
> +	hlist_del_init_rcu(node);
> +}
> +
> +/**
> + * hash_for_each - iterate over a hashtable
> + * @name: hashtable to iterate
> + * @bkt: integer to use as bucket loop cursor
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @obj: the type * to use as a loop cursor for each entry
> + * @member: the name of the hlist_node within the struct
> + */
> +#define hash_for_each(name, bkt, node, obj, member)				\
> +	for ((bkt) = 0, node = NULL; node == NULL && (bkt) < HASH_SIZE(name); (bkt)++)\
> +		hlist_for_each_entry(obj, node, &name[bkt], member)
> +
> +/**
> + * hash_for_each_rcu - iterate over a rcu enabled hashtable
> + * @name: hashtable to iterate
> + * @bkt: integer to use as bucket loop cursor
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @obj: the type * to use as a loop cursor for each entry
> + * @member: the name of the hlist_node within the struct
> + */
> +#define hash_for_each_rcu(name, bkt, node, obj, member)				\
> +	for ((bkt) = 0, node = NULL; node == NULL && (bkt) < HASH_SIZE(name); (bkt)++)\
> +		hlist_for_each_entry_rcu(obj, node, &name[bkt], member)
> +
> +/**
> + * hash_for_each_safe - iterate over a hashtable safe against removal of
> + * hash entry
> + * @name: hashtable to iterate
> + * @bkt: integer to use as bucket loop cursor
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @tmp: a &struct used for temporary storage
> + * @obj: the type * to use as a loop cursor for each entry
> + * @member: the name of the hlist_node within the struct
> + */
> +#define hash_for_each_safe(name, bkt, node, tmp, obj, member)			\
> +	for ((bkt) = 0, node = NULL; node == NULL && (bkt) < HASH_SIZE(name); (bkt)++)\
> +		hlist_for_each_entry_safe(obj, node, tmp, &name[bkt], member)
> +
> +/**
> + * hash_for_each_possible - iterate over all possible objects hashing to the
> + * same bucket
> + * @name: hashtable to iterate
> + * @obj: the type * to use as a loop cursor for each entry
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @member: the name of the hlist_node within the struct
> + * @key: the key of the objects to iterate over
> + */
> +#define hash_for_each_possible(name, obj, node, member, key)			\
> +	hlist_for_each_entry(obj, node,	&name[hash_min(key, HASH_BITS(name))], member)
> +
> +/**
> + * hash_for_each_possible_rcu - iterate over all possible objects hashing to the
> + * same bucket in an rcu enabled hashtable
> + * in a rcu enabled hashtable
> + * @name: hashtable to iterate
> + * @obj: the type * to use as a loop cursor for each entry
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @member: the name of the hlist_node within the struct
> + * @key: the key of the objects to iterate over
> + */
> +#define hash_for_each_possible_rcu(name, obj, node, member, key)		\
> +	hlist_for_each_entry_rcu(obj, node, &name[hash_min(key, HASH_BITS(name))], member)
> +
> +/**
> + * hash_for_each_possible_safe - iterate over all possible objects hashing to the
> + * same bucket safe against removals
> + * @name: hashtable to iterate
> + * @obj: the type * to use as a loop cursor for each entry
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @tmp: a &struct used for temporary storage
> + * @member: the name of the hlist_node within the struct
> + * @key: the key of the objects to iterate over
> + */
> +#define hash_for_each_possible_safe(name, obj, node, tmp, member, key)		\
> +	hlist_for_each_entry_safe(obj, node, tmp,				\
> +		&name[hash_min(key, HASH_BITS(name))], member)
> +
> +
> +#endif
> -- 
> 1.7.12.4
> 

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
