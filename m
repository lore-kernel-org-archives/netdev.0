From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Wed, 1 Nov 2017 09:27:14 -0700
Message-ID: <20171101162712.inf4ejbxmfm2kzie@ast-mbp>
References: <20171101181554.1826e8c8@canb.auug.org.au>
 <20171101081832.zdehp7ysi5ecwsdv@hirez.programming.kicks-ass.net>
 <20171101082742.dteg337holmodzn2@gmail.com>
 <20171101085524.4dcxgaq7kawn37pq@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Yonghong Song <yhs@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171101085524.4dcxgaq7kawn37pq@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 01, 2017 at 09:55:24AM +0100, Peter Zijlstra wrote:
> On Wed, Nov 01, 2017 at 09:27:43AM +0100, Ingo Molnar wrote:
> > 
> > * Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > On Wed, Nov 01, 2017 at 06:15:54PM +1100, Stephen Rothwell wrote:
> > > > Hi all,
> > > > 
> > > > Today's linux-next merge of the tip tree got a conflict in:
> > > > 
> > > >   kernel/trace/bpf_trace.c
> > > > 
> > > > between commits:
> > > > 
> > > >   97562633bcba ("bpf: perf event change needed for subsequent bpf helpers")
> > > > and more changes ...
> > > > 
> > > > from the net-next tree and commit:
> > > > 
> > > >   7d9285e82db5 ("perf/bpf: Extend the perf_event_read_local() interface, a.k.a. "bpf: perf event change needed for subsequent bpf helpers"")
> > > > 
> > > > from the tip tree.
> > > 
> > > So those should be the exact same patch; except for Changelog and
> > > subject. Code wise there shouldn't be a conflict.
> > 
> > So the problem is that then we have:
> > 
> >   0d3d73aac2ff ("perf/core: Rewrite event timekeeping")
> > 
> > which changes the code. This is a known conflict generation pattern: Git isn't 
> > smart enough to sort out that (probably because it would make merges too 
> > expensive) - and it's a bad flow in any case.
> 
> Hmm, I thought having that same base patch in both trees would allow it
> to resolve that conflict. A well..

sigh. I had the same impression.
In the past the same patch was applied to both tip and net-next
and there were no conflicts.
May be git could have been smarter if you kept the same
one line commit description as we have in net-next?

Will it help if we push the same ("perf/core: Rewrite event timekeeping") commit
into net-next ? They will be in different order, so it probably
won't help and only make things worse. That sucks.

I think we need to discuss what should be our apporach moving
forward to commits that affect tracing and networking at the same time.
I don't think pushing to only one tree is an option, since it will be
close to impossible to resolve such conflicts at merge window time.
Linus would need to do some major surgery to untangle the mess.
I think it's still the best to push to both trees and expect
such mini-conflicts to appear in linux-next.
Like this time it was pretty obvious that commits are the same
and no real action necessary.

Also what do you mean by "same patch != same commit" ?
Like if we had pushed to some 3rd tree first and then pulled
into tip and net-next it would have been better?
