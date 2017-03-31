From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: probably serious conntrack/netfilter panic, 4.8.14, timers and
 intel turbo
Date: Fri, 31 Mar 2017 21:46:01 +0300
Message-ID: <121449f64d51a122d88822bdb4047b00@nuclearcat.com>
References: <9be92e4dc7d83096cbcdaae1a3f77bd3@nuclearcat.com>
 <20170111172243.5yqliuverfhchlju@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:51716 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752491AbdCaSqL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 14:46:11 -0400
In-Reply-To: <20170111172243.5yqliuverfhchlju@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am not sure if it is same issue, but panics still happen, but much 
less. Same server, nat.
I will upgrade to latest 4.10.x build, because for this one i dont have 
files anymore (for symbols and etc).

  [864288.511464] Modules linked in: nf_conntrack_netlink nf_nat_pptp 
nf_nat_proto_gre xt_TCPMSS xt_connmark ipt_MASQUERADE 
nf_nat_masquerade_ipv4 xt_nat xt_rateest xt_RATEEST nf_conntrack_pptp 
nf_conntrack_proto_gre xt_CT xt_set xt_hl xt_tcpudp ip_set_hash_net 
ip_set nfnetlink iptable_raw iptable_mangle iptable_nat 
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack 
iptable_filter ip_tables x_tables netconsole configfs 8021q garp mrp stp 
llc bonding ixgbe dca
  [864288.512740] CPU: 17 PID: 0 Comm: swapper/17 Not tainted 
4.10.1-build-0132 #2
  [864288.513005] Hardware name: Intel Corporation S2600WTT/S2600WTT, 
BIOS SE5C610.86B.01.01.0019.101220160604 10/12/2016
  [864288.513454] task: ffff881038cb6000 task.stack: ffffc9000c678000
  [864288.513719] RIP: 0010:nf_nat_cleanup_conntrack+0xe2/0x1bc [nf_nat]
  [864288.513980] RSP: 0018:ffff88103fc43ba0 EFLAGS: 00010206
  [864288.514237] RAX: ffff140504021ad8 RBX: ffff881004021ad8 RCX: 
0000000001000000
  [864288.514677] RDX: ffff140504021ad8 RSI: ffff88103279628c RDI: 
ffff88103279628c
  [864288.515117] RBP: ffff88103fc43be0 R08: ffffc9003b47b558 R09: 
0000000000000004
  [864288.515558] R10: ffff8820083d00ce R11: ffff881038480b00 R12: 
ffff881004021a40
  [864288.515998] R13: 0000000000000000 R14: ffffffffa00d406e R15: 
ffffc90036e11000
  [864288.516438] FS:  0000000000000000(0000) GS:ffff88103fc40000(0000) 
knlGS:0000000000000000
  [864288.516882] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  [864288.517142] CR2: 00007fbfc303f978 CR3: 000000202267c000 CR4: 
00000000001406e0
  [864288.517580] Call Trace:
  [864288.517831]  <IRQ>
  [864288.518090]  __nf_ct_ext_destroy+0x3f/0x57 [nf_conntrack]
  [864288.518352]  nf_conntrack_free+0x25/0x55 [nf_conntrack]
  [864288.518615]  destroy_conntrack+0x80/0x8c [nf_conntrack]
  [864288.518880]  nf_conntrack_destroy+0x19/0x1b
  [864288.519137]  nf_ct_gc_expired+0x6e/0x71 [nf_conntrack]
  [864288.519400]  __nf_conntrack_find_get+0x89/0x2ab [nf_conntrack]
  [864288.519663]  nf_conntrack_in+0x1ec/0x877 [nf_conntrack]
  [864288.519925]  ipv4_conntrack_in+0x1c/0x1e [nf_conntrack_ipv4]
  [864288.520185]  nf_hook_slow+0x2a/0x9a
  [864288.520439]  ip_rcv+0x318/0x337
  [864288.520692]  ? ip_local_deliver_finish+0x1ba/0x1ba
  [864288.520953]  __netif_receive_skb_core+0x607/0x852
  [864288.521213]  ? kmem_cache_free_bulk+0x232/0x274
  [864288.521471]  __netif_receive_skb+0x18/0x5a
  [864288.521727]  process_backlog+0x90/0x113
  [864288.521981]  net_rx_action+0x114/0x2dc
  [864288.522238]  ? sched_clock_cpu+0x15/0x94
  [864288.522496]  __do_softirq+0xe7/0x259
  [864288.522753]  irq_exit+0x52/0x93
  [864288.523006]  smp_call_function_single_interrupt+0x33/0x35
  [864288.523267]  call_function_single_interrupt+0x83/0x90
  [864288.523531] RIP: 0010:mwait_idle+0x9e/0x125
  [864288.523786] RSP: 0018:ffffc9000c67beb0 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff04
  [864288.524229] RAX: 0000000000000000 RBX: ffff881038cb6000 RCX: 
0000000000000000
  [864288.524669] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
0000000000000000
  [864288.525110] RBP: ffffc9000c67bec0 R08: 0000000000000001 R09: 
0000000000000000
  [864288.525551] R10: ffffc9000c67be50 R11: 0000000000000000 R12: 
0000000000000011
  [864288.525991] R13: 0000000000000000 R14: ffff881038cb6000 R15: 
ffff881038cb6000
  [864288.526429]  </IRQ>
  [864288.526682]  arch_cpu_idle+0xf/0x11
  [864288.526937]  default_idle_call+0x25/0x27
  [864288.527193]  do_idle+0xb6/0x15d
  [864288.527446]  cpu_startup_entry+0x1f/0x21
  [864288.527702]  start_secondary+0xe8/0xeb
  [864288.527961]  start_cpu+0x14/0x14
  [864288.528212] Code: 48 89 f7 48 89 75 c8 e8 6e e8 8f e1 8b 45 c4 48 
8b 75 c8 48 83 c0 08 4d 8d 04 c7 49 8b 04 c7 a8 01 75 46 48 39 c3 74 1e 
48 89 c2 <48> 8b 7a 08 48 85 ff 0f 84 b3 00 00 00 48 39 fb 0f 84 9e 00 
00
  [864288.528905] RIP: nf_nat_cleanup_conntrack+0xe2/0x1bc [nf_nat] RSP: 
ffff88103fc43ba0
  [864288.529362] ---[ end trace e3c40a5e4bf43e26 ]---
  [864288.567835] Kernel panic - not syncing: Fatal exception in 
interrupt
  [864288.568122] Kernel Offset: disabled
  [864288.587619] Rebooting in 5 seconds..
