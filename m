From: "George Spelvin" <linux@horizon.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: 31 Jul 2013 08:34:50 -0400
Message-ID: <20130731123450.5324.qmail@science.horizon.com>
References: <1374075727.3861.6.camel@bwh-desktop.uk.level5networks.com>
Cc: eric.dumazet@gmail.com, grantgrundler@gmail.com,
	grundler@parisc-linux.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com, linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:28603 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751403Ab3GaMe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 08:34:59 -0400
In-Reply-To: <1374075727.3861.6.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grumble.  After a week of uptime with my tulip patches
(the ones I posted here plus some cleanup patches) my
kernel gave me this:

------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xd9/0x137()
NETDEV WATCHDOG: cable (tulip): transmit queue 0 timed out
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.2-00033-gca137af #47
Hardware name: MICRO-STAR INTERNATIONAL CO.,LTD MS-7376/MS-7376, BIOS V1.7 01/13/2009
 0000000000000000 ffffffff81028aba ffff88021fc03e68 ffff880216b38000
 ffff88021fc03eb8 ffffffff8133643a ffffffff8133643a ffffffff81028b33
 ffffffff8159fe93 ffff880200000030 ffff88021fc03ec8 ffff88021fc03e88
Call Trace:
 <IRQ>  [<ffffffff81028aba>] ? warn_slowpath_common+0x56/0x6b
 [<ffffffff8133643a>] ? qdisc_rcu_free+0x19/0x19
 [<ffffffff8133643a>] ? qdisc_rcu_free+0x19/0x19
 [<ffffffff81028b33>] ? warn_slowpath_fmt+0x47/0x49
 [<ffffffff8133634e>] ? netif_tx_lock+0x47/0x72
 [<ffffffff81336513>] ? dev_watchdog+0xd9/0x137
 [<ffffffff81031f40>] ? call_timer_fn.isra.29+0x1c/0x6f
 [<ffffffff810321a2>] ? run_timer_softirq+0x19a/0x1c2
 [<ffffffff8102de09>] ? __do_softirq+0xb9/0x171
 [<ffffffff8102df7f>] ? irq_exit+0x3a/0x7a
 [<ffffffff8101967a>] ? smp_apic_timer_interrupt+0x72/0x7e
 [<ffffffff8142a60a>] ? apic_timer_interrupt+0x6a/0x70
 <EOI>  [<ffffffff81007e34>] ? amd_e400_idle+0xbf/0xc1
 [<ffffffff81007e2c>] ? amd_e400_idle+0xb7/0xc1
 [<ffffffff8104f74d>] ? cpu_startup_entry+0x9c/0xec
 [<ffffffff8164eb91>] ? start_kernel+0x2bd/0x2c8
 [<ffffffff8164e6f7>] ? repair_env_string+0x54/0x54
---[ end trace fa3269ab5c1a15ad ]---

Since it's on the tulip device, it's probably my fault, and
since it took a week to manifest itself, it's going to be
a complete PITA to reproduce.

Anyway, I haven't forgotten.
