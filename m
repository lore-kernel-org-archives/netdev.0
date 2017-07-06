From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Thu, 6 Jul 2017 18:41:34 +0200
Message-ID: <20170706164134.6a54adwcdvjx6ouc@hirez.programming.kicks-ass.net>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
 <20170706152110.GZ2393@linux.vnet.ibm.com>
 <20170706161047.nse2s4gquljv5bni@hirez.programming.kicks-ass.net>
 <20170706162412.GE2393@linux.vnet.ibm.com>
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
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170706162412.GE2393@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 06, 2017 at 09:24:12AM -0700, Paul E. McKenney wrote:
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

For the exact semantics you'd have to fully participate in the fairness
protocol. You have to in fact acquire the lock in order to have the
other contending CPUs wait (otherwise my earlier case 3 will fail).

At that point I'm not sure there is much actual code you can leave out.

What actual optimization is there left at that point?
