From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
Date: Tue, 28 Aug 2012 11:56:52 +0200
Message-ID: <503C95E4.3010000@gmail.com>
References: <50357840.5020201@gmail.com> <20120823200456.GD14962@google.com> <5037DA47.9010306@gmail.com> <20120824195941.GC21325@google.com> <5037E00B.6090606@gmail.com> <20120824203332.GF21325@google.com> <5037E9D9.9000605@gmail.com> <20120824212348.GK21325@google.com> <5038074D.300@gmail.com> <20120824230740.GN21325@google.com> <20120825042419.GA27240@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120825042419.GA27240@Krystal>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/25/2012 06:24 AM, Mathieu Desnoyers wrote:
> * Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org) wrote:
>> Hello,
>>
>> On Sat, Aug 25, 2012 at 12:59:25AM +0200, Sasha Levin wrote:
>>> Thats the thing, the amount of things of things you can do with a given bucket
>>> is very limited. You can't add entries to any point besides the head (without
>>> walking the entire list).
>>
>> Kinda my point.  We already have all the hlist*() interface to deal
>> with such cases.  Having something which is evidently the trivial
>> hlist hashtable and advertises as such in the interface can be
>> helpful.  I think we need that more than we need anything fancy.
>>
>> Heh, this is a debate about which one is less insignificant.  I can
>> see your point.  I'd really like to hear what others think on this.
>>
>> Guys, do we want something which is evidently trivial hlist hashtable
>> which can use hlist_*() API directly or do we want something better
>> encapsulated?
> 
> My 2 cents, FWIW: I think this specific effort should target a trivially
> understandable API and implementation, for use-cases where one would be
> tempted to reimplement his own trivial hash table anyway. So here
> exposing hlist internals, with which kernel developers are already
> familiar, seems like a good approach in my opinion, because hiding stuff
> behind new abstraction might make the target users go away.
> 
> Then, as we see the need, we can eventually merge a more elaborate hash
> table with poneys and whatnot, but I would expect that the trivial hash
> table implementation would still be useful. There are of course very
> compelling reasons to use a more featureful hash table: automatic
> resize, RT-aware updates, scalable updates, etc... but I see a purpose
> for a trivial implementation. Its primary strong points being:
> 
> - it's trivially understandable, so anyone how want to be really sure
>   they won't end up debugging the hash table instead of their
>   work-in-progress code can have a full understanding of it,
> - it has few dependencies, which makes it easier to understand and
>   easier to use in some contexts (e.g. early boot).
> 
> So I'm in favor of not overdoing the abstraction for this trivial hash
> table, and honestly I would rather prefer that this trivial hash table
> stays trivial. A more elaborate hash table should probably come as a
> separate API.
> 
> Thanks,
> 
> Mathieu
> 

Alright, let's keep it simple then.

I do want to keep the hash_for_each[rcu,safe] family though.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
