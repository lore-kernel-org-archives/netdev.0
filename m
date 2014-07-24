From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: net, phonet, rcu: rcu hang within gprs_attach
Date: Thu, 24 Jul 2014 15:54:31 -0700
Message-ID: <20140724225431.GW11241@linux.vnet.ibm.com>
References: <53D1865F.7040604@oracle.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, courmisch@gmail.com,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:45553 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756093AbaGXWyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 18:54:37 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 24 Jul 2014 16:54:36 -0600
Content-Disposition: inline
In-Reply-To: <53D1865F.7040604@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2014 at 06:19:11PM -0400, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel I've stumbled on the following stack trace (full log attached):
> 
> [  370.662014] INFO: task trinity-main:8727 blocked for more than 120 seconds.
> [  370.662891]       Not tainted 3.16.0-rc6-next-20140724-sasha-00046-g7324c87-dirty #932
> [  370.663655] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  370.664562] trinity-main    D ffff88053cc80000 13064  8727   8714 0x00000000
> [  370.665328]  ffff88053da6fc10 0000000000000002 ffff8805483e2dc8 ffff880541873000
> [  370.666147]  000000276ed30787 ffff88053da6c010 ffff88053da6c000 ffff8805452a0000
> [  370.667243]  ffff880541873000 0000000000000000 7fffffffffffffff ffffffffb3ec51d8
> [  370.668788] Call Trace:
> [  370.669118] schedule (kernel/sched/core.c:2847)
> [  370.670538] schedule_timeout (kernel/time/timer.c:1476)
> [  370.671524] ? mark_lock (kernel/locking/lockdep.c:2894)
> [  370.672299] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [  370.673227] ? get_parent_ip (kernel/sched/core.c:2561)
> [  370.674085] wait_for_completion (include/linux/spinlock.h:328 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
> [  370.674960] ? wake_up_state (kernel/sched/core.c:2942)
> [  370.675576] _rcu_barrier (kernel/rcu/tree.c:3325 (discriminator 8))
> [  370.676109] rcu_barrier (kernel/rcu/tree_plugin.h:920)
> [  370.676627] netdev_run_todo (net/core/dev.c:6323)
> [  370.677202] rtnl_unlock (net/core/rtnetlink.c:80)
> [  370.677714] unregister_netdev (net/core/dev.c:6687)
> [  370.678266] gprs_attach (net/phonet/pep-gprs.c:311)
> [  370.679641] pep_setsockopt (net/phonet/pep.c:1016)
> [  370.681082] sock_common_setsockopt (net/core/sock.c:2603)
> [  370.682048] SyS_setsockopt (net/socket.c:1914 net/socket.c:1894)
> [  370.682854] tracesys (arch/x86/kernel/entry_64.S:541)
> [  370.683586] 1 lock held by trinity-main/8727:
> [  370.684232] #0: (rcu_preempt_state.barrier_mutex){+.+...}, at: _rcu_barrier (kernel/rcu/tree.c:3233)
> 
> This has reproduced couple of times, and has always originated from gprs_attach. I don't see any obvious
> issues with the code there, so I'm not sure if it's a fault of the phonet or the rcu code.

Can't tell much from this.  Any chance of a .config?

							Thanx, Paul
