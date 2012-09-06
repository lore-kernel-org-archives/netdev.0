From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and
	naive	hashtable
Date: Thu, 6 Sep 2012 10:33:20 -0400
Message-ID: <20120906143320.GA4513@Krystal>
References: <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal>
	<503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal>
	<20120828230050.GA3337@Krystal>
	<1346772948.27919.9.camel@gandalf.local.home>
	<50462C99.5000007@redhat.com> <50462EE8.1090903@redhat.com>
	<20120904170138.GB31934@Krystal> <5048AAF6.5090101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	Pedro Alves <palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5048AAF6.5090101-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
> On 09/04/2012 07:01 PM, Mathieu Desnoyers wrote:
> >> #define do_for_each_ftrace_rec(pg, rec)                                          \
> >> >         for (pg = ftrace_pages_start, rec = &pg->records[pg->index];             \
> >> >              pg && rec == &pg->records[pg->index];                               \
> >> >              pg = pg->next)                                                      \
> >> >           for (rec = pg->records; rec < &pg->records[pg->index]; rec++)
> > Maybe in some cases there might be ways to combine the two loops into
> > one ? I'm not seeing exactly how to do it for this one, but it should
> > not be impossible. If the inner loop condition can be moved to the outer
> > loop, and if we use (blah ? loop1_conf : loop2_cond) to test for
> > different conditions depending on the context, and do the same for the
> > 3rd argument of the for() loop. The details elude me for now though, so
> > maybe it's complete non-sense ;)
> > 
> > It might not be that useful for do_for_each_ftrace_rec, but if we can do
> > it for the hash table iterator, it might be worth it.
> 
> So I think that for the hash iterator it might actually be simpler.
> 
> My solution to making 'break' work in the iterator is:
> 
> 	for (bkt = 0, node = NULL; bkt < HASH_SIZE(name) && node == NULL; bkt++)
> 		hlist_for_each_entry(obj, node, &name[bkt], member)
> 
> We initialize our node loop cursor with NULL in the external loop, and the
> external loop will have a new condition to loop while that cursor is NULL.
> 
> My logic is that we can only 'break' when we are iterating over an object in the
> internal loop. If we're iterating over an object in that loop then 'node != NULL'.
> 
> This way, if we broke from within the internal loop, the external loop will see
> node as not NULL, and so it will stop looping itself. On the other hand, if the
> internal loop has actually ended, then node will be NULL, and the outer loop
> will keep running.
> 
> Is there anything I've missed?

This sounds good. Unless I'm missing something too.

Thanks!

Mathieu

> 
> 
> Thanks,
> Sasha

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
