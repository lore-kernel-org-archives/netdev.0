From: "George Spelvin" <linux@horizon.com>
Subject: NETDEV WATCHDOG: %s (%s): transmit queue %u timed out
Date: 22 May 2012 21:03:34 -0400
Message-ID: <20120523010334.5778.qmail@science.horizon.com>
Cc: linux@horizon.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:55420 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S933045Ab2EWBKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 21:10:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After installing a 3.4 kernel, I got the following:

------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0xe9/0x15c()
Hardware name: MS-7376
NETDEV WATCHDOG: inside (r8169): transmit queue 0 timed out
Pid: 0, comm: swapper/3 Not tainted 3.4.0-00017-g3df9c78 #152
Call Trace:
 <IRQ>  [<ffffffff81311aba>] ? dev_watchdog+0xe9/0x15c
 [<ffffffff81024499>] ? warn_slowpath_common+0x71/0x85
 [<ffffffff813119d1>] ? netif_tx_lock+0x7a/0x7a
 [<ffffffff81024511>] ? warn_slowpath_fmt+0x45/0x4a
 [<ffffffff813119be>] ? netif_tx_lock+0x67/0x7a
 [<ffffffff81311aba>] ? dev_watchdog+0xe9/0x15c
 [<ffffffff810345ab>] ? __queue_work+0x20a/0x20a
 [<ffffffff8102c908>] ? run_timer_softirq+0x17e/0x20b
 [<ffffffff81028889>] ? __do_softirq+0x80/0x102
 [<ffffffff81404b8c>] ? call_softirq+0x1c/0x30
 [<ffffffff81003044>] ? do_softirq+0x2c/0x60
 [<ffffffff81028abc>] ? irq_exit+0x3a/0x91
 [<ffffffff81002e91>] ? do_IRQ+0x81/0x97
 [<ffffffff81403327>] ? common_interrupt+0x67/0x67
 <EOI>  [<ffffffff810079d8>] ? default_idle+0x1e/0x32
 [<ffffffff81007afc>] ? amd_e400_idle+0xb7/0xd4
 [<ffffffff810081a5>] ? cpu_idle+0x58/0x98
---[ end trace 7d5a7d21f604b0d8 ]---
r8169 0000:02:00.0: inside: link up


(The 17 local patches are to the PPS subsystem and nowhere near net net/
directory.)

The system is an AND Phenom X4 processor with 8G of ECC RAM, recently rebooted with 

lspci -nn gives:

