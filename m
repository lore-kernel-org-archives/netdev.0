From: Bernd Schmidt <bernds_cb1@t-online.de>
Subject: Occasional crashes with sky2
Date: Sun, 11 Oct 2009 15:55:46 +0100
Message-ID: <4AD1F1F2.4060001@t-online.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040403010601090401030904"
Cc: Stephen Hemminger <shemminger@osdl.org>,
	shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout04.t-online.de ([194.25.134.18]:55523 "EHLO
	mailout04.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbZJKOy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2009 10:54:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040403010601090401030904
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

For a few months now, I've been seeing occasional kernel panics that
would happen every few weeks.  I'm not exactly sure when they started,
but I definitely see them in 2.6.29 and 2.6.30, and never saw them in
2.6.25 and earlier.  They happen with 32 bit and 64 bit kernels.

Today I managed to capture an oops with netconsole; it's attached.  This
seems to point towards the sky2 driver.

Some hardware information:
03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E
Gigabit Ethernet Controller (rev 20)
	Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit Ethernet
controller PCIe (Asus)
	Flags: bus master, fast devsel, latency 0, IRQ 16
	Memory at f88fc000 (64-bit, non-prefetchable) [size=16K]
	I/O ports at a800 [size=256]
	Expansion ROM at f88c0000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 2
	Capabilities: [50] Vital Product Data <?>
	Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Count=1/2
Enable-
	Capabilities: [e0] Express Legacy Endpoint, MSI 00
	Capabilities: [100] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSVoil-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSVoil-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSVoil-
		CESta:	RxErr+ BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		AERCap:	First Error Pointer: 1f, GenCap- CGenEn- ChkCap- ChkEn-
	Kernel driver in use: sky2
	Kernel modules: sky2

04:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E
Gigabit Ethernet Controller (rev 20)
	Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit Ethernet
controller PCIe (Asus)
	Flags: bus master, fast devsel, latency 0, IRQ 19
	Memory at f89fc000 (64-bit, non-prefetchable) [size=16K]
	I/O ports at b800 [size=256]
	Expansion ROM at f89c0000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 2
	Capabilities: [50] Vital Product Data <?>
	Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Count=1/2
Enable-
	Capabilities: [e0] Express Legacy Endpoint, MSI 00
	Capabilities: [100] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSVoil-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSVoil-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSVoil-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		AERCap:	First Error Pointer: 1f, GenCap- CGenEn- ChkCap- ChkEn-
	Kernel driver in use: sky2
	Kernel modules: sky2


Both of these share their IRQ with other devices:
beaker ~ # dir /proc/irq/16/
total 0
dr-xr-xr-x 2 root root 0 Oct 11 15:46 eth1
dr-xr-xr-x 2 root root 0 Oct 11 15:46 nvidia
dr-xr-xr-x 2 root root 0 Oct 11 15:46 pata_jmicron
-rw------- 1 root root 0 Oct 11 15:46 smp_affinity
-r--r--r-- 1 root root 0 Oct 11 15:46 spurious
beaker ~ # dir /proc/irq/19/
total 0
dr-xr-xr-x 2 root root 0 Oct 11 15:46 HDA Intel
dr-xr-xr-x 2 root root 0 Oct 11 15:46 eth0
-rw------- 1 root root 0 Oct 11 15:46 smp_affinity
-r--r--r-- 1 root root 0 Oct 11 15:46 spurious
dr-xr-xr-x 2 root root 0 Oct 11 15:46 uhci_hcd:usb5

azx_interrupt, which occurs in the call trace, belongs to HDA Intel.
Not sure if that's a clue.

Please let me know if you need additional information.


Bernd

--------------040403010601090401030904
Content-Type: text/plain;
 name="oops"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="oops"

sky2 eth0: hung mac 5:6 fifo 0 (166:176)
sky2 eth0: receiver hang detected
sky2 eth0: disabling interface
BUG: unable to handle kernel NULL pointer dereference at 000000000000007c
IP: [<ffffffffa07c7727>] sky2_poll+0x7e0/0xa95 [sky2]
PGD 122e28067 PUD 122c4e067 PMD 0
Oops: 0000 [#1] SMP
last sysfs file: /sys/devices/system/cpu/cpu1/cache/index2/shared_cpu_map
CPU 1
Modules linked in: loop netconsole snd_mixer_oss i2c_i801 sky2 nvidia(P) [last unloaded: loop]
Pid: 0, comm: swapper Tainted: P           2.6.30.9 #4 P5W DH Deluxe
RIP: 0010:[<ffffffffa07c7727>]  [<ffffffffa07c7727>] sky2_poll+0x7e0/0xa95 [sky2]
RSP: 0018:ffff88002803de20  EFLAGS: 00010246
RAX: ffff88013c69a000 RBX: ffff88013d287800 RCX: 0000000000000051
RDX: 0000000000000000 RSI: 00000000000000e4 RDI: ffff88013d1cb810
RBP: ffff88013d287dc0 R08: 00000000000d3d58 R09: 000000000000cf10
R10: ffff88012f3cc000 R11: ffffffff80549271 R12: 0000000000000000
R13: ffff88013d1cb800 R14: 0000000000004ad9 R15: ffff88013c484990
FS:  0000000000000000(0000) GS:ffff88002803a000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 000000000000007c CR3: 0000000122c4a000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff88013f0ca000, task ffff88013f0ab800)
Stack:
 ffffffff804ef66d ffff88013d1d5c80 ffff00003d706b30 ffff880100000001
 ffff880100000000 0000013400000000 0000004000000040 ffff88013d1cb810
 0000000000000000 0000000000000246 ffffffff804f80d6 ffff88013d1cb810
Call Trace:
 <IRQ> <0> [<ffffffff804ef66d>] ? snd_timer_interrupt+0x2d2/0x30f
 [<ffffffff804f80d6>] ? snd_pcm_period_elapsed+0x199/0x1ce
 [<ffffffff8054ab5f>] ? net_rx_action+0x9d/0x171
 [<ffffffff805362bb>] ? azx_interrupt+0x1d/0x126
 [<ffffffff80235d48>] ? __do_softirq+0xa6/0x16e
 [<ffffffffa07c6ad1>] ? sky2_intr+0x42/0x49 [sky2]
 [<ffffffff8020be3c>] ? call_softirq+0x1c/0x28
 [<ffffffff8020d60c>] ? do_softirq+0x2c/0x68
 [<ffffffff80235a56>] ? irq_exit+0x3f/0x7e
 [<ffffffff8020ced9>] ? do_IRQ+0xa5/0xbb
 [<ffffffff8020b713>] ? ret_from_intr+0x0/0xa
 <EOI> <0> [<ffffffff802117c4>] ? mwait_idle+0xaa/0xdb
 [<ffffffff80246756>] ? notifier_call_chain+0x2e/0x5b
 [<ffffffff8020a1c4>] ? cpu_idle+0x4a/0x8d
Code: 06 a1 e1 df e9 fe 01 00 00 44 89 f2 41 0f b7 c6 c1 ea 10 39 c2 75 29 48 8b 45 40 0f b7 55 50 45 0f b7 f6 48 6b d2 28 48 8b 14 02 <8a> 42 7c 44 89 72 74 83 e0 f3 83 c8 08 88 42 7c e9 c7 01 00 00
RIP  [<ffffffffa07c7727>] sky2_poll+0x7e0/0xa95 [sky2]
 RSP <ffff88002803de20>
CR2: 000000000000007c
---[ end trace 7c45029c31f5b85f ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: P      D    2.6.30.9 #4
Call Trace:
 <IRQ>  [<ffffffff805e1761>] ? panic+0x78/0x11d
 [<ffffffff8020e805>] ? oops_end+0x7f/0x8c
 [<ffffffff80220f7d>] ? no_context+0x1ea/0x1f7
 [<ffffffff8022110d>] ? __bad_area_nosemaphore+0x183/0x1a7
 [<ffffffff80295d1d>] ? pollwake+0x3c/0x43
 [<ffffffff80295d1d>] ? pollwake+0x3c/0x43
 [<ffffffff8022c5b7>] ? default_wake_function+0x0/0xe
 [<ffffffff805e3f9f>] ? page_fault+0x1f/0x30
 [<ffffffff80549271>] ? net_tx_action+0xb7/0x10a
 [<ffffffffa07c7727>] ? sky2_poll+0x7e0/0xa95 [sky2]
 [<ffffffff804ef66d>] ? snd_timer_interrupt+0x2d2/0x30f
 [<ffffffff804f80d6>] ? snd_pcm_period_elapsed+0x199/0x1ce
 [<ffffffff8054ab5f>] ? net_rx_action+0x9d/0x171
 [<ffffffff805362bb>] ? azx_interrupt+0x1d/0x126
 [<ffffffff80235d48>] ? __do_softirq+0xa6/0x16e
 [<ffffffffa07c6ad1>] ? sky2_intr+0x42/0x49 [sky2]
 [<ffffffff8020be3c>] ? call_softirq+0x1c/0x28
 [<ffffffff8020d60c>] ? do_softirq+0x2c/0x68
 [<ffffffff80235a56>] ? irq_exit+0x3f/0x7e
 [<ffffffff8020ced9>] ? do_IRQ+0xa5/0xbb
 [<ffffffff8020b713>] ? ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff802117c4>] ? mwait_idle+0xaa/0xdb
 [<ffffffff80246756>] ? notifier_call_chain+0x2e/0x5b
 [<ffffffff8020a1c4>] ? cpu_idle+0x4a/0x8d



--------------040403010601090401030904--
