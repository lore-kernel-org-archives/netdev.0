From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and
	naive	hashtable
Date: Tue, 4 Sep 2012 13:01:38 -0400
Message-ID: <20120904170138.GB31934@Krystal>
References: <20120824230740.GN21325@google.com>
	<20120825042419.GA27240@Krystal> <503C95E4.3010000@gmail.com>
	<20120828101148.GA21683@Krystal> <503CAB1E.5010408@gmail.com>
	<20120828115638.GC23818@Krystal> <20120828230050.GA3337@Krystal>
	<1346772948.27919.9.camel@gandalf.local.home>
	<50462C99.5000007@redhat.com> <50462EE8.1090903@redhat.com>
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
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Pedro Alves <palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50462EE8.1090903-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

* Pedro Alves (palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org) wrote:
> On 09/04/2012 05:30 PM, Pedro Alves wrote:
> > On 09/04/2012 04:35 PM, Steven Rostedt wrote:
> >> On Tue, 2012-08-28 at 19:00 -0400, Mathieu Desnoyers wrote:
> >>
> >>> Looking again at:
> >>>
> >>> +#define hash_for_each_size(name, bits, bkt, node, obj, member)                 \
> >>> +       for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)                             \
> >>> +               hlist_for_each_entry(obj, node, &name[bkt], member)
> >>>
> >>> you will notice that a "break" or "continue" in the inner loop will not
> >>> affect the outer loop, which is certainly not what the programmer would
> >>> expect!
> >>>
> >>> I advise strongly against creating such error-prone construct.
> >>>
> >>
> >> A few existing loop macros do this. But they require a do { } while ()
> >> approach, and all have a comment.
> >>
> >> It's used by do_each_thread() in sched.h and ftrace does this as well.
> >> Look at kernel/trace/ftrace.c at do_for_each_ftrace_rec().
> >>
> >> Yes it breaks 'break' but it does not break 'continue' as it would just
> >> go to the next item that would have been found (like a normal for
> >> would).
> > 
> > /*
> >  * This is a double for. Do not use 'break' to break out of the loop,
> >  * you must use a goto.
> >  */
> > #define do_for_each_ftrace_rec(pg, rec)                                 \
> >         for (pg = ftrace_pages_start; pg; pg = pg->next) {              \
> >                 int _____i;                                             \
> >                 for (_____i = 0; _____i < pg->index; _____i++) {        \
> >                         rec = &pg->records[_____i];
> > 
> > 
> > 
> > You can make 'break' also work as expected if you can embed a little knowledge
> > of the inner loop's condition in the outer loop's condition.  Sometimes it's
> > trivial, most often when the inner loop's iterator is a pointer that goes
> > NULL at the end, but other times not so much.  Something like (completely untested):
> > 
> > #define do_for_each_ftrace_rec(pg, rec)                                 \
> >         for (pg = ftrace_pages_start, rec = &pg->records[pg->index];    \
> >              pg && rec == &pg->records[pg->index];                      \
> >              pg = pg->next) {                                           \
> >                 int _____i;                                             \
> >                 for (_____i = 0; _____i < pg->index; _____i++) {        \
> >                         rec = &pg->records[_____i];
> >
> > 
> > (other variants possible)
> > 
> > IOW, the outer loop only iterates if the inner loop completes.  If there's
> > a break in the inner loop, then the outer loop breaks too.  Of course, it
> > all depends on whether the generated code looks sane or hideous, if
> > the uses of the macro care for it over bug avoidance.
> > 
> 
> BTW, you can also go a step further and remove the need to close with double }},
> with something like:
> 
> #define do_for_each_ftrace_rec(pg, rec)                                          \
>         for (pg = ftrace_pages_start, rec = &pg->records[pg->index];             \
>              pg && rec == &pg->records[pg->index];                               \
>              pg = pg->next)                                                      \
>           for (rec = pg->records; rec < &pg->records[pg->index]; rec++)

Maybe in some cases there might be ways to combine the two loops into
one ? I'm not seeing exactly how to do it for this one, but it should
not be impossible. If the inner loop condition can be moved to the outer
loop, and if we use (blah ? loop1_conf : loop2_cond) to test for
different conditions depending on the context, and do the same for the
3rd argument of the for() loop. The details elude me for now though, so
maybe it's complete non-sense ;)

It might not be that useful for do_for_each_ftrace_rec, but if we can do
it for the hash table iterator, it might be worth it.

Thanks,

Mathieu


-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
