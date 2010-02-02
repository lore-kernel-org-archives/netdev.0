From: Meelis Roos <mroos@linux.ee>
Subject: transmit timed out with tulip on sparc64
Date: Tue, 2 Feb 2010 17:51:48 +0200 (EET)
Message-ID: <alpine.SOC.1.00.0910081022270.16430@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, sparclinux@cger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:34360 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103Ab0BBQXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 11:23:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Found a postponed mesasage from some time ago and restested - still a 
problem with 2.6.33-rc6)

I have a Sun Fire V100 running bleeding-edge kernels.

I usually do not transfer large amounts of data - updating debian 
unstable is the most stressing one. However, today I tried to copy 
gigabytes of data over scp to this machine and it dropped out of the 
network. Reson unknown, attaching serial console after that gave the 
following transmit timeout message that may or may not be the primary 
reason.

2.6.32-rc3-00052-g0eca52a:

[130930.573930] ------------[ cut here ]------------
[130930.635834] WARNING: at net/sched/sch_generic.c:261 dev_watchdog+0x258/0x280()
[130930.731919] NETDEV WATCHDOG: eth0 (tulip): transmit queue 0 timed out
[130930.817722] Modules linked in: ipv6 fuse loop usbhid ohci_hcd sg sr_mod usbcore cdrom
[130930.921905] Call Trace:
[130930.955091]  [0000000000454230] warn_slowpath_common+0x50/0xa0
[130931.032922]  [00000000004542f4] warn_slowpath_fmt+0x34/0x60
[130931.107316]  [000000000064a658] dev_watchdog+0x258/0x280
[130931.178289]  [000000000045f6f4] run_timer_softirq+0x1b4/0x240
[130931.254975]  [000000000045a484] __do_softirq+0xa4/0x140
[130931.324798]  [000000000042a93c] do_softirq+0x7c/0xa0
[130931.391189]  [000000000045a0cc] irq_exit+0x8c/0xc0
[130931.455303]  [000000000042fcc4] timer_interrupt+0x64/0xa0
[130931.527412]  [00000000004209d4] tl0_irq14+0x14/0x20
[130931.592671]  [000000000043af60] touch_nmi_watchdog+0x0/0x60
[130931.667064]  [00000000006b59a8] rest_init+0x68/0x80
[130931.732321]  [00000000008247c4] start_kernel+0x2ac/0x2e8
[130931.803280]  [00000000006b5924] tlb_fixup_done+0x80/0x9c
[130931.874243]  [0000000000000000] (null)
[130931.924635] ---[ end trace 70d1b6d12c0cb235 ]---

I restared the computer and reran the test to see whether something 
appears on the console before - no, it doesn't, this is the first log 
snippet and is basically the same.

[  105.701102] eth0: no IPv6 routers present
[  473.311090] ------------[ cut here ]------------
[  473.371799] WARNING: at net/sched/sch_generic.c:261 dev_watchdog+0x258/0x280()
[  473.466747] NETDEV WATCHDOG: eth0 (tulip): transmit queue 0 timed out
[  473.551407] Modules linked in: ipv6 fuse loop usbhid ohci_hcd sg sr_mod cdrom usbcore
[  473.654446] Call Trace:
[  473.686491]  [0000000000454230] warn_slowpath_common+0x50/0xa0
[  473.763176]  [00000000004542f4] warn_slowpath_fmt+0x34/0x60
[  473.836430]  [000000000064a658] dev_watchdog+0x258/0x280
[  473.906265]  [000000000045f6f4] run_timer_softirq+0x1b4/0x240
[  473.981806]  [000000000045a484] __do_softirq+0xa4/0x140
[  474.050479]  [000000000042a93c] do_softirq+0x7c/0xa0
[  474.115728]  [000000000045a0cc] irq_exit+0x8c/0xc0
[  474.178699]  [000000000042fcc4] timer_interrupt+0x64/0xa0
[  474.249666]  [00000000004209d4] tl0_irq14+0x14/0x20
[  474.313784]  [0000000000590c80] mcount+0xc0/0xe0
[  474.374457]  [000000000042c94c] cpu_idle+0x4c/0x100
[  474.438568]  [00000000006b59a8] rest_init+0x68/0x80
[  474.502683]  [00000000008247c4] start_kernel+0x2ac/0x2e8
[  474.572503]  [00000000006b5924] tlb_fixup_done+0x80/0x9c
[  474.642320]  [0000000000000000] (null)

Now verified that the same happens with selfcompiled 2.6.31.

Freshly tested that it also happens with 2.6.33-rc6:

[247694.931852] ------------[ cut here ]------------
[247694.993771] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x240/0x260()
[247695.089865] NETDEV WATCHDOG: eth0 (tulip): transmit queue 0 timed out
[247695.175667] Modules linked in: ipv6 fuse loop ohci_hcd sg sr_mod usbcore cdrom
[247695.271857] Call Trace:
[247695.305135]  [0000000000454aac] warn_slowpath_common+0x4c/0x80
[247695.382967]  [0000000000454b4c] warn_slowpath_fmt+0x2c/0x40
[247695.457360]  [0000000000645160] dev_watchdog+0x240/0x260
[247695.528334]  [000000000046008c] run_timer_softirq+0x18c/0x240
[247695.605020]  [000000000045abb8] __do_softirq+0x98/0x140
[247695.674842]  [000000000042a758] do_softirq+0x78/0xa0
[247695.741234]  [000000000045a830] irq_exit+0x90/0xa0
[247695.805347]  [000000000042f860] timer_interrupt+0x60/0xa0
[247695.877460]  [00000000004209d4] tl0_irq14+0x14/0x20
[247695.942710]  [000000000058b944] mcount+0x4/0xe0
[247696.003387]  [000000000042c764] cpu_idle+0x44/0xe0
[247696.067502]  [00000000006b025c] rest_init+0x5c/0x80
[247696.132758]  [0000000000810794] start_kernel+0x2d4/0x2e4
[247696.203720]  [00000000006b01e4] tlb_fixup_done+0x80/0x9c
[247696.274682]  [0000000000000000] (null)
[247696.325070] ---[ end trace 27a08f024f3aa132 ]---

-- 
Meelis Roos (mroos@linux.ee)
