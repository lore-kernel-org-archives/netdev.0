From: Andrey Konovalov <andreyknvl@google.com>
Subject: usb/net/rt2x00: warning in rt2800_eeprom_word_index
Date: Mon, 9 Oct 2017 19:50:53 +0200
Message-ID: <CAAeHK+yUNrrNU3Jqrfs7XAT809eyF4nv673cSL8RppbLrDtWNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I've got the following report while fuzzing the kernel with syzkaller.

On commit 8a5776a5f49812d29fe4b2d0a2d71675c3facf3f (4.14-rc4).

I'm not sure whether this is a bug in the driver, or just a way to
report misbehaving device. In the latter case this shouldn't be a
WARN() call, since WARN() means bug in the kernel.

phy2: invalid access of EEPROM word 39
------------[ cut here ]------------
WARNING: CPU: 1 PID: 5591 at
drivers/net/wireless/ralink/rt2x00/rt2800lib.c:399
rt2800_eeprom_word_index.isra.15+0x149/0x1c0
Modules linked in:
CPU: 1 PID: 5591 Comm: syz-executor Not tainted
4.14.0-rc4-43423-g7263a3720c3f #392
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880069933180 task.stack: ffff88005aee8000
RIP: 0010:rt2800_eeprom_word_index.isra.15+0x149/0x1c0
drivers/net/wireless/ralink/rt2x00/rt2800lib.c:397
RSP: 0018:ffff88005aeed960 EFLAGS: 00010282
RAX: 0000000000000026 RBX: ffff88005af0c5c0 RCX: 0000000000000000
RDX: 0000000000000026 RSI: ffffffff813292c9 RDI: ffffed000b5ddb1e
RBP: ffff88005aeed978 R08: ffff88005aeecd90 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000027
R13: ffff880068631018 R14: 0000000000000052 R15: 0000000000000000
FS:  0000000001c60940(0000) GS:ffff88006c700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000001967000 CR3: 0000000068089000 CR4: 00000000000006e0
Call Trace:
 rt2800_eeprom_addr drivers/net/wireless/ralink/rt2x00/rt2800lib.c:409
 rt2800_probe_hw_mode drivers/net/wireless/ralink/rt2x00/rt2800lib.c:9321
 rt2800_probe_hw+0x19ef/0x27b0
drivers/net/wireless/ralink/rt2x00/rt2800lib.c:9456
 rt2800usb_probe_hw+0x6e/0x200
drivers/net/wireless/ralink/rt2x00/rt2800usb.c:768
 rt2x00lib_probe_dev+0x9e5/0x2800
drivers/net/wireless/ralink/rt2x00/rt2x00dev.c:1427
 rt2x00usb_probe+0x67b/0x990 drivers/net/wireless/ralink/rt2x00/rt2x00usb.c:837
 rt2800usb_probe+0x21/0x30 drivers/net/wireless/ralink/rt2x00/rt2800usb.c:1410
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
 usb_new_device+0x7b8/0x1020 drivers/usb/core/hub.c:2538
 hub_port_connect drivers/usb/core/hub.c:4984
 hub_port_connect_change drivers/usb/core/hub.c:5090
 port_event drivers/usb/core/hub.c:5196
 hub_event_impl+0x1971/0x3760 drivers/usb/core/hub.c:5310
 gfs_hub_events_handle+0x881/0xae0 drivers/usb/core/hub.c:1853
 hub_ioctl+0x53d/0x680 drivers/usb/core/hub.c:1903
 proc_ioctl+0x435/0x680 drivers/usb/core/devio.c:2175
 proc_ioctl_default drivers/usb/core/devio.c:2198
 usbdev_do_ioctl+0xee9/0x3790 drivers/usb/core/devio.c:2512
 usbdev_ioctl+0x2a/0x40 drivers/usb/core/devio.c:2556
 vfs_ioctl fs/ioctl.c:45
 do_vfs_ioctl+0x1c4/0x15c0 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700
 SyS_ioctl+0x94/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x23/0xc2 arch/x86/entry/entry_64.S:202
RIP: 0033:0x447707
RSP: 002b:00007ffd565109b8 EFLAGS: 00000206 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 0000000000447707
RDX: 00007ffd565109d0 RSI: 00000000c0105512 RDI: 0000000000000015
RBP: 0000000000000005 R08: 0000000001c60940 R09: 0000000001c60940
R10: 00000000004a8e59 R11: 0000000000000206 R12: 0000000000000015
R13: 0000000000000000 R14: 00007ffd56510888 R15: 00007ffd565108f8
Code: ea 03 80 3c 02 00 75 72 4c 8b ab 70 01 00 00 4d 85 ed 74 3a e8
29 c5 9b fd 44 89 e2 4c 89 ee 48 c7 c7 e0 4d d5 86 e8 f1 6d 84 fd <0f>
ff 31 db e9 4c ff ff ff 48 89 df e8 36 f2 cd fd e9 34 ff ff
---[ end trace a71f41162bce05c3 ]---
