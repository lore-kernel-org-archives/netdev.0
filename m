From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14798] New: Realtek 8112L Ethernet controller
 is not initialized
Date: Wed, 16 Dec 2009 16:05:00 -0800
Message-ID: <20091216160500.fc09a7c3.akpm@linux-foundation.org>
References: <bug-14798-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	alust@alust.homeunix.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52316 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751093AbZLQAFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 19:05:34 -0500
In-Reply-To: <bug-14798-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 13 Dec 2009 16:11:05 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14798
> 
>            Summary: Realtek 8112L Ethernet controller is not initialized
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.32
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: alust@alust.homeunix.com
>         Regression: No
> 
> 
> Hi,
> 
> I have a PC with ASUS P755D LE motherboard. This MB contains Realtek 8112L
> Gigabit LAN controller which I believe is governed by r8169 driver.
> 
> lspci detects this controller as follows:
> 02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI
> Express Gigabit Ethernet controller (rev 03)
>     Subsystem: ASUSTeK Computer Inc. Device 83a3
>     Flags: bus master, fast devsel, latency 0, IRQ 36
>     I/O ports at c800 [size=256]
>     Memory at f6fff000 (64-bit, prefetchable) [size=4K]
>     Memory at f6ff8000 (64-bit, prefetchable) [size=16K]
>     Expansion ROM at fbcf0000 [disabled] [size=64K]
>     Capabilities: [40] Power Management version 3
>     Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0
> Enable+
>     Capabilities: [70] Express Endpoint, MSI 01
>     Capabilities: [ac] MSI-X: Enable- Mask- TabSize=4
>     Capabilities: [cc] Vital Product Data <?>
>     Capabilities: [100] Advanced Error Reporting <?>
>     Capabilities: [140] Virtual Channel <?>
>     Capabilities: [160] Device Serial Number 00-00-00-00-00-00-00-00
>     Kernel driver in use: r8169
>     Kernel modules: r8169
> 
> However my hand-made amd64 kernel couldn't initialize this controller with this
> error:
> 
> [    6.284837] ------------[ cut here ]------------
> [    6.284892] kernel BUG at net/core/dev.c:5219!
> [    6.284947] invalid opcode: 0000 [#1] SMP 
> [    6.285070] last sysfs file:
> /sys/devices/pci0000:00/0000:00:1c.7/0000:02:00.0/firmware/0000:02:00.0/loading
> [    6.285146] CPU 2 
> [    6.285230] Modules linked in: r8169(+) snd_hda_codec_via jmicron(+) tulip
> i2c_i801 evdev via_rhine mii psmouse pcspkr i2c_core ide_core bitrev
> snd_hda_intel crc32 snd_hda_codec ehci_hcd snd_pcm snd_timer snd soundcore
> snd_page_alloc thermal processor thermal_sys hwmon button
> [    6.286322] Pid: 865, comm: modprobe Not tainted 2.6.32 #1 System Product
> Name
> [    6.286393] RIP: 0010:[<ffffffff811e4f78>]  [<ffffffff811e4f78>]
> free_netdev+0xc9/0xeb
> [    6.286504] RSP: 0018:ffff88013dadbc68  EFLAGS: 00010293
> [    6.286560] RAX: 0000000000000001 RBX: ffff88013f3da000 RCX:
> ffff88013f3da060
> [    6.286619] RDX: ffff88013f3da060 RSI: ffffffff811e3bf7 RDI:
> ffff88013f3da020
> [    6.286678] RBP: ffff88013dadbc88 R08: 0000000000000000 R09:
> ffff88013fc07200
> [    6.286736] R10: ffff88013fc07200 R11: ffff88013dadbb28 R12:
> ffff88013f3da020
> [    6.286795] R13: ffff88013f3da060 R14: ffffc9000067e000 R15:
> 00000000fffffffe
> [    6.286854] FS:  00007f5ed6bc76f0(0000) GS:ffff880028240000(0000)
> knlGS:0000000000000000
> [    6.286927] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [    6.286984] CR2: 00007f58fcd5a470 CR3: 000000013d15e000 CR4:
> 00000000000006e0
> [    6.287043] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [    6.287102] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [    6.287161] Process modprobe (pid: 865, threadinfo ffff88013dada000, task
> ffff88013d89a600)
> [    6.291267] Stack:
> [    6.291317]  ffff88013dadbc88 ffff88013f3da580 ffff88013f3da000
> ffff88013ec00800
> [    6.291480] <0> ffff88013dadbd28 ffffffffa00f0616 ffff880100000018
> ffff8801000000f1
> [    6.291723] <0> ffff880100000086 ffff8801000000c5 ffff8801083000c0
> ffff880100000024
> [    6.292014] Call Trace:
> [    6.292069]  [<ffffffffa00f0616>] rtl8169_init_one+0x930/0x944 [r8169]
> [    6.292129]  [<ffffffff8112dccf>] local_pci_probe+0x12/0x16
> [    6.292187]  [<ffffffff8112df53>] pci_device_probe+0xc2/0xf2
> [    6.292245]  [<ffffffff8117ef98>] ? driver_sysfs_add+0x47/0x6c
> [    6.292303]  [<ffffffff8117f0d0>] driver_probe_device+0x9a/0x11f
> [    6.292361]  [<ffffffff8117f1ad>] __driver_attach+0x58/0x7c
> [    6.292418]  [<ffffffff8117f155>] ? __driver_attach+0x0/0x7c
> [    6.292476]  [<ffffffff8117e95f>] bus_for_each_dev+0x4e/0x83
> [    6.292533]  [<ffffffff8117ef4f>] driver_attach+0x19/0x1b
> [    6.292590]  [<ffffffff8117e2f7>] bus_add_driver+0xb8/0x204
> [    6.292648]  [<ffffffff8117f470>] driver_register+0x98/0x109
> [    6.292705]  [<ffffffff8112e18c>] __pci_register_driver+0x53/0xc3
> [    6.292764]  [<ffffffffa00f6000>] ? rtl8169_init_module+0x0/0x20 [r8169]
> [    6.292824]  [<ffffffffa00f601e>] rtl8169_init_module+0x1e/0x20 [r8169]
> [    6.292884]  [<ffffffff8100905f>] do_one_initcall+0x59/0x149
> [    6.292942]  [<ffffffff8105a6e0>] sys_init_module+0xd1/0x231
> [    6.293000]  [<ffffffff8100ae2b>] system_call_fastpath+0x16/0x1b
> [    6.293057] Code: 8d 47 40 49 39 c5 75 e6 8b 83 b0 03 00 00 85 c0 75 14 0f
> b7 bb 58 01 00 00 48 29 fb 48 89 df e8 b5 81 ea ff eb 1f 83 f8 03 74 04 <0f> 0b
> eb fe c7 83 b0 03 00 00 04 00 00 00 48 8d bb e8 03 00 00 
> [    6.295394] RIP  [<ffffffff811e4f78>] free_netdev+0xc9/0xeb
> [    6.295485]  RSP <ffff88013dadbc68>
> [    6.295549] ---[ end trace 7a81e56fccc25aa4 ]---
> 
> The full dmesg output and .config used to compile the kernel attached.
> 

free_netdev() died in

	BUG_ON(dev->reg_state != NETREG_UNREGISTERED);


