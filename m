From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Tue, 13 Feb 2007 15:29:06 -0500
Message-ID: <20070213202905.GA26818@gospo.rdu.redhat.com>
References: <200702091623.l19GNiUP006513@fire-2.osdl.org> <20070209133802.01286bbb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	lpiccilli@gelre.com.br,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbXBMU3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 15:29:53 -0500
Content-Disposition: inline
In-Reply-To: <20070209133802.01286bbb.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 09, 2007 at 01:38:02PM -0800, Andrew Morton wrote:
> 
> cond_resched() called from softirq, amongst other problems.
> 
> On Fri, 9 Feb 2007 08:23:44 -0800
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=7974
> > 
> >            Summary: BUG: scheduling while atomic: swapper/0x10000100/0
> >     Kernel Version: 2.6.20
> >             Status: NEW
> >           Severity: normal
> >              Owner: acme@conectiva.com.br
> >          Submitter: lpiccilli@gelre.com.br
> > 
> > 
> > The machine hangs in normal boot with 2.6.19 and 2.6.20 after network starts. If
> > I boot in single mode and start the services manually, the machine and network
> > works fine, but I see this on dmesg:
> > 
> > 
> > Call Trace:
> >  <IRQ>  [<ffffffff802607d0>] __sched_text_start+0x60/0xb27
> >  [<ffffffff8802c8a1>] :tg3:tg3_setup_copper_phy+0x9d9/0xad9
> >  [<ffffffff8026f8d5>] smp_local_timer_interrupt+0x34/0x5b
> >  [<ffffffff8802d6d4>] :tg3:tg3_setup_phy+0xd33/0xe16
> >  [<ffffffff8027f572>] __cond_resched+0x1c/0x44
> >  [<ffffffff802613aa>] cond_resched+0x2e/0x39
> >  [<ffffffff80209f5a>] kmem_cache_alloc+0x14/0x58
> >  [<ffffffff8022df6f>] __alloc_skb+0x36/0x134
> >  [<ffffffff804a4ea7>] rtmsg_ifinfo+0x28/0xa1
> >  [<ffffffff804a4f81>] rtnetlink_event+0x61/0x68
> >  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
> >  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
> >  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
> >  [<ffffffff88019b0c>] :bonding:alb_swap_mac_addr+0x8b/0x15c
> >  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
> >  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
> >  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
> >  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
> >  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
> >  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
> >  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
> >  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
> >  [<ffffffff80268e95>] do_softirq+0x2c/0x87
> >  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
> >  [<ffffffff8025691a>] mwait_idle+0x0/0x45
> >  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
> >  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
> >  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
> >  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> > 
> > RTNL: assertion failed at net/core/fib_rules.c (444)
> > 
> > Call Trace:
> >  <IRQ>  [<ffffffff804a8abb>] fib_rules_event+0x3b/0x120
> >  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
> >  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
> >  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
> >  [<ffffffff88019b0c>] :bonding:alb_swap_mac_addr+0x8b/0x15c
> >  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
> >  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
> >  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
> >  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
> >  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
> >  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
> >  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
> >  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
> >  [<ffffffff80268e95>] do_softirq+0x2c/0x87
> >  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
> >  [<ffffffff8025691a>] mwait_idle+0x0/0x45
> >  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
> >  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
> >  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
> >  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> > 
> > BUG: scheduling while atomic: swapper/0x10000100/0
> > 
> > Call Trace:
> >  <IRQ>  [<ffffffff802607d0>] __sched_text_start+0x60/0xb27
> >  [<ffffffff8026f8d5>] smp_local_timer_interrupt+0x34/0x5b
> >  [<ffffffff8027f572>] __cond_resched+0x1c/0x44
> >  [<ffffffff802613aa>] cond_resched+0x2e/0x39
> >  [<ffffffff80262029>] mutex_lock+0x9/0x18
> >  [<ffffffff8049ea76>] netdev_run_todo+0x16/0x230
> >  [<ffffffff804bcc75>] dst_rcu_free+0x0/0x3f
> >  [<ffffffff804d9c29>] inetdev_event+0x29/0x2d0
> >  [<ffffffff80263138>] _spin_lock_bh+0x9/0x19
> >  [<ffffffff8023d84a>] rt_run_flush+0x92/0xcc
> >  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
> >  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
> >  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
> >  [<ffffffff88019b0c>] :bonding:alb_swap_mac_addr+0x8b/0x15c
> >  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
> >  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
> >  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
> >  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
> >  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
> >  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
> >  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
> >  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
> >  [<ffffffff80268e95>] do_softirq+0x2c/0x87
> >  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
> >  [<ffffffff8025691a>] mwait_idle+0x0/0x45
> >  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
> >  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
> >  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
> >  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> > 
> > RTNL: assertion failed at net/ipv4/devinet.c (1055)
> > 
> > Call Trace:
> >  <IRQ>  [<ffffffff804d9c48>] inetdev_event+0x48/0x2d0
> >  [<ffffffff80263138>] _spin_lock_bh+0x9/0x19
> >  [<ffffffff8023d84a>] rt_run_flush+0x92/0xcc
> >  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
> >  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
> >  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
> >  [<ffffffff88019b0c>] :bonding:alb_swap_mac_addr+0x8b/0x15c
> >  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
> >  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
> >  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
> >  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
> >  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
> >  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
> >  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
> >  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
> >  [<ffffffff80268e95>] do_softirq+0x2c/0x87
> >  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
> >  [<ffffffff8025691a>] mwait_idle+0x0/0x45
> >  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
> >  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
> >  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
> >  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> > 
> > BUG: scheduling while atomic: swapper/0x10000100/0
> > 
> > Call Trace:
> >  <IRQ>  [<ffffffff802607d0>] __sched_text_start+0x60/0xb27
> >  [<ffffffff8802c8a1>] :tg3:tg3_setup_copper_phy+0x9d9/0xad9
> >  [<ffffffff8026f8d5>] smp_local_timer_interrupt+0x34/0x5b
> >  [<ffffffff8802d6d4>] :tg3:tg3_setup_phy+0xd33/0xe16
> >  [<ffffffff8027f572>] __cond_resched+0x1c/0x44
> >  [<ffffffff802613aa>] cond_resched+0x2e/0x39
> >  [<ffffffff80209f5a>] kmem_cache_alloc+0x14/0x58
> >  [<ffffffff8022df6f>] __alloc_skb+0x36/0x134
> >  [<ffffffff804a4ea7>] rtmsg_ifinfo+0x28/0xa1
> >  [<ffffffff804a4f81>] rtnetlink_event+0x61/0x68
> >  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
> >  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
> >  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
> >  [<ffffffff88019b1e>] :bonding:alb_swap_mac_addr+0x9d/0x15c
> >  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
> >  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
> >  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
> >  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
> >  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
> >  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
> >  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
> >  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
> >  [<ffffffff80268e95>] do_softirq+0x2c/0x87
> >  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
> >  [<ffffffff8025691a>] mwait_idle+0x0/0x45
> >  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
> >  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
> >  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
> >  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> > 
> > RTNL: assertion failed at net/core/fib_rules.c (444)
> > 
> > Call Trace:
> >  <IRQ>  [<ffffffff804a8abb>] fib_rules_event+0x3b/0x120
> >  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
> >  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
> >  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
> >  [<ffffffff88019b1e>] :bonding:alb_swap_mac_addr+0x9d/0x15c
> >  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
> >  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
> >  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
> >  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
> >  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
> >  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
> >  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
> >  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
> >  [<ffffffff80268e95>] do_softirq+0x2c/0x87
> >  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
> >  [<ffffffff8025691a>] mwait_idle+0x0/0x45
> >  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
> >  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
> >  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
> >  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> > 
> > BUG: scheduling while atomic: swapper/0x10000100/0
> > 
> > Call Trace:
> >  <IRQ>  [<ffffffff802607d0>] __sched_text_start+0x60/0xb27
> >  [<ffffffff8026f8d5>] smp_local_timer_interrupt+0x34/0x5b
> >  [<ffffffff8027f572>] __cond_resched+0x1c/0x44
> >  [<ffffffff802613aa>] cond_resched+0x2e/0x39
> >  [<ffffffff80262029>] mutex_lock+0x9/0x18
> >  [<ffffffff8049ea76>] netdev_run_todo+0x16/0x230
> >  [<ffffffff804bcc75>] dst_rcu_free+0x0/0x3f
> >  [<ffffffff804d9c29>] inetdev_event+0x29/0x2d0
> >  [<ffffffff80263138>] _spin_lock_bh+0x9/0x19
> >  [<ffffffff8023d84a>] rt_run_flush+0x92/0xcc
> >  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
> >  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
> >  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
> >  [<ffffffff88019b1e>] :bonding:alb_swap_mac_addr+0x9d/0x15c
> >  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
> >  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
> >  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
> >  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
> >  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
> >  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
> >  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
> >  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
> >  [<ffffffff80268e95>] do_softirq+0x2c/0x87
> >  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
> >  [<ffffffff8025691a>] mwait_idle+0x0/0x45
> >  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
> >  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
> >  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
> >  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> > 
> > RTNL: assertion failed at net/ipv4/devinet.c (1055)
> > 
> > Call Trace:
> >  <IRQ>  [<ffffffff804d9c48>] inetdev_event+0x48/0x2d0
> >  [<ffffffff80263138>] _spin_lock_bh+0x9/0x19
> >  [<ffffffff8023d84a>] rt_run_flush+0x92/0xcc
> >  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
> >  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
> >  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
> >  [<ffffffff88019b1e>] :bonding:alb_swap_mac_addr+0x9d/0x15c
> >  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
> >  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
> >  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
> >  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
> >  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
> >  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
> >  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
> >  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
> >  [<ffffffff80268e95>] do_softirq+0x2c/0x87
> >  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
> >  [<ffffffff8025691a>] mwait_idle+0x0/0x45
> >  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
> >  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
> >  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
> >  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> > 
> > bonding: bond0: first active interface up!
> > NET: Registered protocol family 10
> > lo: Disabled Privacy Extensions
> > ADDRCONF(NETDEV_UP): eth1: link is not ready
> > bond0: no IPv6 routers present
> > eth0: no IPv6 routers present
> > Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> > NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> > NFSD: starting 90-second grace period
> > 

I've been working off and on for a little while to resolve these issues
and even posted a patch not long ago to address some these by removing
the timers and using workqueues instead.  This enabled resolution of
quite a few of the issues with bonding since the code was no longer
running in an atomic context and could now more easily take locks.

On the side I've also been working to keep the timers and take the rtnl
lock in the correct place so avoid messages like these:

> > RTNL: assertion failed at net/ipv4/devinet.c (1055)
> > 
> > Call Trace:
> >  <IRQ>  [<ffffffff804d9c48>] inetdev_event+0x48/0x2d0
> >  [<ffffffff80263138>] _spin_lock_bh+0x9/0x19
> >  [<ffffffff8023d84a>] rt_run_flush+0x92/0xcc

but I recently have been getting a panic on one of my systems and need
to get a serial cable so I can get the full string, so I haven't debugged
that yet.


