From: Tommi Rantala <tt.rantala@gmail.com>
Subject: vhost && kernel BUG at /build/linux/mm/slub.c:3352!
Date: Tue, 4 Jun 2013 21:50:59 +0300
Message-ID: <CA+ydwtrtpA3jXojG3tKt_-ueJOWDSOL1trM9h6F5qLvdoonUOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trinity@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Hit this right after killing trinity with Ctrl-C. Was fuzzing
v3.10-rc4-0-gd683b96 in a qemu virtual machine as the root user.

Tommi

[29175] Random reseed: 3970521611
[29175] Random reseed: 202886419
[29175] Random reseed: 2930978521
[179904.099501] binder: 29175:2539 ioctl 4010630e fff returned -22
[29175] Random reseed: 2776471322
[29175] Random reseed: 3086119361
child 2606 exiting
[29175] Bailing main loop. Exit reason: ctrl-c
[179906.393060] ------------[ cut here ]------------
[179906.396341] kernel BUG at /build/linux/mm/slub.c:3352!
[179906.399693] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[179906.403272] CPU: 0 PID: 29175 Comm: trinity-main Not tainted 3.10.0-rc4 #1
[179906.407692] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[179906.411475] task: ffff8800b69e47c0 ti: ffff880092f2e000 task.ti:
ffff880092f2e000
[179906.416305] RIP: 0010:[<ffffffff81225255>]  [<ffffffff81225255>]
kfree+0x155/0x2c0
[179906.421462] RSP: 0000:ffff880092f2fdb0  EFLAGS: 00010246
[179906.424983] RAX: 0100000000000000 RBX: ffff88009e588000 RCX:
0000000000000000
[179906.429746] RDX: ffff8800b69e47c0 RSI: 00000000000a0004 RDI:
ffff88009e588000
[179906.434499] RBP: ffff880092f2fdd8 R08: 0000000000000001 R09:
0000000000000000
[179906.439226] R10: 0000000000000000 R11: 0000000000000001 R12:
0000000000000000
[179906.443835] R13: ffffea0002796200 R14: ffff8800b9a960f8 R15:
ffff8800ba06f6a0
[179906.448470] FS:  00007f04cd25c700(0000) GS:ffff8800bf600000(0000)
knlGS:0000000000000000
[179906.453857] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[179906.456956] CR2: 00007f98e29d8f50 CR3: 000000009294a000 CR4:
00000000000006f0
[179906.460558] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[179906.464059] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[179906.467617] Stack:
[179906.468704]  ffff88001a7c0000 0000000000000000 0000000000000000
ffff8800b9a960f8
[179906.472638]  ffff8800ba06f6a0 ffff880092f2fdf0 ffffffff81c1c6df
ffff88001a7c0000
[179906.476583]  ffff880092f2fe18 ffffffff81c1c771 ffff8800b69718c0
0000000000000008
[179906.480377] Call Trace:
[179906.481636]  [<ffffffff81c1c6df>] vhost_net_vq_reset+0x7f/0xb0
[179906.484611]  [<ffffffff81c1c771>] vhost_net_release+0x61/0xb0
[179906.487481]  [<ffffffff8123237a>] __fput+0x12a/0x230
[179906.489968]  [<ffffffff81232489>] ____fput+0x9/0x10
[179906.492422]  [<ffffffff8113a79e>] task_work_run+0xae/0xf0
[179906.495169]  [<ffffffff811172bc>] do_exit+0x44c/0xb40
[179906.497789]  [<ffffffff822a24d8>] ? retint_swapgs+0x13/0x1b
[179906.500652]  [<ffffffff81117a74>] do_group_exit+0x84/0xd0
[179906.503348]  [<ffffffff81117ad2>] SyS_exit_group+0x12/0x20
[179906.506146]  [<ffffffff822a2e29>] system_call_fastpath+0x16/0x1b
[179906.509147] Code: 49 c1 ed 0c 49 c1 e5 06 49 01 c5 49 8b 45 00 f6
c4 80 74 0a 4d 8b 6d 30 66 0f 1f 44 00 00 49 8b 45 00 a8 80 75 28 f6
c4 c0 75 02 <0f> 0b 49 8b 45 00 31 f6 f6 c4 40 74 04 41 8b 75 68 4c 89
ef e8
[179906.522213] RIP  [<ffffffff81225255>] kfree+0x155/0x2c0
[179906.524937]  RSP <ffff880092f2fdb0>
[179906.575627] ---[ end trace 3d4ce10faaa29990 ]---
[179906.577103] Fixing recursive fault but reboot is needed!
[29174] Watchdog exiting
