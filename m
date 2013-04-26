From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when
 dumping connections
Date: Fri, 26 Apr 2013 11:26:55 -0700
Message-ID: <1367000815.8964.243.camel@edumazet-glaptop>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>
	 <1366940708-10180-3-git-send-email-horms@verge.net.au>
	 <20130426080313.GC8669@dyad.programming.kicks-ass.net>
	 <20130426154547.GC3860@linux.vnet.ibm.com>
	 <20130426171948.GA31467@dyad.programming.kicks-ass.net>
	 <20130426174815.GI3860@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Dipankar Sarma <dipankar@in.ibm.com>, dhaval.giani@gmail.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130426174815.GI3860@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-04-26 at 10:48 -0700, Paul E. McKenney wrote:

> Don't get me wrong, I am not opposing cond_resched_rcu_lock() because it
> will be difficult to validate.  For one thing, until there are a lot of
> them, manual inspection is quite possible.  So feel free to apply my
> Acked-by to the patch.

One question : If some thread(s) is(are) calling rcu_barrier() and
waiting we exit from rcu_read_lock() section, is need_resched() enough
for allowing to break the section ?

If not, maybe we should not test need_resched() at all.

rcu_read_unlock();
cond_resched();
rcu_read_lock();



