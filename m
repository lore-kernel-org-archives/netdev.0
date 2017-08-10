From: David Ahern <dsahern@gmail.com>
Subject: RTNL: assertion failed at ...
Date: Wed, 9 Aug 2017 19:18:32 -0600
Message-ID: <6279e669-f38c-3635-9f02-4c5281219fbd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37735 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752098AbdHJBSp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 21:18:45 -0400
Received: by mail-pg0-f68.google.com with SMTP id 83so7166873pgb.4
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 18:18:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian:

Booting top of tree on my host with a VRF configured is spewing traces:

[   24.779911] RTNL: assertion failed at
/home/dsa/kernel.git/net/core/dev.c (5717)
[   24.779984] CPU: 3 PID: 989 Comm: ip Not tainted
4.13.0-rc4-01020-gcd9cb3890b20 #8
[   24.779986] Hardware name: Supermicro X9DAi/X9DAi, BIOS 1.0b 10/17/2012
[   24.779988] Call Trace:
[   24.780002]  dump_stack+0x85/0xc7
[   24.780009]  netdev_master_upper_dev_get+0x5f/0x70
[   24.780017]  if_nlmsg_size+0x158/0x240
[   24.780021]  rtnl_calcit.isra.26+0xa3/0xf0
[   24.780029]  ? dump_rules+0xd0/0xd0
[   24.780033]  rtnetlink_rcv_msg+0x1f0/0x230
[   24.780037]  ? rtnl_calcit.isra.26+0xf0/0xf0
[   24.780043]  netlink_rcv_skb+0xec/0x120
[   24.780047]  rtnetlink_rcv+0x15/0x20
[   24.780050]  netlink_unicast+0x16a/0x210
[   24.780054]  netlink_sendmsg+0x2b8/0x3a0
[   24.780060]  sock_sendmsg+0x38/0x50
[   24.780063]  SYSC_sendto+0x102/0x190
[   24.780069]  ? handle_mm_fault+0xe8/0x210
[   24.780075]  ? __do_page_fault+0x1f6/0x4a0
[   24.780080]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[   24.780083]  SyS_sendto+0xe/0x10
[   24.780089]  entry_SYSCALL_64_fastpath+0x23/0xbd
[   24.780117] RIP: 0033:0x7fc3972d95ed
[   24.780119] RSP: 002b:00007fff9fbd4528 EFLAGS: 00000246 ORIG_RAX:
000000000000002c
[   24.780121] RAX: ffffffffffffffda RBX: 000000000044bd00 RCX:
00007fc3972d95ed
[   24.780122] RDX: 0000000000000028 RSI: 00007fff9fbd4530 RDI:
0000000000000003
[   24.780123] RBP: 00007fff9fbd5f77 R08: 0000000000000000 R09:
0000000000000000
[   24.780124] R10: 0000000000000000 R11: 0000000000000246 R12:
0000000000000002
[   24.780125] R13: 00007fff9fbd4750 R14: 0000000000000000 R15:
0000000000000000


I did not do a bisect but seems pretty obvious that it has to be your
patch set.

David
