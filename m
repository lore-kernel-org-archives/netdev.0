From: Simon Kirby <sim@hostway.ca>
Subject: Re: Linux 3.1-rc9
Date: Mon, 17 Oct 2011 22:40:51 -0700
Message-ID: <20111018054051.GA19085@hostway.ca>
References: <CA+55aFxPNszU5UHFrDDYnshLEMupaviFwhgEsgmPkqpmuWNZ8A@mail.gmail.com> <20111007070842.GA27555@hostway.ca> <20111007174848.GA11011@hostway.ca> <1318010515.398.8.camel@twins> <20111008005035.GC22843@hostway.ca> <1318060551.8395.0.camel@twins> <20111012213555.GC24461@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111012213555.GC24461@hostway.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 12, 2011 at 02:35:55PM -0700, Simon Kirby wrote:

> > > patching file kernel/posix-cpu-timers.c
> > > patching file kernel/sched_stats.h 
> > 
> > yes that would be fine.
> 
> This patch (s/raw_//) has been stable on 5 boxes for a day. I'll push to
> another 15 shortly and confirm tomorrow. Meanwhile, we had another ~4
> boxes lock up on 3.1-rc9 _with_ d670ec13 reverted (all CPUs spinning),
> but there weren't enough serial cables to log all of them and we haven't
> been lucky enough to capture anything other than what fits on 80x25.
> I'm hoping it's just the same bug you've already fixed.

Looks to be a different bug. It just happened on a box with serial
console logging, on the same build I was testing the above patch on --
Linus master circa Oct 7th. This seems to be specific to TCP. I'm not
sure what is with all of the doubled backtraces. I've only seen this on
a couple of different boxes so far.

Full log at http://0x.ca/sim/ref/3.1-rc9/3.1-rc9-tcp-lockup.log

First 100 lines:

[516112.140013] BUG: soft lockup - CPU#0 stuck for 22s! [swapper:0]
[516112.144001] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[516112.144001] CPU 0 
[516112.144001] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[516112.144001] 
[516112.144001] Pid: 0, comm: swapper Not tainted 3.1.0-rc9-hw+ #48 Dell Inc. PowerEdge 1950/0UR033
[516112.144001] RIP: 0010:[<ffffffff816b6694>]  [<ffffffff816b6694>] _raw_spin_lock+0x14/0x20
[516112.144001] RSP: 0018:ffff88022fc03e10  EFLAGS: 00000297
[516112.144001] RAX: 0000000000000100 RBX: ffffffff81022674 RCX: ffffffff81b4df20
[516112.144001] RDX: ffff8801002aebe0 RSI: dead000000200200 RDI: ffff8801002ad188
[516112.144001] RBP: ffff88022fc03e10 R08: 00000000000000f7 R09: 0000000000000000
[516112.144001] R10: 0000000000000000 R11: 0000000000000010 R12: ffff88022fc03d88
[516112.144001] R13: ffffffff816bed1e R14: ffff88022fc03e10 R15: ffffffff81b4df00
[516112.144001] FS:  0000000000000000(0000) GS:ffff88022fc00000(0000) knlGS:0000000000000000
[516112.244020] BUG: soft lockup - CPU#1 stuck for 22s! [kworker/0:0:0]
[516112.244024] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[516112.244033] CPU 1 
[516112.244035] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[516112.244041] 
[516112.244044] Pid: 0, comm: kworker/0:0 Not tainted 3.1.0-rc9-hw+ #48 Dell Inc. PowerEdge 1950/0UR033
[516112.244048] RIP: 0010:[<ffffffff816b6694>]  [<ffffffff816b6694>] _raw_spin_lock+0x14/0x20
[516112.244057] RSP: 0018:ffff88022fc43e10  EFLAGS: 00000297
[516112.244059] RAX: 0000000000000100 RBX: ffffffff81022674 RCX: ffff880226888020
[516112.244062] RDX: ffff88001ece1aa0 RSI: dead000000200200 RDI: ffff88001ece1f88
[516112.244064] RBP: ffff88022fc43e10 R08: 00000000000000df R09: 0000000000000000
[516112.244066] R10: 0000000000000000 R11: 0000000000000010 R12: ffff88022fc43d88
[516112.244068] R13: ffffffff816bed1e R14: ffff88022fc43e10 R15: ffff880226888000
[516112.244071] FS:  0000000000000000(0000) GS:ffff88022fc40000(0000) knlGS:0000000000000000
[516112.244074] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[516112.244076] CR2: ffffffffff600400 CR3: 0000000126d93000 CR4: 00000000000006e0
[516112.244078] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[516112.244081] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[516112.244083] Process kworker/0:0 (pid: 0, threadinfo ffff880226918000, task ffff880226911640)
[516112.244085] Stack:
[516112.244086]  ffff88022fc43e40 ffffffff8162a613 0000000000000000 0000000000000000
[516112.244090]  ffff880226888000 ffff88001ece20e0 ffff88022fc43ee0 ffffffff810692dc
[516112.244094]  0000000000000000 ffff880226919fd8 ffff880226919fd8 ffff880226919fd8
[516112.244098] Call Trace:
[516112.244099]  <IRQ> 
[516112.244105]  [<ffffffff8162a613>] tcp_keepalive_timer+0x23/0x260
[516112.244110]  [<ffffffff810692dc>] run_timer_softirq+0x1ac/0x310
[516112.244113]  [<ffffffff8162a5f0>] ? tcp_init_xmit_timers+0x20/0x20
[516112.244118]  [<ffffffff8102e838>] ? lapic_next_event+0x18/0x20
[516112.244121]  [<ffffffff81060bf0>] __do_softirq+0xe0/0x1d0
[516112.244125]  [<ffffffff816c04ac>] call_softirq+0x1c/0x30
[516112.244129]  [<ffffffff81014255>] do_softirq+0x65/0xa0
[516112.244132]  [<ffffffff810608fd>] irq_exit+0xad/0xe0
[516112.244135]  [<ffffffff8102f569>] smp_apic_timer_interrupt+0x69/0xa0
[516112.244139]  [<ffffffff816bed1e>] apic_timer_interrupt+0x6e/0x80
[516112.244140]  <EOI> 
[516112.244144]  [<ffffffff8101a337>] ? mwait_idle+0x117/0x120
[516112.244147]  [<ffffffff810120c6>] cpu_idle+0x86/0xe0
[516112.244151]  [<ffffffff816ae77c>] start_secondary+0x1a3/0x1e7
[516112.244153] Code: 0f b6 c2 85 c0 c9 0f 95 c0 0f b6 c0 c3 66 2e 0f 1f 84 00 00 00 00 00 55 b8 00 01 00 00 48 89 e5 f0 66 0f c1 07 38 e0 74 06 f3 90 <8a> 07 eb f6 c9 c3 66 0f 1f 44 00 00 55 48 89 e5 9c 58 66 66 90 
[516112.244173] Call Trace:
[516112.244174]  <IRQ>  [<ffffffff8162a613>] tcp_keepalive_timer+0x23/0x260
[516112.244179]  [<ffffffff810692dc>] run_timer_softirq+0x1ac/0x310
[516112.244182]  [<ffffffff8162a5f0>] ? tcp_init_xmit_timers+0x20/0x20
[516112.244185]  [<ffffffff8102e838>] ? lapic_next_event+0x18/0x20
[516112.244188]  [<ffffffff81060bf0>] __do_softirq+0xe0/0x1d0
[516112.244191]  [<ffffffff816c04ac>] call_softirq+0x1c/0x30
[516112.244194]  [<ffffffff81014255>] do_softirq+0x65/0xa0
[516112.244197]  [<ffffffff810608fd>] irq_exit+0xad/0xe0
[516112.244199]  [<ffffffff8102f569>] smp_apic_timer_interrupt+0x69/0xa0
[516112.244202]  [<ffffffff816bed1e>] apic_timer_interrupt+0x6e/0x80
[516112.244204]  <EOI>  [<ffffffff8101a337>] ? mwait_idle+0x117/0x120
[516112.244209]  [<ffffffff810120c6>] cpu_idle+0x86/0xe0
[516112.244212]  [<ffffffff816ae77c>] start_secondary+0x1a3/0x1e7
[516112.344023] BUG: soft lockup - CPU#2 stuck for 23s! [php:1486]
[516112.344025] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[516112.344033] CPU 2 
[516112.344034] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[516112.344040] 
[516112.344042] Pid: 1486, comm: php Not tainted 3.1.0-rc9-hw+ #48 Dell Inc. PowerEdge 1950/0UR033
[516112.344046] RIP: 0010:[<ffffffff816b6694>]  [<ffffffff816b6694>] _raw_spin_lock+0x14/0x20
[516112.344051] RSP: 0000:ffff88022fc83e10  EFLAGS: 00000297
[516112.344053] RAX: 0000000000000100 RBX: ffffffff81022674 RCX: ffff880226920020
[516112.344056] RDX: ffff88022198c660 RSI: dead000000200200 RDI: ffff8800ac758cc8
[516112.344058] RBP: ffff88022fc83e10 R08: 00000000000000ef R09: 0000000000000000
[516112.344060] R10: 000000000000018b R11: 0000000000000010 R12: ffff88022fc83d88
[516112.344062] R13: ffffffff816bed1e R14: ffff88022fc83e10 R15: ffff880226920000
[516112.344065] FS:  00007faafda03720(0000) GS:ffff88022fc80000(0000) knlGS:0000000000000000
[516112.344068] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[516112.344070] CR2: ffffffffff600400 CR3: 00000002223de000 CR4: 00000000000006e0
[516112.344072] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[516112.344075] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[516112.344077] Process php (pid: 1486, threadinfo ffff880039262000, task ffff88003e675900)
[516112.344079] Stack:
[516112.344081]  ffff88022fc83e40 ffffffff8162a613 0000000000000000 0000000000000000
[516112.344084]  ffff880226920000 ffff8800ac758e20 ffff88022fc83ee0 ffffffff810692dc
[516112.344088]  0000000000000001 ffff880039263fd8 ffff880039263fd8 ffff880039263fd8
[516112.344091] Call Trace:
[516112.344093]  <IRQ> 
[516112.344099]  [<ffffffff8162a613>] tcp_keepalive_timer+0x23/0x260
[516112.344104]  [<ffffffff810692dc>] run_timer_softirq+0x1ac/0x310
[516112.344107]  [<ffffffff8162a5f0>] ? tcp_init_xmit_timers+0x20/0x20
[516112.344111]  [<ffffffff8102e838>] ? lapic_next_event+0x18/0x20
[516112.344115]  [<ffffffff81060bf0>] __do_softirq+0xe0/0x1d0
[516112.344119]  [<ffffffff816c04ac>] call_softirq+0x1c/0x30
[516112.344123]  [<ffffffff81014255>] do_softirq+0x65/0xa0

Simon-
