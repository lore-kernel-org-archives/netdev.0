From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Linux 3.1-rc9
Date: Tue, 25 Oct 2011 09:13:48 +0200
Message-ID: <CA+55aFwzAM6zhqCYJwoRxCdLJB+h84BDqzhF0RNQ6Jg9SQFjSA@mail.gmail.com>
References: <1318847658.6594.40.camel@twins> <CA+55aFxaGKEyhXdHXNxvPrPQ-SGSpbXdfoeXrxfjPx3VXsgvtg@mail.gmail.com>
 <1318874090.4172.84.camel@twins> <CA+55aFwCBy=4YK6amE=H-BYu9-boj4Po2Zkgf4V261mCx0DC4A@mail.gmail.com>
 <1318879396.4172.92.camel@twins> <alpine.LFD.2.02.1110172237030.3240@ionos>
 <alpine.LFD.2.02.1110181037120.3240@ionos> <1318928713.21167.4.camel@twins>
 <20111018182046.GF1309@hostway.ca> <alpine.LFD.2.02.1110182146440.3240@ionos> <20111024190203.GA24410@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>
To: Simon Kirby <sim@hostway.ca>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54562 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754376Ab1JYHOL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 03:14:11 -0400
In-Reply-To: <20111024190203.GA24410@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added netdev, because this seems to be a generic networking bug (ABBA
between sk_lock and icsk_retransmit_timer if my quick scan looks
correct).

Davem?

               Linus

On Mon, Oct 24, 2011 at 9:02 PM, Simon Kirby <sim@hostway.ca> wrote:
>
> Ok, hit the hang about 4 more times, but only this morning on a box w=
ith
> a serial cable attached. Yay!
>
> Simon-
>
> [216695.579770] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [216695.589435]
> [216695.589437] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [216695.593380] [ INFO: possible circular locking dependency detected=
 ]
> [216695.593380] 3.1.0-rc10-hw-lockdep+ #51
> [216695.593380] -----------------------------------------------------=
--
> [216695.593380] kworker/0:1/0 is trying to acquire lock:
> [216695.593380] =A0(&icsk->icsk_retransmit_timer){+.-.-.}, at: [<ffff=
ffff8106cc88>] run_timer_softirq+0x198/0x410
> [216695.593380]
> [216695.593380] but task is already holding lock:
> [216695.593380] =A0(slock-AF_INET){+.-.-.}, at: [<ffffffff81604540>] =
sk_clone+0x120/0x420
> [216695.593380]
> [216695.593380] which lock already depends on the new lock.
> [216695.593380]
> [216695.593380]
> [216695.593380] the existing dependency chain (in reverse order) is:
> [216695.593380]
> [216695.593380] -> #1 (slock-AF_INET){+.-.-.}:
> [216695.593380] =A0 =A0 =A0 =A0[<ffffffff8109a7b9>] lock_acquire+0x10=
9/0x140
> [216695.593380] =A0 =A0 =A0 =A0[<ffffffff816f55fc>] _raw_spin_lock+0x=
3c/0x50
> [216695.593380] =A0 =A0 =A0 =A0[<ffffffff81661cc3>] tcp_write_timer+0=
x23/0x230
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff8106cd5d>] run_timer_softirq=
+0x26d/0x410
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff810640b8>] __do_softirq+0x13=
8/0x250
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff817002bc>] call_softirq+0x1c=
/0x30
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff810153c5>] do_softirq+0x95/0=
xd0
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x1=
10
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff810310c9>] smp_apic_timer_in=
terrupt+0x69/0xa0
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff816feb33>] apic_timer_interr=
upt+0x73/0x80
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff81013156>] cpu_idle+0x96/0xf=
0
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff816ec4bb>] start_secondary+0=
x1ca/0x1ff
> [216695.682901]
> [216695.682901] -> #0 (&icsk->icsk_retransmit_timer){+.-.-.}:
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff8109a000>] __lock_acquire+0x=
2040/0x2180
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff8109a7b9>] lock_acquire+0x10=
9/0x140
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff8106cd09>] run_timer_softirq=
+0x219/0x410
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff810640b8>] __do_softirq+0x13=
8/0x250
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff817002bc>] call_softirq+0x1c=
/0x30
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff810153c5>] do_softirq+0x95/0=
xd0
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x1=
10
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff81014b74>] do_IRQ+0x64/0xe0
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff816f6273>] ret_from_intr+0x0=
/0x1a
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff81013156>] cpu_idle+0x96/0xf=
0
> [216695.682901] =A0 =A0 =A0 =A0[<ffffffff816ec4bb>] start_secondary+0=
x1ca/0x1ff
> [216695.682901]
> [216695.682901] other info that might help us debug this:
> [216695.682901]
> [216695.682901] =A0Possible unsafe locking scenario:
> [216695.682901]
> [216695.682901] =A0 =A0 =A0 =A0CPU0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0CPU1
> [216695.682901] =A0 =A0 =A0 =A0---- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0----
> [216695.682901] =A0 lock(slock-AF_INET);
> [216695.682901] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0lock(&icsk->icsk_retransmit_timer);
> [216695.682901] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0lock(slock-AF_INET);
> [216695.682901] =A0 lock(&icsk->icsk_retransmit_timer);
> [216695.682901]
> [216695.682901] =A0*** DEADLOCK ***
> [216695.682901]
> [216695.682901] 1 lock held by kworker/0:1/0:
> [216695.682901] =A0#0: =A0(slock-AF_INET){+.-.-.}, at: [<ffffffff8160=
4540>] sk_clone+0x120/0x420
> [216695.682901]
> [216695.682901] stack backtrace:
> [216695.682901] Pid: 0, comm: kworker/0:1 Not tainted 3.1.0-rc10-hw-l=
ockdep+ #51
> [216695.682901] Call Trace:
> [216695.682901] =A0<IRQ> =A0[<ffffffff81097eab>] print_circular_bug+0=
x21b/0x330
> [216695.682901] =A0[<ffffffff8109a000>] __lock_acquire+0x2040/0x2180
> [216695.682901] =A0[<ffffffffa001d6e2>] ? nf_conntrack_free+0x42/0x50=
 [nf_conntrack]
> [216695.682901] =A0[<ffffffffa001d6e2>] ? nf_conntrack_free+0x42/0x50=
 [nf_conntrack]
> [216695.682901] =A0[<ffffffff8109a7b9>] lock_acquire+0x109/0x140
> [216695.682901] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [216695.682901] =A0[<ffffffff81096b4c>] ? trace_hardirqs_on_caller+0x=
7c/0x1c0
> [216695.682901] =A0[<ffffffff8106cd09>] run_timer_softirq+0x219/0x410
> [216695.682901] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [216695.682901] =A0[<ffffffff816f16c1>] ? printk+0x67/0x69
> [216695.682901] =A0[<ffffffff81661ca0>] ? tcp_delack_timer+0x230/0x23=
0
> [216695.682901] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [216695.682901] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [216695.682901] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [216695.682901] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [216695.682901] =A0[<ffffffff81014b74>] do_IRQ+0x64/0xe0
> [216695.682901] =A0[<ffffffff816f6273>] common_interrupt+0x73/0x73
> [216695.682901] =A0<EOI> =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0=
x170
> [216695.682901] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [216695.682901] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [216695.682901] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [216696.019296] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000105?
> [216697.762956] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [216698.597297] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [216701.489681] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [216701.667999] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [216704.580592] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [216709.468971] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [216712.845904] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [216716.588502] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [216725.072958] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [216725.603879] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [216725.828374] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [216727.588978] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [216735.513864] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [216740.581530] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [216756.278571] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [218855.312903] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [218855.323133] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [218858.293355] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [218864.301938] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [218876.333821] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [218885.332651] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [218900.313590] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [220821.012017] TCP: Peer 32.176.160.153:49226/80 unexpectedly shrunk=
 window 665256753:665268993 (repaired)
