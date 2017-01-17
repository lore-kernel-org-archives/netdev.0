From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Tue, 17 Jan 2017 14:58:30 +0100
Message-ID: <20170117135830.GO19699@dhcp22.suse.cz>
References: <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com>
 <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <2dbec775-6304-e44c-19c5-fbf07877e7b1@gmail.com>
 <CALCETrUW2jEYmjSsOrPj+MAjkDGGUCw_rdxQh+5Er0r4ReGLnA@mail.gmail.com>
 <20161220091150.GJ3124@twins.programming.kicks-ass.net>
 <20170103102559.GA30129@dhcp22.suse.cz>
 <20170116011901.GH14446@mtj.duckdns.org>
 <20170117130303.GL19699@dhcp22.suse.cz>
 <20170117133204.GA6515@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, Andy Lutomirski <luto@amacapital.net>,
        David Ahern <dsahern@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        Daniel Mack <daniel@zonque.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170117133204.GA6515@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 17-01-17 14:32:04, Peter Zijlstra wrote:
> On Tue, Jan 17, 2017 at 02:03:03PM +0100, Michal Hocko wrote:
> > On Sun 15-01-17 20:19:01, Tejun Heo wrote:
> > [...]
> > > So, what's proposed is a proper part of bpf.  In terms of
> > > implementation, cgroup helps by hosting the pointers but that doesn't
> > > necessarily affect the conceptual structure of it.  Given that, I
> > > don't think it'd be a good idea to add anything to cgroup interface
> > > for this feature.  Introspection is great to have but this should be
> > > introspectable together with other bpf programs using the same
> > > mechanism.  That's where it belongs.
> > 
> > If BPF only piggy backs on top of cgroup to iterate tasks shouldn't we
> > at least enforce that the cgroup has to be a leaf one and no further
> > children groups can be created once there is BPF program attached?
> 
> Why (again) this stupid constraint?
> 
> If you want to use cgroups for tagging (like perf does), _any_ parent
> cgroup will also tag you.
> 
> So creating child cgroups, and placing tasks in it, should not be a
> problem, the BPF thing should apply to all of them.

This would require using hierarchical cgroup iterators to iterate over
tasks. As per Andy's testing this doesn't seem to be the case. I haven't
checked the implementation closely but my understanding was that using
only cgroup specific tasks was intentional.

I do agree that using hierarchy aware cgroup iterators is the right
approach here and we wouldn't see any issue. But I am still not sure
I've wrapped my head around this feature completely.

-- 
Michal Hocko
SUSE Labs
