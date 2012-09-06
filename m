From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
	hashtable
Date: Thu, 6 Sep 2012 13:02:36 -0400
Message-ID: <20120906170236.GA7846@Krystal>
References: <50462C99.5000007@redhat.com> <50462EE8.1090903@redhat.com> <20120904170138.GB31934@Krystal> <5048AAF6.5090101@gmail.com> <20120906145545.GA17332@leaf> <5048C615.4070204@gmail.com> <1346947206.1680.36.camel@gandalf.local.home> <5048CDA2.10300@gmail.com> <20120906165055.GC7385@Krystal> <5048D6DE.8090805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>,
	Pedro Alves <palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5048D6DE.8090805-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> On 09/06/2012 06:50 PM, Mathieu Desnoyers wrote:
> > * Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> >> On 09/06/2012 06:00 PM, Steven Rostedt wrote:
> >>>>> I think that that code doesn't make sense. The users of hlist_for_each_* aren't
> >>>>> supposed to be changing the loop cursor.
> >>> I totally agree. Modifying the 'node' pointer is just asking for issues.
> >>> Yes that is error prone, but not due to the double loop. It's due to the
> >>> modifying of the node pointer that is used internally by the loop
> >>> counter. Don't do that :-)
> >>
> >> While we're on this subject, I haven't actually seen hlist_for_each_entry() code
> >> that even *touches* 'pos'.
> >>
> >> Will people yell at me loudly if I change the prototype of those macros to be:
> >>
> >> 	hlist_for_each_entry(tpos, head, member)
> >>
> >> (Dropping the 'pos' parameter), and updating anything that calls those macros to
> >> drop it as well?
> > 
> > I think the intent there is to keep hlist macros and list macros
> > slightly in sync. Given those are vastly used, I'm not sure you want to
> > touch them. But hey, that's just my 2 cents.
> 
> Actually, the corresponding list macro looks like this:
> 
> 	list_for_each_entry(pos, head, member)
> 
> With 'pos' being the equivalent of 'tpos' in the hlist macros (the type *).
> Changing hlist macro will make them both look as follows:
> 
> 	hlist_for_each_entry(pos, head, member)
> 	list_for_each_entry(pos, head, member)
> 
> So following this suggesting will actually bring them back to sync...
> 
> The only issue I can see is that as you've said, they're used almost everywhere,
> so doing something to change that will require some coordination.

if this brings hlist and list in sync, then it looks like an
improvement. It might be good to propose this change as a separate
patchset.

Thanks,

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
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
