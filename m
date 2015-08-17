From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: Linux 4.2-rc6 regression: RIP: e030:[<ffffffff8110fb18>] [<ffffffff8110fb18>] detach_if_pending+0x18/0x80
Date: Mon, 17 Aug 2015 11:09:56 +0200
Message-ID: <963062024.20150817110956@eikelenboom.it>
References: <7c39e6332aae572372108d5fd68c503b@eikelenboom.it> <1439412094.29802.21.camel@edumazet-glaptop2.roam.corp.google.com> <0de9f30086ee2e662bdafee61d24b3c1@eikelenboom.it> <20150812.144040.1151964094247340464.davem@davemloft.net> <b5e9ffc27531e98bc2ac1e28d6a3d0f0@eikelenboom.it> <1439419279.29802.25.camel@edumazet-glaptop2.roam.corp.google.com> <3b284689aaa1573610c0e388e66e756a@eikelenboom.it> <1439591965.7507.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	<netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	<david.vrabel@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439591965.7507.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Saturday, August 15, 2015, 12:39:25 AM, you wrote:

> On Sat, 2015-08-15 at 00:09 +0200, Sander Eikelenboom wrote:
>> On 2015-08-13 00:41, Eric Dumazet wrote:
>> > On Wed, 2015-08-12 at 23:46 +0200, Sander Eikelenboom wrote:
>> > 
>> >> Thanks for the reminder, but luckily i was aware of that,
>> >> seen enough of your replies asking for patches to be resubmitted
>> >> against "the other tree" ;)
>> >> Kernel with patch is currently running so fingers crossed.
>> > 
>> > Thanks for testing. I am definitely interested knowing your results.
>> 
>> Hmm it seems now commit 83fccfc3940c4a2db90fd7e7079f5b465cd8c6af is 
>> breaking things
>> (have to test if a revert helps) i get this in some guests:


> Yes, this was fixed by :
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=83fccfc3940c4a2db90fd7e7079f5b465cd8c6af


Hi Eric,

With that patch i had a crash again this night, see below.

--
Sander

