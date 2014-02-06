From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7 overlapping mappings of pfn 55ebe
Date: Thu, 6 Feb 2014 15:27:22 +0100
Message-ID: <932118392.20140206152722@eikelenboom.it>
References: <1859471893.20140126115521@eikelenboom.it> <20140127000305.GA14236@electric-eye.fr.zoreil.com> <CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com> <84816226.20140206123631@eikelenboom.it> <942972114.20140206140909@eikelenboom.it> <CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:33994 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745AbaBFO11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 09:27:27 -0500
In-Reply-To: <CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thursday, February 6, 2014, 3:26:09 PM, you wrote:

> On Thu, Feb 6, 2014 at 5:09 AM, Sander Eikelenboom <linux@eikelenboom.it> wrote:
>> Hmm ok that last message was false .. sorry for that .. it did happen again without r8169.use_dac=1, it just doesn't seem to happen all the time...
>>
>> Konrad / Wei, do you happen to know of any xen related change that went into 3.14 merge window that relates to dma / xen networking ?
>>
>> --
>> Sander
>>
>> complete stacktrace:
>>
>> [  342.710738] ------------[ cut here ]------------
>> [  342.726890] WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x105/0x130()
>> [  342.743210] DMA-API: exceeded 7 overlapping mappings of pfn 40b00
>> [  342.759510] Modules linked in:
>> [  342.775557] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.0-rc1-20140206-pcireset-net-btrevert+ #1
>> [  342.791706] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS V1.8B1 09/13/2010
>> [  342.807627]  0000000000000009 ffff88005f603828 ffffffff81ad29fc ffffffff822134e0
>> [  342.823430]  ffff88005f603878 ffff88005f603868 ffffffff810bdf62 ffff880000000000
>> [  342.839081]  0000000000040b00 00000000ffffffef ffffffff822102e0 ffff8800592b9098
>> [  342.854572] Call Trace:
>> [  342.869748]  <IRQ>  [<ffffffff81ad29fc>] dump_stack+0x46/0x58
>> [  342.884915]  [<ffffffff810bdf62>] warn_slowpath_common+0x82/0xb0
>> [  342.899710]  [<ffffffff810be031>] warn_slowpath_fmt+0x41/0x50
>> [  342.914395]  [<ffffffff8147853a>] ? active_pfn_read_overlap+0x3a/0x70
>> [  342.929166]  [<ffffffff814792c5>] add_dma_entry+0x105/0x130
>> [  342.943733]  [<ffffffff814796c6>] debug_dma_map_page+0x126/0x150
>> [  342.957988]  [<ffffffff8171c8b6>] rtl8169_start_xmit+0x216/0xa20
>> [  342.972306]  [<ffffffff8195f08f>] ? dev_queue_xmit_nit+0x1ef/0x260
>> [  342.986523]  [<ffffffff8195eea0>] ? dev_loopback_xmit+0x1e0/0x1e0
>> [  343.000689]  [<ffffffff819631e6>] dev_hard_start_xmit+0x2e6/0x4a0
>> [  343.014466]  [<ffffffff81980f3e>] sch_direct_xmit+0xfe/0x280
>> [  343.028052]  [<ffffffff819635dc>] __dev_queue_xmit+0x23c/0x630
>> [  343.041338]  [<ffffffff819633a0>] ? dev_hard_start_xmit+0x4a0/0x4a0
>> [  343.054483]  [<ffffffff81a0a334>] ? ip_output+0x54/0xf0
>> [  343.067659]  [<ffffffff819639eb>] dev_queue_xmit+0xb/0x10
>> [  343.080804]  [<ffffffff81a0890b>] ip_finish_output+0x2cb/0x670
>> [  343.093746]  [<ffffffff81a0a334>] ? ip_output+0x54/0xf0
>> [  343.106391]  [<ffffffff81a0a334>] ip_output+0x54/0xf0
>> [  343.118683]  [<ffffffff81a05791>] ip_forward_finish+0x71/0x1a0
>> [  343.130901]  [<ffffffff81a05a63>] ip_forward+0x1a3/0x440
>> [  343.142829]  [<ffffffff810ffebb>] ? lock_is_held+0x8b/0xb0
>> [  343.154346]  [<ffffffff81a035c0>] ip_rcv_finish+0x150/0x660
>> [  343.165748]  [<ffffffff81a0406b>] ip_rcv+0x22b/0x370
>> [  343.176838]  [<ffffffff81a60972>] ? packet_rcv_spkt+0x42/0x190
>> [  343.187659]  [<ffffffff819609d2>] __netif_receive_skb_core+0x6d2/0x8a0
>> [  343.198209]  [<ffffffff81960414>] ? __netif_receive_skb_core+0x114/0x8a0
>> [  343.208819]  [<ffffffff81009010>] ? xen_clocksource_read+0x20/0x30
>> [  343.219471]  [<ffffffff81116e49>] ? getnstimeofday+0x9/0x30
>> [  343.229862]  [<ffffffff81960bbc>] __netif_receive_skb+0x1c/0x70
>> [  343.239953]  [<ffffffff81960c2e>] netif_receive_skb_internal+0x1e/0xf0
>> [  343.249908]  [<ffffffff81962110>] napi_gro_receive+0x70/0xa0
>> [  343.259509]  [<ffffffff817198a3>] rtl8169_poll+0x2d3/0x680
>> [  343.268982]  [<ffffffff81adcd2b>] ? _raw_spin_unlock_irq+0x2b/0x50
>> [  343.278091]  [<ffffffff819610d1>] net_rx_action+0x161/0x260
>> [  343.287056]  [<ffffffff810c28ec>] __do_softirq+0x12c/0x280
>> [  343.295756]  [<ffffffff810c2da2>] irq_exit+0xa2/0xd0
>> [  343.304235]  [<ffffffff814ffd5f>] xen_evtchn_do_upcall+0x2f/0x40
>> [  343.312387]  [<ffffffff81adf15e>] xen_do_hypervisor_callback+0x1e/0x30
>> [  343.320389]  <EOI>  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
>> [  343.328171]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
>> [  343.335738]  [<ffffffff81008c70>] ? xen_safe_halt+0x10/0x20
>> [  343.343142]  [<ffffffff81018748>] ? default_idle+0x18/0x20
>> [  343.350202]  [<ffffffff81018f5e>] ? arch_cpu_idle+0x2e/0x40
>> [  343.356994]  [<ffffffff8110b551>] ? cpu_startup_entry+0x91/0x1e0
>> [  343.363658]  [<ffffffff81ac7d87>] ? rest_init+0xb7/0xc0
>> [  343.369924]  [<ffffffff81ac7cd0>] ? csum_partial_copy_generic+0x170/0x170
>> [  343.376057]  [<ffffffff8230ff1c>] ? start_kernel+0x409/0x416
>> [  343.381972]  [<ffffffff8230f912>] ? repair_env_string+0x5e/0x5e
>> [  343.387573]  [<ffffffff8230f5f8>] ? x86_64_start_reservations+0x2a/0x2c
>> [  343.393152]  [<ffffffff82312e28>] ? xen_start_kernel+0x586/0x588
>> [  343.398628] ---[ end trace 8379b598fb7ef5ee ]---
>>
>>
>>
>>
>>
>> Thursday, February 6, 2014, 12:36:31 PM, you wrote:
>>
>>> Hi Dan / Francois,
>>
>>> Didn't have time to test it before, but the patch doesn't seem to help.
>>> I'm still getting the "DMA-API: exceeded 7 overlapping mappings of pfn 55ebe",
>>> but i see now i forgot to mention i use r8169.use_dac=1 ...
>>
>>> Not using it seems to prevent the warning, but before 3.14 i have never seen this (with r8169.use_dac=1)

> If you are still hitting this with the patch:

>   59f2e7df574c dma-debug: fix overlap detection

> ...then I'm more inclined to think it is an actual positive report.

> If you don't mind I'll send some debug patches to narrow this down.

Please do .. sounds better than bisecting :-)
