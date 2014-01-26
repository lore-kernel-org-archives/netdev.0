From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: 3.14-mw regression:  rtl8169 WARNING: DMA-API: exceeded 7 overlapping mappings of pfn 55ebe
Date: Sun, 26 Jan 2014 11:55:21 +0100
Message-ID: <1859471893.20140126115521@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: =?utf-8?Q?fran=C3=A7ois_romieu?= <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have got a regression with a 3.14-mw kernel (last commit is 4ba9920e5e9c0e16b5ed24292d45322907bb9035):
It looks like it's related to the rtl8169 ...

--
Sander

Jan 26 11:36:26 serveerstertje kernel: [   89.105537] ------------[ cut here ]------------
Jan 26 11:36:26 serveerstertje kernel: [   89.116779] WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x103/0x130()
Jan 26 11:36:26 serveerstertje kernel: [   89.128148] DMA-API: exceeded 7 overlapping mappings of pfn 55ebe
Jan 26 11:36:26 serveerstertje kernel: [   89.139397] Modules linked in:
Jan 26 11:36:26 serveerstertje kernel: [   89.150535] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0-20140125-mw-pcireset+ #1
Jan 26 11:36:26 serveerstertje kernel: [   89.161784] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS V1.8B1 09/13/2010
Jan 26 11:36:26 serveerstertje kernel: [   89.172965]  0000000000000009 ffff88005f603838 ffffffff81acbcfa ffffffff822134e0
Jan 26 11:36:26 serveerstertje kernel: [   89.184156]  ffff88005f603888 ffff88005f603878 ffffffff810bdf62 ffff880000000000
Jan 26 11:36:26 serveerstertje kernel: [   89.195186]  0000000000055ebe 00000000ffffffef 0000000000000200 ffff8800592ea098
Jan 26 11:36:26 serveerstertje kernel: [   89.206227] Call Trace:
Jan 26 11:36:26 serveerstertje kernel: [   89.217027]  <IRQ>  [<ffffffff81acbcfa>] dump_stack+0x46/0x58
Jan 26 11:36:26 serveerstertje kernel: [   89.227907]  [<ffffffff810bdf62>] warn_slowpath_common+0x82/0xb0
Jan 26 11:36:26 serveerstertje kernel: [   89.238678]  [<ffffffff810be031>] warn_slowpath_fmt+0x41/0x50
Jan 26 11:36:26 serveerstertje kernel: [   89.249336]  [<ffffffff81471c5a>] ? active_pfn_read_overlap+0x3a/0x70
Jan 26 11:36:26 serveerstertje kernel: [   89.259904]  [<ffffffff814729e3>] add_dma_entry+0x103/0x130
Jan 26 11:36:26 serveerstertje kernel: [   89.270416]  [<ffffffff81472de6>] debug_dma_map_page+0x126/0x150
Jan 26 11:36:26 serveerstertje kernel: [   89.280840]  [<ffffffff81714686>] rtl8169_start_xmit+0x216/0xa20
Jan 26 11:36:26 serveerstertje kernel: [   89.291073]  [<ffffffff8194aaaa>] ? __kfree_skb+0x3a/0xb0
Jan 26 11:36:26 serveerstertje kernel: [   89.301252]  [<ffffffff81955a3f>] ? dev_queue_xmit_nit+0x1ef/0x260
Jan 26 11:36:26 serveerstertje kernel: [   89.311392]  [<ffffffff81955850>] ? dev_loopback_xmit+0x1e0/0x1e0
Jan 26 11:36:26 serveerstertje kernel: [   89.321418]  [<ffffffff81959b96>] dev_hard_start_xmit+0x2e6/0x4a0
Jan 26 11:36:26 serveerstertje kernel: [   89.331236]  [<ffffffff819778fe>] sch_direct_xmit+0xfe/0x280
Jan 26 11:36:26 serveerstertje kernel: [   89.341013]  [<ffffffff81959f8c>] __dev_queue_xmit+0x23c/0x630
Jan 26 11:36:26 serveerstertje kernel: [   89.350668]  [<ffffffff81959d50>] ? dev_hard_start_xmit+0x4a0/0x4a0
Jan 26 11:36:26 serveerstertje kernel: [   89.360264]  [<ffffffff81a00ce4>] ? ip_output+0x54/0xf0
Jan 26 11:36:26 serveerstertje kernel: [   89.369698]  [<ffffffff8195a39b>] dev_queue_xmit+0xb/0x10
Jan 26 11:36:26 serveerstertje kernel: [   89.379034]  [<ffffffff819ff2bb>] ip_finish_output+0x2cb/0x670
Jan 26 11:36:26 serveerstertje kernel: [   89.388373]  [<ffffffff81a00ce4>] ? ip_output+0x54/0xf0
Jan 26 11:36:26 serveerstertje kernel: [   89.397498]  [<ffffffff81a00ce4>] ip_output+0x54/0xf0
Jan 26 11:36:26 serveerstertje kernel: [   89.406584]  [<ffffffff819fc141>] ip_forward_finish+0x71/0x1a0
Jan 26 11:36:26 serveerstertje kernel: [   89.415534]  [<ffffffff819fc413>] ip_forward+0x1a3/0x440
Jan 26 11:36:26 serveerstertje kernel: [   89.424400]  [<ffffffff819f9f80>] ip_rcv_finish+0x150/0x650
Jan 26 11:36:26 serveerstertje kernel: [   89.433108]  [<ffffffff819faa1b>] ip_rcv+0x22b/0x370
Jan 26 11:36:26 serveerstertje kernel: [   89.441737]  [<ffffffff81a57322>] ? packet_rcv_spkt+0x42/0x190
Jan 26 11:36:26 serveerstertje kernel: [   89.450226]  [<ffffffff81957382>] __netif_receive_skb_core+0x6d2/0x8a0
Jan 26 11:36:26 serveerstertje kernel: [   89.458687]  [<ffffffff81956dc4>] ? __netif_receive_skb_core+0x114/0x8a0
Jan 26 11:36:26 serveerstertje kernel: [   89.467109]  [<ffffffff81008f50>] ? xen_clocksource_read+0x20/0x30
Jan 26 11:36:26 serveerstertje kernel: [   89.475362]  [<ffffffff81116e09>] ? getnstimeofday+0x9/0x30
Jan 26 11:36:26 serveerstertje kernel: [   89.483548]  [<ffffffff8195756c>] __netif_receive_skb+0x1c/0x70
Jan 26 11:36:26 serveerstertje kernel: [   89.491608]  [<ffffffff819575de>] netif_receive_skb_internal+0x1e/0xf0
Jan 26 11:36:26 serveerstertje kernel: [   89.499596]  [<ffffffff81958ac0>] napi_gro_receive+0x70/0xa0
Jan 26 11:36:26 serveerstertje kernel: [   89.507486]  [<ffffffff81711673>] rtl8169_poll+0x2d3/0x680
Jan 26 11:36:26 serveerstertje kernel: [   89.515222]  [<ffffffff81957a81>] net_rx_action+0x161/0x260
Jan 26 11:36:26 serveerstertje kernel: [   89.523097]  [<ffffffff810c28dd>] __do_softirq+0x11d/0x250
Jan 26 11:36:26 serveerstertje kernel: [   89.530973]  [<ffffffff810c2d72>] irq_exit+0xa2/0xd0
Jan 26 11:36:26 serveerstertje kernel: [   89.538915]  [<ffffffff814f94bf>] xen_evtchn_do_upcall+0x2f/0x40
Jan 26 11:36:26 serveerstertje kernel: [   89.546876]  [<ffffffff81ad83de>] xen_do_hypervisor_callback+0x1e/0x30
Jan 26 11:36:26 serveerstertje kernel: [   89.554591]  <EOI>  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
Jan 26 11:36:26 serveerstertje kernel: [   89.562139]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
Jan 26 11:36:26 serveerstertje kernel: [   89.569503]  [<ffffffff81008c70>] ? xen_safe_halt+0x10/0x20
Jan 26 11:36:26 serveerstertje kernel: [   89.576788]  [<ffffffff81018748>] ? default_idle+0x18/0x20
Jan 26 11:36:26 serveerstertje kernel: [   89.583863]  [<ffffffff81018f5e>] ? arch_cpu_idle+0x2e/0x40
Jan 26 11:36:26 serveerstertje kernel: [   89.590627]  [<ffffffff8110b511>] ? cpu_startup_entry+0x91/0x1e0
Jan 26 11:36:26 serveerstertje kernel: [   89.597184]  [<ffffffff81ac0497>] ? rest_init+0xb7/0xc0
Jan 26 11:36:26 serveerstertje kernel: [   89.603507]  [<ffffffff81ac03e0>] ? csum_partial_copy_generic+0x170/0x170
Jan 26 11:36:26 serveerstertje kernel: [   89.609631]  [<ffffffff8230ef1c>] ? start_kernel+0x409/0x416
Jan 26 11:36:26 serveerstertje kernel: [   89.615490]  [<ffffffff8230e912>] ? repair_env_string+0x5e/0x5e
Jan 26 11:36:26 serveerstertje kernel: [   89.621197]  [<ffffffff8230e5f8>] ? x86_64_start_reservations+0x2a/0x2c
Jan 26 11:36:26 serveerstertje kernel: [   89.626592]  [<ffffffff82311e26>] ? xen_start_kernel+0x584/0x586
Jan 26 11:36:26 serveerstertje kernel: [   89.631933] ---[ end trace 206b59d1fe29b5a7 ]---
