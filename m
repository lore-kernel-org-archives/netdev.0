From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: igb_poll - device driver failed to check map error
Date: Wed, 13 Mar 2013 15:30:51 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6264EEA42D3@ORSMSX102.amr.corp.intel.com>
References: <7974689.msj0QTRKPV@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "christoph.paasch@uclouvain.be" <christoph.paasch@uclouvain.be>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38890 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932391Ab3CMPbD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 11:31:03 -0400
In-Reply-To: <7974689.msj0QTRKPV@cpaasch-mac>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Christoph Paasch
> Sent: Tuesday, March 12, 2013 2:31 AM
> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Duyck, Alexander H;
> Eric Dumazet
> Cc: netdev@vger.kernel.org
> Subject: igb_poll - device driver failed to check map error
> 
> Hello,
> 
> I'm seeing a warning while booting my machine when DMA_API_DEBUG is set:
> 
> [   36.402824] ------------[ cut here ]------------
> [   36.458070] WARNING: at /home/cpaasch/builder/net-next/lib/dma-
> debug.c:934
> check_unmap+0x648/0x702()
> [   36.567377] Hardware name: ProLiant DL165 G7
> [   36.618452] igb 0000:04:00.0: DMA-API: device driver failed to check map
> error[device address=0x0000000233d9b232] [size=154 bytes] [mapped as
> single]
> [   36.776640] Modules linked in:
> [   36.815446] Pid: 0, comm: swapper/7 Not tainted 3.9.0-rc1-mptcp+ #101
> [   36.892515] Call Trace:
> [   36.921745]  <IRQ>  [<ffffffff8102ad7f>] warn_slowpath_common+0x80/0x9a
> [   37.001023]  [<ffffffff8102ae2d>] warn_slowpath_fmt+0x41/0x43
> [   37.069771]  [<ffffffff811db17f>] check_unmap+0x648/0x702
> [   37.134363]  [<ffffffff811db3e9>] debug_dma_unmap_page+0x50/0x52
> [   37.206234]  [<ffffffff8136676a>] igb_poll+0x144/0xf7c
> [   37.267706]  [<ffffffff8104dd19>] ? sched_clock_cpu+0x46/0xd1
> [   37.336456]  [<ffffffff814458ce>] net_rx_action+0xa7/0x1d0
> [   37.402085]  [<ffffffff81030b65>] __do_softirq+0xb4/0x16f
> [   37.466673]  [<ffffffff81030c90>] irq_exit+0x40/0x87
> [   37.526067]  [<ffffffff81002db1>] do_IRQ+0x98/0xaf
> [   37.583378]  [<ffffffff815210aa>] common_interrupt+0x6a/0x6a
> [   37.651086]  <EOI>  [<ffffffff8105d4be>] ?
> __tick_nohz_idle_enter+0x116/0x31f
> [   37.736595]  [<ffffffff81008a04>] ? default_idle+0x24/0x39
> [   37.802224]  [<ffffffff81008c62>] cpu_idle+0x68/0xa4
> [   37.861616]  [<ffffffff81519f78>] start_secondary+0x1a9/0x1ad
> [   37.930364] ---[ end trace 01b5bb0fd75a464c ]---
> 
> 
> It happens shortly after mounting the NFS-root filesystem.
> 
> I tried to understand what is going on, but I am now at my wit's end.
> 
> By adding some print-statements, here is what I found out (not sure if this is
> anyhow helpful):
> 
> The difference between tx_buffer->time_stamp and the current 'jiffies' is up to
> 2000 jiffies (HZ==1000) at the first time the above warning happens (this seems
> too much for me). From then on, I see my print 3-4 times appear but without
> such a big difference between the timestamps (difference around 1 and
> 2 jiffies).
> 
> Some other stuff, I printed:
> tx_buffer->skb: ffff880235054c80
> tx_buffer->bytecount: 154
> tx_buffer->gso_segs: 1
> tx_buffer->protocol: 8
> tx_buffer->tx_flags 0x20
> 
> 
> One last thing:
> Am I right that after each call to dma_map_single/page a call to
> dma_mapping_error is needed? If that's the case, I have some patches that add
> this statement at missing places in the e1000, e1000e and ixgb driver. But these
> patches do not fix my above problem.
> 
> 
> Thanks for your help,
> Christoph
> 
> --
> IP Networking Lab --- http://inl.info.ucl.ac.be MultiPath TCP in the Linux Kernel -
> -- http://multipath-tcp.org UCLouvain
> --
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a
> message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

Thanks Christoph,

We'll take a look at this also.

Carolyn


Carolyn Wyborny 
Linux Development 
Networking Division 
Intel Corporation 
