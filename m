From: Yinghai Lu <yhlu.kernel@gmail.com>
Subject: ipoib crash when booting with ipautoconfig
Date: Mon, 25 Jul 2011 14:39:00 -0700
Message-ID: <CAE9FiQXAzUGu4JD5ZUwi1ZYsVY7fAWy-SsGnrz5spNuHeahOkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: David Miller <davem@davemloft.net>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36628 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661Ab1GYVjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 17:39:01 -0400
Received: by vxh35 with SMTP id 35so3194645vxh.19
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2011 14:39:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[   88.946112] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000040
[   88.954153] IP: [<ffffffff81a61ee1>] ipoib_start_xmit+0x5c/0x31a
[   88.960196] PGD 0
[   88.962235] Oops: 0000 [#1] SMP
[   88.965500] CPU 0
[   88.967343] Modules linked in:
[   88.970601]
[   88.972094] Pid: 1, comm: swapper Not tainted
3.0.0-tip-yh-04912-gf572f66-dirty #1148
[   88.984053] RIP: 0010:[<ffffffff81a61ee1>]  [<ffffffff81a61ee1>]
ipoib_start_xmit+0x5c/0x31a
[   88.992497] RSP: 0018:ffff88046dd37cb0  EFLAGS: 00010246
[   88.997805] RAX: 0000000000000000 RBX: ffff88045a5af380 RCX: 0000000060014c20
[   89.004933] RDX: 0000000000000000 RSI: ffff880464768000 RDI: ffff88045a5af380
[   89.012060] RBP: ffff88046dd37cf0 R08: 0000000000001d1c R09: 000000000039e295
[   89.019188] R10: 0000000000000000 R11: ffff88046dd38708 R12: ffff880464768000
[   89.026317] R13: 0000000000000000 R14: ffff8804647689c0 R15: ffff880464768000
[   89.033447] FS:  0000000000000000(0000) GS:ffff88047de00000(0000)
knlGS:0000000000000000
[   89.041524] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   89.047268] CR2: 0000000000000040 CR3: 00000000023fc000 CR4: 00000000000406f0
[   89.054394] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   89.061523] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   89.068652] Process swapper (pid: 1, threadinfo ffff88046dd36000,
task ffff88046dd38000)
[   89.076729] Stack:
[   89.078741]  0000000000000000 ffff88046dd38000 0000000000000246
ffff88045a5af380
[   89.086189]  0000000060014c23 0000000000000000 0000000000000258
ffff880464768000
[   89.093645]  ffff88046dd37d50 ffffffff81b15a31 ffff880670687e98
ffff880670687e80
[   89.101093] Call Trace:
[   89.103549]  [<ffffffff81b15a31>] dev_hard_start_xmit+0x2a7/0x435
[   89.109658]  [<ffffffff81b2984d>] sch_direct_xmit+0x74/0x207
[   89.115317]  [<ffffffff81b15db9>] dev_queue_xmit+0x1fa/0x4aa
[   89.120981]  [<ffffffff81b15bbf>] ? dev_hard_start_xmit+0x435/0x435
[   89.127267]  [<ffffffff81b0abd2>] ? __alloc_skb+0x83/0x141
[   89.132774]  [<ffffffff82754586>] ic_bootp_send_if+0x2b4/0x2d2
[   89.138597]  [<ffffffff82754709>] ic_dynamic+0x165/0x315
[   89.143913]  [<ffffffff8275508e>] ip_auto_config+0xf2/0x2c0
[   89.149484]  [<ffffffff82754f9c>] ? root_nfs_parse_addr+0xb5/0xb5
[   89.155604]  [<ffffffff810002cf>] do_one_initcall+0x57/0x134
[   89.161278]  [<ffffffff82708f85>] kernel_init+0x11f/0x1a3
[   89.166699]  [<ffffffff81c471d4>] kernel_thread_helper+0x4/0x10
[   89.172640]  [<ffffffff81c3e61d>] ? retint_restore_args+0xe/0xe
[   89.178550]  [<ffffffff82708e66>] ? start_kernel+0x3c9/0x3c9
[   89.184212]  [<ffffffff81c471d0>] ? gs_change+0xb/0xb
[   89.189261] Code: 1d 48 c7 c7 60 11 42 82 e8 e0 d7 64 ff 85 c0 75
0d e8 91 5e 63 ff 85 c0 0f 84 89 02 00 00 48 8b 43 58 48 89 c2 48 83
e2 fe a8 01 <4c> 8b 7a 40 74 26 e8 3c 5e 63 ff 85 c0 74 1d 48 c7 c7 60
11 42
[   89.209206] RIP  [<ffffffff81a61ee1>] ipoib_start_xmit+0x5c/0x31a
[   89.215311]  RSP <ffff88046dd37cb0>
[   89.218792] CR2: 0000000000000040
[   89.222287] ---[ end trace 88d8b543880f18a5 ]---
