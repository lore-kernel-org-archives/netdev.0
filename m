From: linux@eikelenboom.it
Subject: =?utf-8?q?Xen-unstable_+_Linux_4=2E2-rc4=3A_GPF_RIP?=
 =?utf-8?q?=3A_e030=3A=5B=3Cffffffff8110ea98=3E=5D_=5B=3Cffffffff8110ea98?=
 =?utf-8?q?=3E=5D_detach=5Fif=5Fpending+0x18/0x80?=
Date: Wed, 29 Jul 2015 23:21:49 +0200
Message-ID: <4ade625e19b1376e18e2346dbad41e8a@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml@vger.kernel.org, xen-devel@lists.xen.org
To: Thomas Gleixner <tglx@linutronix.de>, Eric Dumazet <edumazet@google.com>
Return-path: <xen-devel-bounces@lists.xen.org>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

Hi,

Running on Xen testing a 4.2-rc4 kernel it got the crash below.

Could this be related to the changes in 
3bb475a3446facd0425d3f2fe7e85bf03c5c6c05 ?

It crashes dom0 when i put some strain onto the network + bridge.

--
Sander


[ 2108.078763] general protection fault: 0000 [#1] SMP
[ 2108.102839] Modules linked in:
[ 2108.121598] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
4.2.0-rc4-20150728-linus-noipv6-doflr+ #1
[ 2108.157188] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS 
V1.8B1 09/13/2010
[ 2108.190430] task: ffffffff8221a580 ti: ffffffff82200000 task.ti: 
ffffffff82200000
[ 2108.222309] RIP: e030:[<ffffffff8110ea98>]  [<ffffffff8110ea98>] 
detach_if_pending+0x18/0x80
[ 2108.257037] RSP: e02b:ffff88005f603818  EFLAGS: 00010086
[ 2108.282424] RAX: ffff88005f6cf410 RBX: ffff8800511a6a60 RCX: 
dead000000200200
[ 2108.313210] RDX: 0000000000000000 RSI: ffff88005f60e5c0 RDI: 
ffff8800511a6a60
[ 2108.344013] RBP: ffff88005f603818 R08: 0000000000000001 R09: 
0000000000000001
[ 2108.374795] R10: 0000000000000003 R11: ffff8800511a69c0 R12: 
0000000000000000
[ 2108.405446] R13: 0000000100098b49 R14: 0000000000015f90 R15: 
ffff88005f60e5c0
[ 2108.435784] FS:  00007fe7e790d700(0000) GS:ffff88005f600000(0000) 
knlGS:0000000000000000
[ 2108.469081] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2108.495152] CR2: 00000000017eeca0 CR3: 0000000004c30000 CR4: 
0000000000000660
[ 2108.525520] Stack:
[ 2108.540406]  ffff88005f603868 ffffffff8110edbf ffffffff810fb1e1 
0000000000000200
[ 2108.571288]  0000000000000003 ffff8800511a69c0 0000000000000000 
ffff880004d5d600
[ 2108.602370]  0000000000015f90 0000000000000000 ffff88005f603898 
ffffffff819b3ad3
[ 2108.633153] Call Trace:
[ 2108.649088]  <IRQ>
[ 2108.654784]  [<ffffffff8110edbf>] mod_timer_pending+0x3f/0xe0
[ 2108.689320]  [<ffffffff810fb1e1>] ? 
__raw_callee_save___pv_queued_spin_unlock+0x11/0x20
[ 2108.721899]  [<ffffffff819b3ad3>] __nf_ct_refresh_acct+0xa3/0xb0
[ 2108.748221]  [<ffffffff819ba71b>] tcp_packet+0xb3b/0x1290
[ 2108.772816]  [<ffffffff81a7c0b5>] ? br_forward_finish+0x25/0x80
[ 2108.798706]  [<ffffffff81102342>] ? irq_to_desc+0x12/0x20
[ 2108.822802]  [<ffffffff810ca8ca>] ? __local_bh_enable_ip+0x2a/0x90
[ 2108.849145]  [<ffffffff819b31f9>] ? 
__nf_conntrack_find_get+0x129/0x2a0
[ 2108.876796]  [<ffffffff819b50bc>] nf_conntrack_in+0x29c/0x7c0
[ 2108.901830]  [<ffffffff81a65651>] ipv4_conntrack_in+0x21/0x30
[ 2108.926819]  [<ffffffff819ad29c>] nf_iterate+0x4c/0x80
[ 2108.949863]  [<ffffffff819ad334>] nf_hook_slow+0x64/0xc0
[ 2108.973297]  [<ffffffff81a87acc>] br_nf_pre_routing+0x33c/0x350
[ 2108.999934]  [<ffffffff81a87370>] ? br_nf_forward_ip+0x3d0/0x3d0
[ 2109.025256]  [<ffffffff819ad29c>] nf_iterate+0x4c/0x80
[ 2109.047697]  [<ffffffff819ad334>] nf_hook_slow+0x64/0xc0
[ 2109.070579]  [<ffffffff81a7d830>] br_handle_frame+0x190/0x270
[ 2109.094725]  [<ffffffff81a7d1f0>] ? br_handle_local_finish+0x50/0x50
[ 2109.120526]  [<ffffffff81a7d6a0>] ? 
br_handle_frame_finish+0x4b0/0x4b0
[ 2109.146523]  [<ffffffff8197c87b>] 
__netif_receive_skb_core+0x12b/0x970
[ 2109.172583]  [<ffffffff8100aeed>] ? 
set_foreign_p2m_mapping+0x19d/0x3a0
[ 2109.198956]  [<ffffffff8197efb5>] __netif_receive_skb+0x15/0x70
[ 2109.223214]  [<ffffffff8197f02e>] 
netif_receive_skb_internal+0x1e/0x80
[ 2109.249274]  [<ffffffff8197f09c>] netif_receive_skb_sk+0xc/0x10
[ 2109.273450]  [<ffffffff8174dd29>] xenvif_tx_action+0x6a9/0x830
[ 2109.297488]  [<ffffffff8173f6bd>] ? rtl8169_poll+0x8d/0x600
[ 2109.320699]  [<ffffffff81750279>] xenvif_poll+0x29/0x70
[ 2109.342620]  [<ffffffff81980387>] net_rx_action+0x1f7/0x300
[ 2109.365337]  [<ffffffff810ca6c3>] __do_softirq+0x103/0x210
[ 2109.387677]  [<ffffffff810ca9cb>] irq_exit+0x4b/0xa0
[ 2109.408519]  [<ffffffff814f03e4>] xen_evtchn_do_upcall+0x34/0x50
[ 2109.432419]  [<ffffffff81af886e>] 
xen_do_hypervisor_callback+0x1e/0x40
[ 2109.457772]  <EOI>
[ 2109.463493]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
[ 2109.494059]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
[ 2109.518541]  [<ffffffff81008d00>] ? xen_safe_halt+0x10/0x20
[ 2109.540952]  [<ffffffff81018a93>] ? default_idle+0x13/0x20
[ 2109.563055]  [<ffffffff81018fda>] ? arch_cpu_idle+0xa/0x10
[ 2109.585071]  [<ffffffff810f8dfe>] ? default_idle_call+0x2e/0x50
[ 2109.608257]  [<ffffffff810f9092>] ? cpu_startup_entry+0x272/0x2e0
[ 2109.631954]  [<ffffffff81ae6dd7>] ? rest_init+0x77/0x80
[ 2109.652953]  [<ffffffff82312f5f>] ? start_kernel+0x442/0x44f
[ 2109.675099]  [<ffffffff823124ef>] ? 
x86_64_start_reservations+0x2a/0x2c
[ 2109.700145]  [<ffffffff8231600f>] ? xen_start_kernel+0x550/0x55c
[ 2109.723264] Code: 77 28 5d c3 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 
00 00 48 8b 47 08 55 48 89 e5 48 85 c0 74 6a 48 8b 0f 48 85 c9 48 89 08 
74 04 <48> 89 41 08 84 d2 74 08 48 c7 47 08 00 00 00 00 f6 47 2a 10 48
[ 2109.789794] RIP  [<ffffffff8110ea98>] detach_if_pending+0x18/0x80
[ 2109.813416]  RSP <ffff88005f603818>
[ 2109.829199] ---[ end trace 042bd0c1a92729d3 ]---
[ 2109.848376] Kernel panic - not syncing: Fatal exception in interrupt
[ 2109.872793] Kernel Offset: disabled
