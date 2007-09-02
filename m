From: slavon@bigtelecom.ru
Subject: [BUG] spinlock lockup on kernel 2.6.23-rc4
Date: Sun, 02 Sep 2007 22:52:39 +0400
Message-ID: <20070902225239.um97qcymuc04cskc@mail.himki.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=windows-1251;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:39391 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbXIBSwm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 14:52:42 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 17751A6C0D3
	for <netdev@vger.kernel.org>; Sun,  2 Sep 2007 22:52:41 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1IKitv5-uHhb for <netdev@vger.kernel.org>;
	Sun,  2 Sep 2007 22:52:39 +0400 (MSD)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Spinlock debug on in kernel. This all that say NETCONSOLE

Maybe some more info you needed?

Thanks.

[123345.401901] BUG: spinlock lockup on CPU#1, swapper/0, f7f6a200
[123345.402104]  [<c01cc7b1>] _raw_spin_lock+0xbb/0xdc
[123345.402180]  [<c0299619>] est_timer+0x21/0x11c
[123345.402254]  [<c02995f8>] est_timer+0x0/0x11c
[123345.402324]  [<c0125893>] run_timer_softirq+0xfa/0x15d
[123345.402399]  [<c01225e2>] __do_softirq+0x5d/0xc1
[123345.402474]  [<c0122678>] do_softirq+0x32/0x36
[123345.402543]  [<c0111619>] smp_apic_timer_interrupt+0x74/0x80
[123345.402625]  [<c01033a8>] apic_timer_interrupt+0x28/0x30
[123345.402697]  [<c01100d8>] smp_store_cpu_info+0x23/0xb7
[123345.402772]  [<c0100d61>] mwait_idle_with_hints+0x3b/0x3f
[123345.402848]  [<c0100d65>] mwait_idle+0x0/0xa
[123345.402921]  [<c0100ea4>] cpu_idle+0x91/0xaa
[123345.402996]  =======================
[123345.605427] BUG: spinlock lockup on CPU#0, swapper/0, f7f6a200
[123345.605496]  [<c01cc7b1>] _raw_spin_lock+0xbb/0xdc
[123345.605568]  [<c029cf8e>] dev_queue_xmit+0x158/0x2a6
[123345.605645]  [<c02b94e3>] ip_output+0x281/0x2ba
[123345.605726]  [<c02b679c>] dst_output+0x0/0x7
[123345.605798]  [<c02b6b45>] ip_push_pending_frames+0x2f2/0x3b6
[123345.605875]  [<c02b679c>] dst_output+0x0/0x7
[123345.605946]  [<c02d3ff1>] icmp_send+0x30d/0x383
[123345.606019]  [<c02ec46b>] _read_unlock_bh+0x5/0xd
[123345.606090]  [<f881c5db>] ipt_do_table+0x41f/0x47c [ip_tables]
[123345.606171]  [<c02b1cd5>] ip_route_input+0x3a/0xad9
[123345.606249]  [<c02b59f9>] ip_forward+0x2af/0x2c6
[123345.606318]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[123345.606388]  [<c02b4729>] ip_rcv+0x484/0x4bd
[123345.606459]  [<c029ab9c>] netif_receive_skb+0x2cd/0x340
[123345.606532]  [<c0234ef1>] e1000_clean_rx_irq+0x379/0x448
[123345.606611]  [<c0234b78>] e1000_clean_rx_irq+0x0/0x448
[123345.606684]  [<c0233f8f>] e1000_clean+0x7a/0x249
[123345.606755]  [<c029ccad>] net_rx_action+0x91/0x17f
[123345.606825]  [<c01225e2>] __do_softirq+0x5d/0xc1
[123345.606896]  [<c0122678>] do_softirq+0x32/0x36
[123345.607077]  [<c010488a>] do_IRQ+0x7e/0x90
[123345.607150]  [<c0111619>] smp_apic_timer_interrupt+0x74/0x80
[123345.607223]  [<c02ea9d5>] __sched_text_start+0x54d/0x5ba
[123345.607301]  [<c01032eb>] common_interrupt+0x23/0x28
[123345.607371]  [<c0100d61>] mwait_idle_with_hints+0x3b/0x3f
[123345.607441]  [<c0100d65>] mwait_idle+0x0/0xa
[123345.607511]  [<c0100ea4>] cpu_idle+0x91/0xaa
[123345.607581]  [<c04098c8>] start_kernel+0x2d5/0x2dd
[123345.608946]  [<c04090e0>] unknown_bootoption+0x0/0x195
[123345.609017]  =======================


----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