> [221075.224300] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221075.234579] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221075.277593] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221075.780515] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221075.780713] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221077.349279] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221077.905587] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [221077.915567] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [221081.498430] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221081.703277] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [221082.088513] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221082.167985] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221089.772578] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221090.487927] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [221090.686394] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221094.587131] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221105.255699] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000101, exited with 00000102?
> [221105.280699] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221105.291634] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221106.325794] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221107.286029] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221107.622736] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221107.734471] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [221120.381643] huh, entered softirq 3 NET_RX ffffffff81613740 preemp=
t_count 00000102, exited with 00000103?
> [223936.264020] BUG: soft lockup - CPU#0 stuck for 22s! [swapper:0]
> [223936.268002] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223936.268002] irq event stamp: 2595159887
> [223936.268002] hardirqs last =A0enabled at (2595159887): [<ffffffff8=
101b805>] mwait_idle+0x145/0x170
> [223936.268002] hardirqs last disabled at (2595159886): [<ffffffff810=
13139>] cpu_idle+0x79/0xf0
> [223936.268002] softirqs last =A0enabled at (2595159878): [<ffffffff8=
1064176>] __do_softirq+0x1f6/0x250
> [223936.268002] softirqs last disabled at (2595159873): [<ffffffff817=
002bc>] call_softirq+0x1c/0x30
> [223936.268002] CPU 0
> [223936.268002] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223936.268002]
> [223936.268002] Pid: 0, comm: swapper Not tainted 3.1.0-rc10-hw-lockd=
ep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223936.268002] RIP: 0010:[<ffffffff813a4ee3>] =A0[<ffffffff813a4ee3>=
] delay_tsc+0x73/0xd0
> [223936.268002] RSP: 0018:ffff88022fc03cf0 =A0EFLAGS: 00000202
> [223936.268002] RAX: 00017b5d5932dd02 RBX: ffffffff816f6334 RCX: 0000=
00005932dd02
> [223936.372028] BUG: soft lockup - CPU#1 stuck for 22s! [kworker/0:0:=
0]
> [223936.372031] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223936.372042] irq event stamp: 2598787699
> [223936.372044] hardirqs last =A0enabled at (2598787699): [<ffffffff8=
101b805>] mwait_idle+0x145/0x170
> [223936.372054] hardirqs last disabled at (2598787698): [<ffffffff810=
13139>] cpu_idle+0x79/0xf0
> [223936.372058] softirqs last =A0enabled at (2598787696): [<ffffffff8=
1064176>] __do_softirq+0x1f6/0x250
> [223936.372063] softirqs last disabled at (2598787681): [<ffffffff817=
002bc>] call_softirq+0x1c/0x30
> [223936.372069] CPU 1
> [223936.372070] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223936.372079]
> [223936.372081] Pid: 0, comm: kworker/0:0 Not tainted 3.1.0-rc10-hw-l=
ockdep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223936.372086] RIP: 0010:[<ffffffff8101afab>] =A0[<ffffffff8101afab>=
] native_read_tsc+0xb/0x20
> [223936.372091] RSP: 0018:ffff88022fc43ce0 =A0EFLAGS: 00000202
> [223936.372093] RAX: 0000000000017b5d RBX: ffffffff816f6334 RCX: 0000=
0000652f810e
> [223936.372096] RDX: 0000000000017b5d RSI: 0000000000000000 RDI: 0000=
000000000001
> [223936.372098] RBP: ffff88022fc43ce0 R08: 00000000652f80c8 R09: 0000=
000000000000
> [223936.372101] R10: ffff88022690dd60 R11: 0000000000000000 R12: ffff=
88022fc43c58
> [223936.372103] R13: ffffffff816feb33 R14: ffff88022fc43ce0 R15: 0000=
0000180bbeb8
> [223936.372106] FS: =A00000000000000000(0000) GS:ffff88022fc40000(000=
0) knlGS:0000000000000000
> [223936.372108] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223936.372111] CR2: 00007f472ba6a6fc CR3: 0000000126bb7000 CR4: 0000=
0000000006e0
> [223936.372113] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223936.372116] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223936.372119] Process kworker/0:0 (pid: 0, threadinfo ffff880226928=
000, task ffff88022690dd60)
> [223936.372121] Stack:
> [223936.372123] =A0ffff88022fc43d30 ffffffff813a4eaf ffff880226928000=
 00000000652f8090
> [223936.372128] =A0000000012fc43d18 ffff88002e90e348 00000000180bbeb8=
 000000006efcdc62
> [223936.372132] =A00000000000000001 ffff88022690dd60 ffff88022fc43d40=
 ffffffff813a4f6a
> [223936.372136] Call Trace:
> [223936.372139] =A0<IRQ>
> [223936.372144] =A0[<ffffffff813a4eaf>] delay_tsc+0x3f/0xd0
> [223936.372148] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223936.372153] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223936.372159] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223936.372164] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223936.372168] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223936.372174] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223936.372178] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223936.372182] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223936.372186] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223936.372190] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223936.372194] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223936.372198] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223936.372203] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223936.372208] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223936.372210] =A0<EOI>
> [223936.372214] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.372218] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223936.372222] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.372226] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223936.372230] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223936.372233] Code: a1 00 48 c7 43 08 00 00 00 00 48 89 03 48 83 c4=
 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 0f 31 89 c=
1 48 89 d0
> [223936.372253] =A0c1 e0 20 89 ca 48 09 d0 c9 c3 66 2e 0f 1f 84 00 00=
 00 00 00
> [223936.372262] Call Trace:
> [223936.372264] =A0<IRQ> =A0[<ffffffff813a4eaf>] delay_tsc+0x3f/0xd0
> [223936.372269] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223936.372272] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223936.372276] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223936.372280] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223936.372283] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223936.372286] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223936.372289] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223936.372293] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223936.372297] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223936.372300] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223936.372303] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223936.372307] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223936.372310] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223936.372313] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223936.372315] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223936.372321] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223936.372324] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.372327] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223936.372331] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223936.476032] BUG: soft lockup - CPU#2 stuck for 23s! [kworker/0:1:=
0]
> [223936.476034] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223936.476043] irq event stamp: 2613824057
> [223936.476045] hardirqs last =A0enabled at (2613824057): [<ffffffff8=
101b805>] mwait_idle+0x145/0x170
> [223936.476050] hardirqs last disabled at (2613824056): [<ffffffff810=
13139>] cpu_idle+0x79/0xf0
> [223936.476054] softirqs last =A0enabled at (2613824048): [<ffffffff8=
1064176>] __do_softirq+0x1f6/0x250
> [223936.476058] softirqs last disabled at (2613824031): [<ffffffff817=
002bc>] call_softirq+0x1c/0x30
> [223936.476062] CPU 2
> [223936.476063] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223936.476071]
> [223936.476073] Pid: 0, comm: kworker/0:1 Not tainted 3.1.0-rc10-hw-l=
ockdep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223936.476077] RIP: 0010:[<ffffffff8101afa6>] =A0[<ffffffff8101afa6>=
] native_read_tsc+0x6/0x20
> [223936.476082] RSP: 0018:ffff88022fc83ce0 =A0EFLAGS: 00000202
> [223936.476084] RAX: 0000000070ba7dfc RBX: ffffffff813a60ae RCX: 0000=
000070ba7dc4
> [223936.476086] RDX: 0000000000017b5d RSI: 0000000000000000 RDI: 0000=
000000000001
> [223936.476089] RBP: ffff88022fc83ce0 R08: 0000000070ba7d7e R09: 0000=
000000000000
> [223936.476091] R10: ffff880226948000 R11: 0000000000000000 R12: ffff=
88022fc83c58
> [223936.476093] R13: ffffffff816feb33 R14: ffff88022fc83ce0 R15: 0000=
0000182285f9
> [223936.476096] FS: =A00000000000000000(0000) GS:ffff88022fc80000(000=
0) knlGS:0000000000000000
> [223936.476099] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223936.476101] CR2: 00007f25e7874d7f CR3: 0000000124c0d000 CR4: 0000=
0000000006e0
> [223936.476104] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223936.476106] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223936.476109] Process kworker/0:1 (pid: 0, threadinfo ffff88022693e=
000, task ffff880226948000)
> [223936.476111] Stack:
> [223936.476113] =A0ffff88022fc83d30 ffffffff813a4ee8 ffff88022693e000=
 0000000070ba7dc4
> [223936.476117] =A000000002ffffff10 ffff88006afd8948 00000000182285f9=
 000000006efcdc62
> [223936.476121] =A00000000000000001 ffff880226948000 ffff88022fc83d40=
 ffffffff813a4f6a
