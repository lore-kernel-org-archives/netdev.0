From: Simon Kirby <sim@hostway.ca>
Subject: Re: Linux 3.1-rc9
Date: Tue, 25 Oct 2011 13:20:49 -0700
Message-ID: <20111025202049.GB25043@hostway.ca>
References: <CA+55aFxaGKEyhXdHXNxvPrPQ-SGSpbXdfoeXrxfjPx3VXsgvtg@mail.gmail.com> <1318874090.4172.84.camel@twins> <CA+55aFwCBy=4YK6amE=H-BYu9-boj4Po2Zkgf4V261mCx0DC4A@mail.gmail.com> <1318879396.4172.92.camel@twins> <alpine.LFD.2.02.1110172237030.3240@ionos> <alpine.LFD.2.02.1110181037120.3240@ionos> <1318928713.21167.4.camel@twins> <20111018182046.GF1309@hostway.ca> <alpine.LFD.2.02.1110182146440.3240@ionos> <20111024190203.GA24410@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111024190203.GA24410@hostway.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 24, 2011 at 12:02:03PM -0700, Simon Kirby wrote:

> Ok, hit the hang about 4 more times, but only this morning on a box with
> a serial cable attached. Yay!

Here's lockdep output from another box. This one looks a bit different.

Simon-

