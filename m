From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 01/16] hashtable: introduce a small and
	naive hashtable
Date: Sun, 19 Aug 2012 18:17:44 +0200
Message-ID: <503111A8.5030703@gmail.com>
References: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
	<1345337550-24304-2-git-send-email-levinsasha928@gmail.com>
	<20120819131637.GA8272@Krystal> <20120819141641.GA9082@Krystal>
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
In-Reply-To: <20120819141641.GA9082@Krystal>
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

On 08/19/2012 04:16 PM, Mathieu Desnoyers wrote:
> * Mathieu Desnoyers (mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org) wrote:
>> * Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> [...]
>>> +/**
>>> + * hash_for_each_possible - iterate over all possible objects for a given key
>>> + * @name: hashtable to iterate
>>> + * @obj: the type * to use as a loop cursor for each bucket
>>> + * @bits: bit count of hashing function of the hashtable
>>> + * @node: the &struct list_head to use as a loop cursor for each bucket
>>> + * @member: the name of the hlist_node within the struct
>>> + * @key: the key of the objects to iterate over
>>> + */
>>> +#define hash_for_each_possible_size(name, obj, bits, node, member, key)		\
>>> +	hlist_for_each_entry(obj, node,	&name[hash_min(key, bits)], member)
>>
>> Second point: "for_each_possible" does not express the iteration scope.
>> Citing WordNet: "possible adj 1: capable of happening or existing;" --
>> which has nothing to do with iteration on duplicate keys within a hash
>> table.
>>
>> I would recommend to rename "possible" to "duplicate", e.g.:
>>
>>   hash_for_each_duplicate()
>>
>> which clearly says what is the scope of this iteration: duplicate keys.
> 
> OK, about this part: I now see that you iterate over all objects within
> the same hash chain. I guess the description "iterate over all possible
> objects for a given key" is misleading: it's not all objects with a
> given key, but rather all objects hashing to the same bucket.
> 
> I understand that you don't want to build knowledge of the key
> comparison function in the iterator (which makes sense for a simple hash
> table).
> 
> By the way, the comment "@obj: the type * to use as a loop cursor for
> each bucket" is also misleading: it's a loop cursor for each entry,
> since you iterate on all nodes within single bucket. Same for "@node:
> the &struct list_head to use as a loop cursor for each bucket".
> 
> So with these documentation changes applied, hash_for_each_possible
> starts to make more sense, because it refers to entries that can
> _possibly_ be a match (or not). Other options would be
> hash_chain_for_each() or hash_bucket_for_each().

I'd rather avoid starting to use chain/bucket since they're not used anywhere
else (I've tried keeping internal hashing/bucketing opaque to the user).

Otherwise makes sense, I'll improve the documentation as suggested. Thanks!

> Thanks,
> 
> Mathieu
> 