> [223936.476126] Call Trace:
> [223936.476128] =A0<IRQ>
> [223936.476132] =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223936.476136] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223936.476141] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223936.476147] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223936.476153] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223936.476157] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223936.476163] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223936.476167] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223936.476171] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223936.476176] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223936.476180] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223936.476184] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223936.476187] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223936.476193] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223936.476197] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223936.476199] =A0<EOI>
> [223936.476203] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.476207] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223936.476211] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.476215] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223936.476219] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223936.476222] Code: 08 ff 15 46 5c a1 00 48 c7 43 08 00 00 00 00 48=
 89 03 48 83 c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8=
9 e5 0f 31
> [223936.476241] =A0c1 48 89 d0 48 c1 e0 20 89 ca 48 09 d0 c9 c3 66 2e=
 0f 1f 84
> [223936.476251] Call Trace:
> [223936.476252] =A0<IRQ> =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223936.476257] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223936.476261] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223936.476265] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223936.476268] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223936.476272] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223936.476275] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223936.476278] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223936.476282] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223936.476286] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223936.476289] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223936.476292] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223936.476295] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223936.476299] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223936.476302] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223936.476304] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223936.476310] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223936.476313] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.476316] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223936.476320] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223936.580039] BUG: soft lockup - CPU#3 stuck for 23s! [kworker/0:1:=
0]
> [223936.580041] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223936.580050] irq event stamp: 2615464042
> [223936.580052] hardirqs last =A0enabled at (2615464042): [<ffffffff8=
16f5edb>] _raw_spin_unlock_irq+0x2b/0x50
> [223936.580057] hardirqs last disabled at (2615464041): [<ffffffff816=
f56a8>] _raw_spin_lock_irq+0x18/0x60
> [223936.580061] softirqs last =A0enabled at (2615463964): [<ffffffff8=
1063cce>] _local_bh_enable+0xe/0x10
> [223936.580065] softirqs last disabled at (2615463965): [<ffffffff817=
002bc>] call_softirq+0x1c/0x30
> [223936.580069] CPU 3
> [223936.580070] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223936.580078]
> [223936.580080] Pid: 0, comm: kworker/0:1 Not tainted 3.1.0-rc10-hw-l=
ockdep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223936.580085] RIP: 0010:[<ffffffff8101afa6>] =A0[<ffffffff8101afa6>=
] native_read_tsc+0x6/0x20
> [223936.580090] RSP: 0018:ffff88022fcc3ce0 =A0EFLAGS: 00000202
> [223936.580092] RAX: 000000007c457b06 RBX: ffffffff816f6334 RCX: 0000=
00007c457ad5
> [223936.580094] RDX: 0000000000017b5d RSI: ffffffff818f9896 RDI: 0000=
000000000001
> [223936.580097] RBP: ffff88022fcc3ce0 R08: 000000007c457a88 R09: 0000=
000000000000
> [223936.580099] R10: ffff880226981f20 R11: 0000000000000000 R12: ffff=
88022fcc3c58
> [223936.580101] R13: ffffffff816feb33 R14: ffff88022fcc3ce0 R15: 0000=
0000183a1380
> [223936.580104] FS: =A00000000000000000(0000) GS:ffff88022fcc0000(000=
0) knlGS:0000000000000000
> [223936.580107] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223936.580109] CR2: 0000000000f38820 CR3: 0000000104b52000 CR4: 0000=
0000000006e0
> [223936.580112] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223936.580114] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223936.580117] Process kworker/0:1 (pid: 0, threadinfo ffff880226988=
000, task ffff880226981f20)
> [223936.580119] Stack:
> [223936.580120] =A0ffff88022fcc3d30 ffffffff813a4ee8 ffff880226988000=
 000000007c457ad5
> [223936.580125] =A000000003ffffff10 ffff880031438948 00000000183a1380=
 000000006efcdc62
> [223936.580129] =A00000000000000001 ffff880226981f20 ffff88022fcc3d40=
 ffffffff813a4f6a
> [223936.580133] Call Trace:
> [223936.580135] =A0<IRQ>
> [223936.580138] =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223936.580142] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223936.580147] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223936.580151] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223936.580156] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223936.580160] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223936.580164] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223936.580168] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223936.580172] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223936.580176] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223936.580181] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223936.580185] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223936.580188] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223936.580192] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223936.580196] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223936.580199] =A0<EOI>
> [223936.580202] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.580206] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223936.580211] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.580214] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223936.580218] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223936.580221] Code: 08 ff 15 46 5c a1 00 48 c7 43 08 00 00 00 00 48=
 89 03 48 83 c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8=
9 e5 0f 31
> [223936.580240] =A0c1 48 89 d0 48 c1 e0 20 89 ca 48 09 d0 c9 c3 66 2e=
 0f 1f 84
> [223936.580250] Call Trace:
> [223936.580251] =A0<IRQ> =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223936.580256] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223936.580260] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223936.580264] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223936.580267] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223936.580270] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223936.580274] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223936.580277] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223936.580280] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223936.580284] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223936.580288] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223936.580291] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223936.580294] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223936.580297] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223936.580300] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223936.580302] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223936.580308] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223936.580312] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.580315] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223936.580318] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223936.268002] RDX: 000000005932dd02 RSI: ffffffff818f9896 RDI: 0000=
000000000001
> [223936.268002] RBP: ffff88022fc03d30 R08: 000000005932dcb5 R09: 0000=
000000000000
> [223936.268002] R10: ffffffff81a2b020 R11: 0000000000000000 R12: ffff=
88022fc03c68
> [223936.268002] R13: ffffffff816feb33 R14: ffff88022fc03d30 R15: 0000=
000017f328cd
> [223936.268002] FS: =A00000000000000000(0000) GS:ffff88022fc00000(000=
0) knlGS:0000000000000000
> [223936.268002] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223936.268002] CR2: 00007f25e7bc13a0 CR3: 00000001426fc000 CR4: 0000=
0000000006f0
> [223936.268002] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223936.268002] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223936.268002] Process swapper (pid: 0, threadinfo ffffffff819a6000,=
 task ffffffff81a2b020)
> [223936.268002] Stack:
> [223936.268002] =A0ffffffff819a6000 000000005932dd02 000000002fc03d18=
 ffff8801f6c22448
> [223936.268002] =A00000000017f328cd 000000006efcdc62 0000000000000001=
 ffffffff81a2b020
> [223936.268002] =A0ffff88022fc03d40 ffffffff813a4f6a ffff88022fc03d80=
 ffffffff813ac2ab
> [223936.268002] Call Trace:
> [223936.268002] =A0<IRQ>
> [223936.268002] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223936.268002] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223936.268002] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223936.268002] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223936.268002] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223936.268002] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223936.268002] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223936.268002] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223936.268002] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223936.268002] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223936.268002] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223936.268002] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223936.268002] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223936.268002] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223936.268002] =A0<EOI>
> [223936.268002] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.268002] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223936.268002] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.268002] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223936.268002] =A0[<ffffffff816ca491>] rest_init+0xd1/0xe0
> [223936.268002] =A0[<ffffffff816ca3c0>] ? csum_partial_copy_generic+0=
x170/0x170
> [223936.268002] =A0[<ffffffff81adcc55>] start_kernel+0x360/0x3ac
> [223936.268002] =A0[<ffffffff81adc2a2>] x86_64_start_reservations+0x8=
2/0x89
> [223936.268002] =A0[<ffffffff81adc3b8>] x86_64_start_kernel+0x10f/0x1=
2a
> [223936.268002] =A0[<ffffffff81adc140>] ? early_idt_handlers+0x140/0x=
140
> [223936.268002] Code: 4c 89 7d c8 eb 1f 66 90 48 8b 45 c0 83 68 1c 01=
 f3 90 83 40 1c 01 65 44 8b 3c 25 50 d3 00 00 44 3b 7d d4 75 3b 66 66 9=
