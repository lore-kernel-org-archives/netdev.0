From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [Bugme-new] [Bug 11955] New: WARNING: at
	net/sched/sch_generic.c:219 dev_watchdog+0x24b/0x25a()
Date: Wed, 5 Nov 2008 12:26:26 +0300
Message-ID: <20081105092626.GB4393@x200.localdomain>
References: <bug-11955-10286@http.bugzilla.kernel.org/> <20081105010247.5e7d802c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	ralf.hildebrandt@charite.de, stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:23565 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825AbYKEJXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 04:23:10 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1455227nfc.21
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2008 01:23:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081105010247.5e7d802c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2008 at 01:02:47AM -0800, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Wed,  5 Nov 2008 00:38:10 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=11955
> > 
> >            Summary: WARNING: at net/sched/sch_generic.c:219
> >                     dev_watchdog+0x24b/0x25a()
> >            Product: Networking
> >            Version: 2.5
> >      KernelVersion: 2.6.27.4
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: acme@ghostprotocols.net
> >         ReportedBy: ralf.hildebrandt@charite.de
> > 
> > 
> > Latest working kernel version: 2.6.27.3
> > Earliest failing kernel version: 2.6.27.4
> 
> A regression in -stable.

Absolutely no, unless it is reproducible on every boot.
No bnx2 changes between stables and no net/core/ changes.

> > Distribution: Debian/testing
> > Hardware Environment:
> > Software Environment:
> > Problem Description:
> > 
> > Steps to reproduce:
> > 
> > In dmesg I found:
> > 
> > [28739.530306] bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive
> > & transmit flow control ON
> > [221569.991014] ------------[ cut here ]------------
> > [221569.991064] WARNING: at net/sched/sch_generic.c:219
> > dev_watchdog+0x24b/0x25a()
> > [221569.991108] NETDEV WATCHDOG: eth0 (bnx2): transmit timed out
> > [221569.991136] Modules linked in: xt_tcpudp nf_conntrack_ipv4 xt_state
> > nf_conntrack iptable_filter ip_tables x_tables tg3 libphy bnx2 zlib_inflate
> > psmouse crc32 thermal container button processor
> > [221569.991245] Pid: 0, comm: swapper Not tainted 2.6.27.4 #1
> > [221569.991273]  [<c012348a>] warn_slowpath+0x6f/0x96
> > [221569.991302]  [<c0137685>] hrtimer_reprogram+0x71/0xa4
> > [221569.991332]  [<c013772c>] enqueue_hrtimer+0x74/0x100
> > [221569.991360]  [<c013807c>] hrtimer_start+0xa3/0x145
> > [221569.991388]  [<c011d7e5>] hrtick_start_fair+0x131/0x147
> > [221569.991417]  [<c011f06d>] try_to_wake_up+0xbd/0x182
> > [221569.991444]  [<c01e5684>] strlcpy+0x11/0x3d
> > [221569.991472]  [<c027e5b1>] netdev_drivername+0x2f/0x33
> > [221569.991501]  [<c028b208>] dev_watchdog+0x24b/0x25a
> > [221569.991529]  [<c011a59c>] __wake_up+0x32/0x42
> > [221569.991556]  [<c012bb76>] run_timer_softirq+0x101/0x1b7
> > [221569.991585]  [<c028afbd>] dev_watchdog+0x0/0x25a
> > [221569.991612]  [<c0127f8a>] __do_softirq+0x87/0xfd
> > [221569.991640]  [<c0127f03>] __do_softirq+0x0/0xfd
> > [221569.991667]  [<c010666a>] do_softirq+0x7f/0xb1
> > [221569.991695]  [<c0127b85>] irq_exit+0x66/0x7a
> > [221569.991721]  [<c0111475>] smp_apic_timer_interrupt+0x57/0x82
> > [221569.991752]  [<c01e7290>] trace_hardirqs_off_thunk+0xc/0x10
> > [221569.991781]  [<c01044f1>] apic_timer_interrupt+0x2d/0x34
> > [221569.991810]  [<c01098f9>] mwait_idle+0x36/0x3e
> > [221569.991837]  [<c0102a95>] cpu_idle+0x60/0xab
> > [221569.991864]  =======================
> > [221569.991887] ---[ end trace f996508cd6a61637 ]---
> > [221570.100912] bnx2: eth0 NIC Copper Link is Down
> > 
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
