From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] tags: Fix DEFINE_PER_CPU expansions
Date: Tue, 1 Mar 2016 14:01:09 -0800
Message-ID: <20160301220109.GS3577@linux.vnet.ibm.com>
References: <20160301102625.GQ6357@twins.programming.kicks-ass.net>
 <20160301165650.GN3577@linux.vnet.ibm.com>
 <20160301213444.GZ6357@twins.programming.kicks-ass.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, rjw@rjwysocki.net,
	konrad.wilk@oracle.com, Ingo Molnar <mingo@kernel.org>,
	tj@kernel.org, davem@davemloft.net, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160301213444.GZ6357@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 01, 2016 at 10:34:44PM +0100, Peter Zijlstra wrote:
> On Tue, Mar 01, 2016 at 08:56:50AM -0800, Paul E. McKenney wrote:
> > +++ b/kernel/rcu/rcutorture.c
> > @@ -131,9 +131,9 @@ static unsigned long rcu_torture_current_version;
> >  static struct rcu_torture rcu_tortures[10 * RCU_TORTURE_PIPE_LEN];
> >  static DEFINE_SPINLOCK(rcu_torture_lock);
> >  static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
> > -		      rcu_torture_count) = { 0 };
> > +		      rcu_torture_count);
> 
> So the problem I was fixing is that the ctags regex needs the second
> argument for the DEFINE_PER_CPU() macro on the same line.
> 
> So it would still need to be:
> 
> static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1], rcu_torture_count);
> 
> >  static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
> > -		      rcu_torture_batch) = { 0 };
> > +		      rcu_torture_batch);
> >  static atomic_t rcu_torture_wcount[RCU_TORTURE_PIPE_LEN + 1];
> >  static atomic_t n_rcu_torture_alloc;
> >  static atomic_t n_rcu_torture_alloc_fail;

Ah, like this, then.

							Thanx, Paul

------------------------------------------------------------------------

commit 55d4929acdc66f00f27d79bfe273eeda01ec899f
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Tue Mar 1 08:52:19 2016 -0800

    rcutorture: Remove redundant initialization to zero
    
    The current code initializes the global per-CPU variables
    rcu_torture_count and rcu_torture_batch to zero.  However, C does this
    initialization by default, and explicit initialization of per-CPU
    variables now needs a different syntax if "make tags" is to work.
    This commit therefore removes the initialization.
    
    Reported-by: Peter Zijlstra <peterz@infradead.org>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/kernel/rcu/rcutorture.c b/kernel/rcu/rcutorture.c
index 1c2dc23ae07d..e75557368c04 100644
--- a/kernel/rcu/rcutorture.c
+++ b/kernel/rcu/rcutorture.c
@@ -130,10 +130,8 @@ static struct rcu_torture __rcu *rcu_torture_current;
 static unsigned long rcu_torture_current_version;
 static struct rcu_torture rcu_tortures[10 * RCU_TORTURE_PIPE_LEN];
 static DEFINE_SPINLOCK(rcu_torture_lock);
-static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
-		      rcu_torture_count) = { 0 };
-static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
-		      rcu_torture_batch) = { 0 };
+static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1], rcu_torture_count);
+static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1], rcu_torture_batch);
 static atomic_t rcu_torture_wcount[RCU_TORTURE_PIPE_LEN + 1];
 static atomic_t n_rcu_torture_alloc;
 static atomic_t n_rcu_torture_alloc_fail;