0 0f ae e8 <e8> b8 60 c7 ff 66 90 4c 63 c0 4c 89 c0 48 2b 45 c8 48 39 d=
8 72
> [223936.268002] Call Trace:
> [223936.268002] =A0<IRQ> =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223936.268002] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223936.268002] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223936.268002] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223936.268002] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223936.268002] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223936.268002] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223936.268002] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223936.268002] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223936.268002] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223936.268002] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223936.268002] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223936.268002] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223936.268002] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223936.268002] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223936.268002] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223936.268002] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223936.268002] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223936.268002] =A0[<ffffffff816ca491>] rest_init+0xd1/0xe0
> [223936.268002] =A0[<ffffffff816ca3c0>] ? csum_partial_copy_generic+0=
x170/0x170
> [223936.268002] =A0[<ffffffff81adcc55>] start_kernel+0x360/0x3ac
> [223936.268002] =A0[<ffffffff81adc2a2>] x86_64_start_reservations+0x8=
2/0x89
> [223936.268002] =A0[<ffffffff81adc3b8>] x86_64_start_kernel+0x10f/0x1=
2a
> [223936.268002] =A0[<ffffffff81adc140>] ? early_idt_handlers+0x140/0x=
140
> [223964.264018] BUG: soft lockup - CPU#0 stuck for 22s! [swapper:0]
> [223964.268002] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223964.268002] irq event stamp: 2595159887
> [223964.268002] hardirqs last =A0enabled at (2595159887): [<ffffffff8=
101b805>] mwait_idle+0x145/0x170
> [223964.268002] hardirqs last disabled at (2595159886): [<ffffffff810=
13139>] cpu_idle+0x79/0xf0
> [223964.268002] softirqs last =A0enabled at (2595159878): [<ffffffff8=
1064176>] __do_softirq+0x1f6/0x250
> [223964.268002] softirqs last disabled at (2595159873): [<ffffffff817=
002bc>] call_softirq+0x1c/0x30
> [223964.268002] CPU 0
> [223964.268002] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223964.268002]
> [223964.268002] Pid: 0, comm: swapper Not tainted 3.1.0-rc10-hw-lockd=
ep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223964.268002] RIP: 0010:[<ffffffff8101afa6>] =A0[<ffffffff8101afa6>=
] native_read_tsc+0x6/0x20
> [223964.268002] RSP: 0018:ffff88022fc03ce0 =A0EFLAGS: 00000202
> [223964.268002] RAX: 000000007cb6c61b RBX: ffffffff816f6334 RCX: 0000=
00007cb6c5e3
> [223964.372025] BUG: soft lockup - CPU#1 stuck for 23s! [kworker/0:0:=
0]
> [223964.372027] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223964.372036] irq event stamp: 2598787699
> [223964.372037] hardirqs last =A0enabled at (2598787699): [<ffffffff8=
101b805>] mwait_idle+0x145/0x170
> [223964.372042] hardirqs last disabled at (2598787698): [<ffffffff810=
13139>] cpu_idle+0x79/0xf0
> [223964.372045] softirqs last =A0enabled at (2598787696): [<ffffffff8=
1064176>] __do_softirq+0x1f6/0x250
> [223964.372049] softirqs last disabled at (2598787681): [<ffffffff817=
002bc>] call_softirq+0x1c/0x30
> [223964.372052] CPU 1
> [223964.372053] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223964.372061]
> [223964.372063] Pid: 0, comm: kworker/0:0 Not tainted 3.1.0-rc10-hw-l=
ockdep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223964.372067] RIP: 0010:[<ffffffff8101afa0>] =A0[<ffffffff8101afa0>=
] read_persistent_clock+0x30/0x30
> [223964.372072] RSP: 0018:ffff88022fc43ce8 =A0EFLAGS: 00000202
> [223964.372074] RAX: 0000000000000001 RBX: ffff88022fc43c68 RCX: 0000=
000088b369fd
> [223964.372076] RDX: 0000000000000200 RSI: 0000000000000000 RDI: 0000=
000000000001
> [223964.372078] RBP: ffff88022fc43d30 R08: ffffffff88b369fd R09: 0000=
000000000000
> [223964.372081] R10: ffff88022690dd60 R11: 0000000000000000 R12: ffff=
88022fc43c58
> [223964.372083] R13: ffffffff816feb33 R14: ffff88022fc43d30 R15: 0000=
0000307e58b4
> [223964.372086] FS: =A00000000000000000(0000) GS:ffff88022fc40000(000=
0) knlGS:0000000000000000
> [223964.372089] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223964.372091] CR2: 00007f472ba6a6fc CR3: 0000000126bb7000 CR4: 0000=
0000000006e0
> [223964.372093] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223964.372096] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223964.372098] Process kworker/0:0 (pid: 0, threadinfo ffff880226928=
000, task ffff88022690dd60)
> [223964.372100] Stack:
> [223964.372102] =A0ffffffff813a4eaf ffff880226928000 ffffffff88b369c5=
 000000012fc43d18
> [223964.372106] =A0ffff88002e90e348 00000000307e58b4 000000006efcdc62=
 0000000000000001
> [223964.372111] =A0ffff88022690dd60 ffff88022fc43d40 ffffffff813a4f6a=
 ffff88022fc43d80
> [223964.372115] Call Trace:
> [223964.372116] =A0<IRQ>
> [223964.372119] =A0[<ffffffff813a4eaf>] ? delay_tsc+0x3f/0xd0
> [223964.372123] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223964.372127] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223964.372132] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223964.372136] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223964.372140] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223964.372144] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223964.372148] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223964.372153] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223964.372158] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223964.372162] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223964.372166] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223964.372170] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223964.372174] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223964.372178] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223964.372180] =A0<EOI>
> [223964.372184] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.372188] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223964.372192] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.372196] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223964.372200] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223964.372203] Code: 48 89 fb 48 83 ec 08 ff 15 46 5c a1 00 48 c7 43=
 08 00 00 00 00 48 89 03 48 83 c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 0=
0 00 00 00
> [223964.372221] =A048 89 e5 0f 31 89 c1 48 89 d0 48 c1 e0 20 89 ca 48=
 09 d0 c9
> [223964.372231] Call Trace:
> [223964.372232] =A0<IRQ> =A0[<ffffffff813a4eaf>] ? delay_tsc+0x3f/0xd=
0
> [223964.372237] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223964.372241] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223964.372245] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223964.372248] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223964.372251] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223964.372255] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223964.372258] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223964.372261] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223964.372265] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223964.372268] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223964.372271] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223964.372275] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223964.372278] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223964.372281] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223964.372282] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223964.372288] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223964.372292] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.372295] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223964.372298] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223964.476031] BUG: soft lockup - CPU#2 stuck for 23s! [kworker/0:1:=
0]
> [223964.476033] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223964.476042] irq event stamp: 2613824057
> [223964.476043] hardirqs last =A0enabled at (2613824057): [<ffffffff8=
101b805>] mwait_idle+0x145/0x170
> [223964.476048] hardirqs last disabled at (2613824056): [<ffffffff810=
13139>] cpu_idle+0x79/0xf0
> [223964.476051] softirqs last =A0enabled at (2613824048): [<ffffffff8=
1064176>] __do_softirq+0x1f6/0x250
> [223964.476055] softirqs last disabled at (2613824031): [<ffffffff817=
002bc>] call_softirq+0x1c/0x30
> [223964.476059] CPU 2
> [223964.476060] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223964.476067]
> [223964.476070] Pid: 0, comm: kworker/0:1 Not tainted 3.1.0-rc10-hw-l=
ockdep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223964.476074] RIP: 0010:[<ffffffff8101afa6>] =A0[<ffffffff8101afa6>=
] native_read_tsc+0x6/0x20
> [223964.476078] RSP: 0018:ffff88022fc83ce0 =A0EFLAGS: 00000206
> [223964.476080] RAX: 00000000943e6715 RBX: ffffffff816f6334 RCX: 0000=
0000943e66dd
> [223964.476083] RDX: 0000000000017b69 RSI: 0000000000000000 RDI: 0000=
000000000001
> [223964.476085] RBP: ffff88022fc83ce0 R08: ffffffff943e6697 R09: 0000=
000000000000
> [223964.476087] R10: ffff880226948000 R11: 0000000000000000 R12: ffff=
88022fc83c58
> [223964.476090] R13: ffffffff816feb33 R14: ffff88022fc83ce0 R15: 0000=
00003094ad30
> [223964.476092] FS: =A00000000000000000(0000) GS:ffff88022fc80000(000=
0) knlGS:0000000000000000
> [223964.476095] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223964.476097] CR2: 00007f25e7874d7f CR3: 0000000124c0d000 CR4: 0000=
0000000006e0
> [223964.476100] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223964.476102] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223964.476105] Process kworker/0:1 (pid: 0, threadinfo ffff88022693e=
000, task ffff880226948000)
> [223964.476107] Stack:
> [223964.476108] =A0ffff88022fc83d30 ffffffff813a4ee8 ffff88022693e000=
 ffffffff943e66dd
