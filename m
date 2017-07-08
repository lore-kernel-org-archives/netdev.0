From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Sat, 8 Jul 2017 10:35:43 +0200
Message-ID: <20170708083543.tnr7yyhojmyiluw4@gmail.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
 <20170706160555.xc63yydk77gmttae@hirez.programming.kicks-ass.net>
 <20170706162024.GD2393@linux.vnet.ibm.com>
 <20170706165036.v4u5rbz56si4emw5@hirez.programming.kicks-ass.net>
 <20170707083128.wqk6msuuhtyykhpu@gmail.com>
 <48164d9a-f291-94f3-e0b1-98bb312bf846@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "dave@stgolabs.net" <dave@stgolabs.net>,
        "tj@kernel.org" <tj@kernel.org>, "arnd@arndb.de" <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "stern@rowland.harvard.edu" <stern@rowland.harvard.edu>,
        "parri.andrea@gmail.com" <parri.andrea@gmail.com>,
        "torvalds@lin
To: Manfred Spraul <manfred@colorfullife.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48164d9a-f291-94f3-e0b1-98bb312bf846@colorfullife.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Manfred Spraul <manfred@colorfullife.com> wrote:

> Hi Ingo,
> 
> On 07/07/2017 10:31 AM, Ingo Molnar wrote:
> > 
> > There's another, probably just as significant advantage: queued_spin_unlock_wait()
> > is 'read-only', while spin_lock()+spin_unlock() dirties the lock cache line. On
> > any bigger system this should make a very measurable difference - if
> > spin_unlock_wait() is ever used in a performance critical code path.
> At least for ipc/sem:
> Dirtying the cacheline (in the slow path) allows to remove a smp_mb() in the
> hot path.
> So for sem_lock(), I either need a primitive that dirties the cacheline or
> sem_lock() must continue to use spin_lock()/spin_unlock().

Technically you could use spin_trylock()+spin_unlock() and avoid the lock acquire 
spinning on spin_unlock() and get very close to the slow path performance of a 
pure cacheline-dirtying behavior.

But adding something like spin_barrier(), which purely dirties the lock cacheline, 
would be even faster, right?

Thanks,

	Ingo
