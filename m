From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: 3.16-mergewindow + netnext: BUG: unable to handle kernel paging
 request at ffff880035720000 RIP: e030:[<ffffffff814db3fb>] [<ffffffff814db3fb>]
 csum_partial+0x8b/0x190
Date: Wed, 11 Jun 2014 11:55:17 -0400
Message-ID: <53987BE5.7030406@gmail.com>
References: <282486167.20140611153338@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Sander Eikelenboom <linux@eikelenboom.it>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:45573 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbaFKPzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 11:55:20 -0400
Received: by mail-qa0-f44.google.com with SMTP id j7so11508316qaq.3
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 08:55:19 -0700 (PDT)
In-Reply-To: <282486167.20140611153338@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/2014 09:33 AM, Sander Eikelenboom wrote:
> [  323.500540] BUG: unable to handle kernel paging request at ffff880035720000
> [  323.507324] IP: [<ffffffff814db3fb>] csum_partial+0x8b/0x190
> [  323.514001] PGD 2212067 PUD 2213067 PMD 5fe5f067 PTE 8010000035720064
> [  323.520719] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> [  323.527272] Modules linked in:
> [  323.533853] CPU: 0 PID: 12422 Comm: qemu-system-i38 Not tainted 3.15.0-20140611-netnext+ #1
> [  323.540721] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS V1.8B1 09/13/2010
> [  323.547560] task: ffff88003f7c8000 ti: ffff88003cb6c000 task.ti: ffff88003cb6c000
> [  323.554392] RIP: e030:[<ffffffff814db3fb>]  [<ffffffff814db3fb>] csum_partial+0x8b/0x190
> [  323.561338] RSP: e02b:ffff88005f603870  EFLAGS: 00010a92
> [  323.568109] RAX: cf1dda188f631216 RBX: 0000000000000225 RCX: ffff88003571ffc8
> [  323.575002] RDX: 0000000089647a35 RSI: 000000000000112a RDI: ffff88003571efc8
> [  323.581910] RBP: ffff88005f603878 R08: 0000000000000004 R09: 0000000000000000
> [  323.588699] R10: 0000000000000000 R11: 0000000000000044 R12: ffff880053cfdd40
> [  323.595403] R13: ffff88003571efc2 R14: ffff880053cfef40 R15: 00000000ffff07d1
> [  323.602084] FS:  00007fceaf4688e0(0000) GS:ffff88005f600000(0000) knlGS:0000000000000000
> [  323.608909] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  323.615769] CR2: ffff880035720000 CR3: 000000003f28d000 CR4: 0000000000000660
> [  323.622734] Stack:
> [  323.629478]  0000000000001130 ffff88005f6038e8 ffffffff81ae6923 00000f0d00000000
> [  323.636476]  ffffffff02d28ab9 ffff880053cff180 ffff880053cfef40 000005b40000e91b
> [  323.643532]  00000000ffff07d1 0000000000000000 00000000000089c4 0000000000000014
> [  323.650464] Call Trace:
> [  323.657277]  <IRQ> 
> [  323.657328]  [<ffffffff81ae6923>] tcp_gso_segment+0x393/0x460
> [  323.670873]  [<ffffffff81af6c9c>] inet_gso_segment+0x13c/0x380
> [  323.677685]  [<ffffffff81115ede>] ? __lock_acquire+0x52e/0x2220
> [  323.684542]  [<ffffffff81a12a25>] skb_mac_gso_segment+0xd5/0x1d0
> [  323.691264]  [<ffffffff81a1299d>] ? skb_mac_gso_segment+0x4d/0x1d0
> [  323.697906]  [<ffffffff81a12b80>] __skb_gso_segment+0x60/0xc0
> [  323.704492]  [<ffffffff81a12d7c>] dev_hard_start_xmit+0x19c/0x590
> [  323.711130]  [<ffffffff81a348fe>] sch_direct_xmit+0xfe/0x280
> [  323.717698]  [<ffffffff81a133bf>] __dev_queue_xmit+0x24f/0x670
> [  323.724192]  [<ffffffff81a13175>] ? __dev_queue_xmit+0x5/0x670
> [  323.730538]  [<ffffffff81ac3489>] ? ip_output+0x59/0xf0
> [  323.736913]  [<ffffffff81a13800>] dev_queue_xmit+0x10/0x20
> [  323.743264]  [<ffffffff81ac16f3>] ip_finish_output+0x603/0xce0
> [  323.749457]  [<ffffffff81ac3489>] ? ip_output+0x59/0xf0
> [  323.755644]  [<ffffffff81ac3489>] ip_output+0x59/0xf0
> [  323.761787]  [<ffffffff81abe05b>] ip_forward_finish+0x7b/0x1a0
> [  323.767990]  [<ffffffff81abe46b>] ip_forward+0x2eb/0x490
> [  323.774027]  [<ffffffff8111525b>] ? lock_is_held+0x8b/0xb0
> [  323.780157]  [<ffffffff81abbe20>] ip_rcv_finish+0x150/0x660
> [  323.786246]  [<ffffffff81abc8db>] ip_rcv+0x22b/0x370
> [  323.792197]  [<ffffffff81b1bbe7>] ? packet_rcv_spkt+0x47/0x190
> [  323.798202]  [<ffffffff81a0fbd2>] __netif_receive_skb_core+0x592/0x7b0
> [  323.804390]  [<ffffffff81a0f695>] ? __netif_receive_skb_core+0x55/0x7b0
> [  323.810576]  [<ffffffff8100ae30>] ? xen_clocksource_read+0x20/0x30
> [  323.816691]  [<ffffffff8112ddce>] ? getnstimeofday+0xe/0x30
> [  323.822830]  [<ffffffff81af60a8>] ? inet_gro_complete+0xa8/0xf0
> [  323.828831]  [<ffffffff81a0fe11>] __netif_receive_skb+0x21/0x70
> [  323.834803]  [<ffffffff81a0fe83>] netif_receive_skb_internal+0x23/0xf0
> [  323.840876]  [<ffffffff81118020>] ? lock_release+0x140/0x2b0
> [  323.846850]  [<ffffffff81a02a6f>] ? __kfree_skb+0x3f/0xc0
> [  323.852806]  [<ffffffff81a100cc>] napi_gro_complete+0x10c/0x130
> [  323.858808]  [<ffffffff81a0ffe5>] ? napi_gro_complete+0x25/0x130
> [  323.864727]  [<ffffffff811e7911>] ? kmem_cache_free+0x1b1/0x210
> [  323.870544]  [<ffffffff81a10152>] napi_gro_flush+0x62/0x90
> [  323.876333]  [<ffffffff81a1019e>] napi_complete+0x1e/0xb0
> [  323.882061]  [<ffffffff817aff99>] rtl8169_poll+0x89/0x690
> [  323.887685]  [<ffffffff81b9f2f0>] ? _raw_spin_unlock_irq+0x30/0x50
> [  323.893256]  [<ffffffff81a103ba>] net_rx_action+0x18a/0x2c0
> [  323.898760]  [<ffffffff810d03cf>] __do_softirq+0x11f/0x2f0
> [  323.904345]  [<ffffffff810d090a>] irq_exit+0xaa/0xd0
> [  323.909742]  [<ffffffff8158545c>] xen_evtchn_do_upcall+0x3c/0x50
> [  323.915055]  [<ffffffff81ba1d5e>] xen_do_hypervisor_callback+0x1e/0x30
> [  323.920402]  <EOI> 
> [  323.920453]  [<ffffffff8100122a>] ? xen_hypercall_xen_version+0xa/0x20
> [  323.930777]  [<ffffffff8100122a>] ? xen_hypercall_xen_version+0xa/0x20
> [  323.935881]  [<ffffffff8100aaed>] ? xen_force_evtchn_callback+0xd/0x10
> [  323.941021]  [<ffffffff8100b422>] ? check_events+0x12/0x20
> [  323.946134]  [<ffffffff8100b40f>] ? xen_restore_fl_direct_reloc+0x4/0x4
> [  323.951220]  [<ffffffff81b9d8c5>] ? __mutex_unlock_slowpath+0x1d5/0x280
> [  323.956329]  [<ffffffff81b9da3e>] ? mutex_unlock+0xe/0x10
> [  323.961366]  [<ffffffff8158dac0>] ? evtchn_ioctl+0xf0/0x3a0
> [  323.966335]  [<ffffffff81214242>] ? __fget+0x92/0xe0
> [  323.971216]  [<ffffffff81208f38>] ? do_vfs_ioctl+0x88/0x570
> [  323.976022]  [<ffffffff8121425a>] ? __fget+0xaa/0xe0
> [  323.980779]  [<ffffffff812141b5>] ? __fget+0x5/0xe0
> [  323.985420]  [<ffffffff8120946c>] ? SyS_ioctl+0x4c/0x90
> [  323.990025]  [<ffffffff81ba03b9>] ? system_call_fastpath+0x16/0x1b
> [  323.994591] Code: 85 db 74 47 45 89 d8 48 89 f9 45 31 c9 0f 1f 00 48 03 01 48 13 41 08 48 13 41 10 48 13 41 18 48 13 41 20 48 13 41 28 48 13 41 30 <48> 13 41 38 4c 11 c8 48 83 c1 40 41 83 e8 01 75 d4 41 83 eb 01 
> [  324.004805] RIP  [<ffffffff814db3fb>] csum_partial+0x8b/0x190
> [  324.009784]  RSP <ffff88005f603870>
> [  324.014748] CR2: ffff880035720000
> [  324.019669] ---[ end trace c0948c89b2fd96b8 ]---
> [  324.024639] Kernel panic - not syncing: Fatal exception in interrupt
> [  324.029733] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
> 

Does the following fix it for you?
commit 5882a07c72093dc3a18e2d2b129fb200686bb6ee
Author: Wei-Chun Chao <weichunc@plumgrid.com>
Date:   Sun Jun 8 23:48:54 2014 -0700

    net: fix UDP tunnel GSO of frag_list GRO packets

-vlad
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