> [223964.476113] =A000000002ffffff10 ffff88006afd8948 000000003094ad30=
 000000006efcdc62
> [223964.476117] =A00000000000000001 ffff880226948000 ffff88022fc83d40=
 ffffffff813a4f6a
> [223964.476121] Call Trace:
> [223964.476123] =A0<IRQ>
> [223964.476126] =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223964.476130] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223964.476134] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223964.476139] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223964.476143] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223964.476147] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223964.476151] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223964.476155] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223964.476159] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223964.476164] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223964.476168] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223964.476172] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223964.476176] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223964.476180] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223964.476184] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223964.476186] =A0<EOI>
> [223964.476190] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.476194] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223964.476198] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.476202] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223964.476206] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223964.476208] Code: 08 ff 15 46 5c a1 00 48 c7 43 08 00 00 00 00 48=
 89 03 48 83 c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8=
9 e5 0f 31
> [223964.476227] =A0c1 48 89 d0 48 c1 e0 20 89 ca 48 09 d0 c9 c3 66 2e=
 0f 1f 84
> [223964.476236] Call Trace:
> [223964.476238] =A0<IRQ> =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223964.476243] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223964.476246] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223964.476250] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223964.476254] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223964.476257] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223964.476260] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223964.476264] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223964.476267] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223964.476271] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223964.476274] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223964.476277] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223964.476281] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223964.476284] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223964.476287] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223964.476289] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223964.476295] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223964.476298] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.476301] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223964.476304] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223964.580038] BUG: soft lockup - CPU#3 stuck for 23s! [kworker/0:1:=
0]
> [223964.580040] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223964.580049] irq event stamp: 2615464042
> [223964.580050] hardirqs last =A0enabled at (2615464042): [<ffffffff8=
16f5edb>] _raw_spin_unlock_irq+0x2b/0x50
> [223964.580054] hardirqs last disabled at (2615464041): [<ffffffff816=
f56a8>] _raw_spin_lock_irq+0x18/0x60
> [223964.580058] softirqs last =A0enabled at (2615463964): [<ffffffff8=
1063cce>] _local_bh_enable+0xe/0x10
> [223964.580062] softirqs last disabled at (2615463965): [<ffffffff817=
002bc>] call_softirq+0x1c/0x30
> [223964.580066] CPU 3
> [223964.580067] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223964.580075]
> [223964.580077] Pid: 0, comm: kworker/0:1 Not tainted 3.1.0-rc10-hw-l=
ockdep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223964.580081] RIP: 0010:[<ffffffff8101afa6>] =A0[<ffffffff8101afa6>=
] native_read_tsc+0x6/0x20
> [223964.580086] RSP: 0018:ffff88022fcc3ce0 =A0EFLAGS: 00000206
> [223964.580088] RAX: 000000009fc963af RBX: ffffffff816f6334 RCX: 0000=
00009fc96377
> [223964.580090] RDX: 0000000000017b69 RSI: ffffffff818f9896 RDI: 0000=
000000000001
> [223964.580093] RBP: ffff88022fcc3ce0 R08: ffffffff9fc96331 R09: 0000=
000000000000
> [223964.580095] R10: ffff880226981f20 R11: 0000000000000000 R12: ffff=
88022fcc3c58
> [223964.580097] R13: ffffffff816feb33 R14: ffff88022fcc3ce0 R15: 0000=
000030ac88b0
> [223964.580100] FS: =A00000000000000000(0000) GS:ffff88022fcc0000(000=
0) knlGS:0000000000000000
> [223964.580103] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223964.580105] CR2: 0000000000f38820 CR3: 0000000104b52000 CR4: 0000=
0000000006e0
> [223964.580107] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223964.580110] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223964.580112] Process kworker/0:1 (pid: 0, threadinfo ffff880226988=
000, task ffff880226981f20)
> [223964.580114] Stack:
> [223964.580116] =A0ffff88022fcc3d30 ffffffff813a4ee8 ffff880226988000=
 ffffffff9fc96377
> [223964.580120] =A0000000039c3b34d8 ffff880031438948 0000000030ac88b0=
 000000006efcdc62
> [223964.580124] =A00000000000000001 ffff880226981f20 ffff88022fcc3d40=
 ffffffff813a4f6a
> [223964.580128] Call Trace:
> [223964.580130] =A0<IRQ>
> [223964.580133] =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223964.580137] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223964.580141] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223964.580146] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223964.580150] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223964.580154] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223964.580158] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223964.580162] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223964.580167] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223964.580171] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223964.580176] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223964.580180] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223964.580184] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223964.580188] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223964.580192] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223964.580194] =A0<EOI>
> [223964.580198] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.580202] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223964.580206] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.580210] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223964.580214] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223964.580217] Code: 08 ff 15 46 5c a1 00 48 c7 43 08 00 00 00 00 48=
 89 03 48 83 c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8=
9 e5 0f 31
> [223964.580235] =A0c1 48 89 d0 48 c1 e0 20 89 ca 48 09 d0 c9 c3 66 2e=
 0f 1f 84
> [223964.580245] Call Trace:
> [223964.580246] =A0<IRQ> =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223964.580252] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223964.580255] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223964.580259] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223964.580262] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223964.580265] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223964.580269] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223964.580272] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223964.580276] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223964.580279] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223964.580283] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223964.580286] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223964.580289] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223964.580292] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223964.580295] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223964.580297] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223964.580303] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223964.580307] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.580310] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223964.580313] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223964.268002] RDX: 0000000000017b69 RSI: ffffffff818f9896 RDI: 0000=
000000000001
> [223964.268002] RBP: ffff88022fc03ce0 R08: 000000007cb6c596 R09: 0000=
000000000000
> [223964.268002] R10: ffffffff81a2b020 R11: 0000000000000000 R12: ffff=
88022fc03c58
> [223964.268002] R13: ffffffff816feb33 R14: ffff88022fc03ce0 R15: 0000=
00002eb85d38
> [223964.268002] FS: =A00000000000000000(0000) GS:ffff88022fc00000(000=
0) knlGS:0000000000000000
> [223964.268002] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223964.268002] CR2: 00007f25e7bc13a0 CR3: 00000001426fc000 CR4: 0000=
0000000006f0
> [223964.268002] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223964.268002] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223964.268002] Process swapper (pid: 0, threadinfo ffffffff819a6000,=
 task ffffffff81a2b020)
> [223964.268002] Stack:
> [223964.268002] =A0ffff88022fc03d30 ffffffff813a4ee8 ffffffff819a6000=
 000000007cb6c5e3
> [223964.268002] =A0000000007c44ac9c ffff8801f6c22448 000000002eb85d38=
 000000006efcdc62
> [223964.268002] =A00000000000000001 ffffffff81a2b020 ffff88022fc03d40=
 ffffffff813a4f6a
> [223964.268002] Call Trace:
> [223964.268002] =A0<IRQ>
> [223964.268002] =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223964.268002] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223964.268002] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223964.268002] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223964.268002] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223964.268002] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223964.268002] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223964.268002] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223964.268002] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223964.268002] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223964.268002] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223964.268002] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223964.268002] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223964.268002] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223964.268002] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223964.268002] =A0<EOI>
> [223964.268002] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.268002] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223964.268002] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.268002] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223964.268002] =A0[<ffffffff816ca491>] rest_init+0xd1/0xe0
> [223964.268002] =A0[<ffffffff816ca3c0>] ? csum_partial_copy_generic+0=
x170/0x170
> [223964.268002] =A0[<ffffffff81adcc55>] start_kernel+0x360/0x3ac
> [223964.268002] =A0[<ffffffff81adc2a2>] x86_64_start_reservations+0x8=
2/0x89
> [223964.268002] =A0[<ffffffff81adc3b8>] x86_64_start_kernel+0x10f/0x1=
2a
> [223964.268002] =A0[<ffffffff81adc140>] ? early_idt_handlers+0x140/0x=
140
> [223964.268002] Code: 08 ff 15 46 5c a1 00 48 c7 43 08 00 00 00 00 48=
 89 03 48 83 c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8=
