From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Latest kernel net-next - 4.14-rc1+ / WARNING: CPU: 16 PID: 0 at
 net/sched/sch_hfsc.c:1385 hfsc_dequeue+0x241/0x269
Date: Tue, 26 Sep 2017 14:11:31 +0200
Message-ID: <ecf860fe-ff84-2184-fcbf-d69d3f5940cf@itcare.pl>
References: <00115c1c-6296-bc76-8ac2-5160aa870596@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp11.iq.pl ([86.111.242.220]:39267 "EHLO smtp11.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754021AbdIZMNg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 08:13:36 -0400
In-Reply-To: <00115c1c-6296-bc76-8ac2-5160aa870596@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A little more in trace:

[49519.600903] ------------[ cut here ]------------
[49519.600908] WARNING: CPU: 7 PID: 31426 at net/sched/sch_hfsc.c:1385 
hfsc_dequeue+0x241/0x269
[49519.600909] Modules linked in: ipmi_si x86_pkg_temp_thermal
[49519.600914] CPU: 7 PID: 31426 Comm: syslog-ng Tainted: G W       
4.14.0-rc1+ #10
[49519.600915] task: ffff88086d07c100 task.stack: ffffc90006d54000
[49519.600917] RIP: 0010:hfsc_dequeue+0x241/0x269
[49519.600918] RSP: 0018:ffff88087fa439f8 EFLAGS: 00010246
[49519.600919] RAX: 0000000000000000 RBX: ffff88085b8af148 RCX: 
0000000000000018
[49519.600920] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
ffff88085b8af440
[49519.600922] RBP: ffff88087fa43a20 R08: 0000160000000000 R09: 
0000000000000000
[49519.600923] R10: ffff88087fa43960 R11: ffff880859d50a00 R12: 
ffff88085b8af000
[49519.600924] R13: 000000b4266fab9b R14: 0000000000000001 R15: 
ffff88085b8af440
[49519.600925] FS:  00007fad63a35700(0000) GS:ffff88087fa40000(0000) 
knlGS:0000000000000000
[49519.600926] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[49519.600927] CR2: 00007f10d4a90098 CR3: 000000046bb1c005 CR4: 
00000000001606e0
[49519.600928] Call Trace:
[49519.600929]  <IRQ>
[49519.600932]  __qdisc_run+0xed/0x293
[49519.600935]  __dev_queue_xmit+0x2d2/0x4b3
[49519.600936]  ? eth_header+0x27/0xab
[49519.600938]  dev_queue_xmit+0xb/0xd
[49519.600939]  ? dev_queue_xmit+0xb/0xd
[49519.600943]  neigh_connected_output+0x9b/0xb2
[49519.600948]  ip_finish_output2+0x24b/0x28f
[49519.600952]  ? statistic_mt+0x30/0x72
[49519.600954]  ip_finish_output+0x101/0x10d
[49519.600957]  ip_output+0x56/0xa9
[49519.600959]  ip_forward_finish+0x53/0x58
[49519.600961]  ip_forward+0x2b2/0x308
[49519.600962]  ? ip_frag_mem+0xf/0xf
[49519.600964]  ip_rcv_finish+0x27c/0x287
[49519.600965]  ip_rcv+0x2b0/0x300
[49519.600968]  ? vlan_do_receive+0x49/0x294
[49519.600970]  __netif_receive_skb_core+0x312/0x496
[49519.600972]  ? tk_clock_read+0xc/0xe
[49519.600973]  __netif_receive_skb+0x18/0x57
[49519.600974]  ? __netif_receive_skb+0x18/0x57
[49519.600975]  netif_receive_skb_internal+0x4b/0xa1
[49519.600977]  napi_gro_complete+0x7a/0x7d
[49519.600977]  napi_gro_flush+0x3b/0x66
[49519.600979]  napi_complete_done+0x4b/0xa8
[49519.600983]  ixgbe_poll+0x90c/0xeaa
[49519.600985]  net_rx_action+0xd3/0x22d
[49519.600988]  __do_softirq+0xe4/0x23a
[49519.600991]  irq_exit+0x4d/0x5b
[49519.600992]  do_IRQ+0x96/0xae
[49519.600996]  common_interrupt+0x90/0x90
[49519.600997]  </IRQ>
[49519.601001] RIP: 0010:do_con_write+0x2d0/0x1b13
[49519.601002] RSP: 0018:ffffc90006d57bc0 EFLAGS: 00000282 ORIG_RAX: 
ffffffffffffffa2
[49519.601004] RAX: 000000000000004b RBX: 000000000000004b RCX: 
000000000000fffd
[49519.601005] RDX: 00000000ffff004d RSI: 0000000000000003 RDI: 
ffffffff81e751b8
[49519.601006] RBP: ffffc90006d57c68 R08: 0000000000000000 R09: 
0000000000000000
[49519.601007] R10: ffff88086b64f807 R11: ffff88086d07c100 R12: 
000000000000fffd
[49519.601008] R13: ffff88046c7bd400 R14: ffff88086b64f800 R15: 
000000000000004b
[49519.601011]  ? _raw_spin_lock+0x9/0xb
[49519.601013]  con_write+0xe/0x20
[49519.601018]  n_tty_write+0x101/0x3f5
[49519.601021]  ? init_wait_entry+0x29/0x29
[49519.601024]  tty_write+0x1a9/0x228
[49519.601026]  ? n_tty_flush_buffer+0x4c/0x4c
[49519.601029]  do_loop_readv_writev+0x6f/0xa1
[49519.601031]  do_iter_write+0x8e/0xb8
[49519.601032]  vfs_writev+0x77/0xad
[49519.601034]  ? __vfs_write+0x21/0xa0
[49519.601037]  ? __fget+0x25/0x56
[49519.601038]  ? __fget_light+0x3b/0x46
[49519.601039]  ? __fdget+0xe/0x10
[49519.601040]  do_writev+0x4f/0xa1
[49519.601041]  ? do_writev+0x4f/0xa1
[49519.601043]  SyS_writev+0xb/0xd
[49519.601044]  entry_SYSCALL_64_fastpath+0x13/0x94
[49519.601046] RIP: 0033:0x7fad66233da9
[49519.601046] RSP: 002b:00007fad63a32ac0 EFLAGS: 00000293 ORIG_RAX: 
0000000000000014
[49519.601047] RAX: ffffffffffffffda RBX: 0000000001eddd08 RCX: 
00007fad66233da9
[49519.601048] RDX: 0000000000000001 RSI: 0000000001edeab0 RDI: 
0000000000000011
[49519.601049] RBP: 0000000001eddd08 R08: 0000000000000000 R09: 
00007fad662842d0
[49519.601049] R10: 0000000000000000 R11: 0000000000000293 R12: 
00007fad63a326f0
[49519.601050] R13: 00007fad4c0045c0 R14: 00007fad4c0045c0 R15: 
0000000001eddcb0
[49519.601051] Code: f6 48 3d 90 00 00 00 74 04 48 8b 70 70 49 8b 84 24 
68 02 00 00 48 85 c0 74 0c 48 39 f0 72 24 48 85 f6 75 09 eb 1d 48 85 f6 
75 02 <0f> ff 49 8d bc 24 48 04 00 00 48 c1 e6 06 e8 a9 62 ff ff e9 eb
[49519.601065] ---[ end trace 8558fb6f1ca3beb0 ]---



W dniu 2017-09-26 o 14:00, Paweł Staszewski pisze:
> [50102.787542] ------------[ cut here ]------------
> [50102.787545] WARNING: CPU: 16 PID: 0 at net/sched/sch_hfsc.c:1385 
> hfsc_dequeue+0x241/0x269
> [50102.787545] Modules linked in: ipmi_si x86_pkg_temp_thermal
> [50102.787547] CPU: 16 PID: 0 Comm: swapper/16 Tainted: G W 
> 4.14.0-rc1+ #10
> [50102.787548] task: ffff88046d440000 task.stack: ffffc900032e0000
> [50102.787549] RIP: 0010:hfsc_dequeue+0x241/0x269
> [50102.787550] RSP: 0018:ffff88046fc83eb0 EFLAGS: 00010246
> [50102.787551] RAX: 0000000000000000 RBX: ffff880456309948 RCX: 
> 0000000000000018
> [50102.787551] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
> ffff880456309c40
> [50102.787552] RBP: ffff88046fc83ed8 R08: 000000000001c000 R09: 
> 0000000000000100
> [50102.787553] R10: ffff88046fc83e98 R11: 0000000000000003 R12: 
> ffff880456309800
> [50102.787553] R13: 000000b6459156dd R14: 0000000000000001 R15: 
> ffff880456309c40
> [50102.787554] FS:  0000000000000000(0000) GS:ffff88046fc80000(0000) 
> knlGS:0000000000000000
> [50102.787555] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [50102.787556] CR2: 00007fc764f21090 CR3: 000000085844a000 CR4: 
> 00000000001606e0
> [50102.787556] Call Trace:
> [50102.787557]  <IRQ>
> [50102.787558]  __qdisc_run+0xed/0x293
> [50102.787560]  net_tx_action+0xeb/0x18b
> [50102.787562]  __do_softirq+0xe4/0x23a
> [50102.787564]  irq_exit+0x4d/0x5b
> [50102.787565]  smp_apic_timer_interrupt+0xc0/0xfa
> [50102.787566]  apic_timer_interrupt+0x90/0xa0
> [50102.787566]  </IRQ>
> [50102.787568] RIP: 0010:cpuidle_enter_state+0x134/0x189
> [50102.787569] RSP: 0018:ffffc900032e3ea0 EFLAGS: 00000246 ORIG_RAX: 
> ffffffffffffff10
> [50102.787570] RAX: 00002d9176d7d9f4 RBX: 0000000000000002 RCX: 
> 000000000000001f
> [50102.787570] RDX: 0000000000000000 RSI: 0000000000000010 RDI: 
> 0000000000000000
> [50102.787571] RBP: ffffc900032e3ed0 R08: 00000000ffffffd8 R09: 
> 0000000000000003
> [50102.787572] R10: ffffc900032e3e70 R11: ffff88046fc98e50 R12: 
> ffff88046c234400
> [50102.787572] R13: 00002d9176d7d9f4 R14: 0000000000000002 R15: 
> 00002d9176d6e845
> [50102.787575]  cpuidle_enter+0x12/0x14
> [50102.787576]  do_idle+0x113/0x16b
> [50102.787578]  cpu_startup_entry+0x1a/0x1f
> [50102.787580]  start_secondary+0xea/0xed
> [50102.787581]  secondary_startup_64+0xa5/0xa5
> [50102.787582] Code: f6 48 3d 90 00 00 00 74 04 48 8b 70 70 49 8b 84 
> 24 68 02 00 00 48 85 c0 74 0c 48 39 f0 72 24 48 85 f6 75 09 eb 1d 48 
> 85 f6 75 02 <0f> ff 49 8d bc 24 48 04 00 00 48 c1 e6 06 e8 a9 62 ff ff 
> e9 eb
> [50102.787602] ---[ end trace 8558fb6f1ca3beb2 ]---
>
>
