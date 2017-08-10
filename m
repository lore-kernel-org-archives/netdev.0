From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Some traffic stress testing with 4.13.0-rc4-next-20170808 and
 BUG: [61183.212237] BUG: Bad page state in process ksoftirqd/52 pfn:855f2f
Date: Thu, 10 Aug 2017 12:05:11 +0200
Message-ID: <bcffda88-02ab-8d17-bdef-97cf39c409ee@itcare.pl>
References: <9c49b487-2307-27ab-78cd-ed9ad8edbb65@itcare.pl>
 <CAM_iQpW908ri7ecz4ThD+fFESQoTvZLu-2Pu6wEtgHwGuca_1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp7.iq.pl ([86.111.240.244]:49865 "EHLO smtp7.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750868AbdHJKGq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 06:06:46 -0400
In-Reply-To: <CAM_iQpW908ri7ecz4ThD+fFESQoTvZLu-2Pu6wEtgHwGuca_1w@mail.gmail.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi


yes there are some stack traces more

enp24s0f3 - this NIC is used only for ssh to the host (not much traffic 
on it)

enp216s0f1 - this NIC was have 6Mpps TX traffic (when stack trace occured)

enp216s0f0 - this NIC was have 6Mpps RX traffic (when stack trace occured)


- complete dmesg with stack traces for all nics below:

[53838.303348] NETDEV WATCHDOG: enp24s0f3 (igb): transmit queue 1 timed out
[53838.303358] ------------[ cut here ]------------
[53838.303363] WARNING: CPU: 0 PID: 8 at net/sched/sch_generic.c:316 
dev_watchdog+0xc5/0x122
[53838.303363] Modules linked in: sch_fq x86_pkg_temp_thermal ipmi_si
[53838.303367] CPU: 0 PID: 8 Comm: ksoftirqd/0 Not tainted 
4.13.0-rc4-next-20170808 #1
[53838.303368] task: ffff88046da39400 task.stack: ffffc900001b8000
[53838.303369] RIP: 0010:dev_watchdog+0xc5/0x122
[53838.303369] RSP: 0018:ffffc900001bbda0 EFLAGS: 00010286
[53838.303370] RAX: 000000000000003c RBX: ffff88046beb6000 RCX: 
0000000000000000
[53838.303371] RDX: ffff88046fa13310 RSI: ffff88046fa0ca98 RDI: 
ffff88046fa0ca98
[53838.303371] RBP: ffffc900001bbdb0 R08: 0000000000000000 R09: 
0000000000000000
[53838.303372] R10: ffff88046fa188e0 R11: ffff88087ff94a84 R12: 
0000000000000001
[53838.303372] R13: ffffffff815e0007 R14: ffff88046beb6438 R15: 
ffff88046beb6000
[53838.303373] FS:  0000000000000000(0000) GS:ffff88046fa00000(0000) 
knlGS:0000000000000000
[53838.303374] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[53838.303374] CR2: 00007ffc18047d58 CR3: 000000046c51f003 CR4: 
00000000007606f0
[53838.303375] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[53838.303375] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
0000000000000400
[53838.303376] PKRU: 55555554
[53838.303376] Call Trace:
[53838.303381]  call_timer_fn+0x5b/0x123
[53838.303382]  run_timer_softirq+0x137/0x15a
[53838.303386]  ? pick_next_task_fair+0x139/0x2f9
[53838.303388]  __do_softirq+0xe4/0x23a
[53838.303390]  ? sort_range+0x1d/0x1d
[53838.303391]  run_ksoftirqd+0x15/0x2a
[53838.303392]  smpboot_thread_fn+0x128/0x13f
[53838.303394]  kthread+0xf7/0xfc
[53838.303395]  ? init_completion+0x24/0x24
[53838.303399]  ret_from_fork+0x22/0x30
[53838.303400] Code: 62 68 6e 00 00 75 38 48 89 df c6 05 56 68 6e 00 01 
e8 f4 49 fe ff 44 89 e1 48 89 de 48 c7 c7 5b 3d ac 81 48 89 c2 e8 c8 26 
a9 ff <0f> ff eb 10 41 ff c4 48 05 40 01 00 00 41 39 f4 75 9a eb 0d 48
[53838.303417] ---[ end trace cf42df41100f38ce ]---
[53838.303555] igb 0000:18:00.3 enp24s0f3: Reset adapter
[53843.119595] igb 0000:18:00.3 enp24s0f3: igb: enp24s0f3 NIC Link is Up 
1000 Mbps Full Duplex, Flow Control: RX
[56238.303636] igb 0000:18:00.3 enp24s0f3: Reset adapter
[56241.651735] igb 0000:18:00.3 enp24s0f3: igb: enp24s0f3 NIC Link is Up 
1000 Mbps Full Duplex, Flow Control: RX
[59482.865823] nr_pdflush_threads exported in /proc is scheduled for removal
[59697.280051] ------------[ cut here ]------------
[59697.280060] WARNING: CPU: 45 PID: 237 at kernel/rcu/tree.c:2700 
rcu_process_callbacks+0x327/0x36f
[59697.280061] Modules linked in: sch_fq x86_pkg_temp_thermal ipmi_si
[59697.280066] CPU: 45 PID: 237 Comm: ksoftirqd/45 Tainted: G        
W       4.13.0-rc4-next-20170808 #1
[59697.280067] task: ffff88086d07a800 task.stack: ffffc90003bd4000
[59697.280069] RIP: 0010:rcu_process_callbacks+0x327/0x36f
[59697.280070] RSP: 0018:ffffc90003bd7e00 EFLAGS: 00010097
[59697.280071] RAX: 0000000000000246 RBX: ffff88087fa598c0 RCX: 
ffffffffffffd800
[59697.280071] RDX: 0000000000000001 RSI: ffffc90003bd7e18 RDI: 
ffff88087fa598f8
[59697.280072] RBP: ffffc90003bd7e60 R08: 0000000000000068 R09: 
00000000ffffff80
[59697.280073] R10: ffffc90003bd7dd8 R11: 000000000001cc80 R12: 
ffffffff81c423c0
[59697.280073] R13: ffffc90003bd7e18 R14: ffff88087fa598f8 R15: 
ffff88086d07a800
[59697.280074] FS:  0000000000000000(0000) GS:ffff88087fa40000(0000) 
knlGS:0000000000000000
[59697.280075] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[59697.280075] CR2: 00007fffd1a54000 CR3: 000000086bc53001 CR4: 
00000000007606e0
[59697.280076] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[59697.280077] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
0000000000000400
[59697.280077] PKRU: 55555554
[59697.280078] Call Trace:
[59697.280081]  ? net_rx_action+0x21e/0x22d
[59697.280084]  __do_softirq+0xe4/0x23a
[59697.280088]  ? sort_range+0x1d/0x1d
[59697.280089]  run_ksoftirqd+0x15/0x2a
[59697.280090]  smpboot_thread_fn+0x128/0x13f
[59697.280093]  kthread+0xf7/0xfc
[59697.280094]  ? init_completion+0x24/0x24
[59697.280099]  ret_from_fork+0x22/0x30
[59697.280100] Code: 8b 8b 90 00 00 00 48 2b 0d 2b 4e bc 00 48 39 ca 7d 
07 48 89 93 90 00 00 00 48 83 7b 38 00 0f 94 c1 48 85 d2 0f 94 c2 38 d1 
74 02 <0f> ff 50 9d 4c 89 f7 e8 55 22 00 00 84 c0 74 09 e8 06 f1 ff ff
[59697.280120] ---[ end trace cf42df41100f38cf ]---
[59697.280251] BUG: Bad page state in process ksoftirqd/49 pfn:85537d
[59697.280253] page:ffffea002154df40 count:0 mapcount:-1 
mapping:          (null) index:0xffff88085537db00
[59697.280393] flags: 0x600000000000000()
[59697.280510] raw: 0600000000000000 0000000000000000 ffff88085537db00 
00000000fffffffe
[59697.280511] raw: 0000000000000000 0000000100000001 0000000000000000 
0000000000000000
[59697.280511] page dumped because: nonzero mapcount
[59697.280512] Modules linked in: sch_fq x86_pkg_temp_thermal ipmi_si
[59697.280515] CPU: 49 PID: 257 Comm: ksoftirqd/49 Tainted: G        
W       4.13.0-rc4-next-20170808 #1
[59697.280516] Call Trace:
[59697.280521]  dump_stack+0x4d/0x63
[59697.280526]  bad_page+0xf3/0x10f
[59697.280528]  check_new_page_bad+0x73/0x75
[59697.280529]  get_page_from_freelist+0x419/0x63f
[59697.280532]  ? ip_finish_output+0x11f/0x12b
[59697.280533]  __alloc_pages_nodemask+0xf2/0x187
[59697.280536]  ? ip_route_input_rcu+0x489/0x7d3
[59697.280540]  alloc_pages_current+0x85/0x8c
[59697.280542]  new_slab+0xc2/0x2f7
[59697.280544]  ___slab_alloc+0x350/0x3cd
[59697.280547]  ? __build_skb+0x28/0xa4
[59697.280550]  ? __netif_receive_skb_core+0x325/0x4c0
[59697.280551]  __slab_alloc+0x12/0x17
[59697.280552]  ? __slab_alloc+0x12/0x17
[59697.280554]  kmem_cache_alloc+0x50/0x112
[59697.280555]  __build_skb+0x28/0xa4
[59697.280556]  build_skb+0x12/0x41
[59697.280560]  ixgbe_poll+0x6e4/0xeef
[59697.280562]  net_rx_action+0xd3/0x22d
[59697.280563]  __do_softirq+0xe4/0x23a
[59697.280565]  ? sort_range+0x1d/0x1d
[59697.280566]  run_ksoftirqd+0x15/0x2a
[59697.280567]  smpboot_thread_fn+0x128/0x13f
[59697.280568]  kthread+0xf7/0xfc
[59697.280569]  ? init_completion+0x24/0x24
[59697.280572]  ret_from_fork+0x22/0x30
[59697.280573] Disabling lock debugging due to kernel taint
[60087.124142] BUG: Bad page state in process ksoftirqd/50 pfn:84ed9f
[60087.124145] page:ffffea00213b67c0 count:0 mapcount:-127 
mapping:          (null) index:0x0
[60087.124279] flags: 0x600000000000000()
[60087.124396] raw: 0600000000000000 0000000000000000 0000000000000000 
00000000ffffff80
[60087.124397] raw: ffffea0021a029a0 ffffea00215302a0 0000000000000000 
0000000000000000
[60087.124397] page dumped because: nonzero mapcount
[60087.124398] Modules linked in: sch_fq x86_pkg_temp_thermal ipmi_si
[60087.124403] CPU: 50 PID: 262 Comm: ksoftirqd/50 Tainted: G B   
W       4.13.0-rc4-next-20170808 #1
[60087.124404] Call Trace:
[60087.124411]  dump_stack+0x4d/0x63
[60087.124415]  bad_page+0xf3/0x10f
[60087.124417]  free_pages_check+0x75/0x7f
[60087.124419]  __free_pages_ok+0xaf/0x158
[60087.124420]  page_frag_free+0x47/0x49
[60087.124424]  skb_free_head+0x19/0x22
[60087.124425]  skb_release_data+0x89/0x90
[60087.124427]  skb_release_all+0x1f/0x22
[60087.124428]  _kfree_skb_defer+0x1e/0x5b
[60087.124430]  napi_consume_skb+0x3e/0x41
[60087.124434]  ixgbe_poll+0xe7/0xeef
[60087.124437]  net_rx_action+0xd3/0x22d
[60087.124439]  __do_softirq+0xe4/0x23a
[60087.124443]  ? sort_range+0x1d/0x1d
[60087.124443]  run_ksoftirqd+0x15/0x2a
[60087.124444]  smpboot_thread_fn+0x128/0x13f
[60087.124447]  kthread+0xf7/0xfc
[60087.124448]  ? init_completion+0x24/0x24
[60087.124452]  ret_from_fork+0x22/0x30
[60175.047713] BUG: Bad page state in process perf  pfn:84ed9f
[60175.047715] page:ffffea00213b67c0 count:44363 mapcount:0 
mapping:          (null) index:0x0
[60175.047849] flags: 0x600000000000000()
[60175.047964] raw: 0600000000000000 0000000000000000 0000000000000000 
0000ad4bffffffff
[60175.047965] raw: dead000000000100 dead000000000200 0000000000000000 
0000000000000000
[60175.047965] page dumped because: nonzero _count
[60175.047966] Modules linked in: sch_fq x86_pkg_temp_thermal ipmi_si
[60175.047970] CPU: 28 PID: 8325 Comm: perf Tainted: G    B W       
4.13.0-rc4-next-20170808 #1
[60175.047971] Call Trace:
[60175.047980]  dump_stack+0x4d/0x63
[60175.047986]  bad_page+0xf3/0x10f
[60175.047988]  check_new_page_bad+0x73/0x75
[60175.047989]  get_page_from_freelist+0x2a9/0x63f
[60175.047990]  __alloc_pages_nodemask+0xf2/0x187
[60175.047994]  new_slab+0xd6/0x2f7
[60175.047996]  ___slab_alloc+0x350/0x3cd
[60175.048000]  ? kzalloc_node+0xf/0x11
[60175.048001]  ? __alloc_pages_nodemask+0xf2/0x187
[60175.048002]  __slab_alloc+0x12/0x17
[60175.048004]  ? __slab_alloc+0x12/0x17
[60175.048005]  __kmalloc_node+0x92/0x10c
[60175.048007]  kzalloc_node+0xf/0x11
[60175.048008]  reserve_ds_buffers+0x90/0x30d
[60175.048010]  x86_reserve_hardware+0xbd/0xcd
[60175.048011]  x86_pmu_event_init+0x50/0x1c9
[60175.048013]  perf_try_init_event+0x41/0x72
[60175.048014]  perf_event_alloc+0x36f/0x61a
[60175.048016]  SYSC_perf_event_open+0x3fa/0xb22
[60175.048018]  SyS_perf_event_open+0x9/0xb
[60175.048022]  entry_SYSCALL_64_fastpath+0x13/0x94
[60175.048023] RIP: 0033:0x7f4b74add5c9
[60175.048024] RSP: 002b:00007ffe273ff6f8 EFLAGS: 00000202 ORIG_RAX: 
000000000000012a
[60175.048025] RAX: ffffffffffffffda RBX: 00007ffe273ff830 RCX: 
00007f4b74add5c9
[60175.048026] RDX: 00000000ffffffff RSI: 0000000000000000 RDI: 
00007ffe273ff740
[60175.048027] RBP: 00007ffe273ff800 R08: 0000000000000000 R09: 
00007ffe273ffa40
[60175.048027] R10: 00000000ffffffff R11: 0000000000000202 R12: 
0000000000000000
[60175.048028] R13: 00007ffe273ffaf0 R14: 0000000000000001 R15: 
00007ffe274050b0
[60205.531673] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
[60205.775698] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, 
Flow Control: None
[60226.155671] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
[60226.399691] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, 
Flow Control: None
[60401.551685] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
[60401.795723] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, 
Flow Control: None
[60580.967690] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
[60581.315732] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, 
Flow Control: None
[60961.112120] BUG: Bad page state in process ksoftirqd/44 pfn:855f2f
[60961.112123] page:ffffea002157cbc0 count:51910 mapcount:0 
mapping:          (null) index:0x0
[60961.112259] flags: 0x600000000000000()
[60961.112375] raw: 0600000000000000 0000000000000000 0000000000000000 
0000cac6ffffffff
[60961.112376] raw: dead000000000100 dead000000000200 0000000000000000 
0000000000000000
[60961.112377] page dumped because: nonzero _count
[60961.112377] Modules linked in: sch_fq x86_pkg_temp_thermal ipmi_si
[60961.112381] CPU: 44 PID: 232 Comm: ksoftirqd/44 Tainted: G B   
W       4.13.0-rc4-next-20170808 #1
[60961.112382] Call Trace:
[60961.112390]  dump_stack+0x4d/0x63
[60961.112394]  bad_page+0xf3/0x10f
[60961.112396]  check_new_page_bad+0x73/0x75
[60961.112397]  get_page_from_freelist+0x2a9/0x63f
[60961.112398]  __alloc_pages_nodemask+0xf2/0x187
[60961.112403]  alloc_pages_current+0x85/0x8c
[60961.112405]  new_slab+0xc2/0x2f7
[60961.112407]  ___slab_alloc+0x350/0x3cd
[60961.112409]  ? fq_enqueue+0x24e/0x3e3 [sch_fq]
[60961.112411]  __slab_alloc+0x12/0x17
[60961.112412]  ? __slab_alloc+0x12/0x17
[60961.112413]  kmem_cache_alloc+0x50/0x112
[60961.112414]  fq_enqueue+0x24e/0x3e3 [sch_fq]
[60961.112419]  ? ixgbe_select_queue+0x15/0x17
[60961.112422]  __dev_queue_xmit+0x2a5/0x4b9
[60961.112423]  dev_queue_xmit+0xb/0xd
[60961.112423]  ? dev_queue_xmit+0xb/0xd
[60961.112425]  vlan_dev_hard_start_xmit+0x81/0xaa
[60961.112426]  dev_hard_start_xmit+0xc3/0x197
[60961.112427]  __dev_queue_xmit+0x38d/0x4b9
[60961.112429]  ? eth_header+0x27/0xab
[60961.112429]  dev_queue_xmit+0xb/0xd
[60961.112430]  ? dev_queue_xmit+0xb/0xd
[60961.112432]  neigh_connected_output+0x9b/0xb2
[60961.112436]  ip_finish_output2+0x24e/0x292
[60961.112437]  ip_finish_output+0x11f/0x12b
[60961.112438]  ip_output+0x56/0xa7
[60961.112441]  ? ip_route_input_rcu+0x489/0x7d3
[60961.112442]  ip_forward_finish+0x53/0x58
[60961.112443]  ip_forward+0x2ff/0x350
[60961.112443]  ? ip_frag_mem+0x1e/0x1e
[60961.112444]  ip_rcv_finish+0x27f/0x28a
[60961.112445]  ip_rcv+0x2c0/0x30d
[60961.112448]  __netif_receive_skb_core+0x325/0x4c0
[60961.112449]  __netif_receive_skb+0x18/0x5a
[60961.112450]  ? dev_gro_receive+0x2a9/0x3b4
[60961.112451]  ? __netif_receive_skb+0x18/0x5a
[60961.112452]  netif_receive_skb_internal+0x4b/0x96
[60961.112453]  napi_gro_receive+0x75/0xcc
[60961.112455]  ixgbe_poll+0xed8/0xeef
[60961.112459]  ? __printk_ratelimit+0x8/0x15
[60961.112460]  net_rx_action+0xd3/0x22d
[60961.112462]  __do_softirq+0xe4/0x23a
[60961.112465]  ? sort_range+0x1d/0x1d
[60961.112466]  run_ksoftirqd+0x15/0x2a
[60961.112467]  smpboot_thread_fn+0x128/0x13f
[60961.112470]  kthread+0xf7/0xfc
[60961.112471]  ? init_completion+0x24/0x24
[60961.112475]  ret_from_fork+0x22/0x30
[60983.541418] capability: warning: `turbostat' uses 32-bit capabilities 
(legacy support in use)
[61179.159683] ixgbe 0000:d8:00.1 enp216s0f1: detected SFP+: 4
[61179.503705] ixgbe 0000:d8:00.1 enp216s0f1: NIC Link is Up 10 Gbps, 
Flow Control: None
[61183.212237] BUG: Bad page state in process ksoftirqd/52 pfn:855f2f
[61183.212240] page:ffffea002157cbc0 count:-1 mapcount:0 
mapping:          (null) index:0x0
[61183.212375] flags: 0x600000000000000()
[61183.212492] raw: 0600000000000000 0000000000000000 0000000000000000 
ffffffffffffffff
[61183.212493] raw: dead000000000100 dead000000000200 0000000000000000 
0000000000000000
[61183.212493] page dumped because: nonzero _count
[61183.212494] Modules linked in: sch_fq x86_pkg_temp_thermal ipmi_si
[61183.212498] CPU: 52 PID: 272 Comm: ksoftirqd/52 Tainted: G B   
W       4.13.0-rc4-next-20170808 #1
[61183.212500] Call Trace:
[61183.212507]  dump_stack+0x4d/0x63
[61183.212512]  bad_page+0xf3/0x10f
[61183.212514]  check_new_page_bad+0x73/0x75
[61183.212515]  get_page_from_freelist+0x2a9/0x63f
[61183.212517]  __alloc_pages_nodemask+0xf2/0x187
[61183.212523]  ixgbe_alloc_rx_buffers+0x77/0x1bb
[61183.212524]  ixgbe_poll+0x421/0xeef
[61183.212529]  ? cfs_rq_util_change+0x1e/0x20
[61183.212532]  net_rx_action+0xd3/0x22d
[61183.212534]  __do_softirq+0xe4/0x23a
[61183.212536]  ? sort_range+0x1d/0x1d
[61183.212537]  run_ksoftirqd+0x15/0x2a
[61183.212538]  smpboot_thread_fn+0x128/0x13f
[61183.212540]  kthread+0xf7/0xfc
[61183.212541]  ? init_completion+0x24/0x24
[61183.212546]  ret_from_fork+0x22/0x30
[61183.283732] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
[61183.527747] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, 
Flow Control: None
[61223.651684] ixgbe 0000:d8:00.1 enp216s0f1: detected SFP+: 4
[61223.891712] ixgbe 0000:d8:00.1 enp216s0f1: NIC Link is Up 10 Gbps, 
Flow Control: None
[61228.651748] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
[61228.891759] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, 
Flow Control: None
[61408.583698] ixgbe 0000:d8:00.1 enp216s0f1: detected SFP+: 4
[61408.831720] ixgbe 0000:d8:00.1 enp216s0f1: NIC Link is Up 10 Gbps, 
Flow Control: None
[61414.003718] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
[61414.247764] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, 
Flow Control: None
[63318.496105] igb 0000:18:00.3 enp24s0f3: Reset adapter
[63321.828156] igb 0000:18:00.3 enp24s0f3: igb: enp24s0f3 NIC Link is Up 
1000 Mbps Full Duplex, Flow Control: RX



W dniu 2017-08-10 o 01:27, Cong Wang pisze:
> On Wed, Aug 9, 2017 at 8:50 AM, Paweł Staszewski <pstaszewski@itcare.pl> wrote:
>>
>>
>> [60961.112120] BUG: Bad page state in process ksoftirqd/44 pfn:855f2f
>> [60961.112123] page:ffffea002157cbc0 count:51910 mapcount:0 mapping:
>> (null) index:0x0
>> [60961.112259] flags: 0x600000000000000()
>> [60961.112375] raw: 0600000000000000 0000000000000000 0000000000000000
>> 0000cac6ffffffff
>> [60961.112376] raw: dead000000000100 dead000000000200 0000000000000000
>> 0000000000000000
>> [60961.112377] page dumped because: nonzero _count
>> [60961.112377] Modules linked in: sch_fq x86_pkg_temp_thermal ipmi_si
>> [60961.112381] CPU: 44 PID: 232 Comm: ksoftirqd/44 Tainted: G B   W
>> 4.13.0-rc4-next-20170808 #1
>> [60961.112382] Call Trace:
>> [60961.112390]  dump_stack+0x4d/0x63
>> [60961.112394]  bad_page+0xf3/0x10f
>> [60961.112396]  check_new_page_bad+0x73/0x75
>> [60961.112397]  get_page_from_freelist+0x2a9/0x63f
>> [60961.112398]  __alloc_pages_nodemask+0xf2/0x187
>> [60961.112403]  alloc_pages_current+0x85/0x8c
>> [60961.112405]  new_slab+0xc2/0x2f7
>> [60961.112407]  ___slab_alloc+0x350/0x3cd
>> [60961.112409]  ? fq_enqueue+0x24e/0x3e3 [sch_fq]
>> [60961.112411]  __slab_alloc+0x12/0x17
>> [60961.112412]  ? __slab_alloc+0x12/0x17
>> [60961.112413]  kmem_cache_alloc+0x50/0x112
>> [60961.112414]  fq_enqueue+0x24e/0x3e3 [sch_fq]
>> [60961.112419]  ? ixgbe_select_queue+0x15/0x17
>> [60961.112422]  __dev_queue_xmit+0x2a5/0x4b9
>> [60961.112423]  dev_queue_xmit+0xb/0xd
>
> Is this the first stack trace in your dmesg?
>
> It doesn't look like a bug in sch_fq, but like we have
> a bad mm page somewhere else, perhaps ixgbe driver.
>
>
>
>> [60961.112423]  ? dev_queue_xmit+0xb/0xd
>> [60961.112425]  vlan_dev_hard_start_xmit+0x81/0xaa
>> [60961.112426]  dev_hard_start_xmit+0xc3/0x197
>> [60961.112427]  __dev_queue_xmit+0x38d/0x4b9
>> [60961.112429]  ? eth_header+0x27/0xab
>> [60961.112429]  dev_queue_xmit+0xb/0xd
>> [60961.112430]  ? dev_queue_xmit+0xb/0xd
>> [60961.112432]  neigh_connected_output+0x9b/0xb2
>> [60961.112436]  ip_finish_output2+0x24e/0x292
>> [60961.112437]  ip_finish_output+0x11f/0x12b
>> [60961.112438]  ip_output+0x56/0xa7
>> [60961.112441]  ? ip_route_input_rcu+0x489/0x7d3
>> [60961.112442]  ip_forward_finish+0x53/0x58
>> [60961.112443]  ip_forward+0x2ff/0x350
>> [60961.112443]  ? ip_frag_mem+0x1e/0x1e
>> [60961.112444]  ip_rcv_finish+0x27f/0x28a
>> [60961.112445]  ip_rcv+0x2c0/0x30d
>> [60961.112448]  __netif_receive_skb_core+0x325/0x4c0
>> [60961.112449]  __netif_receive_skb+0x18/0x5a
>> [60961.112450]  ? dev_gro_receive+0x2a9/0x3b4
>> [60961.112451]  ? __netif_receive_skb+0x18/0x5a
>> [60961.112452]  netif_receive_skb_internal+0x4b/0x96
>> [60961.112453]  napi_gro_receive+0x75/0xcc
>> [60961.112455]  ixgbe_poll+0xed8/0xeef
>> [60961.112459]  ? __printk_ratelimit+0x8/0x15
>> [60961.112460]  net_rx_action+0xd3/0x22d
>> [60961.112462]  __do_softirq+0xe4/0x23a
>> [60961.112465]  ? sort_range+0x1d/0x1d
>> [60961.112466]  run_ksoftirqd+0x15/0x2a
>> [60961.112467]  smpboot_thread_fn+0x128/0x13f
>> [60961.112470]  kthread+0xf7/0xfc
>> [60961.112471]  ? init_completion+0x24/0x24
>> [60961.112475]  ret_from_fork+0x22/0x30
>> [60983.541418] capability: warning: `turbostat' uses 32-bit capabilities
>> (legacy support in use)
>> [61179.159683] ixgbe 0000:d8:00.1 enp216s0f1: detected SFP+: 4
>> [61179.503705] ixgbe 0000:d8:00.1 enp216s0f1: NIC Link is Up 10 Gbps, Flow
>> Control: None
>> [61183.212237] BUG: Bad page state in process ksoftirqd/52 pfn:855f2f
>> [61183.212240] page:ffffea002157cbc0 count:-1 mapcount:0 mapping:
>> (null) index:0x0
>> [61183.212375] flags: 0x600000000000000()
>> [61183.212492] raw: 0600000000000000 0000000000000000 0000000000000000
>> ffffffffffffffff
>> [61183.212493] raw: dead000000000100 dead000000000200 0000000000000000
>> 0000000000000000
>> [61183.212493] page dumped because: nonzero _count
>> [61183.212494] Modules linked in: sch_fq x86_pkg_temp_thermal ipmi_si
>> [61183.212498] CPU: 52 PID: 272 Comm: ksoftirqd/52 Tainted: G B   W
>> 4.13.0-rc4-next-20170808 #1
>> [61183.212500] Call Trace:
>> [61183.212507]  dump_stack+0x4d/0x63
>> [61183.212512]  bad_page+0xf3/0x10f
>> [61183.212514]  check_new_page_bad+0x73/0x75
>> [61183.212515]  get_page_from_freelist+0x2a9/0x63f
>> [61183.212517]  __alloc_pages_nodemask+0xf2/0x187
>> [61183.212523]  ixgbe_alloc_rx_buffers+0x77/0x1bb
>> [61183.212524]  ixgbe_poll+0x421/0xeef
>> [61183.212529]  ? cfs_rq_util_change+0x1e/0x20
>> [61183.212532]  net_rx_action+0xd3/0x22d
>> [61183.212534]  __do_softirq+0xe4/0x23a
>> [61183.212536]  ? sort_range+0x1d/0x1d
>> [61183.212537]  run_ksoftirqd+0x15/0x2a
>> [61183.212538]  smpboot_thread_fn+0x128/0x13f
>> [61183.212540]  kthread+0xf7/0xfc
>> [61183.212541]  ? init_completion+0x24/0x24
>> [61183.212546]  ret_from_fork+0x22/0x30
>> [61183.283732] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
>> [61183.527747] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, Flow
>> Control: None
>> [61223.651684] ixgbe 0000:d8:00.1 enp216s0f1: detected SFP+: 4
>> [61223.891712] ixgbe 0000:d8:00.1 enp216s0f1: NIC Link is Up 10 Gbps, Flow
>> Control: None
>> [61228.651748] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
>> [61228.891759] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, Flow
>> Control: None
>> [61408.583698] ixgbe 0000:d8:00.1 enp216s0f1: detected SFP+: 4
>> [61408.831720] ixgbe 0000:d8:00.1 enp216s0f1: NIC Link is Up 10 Gbps, Flow
>> Control: None
>> [61414.003718] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
>> [61414.247764] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, Flow
>> Control: None
>> [63318.496105] igb 0000:18:00.3 enp24s0f3: Reset adapter
>> [63321.828156] igb 0000:18:00.3 enp24s0f3: igb: enp24s0f3 NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX
>>
>>
>>
>>
>>
>> If matters configuration below:
>>
>>   tc -s -d qdisc show
>> qdisc noqueue 0: dev lo root refcnt 2
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>> qdisc mq 0: dev enp24s0f3 root
>>   Sent 10595979 bytes 44275 pkt (dropped 0, overlimits 0 requeues 7)
>>   backlog 0b 0p requeues 7
>> qdisc pfifo_fast 0: dev enp24s0f3 parent :8 bands 3 priomap  1 2 2 2 1 2 0 0
>> 1 1 1 1 1 1 1 1
>>   Sent 2562064 bytes 7304 pkt (dropped 0, overlimits 0 requeues 1)
>>   backlog 0b 0p requeues 1
>> qdisc pfifo_fast 0: dev enp24s0f3 parent :7 bands 3 priomap  1 2 2 2 1 2 0 0
>> 1 1 1 1 1 1 1 1
>>   Sent 152292 bytes 3589 pkt (dropped 0, overlimits 0 requeues 2)
>>   backlog 0b 0p requeues 2
>> qdisc pfifo_fast 0: dev enp24s0f3 parent :6 bands 3 priomap  1 2 2 2 1 2 0 0
>> 1 1 1 1 1 1 1 1
>>   Sent 7298 bytes 15 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>> qdisc pfifo_fast 0: dev enp24s0f3 parent :5 bands 3 priomap  1 2 2 2 1 2 0 0
>> 1 1 1 1 1 1 1 1
>>   Sent 5042 bytes 5 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>> qdisc pfifo_fast 0: dev enp24s0f3 parent :4 bands 3 priomap  1 2 2 2 1 2 0 0
>> 1 1 1 1 1 1 1 1
>>   Sent 3194 bytes 4 pkt (dropped 0, overlimits 0 requeues 1)
>>   backlog 0b 0p requeues 1
>> qdisc pfifo_fast 0: dev enp24s0f3 parent :3 bands 3 priomap  1 2 2 2 1 2 0 0
>> 1 1 1 1 1 1 1 1
>>   Sent 5386576 bytes 13206 pkt (dropped 0, overlimits 0 requeues 1)
>>   backlog 0b 0p requeues 1
>> qdisc pfifo_fast 0: dev enp24s0f3 parent :2 bands 3 priomap  1 2 2 2 1 2 0 0
>> 1 1 1 1 1 1 1 1
>>   Sent 6286 bytes 24 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>> qdisc pfifo_fast 0: dev enp24s0f3 parent :1 bands 3 priomap  1 2 2 2 1 2 0 0
>> 1 1 1 1 1 1 1 1
>>   Sent 2473227 bytes 20128 pkt (dropped 0, overlimits 0 requeues 2)
>>   backlog 0b 0p requeues 2
>> qdisc mq 1: dev enp216s0f0 root
>>   Sent 140 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>> qdisc fq 831c: dev enp216s0f0 parent 1:a limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 8320: dev enp216s0f0 parent 1:e limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 831e: dev enp216s0f0 parent 1:c limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 8322: dev enp216s0f0 parent 1:10 limit 8192p flow_limit 100p
>> buckets 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate
>> 10Gbit refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 8313: dev enp216s0f0 parent 1:1 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 8315: dev enp216s0f0 parent 1:3 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 8317: dev enp216s0f0 parent 1:5 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 831b: dev enp216s0f0 parent 1:9 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 8319: dev enp216s0f0 parent 1:7 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 140 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    1 flows (1 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 831d: dev enp216s0f0 parent 1:b limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 831f: dev enp216s0f0 parent 1:d limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 8321: dev enp216s0f0 parent 1:f limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 8316: dev enp216s0f0 parent 1:4 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 8314: dev enp216s0f0 parent 1:2 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 8318: dev enp216s0f0 parent 1:6 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc fq 831a: dev enp216s0f0 parent 1:8 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>    0 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 0 throttled
>> qdisc mq 1: dev enp216s0f1 root
>>   Sent 5724464060294 bytes 3017574303 pkt (dropped 261703917, overlimits 0
>> requeues 1588)
>>   backlog 19340684b 68101p requeues 1588
>> qdisc fq 8331: dev enp216s0f1 parent 1:f limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357754034478 bytes 1261904590 pkt (dropped 16345926, overlimits 0
>> requeues 99)
>>   backlog 1190528b 4198p requeues 99
>>    64 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 15 throttled, 2238 ns latency, 16345926 flows_plimit
>> qdisc fq 8324: dev enp216s0f1 parent 1:2 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357941986556 bytes 1265190082 pkt (dropped 16334441, overlimits 0
>> requeues 114)
>>   backlog 1203308b 4237p requeues 114
>>    64 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 56 throttled, 1988 ns latency, 16334441 flows_plimit
>> qdisc fq 8326: dev enp216s0f1 parent 1:4 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357756741808 bytes 1261951272 pkt (dropped 16352852, overlimits 0
>> requeues 108)
>>   backlog 1195356b 4210p requeues 108
>>    64 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 10 throttled, 1652 ns latency, 16352852 flows_plimit
>> qdisc fq 832a: dev enp216s0f1 parent 1:8 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357754168172 bytes 1261906634 pkt (dropped 16375523, overlimits 0
>> requeues 93)
>>   backlog 1191664b 4196p requeues 93
>>    64 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 4 throttled, 1722 ns latency, 16375523 flows_plimit
>> qdisc fq 8328: dev enp216s0f1 parent 1:6 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357755800928 bytes 1261934832 pkt (dropped 16297692, overlimits 0
>> requeues 89)
>>   backlog 1206432b 4248p requeues 89
>>    65 flows (1 inactive, 0 throttled)
>>    0 gc, 0 highprio, 4 throttled, 1520 ns latency, 16297692 flows_plimit
>> qdisc fq 832c: dev enp216s0f1 parent 1:a limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357757943172 bytes 1261969807 pkt (dropped 16393936, overlimits 0
>> requeues 97)
>>   backlog 1185984b 4176p requeues 97
>>    64 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 4 throttled, 1257 ns latency, 16393936 flows_plimit
>> qdisc fq 832e: dev enp216s0f1 parent 1:c limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357754956814 bytes 1261920403 pkt (dropped 16373257, overlimits 0
>> requeues 111)
>>   backlog 1184848b 4172p requeues 111
>>    65 flows (1 inactive, 0 throttled)
>>    0 gc, 0 highprio, 11 throttled, 2070 ns latency, 16373257 flows_plimit
>> qdisc fq 8332: dev enp216s0f1 parent 1:10 limit 8192p flow_limit 100p
>> buckets 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate
>> 10Gbit refill_delay 40.0ms
>>   Sent 357754779582 bytes 1261916755 pkt (dropped 16306559, overlimits 0
>> requeues 80)
>>   backlog 1151336b 4054p requeues 80
>>    65 flows (1 inactive, 0 throttled)
>>    0 gc, 0 highprio, 3 throttled, 1530 ns latency, 16306559 flows_plimit
>> qdisc fq 8330: dev enp216s0f1 parent 1:e limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357754801422 bytes 1261919138 pkt (dropped 16360298, overlimits 0
>> requeues 68)
>>   backlog 1266072b 4457p requeues 68
>>    64 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 7 throttled, 1114 ns latency, 16360298 flows_plimit
>> qdisc fq 8325: dev enp216s0f1 parent 1:3 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357756968400 bytes 1261953663 pkt (dropped 16377069, overlimits 0
>> requeues 84)
>>   backlog 1267492b 4463p requeues 84
>>    64 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 6 throttled, 2470 ns latency, 16377069 flows_plimit
>> qdisc fq 8323: dev enp216s0f1 parent 1:1 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357944308424 bytes 1265224502 pkt (dropped 16351766, overlimits 0
>> requeues 125)
>>   backlog 1227164b 4321p requeues 125
>>    65 flows (1 inactive, 0 throttled)
>>    0 gc, 0 highprio, 58 throttled, 2143 ns latency, 16351766 flows_plimit
>> qdisc fq 8327: dev enp216s0f1 parent 1:5 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357756634544 bytes 1261949446 pkt (dropped 16354220, overlimits 0
>> requeues 114)
>>   backlog 1176896b 4143p requeues 114
>>    64 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 5 throttled, 2274 ns latency, 16354220 flows_plimit
>> qdisc fq 8329: dev enp216s0f1 parent 1:7 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357755020876 bytes 1261921756 pkt (dropped 16366535, overlimits 0
>> requeues 108)
>>   backlog 1171216b 4124p requeues 108
>>    65 flows (1 inactive, 0 throttled)
>>    0 gc, 0 highprio, 3 throttled, 932 ns latency, 16366535 flows_plimit
>> qdisc fq 832d: dev enp216s0f1 parent 1:b limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357755470474 bytes 1261930198 pkt (dropped 16347462, overlimits 0
>> requeues 99)
>>   backlog 1255848b 4422p requeues 99
>>    64 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 5 throttled, 1699 ns latency, 16347462 flows_plimit
>> qdisc fq 832b: dev enp216s0f1 parent 1:9 limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357754977102 bytes 1261920885 pkt (dropped 16407954, overlimits 0
>> requeues 92)
>>   backlog 1260108b 4437p requeues 92
>>    64 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 5 throttled, 1638 ns latency, 16407954 flows_plimit
>> qdisc fq 832f: dev enp216s0f1 parent 1:d limit 8192p flow_limit 100p buckets
>> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
>> refill_delay 40.0ms
>>   Sent 357755499918 bytes 1261929638 pkt (dropped 16358427, overlimits 0
>> requeues 107)
>>   backlog 1194220b 4205p requeues 107
>>    64 flows (0 inactive, 0 throttled)
>>    0 gc, 0 highprio, 8 throttled, 2257 ns latency, 16358427 flows_plimit
>> qdisc noqueue 0: dev vlan1000 root refcnt 2
>>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>   backlog 0b 0p requeues 0
>>
>>   ethtool -k enp216s0f1
>> Features for enp216s0f1:
>> Cannot get device udp-fragmentation-offload settings: Operation not
>> supported
>> rx-checksumming: on
>> tx-checksumming: on
>>          tx-checksum-ipv4: off [fixed]
>>          tx-checksum-ip-generic: on
>>          tx-checksum-ipv6: off [fixed]
>>          tx-checksum-fcoe-crc: off [fixed]
>>          tx-checksum-sctp: on
>> scatter-gather: on
>>          tx-scatter-gather: on
>>          tx-scatter-gather-fraglist: off [fixed]
>> tcp-segmentation-offload: on
>>          tx-tcp-segmentation: on
>>          tx-tcp-ecn-segmentation: off [fixed]
>>          tx-tcp-mangleid-segmentation: on
>>          tx-tcp6-segmentation: on
>> udp-fragmentation-offload: off
>> generic-segmentation-offload: off
>> generic-receive-offload: on
>> large-receive-offload: off
>> rx-vlan-offload: on
>> tx-vlan-offload: on
>> ntuple-filters: on
>> receive-hashing: on
>> highdma: on [fixed]
>> rx-vlan-filter: on
>> vlan-challenged: off [fixed]
>> tx-lockless: off [fixed]
>> netns-local: off [fixed]
>> tx-gso-robust: off [fixed]
>> tx-fcoe-segmentation: off [fixed]
>> tx-gre-segmentation: on
>> tx-gre-csum-segmentation: on
>> tx-ipxip4-segmentation: on
>> tx-ipxip6-segmentation: on
>> tx-udp_tnl-segmentation: on
>> tx-udp_tnl-csum-segmentation: on
>> tx-gso-partial: on
>> tx-sctp-segmentation: off [fixed]
>> tx-esp-segmentation: off [fixed]
>> fcoe-mtu: off [fixed]
>> tx-nocache-copy: on
>> loopback: off [fixed]
>> rx-fcs: off [fixed]
>> rx-all: off
>> tx-vlan-stag-hw-insert: off [fixed]
>> rx-vlan-stag-hw-parse: off [fixed]
>> rx-vlan-stag-filter: off [fixed]
>> l2-fwd-offload: off
>> hw-tc-offload: on
>> esp-hw-offload: off [fixed]
>> esp-tx-csum-hw-offload: off [fixed]
>> rx-udp_tunnel-port-offload: on
>>
>>   ethtool -k enp216s0f0
>> Features for enp216s0f0:
>> Cannot get device udp-fragmentation-offload settings: Operation not
>> supported
>> rx-checksumming: on
>> tx-checksumming: on
>>          tx-checksum-ipv4: off [fixed]
>>          tx-checksum-ip-generic: on
>>          tx-checksum-ipv6: off [fixed]
>>          tx-checksum-fcoe-crc: off [fixed]
>>          tx-checksum-sctp: on
>> scatter-gather: on
>>          tx-scatter-gather: on
>>          tx-scatter-gather-fraglist: off [fixed]
>> tcp-segmentation-offload: on
>>          tx-tcp-segmentation: on
>>          tx-tcp-ecn-segmentation: off [fixed]
>>          tx-tcp-mangleid-segmentation: on
>>          tx-tcp6-segmentation: on
>> udp-fragmentation-offload: off
>> generic-segmentation-offload: off
>> generic-receive-offload: on
>> large-receive-offload: off
>> rx-vlan-offload: on
>> tx-vlan-offload: on
>> ntuple-filters: on
>> receive-hashing: on
>> highdma: on [fixed]
>> rx-vlan-filter: on
>> vlan-challenged: off [fixed]
>> tx-lockless: off [fixed]
>> netns-local: off [fixed]
>> tx-gso-robust: off [fixed]
>> tx-fcoe-segmentation: off [fixed]
>> tx-gre-segmentation: on
>> tx-gre-csum-segmentation: on
>> tx-ipxip4-segmentation: on
>> tx-ipxip6-segmentation: on
>> tx-udp_tnl-segmentation: on
>> tx-udp_tnl-csum-segmentation: on
>> tx-gso-partial: on
>> tx-sctp-segmentation: off [fixed]
>> tx-esp-segmentation: off [fixed]
>> fcoe-mtu: off [fixed]
>> tx-nocache-copy: on
>> loopback: off [fixed]
>> rx-fcs: off [fixed]
>> rx-all: off
>> tx-vlan-stag-hw-insert: off [fixed]
>> rx-vlan-stag-hw-parse: off [fixed]
>> rx-vlan-stag-filter: off [fixed]
>> l2-fwd-offload: off
>> hw-tc-offload: off
>> esp-hw-offload: off [fixed]
>> esp-tx-csum-hw-offload: off [fixed]
>> rx-udp_tunnel-port-offload: on
>>
>>
