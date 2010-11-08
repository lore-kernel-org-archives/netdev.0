From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 22142] New: skge module doesn't work in
 2.6.37-rc1
Date: Mon, 8 Nov 2010 15:43:06 -0800
Message-ID: <20101108154306.0f93eddb.akpm@linux-foundation.org>
References: <bug-22142-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	jtmettala@gmail.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50390 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755890Ab0KHXnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 18:43:31 -0500
In-Reply-To: <bug-22142-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 5 Nov 2010 23:14:21 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=22142
> 
>            Summary: skge module doesn't work in 2.6.37-rc1
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.37-rc1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: jtmettala@gmail.com
>         Regression: Yes
> 
> 
> Here is original report.
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/670955
> 
> I hope attached file has enough information. It has a trace.
> 

skge_devinit() did a nearly-NULL deref.

[    8.521324] Intel ICH 0000:00:1f.5: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    8.521384] Intel ICH 0000:00:1f.5: setting latency timer to 64
[    8.683032] skge 0000:02:05.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    8.683091] skge: 1.13 addr 0xfbffc000 irq 22 chip Yukon-Lite rev 7
[    8.696044] BUG: unable to handle kernel NULL pointer dereference at 00000008
[    8.696162] IP: [<f800a215>] skge_devinit+0x1a5/0x210 [skge]
[    8.696246] *pde = 00000000 
[    8.696320] Oops: 0002 [#1] SMP 
[    8.696425] last sysfs file: /sys/devices/pci0000:00/0000:00:1d.1/usb3/3-1/3-1:1.0/input/input4/mouse1/uevent
[    8.696478] Modules linked in: skge(+) i2c_algo_bit joydev snd_mpu401 snd_mpu401_uart snd_seq_midi snd_intel8x0(+) usbhid hid snd_ac97_codec snd_rawmidi snd_seq_midi_event snd_seq ac97_bus snd_pcm snd_seq_device snd_timer snd_page_alloc snd ppdev firewire_sbp2 shpchp parport_pc asus_atk0110 firewire_core floppy crc_itu_t ns558 soundcore gameport psmouse serio_raw lp parport
[    8.697688] 
[    8.697730] Pid: 329, comm: modprobe Not tainted 2.6.37-2-generic #9-Ubuntu P5P800/To Be Filled By O.E.M.
[    8.697783] EIP: 0060:[<f800a215>] EFLAGS: 00010246 CPU: 0
[    8.697829] EIP is at skge_devinit+0x1a5/0x210 [skge]
[    8.697872] EAX: 00000000 EBX: f5fbb000 ECX: 00000000 EDX: 00000000
[    8.697916] ESI: f5fbb440 EDI: f5f68300 EBP: f5ff5dfc ESP: f5ff5de4
[    8.697960]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[    8.698004] Process modprobe (pid: 329, ti=f5ff4000 task=f5880000 task.ti=f5ff4000)
[    8.698054] Stack:
[    8.698093]  00000040 f5f68300 00000000 f6581000 00000000 f5f68300 f5ff5e3c f800f789
[    8.698400]  f800fdd4 f800febd fbffc000 00000000 00000016 f8010131 00000007 c0423af5
[    8.698706]  00000292 00000001 f5f68344 f6581000 f5ff5e5c f6581060 f5ff5e54 c0388937
[    8.699012] Call Trace:
[    8.699059]  [<f800f789>] ? skge_probe+0x284/0x41b [skge]
[    8.699108]  [<c0423af5>] ? pm_runtime_enable+0x45/0x70
[    8.699155]  [<c0388937>] ? local_pci_probe+0x47/0xb0
[    8.699201]  [<c0389e18>] ? pci_device_probe+0x68/0x90
[    8.699247]  [<c041cb6d>] ? really_probe+0x4d/0x150
[    8.699292]  [<c0424fab>] ? pm_runtime_barrier+0x4b/0xb0
[    8.699337]  [<c041ce0c>] ? driver_probe_device+0x3c/0x60
[    8.699383]  [<c041ceb1>] ? __driver_attach+0x81/0x90
[    8.699428]  [<c041ce30>] ? __driver_attach+0x0/0x90
[    8.699473]  [<c041be98>] ? bus_for_each_dev+0x48/0x70
[    8.699518]  [<c041ca1e>] ? driver_attach+0x1e/0x20
[    8.699562]  [<c041ce30>] ? __driver_attach+0x0/0x90
[    8.699606]  [<c041c5d1>] ? bus_add_driver+0xc1/0x2c0
[    8.699652]  [<c03897c0>] ? pci_device_remove+0x0/0xf0
[    8.699697]  [<c041d0f6>] ? driver_register+0x66/0x110
[    8.699742]  [<c04fd807>] ? dmi_matches+0x47/0xb0
[    8.699787]  [<c0388ed5>] ? __pci_register_driver+0x45/0xb0
[    8.699834]  [<f802102f>] ? skge_init_module+0x2f/0x31 [skge]
[    8.699880]  [<c0101255>] ? do_one_initcall+0x35/0x170
[    8.699927]  [<f8021000>] ? skge_init_module+0x0/0x31 [skge]
[    8.699973]  [<c018807b>] ? sys_init_module+0x9b/0x1e0
[    8.700012]  [<c02252a2>] ? sys_write+0x42/0x70
[    8.700012]  [<c010309f>] ? sysenter_do_call+0x12/0x28
[    8.700012] Code: 40 04 66 89 42 04 0f b6 8b 21 01 00 00 8d 83 00 01 00 00 8b 93 78 01 00 00 e8 c8 a9 36 c8 89 d8 e8 b1 57 52 c8 8b 83 00 02 00 00 <f0> 80 48 08 01 83 c4 0c 89 d8 5b 5e 5f 5d c3 8d 74 26 00 31 d2 
[    8.700012] EIP: [<f800a215>] skge_devinit+0x1a5/0x210 [skge] SS:ESP 0068:f5ff5de4
[    8.700012] CR2: 0000000000000008
[    8.702518] ---[ end trace 997185377b275fcf ]---

