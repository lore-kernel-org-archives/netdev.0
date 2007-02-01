From: Fagyal Csongor <concept@conceptonline.hu>
Subject: Re: sky2 or acpi problem ?
Date: Thu, 01 Feb 2007 19:20:07 +0100
Message-ID: <45C22F57.3030804@conceptonline.hu>
References: <1170352795.5299.17.camel@cocoduo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lionel Landwerlin <landwer@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.interware.hu ([195.70.32.130]:46351 "EHLO
	mail.interware.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422931AbXBASjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 13:39:51 -0500
In-Reply-To: <1170352795.5299.17.camel@cocoduo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lionel Landwerlin wrote:

>Hi,
>we already had words on lkml about this bug with sky2 driver.
>
>I was having problems, and you told me to use the disable_msi=1
>parameter to see what happens. After a couple of hours of testing with
>heavly ethernet load, I answered you it had fixed the problem. I was
>wrong. Now, it takes much more time to crash. Most of time, I can't even
>see what happens beacause the box is completly frozen. But after several
>crashs, I only had my keyboard locked, usb unpowered, and ethernet
>interface down, I finally had the possibility see that :
>
>Feb  1 18:35:06 cocoduo kernel: [59723.468000] NETDEV WATCHDOG: eth0: transmit timed out
>Feb  1 18:35:07 cocoduo kernel: [59723.468000] sky2 eth0: tx timeout
>Feb  1 18:35:07 cocoduo kernel: [59723.468000] sky2 eth0: transmit ring 64 .. 41 report=65 done=65
>Feb  1 18:35:07 cocoduo kernel: [59723.468000] sky2 status report lost?
>Feb  1 18:35:16 cocoduo kernel: [59733.200000] BUG: soft lockup detected on CPU#0!
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [softlockup_tick+155/208] softlockup_tick+0x9b/0xd0
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [update_process_times+49/128] update_process_times+0x31/0x80
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [smp_apic_timer_interrupt+145/176] smp_apic_timer_interrupt+0x91/0xb0
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [apic_timer_interrupt+31/36] apic_timer_interrupt+0x1f/0x24
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [_spin_lock_bh+15/32] _spin_lock_bh+0xf/0x20
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [pg0+945481365/1068803072] sky2_tx_timeout+0xf5/0x1d0 [sky2]
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [dev_watchdog+0/208] dev_watchdog+0x0/0xd0
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [dev_watchdog+192/208] dev_watchdog+0xc0/0xd0
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [run_timer_softirq+273/400] run_timer_softirq+0x111/0x190
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [__do_softirq+116/240] __do_softirq+0x74/0xf0
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [do_softirq+59/80] do_softirq+0x3b/0x50
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [smp_apic_timer_interrupt+150/176] smp_apic_timer_interrupt+0x96/0xb0
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [apic_timer_interrupt+31/36] apic_timer_interrupt+0x1f/0x24
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [pg0+943208348/1068803072] acpi_processor_idle+0x1fd/0x3b9 [processor]
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [cpu_idle+116/208] cpu_idle+0x74/0xd0
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [start_kernel+872/1072] start_kernel+0x368/0x430
>Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [unknown_bootoption+0/624] unknown_bootoption+0x0/0x270
>
>It's exactly the same error than before. What do you think of this
>trace ? Is it related to sky2 driver or acpi ? Did you add debug output
>since 2.6.19.2 (version of the kernel I'm using) that would help to fix
>that bug ? What can I do to help to fix the bug ?
>
>Regards,
>  
>
Same(?) problem here. I am not sure what causes it - happens once in a while (once in every day?) Once I got "no route to host", after which I had to reboot to get the interface working again. But the latest was this:


Jan 31 19:15:34 tc kernel: sky2 eth0: tx timeout
Jan 31 19:15:34 tc kernel: sky2 status report lost?
Jan 31 19:15:34 tc kernel: BUG: spinlock recursion on CPU#0, swapper/0 
(Not tainted)
Jan 31 19:15:34 tc kernel: lock: f73b2a00, .magic: dead4ead, .owner: 
swapper/0, .owner_cpu: 0
Jan 31 19:15:34 tc kernel: [<c0405018>] dump_trace+0x69/0x1b6
Jan 31 19:15:34 tc kernel: [<c040517d>] show_trace_log_lvl+0x18/0x2c
Jan 31 19:15:34 tc kernel: [<c0405778>] show_trace+0xf/0x11
Jan 31 19:15:34 tc kernel: [<c0405875>] dump_stack+0x15/0x17
Jan 31 19:15:34 tc kernel: [<c04f3925>] _raw_spin_lock+0x35/0xdc
Jan 31 19:15:34 tc kernel: [<f899bd63>] sky2_tx_timeout+0xe9/0x191 [sky2]
Jan 31 19:15:34 tc kernel: [<c05d5a2c>] dev_watchdog+0x77/0xb9
Jan 31 19:15:34 tc kernel: [<c0430cef>] run_timer_softirq+0x105/0x16c
Jan 31 19:15:34 tc kernel: [<c042c041>] __do_softirq+0x5a/0xbb
Jan 31 19:15:34 tc kernel: [<c0406435>] do_softirq+0x55/0xb5
Jan 31 19:15:34 tc kernel: =======================
Jan 31 19:15:43 tc kernel: BUG: soft lockup detected on CPU#0!
Jan 31 19:15:43 tc kernel: [<c0405018>] dump_trace+0x69/0x1b6
Jan 31 19:15:43 tc kernel: [<c040517d>] show_trace_log_lvl+0x18/0x2c
Jan 31 19:15:43 tc kernel: [<c0405778>] show_trace+0xf/0x11
Jan 31 19:15:43 tc kernel: [<c0405875>] dump_stack+0x15/0x17
Jan 31 19:15:43 tc kernel: [<c04522c5>] softlockup_tick+0xad/0xc4
Jan 31 19:15:43 tc kernel: [<c0430d8f>] update_process_times+0x39/0x5c
Jan 31 19:15:43 tc kernel: [<c0419f5a>] smp_apic_timer_interrupt+0x95/0xb3
Jan 31 19:15:43 tc kernel: [<c0404a57>] apic_timer_interrupt+0x1f/0x24
Jan 31 19:15:43 tc kernel: [<c04f395f>] _raw_spin_lock+0x6f/0xdc
Jan 31 19:15:43 tc kernel: [<f899bd63>] sky2_tx_timeout+0xe9/0x191 [sky2]
Jan 31 19:15:43 tc kernel: [<c05d5a2c>] dev_watchdog+0x77/0xb9
Jan 31 19:15:43 tc kernel: [<c0430cef>] run_timer_softirq+0x105/0x16c
Jan 31 19:15:43 tc kernel: [<c042c041>] __do_softirq+0x5a/0xbb
Jan 31 19:15:43 tc kernel: [<c0406435>] do_softirq+0x55/0xb5
Jan 31 19:15:43 tc kernel: =======================
Jan 31 19:16:10 tc kernel: BUG: spinlock lockup on CPU#0, swapper/0, 
f73b2a00 (Not tainted)
Jan 31 19:16:10 tc kernel: [<c0405018>] dump_trace+0x69/0x1b6
Jan 31 19:16:10 tc kernel: [<c040517d>] show_trace_log_lvl+0x18/0x2c
Jan 31 19:16:10 tc kernel: [<c0405778>] show_trace+0xf/0x11
Jan 31 19:16:10 tc kernel: [<c0405875>] dump_stack+0x15/0x17
Jan 31 19:16:10 tc kernel: [<c04f39af>] _raw_spin_lock+0xbf/0xdc
Jan 31 19:16:10 tc kernel: [<f899bd63>] sky2_tx_timeout+0xe9/0x191 [sky2]
Jan 31 19:16:10 tc kernel: [<c05d5a2c>] dev_watchdog+0x77/0xb9
Jan 31 19:16:10 tc kernel: [<c0430cef>] run_timer_softirq+0x105/0x16c
Jan 31 19:16:10 tc kernel: [<c042c041>] __do_softirq+0x5a/0xbb
Jan 31 19:16:10 tc kernel: [<c0406435>] do_softirq+0x55/0xb5
Jan 31 19:16:10 tc kernel: =======================
Jan 31 19:17:14 tc named[2334]: *** POKED TIMER ***

At this time I tried ifdown eth0, which completely froze the computer.

I am running 2.6.19-1.2895.fc6, and this is an E6600 in a Gigabyte 
965P-DS3 (with the default Marvell 88E8053).

I have idle=poll now, according to this thread:

http://www.gossamer-threads.com/lists/linux/kernel/725399


No lockup so far, but I only have this setting since yesterday...

- Fagzal
