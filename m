From: =?UTF-8?Q?Ortwin_Gl=c3=bcck?= <odi@odi.ch>
Subject: 4.1.5 oops in alloc_skb_with_frags
Date: Fri, 14 Aug 2015 09:40:05 +0200
Message-ID: <55CD9B55.7060902@odi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I got a series of (same) Oopses on a fresh 4.1.5 on KDE startup:

Aug 14 08:45:38 gandalf kernel: PGD 0
Aug 14 08:45:38 gandalf kernel: Oops: 0000 [#1] PREEMPT SMP
Aug 14 08:45:38 gandalf kernel: Modules linked in: radeon cfbfillrect cfbimgblt cfbcopyarea fbcon 
i2c_algo_bit bit
blit softcursor font drm_kms_helper ttm drm fb fbdev
Aug 14 08:45:38 gandalf kernel: CPU: 2 PID: 2726 Comm: X Not tainted 4.1.5 #1
Aug 14 08:45:38 gandalf kernel: Hardware name: Apple Inc. iMac11,2/Mac-F2238AC8, BIOS 
IM112.88Z.0057.B00.100503
1455 05/03/10
Aug 14 08:45:38 gandalf kernel: task: ffff880092e8b020 ti: ffff880135248000 task.ti: ffff880135248000
Aug 14 08:45:38 gandalf kernel: RIP: 0010:[<ffffffff811b41a6>]  [<ffffffff811b41a6>] 
__kmalloc_track_caller+0x76/0
x190
Aug 14 08:45:38 gandalf kernel: RSP: 0018:ffff88013524ba88  EFLAGS: 00010202
Aug 14 08:45:38 gandalf kernel: RAX: 0000000000000000 RBX: ffff8800812e2f00 RCX: 0000000000009042
Aug 14 08:45:38 gandalf kernel: RDX: 000000000000903a RSI: 000000000000903a RDI: 00000000000002bf
Aug 14 08:45:38 gandalf kernel: RBP: ffff88013524bac8 R08: 0000000000018d80 R09: 0000000000000003
Aug 14 08:45:38 gandalf kernel: R10: 000000007ffff000 R11: 0000000000000160 R12: 00000000000002c0
Aug 14 08:45:38 gandalf kernel: R13: 00000000000106d0 R14: 000001d60000800b R15: ffff880137001780
Aug 14 08:45:38 gandalf kernel: FS:  00007f5233ea1880(0000) GS:ffff88013bc80000(0000) 
knlGS:0000000000000000
Aug 14 08:45:38 gandalf kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Aug 14 08:45:38 gandalf kernel: CR2: 000001d60000800b CR3: 000000013528b000 CR4: 00000000000006e0
Aug 14 08:45:38 gandalf kernel: Stack:
Aug 14 08:45:38 gandalf kernel:  ffff880100000000 ffffffff8164defd ffff88013524bae8 ffff8800812e2f00
Aug 14 08:45:38 gandalf kernel:  ffff88013524bb27 00000000000004d0 00000000000002c0 0000000000000000
Aug 14 08:45:38 gandalf kernel:  ffff88013524bb08 ffffffff8164de3c ffff880136799300 ffff8800812e2f00
Aug 14 08:45:38 gandalf kernel: Call Trace:
Aug 14 08:45:38 gandalf kernel:  [<ffffffff8164defd>] ? __alloc_skb+0x6d/0x1c0
Aug 14 08:45:38 gandalf kernel:  [<ffffffff8164de3c>] __kmalloc_reserve.isra.43+0x2c/0x80
Aug 14 08:45:38 gandalf kernel:  [<ffffffff8164defd>] __alloc_skb+0x6d/0x1c0
Aug 14 08:45:38 gandalf kernel:  [<ffffffff8164e0a7>] alloc_skb_with_frags+0x57/0x200
Aug 14 08:45:38 gandalf kernel:  [<ffffffff81649e83>] ? sock_wfree+0x53/0x60
Aug 14 08:45:38 gandalf kernel:  [<ffffffff81647dd6>] sock_alloc_send_pskb+0x196/0x240
Aug 14 08:45:38 gandalf kernel:  [<ffffffff816531bf>] ? skb_copy_datagram_from_iter+0x4f/0x1f0
Aug 14 08:45:38 gandalf kernel:  [<ffffffff8174b55a>] unix_stream_sendmsg+0x25a/0x3a0
Aug 14 08:45:38 gandalf kernel:  [<ffffffff81644c52>] sock_sendmsg+0x12/0x20
Aug 14 08:45:38 gandalf kernel:  [<ffffffff81644cd3>] sock_write_iter+0x73/0xd0
Aug 14 08:45:38 gandalf kernel:  [<ffffffff811bc3d4>] do_iter_readv_writev+0x54/0x70
Aug 14 08:45:38 gandalf kernel:  [<ffffffff811bca96>] do_readv_writev+0x196/0x230
Aug 14 08:45:38 gandalf kernel:  [<ffffffff811d7f80>] ? __fget_light+0x20/0x70
Aug 14 08:45:38 gandalf kernel:  [<ffffffff811d7f0d>] ? __fget+0x6d/0xa0
Aug 14 08:45:38 gandalf kernel:  [<ffffffff811bcba4>] vfs_writev+0x34/0x50
Aug 14 08:45:38 gandalf kernel:  [<ffffffff811bd875>] SyS_writev+0x45/0xd0
Aug 14 08:45:38 gandalf kernel:  [<ffffffff8189f197>] system_call_fastpath+0x12/0x6a
Aug 14 08:45:38 gandalf kernel: Code: 48 89 c8 65 48 03 05 8a 5f e5 7e 48 8b 70 08 48 39 f2 75 e7 4c 
8b 30 4d 85 f6 0f 84 bc 00 00 00 49 63 47 20 48 8d 4a 08 4d 8b 07 <49> 8b 1c 06 4c 89 f0 65 49 0f c7 
08 0f 94 c0 84 c0 74 ba 49 63
Aug 14 08:45:38 gandalf kernel:  RSP <ffff88013524ba88>
Aug 14 08:45:38 gandalf kernel: CR2: 000001d60000800b
Aug 14 08:45:38 gandalf kernel: ---[ end trace 3cf0da471519df5e ]---
