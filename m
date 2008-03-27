From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in  
 net_rx_action
Date: Wed, 26 Mar 2008 17:14:03 -0700
Message-ID: <20080326171403.ad186037.akpm@linux-foundation.org>
References: <bug-10326-10286@http.bugzilla.kernel.org/>
	<20080325134320.21525479.akpm@linux-foundation.org>
	<47EAD8A5.3070806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	marcus@better.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58367 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754615AbYC0AON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 20:14:13 -0400
In-Reply-To: <47EAD8A5.3070806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Mar 2008 00:13:41 +0100 Jarek Poplawski <jarkao2@gmail.com> wrote:

> Andrew Morton wrote, On 03/25/2008 09:43 PM:
> 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Tue, 25 Mar 2008 13:21:23 -0700 (PDT)
> > bugme-daemon@bugzilla.kernel.org wrote:
> > 
> >> http://bugzilla.kernel.org/show_bug.cgi?id=10326
> >>
> >>            Summary: inconsistent lock state in net_rx_action
> >>            Product: Networking
> >>            Version: 2.5
> >>      KernelVersion: 2.6.25-rc6 (git
> >>                     a4083c9271e0a697278e089f2c0b9a95363ada0a)
> >>           Platform: All
> >>         OS/Version: Linux
> >>               Tree: Mainline
> >>             Status: NEW
> >>           Severity: normal
> >>           Priority: P1
> >>          Component: Other
> >>         AssignedTo: acme@ghostprotocols.net
> >>         ReportedBy: marcus@better.se
> >>
> >>
> >> Latest working kernel version: 2.6.24
> >> Earliest failing kernel version: 2.6.25-rc6 (git
> >> a4083c9271e0a697278e089f2c0b9a95363ada0a)
> > 
> > A post-2.624 regression.
> > 
> >> Distribution: Debian testing/unstable
> >> Hardware Environment: LG LE50 Express laptop, i386
> >> Software Environment: Debian i386, X.org 7.3, KDE 4
> >>
> >> Problem Description:
> >>
> >> Got this during bootup, somewhere before launching X. It only happened once, I
> >> have rebooted a few times and didn't reproduce it.
> >>
> >> Mar 25 19:48:46 better kernel: =================================
> >> Mar 25 19:48:46 better kernel: [ INFO: inconsistent lock state ]
> >> Mar 25 19:48:46 better kernel: 2.6.25-rc6-lg #4
> >> Mar 25 19:48:46 better kernel: ---------------------------------
> >> Mar 25 19:48:46 better kernel: inconsistent {in-softirq-W} -> {softirq-on-W}
> >> usage.
> >> Mar 25 19:48:46 better kernel: syslogd/2773 [HC0[0]:SC0[0]:HE1:SE1] takes:
> >> Mar 25 19:48:46 better kernel:  (&napi->poll_lock){-+..}, at: [<c03db11c>]
> >> netpoll_poll+0xbc/0x390
> >> Mar 25 19:48:46 better kernel: {in-softirq-W} state was registered at:
> >> Mar 25 19:48:46 better kernel:   [<c024171a>] __lock_acquire+0x36a/0x1070
> >> Mar 25 19:48:46 better kernel:   [<c024153f>] __lock_acquire+0x18f/0x1070
> >> Mar 25 19:48:46 better kernel:   [<c024247f>] lock_acquire+0x5f/0x80
> >> Mar 25 19:48:46 better kernel:   [<c03cfafc>] net_rx_action+0xbc/0x1d0
> >> Mar 25 19:48:46 better kernel:   [<c044a9e4>] _spin_lock+0x34/0x40
> >> Mar 25 19:48:46 better kernel:   [<c03cfafc>] net_rx_action+0xbc/0x1d0
> >> Mar 25 19:48:46 better kernel:   [<c03cfafc>] net_rx_action+0xbc/0x1d0
> >> Mar 25 19:48:46 better kernel:   [<c03cfaa0>] net_rx_action+0x60/0x1d0
> >> Mar 25 19:48:46 better kernel:   [<c02254f2>] __do_softirq+0x62/0xc0
> >> Mar 25 19:48:46 better kernel:   [<c0225595>] do_softirq+0x45/0x50
> >> Mar 25 19:48:46 better kernel:   [<c0225797>] irq_exit+0x77/0x80
> >> Mar 25 19:48:46 better kernel:   [<c0211a95>]
> >> smp_apic_timer_interrupt+0x45/0x80
> >> Mar 25 19:48:46 better kernel:   [<c02058ad>] apic_timer_interrupt+0x29/0x38
> >> Mar 25 19:48:46 better kernel:   [<c02058b7>] apic_timer_interrupt+0x33/0x38
> >> Mar 25 19:48:46 better kernel:   [<c022007b>] __set_personality+0x2b/0x240
> >> Mar 25 19:48:46 better kernel:   [<c0220e51>] release_console_sem+0x191/0x1e0
> >> Mar 25 19:48:46 better kernel:   [<c05751aa>] init_netconsole+0x1da/0x1f0
> >> Mar 25 19:48:46 better kernel:   [<c0558700>] kernel_init+0x90/0x270
> >> Mar 25 19:48:46 better kernel:   [<c0204ecf>] restore_nocheck+0x12/0x15
> >> Mar 25 19:48:46 better kernel:   [<c0240eec>] trace_hardirqs_on+0x9c/0x110
> >> Mar 25 19:48:46 better kernel:   [<c0558670>] kernel_init+0x0/0x270
> >> Mar 25 19:48:46 better kernel:   [<c0558670>] kernel_init+0x0/0x270
> >> Mar 25 19:48:46 better kernel:   [<c0205a23>] kernel_thread_helper+0x7/0x14
> >> Mar 25 19:48:46 better kernel:   [<ffffffff>] 0xffffffff
> >> Mar 25 19:48:46 better kernel: irq event stamp: 174638
> >> Mar 25 19:48:46 better kernel: hardirqs last  enabled at (174637): [<c0204ecf>]
> >> restore_nocheck+0x12/0x15
> >> Mar 25 19:48:46 better kernel: hardirqs last disabled at (174638): [<c044ac65>]
> >> _spin_lock_irqsave+0x15/0x60
> >> Mar 25 19:48:46 better kernel: softirqs last  enabled at (174636): [<c0225595>]
> >> do_softirq+0x45/0x50
> >> Mar 25 19:48:46 better kernel: softirqs last disabled at (174629): [<c0225595>]
> >> do_softirq+0x45/0x50
> >> Mar 25 19:48:46 better kernel: 
> >> Mar 25 19:48:46 better kernel: other info that might help us debug this:
> >> Mar 25 19:48:46 better kernel: 3 locks held by syslogd/2773:
> >> Mar 25 19:48:46 better kernel:  #0:  (&tty->atomic_write_lock){--..}, at:
> >> [<c036c699>] tty_write_lock+0x19/0x50
> >> Mar 25 19:48:46 better kernel:  #1:  (target_list_lock){--..}, at: [<c0399c0d>]
> >> write_msg+0x2d/0xd0
> >> Mar 25 19:48:46 better kernel:  #2:  (&napi->poll_lock){-+..}, at: [<c03db11c>]
> >> netpoll_poll+0xbc/0x390
> >> Mar 25 19:48:46 better kernel: 
> >> Mar 25 19:48:46 better kernel: stack backtrace:
> >> Mar 25 19:48:46 better kernel: Pid: 2773, comm: syslogd Not tainted
> >> 2.6.25-rc6-lg #4
> >> Mar 25 19:48:46 better kernel:  [<c023ff6f>] print_usage_bug+0x15f/0x170
> >> Mar 25 19:48:46 better kernel:  [<c0240bd1>] mark_lock+0x401/0x590
> >> Mar 25 19:48:46 better kernel:  [<c0240d98>] mark_held_locks+0x38/0x70
> >> Mar 25 19:48:46 better kernel:  [<c0398a43>] sky2_poll+0x7a3/0xad0
> >> Mar 25 19:48:46 better kernel:  [<c0240eec>] trace_hardirqs_on+0x9c/0x110
> >> Mar 25 19:48:46 better kernel:  [<c0398a43>] sky2_poll+0x7a3/0xad0
> >> Mar 25 19:48:46 better kernel:  [<c03db11c>] netpoll_poll+0xbc/0x390
> >> Mar 25 19:48:46 better kernel:  [<c044adb2>] _spin_trylock+0x42/0x80
> >> Mar 25 19:48:46 better kernel:  [<c03db0d3>] netpoll_poll+0x73/0x390
> >> Mar 25 19:48:46 better kernel:  [<c03db51f>] netpoll_send_skb+0x12f/0x1d0
> >> Mar 25 19:48:46 better kernel:  [<c0399c7c>] write_msg+0x9c/0xd0
> 
> 
> netconsole's write_msg calls netpoll_send_udp (then netpoll_send_skb) always
> under spin_lock_irqsave(&target_list_lock, flags), and here this lock (and 
> afterwards napi->poll_lock) is seen taken with irqs enabled. So, IMHO, it
> looks like some other irq (tracking?) imbalance and not networking bug.
> 

No, it's not an irq_disable() thing, directly.

What lockdep is saying is that sky2_poll() is taking napi->poll_lock for
writing with softirqs enabled, but net_rx_action() takes the same lock from
within softirq context.

If sky2_poll() always takes napi->poll_lock under local_irq_disable() then
that would be a lockdep bug.


