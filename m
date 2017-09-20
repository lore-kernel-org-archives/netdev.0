From: Andrey Konovalov <andreyknvl@google.com>
Subject: usb/net/p54: trying to register non-static key in p54_unregister_leds
Date: Wed, 20 Sep 2017 20:37:08 +0200
Message-ID: <CAAeHK+xPoNn7i5xOzEqHX6tfDpmpb1rd0hcAxZpTHKi6B8xzsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Christian Lamparter <chunkeey@googlemail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I've got the following report while fuzzing the kernel with syzkaller.

On commit ebb2c2437d8008d46796902ff390653822af6cc4 (Sep 18).

INFO: trying to register non-static key.
the code is fine but needs lockdep annotation.
turning off the locking correctness validator.
CPU: 1 PID: 1404 Comm: kworker/1:1 Not tainted
4.14.0-rc1-42251-gebb2c2437d80-dirty #205
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: usb_hub_wq hub_event
Call Trace:
 __dump_stack lib/dump_stack.c:16
 dump_stack+0x292/0x395 lib/dump_stack.c:52
 register_lock_class+0x6c4/0x1a00 kernel/locking/lockdep.c:769
 __lock_acquire+0x27e/0x4550 kernel/locking/lockdep.c:3385
 lock_acquire+0x259/0x620 kernel/locking/lockdep.c:4002
 flush_work+0xf0/0x8c0 kernel/workqueue.c:2886
 __cancel_work_timer+0x51d/0x870 kernel/workqueue.c:2961
 cancel_delayed_work_sync+0x1f/0x30 kernel/workqueue.c:3081
 p54_unregister_leds+0x6c/0xc0 drivers/net/wireless/intersil/p54/led.c:160
 p54_unregister_common+0x3d/0xb0 drivers/net/wireless/intersil/p54/main.c:856
 p54u_disconnect+0x86/0x120 drivers/net/wireless/intersil/p54/p54usb.c:1073
 usb_unbind_interface+0x21c/0xa90 drivers/usb/core/driver.c:423
 __device_release_driver drivers/base/dd.c:861
 device_release_driver_internal+0x4f4/0x5c0 drivers/base/dd.c:893
 device_release_driver+0x1e/0x30 drivers/base/dd.c:918
 bus_remove_device+0x2f4/0x4b0 drivers/base/bus.c:565
 device_del+0x5c4/0xab0 drivers/base/core.c:1985
 usb_disable_device+0x1e9/0x680 drivers/usb/core/message.c:1170
 usb_disconnect+0x260/0x7a0 drivers/usb/core/hub.c:2124
 hub_port_connect drivers/usb/core/hub.c:4754
 hub_port_connect_change drivers/usb/core/hub.c:5009
 port_event drivers/usb/core/hub.c:5115
 hub_event+0x1318/0x3740 drivers/usb/core/hub.c:5195
 process_one_work+0xc7f/0x1db0 kernel/workqueue.c:2119
 process_scheduled_works kernel/workqueue.c:2179
 worker_thread+0xb2b/0x1850 kernel/workqueue.c:2255
 kthread+0x3a1/0x470 kernel/kthread.c:231
 ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