9 e5 0f 31
> [223964.268002] =A0c1 48 89 d0 48 c1 e0 20 89 ca 48 09 d0 c9 c3 66 2e=
 0f 1f 84
> [223964.268002] Call Trace:
> [223964.268002] =A0<IRQ> =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223964.268002] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223964.268002] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223964.268002] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223964.268002] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223964.268002] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223964.268002] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223964.268002] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223964.268002] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223964.268002] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223964.268002] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223964.268002] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223964.268002] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223964.268002] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223964.268002] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223964.268002] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223964.268002] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223964.268002] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223964.268002] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223964.268002] =A0[<ffffffff816ca491>] rest_init+0xd1/0xe0
> [223964.268002] =A0[<ffffffff816ca3c0>] ? csum_partial_copy_generic+0=
x170/0x170
> [223964.268002] =A0[<ffffffff81adcc55>] start_kernel+0x360/0x3ac
> [223964.268002] =A0[<ffffffff81adc2a2>] x86_64_start_reservations+0x8=
2/0x89
> [223964.268002] =A0[<ffffffff81adc3b8>] x86_64_start_kernel+0x10f/0x1=
2a
> [223964.268002] =A0[<ffffffff81adc140>] ? early_idt_handlers+0x140/0x=
140
> [223968.815995] INFO: rcu_sched_state detected stall on CPU 1 (t=3D15=
000 jiffies)
> [223968.819995] INFO: rcu_sched_state detected stalls on CPUs/tasks: =
{ 1} (detected by 3, t=3D15002 jiffies)
> [223968.820000] sending NMI to all CPUs:
> [223968.820002] NMI backtrace for cpu 3
> [223968.820002] CPU 3
> [223968.820002] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223968.820002]
> [223968.820002] Pid: 0, comm: kworker/0:1 Not tainted 3.1.0-rc10-hw-l=
ockdep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223968.820002] RIP: 0010:[<ffffffff813a4f86>] =A0[<ffffffff813a4f86>=
] __const_udelay+0x16/0x40
> [223968.820002] RSP: 0018:ffff88022fcc3a90 =A0EFLAGS: 00000002
> [223968.820002] RAX: 0000000000e34d8a RBX: 0000000000000001 RCX: 0000=
000001062560
> [223968.820002] RDX: 000000000071a6c5 RSI: 0000000000000002 RDI: 0000=
000000418958
> [223968.820002] RBP: ffff88022fcc3ab0 R08: 0000000000000002 R09: 0000=
000000000000
> [223968.820002] R10: 0000000000000006 R11: 000000000000000a R12: ffff=
ffff81a40d80
> [223968.820002] R13: 0000000000000010 R14: ffffffff81a40e40 R15: ffff=
ffff81a40fc0
> [223968.820002] FS: =A00000000000000000(0000) GS:ffff88022fcc0000(000=
0) knlGS:0000000000000000
> [223968.820002] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223968.820002] CR2: 0000000000f38820 CR3: 0000000104b52000 CR4: 0000=
0000000006e0
> [223968.820002] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223968.820002] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223968.820002] Process kworker/0:1 (pid: 0, threadinfo ffff880226988=
000, task ffff880226981f20)
> [223968.820002] Stack:
> [223968.820002] =A0ffff88022fcc3ab0 ffffffff81031695 ffff88022fccdfa0=
 ffff88022fccdfa0
> [223968.820002] =A0ffff88022fcc3af0 ffffffff810bb9d2 ffffffff81a40fc0=
 0000000000000003
> [223968.820002] =A00000000000000003 ffff880226981f20 ffffffff810921f0=
 ffff88022fcc3be0
> [223968.820002] Call Trace:
> [223968.820002] =A0<IRQ>
> [223968.820002] =A0[<ffffffff81031695>] ? arch_trigger_all_cpu_backtr=
ace+0x65/0x90
> [223968.820002] =A0[<ffffffff810bb9d2>] __rcu_pending+0x382/0x3b0
> [223968.820002] =A0[<ffffffff810921f0>] ? tick_nohz_handler+0x100/0x1=
00
> [223968.820002] =A0[<ffffffff810bba67>] rcu_check_callbacks+0x67/0x13=
0
> [223968.820002] =A0[<ffffffff8106d861>] update_process_times+0x41/0x8=
0
> [223968.820002] =A0[<ffffffff81092256>] tick_sched_timer+0x66/0xc0
> [223968.820002] =A0[<ffffffff810845ee>] __run_hrtimer+0xfe/0x1e0
> [223968.820002] =A0[<ffffffff8108491d>] hrtimer_interrupt+0xcd/0x1f0
> [223968.820002] =A0[<ffffffff810310c4>] smp_apic_timer_interrupt+0x64=
/0xa0
> [223968.820002] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.820002] =A0[<ffffffff816f6334>] ? retint_restore_args+0x13/0x=
13
> [223968.820002] =A0[<ffffffff8101afa6>] ? native_read_tsc+0x6/0x20
> [223968.820002] =A0[<ffffffff813a4eaf>] delay_tsc+0x3f/0xd0
> [223968.820002] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223968.820002] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223968.820002] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223968.820002] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223968.820002] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223968.820002] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223968.820002] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223968.820002] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223968.820002] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223968.820002] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223968.820002] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223968.820002] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223968.820002] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223968.820002] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.820002] =A0<EOI>
> [223968.820002] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.820002] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223968.820002] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.820002] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223968.820002] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223968.820002] Code: 00 00 00 00 00 55 48 89 e5 ff 15 8e a5 6c 00 c9=
 c3 0f 1f 40 00 55 48 8d 0c bd 00 00 00 00 65 48 8b 14 25 58 2d 01 00 4=
8 8d 04 12
> [223968.820002] =A0c1 e2 06 48 89 e5 48 29 c2 48 89 c8 f7 e2 48 8d 7a=
 01 ff 15
> [223968.820002] Call Trace:
> [223968.820002] =A0<IRQ> =A0[<ffffffff81031695>] ? arch_trigger_all_c=
pu_backtrace+0x65/0x90
> [223968.820002] =A0[<ffffffff810bb9d2>] __rcu_pending+0x382/0x3b0
> [223968.820002] =A0[<ffffffff810921f0>] ? tick_nohz_handler+0x100/0x1=
00
> [223968.820002] =A0[<ffffffff810bba67>] rcu_check_callbacks+0x67/0x13=
0
> [223968.820002] =A0[<ffffffff8106d861>] update_process_times+0x41/0x8=
0
> [223968.820002] =A0[<ffffffff81092256>] tick_sched_timer+0x66/0xc0
> [223968.820002] =A0[<ffffffff810845ee>] __run_hrtimer+0xfe/0x1e0
> [223968.820002] =A0[<ffffffff8108491d>] hrtimer_interrupt+0xcd/0x1f0
> [223968.820002] =A0[<ffffffff810310c4>] smp_apic_timer_interrupt+0x64=
/0xa0
> [223968.820002] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.820002] =A0[<ffffffff816f6334>] ? retint_restore_args+0x13/0x=
13
> [223968.820002] =A0[<ffffffff8101afa6>] ? native_read_tsc+0x6/0x20
> [223968.820002] =A0[<ffffffff813a4eaf>] delay_tsc+0x3f/0xd0
> [223968.820002] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223968.820002] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223968.820002] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223968.820002] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223968.820002] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223968.820002] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223968.820002] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223968.820002] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223968.820002] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223968.820002] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223968.820002] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223968.820002] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223968.820002] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223968.820002] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.820002] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223968.820002] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223968.820002] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.820002] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223968.820002] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223968.820335] NMI backtrace for cpu 0
> [223968.820337] CPU 0
> [223968.820338] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223968.820347]
> [223968.820349] Pid: 0, comm: swapper Not tainted 3.1.0-rc10-hw-lockd=
ep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223968.820353] RIP: 0010:[<ffffffff813a4ef0>] =A0[<ffffffff813a4ef0>=
] delay_tsc+0x80/0xd0
> [223968.820358] RSP: 0018:ffff88022fc03cf0 =A0EFLAGS: 00000206
> [223968.820360] RAX: 000000007659b10f RBX: 0000000000000001 RCX: 0000=
00007659b10f
> [223968.820363] RDX: 000000007659b10f RSI: ffffffff818f9896 RDI: 0000=
000000000001
> [223968.820365] RBP: ffff88022fc03d30 R08: 000000007659b10f R09: 0000=
000000000000
> [223968.820367] R10: ffffffff81a2b020 R11: 0000000000000000 R12: 0000=
000031026962
> [223968.820370] R13: 000000006efcdc62 R14: ffffffff819a6000 R15: 0000=
00007659b0de
> [223968.820373] FS: =A00000000000000000(0000) GS:ffff88022fc00000(000=
0) knlGS:0000000000000000
> [223968.820375] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223968.820377] CR2: 00007f25e7bc13a0 CR3: 00000001426fc000 CR4: 0000=
0000000006f0
> [223968.820380] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223968.820382] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223968.820385] Process swapper (pid: 0, threadinfo ffffffff819a6000,=
 task ffffffff81a2b020)
