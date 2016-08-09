From: linux@eikelenboom.it
Subject: 4.8.0-rc1: page allocation failure: order:3,
 =?UTF-8?Q?mode=3A=30x=32=30=38=34=30=32=30=28GFP=5FATOMIC=7C=5F=5FGFP=5FC?=
 =?UTF-8?Q?OMP=29?=
Date: Tue, 09 Aug 2016 12:19:03 +0200
Message-ID: <8bdcb66dc3eb2448e4b6f2baef2ad8ea@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.eikelenboom.it ([91.121.65.215]:33338 "EHLO
	server.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932284AbcHIKar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:30:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L.S.,

Just tested 4.8.0-rc1, but i get the stack trace below, everything seems 
to continue fine afterwards though
(haven't tried to bisect it yet, hopefully someone has an insight 
without having to go through that :) )
My network config consists of a bridge and NAT.

--
Sander

[10469.336815] swapper/0: page allocation failure: order:3, 
mode:0x2084020(GFP_ATOMIC|__GFP_COMP)
[10469.336820] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
4.8.0-rc1-20160808-linus-doflr+ #1
[10469.336821] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS 
V1.8B1 09/13/2010
[10469.336825]  0000000000000000 ffff88005f603228 ffffffff81456ca5 
0000000000000000
[10469.336828]  0000000000000003 ffff88005f6032b0 ffffffff811633ed 
020840205fd0f000
[10469.336830]  0000000000000000 ffff88005f603278 0208402000000008 
000000035fd0f500
[10469.336832] Call Trace:
[10469.336834]  <IRQ>  [<ffffffff81456ca5>] dump_stack+0x87/0xb2
[10469.336845]  [<ffffffff811633ed>] warn_alloc_failed+0xdd/0x140
[10469.336847]  [<ffffffff811638b1>] __alloc_pages_nodemask+0x3e1/0xcf0
[10469.336851]  [<ffffffff810edebf>] ? check_preempt_curr+0x4f/0x90
[10469.336852]  [<ffffffff810edf12>] ? ttwu_do_wakeup+0x12/0x90
[10469.336855]  [<ffffffff811a72ed>] alloc_pages_current+0x8d/0x110
[10469.336857]  [<ffffffff8117cb7f>] kmalloc_order+0x1f/0x70
[10469.336859]  [<ffffffff811aec19>] __kmalloc+0x129/0x140
[10469.336861]  [<ffffffff8146d561>] bucket_table_alloc+0xc1/0x1d0
[10469.336862]  [<ffffffff8146da1d>] rhashtable_insert_rehash+0x5d/0xe0
[10469.336865]  [<ffffffff819fbe70>] ? __nf_nat_l4proto_find+0x20/0x20
[10469.336866]  [<ffffffff819fcfff>] nf_nat_setup_info+0x2ef/0x400
[10469.336869]  [<ffffffff81aa88d5>] nf_nat_masquerade_ipv4+0xd5/0x100
[10469.336870]  [<ffffffff81aacda2>] masquerade_tg+0x32/0x40
[10469.336872]  [<ffffffff81aa8f4e>] ipt_do_table+0x29e/0x3b0
[10469.336873]  [<ffffffff81aab8da>] iptable_nat_do_chain+0x1a/0x20
[10469.336875]  [<ffffffff81aa61df>] nf_nat_ipv4_fn+0x12f/0x1e0
[10469.336876]  [<ffffffff81aab8c0>] ? iptable_nat_ipv4_fn+0x20/0x20
[10469.336877]  [<ffffffff81aa6347>] nf_nat_ipv4_out+0x37/0x40
[10469.336878]  [<ffffffff81aab910>] iptable_nat_ipv4_out+0x10/0x20
[10469.336880]  [<ffffffff819df148>] nf_iterate+0x58/0x70
[10469.336881]  [<ffffffff819df1bf>] nf_hook_slow+0x5f/0xb0
[10469.336884]  [<ffffffff81a60aa5>] ip_output+0xb5/0xd0
[10469.336886]  [<ffffffff81a5ff00>] ? 
ip_fragment.constprop.43+0x80/0x80
[10469.336887]  [<ffffffff81a5cbdb>] ip_forward_finish+0x3b/0x60
[10469.336888]  [<ffffffff81a5cec8>] ip_forward+0x2c8/0x390
[10469.336890]  [<ffffffff81a5cba0>] ? ip_frag_mem+0x40/0x40
[10469.336891]  [<ffffffff81a5b0f5>] ip_rcv_finish+0x1b5/0x3a0
[10469.336892]  [<ffffffff81a5b789>] ip_rcv+0x279/0x380
[10469.336895]  [<ffffffff8199ab02>] ? skb_copy_ubufs+0xf2/0x290
[10469.336896]  [<ffffffff81a5af40>] ? 
ip_local_deliver_finish+0x120/0x120
[10469.336898]  [<ffffffff819aab72>] 
__netif_receive_skb_core+0x2d2/0x9e0
[10469.336900]  [<ffffffff819ad141>] __netif_receive_skb+0x11/0x70
[10469.336901]  [<ffffffff819ad1be>] 
netif_receive_skb_internal+0x1e/0x80
[10469.336902]  [<ffffffff819df1bf>] ? nf_hook_slow+0x5f/0xb0
[10469.336906]  [<ffffffff819ad229>] netif_receive_skb+0x9/0x10
[10469.336910]  [<ffffffff81b00c2e>] br_pass_frame_up+0x6e/0xe0
[10469.336911]  [<ffffffff81b00bb0>] ? 
__br_handle_local_finish+0x40/0x40
[10469.336913]  [<ffffffff81b00dc3>] br_handle_frame_finish+0x123/0x4a0
[10469.336914]  [<ffffffff81aa623e>] ? nf_nat_ipv4_fn+0x18e/0x1e0
[10469.336916]  [<ffffffff81b0def3>] 
br_nf_pre_routing_finish+0x183/0x380
[10469.336918]  [<ffffffff81b00ca0>] ? br_pass_frame_up+0xe0/0xe0
[10469.336919]  [<ffffffff81b0e492>] br_nf_pre_routing+0x2b2/0x390
[10469.336920]  [<ffffffff81b0dd70>] ? br_nf_forward_ip+0x410/0x410
[10469.336921]  [<ffffffff819df148>] nf_iterate+0x58/0x70
[10469.336922]  [<ffffffff819df1bf>] nf_hook_slow+0x5f/0xb0
[10469.336924]  [<ffffffff81b0134e>] br_handle_frame+0x1ce/0x2d0
[10469.336926]  [<ffffffff81b00ca0>] ? br_pass_frame_up+0xe0/0xe0
[10469.336927]  [<ffffffff81b01180>] ? br_handle_local_finish+0x40/0x40
[10469.336928]  [<ffffffff819aa9cb>] 
__netif_receive_skb_core+0x12b/0x9e0
[10469.336932]  [<ffffffff810219b4>] ? set_phys_to_machine+0x14/0x40
[10469.336934]  [<ffffffff81021b80>] ? 
set_foreign_p2m_mapping+0x1a0/0x3a0
[10469.336935]  [<ffffffff819ad141>] __netif_receive_skb+0x11/0x70
[10469.336937]  [<ffffffff819ad1be>] 
netif_receive_skb_internal+0x1e/0x80
[10469.336939]  [<ffffffff819ad229>] netif_receive_skb+0x9/0x10
[10469.336941]  [<ffffffff817704e3>] xenvif_tx_action+0x693/0x820
[10469.336944]  [<ffffffff8110d0e1>] ? 
__handle_irq_event_percpu+0x31/0x100
[10469.336945]  [<ffffffff81773079>] xenvif_poll+0x29/0x70
[10469.336949]  [<ffffffff81106d25>] ? do_raw_spin_unlock+0x55/0xa0
[10469.336950]  [<ffffffff819ae8c1>] net_rx_action+0x211/0x320
[10469.336953]  [<ffffffff810d1243>] __do_softirq+0x103/0x210
[10469.336955]  [<ffffffff810d155b>] irq_exit+0x4b/0xa0
[10469.336957]  [<ffffffff81503180>] xen_evtchn_do_upcall+0x30/0x40
[10469.336961]  [<ffffffff81b8107e>] 
xen_do_hypervisor_callback+0x1e/0x40
[10469.336962]  <EOI>  [<ffffffff810013aa>] ? 
xen_hypercall_sched_op+0xa/0x20
[10469.336965]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
[10469.336967]  [<ffffffff8101fb00>] ? xen_safe_halt+0x10/0x20
[10469.336970]  [<ffffffff810302b3>] ? default_idle+0x13/0x20
[10469.336971]  [<ffffffff8103079a>] ? arch_cpu_idle+0xa/0x10
[10469.336973]  [<ffffffff8110289e>] ? default_idle_call+0x2e/0x50
[10469.336974]  [<ffffffff81102b16>] ? cpu_startup_entry+0x256/0x2c0
[10469.336975]  [<ffffffff81b78152>] ? rest_init+0x72/0x80
[10469.336979]  [<ffffffff82323f38>] ? start_kernel+0x410/0x41d
[10469.336981]  [<ffffffff82323499>] ? 
x86_64_start_reservations+0x2f/0x31
[10469.336983]  [<ffffffff8232a763>] ? xen_start_kernel+0x547/0x553
[10469.336984] Mem-Info:
[10469.336989] active_anon:55875 inactive_anon:70482 isolated_anon:0
  active_file:71530 inactive_file:77473 isolated_file:0
  unevictable:601 dirty:3644 writeback:0 unstable:0
  slab_reclaimable:23415 slab_unreclaimable:11066
  mapped:7925 shmem:322 pagetables:2756 bounce:0
  free:11987 free_pcp:747 free_cma:0
