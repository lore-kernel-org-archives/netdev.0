From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: ipv6: oops in datagram.c line 260
Date: Tue, 06 Jan 2015 17:01:13 +0100
Message-ID: <1420560073.32369.60.camel@redhat.com>
References: <5487DD65.60800@gtsys.com.hk> <549AC2B4.8070203@gtsys.com.hk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	steffen.klassert@secunet.com
To: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58186 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755535AbbAFQBg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 11:01:36 -0500
In-Reply-To: <549AC2B4.8070203@gtsys.com.hk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-12-24 at 21:42 +0800, Chris Ruehl wrote:
> [447604.244357] ipv6_pinfo is NULL
> [447604.273733] ------------[ cut here ]------------
> [447604.303628] WARNING: CPU: 7 PID: 0 at net/ipv6/datagram.c:262 
> ipv6_local_error+0x16b/0x1a0()
> [[...]]
> [last unloaded: ipmi_si]
> [447605.087999] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 3.14.27 #11
> [447605.139687] Hardware name: Dell Inc. PowerEdge R420/0CN7CM, BIOS 2.3.3 
> 07/10/2014
> [447605.242931]  0000000000000009 ffff8806172e3b48 ffffffff815ffd58 0000000000000000
> [447605.349130]  ffff8806172e3b80 ffffffff81043c23 ffff8800a16322e8 ffff880037daa1c0
> [447605.459659]  ffff88000b026800 0000000000000000 ffff880037daa4b8 ffff8806172e3b90
> [447605.576385] Call Trace:
> [447605.634243]  <IRQ>  [<ffffffff815ffd58>] dump_stack+0x45/0x56
> [447605.692870]  [<ffffffff81043c23>] warn_slowpath_common+0x73/0x90
> [447605.751097]  [<ffffffff81043cf5>] warn_slowpath_null+0x15/0x20
> [447605.808000]  [<ffffffff815da6db>] ipv6_local_error+0x16b/0x1a0
> [447605.863821]  [<ffffffff815e29d0>] xfrm6_local_error+0x60/0x90
> [447605.918493]  [<ffffffff8150b485>] ? skb_dequeue+0x15/0x70
> [447605.971871]  [<ffffffff815a6cc1>] xfrm_local_error+0x51/0x70
> [447606.024218]  [<ffffffff8159ca15>] xfrm4_extract_output+0x75/0xb0
> [447606.075630]  [<ffffffff815a6c5a>] xfrm_inner_extract_output+0x6a/0x80
> [447606.126055]  [<ffffffff815e27a2>] xfrm6_prepare_output+0x12/0x60
> [447606.175310]  [<ffffffff815a6ed0>] xfrm_output_resume+0x1f0/0x370
> [447606.223406]  [<ffffffff8151a486>] ? skb_checksum_help+0x76/0x190
> [447606.270572]  [<ffffffff815a709b>] xfrm_output+0x3b/0xf0
> [447606.316454]  [<ffffffff815e2ae0>] ? xfrm6_extract_output+0xe0/0xe0
> [447606.361803]  [<ffffffff815e2af7>] xfrm6_output_finish+0x17/0x20
> [447606.406053]  [<ffffffff8159cad6>] xfrm4_output+0x46/0x80
> [447606.448694]  [<ffffffff81550a80>] ip_local_out+0x20/0x30
> [447606.489952]  [<ffffffff81550dd5>] ip_queue_xmit+0x135/0x3c0
> [447606.530017]  [<ffffffff815672e1>] tcp_transmit_skb+0x461/0x8c0
> [447606.569362]  [<ffffffff8156786e>] tcp_write_xmit+0x12e/0xb20
> [447606.607876]  [<ffffffff815669ff>] ? tcp_current_mss+0x4f/0x70
> [447606.645723]  [<ffffffff8156b320>] ? tcp_write_timer_handler+0x1b0/0x1b0
> [447606.682837]  [<ffffffff81569487>] tcp_send_loss_probe+0x37/0x1f0
> [447606.719000]  [<ffffffff8156b320>] ? tcp_write_timer_handler+0x1b0/0x1b0
> [447606.754537]  [<ffffffff8156b1bb>] tcp_write_timer_handler+0x4b/0x1b0
> [447606.789266]  [<ffffffff8156b320>] ? tcp_write_timer_handler+0x1b0/0x1b0
> [447606.823242]  [<ffffffff8156b378>] tcp_write_timer+0x58/0x60
> [447606.856047]  [<ffffffff8104e848>] call_timer_fn.isra.32+0x18/0x80
> [447606.888029]  [<ffffffff8104ea1a>] run_timer_softirq+0x16a/0x200
> [447606.920224]  [<ffffffff81047efc>] __do_softirq+0xec/0x250
> [447606.951850]  [<ffffffff810482f5>] irq_exit+0xf5/0x100
> [447606.982665]  [<ffffffff8102bc6f>] smp_apic_timer_interrupt+0x3f/0x50
> [447607.014382]  [<ffffffff8160d98a>] apic_timer_interrupt+0x6a/0x70
> [447607.046175]  <EOI>  [<ffffffff8104f336>] ? get_next_timer_interrupt+0x1d6/0x250
> [447607.111311]  [<ffffffff814d45a7>] ? cpuidle_enter_state+0x47/0xc0
> [447607.145850]  [<ffffffff814d45a3>] ? cpuidle_enter_state+0x43/0xc0
> [447607.179625]  [<ffffffff814d46b6>] cpuidle_idle_call+0x96/0x130
> [447607.213531]  [<ffffffff8100b909>] arch_cpu_idle+0x9/0x20
> [447607.247052]  [<ffffffff810925ba>] cpu_startup_entry+0xda/0x1d0
> [447607.280775]  [<ffffffff81029d22>] start_secondary+0x212/0x2c0
> [447607.314555] ---[ end trace 6ff3826b6e4fdf67 ]---
> 

Thanks for the report!

xfrm6_output_finish unconditionally resets skb->protocol so we try to
dispatch to the IPv6 handler, even though tcp just sends an IPv4 packet.

Hairy, I have a look.

Bye,
Hannes
