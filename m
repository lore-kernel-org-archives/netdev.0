From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: null dereference in ipip6_get_stats in linux-next
Date: Wed, 29 Sep 2010 12:26:25 -0400
Message-ID: <20100929162625.GB17087@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Last night's linux-next fails to boot for me; apologies if this is already
known.

--b.

BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffff818f1fc0>] ipip6_get_stats+0x10/0x50
PGD 0 
Oops: 0000 [#1] PREEMPT 
last sysfs file: 
CPU 0 
Modules linked in:

Pid: 1, comm: swapper Not tainted 2.6.36-rc5-next-20100929-05834-g1063b82 #471 /Bochs
RIP: 0010:[<ffffffff818f1fc0>]  [<ffffffff818f1fc0>] ipip6_get_stats+0x10/0x50
RSP: 0018:ffff88001f4bdbe0  EFLAGS: 00010282
RAX: 0000000000000000 RBX: ffff88001f4bdc30 RCX: 0000000000000000
RDX: ffff88001ceecc60 RSI: ffff88001f4bdc30 RDI: ffff88001ceecc60
RBP: ffff88001f4bdbe0 R08: ffffffff81b31b20 R09: ffff88001cef55e4
R10: 0000000000000000 R11: 0000000000000000 R12: ffff88001f506c48
R13: ffff88001cef54f8 R14: ffff88001f4bdd1c R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffffffff81e1c000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 000000001ce5f000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 1, threadinfo ffff88001f4bc000, task ffff88001f4ba050)
Stack:
 ffff88001f4bdc00 ffffffff81840f6e ffff88001f4bdc00 ffff88001ceecc60
<0> ffff88001f4bdd50 ffffffff8184fe9b ffff88001f4bdcb0 ffff88001cef5584
<0> ffff88001cef3ca8 ffff8800ffffffff ffff88001cef54f0 ffff88001f400e80
Call Trace:
 [<ffffffff81840f6e>] dev_get_stats+0x5e/0xa0
 [<ffffffff8184fe9b>] rtnl_fill_ifinfo+0x39b/0x870
 [<ffffffff810e247a>] ? cache_alloc_debugcheck_after+0xea/0x220
 [<ffffffff81851115>] ? rtmsg_ifinfo+0x45/0x100
 [<ffffffff810e3f70>] ? __kmalloc_track_caller+0x150/0x290
 [<ffffffff81851115>] ? rtmsg_ifinfo+0x45/0x100
 [<ffffffff8185113e>] rtmsg_ifinfo+0x6e/0x100
 [<ffffffff8105f5c6>] ? raw_notifier_call_chain+0x16/0x20
 [<ffffffff81845391>] register_netdevice+0x441/0x4f0
 [<ffffffff818460df>] register_netdev+0x3f/0x60
 [<ffffffff81f0e9e6>] sit_init_net+0x194/0x1c4
 [<ffffffff81f0e934>] ? sit_init_net+0xe2/0x1c4
 [<ffffffff8183e28a>] ? ops_init.clone.2+0x6a/0x120
 [<ffffffff8183e268>] ops_init.clone.2+0x48/0x120
 [<ffffffff8183e417>] ? register_pernet_device+0x27/0x80
 [<ffffffff81f0e7f2>] ? sit_init+0x0/0x60
 [<ffffffff8183e397>] register_pernet_operations+0x57/0xb0
 [<ffffffff81f0e7f2>] ? sit_init+0x0/0x60
 [<ffffffff8183e426>] register_pernet_device+0x36/0x80
 [<ffffffff81f0e815>] sit_init+0x23/0x60
 [<ffffffff810001d2>] do_one_initcall+0x42/0x170
 [<ffffffff81ed85f5>] kernel_init+0xa5/0x12a
 [<ffffffff8196ccb9>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff81003274>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196defe>] ? restore_args+0x0/0x30
 [<ffffffff81ed8550>] ? kernel_init+0x0/0x12a
 [<ffffffff81003270>] ? kernel_thread_helper+0x0/0x10
Code: 48 8b 93 b8 00 00 00 e9 fd fe ff ff 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 55 48 89 e5 0f 1f 44 00 00 48 8b 87 58 04 00 00 <48> 8b 70 08 48 8b 48 10 48 8b 50 18 48 8b 00 48 89 b7 e0 00 00 
RIP  [<ffffffff818f1fc0>] ipip6_get_stats+0x10/0x50
 RSP <ffff88001f4bdbe0>
CR2: 0000000000000008
---[ end trace e2d6566c536d1627 ]---