[583223.799383] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000102, exited with 00000103?
[583223.805083] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000102, exited with 00000103?
[583223.805093] 
[583223.805094] =================================
[583223.805096] [ INFO: inconsistent lock state ]
[583223.805098] 3.1.0-rc10-hw-lockdep+ #51
[583223.805100] ---------------------------------
[583223.805102] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[583223.805105] swapper/0 [HC0[0]:SC0[0]:HE1:SE1] takes:
[583223.805107]  (slock-AF_INET){+.?.-.}, at: [<ffffffff81604540>] sk_clone+0x120/0x420
[583223.805116] {IN-SOFTIRQ-W} state was registered at:
[583223.805117]   [<ffffffff81098c7c>] __lock_acquire+0xcbc/0x2180
[583223.805123]   [<ffffffff8109a7b9>] lock_acquire+0x109/0x140
[583223.805126]   [<ffffffff816f55fc>] _raw_spin_lock+0x3c/0x50
[583223.805131]   [<ffffffff8166bd3d>] udp_queue_rcv_skb+0x26d/0x4b0
[583223.805135]   [<ffffffff8166c6a3>] __udp4_lib_rcv+0x2f3/0x910
[583223.805139]   [<ffffffff8166ccd5>] udp_rcv+0x15/0x20
[583223.805142]   [<ffffffff81641960>] ip_local_deliver_finish+0x100/0x2f0
[583223.805146]   [<ffffffff81641bdd>] ip_local_deliver+0x8d/0xa0
[583223.805149]   [<ffffffff81641203>] ip_rcv_finish+0x1a3/0x510
[583223.805152]   [<ffffffff816417e2>] ip_rcv+0x272/0x2f0
[583223.805154]   [<ffffffff81610d67>] __netif_receive_skb+0x4d7/0x560
[583223.805158]   [<ffffffff81610ec0>] process_backlog+0xd0/0x1e0
[583223.805161]   [<ffffffff81613880>] net_rx_action+0x140/0x2c0
[583223.805164]   [<ffffffff810640b8>] __do_softirq+0x138/0x250
[583223.805168]   [<ffffffff817002bc>] call_softirq+0x1c/0x30
[583223.805172]   [<ffffffff810153c5>] do_softirq+0x95/0xd0
[583223.805176]   [<ffffffff81063ecd>] local_bh_enable+0xed/0x110
[583223.805179]   [<ffffffff81614c48>] dev_queue_xmit+0x1a8/0x8a0
[583223.805181]   [<ffffffff8161f1aa>] neigh_resolve_output+0x17a/0x220
[583223.805185]   [<ffffffff81647d4c>] ip_finish_output+0x2ec/0x590
[583223.805188]   [<ffffffff81648078>] ip_output+0x88/0xe0
[583223.805191]   [<ffffffff81646cd8>] ip_local_out+0x28/0x80
[583223.805194]   [<ffffffff81646d39>] ip_send_skb+0x9/0x40
[583223.805197]   [<ffffffff8166aeb2>] udp_send_skb+0x122/0x390
[583223.805200]   [<ffffffff8166db0c>] udp_sendmsg+0x7dc/0x920
[583223.805203]   [<ffffffff81675e1f>] inet_sendmsg+0xbf/0x120
[583223.805207]   [<ffffffff815ff333>] sock_sendmsg+0xe3/0x110
[583223.805209]   [<ffffffff815ffc55>] sys_sendto+0x105/0x140
[583223.805212]   [<ffffffff816fe052>] system_call_fastpath+0x16/0x1b
[583223.805217] irq event stamp: 4284605374
[583223.805219] hardirqs last  enabled at (4284605372): [<ffffffff816101ad>] net_rps_action_and_irq_enable+0x8d/0xa0
[583223.805222] hardirqs last disabled at (4284605373): [<ffffffff8106412d>] __do_softirq+0x1ad/0x250
[583223.805226] softirqs last  enabled at (4284605374): [<ffffffff81064176>] __do_softirq+0x1f6/0x250
[583223.805230] softirqs last disabled at (4284605313): [<ffffffff817002bc>] call_softirq+0x1c/0x30
[583223.805233] 
[583223.805233] other info that might help us debug this:
[583223.805235]  Possible unsafe locking scenario:
[583223.805236] 
[583223.805237]        CPU0
[583223.805238]        ----
[583223.805239]   lock(slock-AF_INET);
[583223.805241]   <Interrupt>
[583223.805242]     lock(slock-AF_INET);
[583223.805244] 
[583223.805245]  *** DEADLOCK ***
[583223.805246] 
[583223.805248] 1 lock held by swapper/0:
[583223.805249]  #0:  (slock-AF_INET){+.?.-.}, at: [<ffffffff81604540>] sk_clone+0x120/0x420
[583223.805254] 
[583223.805254] stack backtrace:
[583223.805257] Pid: 0, comm: swapper Not tainted 3.1.0-rc10-hw-lockdep+ #51
[583223.805259] Call Trace:
[583223.805264]  [<ffffffff81096033>] print_usage_bug+0x243/0x310
[583223.805267]  [<ffffffff810965b4>] mark_lock+0x4b4/0x6c0
[583223.805271]  [<ffffffff81097400>] ? check_usage_forwards+0x110/0x110
[583223.805275]  [<ffffffff81096862>] mark_held_locks+0xa2/0x130
[583223.805278]  [<ffffffff816f6334>] ? retint_restore_args+0x13/0x13
[583223.805281]  [<ffffffff81096c0d>] trace_hardirqs_on_caller+0x13d/0x1c0
[583223.805286]  [<ffffffff813a60ae>] trace_hardirqs_on_thunk+0x3a/0x3f
[583223.805290]  [<ffffffff81092b8e>] ? tick_nohz_stop_sched_tick+0x2fe/0x430
[583223.805293]  [<ffffffff816f6334>] ? retint_restore_args+0x13/0x13
[583223.805297]  [<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
[583223.805301]  [<ffffffff8101b805>] ? mwait_idle+0x145/0x170
[583223.805304]  [<ffffffff81013156>] cpu_idle+0x96/0xf0
[583223.805307]  [<ffffffff816ca491>] rest_init+0xd1/0xe0
[583223.805310]  [<ffffffff816ca3c0>] ? csum_partial_copy_generic+0x170/0x170
[583223.805315]  [<ffffffff81adcc55>] start_kernel+0x360/0x3ac
[583223.805318]  [<ffffffff81adc2a2>] x86_64_start_reservations+0x82/0x89
[583223.805321]  [<ffffffff81adc3b8>] x86_64_start_kernel+0x10f/0x12a
[583223.805325]  [<ffffffff81adc140>] ? early_idt_handlers+0x140/0x140
[583226.813848] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000102, exited with 00000103?
[583232.802948] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000102, exited with 00000103?
[583244.833571] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
[583253.849631] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
[583268.837126] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
[587843.931805] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000102, exited with 00000103?
[587846.165584] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
[587850.602316] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
[587859.482841] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000102, exited with 00000103?
[587873.940136] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000102, exited with 00000103?
[587877.240624] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
[590476.272022] BUG: soft lockup - CPU#0 stuck for 22s! [swapper:0]
[590476.276002] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[590476.276002] irq event stamp: 4284605374
[590476.276002] hardirqs last  enabled at (4284605372): [<ffffffff816101ad>] net_rps_action_and_irq_enable+0x8d/0xa0
[590476.276002] hardirqs last disabled at (4284605373): [<ffffffff8106412d>] __do_softirq+0x1ad/0x250
[590476.276002] softirqs last  enabled at (4284605374): [<ffffffff81064176>] __do_softirq+0x1f6/0x250
[590476.276002] softirqs last disabled at (4284605313): [<ffffffff817002bc>] call_softirq+0x1c/0x30
[590476.276002] CPU 0 
[590476.276002] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[590476.276002] 
[590476.276002] Pid: 0, comm: swapper Not tainted 3.1.0-rc10-hw-lockdep+ #51 Dell Inc. PowerEdge 1950/0UR033
[590476.276002] RIP: 0010:[<ffffffff813a4ee3>]  [<ffffffff813a4ee3>] delay_tsc+0x73/0xd0
[590476.276002] RSP: 0018:ffff88022fc03cf0  EFLAGS: 00000206
[590476.276002] RAX: 00042f884dcdaa24 RBX: ffff88022fc0d3c0 RCX: 000000004dcdaa24
[590476.380029] BUG: soft lockup - CPU#1 stuck for 22s! [php:10828]
[590476.380033] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[590476.380044] irq event stamp: 0
[590476.380045] hardirqs last  enabled at (0): [<          (null)>]           (null)
[590476.380048] hardirqs last disabled at (0): [<ffffffff8105aa8b>] copy_process+0x65b/0x1450
[590476.380056] softirqs last  enabled at (0): [<ffffffff8105aa8b>] copy_process+0x65b/0x1450
[590476.380060] softirqs last disabled at (0): [<          (null)>]           (null)
[590476.380063] CPU 1 
[590476.380064] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
[590476.380072] 
[590476.380075] Pid: 10828, comm: php Not tainted 3.1.0-rc10-hw-lockdep+ #51 Dell Inc. PowerEdge 1950/0UR033
[590476.380079] RIP: 0010:[<ffffffff8101afa6>]  [<ffffffff8101afa6>] native_read_tsc+0x6/0x20
[590476.380086] RSP: 0000:ffff88022fc43ce0  EFLAGS: 00000206
[590476.380088] RAX: 000000005aa56d04 RBX: ffffffff816f6334 RCX: 000000005aa56c92
[590476.380091] RDX: 0000000000042f88 RSI: ffffffff818f9896 RDI: 0000000000000001
[590476.380093] RBP: ffff88022fc43ce0 R08: 000000005aa56c92 R09: 0000000000000000
[590476.380096] R10: ffff88014b9a9f20 R11: 0000000000000000 R12: ffff88022fc43c58
[590476.380098] R13: ffffffff816feb33 R14: ffff88022fc43ce0 R15: 000000000e27878c
[590476.380101] FS:  00007fb61c8fa720(0000) GS:ffff88022fc40000(0000) knlGS:0000000000000000
[590476.380103] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[590476.380106] CR2: 00000000027914a0 CR3: 000000013a070000 CR4: 00000000000006e0
[590476.380108] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[590476.380110] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[590476.380113] Process php (pid: 10828, threadinfo ffff88014a1f2000, task ffff88014b9a9f20)
[590476.380115] Stack:
[590476.380117]  ffff88022fc43d30 ffffffff813a4eaf ffff88014a1f2000 000000005aa56c38
[590476.380121]  00000001818f9896 ffff88001db58048 000000000e27878c 0000000076e96800
[590476.380125]  0000000000000001 ffff88014b9a9f20 ffff88022fc43d40 ffffffff813a4f6a
[590476.380129] Call Trace:
[590476.380132]  <IRQ> 
[590476.380137]  [<ffffffff813a4eaf>] delay_tsc+0x3f/0xd0
[590476.380141]  [<ffffffff813a4f6a>] __delay+0xa/0x10
[590476.380145]  [<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
[590476.380151]  [<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
[590476.380157]  [<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x270
[590476.380161]  [<ffffffff81661823>] tcp_keepalive_timer+0x23/0x270
[590476.380166]  [<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
[590476.380169]  [<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x410
[590476.380174]  [<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0x20
[590476.380179]  [<ffffffff810640b8>] __do_softirq+0x138/0x250
[590476.380184]  [<ffffffff817002bc>] call_softirq+0x1c/0x30
[590476.380188]  [<ffffffff810153c5>] do_softirq+0x95/0xd0
[590476.380191]  [<ffffffff81063c8d>] irq_exit+0xdd/0x110
[590476.380196]  [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
[590476.380200]  [<ffffffff816feb33>] apic_timer_interrupt+0x73/0x80
[590476.380203]  <EOI> 
[590476.380206]  [<ffffffff816f6319>] ? retint_swapgs+0x13/0x1b
[590476.380208] Code: 08 ff 15 46 5c a1 00 48 c7 43 08 00 00 00 00 48 89 03 48 83 c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 0f 31 
[590476.380227]  c1 48 89 d0 48 c1 e0 20 89 ca 48 09 d0 c9 c3 66 2e 0f 1f 84 
[590476.380236] Call Trace:
[590476.380237]  <IRQ>  [<ffffffff813a4eaf>] delay_tsc+0x3f/0xd0
[590476.380242]  [<ffffffff813a4f6a>] __delay+0xa/0x10
[590476.380246]  [<ffffffff813ac2ab>] do_raw_spin_lock+0x13b/0x180
[590476.380249]  [<ffffffff816f5604>] _raw_spin_lock+0x44/0x50
[590476.380252]  [<ffffffff81661823>] ? tcp_keepalive_timer+0x23/0x270
[590476.380256]  [<ffffffff81661823>] tcp_keepalive_timer+0x23/0x270
[590476.380259]  [<ffffffff8106cd5d>] run_timer_softirq+0x26d/0x410
[590476.380262]  [<ffffffff8106cc88>] ? run_timer_softirq+0x198/0x410
[590476.380265]  [<ffffffff81661800>] ? tcp_init_xmit_timers+0x20/0x20
[590476.380268]  [<ffffffff810640b8>] __do_softirq+0x138/0x250
[590476.380271]  [<ffffffff817002bc>] call_softirq+0x1c/0x30
[590476.380274]  [<ffffffff810153c5>] do_softirq+0x95/0xd0
[590476.380277]  [<ffffffff81063c8d>] irq_exit+0xdd/0x110
[590476.380280]  [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
[590476.380283]  [<ffffffff816feb33>] apic_timer_interrupt+0x73/0x80
[590476.380285]  <EOI>  [<ffffffff816f6319>] ? retint_swapgs+0x13/0x1b
[590476.484032] BUG: soft lockup - CPU#2 stuck for 23s! [suexec:10831]
...
