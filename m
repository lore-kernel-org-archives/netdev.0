From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: __nf_conntrack_find_get - NMI watchdog, 4.10.5
Date: Sat, 25 Mar 2017 14:13:25 +0200
Message-ID: <9d6cf6e5c6e026450747037725fac229@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Netfilter Devel <netfilter-devel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

While applying/removing shapers on few thousands of ppp interfaces got 
pppoe server rebooted with this message:
[51306.144984] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! 
[swapper/0:0]
[51306.145319] Modules linked in: sch_sfq cls_fw act_police cls_u32 
sch_ingress sch_htb pppoe pppox ppp_generic slhc netconsole configfs 
coretemp nf_nat_pptp nf_nat_proto_gre nf_conntr
ack_pptp nf_conntrack_proto_gre tun xt_REDIRECT nf_nat_redirect xt_nat 
xt_TCPMSS ipt_REJECT nf_reject_ipv4 xt_set ts_bm xt_string xt_connmark 
xt_DSCP xt_mark xt_tcpudp ip_set_hash_net ip_set_hash_ip ip_set nfnet
link iptable_mangle iptable_filter iptable_nat nf_conntrack_ipv4 
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack ip_tables x_tables 8021q 
garp mrp stp llc
[51306.146381] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
4.10.5-build-0132 #2
[51306.146577] Hardware name: HP ProLiant DL320e Gen8 v2, BIOS P80 
04/02/2015
[51306.146775] task: ffffffff8200e4c0 task.stack: ffffffff82000000
[51306.146976] RIP: 0010:__nf_conntrack_find_get+0x23/0x2ab 
[nf_conntrack]
[51306.147173] RSP: 0018:ffff880436403c50 EFLAGS: 00000203 ORIG_RAX: 
ffffffffffffff10
[51306.147505] RAX: 000060fbc8a03408 RBX: 7fffc4020277d00a RCX: 
00000000b9a11ba7
[51306.147703] RDX: ffff88042a400000 RSI: ffffffff81c03e00 RDI: 
ffffffff820d2340
[51306.147900] RBP: ffff880436403c80 R08: 000000004f33ff15 R09: 
ffffffff820d2340
[51306.148098] R10: ffff88041032bd10 R11: 0000000000000000 R12: 
ffff880436403cd8
[51306.148295] R13: ffffffff820d2340 R14: ffffffff81c03e00 R15: 
000000000005cd08
[51306.148492] FS:  0000000000000000(0000) GS:ffff880436400000(0000) 
knlGS:0000000000000000
[51306.148824] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[51306.149020] CR2: 00007f455449f768 CR3: 000000042bd64000 CR4: 
00000000001406f0
[51306.149217] Call Trace:
[51306.149410]  <IRQ>
[51306.149605]  nf_conntrack_in+0x1ec/0x877 [nf_conntrack]
[51306.149804]  ? _raw_read_unlock_bh+0x20/0x22
[51306.150000]  ? ppp_input+0x14c/0x157 [ppp_generic]
[51306.150196]  ipv4_conntrack_in+0x1c/0x1e [nf_conntrack_ipv4]
[51306.150394]  nf_hook_slow+0x2a/0x9a
[51306.150589]  ip_rcv+0x318/0x337
[51306.150782]  ? ip_local_deliver_finish+0x1ba/0x1ba
[51306.150980]  __netif_receive_skb_core+0x607/0x852
[51306.151178]  ? swiotlb_sync_single+0x16/0x24
[51306.151373]  __netif_receive_skb+0x18/0x5a
[51306.151566]  process_backlog+0x90/0x113
[51306.151761]  net_rx_action+0x114/0x2dc
[51306.151955]  ? igb_msix_ring+0x2e/0x36
[51306.152151]  __do_softirq+0xe7/0x259
[51306.152347]  irq_exit+0x52/0x93
[51306.152541]  do_IRQ+0xaa/0xc2
[51306.152735]  common_interrupt+0x83/0x83
[51306.152931] RIP: 0010:mwait_idle+0x9e/0x125
[51306.153125] RSP: 0018:ffffffff82003e28 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff1d
[51306.153459] RAX: 0000000000000000 RBX: ffffffff8200e4c0 RCX: 
0000000000000000
[51306.153656] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
0000000000000000
[51306.153853] RBP: ffffffff82003e38 R08: 000000000000009e R09: 
0000000000000000
[51306.154051] R10: ffffffff82003dc8 R11: 0000000000000000 R12: 
0000000000000000
[51306.154247] R13: 0000000000000000 R14: ffffffff8200e4c0 R15: 
ffffffff8200e4c0
[51306.154444]  </IRQ>
[51306.157951]  arch_cpu_idle+0xf/0x11
[51306.158143]  default_idle_call+0x25/0x27
[51306.158336]  do_idle+0xb6/0x15d
[51306.158527]  cpu_startup_entry+0x1f/0x21
[51306.158721]  rest_init+0x77/0x79
[51306.158915]  start_kernel+0x3c9/0x3d6
[51306.159109]  x86_64_start_reservations+0x2a/0x2c
[51306.159307]  x86_64_start_kernel+0x16a/0x178
[51306.159507]  start_cpu+0x14/0x14
[51306.159701] Code: e8 ed d3 93 e1 5b 5d c3 0f 1f 44 00 00 55 89 c8 48 
89 e5 41 57 41 56 49 89 f6 41 55 49 89 fd 41 54 49 89 d4 53 41 50 48 89 
45 d0 <8b> 05 b4 b1 00 00 a8 01 74 04 f3
  90 eb f2 44 8b 3d ad b1 00 00
