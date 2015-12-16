From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: kernel BUG at /home/kas/linux/mm/net/ipv6/raw.c:592!
Date: Wed, 16 Dec 2015 16:24:42 +0200
Message-ID: <20151216142442.GA18196@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Fuzzing -mm tree with trinity in KVM trigered this:

[  602.630207] kernel BUG at /home/kas/linux/mm/net/ipv6/raw.c:592!
[  602.630912] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC 
[  602.631627] Modules linked in:
[  602.631969] CPU: 17 PID: 13535 Comm: trinity-c17 Not tainted 4.3.0-dirty #858
[  602.632730] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[  602.633079] task: ffff880852f298c0 ti: ffff8806d4648000 task.ti: ffff8806d4648000
[  602.633079] RIP: 0010:[<ffffffff81859e21>]  [<ffffffff81859e21>] rawv6_sendmsg+0xb31/0xb80
[  602.633079] RSP: 0018:ffff8806d464bc30  EFLAGS: 00010282
[  602.633079] RAX: 00000000fffffff2 RBX: 0000000000000030 RCX: 0000000000000002
[  602.633079] RDX: ffff8806d464bce0 RSI: 0000000000000030 RDI: ffff88084ff9de00
[  602.633079] RBP: ffff8806d464bd88 R08: 000000000000007c R09: 0000000000000009
[  602.638114] R10: 0000000000000031 R11: 0000000000000000 R12: 0000000000000000
[  602.638114] R13: ffff88084f685480 R14: ffff88084ff9de00 R15: ffff880791a7c000
[  602.638114] FS:  00007f1fb31a8700(0000) GS:ffff880859800000(0000) knlGS:0000000000000000
[  602.638114] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  602.638114] CR2: 0000000000000004 CR3: 0000000832baa000 CR4: 00000000000006a0
[  602.638114] DR0: ffffffff81000000 DR1: 0000000000000000 DR2: 0000000000000000
[  602.638114] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  602.638114] Stack:
[  602.638114]  0000000000000000 ffff880855ead000 ffff8806d464bd18 ffff880791a7c000
[  602.638114]  ffff880800000000 0000000000000000 0000000000000011 ffff88080000007c
[  602.638114]  ffff880800000009 0000000000000001 0000000000000040 0000000000000000
[  602.638114] Call Trace:
[  602.638114]  [<ffffffff8108ced7>] ? sched_clock_local+0x17/0x80
[  602.638114]  [<ffffffff8143f9e7>] ? debug_smp_processor_id+0x17/0x20
[  602.638114]  [<ffffffff81808031>] ? inet_sendmsg+0xc1/0x1c0
[  602.638114]  [<ffffffff8180806e>] inet_sendmsg+0xfe/0x1c0
[  602.638114]  [<ffffffff81807f75>] ? inet_sendmsg+0x5/0x1c0
[  602.638114]  [<ffffffff8175a747>] sock_sendmsg+0x17/0x30
[  602.638114]  [<ffffffff8175a7de>] sock_write_iter+0x7e/0xd0
[  602.638114]  [<ffffffff811e684a>] __vfs_write+0xaa/0xf0
[  602.638114]  [<ffffffff811e7067>] vfs_write+0xa7/0x1a0
[  602.638114]  [<ffffffff812062ef>] ? __fget_light+0x6f/0x90
[  602.638114]  [<ffffffff811e7ccd>] SyS_write+0x4d/0xc0
[  602.638114]  [<ffffffff8189df17>] entry_SYSCALL_64_fastpath+0x12/0x6f
[  602.638114] Code: 00 00 e9 15 f9 ff ff ba ff ff ff ff 66 89 94 24 b0 00 00 00 e9 bf fe ff ff e8 2c 42 87 ff 85 c0 74 19 49 8b 46 58 e9 b1 fd ff ff <0f> 0b f7 d0 41 01 c0 41 83 d0 00 e9 5e fe ff ff e8 7a 43 87 ff 
[  602.638114] RIP  [<ffffffff81859e21>] rawv6_sendmsg+0xb31/0xb80
[  602.638114]  RSP <ffff8806d464bc30>

-- 
 Kirill A. Shutemov
