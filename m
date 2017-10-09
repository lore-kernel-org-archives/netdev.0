From: Andrey Konovalov <andreyknvl@google.com>
Subject: usb/net/rtlwifi: trying to register non-static key in rtl_c2hcmd_launcher
Date: Mon, 9 Oct 2017 19:50:34 +0200
Message-ID: <CAAeHK+wjhrkr_EedW7+XyFcs1Y9NZVaLyYuGxDTpgrZ-jaLFJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I've got the following report while fuzzing the kernel with syzkaller.

On commit 8a5776a5f49812d29fe4b2d0a2d71675c3facf3f (4.14-rc4).

INFO: trying to register non-static key.
the code is fine but needs lockdep annotation.
turning off the locking correctness validator.
CPU: 0 PID: 24 Comm: kworker/0:1 Not tainted
4.14.0-rc4-43418-g43a3f84d2109-dirty #391
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: usb_hub_wq hub_event
Call Trace:
 __dump_stack lib/dump_stack.c:16
 dump_stack+0x292/0x395 lib/dump_stack.c:52
 register_lock_class+0x6c4/0x1a00 kernel/locking/lockdep.c:769
 __lock_acquire+0x27e/0x4550 kernel/locking/lockdep.c:3385
 lock_acquire+0x259/0x620 kernel/locking/lockdep.c:4002
 __raw_spin_lock_irqsave ./include/linux/spinlock_api_smp.h:110
 _raw_spin_lock_irqsave+0xcc/0x110 kernel/locking/spinlock.c:159
 rtl_c2hcmd_launcher+0x3ca/0x5d0
drivers/net/wireless/realtek/rtlwifi/base.c:2052
 rtl_deinit_core+0x79/0x350 drivers/net/wireless/realtek/rtlwifi/base.c:590
 rtl_usb_probe+0x1ca3/0x2470 drivers/net/wireless/realtek/rtlwifi/usb.c:1128
 rtl8192cu_probe+0x29/0x30
drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c:398
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
