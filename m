From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] tags: Fix DEFINE_PER_CPU expansions
Date: Tue, 01 Mar 2016 11:36:42 -0500 (EST)
Message-ID: <20160301.113642.1119377555960644780.davem@davemloft.net>
References: <20160301102625.GQ6357@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	rjw@rjwysocki.net, konrad.wilk@oracle.com, mingo@kernel.org,
	paulmck@linux.vnet.ibm.com, tj@kernel.org,
	linux-acpi@vger.kernel.org, netdev@vger.kernel.org
To: peterz@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160301102625.GQ6357@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 1 Mar 2016 11:26:25 +0100

> 
> $ make tags
>   GEN     tags
> ctags: Warning: drivers/acpi/processor_idle.c:64: null expansion of name pattern "\1"
> ctags: Warning: drivers/xen/events/events_2l.c:41: null expansion of name pattern "\1"
> ctags: Warning: kernel/locking/lockdep.c:151: null expansion of name pattern "\1"
> ctags: Warning: kernel/rcu/rcutorture.c:133: null expansion of name pattern "\1"
> ctags: Warning: kernel/rcu/rcutorture.c:135: null expansion of name pattern "\1"
> ctags: Warning: kernel/workqueue.c:323: null expansion of name pattern "\1"
> ctags: Warning: net/ipv4/syncookies.c:53: null expansion of name pattern "\1"
> ctags: Warning: net/ipv6/syncookies.c:44: null expansion of name pattern "\1"
> ctags: Warning: net/rds/page.c:45: null expansion of name pattern "\1"
> 
> Which are all the result of the DEFINE_PER_CPU pattern:
> 
> scripts/tags.sh:200:	'/\<DEFINE_PER_CPU([^,]*, *\([[:alnum:]_]*\)/\1/v/'
> scripts/tags.sh:201:	'/\<DEFINE_PER_CPU_SHARED_ALIGNED([^,]*, *\([[:alnum:]_]*\)/\1/v/'
> 
> The below cures them. All except the workqueue one are within reasonable
> distance of the 80 char limit. TJ do you have any preference on how to
> fix the wq one, or shall we just not care its too long?
> 
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

For the networking bits:

Acked-by: David S. Miller <davem@davemloft.net>
