From: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Tue, 3 Jan 2017 11:25:59 +0100
Message-ID: <20170103102559.GA30129@dhcp22.suse.cz>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com>
 <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <2dbec775-6304-e44c-19c5-fbf07877e7b1@gmail.com>
 <CALCETrUW2jEYmjSsOrPj+MAjkDGGUCw_rdxQh+5Er0r4ReGLnA@mail.gmail.com>
 <20161220091150.GJ3124@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161220091150.GJ3124-ndre7Fmf5hadTX5a5knrm8zTDFooKrT+cvkQGrU6aU0@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue 20-12-16 10:11:50, Peter Zijlstra wrote:
> On Mon, Dec 19, 2016 at 05:56:24PM -0800, Andy Lutomirski wrote:
> > >> Huh?  My example in the original email attaches a program in a
> > >> sub-hierarchy.  Are you saying that 4.11 could make that example stop
> > >> working?
> > >
> > > Are you suggesting sub-cgroups should not be allowed to override the filter of a parent cgroup?
> > 
> > Yes, exactly.  I think there are two sensible behaviors:
> > 
> > a) sub-cgroups cannot have a filter at all of the parent has a filter.
> > (This is the "punt" approach -- it lets different semantics be
> > assigned later without breaking userspace.)
> > 
> > b) sub-cgroups can have a filter if a parent does, too.  The semantics
> > are that the sub-cgroup filter runs first and all side-effects occur.
> > If that filter says "reject" then ancestor filters are skipped.  If
> > that filter says "accept", then the ancestor filter is run and its
> > side-effects happen as well.  (And so on, all the way up to the root.)
> 
> So from what I understand the proposed cgroup is not in fact
> hierarchical at all.
> 
> @TJ, I thought you were enforcing all new cgroups to be properly
> hierarchical, that would very much include this one.

I would be interested in that as well. We have made that mistake in
memcg v1 where hierarchy could be disabled for performance reasons and
that turned out to be major PITA in the end. Why do we want to repeat
the same mistake here?
-- 
Michal Hocko
SUSE Labs
