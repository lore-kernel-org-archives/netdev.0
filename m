From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH] tags: Fix DEFINE_PER_CPU expansions
Date: Tue, 1 Mar 2016 22:34:44 +0100
Message-ID: <20160301213444.GZ6357@twins.programming.kicks-ass.net>
References: <20160301102625.GQ6357@twins.programming.kicks-ass.net>
 <20160301165650.GN3577@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, rjw@rjwysocki.net,
	konrad.wilk@oracle.com, Ingo Molnar <mingo@kernel.org>,
	tj@kernel.org, davem@davemloft.net, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160301165650.GN3577@linux.vnet.ibm.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 01, 2016 at 08:56:50AM -0800, Paul E. McKenney wrote:
> +++ b/kernel/rcu/rcutorture.c
> @@ -131,9 +131,9 @@ static unsigned long rcu_torture_current_version;
>  static struct rcu_torture rcu_tortures[10 * RCU_TORTURE_PIPE_LEN];
>  static DEFINE_SPINLOCK(rcu_torture_lock);
>  static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
> -		      rcu_torture_count) = { 0 };
> +		      rcu_torture_count);

So the problem I was fixing is that the ctags regex needs the second
argument for the DEFINE_PER_CPU() macro on the same line.

So it would still need to be:

static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1], rcu_torture_count);

>  static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
> -		      rcu_torture_batch) = { 0 };
> +		      rcu_torture_batch);
>  static atomic_t rcu_torture_wcount[RCU_TORTURE_PIPE_LEN + 1];
>  static atomic_t n_rcu_torture_alloc;
>  static atomic_t n_rcu_torture_alloc_fail;
> 
