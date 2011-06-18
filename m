From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: siw-2011-06-16 and ib_uverbs
Date: Sat, 18 Jun 2011 19:26:54 +0200
Message-ID: <BANLkTinb_9AAGHCJw22VAP87Y5eBG3o6TA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 15, 2011 at 5:43 PM, Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> wrote:
> If I don't hear objection before tomorrow I would post it as an
> increment - as summarized below.

This is what I ran into by unloading ib_uverbs:

$ modprobe siw && modprobe ib_uverbs && rmmod ib_uverbs
BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<ffffffffa0348809>] uverbs_devnode+0x9/0x30 [ib_uverbs]
PGD 1fb5d067 PUD 1d398067 PMD 0
Oops: 0002 [#1] PREEMPT SMP
[ ... ]
RIP: 0010:[<ffffffffa0348809>]  [<ffffffffa0348809>]
uverbs_devnode+0x9/0x30 [ib_uverbs]
RSP: 0018:ffff88001298fbd8  EFLAGS: 00010286
RAX: ffffffffa0348800 RBX: ffff880013d49df8 RCX: 0000000000000001
RDX: ffff88001298fd80 RSI: 0000000000000000 RDI: ffff880013d49df8
RBP: ffff88001298fbd8 R08: 0000000000000002 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000000
R13: ffff88001a4ee4f0 R14: ffff88001298fd80 R15: 00000000fffffff4
FS:  00007f9b7b8e5720(0000) GS:ffff88001fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000019026000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process rmmod (pid: 10245, threadinfo ffff88001298e000, task ffff88000c6a3f40)
Stack:
 ffff88001298fc08 ffffffff812a30bd ffff880013d49df8 ffff88001dbfc1b0
 ffff88001a4ee4f0 00007fff9a4aa8c0 ffff88001298fdb8 ffffffff812aa0a9
 0000000000000000 0000000000000006 ffff880013dd62e0 0000000000000000
Call Trace:
 [<ffffffff812a30bd>] device_get_devnode+0x8d/0x120
 [<ffffffff812aa0a9>] devtmpfs_delete_node+0x69/0x2c0
 [<ffffffff8108e2cf>] ? mark_held_locks+0x6f/0xa0
 [<ffffffff81128cc6>] ? __slab_free+0xc6/0x240
 [<ffffffff813eaae1>] ? klist_release+0x31/0xd0
 [<ffffffff812a1510>] ? put_device+0x20/0x20
 [<ffffffff811dafe7>] ? kobject_put+0x27/0x60
 [<ffffffff812a1507>] ? put_device+0x17/0x20
 [<ffffffff812a1522>] ? klist_children_put+0x12/0x20
 [<ffffffff812a1fe0>] device_del+0x190/0x1c0
 [<ffffffff812a2032>] device_unregister+0x22/0x60
 [<ffffffff812a20ab>] device_destroy+0x3b/0x50
 [<ffffffffa034808f>] ib_uverbs_remove_one+0x3f/0xa0 [ib_uverbs]
 [<ffffffffa022832f>] ib_unregister_device+0x4f/0x100 [ib_core]
 [<ffffffffa024dc4d>] siw_exit_module+0x101/0x147 [siw]
 [<ffffffff81099273>] sys_delete_module+0x173/0x260
 [<ffffffff81402771>] ? retint_swapgs+0xe/0x13
 [<ffffffff8108e44d>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff8140302b>] system_call_fastpath+0x16/0x1b
Code: ff 48 c7 c7 38 e6 34 a0 31 c0 e8 7d 55 0b e1 e9 66 ff ff ff 66
66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 66 66 66 66 90 <c7>
06 b6 01 00 00 48 c7 c6 17 e5 34 a0 48 8b 57 50 48 85 d2 48
RIP  [<ffffffffa0348809>] uverbs_devnode+0x9/0x30 [ib_uverbs]
 RSP <ffff88001298fbd8>
CR2: 0000000000000000
---[ end trace 2dab58bcf192cb4b ]---

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
