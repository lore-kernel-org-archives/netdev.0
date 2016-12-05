From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Kernel panic in netfilter 4.8.10 probably on conntrack -L
Date: Tue, 06 Dec 2016 00:05:58 +0200
Message-ID: <a847cee4824743e7e8b55a017117eb95@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I have quite loaded NAT server (approx 17Gbps of traffic) where periodic 
"conntrack -L" might trigger once per day kernel panic.
I am not definitely sure it is triggered exactly at running tool, or 
just by enabling events.
Here is panic message:

<udp> [221287.380762] general protection fault: 0000 [#1] SMP
<udp> [221287.381029] Modules linked in:
<udp> xt_rateest
<udp> xt_RATEEST
<udp> nf_conntrack_netlink
<udp> netconsole
<udp> configfs
<udp> tun
<udp> nf_nat_pptp
<udp> nf_nat_proto_gre
<udp> xt_TCPMSS
<udp> xt_connmark
<udp> ipt_MASQUERADE
<udp> nf_nat_masquerade_ipv4
<udp> xt_nat
<udp> nf_conntrack_pptp
<udp> nf_conntrack_proto_gre
<udp> xt_CT
<udp> xt_set
<udp> xt_hl
<udp> xt_tcpudp
<udp> ip_set_hash_net
<udp> ip_set
<udp> nfnetlink
<udp> iptable_raw
<udp> iptable_mangle
<udp> iptable_nat
<udp> nf_conntrack_ipv4
<udp> nf_defrag_ipv4
<udp> nf_nat_ipv4
<udp> nf_nat
<udp> nf_conntrack
<udp> iptable_filter
<udp> ip_tables
<udp> x_tables
<udp> 8021q
<udp> garp
<udp> mrp
<udp> stp
<udp> llc
<udp> bonding
<udp> ixgbe
<udp> dca
<udp>
<udp> [221287.384913] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
4.8.10-build-0121 #10
<udp> [221287.385184] Hardware name: Intel Corporation 
S2600WTT/S2600WTT, BIOS SE5C610.86B.01.01.1008.031920151331 03/19/2015
<udp> [221287.385634] task: ffffffff8200b4c0 task.stack: 
ffffffff82000000
<udp> [221287.385900] RIP: 0010:[<ffffffffa009fb95>]
<udp> [<ffffffffa009fb95>] nf_conntrack_eventmask_report+0xba/0x123 
[nf_conntrack]
<udp> [221287.386428] RSP: 0018:ffff882fbf603df8  EFLAGS: 00010202
<udp> [221287.386693] RAX: 0000000000000000 RBX: ffff882f96a51da8 RCX: 
0000000000000000
<udp> [221287.387134] RDX: 0000000000000000 RSI: ffff882fbf603e00 RDI: 
0000000000000004
<udp> [221287.387575] RBP: ffff882fbf603e38 R08: ff81822024ffffff R09: 
0000000000000004
<udp> [221287.388011] R10: ffff882fbf603de0 R11: ffffffff820050c0 R12: 
ffff882f810bf0c0
<udp> [221287.388445] R13: 0000000000000000 R14: 0000000000000000 R15: 
0000000000000004
<udp> [221287.388877] FS:  0000000000000000(0000) 
GS:ffff882fbf600000(0000) knlGS:0000000000000000
<udp> [221287.389311] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<udp> [221287.389567] CR2: 00007faff0bd8978 CR3: 0000000002006000 CR4: 
00000000001406f0
<udp> [221287.389998] Stack:
<udp> [221287.390238]  000000049f292300
<udp> ffff882f810bf0c0
<udp> 0000000000000000
<udp> ffff882f810bf0c0
<udp>
<udp> [221287.390913]  ffff882f96a51d80
<udp> 0000000000000000
<udp> 0000000000000000
<udp> ffffffff820050c8
<udp>
<udp> [221287.391587]  ffff882fbf603e68
<udp> ffffffffa0098bd3
<udp> 0000000080000100
<udp> ffffffffa0098c85
<udp>
<udp> [221287.392262] Call Trace:
<udp> [221287.392508]  <IRQ>
<udp>
<udp> [221287.392579]  [<ffffffffa0098bd3>] nf_ct_delete+0x7a/0x12c 
[nf_conntrack]
<udp> [221287.393082]  [<ffffffffa0098c85>] ? nf_ct_delete+0x12c/0x12c 
[nf_conntrack]
<udp> [221287.393351]  [<ffffffffa0098c92>] death_by_timeout+0xd/0xf 
[nf_conntrack]
<udp> [221287.393617]  [<ffffffff811078ad>] 
call_timer_fn.isra.5+0x17/0x6b
<udp> [221287.393881]  [<ffffffff81107970>] expire_timers+0x6f/0x7e
<udp> [221287.394134]  [<ffffffff81107a68>] run_timer_softirq+0x69/0x8b
<udp> [221287.394390]  [<ffffffff810cefbc>] __do_softirq+0xbd/0x1aa
<udp> [221287.394643]  [<ffffffff810cf1f0>] irq_exit+0x37/0x7c
<udp> [221287.394898]  [<ffffffff8102a703>] 
smp_trace_call_function_single_interrupt+0x2e/0x30
<udp> [221287.395341]  [<ffffffff8102a70e>] 
smp_call_function_single_interrupt+0x9/0xb
<udp> [221287.395600]  [<ffffffff818dbcbc>] 
call_function_single_interrupt+0x7c/0x90
<udp> [221287.395857]  <EOI>
<udp>
<udp> [221287.395926]  [<ffffffff8101b8d7>] ? mwait_idle+0x64/0x7a
<udp> [221287.396413]  [<ffffffff8101bcb2>] arch_cpu_idle+0xa/0xc
<udp> [221287.396665]  [<ffffffff810f670a>] default_idle_call+0x27/0x29
<udp> [221287.396919]  [<ffffffff810f6829>] 
cpu_startup_entry+0x11d/0x1c7
<udp> [221287.397175]  [<ffffffff818d6c3b>] rest_init+0x72/0x74
<udp> [221287.397428]  [<ffffffff820d0e5c>] start_kernel+0x3ba/0x3c7
<udp> [221287.397681]  [<ffffffff820d028f>] 
x86_64_start_reservations+0x2a/0x2c
<udp> [221287.397937]  [<ffffffff820d03bb>] 
x86_64_start_kernel+0x12a/0x135
<udp> [221287.402124] Code:
<udp> f2
<udp> 89
<udp> 75
<udp> d0
<udp> 75
<udp> 04
<udp> 4c
<udp> 8b
<udp> 73
<udp> 08
<udp> 0f
<udp> b7
<udp> 73
<udp> 10
<udp> 41
<udp> 89
<udp> ff
<udp> 4d
<udp> 89
<udp> f1
<udp> 4d
<udp> 09
<udp> f9
<udp> 31
<udp> c0
<udp> 49
<udp> 85
<udp> f1
<udp> 74
<udp> 67
<udp> 41
<udp> 89
<udp> d5
<udp> 89
<udp> 7d
<udp> c4
<udp> 48
<udp> 8d
<udp> 75
<udp> c8
<udp> 44
<udp> 09
<udp> f7
<udp>
<udp> ff
<udp> 10
<udp> 89
<udp> c2
<udp> c1
<udp> ea
<udp> 1f
<udp> 75
<udp> 05
<udp> 4d
<udp> 85
<udp> f6
<udp> 74
<udp> 4b
<udp> 49
<udp> 83
<udp> c4
<udp> 04
<udp> 89
<udp> 45
<udp>
<udp> [221287.406724] RIP
<udp> [<ffffffffa009fb95>] nf_conntrack_eventmask_report+0xba/0x123 
[nf_conntrack]
<udp> [221287.407234]  RSP <ffff882fbf603df8>
<udp> [221287.407489] ---[ end trace 4b077b9412fc7065 ]---
<udp> [221287.407746] Kernel panic - not syncing: Fatal exception in 
interrupt
<udp> [221287.408013] Kernel Offset: disabled
<udp> [221287.408270] Rebooting in 5 seconds..
Dec  5 23:17:58 10.0.253.34
Dec  5 23:17:58 10.0.253.34 [221292.408645] ACPI MEMORY or I/O 
RESET_REG.
