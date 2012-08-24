From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
Date: Fri, 24 Aug 2012 22:11:55 +0200
Message-ID: <5037E00B.6090606@gmail.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com> <1345602432-27673-2-git-send-email-levinsasha928@gmail.com> <20120822180138.GA19212@google.com> <50357840.5020201@gmail.com> <20120823200456.GD14962@google.com> <5037DA47.9010306@gmail.com> <20120824195941.GC21325@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120824195941.GC21325-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/24/2012 09:59 PM, Tejun Heo wrote:
> Hello, Sasha.
> 
> On Fri, Aug 24, 2012 at 09:47:19PM +0200, Sasha Levin wrote:
>>> I think this is problematic.  It looks exactly like other existing
>>> DEFINE macros yet what its semantics is different.  I don't think
>>> that's a good idea.
>>
>> I can switch that to be DECLARE_HASHTABLE() if the issue is semantics.
> 
> If this implementation is about the common trivial case, why not just
> have the usual DECLARE/DEFINE_HASHTABLE() combination?

When we add the dynamic non-resizable support, how would DEFINE_HASHTABLE() look?

>>> So, I think it would be best to keep this one as straight-forward and
>>> trivial as possible.  Helper macros to help its users are fine but
>>> let's please not go for full encapsulation.
>>
>> What if we cut off the dynamic allocated (but not resizable) hashtable out for
>> the moment, and focus on the most common statically allocated hashtable case?
>>
>> The benefits would be:
>>
>>  - Getting rid of all the _size() macros, which will make the amount of helpers
>> here reasonable.
>>  - Dynamically allocated hashtable can be easily added as a separate
>> implementation using the same API. We already have some of those in the kernel...
> 
> It seems we have enough of this static usage and solving the static
> case first shouldn't hinder the dynamic (!resize) case later, so,
> yeah, sounds good to me.
> 
>>  - When that's ready, I feel it's a shame to lose full encapsulation just due to
>> hash_hashed().
> 
> I don't know.  If we stick to the static (or even !resize dymaic)
> straight-forward hash - and we need something like that - I don't see
> what the full encapsulation buys us other than a lot of trivial
> wrappers.

Which macros do you consider as trivial within the current API?

Basically this entire thing could be reduced to DEFINE/DECLARE_HASHTABLE and
get_bucket(), but it would make the life of anyone who wants a slightly
different hashtable a hell.

I think that right now the only real trivial wrapper is hash_hashed(), and I
think it's a price worth paying to have a single hashtable API instead of
fragmenting it when more implementations come along.

Thanks,
Sasha

> 
> Thanks.
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
