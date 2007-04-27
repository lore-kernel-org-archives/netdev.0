From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PROBLEM] Bonding driver in linux-2.6.21-rc6-mm1
Date: Fri, 27 Apr 2007 15:32:37 -0700
Message-ID: <20070427153237.03f3b59c.akpm@linux-foundation.org>
References: <200704262058.33087.ve@vetienne.net>
	<010a01c788ae$0a7d0140$5601a8c0@apws2>
	<20070427122039.98e02471.akpm@linux-foundation.org>
	<200704272205.29131.ve@vetienne.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Vincent ETIENNE <ve@vetienne.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:48224 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757502AbXD0Wco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 18:32:44 -0400
In-Reply-To: <200704272205.29131.ve@vetienne.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Apr 2007 22:05:28 +0200
Vincent ETIENNE <ve@vetienne.net> wrote:

> Le Friday 27 April 2007 21:20:39, vous avez __crit__:
> > On Fri, 27 Apr 2007 11:25:46 +0200 "VE \(HOME\)" <ve@vetienne.net> wrote:
> > > Andrew Morton wrote:
> > > > On Thu, 26 Apr 2007 20:58:32 +0200 Vincent ETIENNE <ve@vetienne.net>
> > > > wrote:
> > > >
> > > >
> > > > This was due to locking bustage in the net tree.  It should be fixed
> > > > in 2.6.21-rc7-mm2.
> > >
> > > I have tried this version. Same problem ( see
> > > http://mail1.vetienne.net/linux/dmesg-2.6.21-rc7-mm2.log )
> >
> > That file has disappeared.
> 
> Sorry wrong right on the file. Should be ok now

Please don't go off-list.  Now the people who work on this code don't know
that the log is available.  I've reestablished a few cc's.


The troublesome part is here:

e1000: eth0: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX
e1000: eth0: e1000_watchdog_task: 10/100 speed: disabling TSO
bonding: bond0: link status definitely up for interface eth0.
bonding: bond0: making interface eth0 the new active one.
RTNL: assertion failed at net/ipv4/devinet.c (1055)

Call Trace:
 <IRQ>  [<ffffffff8049b9a1>] inetdev_event+0x48/0x283
 [<ffffffff804c85d1>] _spin_lock_bh+0x9/0x19
 [<ffffffff804753d7>] rt_run_flush+0x7e/0xaf
 [<ffffffff8022d388>] notifier_call_chain+0x29/0x56
 [<ffffffff80457994>] dev_set_mac_address+0x53/0x59
 [<ffffffff88006d6d>] :bonding:alb_set_slave_mac_addr+0x41/0x6c
 [<ffffffff880071e9>] :bonding:alb_swap_mac_addr+0x91/0x165
 [<ffffffff88002022>] :bonding:bond_change_active_slave+0x227/0x382
 [<ffffffff880024c2>] :bonding:bond_select_active_slave+0xb7/0xe5
 [<ffffffff88004172>] :bonding:bond_mii_monitor+0x3cd/0x41e
 [<ffffffff88003da5>] :bonding:bond_mii_monitor+0x0/0x41e
 [<ffffffff802299a0>] run_timer_softirq+0x130/0x19f
 [<ffffffff80226b64>] __do_softirq+0x55/0xc4
 [<ffffffff8020a6ac>] call_softirq+0x1c/0x28
 [<ffffffff8020bfb9>] do_softirq+0x2c/0x7d
 [<ffffffff802145a7>] smp_apic_timer_interrupt+0x49/0x5e
 [<ffffffff80208989>] mwait_idle+0x0/0x47
 [<ffffffff8020a156>] apic_timer_interrupt+0x66/0x70
 <EOI>  [<ffffffff802089cb>] mwait_idle+0x42/0x47
 [<ffffffff80208921>] cpu_idle+0x7f/0xa2
 [<ffffffff806349bd>] start_kernel+0x242/0x24e
 [<ffffffff80634146>] _sinittext+0x146/0x14a


because we thought we'd fixed the rtnl_lock() problems in 2.6.21-rc7-mm2. 
Are you sure that log is from 2.6.21-rc7-mm2?

