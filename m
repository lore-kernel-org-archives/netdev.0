From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Thu, 6 Jul 2017 10:18:32 -0700
Message-ID: <20170706171832.GH2393@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
 <20170706160555.xc63yydk77gmttae@hirez.programming.kicks-ass.net>
 <20170706162024.GD2393@linux.vnet.ibm.com>
 <20170706165036.v4u5rbz56si4emw5@hirez.programming.kicks-ass.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "dave@stgolabs.net" <dave@stgolabs.net>,
        "manfred@colorfullife.com" <manfred@colorfullife.com>,
        "tj@kernel.org" <tj@kernel.org>, "arnd@arndb.de" <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "stern@rowland.harvard.edu" <stern@rowland.harvard.edu>,
        "parri.andrea@gmail.com" <parri.andrea@gmail.com>,
        "torvalds@linux-foundation.org" <torvalds@linux-founda
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170706165036.v4u5rbz56si4emw5@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 06, 2017 at 06:50:36PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 06, 2017 at 09:20:24AM -0700, Paul E. McKenney wrote:
> > On Thu, Jul 06, 2017 at 06:05:55PM +0200, Peter Zijlstra wrote:
> > > On Thu, Jul 06, 2017 at 02:12:24PM +0000, David Laight wrote:
> > > > From: Paul E. McKenney
> > 
> > [ . . . ]
> > 
> > > Now on the one hand I feel like Oleg that it would be a shame to loose
> > > the optimization, OTOH this thing is really really tricky to use,
> > > and has lead to a number of bugs already.
> > 
> > I do agree, it is a bit sad to see these optimizations go.  So, should
> > this make mainline, I will be tagging the commits that spin_unlock_wait()
> > so that they can be easily reverted should someone come up with good
> > semantics and a compelling use case with compelling performance benefits.
> 
> Ha!, but what would constitute 'good semantics' ?

At this point, it beats the heck out of me!  ;-)

> The current thing is something along the lines of:
> 
>   "Waits for the currently observed critical section
>    to complete with ACQUIRE ordering such that it will observe
>    whatever state was left by said critical section."
> 
> With the 'obvious' benefit of limited interference on those actually
> wanting to acquire the lock, and a shorter wait time on our side too,
> since we only need to wait for completion of the current section, and
> not for however many contender are before us.
> 
> Not sure I have an actual (micro) benchmark that shows a difference
> though.
> 
> 
> 
> Is this all good enough to retain the thing, I dunno. Like I said, I'm
> conflicted on the whole thing. On the one hand its a nice optimization,
> on the other hand I don't want to have to keep fixing these bugs.

Yeah, if I had seen a compelling use case...  Oleg's task_work case was
closest, but given that it involved a task-local lock that shouldn't
be all -that- heavily contended, it is hard to see there being all that
much difference.

But maybe I am missing something here?  Wouldn't be the first time...

							Thanx, Paul
