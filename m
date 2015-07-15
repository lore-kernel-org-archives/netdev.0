From: Jordi Clariana <jclariana@trovit.com>
Subject: page allocation failure. order:2, mode:0x204020 with tg3 driver
Date: Wed, 15 Jul 2015 16:48:44 +0200
Message-ID: <CAPi8NDn5Mq57_+jkYRWoZRchW5NDguAatRTAHO0x2Yu271U=Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36509 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbbGOOs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 10:48:59 -0400
Received: by qkdv3 with SMTP id v3so29650312qkd.3
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 07:48:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have the same problem described here:
http://www.spinics.net/lists/netdev/msg295266.html
but with the tg3 driver. Anyone know if this can be or is fixed? I'm
using Debian 7 and kernel 3.16.7-ckt11-1~bpo70+1 from backports. I'm
using jumbo frames too, and haven't tried to disable it because the
server is in production environment.

Here it is the relevant log fragment:

Jul 15 15:49:22 XXXXXX kernel: [767403.170053] warn_alloc_failed: 20
callbacks suppressed
Jul 15 15:49:22 XXXXXX kernel: [767403.170059] java: page allocation
failure: order:2, mode:0x204020
Jul 15 15:49:22 XXXXXX kernel: [767403.170063] CPU: 20 PID: 146117
Comm: java Not tainted 3.16.0-0.bpo.4-amd64 #1 Debian
3.16.7-ckt11-1~bpo70+1
Jul 15 15:49:22 XXXXXX kernel: [767403.170065] Hardware name: Dell
Inc. PowerEdge R630/0CNCJW, BIOS 1.2.10 03/09/2015
Jul 15 15:49:22 XXXXXX kernel: [767403.170068]  0000000000000000
0000000000000002 ffffffff815458b4 0000000000204020
Jul 15 15:49:22 XXXXXX kernel: [767403.170073]  ffffffff811530cd
0000000000000002 ffff88047fffcc00 0000000000000002
Jul 15 15:49:22 XXXXXX kernel: [767403.170076]  ffffffff818e2410
0000000100000002 ffff88047fffcc08 0000000000000000
Jul 15 15:49:22 XXXXXX kernel: [767403.170080] Call Trace:
Jul 15 15:49:22 XXXXXX kernel: [767403.170082]  <IRQ>
[<ffffffff815458b4>] ? dump_stack+0x41/0x51
Jul 15 15:49:22 XXXXXX kernel: [767403.170099]  [<ffffffff811530cd>] ?
warn_alloc_failed+0xfd/0x160
Jul 15 15:49:22 XXXXXX kernel: [767403.170102]  [<ffffffff8115771f>] ?
__alloc_pages_nodemask+0x91f/0xbb0
Jul 15 15:49:22 XXXXXX kernel: [767403.170109]  [<ffffffff811a17c0>] ?
kmem_getpages+0x60/0x110
Jul 15 15:49:22 XXXXXX kernel: [767403.170112]  [<ffffffff811a3008>] ?
fallback_alloc+0x158/0x220
Jul 15 15:49:22 XXXXXX kernel: [767403.170115]  [<ffffffff811a3334>] ?
__kmalloc+0x1b4/0x200
Jul 15 15:49:22 XXXXXX kernel: [767403.170182]  [<ffffffffa019c9d2>] ?
tg3_alloc_rx_data+0x112/0x270 [tg3]
Jul 15 15:49:22 XXXXXX kernel: [767403.170189]  [<ffffffffa019c9d2>] ?
tg3_alloc_rx_data+0x112/0x270 [tg3]
Jul 15 15:49:22 XXXXXX kernel: [767403.170197]  [<ffffffffa019d2c3>] ?
tg3_poll_work+0x603/0xec0 [tg3]
Jul 15 15:49:22 XXXXXX kernel: [767403.170202]  [<ffffffff8144d82f>] ?
netif_receive_skb_internal+0x1f/0x90
Jul 15 15:49:22 XXXXXX kernel: [767403.170209]  [<ffffffffa019dbc6>] ?
tg3_poll_msix+0x46/0x160 [tg3]
Jul 15 15:49:22 XXXXXX kernel: [767403.170212]  [<ffffffff8144e891>] ?
net_rx_action+0x121/0x230
Jul 15 15:49:22 XXXXXX kernel: [767403.170217]  [<ffffffff813b92b1>] ?
add_interrupt_randomness+0x51/0x200
Jul 15 15:49:22 XXXXXX kernel: [767403.170221]  [<ffffffff81072cce>] ?
__do_softirq+0xde/0x2e0
Jul 15 15:49:22 XXXXXX kernel: [767403.170224]  [<ffffffff81073126>] ?
irq_exit+0x86/0xb0
Jul 15 15:49:22 XXXXXX kernel: [767403.170228]  [<ffffffff8154ec56>] ?
do_IRQ+0x66/0x110
Jul 15 15:49:22 XXXXXX kernel: [767403.170233]  [<ffffffff8154caed>] ?
common_interrupt+0x6d/0x6d
Jul 15 15:49:22 XXXXXX kernel: [767403.170234]  <EOI> Mem-Info:
Jul 15 15:49:22 XXXXXX kernel: [767403.170239] Node 0 DMA per-cpu:
Jul 15 15:49:22 XXXXXX kernel: [767403.170242] CPU    0: hi:    0,
btch:   1 usd:   0
[...]

Thanks!
