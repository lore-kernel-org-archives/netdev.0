From: Lionel Landwerlin <landwer@free.fr>
Subject: sky2 or acpi problem ?
Date: Thu, 01 Feb 2007 18:59:55 +0100
Message-ID: <1170352795.5299.17.camel@cocoduo>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422842AbXBASAd@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
we already had words on lkml about this bug with sky2 driver.

I was having problems, and you told me to use the disable_msi=1
parameter to see what happens. After a couple of hours of testing with
heavly ethernet load, I answered you it had fixed the problem. I was
wrong. Now, it takes much more time to crash. Most of time, I can't even
see what happens beacause the box is completly frozen. But after several
crashs, I only had my keyboard locked, usb unpowered, and ethernet
interface down, I finally had the possibility see that :

Feb  1 18:35:06 cocoduo kernel: [59723.468000] NETDEV WATCHDOG: eth0: transmit timed out
Feb  1 18:35:07 cocoduo kernel: [59723.468000] sky2 eth0: tx timeout
Feb  1 18:35:07 cocoduo kernel: [59723.468000] sky2 eth0: transmit ring 64 .. 41 report=65 done=65
Feb  1 18:35:07 cocoduo kernel: [59723.468000] sky2 status report lost?
Feb  1 18:35:16 cocoduo kernel: [59733.200000] BUG: soft lockup detected on CPU#0!
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [softlockup_tick+155/208] softlockup_tick+0x9b/0xd0
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [update_process_times+49/128] update_process_times+0x31/0x80
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [smp_apic_timer_interrupt+145/176] smp_apic_timer_interrupt+0x91/0xb0
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [apic_timer_interrupt+31/36] apic_timer_interrupt+0x1f/0x24
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [_spin_lock_bh+15/32] _spin_lock_bh+0xf/0x20
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [pg0+945481365/1068803072] sky2_tx_timeout+0xf5/0x1d0 [sky2]
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [dev_watchdog+0/208] dev_watchdog+0x0/0xd0
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [dev_watchdog+192/208] dev_watchdog+0xc0/0xd0
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [run_timer_softirq+273/400] run_timer_softirq+0x111/0x190
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [__do_softirq+116/240] __do_softirq+0x74/0xf0
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [do_softirq+59/80] do_softirq+0x3b/0x50
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [smp_apic_timer_interrupt+150/176] smp_apic_timer_interrupt+0x96/0xb0
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [apic_timer_interrupt+31/36] apic_timer_interrupt+0x1f/0x24
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [pg0+943208348/1068803072] acpi_processor_idle+0x1fd/0x3b9 [processor]
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [cpu_idle+116/208] cpu_idle+0x74/0xd0
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [start_kernel+872/1072] start_kernel+0x368/0x430
Feb  1 18:35:16 cocoduo kernel: [59733.200000]  [unknown_bootoption+0/624] unknown_bootoption+0x0/0x270

It's exactly the same error than before. What do you think of this
trace ? Is it related to sky2 driver or acpi ? Did you add debug output
since 2.6.19.2 (version of the kernel I'm using) that would help to fix
that bug ? What can I do to help to fix the bug ?

Regards,

-- 
Lionel Landwerlin <landwer@free.fr>
