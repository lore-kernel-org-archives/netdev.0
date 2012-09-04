From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and
 naive hashtable
Date: Tue, 04 Sep 2012 16:59:05 -0400
Message-ID: <1346792345.27919.18.camel@gandalf.local.home>
References: <20120824203332.GF21325@google.com> <5037E9D9.9000605@gmail.com>
	<20120824212348.GK21325@google.com> <5038074D.300@gmail.com>
	<20120824230740.GN21325@google.com> <20120825042419.GA27240@Krystal>
	<503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal>
	<503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal>
	<20120828230050.GA3337@Krystal>
	<1346772948.27919.9.camel@gandalf.local.home>
	<50462C99.5000007@redhat.com>  <50462EE8.1090903@redhat.com>
	<1346779027.27919.15.camel@gandalf.local.home>
	<50463883.8080706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org,
	Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Pedro Alves <palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <50463883.8080706-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Tue, 2012-09-04 at 18:21 +0100, Pedro Alves wrote:
> On 09/04/2012 06:17 PM, Steven Rostedt wrote:
> > On Tue, 2012-09-04 at 17:40 +0100, Pedro Alves wrote:
> > 
> >> BTW, you can also go a step further and remove the need to close with double }},
> >> with something like:
> >>
> >> #define do_for_each_ftrace_rec(pg, rec)                                          \
> >>         for (pg = ftrace_pages_start, rec = &pg->records[pg->index];             \
> >>              pg && rec == &pg->records[pg->index];                               \
> >>              pg = pg->next)                                                      \
> >>           for (rec = pg->records; rec < &pg->records[pg->index]; rec++)
> >>
> > 
> > Yeah, but why bother? It's hidden in a macro, and the extra '{ }' shows
> > that this is something "special".
> 
> The point of both changes is that there's nothing special in the end
> at all.  It all just works...
> 

It would still fail on a 'break'. The 'while' macro tells us that it is
special, because in the end, it wont work.

-- Steve