00:00.0 Host bridge [0600]: Advanced Micro Devices [AMD] nee ATI RD790 Northbridge only dual slot PCI-e_GFX and HT3 K8 part [1002:5956]
00:02.0 PCI bridge [0604]: Advanced Micro Devices [AMD] nee ATI RD790 PCI to PCI bridge (external gfx0 port A) [1002:5978]
00:05.0 PCI bridge [0604]: Advanced Micro Devices [AMD] nee ATI RD790 PCI to PCI bridge (PCI express gpp port B) [1002:597b]
00:09.0 PCI bridge [0604]: Advanced Micro Devices [AMD] nee ATI RD790 PCI to PCI bridge (PCI express gpp port E) [1002:597e]
00:12.0 SATA controller [0106]: Advanced Micro Devices [AMD] nee ATI SB600 Non-Raid-5 SATA [1002:4380]
00:13.0 USB controller [0c03]: Advanced Micro Devices [AMD] nee ATI SB600 USB (OHCI0) [1002:4387]
00:13.1 USB controller [0c03]: Advanced Micro Devices [AMD] nee ATI SB600 USB (OHCI1) [1002:4388]
00:13.2 USB controller [0c03]: Advanced Micro Devices [AMD] nee ATI SB600 USB (OHCI2) [1002:4389]
00:13.3 USB controller [0c03]: Advanced Micro Devices [AMD] nee ATI SB600 USB (OHCI3) [1002:438a]
00:13.4 USB controller [0c03]: Advanced Micro Devices [AMD] nee ATI SB600 USB (OHCI4) [1002:438b]
00:13.5 USB controller [0c03]: Advanced Micro Devices [AMD] nee ATI SB600 USB Controller (EHCI) [1002:4386]
00:14.0 SMBus [0c05]: Advanced Micro Devices [AMD] nee ATI SBx00 SMBus Controller [1002:4385] (rev 14)
00:14.1 IDE interface [0101]: Advanced Micro Devices [AMD] nee ATI SB600 IDE [1002:438c]
00:14.2 Audio device [0403]: Advanced Micro Devices [AMD] nee ATI SBx00 Azalia (Intel HDA) [1002:4383]
00:14.3 ISA bridge [0601]: Advanced Micro Devices [AMD] nee ATI SB600 PCI to LPC Bridge [1002:438d]
00:14.4 PCI bridge [0604]: Advanced Micro Devices [AMD] nee ATI SBx00 PCI to PCI Bridge [1002:4384]
00:18.0 Host bridge [0600]: Advanced Micro Devices [AMD] Family 10h Processor HyperTransport Configuration [1022:1200]
00:18.1 Host bridge [0600]: Advanced Micro Devices [AMD] Family 10h Processor Address Map [1022:1201]
00:18.2 Host bridge [0600]: Advanced Micro Devices [AMD] Family 10h Processor DRAM Controller [1022:1202]
00:18.3 Host bridge [0600]: Advanced Micro Devices [AMD] Family 10h Processor Miscellaneous Control [1022:1203]
00:18.4 Host bridge [0600]: Advanced Micro Devices [AMD] Family 10h Processor Link Control [1022:1204]
01:00.0 VGA compatible controller [0300]: Advanced Micro Devices [AMD] nee ATI RV370 5B60 [Radeon X300 (PCIE)] [1002:5b60]
01:00.1 Display controller [0380]: Advanced Micro Devices [AMD] nee ATI RV370 [Radeon X300SE] [1002:5b70]
02:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller [10ec:8168] (rev 01)
03:00.0 RAID bus controller [0104]: Promise Technology, Inc. PDC42819 [FastTrak TX2650/TX4650] [105a:3f20]
04:00.0 FireWire (IEEE 1394) [0c00]: VIA Technologies, Inc. VT6306/7/8 [Fire II(M)] IEEE 1394 OHCI Controller [1106:3044] (rev c0)
04:02.0 Serial controller [0700]: Oxford Semiconductor Ltd OX16PCI954 (Quad 16950 UART) function 0 (Uart) [1415:9501]
04:02.1 Parallel controller [0701]: Oxford Semiconductor Ltd OX16PCI954 (Quad 16950 UART) function 1 (parallel port) [1415:9513]
04:03.0 PCI bridge [0604]: Digital Equipment Corporation DECchip 21152 [1011:0024] (rev 03)
05:04.0 Ethernet controller [0200]: Digital Equipment Corporation DECchip 21142/43 [1011:0019] (rev 41)
05:05.0 Ethernet controller [0200]: Digital Equipment Corporation DECchip 21142/43 [1011:0019] (rev 41)
05:06.0 Ethernet controller [0200]: Digital Equipment Corporation DECchip 21142/43 [1011:0019] (rev 41)
05:07.0 Ethernet controller [0200]: Digital Equipment Corporation DECchip 21142/43 [1011:0019] (rev 41)

The Tulip 100baseT ports are used for external and DMZ ports, while the RTL8169 is the main "inside"
gigabit network port.

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:02:00.0: irq 40 for MSI/MSI-X
r8169 0000:02:00.0: eth4: RTL8168b/8111b at 0xffffc90000020000, 00:21:85:16:51:7f, XID 18000000 IRQ 40
r8169 0000:02:00.0: eth4: jumbo features [frames: 4080 bytes, tx checksumming: ko]

It doesn't seem to be causing serious problems, but I presume the warning is there because
someone would like to know about it.
