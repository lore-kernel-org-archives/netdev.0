From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH RFC] v1 expedited "big hammer" RCU grace periods
Date: Thu, 23 Apr 2009 09:54:36 +0200
Message-ID: <20090423075436.GB22606@elte.hu>
References: <20090423052520.GA13036@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090423052520.GA13036@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> First cut of "big hammer" expedited RCU grace periods, but only 
> for rcu_bh.  This creates another softirq vector, so that entering 
> this softirq vector will have forced an rcu_bh quiescent state (as 
> noted by Dave Miller).  Use smp_call_function() to invoke 
> raise_softirq() on all CPUs in order to cause this to happen.  
> Track the CPUs that have passed through a quiescent state (or gone 
> offline) with a cpumask.
> 
> Does nothing to expedite callbacks already registered with 
> call_rcu_bh(), but there is no need to.
> 
> Shortcomings:
> 
> o	Untested, probably does not compile, not for inclusion.
> 
> o	Does not handle rcu, only rcu_bh.
> 
> Thoughts?

I'm wondering, why not just do a two-liner, along the lines of:

	for_each_online_cpu(cpu)
		smp_send_reschedule(cpu);

That should trigger a quiescent state on all online cpus. It wont 
perturb the scheduler state (which is reschedule-IPI invariant).
(And this is a big-hammer approach anyway so even if it did we 
wouldnt care.)

Am i missing something embarrasingly obvious perhaps?

	Ingo
