From: Jonathan McDowell <noodles@earth.li>
Subject: 2.6.28-rc2 / hso driver oops
Date: Wed, 29 Oct 2008 16:40:06 +0000
Message-ID: <20081029164006.GH3162@earth.li>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754886AbYJ2QkY@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

Tried out 2.6.28-rc2 today on my EEE 901 and my Option Icon 225 and got
the following oops:

hso: drivers/net/usb/hso.c: 1.2 Option Wireless
usbcore: registered new interface driver hso
usb 2-2: new full speed USB device using uhci_hcd and address 3
usb 2-2: configuration #1 chosen from 1 choice
hso0: Disabled Privacy Extensions
BUG: unable to handle kernel NULL pointer dereference at 000000d0
IP: [<c03589b9>] dev_driver_string+0x1/0x2a
*pde = 00000000 
Oops: 0000 [#1] PREEMPT SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:1d.0/usb2/idVendor
Modules linked in: hso usb_storage rfcomm l2cap rt2860sta evdev

Pid: 230, comm: khubd Not tainted (2.6.28-rc2 #2) 901
EIP: 0060:[<c03589b9>] EFLAGS: 00010246 CPU: 0
EIP is at dev_driver_string+0x1/0x2a
EAX: 00000000 EBX: f2c88480 ECX: f7159cb0 EDX: 00000001
ESI: f2fdee40 EDI: f68bd200 EBP: f7159cf8 ESP: f7159cd0
DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process khubd (pid: 230, ti=f7158000 task=f70b02b0 task.ti=f7158000)
Stack:
f7159cf8 f81b8265 f2c88480 f6ab8440 00000003 00000003 00000000 00000112
00000000 f81b90c8 f7159d48 f81b840d c029f782 f68bd200 fffffffe f6b143a8
f7159d20 f7159d2c 00000000 f6b143a8 f81b90c8 f7159d38 f7159d40 c038886b
Call Trace:
[<f81b8265>] ? hso_create_net_device+0x305/0x32d [hso]
[<f81b840d>] ? hso_probe+0x180/0x56c [hso]
[<c029f782>] ? __sysfs_add_one+0x14/0x85
[<c038886b>] ? usb_autopm_do_device+0xb1/0xb9
[<c0388d77>] ? usb_probe_interface+0xe9/0x11c
[<c035b10a>] ? driver_probe_device+0xa0/0x136
[<c035b213>] ? __device_attach+0x8/0xa
[<c035a8fe>] ? bus_for_each_drv+0x3d/0x67
[<c035b284>] ? device_attach+0x50/0x64
[<c035b20b>] ? __device_attach+0x0/0xa
[<c035a77e>] ? bus_attach_device+0x21/0x48
[<c03598e6>] ? device_add+0x307/0x456
[<c03880b2>] ? usb_set_configuration+0x400/0x449
[<c038e44b>] ? generic_probe+0x44/0x7d
[<c038828e>] ? usb_probe_device+0x32/0x38
[<c035b10a>] ? driver_probe_device+0xa0/0x136
[<c035b213>] ? __device_attach+0x8/0xa
[<c035a8fe>] ? bus_for_each_drv+0x3d/0x67
[<c035b284>] ? device_attach+0x50/0x64
[<c035b20b>] ? __device_attach+0x0/0xa
[<c035a77e>] ? bus_attach_device+0x21/0x48
[<c03598e6>] ? device_add+0x307/0x456
[<c03831d1>] ? usb_new_device+0x4d/0x8e
[<c038433c>] ? hub_thread+0x94d/0xdcb
[<c021f6b7>] ? default_wake_function+0xb/0xd
[<c0234b83>] ? autoremove_wake_function+0x0/0x33
[<c03839ef>] ? hub_thread+0x0/0xdcb
[<c02348f9>] ? kthread+0x3b/0x61
[<c02348be>] ? kthread+0x0/0x61
[<c0203c1b>] ? kernel_thread_helper+0x7/0x10
Code: 32 fe ff ff b9 81 00 00 00 b8 03 00 00 00 f3 a5 c7 83 b8 13 00 00 03 00 00 00 59 5e 89 83 8c 0b 00 00 8d 65 f4 5b 5e 5f 5d c3 55 <8b> 90 d0 00 00 00 89 e5 85 d2 75 19 8b 90 cc 00 00 00 85 d2 75 
EIP: [<c03589b9>] dev_driver_string+0x1/0x2a SS:ESP 0068:f7159cd0
---[ end trace fe2452bf3bd83a7f ]---

Stock 2.6.28-rc2 + ec_all.patch from lkml + rt2860sta driver (though I
can't see how either of these are implicated I can try without if
necessary).

It looks like there are only a couple of changes since 2.6.27 to this
driver so I can try reverting both of them, but neither looks especially
likely? (8ef5ba63b94b04b182ac4a6009dbbf1406beb3c5 &
e57b641dfafc10ce23d26cf271fd2638589fdb3f)

J.

-- 
Revd. Jonathan McDowell, ULC | Shall I call the United Nations?
