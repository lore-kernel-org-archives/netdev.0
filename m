From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 36012] New: Kernel oops in
	__pskb_pull_tail
Date: Fri, 27 May 2011 15:17:15 -0700
Message-ID: <20110527151715.a9888b74.akpm@linux-foundation.org>
References: <bug-36012-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, sgunderson@bigfoot.com,
	bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <bug-36012-10286@https.bugzilla.kernel.org/>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

Steinar's kernel went splat.  e1000 might be implicated.  It's a
2.6.38->2.6.39 regression.


On Fri, 27 May 2011 18:21:35 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=36012
> 
>            Summary: Kernel oops in __pskb_pull_tail
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.39
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: sgunderson@bigfoot.com
>         Regression: Yes
> 
> 
> Hi,
> 
> After upgrade from 2.6.38 to 2.6.39, my machine oopses several times a day. It
> doesn't actually _store_ the oops anywhere, but I was able to grab the
> following off the serial console:
> 
> 
> login: [  251.133115] k_sesse: Features changed: 0x00006800 -> 0x00006000
> [  251.350035] k_magne: Features changed: 0x00006800 -> 0x00006000
> [  251.390897] k_trygve: Features changed: 0x00006800 -> 0x00006000
> [  251.430429] k_klette: Features changed: 0x00006800 -> 0x00006000
> [  251.471081] k_berge: Features changed: 0x00006800 -> 0x00006000
> [  251.521415] k_sessesveits: Features changed: 0x00006800 -> 0x00006000
> [  309.602872] ------------[ cut here ]------------
> [  309.607739] kernel BUG at net/core/skbuff.c:1192!
> [  309.612687] invalid opcode: 0000 [#1] SMP 
> [  309.617143] last sysfs file:
> /sys/devices/system/cpu/cpu15/cache/index2/shared_cpu_map
> [  309.625499] CPU 0 
> [  309.627380] Modules linked in: sha256_generic cryptd aes_x86_64 aes_generic
> af_packet microcode ext4 jbd2 crc16 ext2 fuse dm_crypt coretemp w83627ehf
> hwmon_vid ip_gre gre ide_generic ide_gd_mod ide_cd_mod cdrom forcedeth psmouse
> rtc_cmos pcspkr serio_raw rtc_core i2c_i801 rtc_lib ghes evdev i2c_core hed
> ext3 jbd mbcache dm_mod raid456 async_pq async_xor xor async_memcpy
> async_raid6_recov raid6_pq async_tx raid1 md_mod usbhid ide_pci_generic
> ide_core uhci_hcd ata_piix e1000e ehci_hcd sd_mod unix [last unloaded:
> scsi_wait_scan]
> [  309.679212] 
> [  309.685934] Pid: 0, comm: swapper Not tainted 2.6.39 #1 Supermicro
> X8DTL/X8DTL
> [  309.693763] RIP: 0010:[<ffffffff8126ca5f>]  [<ffffffff8126ca5f>]
> __pskb_pull_tail+0x82/0x29d
> [  309.702700] RSP: 0018:ffff88063fa03610  EFLAGS: 00010282
> [  309.708249] RAX: 00000000fffffff2 RBX: ffff8805e53e32e0 RCX:
> ffff880604310a00
> [  309.715622] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> ffff8805e53e32e0
> [  309.722986] RBP: ffff88063fa03650 R08: ffffffff8126c070 R09:
> ffff88060431090a
> [  309.730356] R10: ffff880638a9afc0 R11: ffff880638a9afc0 R12:
> 0000000000000004
> [  309.737723] R13: 000000000000000c R14: ffff880638030640 R15:
> ffff880638030000
> [  309.745098] FS:  0000000000000000(0000) GS:ffff88063fa00000(0000)
> knlGS:0000000000000000
> [  309.753624] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  309.759609] CR2: 00007fa662685788 CR3: 0000000001549000 CR4:
> 00000000000006f0
> [  309.766979] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  309.774350] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [  309.781728] Process swapper (pid: 0, threadinfo ffffffff814f6000, task
> ffffffff81551020)
> [  309.790255] Stack:
> [  309.792510]  ffff880600000000 ffffffffa00baa20 0000005600000056
> ffff8805e53e32e0
> [  309.800581]  0000000000000036 000000000000000c ffff880638030640
> ffff880638030000
> [  309.808642]  ffff88063fa03700 ffffffffa00b3acb ffff88063fa03680
> ffffffff8126c070
> [  309.816708] Call Trace:
> [  309.819394]  <IRQ> 
> [  309.821810]  [<ffffffffa00b3acb>] e1000_xmit_frame+0xce/0x9ff [e1000e]
> [  309.828575]  [<ffffffff8126c070>] ? __kfree_skb+0x78/0x7c
> [  309.834213]  [<ffffffff8126c0d1>] ? consume_skb+0x5d/0x62
> [  309.839850]  [<ffffffffa02d530e>] ? packet_rcv+0x309/0x31b [af_packet]
> [  309.846615]  [<ffffffff81274e31>] dev_hard_start_xmit+0x419/0x58e
> [  309.852952]  [<ffffffff8128ac8d>] sch_direct_xmit+0x67/0x18d
> [  309.858846]  [<ffffffff812752d2>] dev_queue_xmit+0x32c/0x4ec
> [  309.864741]  [<ffffffff812a1e92>] ip_finish_output+0x250/0x293
> [  309.870811]  [<ffffffff812a1f73>] ip_output+0x9e/0xa5
> [  309.876100]  [<ffffffff812a1312>] ip_local_out+0x24/0x28
> [  309.881655]  [<ffffffff812a186f>] ip_queue_xmit+0x2d8/0x31e
> [  309.887467]  [<ffffffff8126a7cd>] ? __skb_clone+0x29/0xf2
> [  309.893102]  [<ffffffff812b2f1b>] tcp_transmit_skb+0x76c/0x7aa
> [  309.899176]  [<ffffffff812b568f>] tcp_write_xmit+0x806/0x8f5
> [  309.905068]  [<ffffffff812b2377>] ? tcp_established_options+0x2e/0xa9
> [  309.911750]  [<ffffffff812b57cf>] __tcp_push_pending_frames+0x20/0x7c
> [  309.918430]  [<ffffffff812b19be>] tcp_rcv_established+0x104/0x5fe
> [  309.924762]  [<ffffffff810ce02d>] ? kfree+0x55/0xf1
> [  309.929881]  [<ffffffff812b88d6>] tcp_v4_do_rcv+0x1b0/0x380
> [  309.935689]  [<ffffffff810ce02d>] ? kfree+0x55/0xf1
> [  309.940807]  [<ffffffff810cdea2>] ? kmem_cache_free+0x1b/0xcf
> [  309.946793]  [<ffffffff81140064>] ? security_sock_rcv_skb+0x11/0x13
> [  309.953297]  [<ffffffff812b8f7b>] tcp_v4_rcv+0x4d5/0x7fc
> [  309.958851]  [<ffffffff812c1f94>] ? icmp_rcv+0x214/0x255
> [  309.964407]  [<ffffffff8129d3f4>] ip_local_deliver_finish+0xfb/0x1a6
> [  309.971002]  [<ffffffff8129d511>] ip_local_deliver+0x72/0x79
> [  309.976898]  [<ffffffff8129d06f>] ip_rcv_finish+0x27f/0x2a9
> [  309.982703]  [<ffffffff8129d2d3>] ip_rcv+0x23a/0x260
> [  309.987907]  [<ffffffff81273a79>] __netif_receive_skb+0x4e2/0x514
> [  309.994237]  [<ffffffff81273db5>] netif_receive_skb+0x67/0x6e
> [  310.000220]  [<ffffffff81273e9a>] napi_skb_finish+0x24/0x3c
> [  310.006032]  [<ffffffff8127437e>] napi_gro_receive+0xa8/0xad
> [  310.011929]  [<ffffffffa00b4cb3>] e1000_receive_skb+0x62/0x6d [e1000e]
> [  310.018699]  [<ffffffffa00b4eec>] e1000_clean_rx_irq+0x22e/0x2c3 [e1000e]
> [  310.025723]  [<ffffffffa00b649a>] e1000_clean+0x75/0x23b [e1000e]
> [  310.032052]  [<ffffffff8105e5e1>] ? clockevents_program_event+0x75/0x7e
> [  310.038908]  [<ffffffff812744b7>] net_rx_action+0xa7/0x215
> [  310.044634]  [<ffffffff8103e950>] __do_softirq+0xc1/0x180
> [  310.050276]  [<ffffffff8101a22e>] ? ack_apic_level+0x6d/0x1af
> [  310.056262]  [<ffffffff8133a5cc>] call_softirq+0x1c/0x30
> [  310.061817]  [<ffffffff81002feb>] do_softirq+0x33/0x68
> [  310.067196]  [<ffffffff8103e6da>] irq_exit+0x3f/0x88
> [  310.072399]  [<ffffffff810028d1>] do_IRQ+0x98/0xaf
> [  310.077435]  [<ffffffff81333353>] common_interrupt+0x13/0x13
> [  310.083335]  <EOI> 
> [  310.085739]  [<ffffffff81335f30>] ? notifier_call_chain+0x32/0x5e
> [  310.092073]  [<ffffffff8102a0fc>] ? update_rq_clock+0x1d/0x39
> [  310.098062]  [<ffffffff8119aca9>] ? intel_idle+0xc3/0xe9
> [  310.103615]  [<ffffffff8119ac8c>] ? intel_idle+0xa6/0xe9
> [  310.109174]  [<ffffffff81259912>] cpuidle_idle_call+0x112/0x1b4
> [  310.115333]  [<ffffffff810012d4>] cpu_idle+0x5a/0x91
> [  310.120538]  [<ffffffff81320fa4>] rest_init+0x68/0x6a
> [  310.125826]  [<ffffffff815afb80>] start_kernel+0x345/0x350
> [  310.131551]  [<ffffffff815af2a8>] x86_64_start_reservations+0xb8/0xbc
> [  310.138227]  [<ffffffff815af399>] x86_64_start_kernel+0xed/0xf4
> [  310.144382] Code: ff 85 c0 0f 85 2c 02 00 00 8b 93 c0 00 00 00 8b 73 68 48
> 03 93 c8 00 00 00 2b 73 6c 44 89 e1 48 89 df e8 19 e0 ff ff 85 c0 74 04 <0f> 0b
> eb fe 8b 83 c4 00 00 00 48 03 83 c8 00 00 00 4c 8b 68 10 
> [  310.167752] RIP  [<ffffffff8126ca5f>] __pskb_pull_tail+0x82/0x29d
> [  310.174141]  RSP <ffff88063fa03610>
> [  310.178190] ---[ end trace bc3a706445eef1e2 ]---
> [  310.183223] Kernel panic - not syncing: Fatal exception in interrupt
> [  310.190105] Pid: 0, comm: swapper Tainted: G      D     2.6.39 #1
> [  310.196683] Call Trace:
> [  310.199565]  <IRQ>  [<ffffffff81330476>] panic+0x8c/0x188
> [  310.205910]  [<ffffffff81333fa6>] oops_end+0x81/0x8e
> [  310.211368]  [<ffffffff81004051>] die+0x55/0x5e
> [  310.216423]  [<ffffffff81333a85>] do_trap+0x11c/0x12b
> [  310.222024]  [<ffffffff810023e4>] do_invalid_op+0x91/0x9a
> [  310.227981]  [<ffffffff8126ca5f>] ? __pskb_pull_tail+0x82/0x29d
> [  310.234424]  [<ffffffff8126ca5b>] ? __pskb_pull_tail+0x7e/0x29d
> [  310.240902]  [<ffffffff8133a355>] invalid_op+0x15/0x20
> [  310.246607]  [<ffffffff8126c070>] ? __kfree_skb+0x78/0x7c
> [  310.252565]  [<ffffffff8126ca5f>] ? __pskb_pull_tail+0x82/0x29d
> [  310.259033]  [<ffffffffa00b3acb>] e1000_xmit_frame+0xce/0x9ff [e1000e]
> [  310.266104]  [<ffffffff8126c070>] ? __kfree_skb+0x78/0x7c
> [  310.272054]  [<ffffffff8126c0d1>] ? consume_skb+0x5d/0x62
> [  310.278005]  [<ffffffffa02d530e>] ? packet_rcv+0x309/0x31b [af_packet]
> [  310.285083]  [<ffffffff81274e31>] dev_hard_start_xmit+0x419/0x58e
> [  310.291739]  [<ffffffff8128ac8d>] sch_direct_xmit+0x67/0x18d
> [  310.297954]  [<ffffffff812752d2>] dev_queue_xmit+0x32c/0x4ec
> [  310.304160]  [<ffffffff812a1e92>] ip_finish_output+0x250/0x293
> [  310.310552]  [<ffffffff812a1f73>] ip_output+0x9e/0xa5
> [  310.316152]  [<ffffffff812a1312>] ip_local_out+0x24/0x28
> [  310.322015]  [<ffffffff812a186f>] ip_queue_xmit+0x2d8/0x31e
> [  310.328134]  [<ffffffff8126a7cd>] ? __skb_clone+0x29/0xf2
> [  310.334083]  [<ffffffff812b2f1b>] tcp_transmit_skb+0x76c/0x7aa
> [  310.340468]  [<ffffffff812b568f>] tcp_write_xmit+0x806/0x8f5
> [  310.346681]  [<ffffffff812b2377>] ? tcp_established_options+0x2e/0xa9
> [  310.353674]  [<ffffffff812b57cf>] __tcp_push_pending_frames+0x20/0x7c
> [  310.360664]  [<ffffffff812b19be>] tcp_rcv_established+0x104/0x5fe
> [  310.367273]  [<ffffffff810ce02d>] ? kfree+0x55/0xf1
> [  310.372686]  [<ffffffff812b88d6>] tcp_v4_do_rcv+0x1b0/0x380
> [  310.378794]  [<ffffffff810ce02d>] ? kfree+0x55/0xf1
> [  310.384218]  [<ffffffff810cdea2>] ? kmem_cache_free+0x1b/0xcf
> [  310.390459]  [<ffffffff81140064>] ? security_sock_rcv_skb+0x11/0x13
> [  310.397284]  [<ffffffff812b8f7b>] tcp_v4_rcv+0x4d5/0x7fc
> [  310.403119]  [<ffffffff812c1f94>] ? icmp_rcv+0x214/0x255
> [  310.408983]  [<ffffffff8129d3f4>] ip_local_deliver_finish+0xfb/0x1a6
> [  310.415893]  [<ffffffff8129d511>] ip_local_deliver+0x72/0x79
> [  310.422097]  [<ffffffff8129d06f>] ip_rcv_finish+0x27f/0x2a9
> [  310.428222]  [<ffffffff8129d2d3>] ip_rcv+0x23a/0x260
> [  310.433742]  [<ffffffff81273a79>] __netif_receive_skb+0x4e2/0x514
> [  310.440390]  [<ffffffff81273db5>] netif_receive_skb+0x67/0x6e
> [  310.446619]  [<ffffffff81273e9a>] napi_skb_finish+0x24/0x3c
> [  310.452664]  [<ffffffff8127437e>] napi_gro_receive+0xa8/0xad
> [  310.458823]  [<ffffffffa00b4cb3>] e1000_receive_skb+0x62/0x6d [e1000e]
> [  310.465843]  [<ffffffffa00b4eec>] e1000_clean_rx_irq+0x22e/0x2c3 [e1000e]
> [  310.473124]  [<ffffffffa00b649a>] e1000_clean+0x75/0x23b [e1000e]
> [  310.479701]  [<ffffffff8105e5e1>] ? clockevents_program_event+0x75/0x7e
> [  310.486800]  [<ffffffff812744b7>] net_rx_action+0xa7/0x215
> [  310.492785]  [<ffffffff8103e950>] __do_softirq+0xc1/0x180
> [  310.498668]  [<ffffffff8101a22e>] ? ack_apic_level+0x6d/0x1af
> [  310.504897]  [<ffffffff8133a5cc>] call_softirq+0x1c/0x30
> [  310.510694]  [<ffffffff81002feb>] do_softirq+0x33/0x68
> [  310.516324]  [<ffffffff8103e6da>] irq_exit+0x3f/0x88
> [  310.521764]  [<ffffffff810028d1>] do_IRQ+0x98/0xaf
> [  310.527035]  [<ffffffff81333353>] common_interrupt+0x13/0x13
> [  310.533170]  <EOI>  [<ffffffff81335f30>] ? notifier_call_chain+0x32/0x5e
> [  310.540639]  [<ffffffff8102a0fc>] ? update_rq_clock+0x1d/0x39
> [  310.546874]  [<ffffffff8119aca9>] ? intel_idle+0xc3/0xe9
> [  310.552662]  [<ffffffff8119ac8c>] ? intel_idle+0xa6/0xe9
> [  310.558455]  [<ffffffff81259912>] cpuidle_idle_call+0x112/0x1b4
> [  310.564878]  [<ffffffff810012d4>] cpu_idle+0x5a/0x91
> [  310.570327]  [<ffffffff81320fa4>] rest_init+0x68/0x6a
> [  310.575862]  [<ffffffff815afb80>] start_kernel+0x345/0x350
> [  310.581848]  [<ffffffff815af2a8>] x86_64_start_reservations+0xb8/0xbc
> [  310.588787]  [<ffffffff815af399>] x86_64_start_kernel+0xed/0xf4
> [  310.595456] Rebooting in 60 seconds..
> 


------------------------------------------------------------------------------
vRanger cuts backup time in half-while increasing security.
With the market-leading solution for virtual backup and recovery, 
you get blazing-fast, flexible, and affordable data protection.
Download your free trial now. 
http://p.sf.net/sfu/quest-d2dcopy1
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
