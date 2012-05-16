From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Subject: e1000: dma_map_area overflow
Date: Wed, 16 May 2012 16:44:03 +0200
Message-ID: <jp0efj$brt$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59915 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752301Ab2EPOpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2012 10:45:04 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1SUfTL-00067U-Mq
	for netdev@vger.kernel.org; Wed, 16 May 2012 16:45:03 +0200
Received: from tc-gate1.pci.uni-heidelberg.de ([129.206.21.241])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 16 May 2012 16:45:03 +0200
Received: from bernd.schubert by tc-gate1.pci.uni-heidelberg.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 16 May 2012 16:45:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm getting kernel panics from the e1000 driver here. Is this a known issue?

> fslab1 login: [89848.228249] Kernel panic - not syncing: dma_map_area overflow 66 bytes
> [89848.228251]
> [89848.236378] Pid: 14293, comm: fhgfs-storage/S Not tainted 3.3.6-debug #19
> [89848.243217] Call Trace:
> [89848.245703]  <IRQ>  [<ffffffff813fc3ed>] panic+0xbd/0x1df
> [89848.251169]  [<ffffffff810433e6>] ? alloc_iommu+0xd6/0x160
> [89848.256703]  [<ffffffff8104360b>] dma_map_area+0x12b/0x130
> [89848.262237]  [<ffffffff81043ce3>] gart_map_page+0x93/0xb0
> [89848.267682]  [<ffffffff810956ef>] ? local_clock+0x6f/0x80
> [89848.273137]  [<ffffffffa00e564d>] e1000_tx_map+0x1bd/0x640 [e1000]
> [89848.279377]  [<ffffffff81043c50>] ? dma_map_sg_nonforce+0x190/0x190
> [89848.285694]  [<ffffffff813750a8>] ? sch_direct_xmit+0x38/0x2a0
> [89848.291584]  [<ffffffffa00e5c75>] e1000_xmit_frame+0x1a5/0x5d0 [e1000]
> [89848.298159]  [<ffffffff81357a60>] dev_hard_start_xmit+0x2b0/0x650
> [89848.304320]  [<ffffffff8137516e>] sch_direct_xmit+0xfe/0x2a0
> [89848.310038]  [<ffffffff81358205>] dev_queue_xmit+0x165/0x6d0
> [89848.315757]  [<ffffffff813580cf>] ? dev_queue_xmit+0x2f/0x6d0
> [89848.321557]  [<ffffffff813896c6>] ip_finish_output2+0x166/0x430
> [89848.327527]  [<ffffffff813895f7>] ? ip_finish_output2+0x97/0x430
> [89848.333586]  [<ffffffff8138af00>] ip_finish_output+0x60/0xf0
> [89848.339438]  [<ffffffff8138afef>] ip_output+0x5f/0xd0
> [89848.344536]  [<ffffffff813899bd>] ip_local_out+0x2d/0x90
> [89848.349899]  [<ffffffff8138a1df>] ip_queue_xmit+0x1bf/0x580
> [89848.355524]  [<ffffffff8138a05d>] ? ip_queue_xmit+0x3d/0x580
> [89848.361231]  [<ffffffff810a73c7>] ? getnstimeofday+0x57/0xe0
> [89848.366940]  [<ffffffff813a2d77>] tcp_transmit_skb+0x3f7/0x770
> [89848.372816]  [<ffffffff813a52c0>] ? tcp_init_xmit_timers+0x30/0x30
> [89848.379047]  [<ffffffff813a32ad>] tcp_send_ack+0xdd/0x130
> [89848.384495]  [<ffffffff813a544e>] tcp_delack_timer+0x18e/0x250
> [89848.390374]  [<ffffffff8106739f>] call_timer_fn+0x9f/0x250
> [89848.395909]  [<ffffffff81067300>] ? del_timer+0x140/0x140



Thanks,
Bernd