[177459.188808] general protection fault: 0000 [#1] SMP 
[177459.199746] Modules linked in:
[177459.210540] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.2.0-rc6-20150815-linus-doflr-net+ #1
[177459.221441] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS V1.8B1 09/13/2010
[177459.232247] task: ffffffff8221a580 ti: ffffffff82200000 task.ti: ffffffff82200000
[177459.242931] RIP: e030:[<ffffffff8110eb58>]  [<ffffffff8110eb58>] detach_if_pending+0x18/0x80
[177459.253503] RSP: e02b:ffff88005f6039d8  EFLAGS: 00010086
[177459.264051] RAX: ffff8800584d6580 RBX: ffff880004901420 RCX: dead000000200200
[177459.274599] RDX: 0000000000000000 RSI: ffff88005f60e5c0 RDI: ffff880004901420
[177459.285122] RBP: ffff88005f6039d8 R08: 0000000000000001 R09: 0000000000000000
[177459.295286] R10: 0000000000000003 R11: ffff880004901394 R12: 0000000000000003
[177459.305388] R13: 000000010ae47040 R14: 0000000007b98a00 R15: ffff88005f60e5c0
[177459.315345] FS:  00007f51317ec700(0000) GS:ffff88005f600000(0000) knlGS:0000000000000000
[177459.325340] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
[177459.335217] CR2: 00000000010f8000 CR3: 000000002a154000 CR4: 0000000000000660
[177459.345129] Stack:
[177459.354783]  ffff88005f603a28 ffffffff8110ee7f ffffffff810fb261 0000000000000200
[177459.364505]  0000000000000003 ffff880004901380 0000000000000003 ffff8800567d0d00
[177459.374064]  0000000007b98a00 0000000000000000 ffff88005f603a58 ffffffff819b3eb3
[177459.383532] Call Trace:
[177459.392878]  <IRQ> 
[177459.392935]  [<ffffffff8110ee7f>] mod_timer_pending+0x3f/0xe0
[177459.411058]  [<ffffffff810fb261>] ? __raw_callee_save___pv_queued_spin_unlock+0x11/0x20
[177459.419876]  [<ffffffff819b3eb3>] __nf_ct_refresh_acct+0xa3/0xb0
[177459.428642]  [<ffffffff819baafb>] tcp_packet+0xb3b/0x1290
[177459.437285]  [<ffffffff81a2535e>] ? ip_output+0x5e/0xc0
[177459.445845]  [<ffffffff810ca8ca>] ? __local_bh_enable_ip+0x2a/0x90
[177459.454331]  [<ffffffff819b35a9>] ? __nf_conntrack_find_get+0x129/0x2a0
[177459.462642]  [<ffffffff819b549c>] nf_conntrack_in+0x29c/0x7c0
[177459.470711]  [<ffffffff81a65e9c>] ipv4_conntrack_local+0x4c/0x50
[177459.478753]  [<ffffffff819ad67c>] nf_iterate+0x4c/0x80
[177459.486726]  [<ffffffff81102437>] ? generic_handle_irq+0x27/0x40
[177459.494634]  [<ffffffff819ad714>] nf_hook_slow+0x64/0xc0
[177459.502486]  [<ffffffff81a22d40>] __ip_local_out_sk+0x90/0xa0
[177459.510248]  [<ffffffff81a22c40>] ? ip_forward_options+0x1a0/0x1a0
[177459.517782]  [<ffffffff81a22d66>] ip_local_out_sk+0x16/0x40
[177459.525044]  [<ffffffff81a2343d>] ip_queue_xmit+0x14d/0x350
[177459.532247]  [<ffffffff81a3ae7e>] tcp_transmit_skb+0x48e/0x960
[177459.539413]  [<ffffffff81a3cddb>] tcp_xmit_probe_skb+0xdb/0xf0
[177459.546389]  [<ffffffff81a3dffb>] tcp_write_wakeup+0x5b/0x150
[177459.553061]  [<ffffffff81a3e51b>] tcp_keepalive_timer+0x1fb/0x230
[177459.559761]  [<ffffffff81a3e320>] ? tcp_init_xmit_timers+0x20/0x20
[177459.566447]  [<ffffffff8110f3c7>] call_timer_fn.isra.27+0x17/0x80
[177459.573121]  [<ffffffff81a3e320>] ? tcp_init_xmit_timers+0x20/0x20
[177459.579778]  [<ffffffff8110f55d>] run_timer_softirq+0x12d/0x200
[177459.586448]  [<ffffffff810ca6c3>] __do_softirq+0x103/0x210
[177459.593138]  [<ffffffff810ca9cb>] irq_exit+0x4b/0xa0
[177459.599783]  [<ffffffff814f05d4>] xen_evtchn_do_upcall+0x34/0x50
[177459.606300]  [<ffffffff81af93ae>] xen_do_hypervisor_callback+0x1e/0x40
[177459.612583]  <EOI> 
[177459.612637]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
[177459.625010]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
[177459.631157]  [<ffffffff81008d60>] ? xen_safe_halt+0x10/0x20
[177459.637158]  [<ffffffff810188d3>] ? default_idle+0x13/0x20
[177459.643072]  [<ffffffff81018e1a>] ? arch_cpu_idle+0xa/0x10
[177459.648809]  [<ffffffff810f8e7e>] ? default_idle_call+0x2e/0x50
[177459.654650]  [<ffffffff810f9112>] ? cpu_startup_entry+0x272/0x2e0
[177459.660488]  [<ffffffff81ae79f7>] ? rest_init+0x77/0x80
[177459.666297]  [<ffffffff82312f58>] ? start_kernel+0x43b/0x448
[177459.672092]  [<ffffffff823124ef>] ? x86_64_start_reservations+0x2a/0x2c
[177459.677800]  [<ffffffff82316008>] ? xen_start_kernel+0x550/0x55c
[177459.683451] Code: 77 28 5d c3 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 8b 47 08 55 48 89 e5 48 85 c0 74 6a 48 8b 0f 48 85 c9 48 89 08 74 04 <48> 89 41 08 84 d2 74 08 48 c7 47 08 00 00 00 00 f6 47 2a 10 48 
[177459.695332] RIP  [<ffffffff8110eb58>] detach_if_pending+0x18/0x80
[177459.701154]  RSP <ffff88005f6039d8>
(XEN) [2015-08-17 00:11:51.426] Hardware Dom0 crashed: rebooting machine in 5 seconds.