[51306.160194] Kernel panic - not syncing: softlockup: hung tasks
[51306.160392] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G             L  
4.10.5-build-0132 #2
[51306.160725] Hardware name: HP ProLiant DL320e Gen8 v2, BIOS P80 
04/02/2015
[51306.160922] Call Trace:
[51306.161115]  <IRQ>
[51306.161310]  dump_stack+0x4d/0x63
[51306.161507]  panic+0xd2/0x215
[51306.161702]  watchdog_timer_fn+0x1a9/0x1cb
[51306.161896]  __hrtimer_run_queues+0xe4/0x1e3
[51306.162092]  ? ktime_get_update_offsets_now+0x4f/0xef
[51306.162288]  hrtimer_interrupt+0xa5/0x167
[51306.162483]  local_apic_timer_interrupt+0x4b/0x4e
[51306.162679]  smp_apic_timer_interrupt+0x38/0x48
[51306.162876]  apic_timer_interrupt+0x83/0x90
[51306.163073] RIP: 0010:__nf_conntrack_find_get+0x23/0x2ab 
[nf_conntrack]
[51306.163269] RSP: 0018:ffff880436403c50 EFLAGS: 00000203 ORIG_RAX: 
ffffffffffffff10
[51306.163601] RAX: 000060fbc8a03408 RBX: 7fffc4020277d00a RCX: 
00000000b9a11ba7
[51306.163798] RDX: ffff88042a400000 RSI: ffffffff81c03e00 RDI: 
ffffffff820d2340
[51306.163996] RBP: ffff880436403c80 R08: 000000004f33ff15 R09: 
ffffffff820d2340
[51306.164195] R10: ffff88041032bd10 R11: 0000000000000000 R12: 
ffff880436403cd8
[51306.164394] R13: ffffffff820d2340 R14: ffffffff81c03e00 R15: 
000000000005cd08
[51306.164594]  nf_conntrack_in+0x1ec/0x877 [nf_conntrack]
[51306.164792]  ? _raw_read_unlock_bh+0x20/0x22
[51306.164987]  ? ppp_input+0x14c/0x157 [ppp_generic]
[51306.165184]  ipv4_conntrack_in+0x1c/0x1e [nf_conntrack_ipv4]
[51306.165383]  nf_hook_slow+0x2a/0x9a
[51306.165578]  ip_rcv+0x318/0x337
[51306.165771]  ? ip_local_deliver_finish+0x1ba/0x1ba
[51306.165969]  __netif_receive_skb_core+0x607/0x852
[51306.166166]  ? swiotlb_sync_single+0x16/0x24
[51306.166361]  __netif_receive_skb+0x18/0x5a
[51306.166557]  process_backlog+0x90/0x113
[51306.166751]  net_rx_action+0x114/0x2dc
[51306.166948]  ? igb_msix_ring+0x2e/0x36
[51306.167145]  __do_softirq+0xe7/0x259
[51306.167341]  irq_exit+0x52/0x93
[51306.167534]  do_IRQ+0xaa/0xc2
[51306.167728]  common_interrupt+0x83/0x83
[51306.167926] RIP: 0010:mwait_idle+0x9e/0x125
[51306.168123] RSP: 0018:ffffffff82003e28 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff1d
[51306.168459] RAX: 0000000000000000 RBX: ffffffff8200e4c0 RCX: 
0000000000000000
[51306.168657] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
0000000000000000
[51306.168856] RBP: ffffffff82003e38 R08: 000000000000009e R09: 
0000000000000000
[51306.169056] R10: ffffffff82003dc8 R11: 0000000000000000 R12: 
0000000000000000
[51306.169254] R13: 0000000000000000 R14: ffffffff8200e4c0 R15: 
ffffffff8200e4c0
[51306.169451]  </IRQ>
[51306.169644]  arch_cpu_idle+0xf/0x11
[51306.169842]  default_idle_call+0x25/0x27
[51306.170039]  do_idle+0xb6/0x15d
[51306.170232]  cpu_startup_entry+0x1f/0x21
[51306.170426]  rest_init+0x77/0x79
[51306.170620]  start_kernel+0x3c9/0x3d6
[51306.170815]  x86_64_start_reservations+0x2a/0x2c
[51306.171013]  x86_64_start_kernel+0x16a/0x178
[51306.171209]  start_cpu+0x14/0x14
[51306.171410] Kernel Offset: disabled
[51306.175765] Rebooting in 5 seconds.