> [223968.820387] Stack:
> [223968.820388] =A0ffffffff819a6000 000000007659b0de 00000000818f9896=
 ffff8801f6c22448
> [223968.820393] =A00000000031026962 000000006efcdc62 0000000000000001=
 ffffffff81a2b020
> [223968.820397] =A0ffff88022fc03d40 ffffffff813a4f6a ffff88022fc03d80=
 ffffffff813ac2ab
> [223968.820401] Call Trace:
> [223968.820402] =A0<IRQ>
> [223968.820406] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223968.820410] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223968.820414] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223968.820417] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223968.820420] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223968.820424] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223968.820427] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223968.820430] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223968.820434] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223968.820437] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223968.820441] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223968.820444] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223968.820447] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223968.820450] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.820452] =A0<EOI>
> [223968.820455] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.820459] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223968.820462] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.820465] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223968.820468] =A0[<ffffffff816ca491>] rest_init+0xd1/0xe0
> [223968.820471] =A0[<ffffffff816ca3c0>] ? csum_partial_copy_generic+0=
x170/0x170
> [223968.820475] =A0[<ffffffff81adcc55>] start_kernel+0x360/0x3ac
> [223968.820478] =A0[<ffffffff81adc2a2>] x86_64_start_reservations+0x8=
2/0x89
> [223968.820481] =A0[<ffffffff81adc3b8>] x86_64_start_kernel+0x10f/0x1=
2a
> [223968.820484] =A0[<ffffffff81adc140>] ? early_idt_handlers+0x140/0x=
140
> [223968.820486] Code: 68 1c 01 f3 90 83 40 1c 01 65 44 8b 3c 25 50 d3=
 00 00 44 3b 7d d4 75 3b 66 66 90 0f ae e8 e8 b8 60 c7 ff 66 90 4c 63 c=
0 4c 89 c0
> [223968.820504] =A02b 45 c8 48 39 d8 72 c7 65 48 8b 04 25 08 c4 00 00=
 83 a8 44
> [223968.820514] Call Trace:
> [223968.820515] =A0<IRQ> =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223968.820521] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223968.820525] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223968.820528] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223968.820532] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223968.820535] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223968.820538] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223968.820542] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223968.820546] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223968.820549] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223968.820552] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223968.820556] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223968.820559] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223968.820562] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.820564] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223968.820570] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223968.820573] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.820576] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223968.820579] =A0[<ffffffff816ca491>] rest_init+0xd1/0xe0
> [223968.820583] =A0[<ffffffff816ca3c0>] ? csum_partial_copy_generic+0=
x170/0x170
> [223968.820586] =A0[<ffffffff81adcc55>] start_kernel+0x360/0x3ac
> [223968.820589] =A0[<ffffffff81adc2a2>] x86_64_start_reservations+0x8=
2/0x89
> [223968.820593] =A0[<ffffffff81adc3b8>] x86_64_start_kernel+0x10f/0x1=
2a
> [223968.820596] =A0[<ffffffff81adc140>] ? early_idt_handlers+0x140/0x=
140
> [223968.820599] NMI backtrace for cpu 2
> [223968.820600] CPU 2
> [223968.820602] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223968.820610]
> [223968.820612] Pid: 0, comm: kworker/0:1 Not tainted 3.1.0-rc10-hw-l=
ockdep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223968.820616] RIP: 0010:[<ffffffff8101afa6>] =A0[<ffffffff8101afa6>=
] native_read_tsc+0x6/0x20
> [223968.820621] RSP: 0018:ffff88022fc83ce0 =A0EFLAGS: 00000202
> [223968.820623] RAX: 000000007659b116 RBX: 0000000000000001 RCX: 0000=
00007659b0e5
> [223968.820625] RDX: 0000000000017b6b RSI: 0000000000000000 RDI: 0000=
000000000001
> [223968.820628] RBP: ffff88022fc83ce0 R08: 000000007659b098 R09: 0000=
000000000000
> [223968.820630] R10: ffff880226948000 R11: 0000000000000000 R12: 0000=
0000345f87d7
> [223968.820632] R13: 000000006efcdc62 R14: ffff88022693e000 R15: 0000=
00007659b0e5
> [223968.820635] FS: =A00000000000000000(0000) GS:ffff88022fc80000(000=
0) knlGS:0000000000000000
> [223968.820638] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223968.820640] CR2: 00007f25e7874d7f CR3: 0000000124c0d000 CR4: 0000=
0000000006e0
> [223968.820642] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223968.820645] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223968.820647] Process kworker/0:1 (pid: 0, threadinfo ffff88022693e=
000, task ffff880226948000)
> [223968.820649] Stack:
> [223968.820651] =A0ffff88022fc83d30 ffffffff813a4ee8 ffff88022693e000=
 000000007659b0e5
> [223968.820655] =A0000000026b4044c5 ffff88006afd8948 00000000345f87d7=
 000000006efcdc62
> [223968.820659] =A00000000000000001 ffff880226948000 ffff88022fc83d40=
 ffffffff813a4f6a
> [223968.820663] Call Trace:
> [223968.820665] =A0<IRQ>
> [223968.820668] =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223968.820671] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223968.820674] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223968.820678] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223968.820682] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223968.820685] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223968.820688] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223968.820691] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223968.820695] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223968.820699] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223968.820702] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223968.820705] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223968.820708] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223968.820712] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223968.820715] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.820717] =A0<EOI>
> [223968.820720] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.820723] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223968.820727] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.820730] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223968.820733] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223968.820735] Code: 08 ff 15 46 5c a1 00 48 c7 43 08 00 00 00 00 48=
 89 03 48 83 c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8=
9 e5 0f 31
> [223968.820753] =A0c1 48 89 d0 48 c1 e0 20 89 ca 48 09 d0 c9 c3 66 2e=
 0f 1f 84
> [223968.820763] Call Trace:
> [223968.820764] =A0<IRQ> =A0[<ffffffff813a4ee8>] delay_tsc+0x78/0xd0
> [223968.820769] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223968.820773] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223968.820777] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223968.820780] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223968.820783] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223968.820787] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223968.820790] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223968.820793] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223968.820797] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223968.820801] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223968.820804] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223968.820807] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223968.820810] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223968.820813] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.820815] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223968.820821] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223968.820824] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.820827] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223968.820831] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223968.816001] NMI backtrace for cpu 1
> [223968.816001] CPU 1
> [223968.816001] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandl=
er xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_co=
nntrack nf_defrag_ipv4 bnx2
> [223968.816001]
> [223968.816001] Pid: 0, comm: kworker/0:0 Not tainted 3.1.0-rc10-hw-l=
ockdep+ #51 Dell Inc. PowerEdge 1950/0M788G
> [223968.816001] RIP: 0010:[<ffffffff81440955>] =A0[<ffffffff81440955>=
] io_serial_out+0x15/0x20
> [223968.816001] RSP: 0018:ffff88022fc437f0 =A0EFLAGS: 00000002
> [223968.816001] RAX: 0000000000000073 RBX: ffffffff8243eec0 RCX: 0000=
000000000000
> [223968.816001] RDX: 00000000000003f8 RSI: 00000000000003f8 RDI: ffff=
ffff8243eec0
> [223968.816001] RBP: ffff88022fc437f0 R08: 000000007659a435 R09: 0000=
000000000000
> [223968.816001] R10: 0000000000000001 R11: 000000000000000a R12: 0000=
000000000073
> [223968.816001] R13: ffffffff81bc648d R14: 0000000000000050 R15: ffff=
ffff8243eec0
> [223968.816001] FS: =A00000000000000000(0000) GS:ffff88022fc40000(000=
0) knlGS:0000000000000000
> [223968.816001] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [223968.816001] CR2: 00007f472ba6a6fc CR3: 0000000126bb7000 CR4: 0000=
0000000006e0
> [223968.816001] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [223968.816001] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [223968.816001] Process kworker/0:0 (pid: 0, threadinfo ffff880226928=
000, task ffff88022690dd60)
> [223968.816001] Stack:
> [223968.816001] =A0ffff88022fc43810 ffffffff814410dc 0000000000000030=
 ffffffff814410b0