[10469.336993] Node 0 active_anon:223500kB inactive_anon:281928kB 
active_file:286120kB inactive_file:309892kB unevictable:2404kB 
isolated(anon):0kB isolated(file):0kB mapped:31700kB dirty:14576kB 
writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 
1288kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? 
no
[10469.336994] Node 0 DMA free:5536kB min:52kB low:64kB high:76kB 
active_anon:104kB inactive_anon:0kB active_file:1200kB 
inactive_file:2776kB unevictable:0kB writepending:0kB present:15968kB 
managed:15884kB mlocked:0kB slab_reclaimable:5912kB 
slab_unreclaimable:140kB kernel_stack:64kB pagetables:0kB bounce:0kB 
free_pcp:0kB local_pcp:0kB free_cma:0kB
[10469.336997] lowmem_reserve[]: 0 1378 1378 1378
[10469.337000] Node 0 DMA32 free:42412kB min:4720kB low:6128kB 
high:7536kB active_anon:223396kB inactive_anon:281928kB 
active_file:284920kB inactive_file:307116kB unevictable:2404kB 
writepending:14576kB present:1556480kB managed:1439640kB mlocked:2404kB 
slab_reclaimable:87748kB slab_unreclaimable:44124kB kernel_stack:11728kB 
pagetables:11024kB bounce:0kB free_pcp:2988kB local_pcp:412kB 
free_cma:0kB
[10469.337003] lowmem_reserve[]: 0 0 0 0
[10469.337005] Node 0 DMA: 206*4kB (MEH) 149*8kB (UMEH) 86*16kB (UMEH) 
23*32kB (M) 14*64kB (UME) 4*128kB (M) 0*256kB 0*512kB 0*1024kB 0*2048kB 
0*4096kB = 5536kB
[10469.337013] Node 0 DMA32: 5388*4kB (UMEH) 2125*8kB (UMEH) 248*16kB 
(M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 
42520kB
[10469.337020] 149853 total pagecache pages
[10469.337021] 1 pages in swap cache
[10469.337022] Swap cache stats: add 23, delete 22, find 0/0
[10469.337023] Free swap  = 2097056kB
[10469.337023] Total swap = 2097148kB
[10469.337024] 393112 pages RAM
[10469.337024] 0 pages HighMem/MovableOnly
[10469.337025] 29231 pages reserved
