From: "Nelson A. de Oliveira" <naoliv@gmail.com>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Mon, 21 Apr 2008 15:14:44 -0300
Message-ID: <9bfa9ae0804211114h365be96ey3c763acfac63acb0@mail.gmail.com>
References: <bug-10473-10286@http.bugzilla.kernel.org/>
	 <200804182018.52753.mb@bu3sch.de>
	 <9bfa9ae0804181202o601e7e86p135547ce802db88d@mail.gmail.com>
	 <200804182119.16195.mb@bu3sch.de>
	 <9bfa9ae0804181338q4a53fffdhe1833441794aed7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.186]:20818 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933AbYDUSOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 14:14:48 -0400
Received: by ti-out-0910.google.com with SMTP id 28so415307tif.23
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 11:14:46 -0700 (PDT)
In-Reply-To: <9bfa9ae0804181338q4a53fffdhe1833441794aed7@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I have tried to do a bisect here (thank you Jike Song for the link).
Marked 2.6.20 as good and master as bad. On the first test, I've got this:

(...)
BUG: unable to handle kernel NULL pointer dereference at virtual
address 00000000
 printing eip:
b01b6265
*pde = 00000000
Oops: 0000 [#1]
PREEMPT SMP
Modules linked in: b44(F) mousedev(F) iwl3945(F) ehci_hcd(F)
mac80211(F) snd_hda_intel(F) thermal(F) i2c_i801(F) ac(F) ssb(F)
snd_pcm(F) snd_timer(F) uhci_hcd(F) psmouse(F) evdev(F) battery(F)
button(F) processor(F) mii(F) usbcore(F) snd(F) snd_page_alloc(F)
sg(F) sr_mod(F) cdrom(F)
CPU:    0
EIP:    0060:[<b01b6265>]    Tainted: GF       VLI
EFLAGS: 00010246   (2.6.23-naoliv1 #1)
EIP is at strlen+0x8/0x11
eax: 00000000   ebx: f7429000   ecx: ffffffff   edx: f76b6cb0
esi: 00000000   edi: 00000000   ebp: 00000000   esp: f76b6ca0
ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
Process modprobe (pid: 692, ti=f76b6000 task=f76c6000 task.ti=f76b6000)
Stack: f75a2000 b01b3254 f785f200 b02d3e5b b02cb0da f7856200 b01b324a f7426688
       b02cb0da f7856200 f88f61f0 b0310c8c f785f200 f88f8e28 b0207d4e f74266a8
       f88f8d9c f7426600 f7426600 00000000 f7453400 b0206d8b f7426688 b02c4e14
Call Trace:
 [<b01b3254>] kobject_uevent_env+0x276/0x383
 [<b01b324a>] kobject_uevent_env+0x26c/0x383
 [<b0207d4e>] bus_add_device+0xad/0xdc
 [<b0206d8b>] device_add+0x2a0/0x45e
 [<f88f36f1>] ssb_attach_queued_buses+0x1a2/0x297 [ssb]
 [<f88f3b2f>] ssb_bus_register+0x120/0x185 [ssb]
 [<f88f4ac2>] ssb_pci_get_invariants+0x0/0x281 [ssb]
 [<f88f3bf3>] ssb_bus_pcibus_register+0x24/0x47 [ssb]
 [<b01bb856>] pci_set_master+0x54/0x58
 [<f88f52b1>] ssb_pcihost_probe+0x5e/0x89 [ssb]
 [<b01bd0ff>] pci_device_probe+0x36/0x55
 [<b020857e>] driver_probe_device+0xc5/0x148
 [<b02890a5>] klist_next+0x58/0x6d
 [<b02086dc>] __driver_attach+0x49/0x7f
 [<b0207ba8>] bus_for_each_dev+0x35/0x57
 [<b02083f2>] driver_attach+0x16/0x18
 [<b0208693>] __driver_attach+0x0/0x7f
 [<b0207e56>] bus_add_driver+0x6d/0x17d
 [<b01bd249>] __pci_register_driver+0x55/0x81
 [<f881d01f>] b44_init+0x1f/0x48 [b44]
 [<b013cdcc>] sys_init_module+0x1545/0x1619
 [<b0103e9a>] sysenter_past_esp+0x5f/0x85
 =======================
Code: f0 48 5e c3 56 89 d1 89 c6 83 ec 04 31 d2 89 c8 88 c4 ac 38 e0
75 03 8d 56 ff 84 c0 75 f4 5e 89 d0 5e c3 57 83 c9 ff 89 c7 31 c0 <f2>
ae f7 d1 49 5f 89 c8 c3 57 89 c7 89 d0 31 d2 85 c9 74 0c f2
EIP: [<b01b6265>] strlen+0x8/0x11 SS:ESP 0068:f76b6ca0
hub 1-2:1.0: hub_port_status failed (err = -71)
hub 1-2:1.0: hub_port_status failed (err = -71)
hub 1-2:1.0: hub_port_status failed (err = -71)
hub 1-2:1.0: hub_port_status failed (err = -71)
Clocksource tsc unstable (delta = -162081422 ns)
usb 5-2: new high speed USB device using ehci_hcd and address 2
usb 5-2: configuration #1 chosen from 1 choice
hub 5-2:1.0: USB hub found
hub 5-2:1.0: 4 ports detected
sysfs: duplicate filename 'bInterfaceNumber' can not be created
WARNING: at fs/sysfs/dir.c:425 sysfs_add_one()
 [<b018bebc>] sysfs_add_one+0x54/0xb8
 [<b018ba00>] sysfs_add_file+0x42/0x6a
 [<b018d115>] sysfs_create_group+0x84/0xe7
 [<b0206f3f>] device_add+0x454/0x45e
 [<f88ca72a>] usb_create_sysfs_intf_files+0x24/0x98 [usbcore]
 [<f88c7295>] usb_set_configuration+0x48f/0x4a9 [usbcore]
 [<f88cdcdb>] generic_probe+0x50/0x91 [usbcore]
 [<f88c8784>] usb_probe_device+0x32/0x37 [usbcore]
 [<b020857e>] driver_probe_device+0xc5/0x148
 [<b02890a5>] klist_next+0x58/0x6d
 [<b0207aa8>] bus_for_each_drv+0x35/0x5c
 [<b020867f>] device_attach+0x5e/0x72
 [<b0208601>] __device_attach+0x0/0x5
 [<b0207a24>] bus_attach_device+0x26/0x75
 [<b0206d92>] device_add+0x2a7/0x45e
 [<f88c2c1a>] usb_new_device+0x4d/0x8a [usbcore]
 [<f88c3746>] hub_thread+0x702/0xa8f [usbcore]
 [<b012fd84>] autoremove_wake_function+0x0/0x33
 [<f88c3044>] hub_thread+0x0/0xa8f [usbcore]
 [<b012fcb7>] kthread+0x38/0x5d
 [<b012fc7f>] kthread+0x0/0x5d
 [<b0104abb>] kernel_thread_helper+0x7/0x10
 =======================
(...)

This one is probably 2.6.23.
After some time the system continued to boot, but without network interface.
So marked it as bad.
The newer bisect failed to compile. Marked it bad. Bisect again,
failed, again, failed :-(
My git-bisect log is:

git-bisect start
# good: [62d0cfcb27cf755cebdc93ca95dabc83608007cd] Linux 2.6.20
git-bisect good 62d0cfcb27cf755cebdc93ca95dabc83608007cd
# bad: [3925e6fc1f774048404fdd910b0345b06c699eb4] Merge branch
'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6
git-bisect bad 3925e6fc1f774048404fdd910b0345b06c699eb4
# bad: [3749c66c67fb5c257771815c186bc32290cacf44] Merge branch
'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/avi/kvm
git-bisect bad 3749c66c67fb5c257771815c186bc32290cacf44
# bad: [b11115c15351faba978ce1b9e75068e77f6ef48d] serial_core.h:
include <linux/sysrq.h>
git-bisect bad b11115c15351faba978ce1b9e75068e77f6ef48d
# bad: [1936502d00ae6c2aa3931c42f6cf54afaba094f2] [NET_SCHED] qdisc:
avoid transmit softirq on watchdog wakeup
git-bisect bad 1936502d00ae6c2aa3931c42f6cf54afaba094f2

What else can I do, please?

Thank you very much!

Best regards,
Nelson