> [223968.816001] =A0ffff88022fc43850 ffffffff8143cdb5 0000000000000087=
 0000000000000000
> [223968.816001] =A0ffffffff8243eec0 0000000000000001 0000000000000087=
 000000000000000d
> [223968.816001] Call Trace:
> [223968.816001] =A0<IRQ>
> [223968.816001] =A0[<ffffffff814410dc>] serial8250_console_putchar+0x=
2c/0x40
> [223968.816001] =A0[<ffffffff814410b0>] ? wait_for_xmitr+0xa0/0xa0
> [223968.816001] =A0[<ffffffff8143cdb5>] uart_console_write+0x35/0x70
> [223968.816001] =A0[<ffffffff814417be>] serial8250_console_write+0xbe=
/0x1a0
> [223968.816001] =A0[<ffffffff8105c78e>] __call_console_drivers+0x8e/0=
xb0
> [223968.816001] =A0[<ffffffff8105c7f5>] _call_console_drivers+0x45/0x=
70
> [223968.816001] =A0[<ffffffff8105d02f>] console_unlock+0x17f/0x2b0
> [223968.816001] =A0[<ffffffff8105d64d>] vprintk+0x1fd/0x520
> [223968.816001] =A0[<ffffffff816f16c1>] printk+0x67/0x69
> [223968.816001] =A0[<ffffffff816f5fa6>] ? _raw_spin_unlock+0x26/0x40
> [223968.816001] =A0[<ffffffff8105388b>] ? account_system_time+0xab/0x=
190
> [223968.816001] =A0[<ffffffff810bb7e4>] __rcu_pending+0x194/0x3b0
> [223968.816001] =A0[<ffffffff810921f0>] ? tick_nohz_handler+0x100/0x1=
00
> [223968.816001] =A0[<ffffffff810bba67>] rcu_check_callbacks+0x67/0x13=
0
> [223968.816001] =A0[<ffffffff8106d861>] update_process_times+0x41/0x8=
0
> [223968.816001] =A0[<ffffffff81092256>] tick_sched_timer+0x66/0xc0
> [223968.816001] =A0[<ffffffff810845ee>] __run_hrtimer+0xfe/0x1e0
> [223968.816001] =A0[<ffffffff8108491d>] hrtimer_interrupt+0xcd/0x1f0
> [223968.816001] =A0[<ffffffff810310c4>] smp_apic_timer_interrupt+0x64=
/0xa0
> [223968.816001] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.816001] =A0[<ffffffff816f6334>] ? retint_restore_args+0x13/0x=
13
> [223968.816001] =A0[<ffffffff8101afa6>] ? native_read_tsc+0x6/0x20
> [223968.816001] =A0[<ffffffff813a4eaf>] delay_tsc+0x3f/0xd0
> [223968.816001] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223968.816001] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223968.816001] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223968.816001] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223968.816001] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223968.816001] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223968.816001] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223968.816001] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223968.816001] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223968.816001] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223968.816001] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223968.816001] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223968.816001] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223968.816001] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.816001] =A0<EOI>
> [223968.816001] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.816001] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223968.816001] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.816001] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223968.816001] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
> [223968.816001] Code: 48 89 e5 d3 e2 03 57 38 ec 0f b6 c0 c9 c3 0f 1f=
 84 00 00 00 00 00 0f b6 8f 81 00 00 00 55 89 d0 48 89 e5 d3 e6 03 77 3=
8 89 f2 ee <c9> c3 66 0f 1f 84 00 00 00 00 00 55 80 bf 82 00 00 00 08 4=
8 89
> [223968.816001] Call Trace:
> [223968.816001] =A0<IRQ> =A0[<ffffffff814410dc>] serial8250_console_p=
utchar+0x2c/0x40
> [223968.816001] =A0[<ffffffff814410b0>] ? wait_for_xmitr+0xa0/0xa0
> [223968.816001] =A0[<ffffffff8143cdb5>] uart_console_write+0x35/0x70
> [223968.816001] =A0[<ffffffff814417be>] serial8250_console_write+0xbe=
/0x1a0
> [223968.816001] =A0[<ffffffff8105c78e>] __call_console_drivers+0x8e/0=
xb0
> [223968.816001] =A0[<ffffffff8105c7f5>] _call_console_drivers+0x45/0x=
70
> [223968.816001] =A0[<ffffffff8105d02f>] console_unlock+0x17f/0x2b0
> [223968.816001] =A0[<ffffffff8105d64d>] vprintk+0x1fd/0x520
> [223968.816001] =A0[<ffffffff816f16c1>] printk+0x67/0x69
> [223968.816001] =A0[<ffffffff816f5fa6>] ? _raw_spin_unlock+0x26/0x40
> [223968.816001] =A0[<ffffffff8105388b>] ? account_system_time+0xab/0x=
190
> [223968.816001] =A0[<ffffffff810bb7e4>] __rcu_pending+0x194/0x3b0
> [223968.816001] =A0[<ffffffff810921f0>] ? tick_nohz_handler+0x100/0x1=
00
> [223968.816001] =A0[<ffffffff810bba67>] rcu_check_callbacks+0x67/0x13=
0
> [223968.816001] =A0[<ffffffff8106d861>] update_process_times+0x41/0x8=
0
> [223968.816001] =A0[<ffffffff81092256>] tick_sched_timer+0x66/0xc0
> [223968.816001] =A0[<ffffffff810845ee>] __run_hrtimer+0xfe/0x1e0
> [223968.816001] =A0[<ffffffff8108491d>] hrtimer_interrupt+0xcd/0x1f0
> [223968.816001] =A0[<ffffffff810310c4>] smp_apic_timer_interrupt+0x64=
/0xa0
> [223968.816001] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.816001] =A0[<ffffffff816f6334>] ? retint_restore_args+0x13/0x=
13
> [223968.816001] =A0[<ffffffff8101afa6>] ? native_read_tsc+0x6/0x20
> [223968.816001] =A0[<ffffffff813a4eaf>] delay_tsc+0x3f/0xd0
> [223968.816001] =A0[<ffffffff813a4f6a>] __delay+0xa/0x10
> [223968.816001] =A0[<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
> [223968.816001] =A0[<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
> [223968.816001] =A0[<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x=
270
> [223968.816001] =A0[<ffffffff81661823>] tcp_keepalive_timer+0x23/0x27=
0
> [223968.816001] =A0[<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
> [223968.816001] =A0[<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x4=
10
> [223968.816001] =A0[<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0=
x20
> [223968.816001] =A0[<ffffffff810640b8>] __do_softirq+0x138/0x250
> [223968.816001] =A0[<ffffffff817002bc>] call_softirq+0x1c/0x30
> [223968.816001] =A0[<ffffffff810153c5>] do_softirq+0x95/0xd0
> [223968.816001] =A0[<ffffffff81063c8d>] irq_exit+0xdd/0x110
> [223968.816001] =A0[<ffffffff810310c9>] smp_apic_timer_interrupt+0x69=
/0xa0
> [223968.816001] =A0[<ffffffff816feb33>] apic_timer_interrupt+0x73/0x8=
0
> [223968.816001] =A0<EOI> =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0=
x170
> [223968.816001] =A0[<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
> [223968.816001] =A0[<ffffffff8101b805>] ? mwait_idle+0x145/0x170
> [223968.816001] =A0[<ffffffff81013156>] cpu_idle+0x96/0xf0
> [223968.816001] =A0[<ffffffff816ec4bb>] start_secondary+0x1ca/0x1ff
>
> [ goes on for another ~300kB, trimmed ]
>
