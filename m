From: Andrey Konovalov <andreyknvl@google.com>
Subject: usb/net/ath6kl: GPF in ath6kl_usb_alloc_urb_from_pipe
Date: Mon, 9 Oct 2017 19:50:01 +0200
Message-ID: <CAAeHK+yHexQUqEAAzC+Bgus4+HcbmJqYUYRVV_Yi=mYJ+B3tig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Kalle Valo <kvalo@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I've got the following report while fuzzing the kernel with syzkaller.

On commit 8a5776a5f49812d29fe4b2d0a2d71675c3facf3f (4.14-rc4).

usb 1-1: New USB device found, idVendor=0cf3, idProduct=9375
usb 1-1: New USB device strings: Mfr=2, Product=255, SerialNumber=8
usb 1-1: Product: a
usb 1-1: Manufacturer: a
usb 1-1: SerialNumber: a
gadgetfs: configuration #9
kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] PREEMPT SMP KASAN
Modules linked in:
CPU: 1 PID: 1494 Comm: kworker/1:1 Not tainted
4.14.0-rc4-43418-g43a3f84d2109 #379
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: usb_hub_wq hub_event
task: ffff880068e9ca40 task.stack: ffff880068948000
RIP: 0010:__lock_acquire+0xe18/0x4550 kernel/locking/lockdep.c:3376
RSP: 0018:ffff88006894d788 EFLAGS: 00010006
RAX: dffffc0000000000 RBX: dffffc0000000000 RCX: 0000000000000000
RDX: 0000000000000003 RSI: 0000000000000000 RDI: 1ffff1000d129b3c
RBP: ffff88006894dd08 R08: 0000000000000001 R09: 0000000000000001
R10: 0000000000000000 R11: ffffffff89789760 R12: ffff880068e9ca40
R13: dffffc0000000000 R14: 0000000000000001 R15: 0000000000000018
FS:  0000000000000000(0000) GS:ffff88006c500000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f9558dca000 CR3: 0000000066dc4000 CR4: 00000000000006e0
Call Trace:
 lock_acquire+0x259/0x620 kernel/locking/lockdep.c:4002
 __raw_spin_lock_irqsave ./include/linux/spinlock_api_smp.h:110
 _raw_spin_lock_irqsave+0xcc/0x110 kernel/locking/spinlock.c:159
 ath6kl_usb_alloc_urb_from_pipe+0x103/0x4c0
drivers/net/wireless/ath/ath6kl/usb.c:135
 ath6kl_usb_post_recv_transfers.constprop.10+0x228/0x420
drivers/net/wireless/ath/ath6kl/usb.c:410
 ath6kl_usb_start_recv_pipes drivers/net/wireless/ath/ath6kl/usb.c:484
 hif_start drivers/net/wireless/ath/ath6kl/usb.c:682
 ath6kl_usb_power_on+0x8a/0x120 drivers/net/wireless/ath/ath6kl/usb.c:1041
 ath6kl_hif_power_on drivers/net/wireless/ath/ath6kl/hif-ops.h:136
 ath6kl_core_init+0x180/0x1190 drivers/net/wireless/ath/ath6kl/core.c:97
 ath6kl_usb_probe+0xdf4/0x1420 drivers/net/wireless/ath/ath6kl/usb.c:1147
 usb_probe_interface+0x35d/0x8e0 drivers/usb/core/driver.c:361
 really_probe drivers/base/dd.c:413
 driver_probe_device+0x610/0xa00 drivers/base/dd.c:557
 __device_attach_driver+0x230/0x290 drivers/base/dd.c:653
 bus_for_each_drv+0x161/0x210 drivers/base/bus.c:463
 __device_attach+0x26e/0x3d0 drivers/base/dd.c:710
 device_initial_probe+0x1f/0x30 drivers/base/dd.c:757
 bus_probe_device+0x1eb/0x290 drivers/base/bus.c:523
 device_add+0xd0b/0x1660 drivers/base/core.c:1835
 usb_set_configuration+0x104e/0x1870 drivers/usb/core/message.c:1932
 generic_probe+0x73/0xe0 drivers/usb/core/generic.c:174
 usb_probe_device+0xaf/0xe0 drivers/usb/core/driver.c:266
 really_probe drivers/base/dd.c:413
 driver_probe_device+0x610/0xa00 drivers/base/dd.c:557
 __device_attach_driver+0x230/0x290 drivers/base/dd.c:653
 bus_for_each_drv+0x161/0x210 drivers/base/bus.c:463
 __device_attach+0x26e/0x3d0 drivers/base/dd.c:710
 device_initial_probe+0x1f/0x30 drivers/base/dd.c:757
 bus_probe_device+0x1eb/0x290 drivers/base/bus.c:523
 device_add+0xd0b/0x1660 drivers/base/core.c:1835
 usb_new_device+0x7b8/0x1020 drivers/usb/core/hub.c:2457
 hub_port_connect drivers/usb/core/hub.c:4903
 hub_port_connect_change drivers/usb/core/hub.c:5009
 port_event drivers/usb/core/hub.c:5115
 hub_event+0x194d/0x3740 drivers/usb/core/hub.c:5195
 process_one_work+0xc7f/0x1db0 kernel/workqueue.c:2119
 worker_thread+0x221/0x1850 kernel/workqueue.c:2253
 kthread+0x3a1/0x470 kernel/kthread.c:231
 ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
Code: 89 f0 c7 07 00 00 00 00 48 81 c4 58 05 00 00 5b 41 5c 41 5d 41
5e 41 5f 5d c3 48 b8 00 00 00 00 00 fc ff df 4c 89 fa 48 c1 ea 03 <80>
3c 02 00 0f 85 b2 36 00 00 49 81 3f 00 52 bb 88 41 be 00 00
RIP: __lock_acquire+0xe18/0x4550 RSP: ffff88006894d788
---[ end trace 56dead20dbd7b387 ]---
