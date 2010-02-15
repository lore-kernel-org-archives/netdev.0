From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH tip/core/rcu 05/13] net: add checking to
 rcu_dereference() primitives
Date: Sun, 14 Feb 2010 23:18:27 -0800 (PST)
Message-ID: <20100214.231827.257182182.davem@davemloft.net>
References: <1265932839-25899-5-git-send-email-paulmck@linux.vnet.ibm.com>
	<1265948152.2891.25.camel@edumazet-laptop>
	<20100214082314.GA12658@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, paulmck@linux.vnet.ibm.com,
	linux-kernel@vger.kernel.org, laijs@cn.fujitsu.com,
	dipankar@in.ibm.com, akpm@linux-foundation.org,
	mathieu.desnoyers@polymtl.ca, josh@joshtriplett.org,
	dvhltc@us.ibm.com, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, Valdis.Kletnieks@vt.edu,
	dhowells@redhat.com, netdev@vger.kernel.org
To: mingo@elte.hu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100214082314.GA12658@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Sun, 14 Feb 2010 09:23:14 +0100

> 
> * Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> Le jeudi 11 f??vrier 2010 ?? 16:00 -0800, Paul E. McKenney a ??crit :
>> > Update rcu_dereference() primitives to use new lockdep-based checking.
>> > The rcu_dereference() in __in6_dev_get() may be protected either by
>> > rcu_read_lock() or RTNL, per Eric Dumazet.  The rcu_dereference()
>> > in __sk_free() is protected by the fact that it is never reached if an
>> > update could change it.  Check for this by using rcu_dereference_check()
>> > to verify that the struct sock's ->sk_wmem_alloc counter is zero.
>> > 
>> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>> 
>> CC to netdev and David Miller, network maintainer.
>> 
>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>> 
>> Thanks Paul, great work !
> 
> Dave, does this look good to you too? Cannot pick up the rest of the patchset 
> without these checks/annotations into the RCU tree as there's too many 
> warnings triggering in the networking code. So it's an all-or-nothing 
> patchset in that regard.

Looks good:

Acked-by: David S. Miller <davem@davemloft.net>
