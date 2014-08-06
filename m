From: Andrey Wagin <avagin@gmail.com>
Subject: linux-next: net/netlink/diag.c:106 suspicious rcu_dereference_protected()
 usage!
Date: Wed, 6 Aug 2014 21:29:36 +0400
Message-ID: <CANaxB-ySsRXHPSEPOuExeKAvDX7esZ1WBZAVMTWQxtmfN2=i4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:51116 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799AbaHFR3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 13:29:36 -0400
Received: by mail-vc0-f180.google.com with SMTP id ij19so4423336vcb.25
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 10:29:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[   40.072199] ===============================
[   40.072350] [ INFO: suspicious RCU usage. ]
[   40.072501] 3.16.0-next-20140806 #1 Not tainted
[   40.072659] -------------------------------
[   40.072807] net/netlink/diag.c:106 suspicious
rcu_dereference_protected() usage!
[   40.073047]
other info that might help us debug this:

[   40.073276]
rcu_scheduler_active = 1, debug_locks = 0
[   40.073494] 4 locks held by criu/2838:
[   40.073635]  #0:  (sock_diag_mutex){+.+.+.}, at:
[<ffffffff81689afb>] sock_diag_rcv+0x1b/0x40
[   40.074226]  #1:  (sock_diag_table_mutex){+.+.+.}, at:
[<ffffffff81689c6d>] sock_diag_rcv_msg+0x6d/0x140
[   40.074803]  #2:  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff816a28f1>]
netlink_dump+0x21/0x2d0
[   40.075382]  #3:  (nl_table_lock){.+.?..}, at: [<ffffffffa0286601>]
netlink_diag_dump+0x31/0xb0 [netlink_diag]
[   40.076351]
stack backtrace:
[   40.076862] CPU: 0 PID: 2838 Comm: criu Not tainted 3.16.0-next-20140806 #1
[   40.077276] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   40.077645]  0000000000000000 000000007979a988 ffff88003a213990
ffffffff817a9c04
[   40.078548]  ffff88003a2e4800 ffff88003a2139c0 ffffffff810ecc47
0000000000000000
[   40.079419]  ffff88003fb324e8 0000000000000ec0 0000000000000000
ffff88003a213a30
[   40.080258] Call Trace:
[   40.080559]  [<ffffffff817a9c04>] dump_stack+0x4d/0x66
[   40.080918]  [<ffffffff810ecc47>] lockdep_rcu_suspicious+0xe7/0x120
[   40.081313]  [<ffffffffa0286585>] __netlink_diag_dump+0x265/0x2b0
[netlink_diag]
[   40.081899]  [<ffffffffa0286667>] netlink_diag_dump+0x97/0xb0 [netlink_diag]
[   40.082360]  [<ffffffff816a29e7>] netlink_dump+0x117/0x2d0
[   40.082822]  [<ffffffff816a366b>] __netlink_dump_start+0x1ab/0x220
[   40.083346]  [<ffffffffa028607c>]
netlink_diag_handler_dump+0x7c/0xa0 [netlink_diag]
[   40.083935]  [<ffffffffa02865d0>] ? __netlink_diag_dump+0x2b0/0x2b0
[netlink_diag]
[   40.084547]  [<ffffffff81689c87>] sock_diag_rcv_msg+0x87/0x140
[   40.084914]  [<ffffffff81689c00>] ? sock_diag_unregister+0x60/0x60
[   40.085322]  [<ffffffff816a55a9>] netlink_rcv_skb+0xa9/0xc0
[   40.085709]  [<ffffffff81689b0a>] sock_diag_rcv+0x2a/0x40
[   40.086080]  [<ffffffff816a4b80>] netlink_unicast+0x100/0x1e0
[   40.086444]  [<ffffffff816a4fb0>] netlink_sendmsg+0x350/0x790
[   40.086847]  [<ffffffff8165209c>] sock_sendmsg+0x9c/0xe0
[   40.087244]  [<ffffffff811e49af>] ? might_fault+0x5f/0xb0
[   40.087600]  [<ffffffff811e49f8>] ? might_fault+0xa8/0xb0
[   40.087954]  [<ffffffff811e49af>] ? might_fault+0x5f/0xb0
[   40.088345]  [<ffffffff81652fe9>] ___sys_sendmsg+0x3a9/0x3c0
[   40.088716]  [<ffffffff810ef3c1>] ? __lock_acquire+0x501/0x1cc0
[   40.089102]  [<ffffffff81063f34>] ? __do_page_fault+0x254/0x5b0
[   40.089480]  [<ffffffff811e49af>] ? might_fault+0x5f/0xb0
[   40.089841]  [<ffffffff8110a7de>] ? rcu_read_lock_held+0x6e/0x80
[   40.090238]  [<ffffffff81256e6e>] ? __fget_light+0xbe/0xe0
[   40.090597]  [<ffffffff816537d1>] __sys_sendmsg+0x51/0x90
[   40.090951]  [<ffffffff81653822>] SyS_sendmsg+0x12/0x20
[   40.091367]  [<ffffffff817b3b69>] system_call_fastpath+0x16/0x1b
