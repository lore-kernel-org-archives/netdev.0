From: Chris Wedgwood <cw@f00f.org>
Subject: 2.6.25-rc3ish TCP assertion & WARN_ON
Date: Sat, 1 Mar 2008 10:32:34 -0800
Message-ID: <20080301183234.GA4707@puku.stupidest.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?unknown-8bit?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp124.sbc.mail.sp1.yahoo.com ([69.147.64.97]:35191 "HELO
	smtp124.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751408AbYCASjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 13:39:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running a near-mainline kernel (v2.6.25-rc3-1123-g066241f with some
local kvm changes).


I've seen this a few times since upgrading psat 2.6.24rc3 (where I
never saw it) but declined to report it initially thinking it might be
the result of a kvm problem.

With the latest crash that seems a less likely, it was several hours
since using kvm whilst the machine was under light network load.

    [114135.072844] KERNEL: assertion (packets <= tp->packets_out) failed at net/ipv4/tcp_input.c (2139)
[ ... repeated another 22 times in rapid succession ... ]
    [114135.115359] KERNEL: assertion (packets <= tp->packets_out) failed at net/ipv4/tcp_input.c (2139)
    [114135.115984] ------------[ cut here ]------------
    [114135.116001] WARNING: at net/ipv4/tcp_input.c:2506 tcp_ack+0xe72/0x1bae()
    [114135.116031] Modules linked in: kvm_amd kvm loop tun firewire_ohci firewire_core crc_itu_t [last unloaded: kvm]
    [114135.116073] Pid: 0, comm: swapper Not tainted 2.6.25-rc3-cw3 #6
    [114135.116091] 
    [114135.116092] Call Trace:
    [114135.116116]  <IRQ>  [<ffffffff80231aeb>] warn_on_slowpath+0x58/0x6b
    [114135.116142]  [<ffffffff8053c4fb>] ? _spin_unlock_bh+0x2f/0x34
    [114135.116165]  [<ffffffff804fb479>] ? bictcp_cong_avoid+0x33/0x258
    [114135.116184]  [<ffffffff804c8dc3>] tcp_ack+0xe72/0x1bae
    [114135.116203]  [<ffffffff804ccb53>] tcp_rcv_established+0x661/0x786
    [114135.116223]  [<ffffffff804d21ca>] tcp_v4_do_rcv+0x31/0x1ba
    [114135.116241]  [<ffffffff804d3f4d>] tcp_v4_rcv+0x701/0x760
    [114135.116260]  [<ffffffff804b9684>] ip_local_deliver_finish+0x158/0x230
    [114135.116279]  [<ffffffff804b9b6d>] ip_local_deliver+0x72/0x7d
    [114135.116297]  [<ffffffff804b9507>] ip_rcv_finish+0x353/0x378
    [114135.116315]  [<ffffffff804b9ac8>] ip_rcv+0x272/0x2a5
    [114135.116334]  [<ffffffff80492f57>] netif_receive_skb+0x26c/0x2b9
    [114135.116354]  [<ffffffff8049575c>] process_backlog+0x82/0xe7
    [114135.116373]  [<ffffffff80495207>] net_rx_action+0x87/0x14e
    [114135.116392]  [<ffffffff80236d07>] __do_softirq+0x66/0xd3
    [114135.116412]  [<ffffffff8020c45c>] call_softirq+0x1c/0x28
    [114135.116430]  [<ffffffff8020dd03>] do_softirq+0x34/0x72
    [114135.116448]  [<ffffffff80236c9f>] irq_exit+0x3f/0x41
    [114135.116465]  [<ffffffff8020deb2>] do_IRQ+0x147/0x169
    [114135.116483]  [<ffffffff8020a225>] ? default_idle+0x0/0x5f
    [114135.116501]  [<ffffffff8020b7a1>] ret_from_intr+0x0/0xa
    [114135.116517]  <EOI>  [<ffffffff8053ed05>] ? __atomic_notifier_call_chain+0x0/0x83
    [114135.116549]  [<ffffffff8020a25e>] ? default_idle+0x39/0x5f
    [114135.116567]  [<ffffffff8020a259>] ? default_idle+0x34/0x5f
    [114135.116585]  [<ffffffff8020a225>] ? default_idle+0x0/0x5f
    [114135.116603]  [<ffffffff8020a31c>] ? cpu_idle+0x98/0xba
    [114135.116622]  [<ffffffff805271e1>] ? rest_init+0x55/0x57
    [114135.116640] 
    [114135.116652] ---[ end trace 9a974c67cd254493 ]---
