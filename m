From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: net: pcnet32: [BUG] IRQ disabled when resizing ring buffer
Date: Tue, 25 Apr 2017 14:25:04 +0200
Message-ID: <20170425122504.GA20805@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pcnet32@frontier.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

When resizing ring buffer on qemu/pcnet32 with linux-next and CONFIG_DMA_API_DEBUG=y, I got the following trace:
[8862.793779] ------------[ cut here ]------------
[ 8862.793784] WARNING: CPU: 0 PID: 26592 at /linux-next/include/linux/dma-mapping.h:505 pcnet32_set_ringparam+0xd55/0xda0
[ 8862.793785] Modules linked in:
[ 8862.793788] CPU: 0 PID: 26592 Comm: ethtool Tainted: G        W       4.11.0-rc7-next-20170424+ #68
[ 8862.793789] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.1-0-g8891697-prebuilt.qemu-project.org 04/01/2014
[ 8862.793790] task: ffff880235390000 task.stack: ffff8801db300000
[ 8862.793792] RIP: 0010:pcnet32_set_ringparam+0xd55/0xda0
[ 8862.793794] RSP: 0018:ffff8801db303be0 EFLAGS: 00010046
[ 8862.793795] RAX: 0000000000000086 RBX: ffff880234d8d000 RCX: 0000000180800052
[ 8862.793797] RDX: 0000000000000004 RSI: ffffea00070b7700 RDI: ffff880236803a40
[ 8862.793798] RBP: ffff8801db303ca0 R08: 0000000000000001 R09: ffff880236a138a0
[ 8862.793799] R10: 00000000bb83e000 R11: ffff8800bb83e000 R12: 0000000000000004
[ 8862.793800] R13: 0000000000000010 R14: ffff8801db303cdc R15: ffffffff81807300
[ 8862.793803] FS:  00007f55edcc6700(0000) GS:ffff88023fc00000(0000) knlGS:0000000000000000
[ 8862.793804] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 8862.793805] CR2: 00007f55ed4eebe0 CR3: 00000001db2e0000 CR4: 00000000000006f0
[ 8862.793808] Call Trace:
[ 8862.793811]  ? get_page_from_freelist+0x263/0x930
[ 8862.793814]  dev_ethtool+0xde3/0x20b0
[ 8862.793816]  ? __alloc_pages_nodemask+0xd9/0xd70
[ 8862.793818]  ? __rtnl_unlock+0x25/0x60
[ 8862.793821]  ? netdev_run_todo+0x5c/0x320
[ 8862.793823]  ? __might_sleep+0x50/0x90
[ 8862.793824]  ? _cond_resched+0x14/0x30
[ 8862.793826]  dev_ioctl+0x18c/0x620
[ 8862.793828]  ? _raw_spin_unlock+0x9/0x20
[ 8862.793830]  sock_do_ioctl+0x4f/0x60
[ 8862.793832]  sock_ioctl+0x247/0x320
[ 8862.793834]  do_vfs_ioctl+0xaa/0x720
[ 8862.793836]  ? __do_page_fault+0x1d1/0x410
[ 8862.793838]  SyS_ioctl+0x47/0x80
[ 8862.793840]  entry_SYSCALL_64_fastpath+0x1a/0xa5
[ 8862.793842] RIP: 0033:0x7f55ed4eebe7
[ 8862.793843] RSP: 002b:00007ffd0b76bef8 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[ 8862.793845] RAX: ffffffffffffffda RBX: 00007ffd0b76c050 RCX: 00007f55ed4eebe7
[ 8862.793846] RDX: 00007ffd0b76c060 RSI: 0000000000008946 RDI: 0000000000000003
[ 8862.793847] RBP: 00007ffd0b76bf20 R08: 000000000000000a R09: 0000000000000000
[ 8862.793848] R10: 000000000000053e R11: 0000000000000246 R12: 00007ffd0b76c060
[ 8862.793848] R13: 00007ffd0b76c1d0 R14: 0000000000420e6f R15: 0000000000000002
[ 8862.793850] Code: 25 19 e1 6f 00 4d 85 e4 0f 85 34 fd ff ff eb 95 48 c7 c2 20 ea 8a 81 48 c7 c6 32 a6 9c 81 48 89 df e8 80 a7 18 00 e9 33 ff ff ff <0f> ff e9 a2 f7 ff ff 0f ff 66 90 e9    2d f6 ff ff 0f ff 66 0f 1f
[ 8862.793881] ---[ end trace ecb86a2cf3a149f7 ]---

Regards
Corentin Labbe
