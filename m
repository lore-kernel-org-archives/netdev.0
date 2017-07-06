From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Thu, 6 Jul 2017 12:49:12 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1707061247070.1581-100000@iolanthe.rowland.org>
References: <20170706162412.GE2393@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Zijlstra <peterz@infradead.org>,
        David Laight <David.Laight@ACULAB.COM>,
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
        "parri.andrea@gmail.com" <parri.andrea@gmail.com>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170706162412.GE2393@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 6 Jul 2017, Paul E. McKenney wrote:

> On Thu, Jul 06, 2017 at 06:10:47PM +0200, Peter Zijlstra wrote:
> > On Thu, Jul 06, 2017 at 08:21:10AM -0700, Paul E. McKenney wrote:
> > > And yes, there are architecture-specific optimizations for an
> > > empty spin_lock()/spin_unlock() critical section, and the current
> > > arch_spin_unlock_wait() implementations show some of these optimizations.
> > > But I expect that performance benefits would need to be demonstrated at
> > > the system level.
> > 
> > I do in fact contended there are any optimizations for the exact
> > lock+unlock semantics.
> 
> You lost me on this one.
> 
> > The current spin_unlock_wait() is weaker. Most notably it will not (with
> > exception of ARM64/PPC for other reasons) cause waits on other CPUs.
> 
> Agreed, weaker semantics allow more optimizations.  So use cases needing
> only the weaker semantics should more readily show performance benefits.
> But either way, we need compelling use cases, and I do not believe that
> any of the existing spin_unlock_wait() calls are compelling.  Perhaps I
> am confused, but I am not seeing it for any of them.

If somebody really wants the full spin_unlock_wait semantics and
doesn't want to interfere with other CPUs, wouldn't synchronize_sched()
or something similar do the job?  It wouldn't be as efficient as
lock+unlock, but it also wouldn't affect other CPUs.

Alan Stern
