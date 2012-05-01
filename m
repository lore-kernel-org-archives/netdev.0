From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Tue, 1 May 2012 18:24:05 +0200
Message-ID: <20120501182405.3dda59b9@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:51581 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab2EAQYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 12:24:10 -0400
Received: from stein ([83.221.231.67])
	(authenticated bits=0)
	by einhorn.in-berlin.de (8.13.6/8.13.6/Debian-1) with ESMTP id q41GO7Fg007462
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 1 May 2012 18:24:08 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I switched from 3.3 to 3.4-rc5 yesterday and am getting the following warning
some time after boot (e.g. this time about two hours after boot).  What's up
with that?

May  1 15:08:35 stein kernel: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x16b/0x20f()
May  1 15:08:35 stein kernel: Hardware name: System Product Name
May  1 15:08:35 stein kernel: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
May  1 15:08:35 stein kernel: Modules linked in: usb_storage snd_isight snd_firewire_lib firewire_ohci firewire_core crc_itu_t cpufreq_ondemand hwmon_vid nfsd lockd sunrpc ext4 jbd2 crc16 sr_mod cdrom snd_hda_codec_realtek powernow_k8 freq_table mperf yenta_socket k10temp pcmcia_core pcmcia_rsrc pata_atiixp sg snd_hda_intel snd_hda_codec snd_pcm snd_timer snd snd_page_alloc processor r8169 mii
May  1 15:08:35 stein kernel: Pid: 0, comm: swapper/3 Not tainted 3.4.0-rc5 #4
May  1 15:08:35 stein kernel: Call Trace:
May  1 15:08:35 stein kernel: <IRQ>  [<ffffffff8102562d>] ? warn_slowpath_common+0x78/0x8c
May  1 15:08:35 stein kernel: [<ffffffff810256e2>] ? warn_slowpath_fmt+0x45/0x4a
May  1 15:08:35 stein kernel: [<ffffffff810174c4>] ? lapic_next_event+0x18/0x1f
May  1 15:08:35 stein kernel: [<ffffffff812c2040>] ? dev_watchdog+0x16b/0x20f
May  1 15:08:35 stein kernel: [<ffffffff8103da4c>] ? hrtimer_interrupt+0x100/0x19b
May  1 15:08:35 stein kernel: [<ffffffff8102e3a8>] ? run_timer_softirq+0x177/0x209
May  1 15:08:35 stein kernel: [<ffffffff8104e201>] ? clockevents_program_event+0xaa/0xce
May  1 15:08:35 stein kernel: [<ffffffff812c1ed5>] ? qdisc_reset+0x35/0x35
May  1 15:08:35 stein kernel: [<ffffffff8102a122>] ? __do_softirq+0x7f/0x106
May  1 15:08:35 stein kernel: [<ffffffff8131750c>] ? call_softirq+0x1c/0x30
May  1 15:08:35 stein kernel: [<ffffffff810034ea>] ? do_softirq+0x31/0x67
May  1 15:08:35 stein kernel: [<ffffffff8102a3cf>] ? irq_exit+0x44/0xae
May  1 15:08:35 stein kernel: [<ffffffff8100322b>] ? do_IRQ+0x94/0xad
May  1 15:08:35 stein kernel: [<ffffffff81315c67>] ? common_interrupt+0x67/0x67
May  1 15:08:35 stein kernel: <EOI>  [<ffffffff81008a6c>] ? default_idle+0x20/0x34
May  1 15:08:35 stein kernel: [<ffffffff81008b46>] ? amd_e400_idle+0xc6/0xe2
May  1 15:08:35 stein kernel: [<ffffffff810092c6>] ? cpu_idle+0x62/0x86
May  1 15:08:35 stein kernel: ---[ end trace 11b2855a75e24d28 ]---
May  1 15:08:35 stein kernel: r8169 0000:0b:00.0: eth0: link up

The "link up" message occurs several times per session.

(booted on Apr 30 20:38:16)
Apr 30 20:38:17 stein kernel: r8169 0000:0b:00.0: eth0: link up
Apr 30 23:57:36 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 01:57:46 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 04:20:21 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 04:28:57 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 06:11:35 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 06:13:59 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 07:51:58 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 08:14:56 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 08:15:20 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 08:16:08 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 08:26:20 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 08:35:04 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 08:46:00 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 08:50:24 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 08:57:48 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 09:07:26 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 10:33:23 stein kernel: r8169 0000:0b:00.0: eth0: link up

(booted on May  1 12:47:45)
May  1 12:47:46 stein kernel: r8169 0000:0b:00.0: eth0: link up
May  1 15:08:35 stein kernel: r8169 0000:0b:00.0: eth0: link up

I do not remember such messages from any earlier kernel.

There are no noticeable issues, but I don't run anything demanding on the
interface right now which would make any downtime obvious.

It is an RTL8168(?) on an Asus M3A78-EM motherboard.

-[0000:00]-+-00.0  Advanced Micro Devices [AMD] RS780 Host Bridge [1022:9600]
           +-01.0-[01]--+-05.0  Advanced Micro Devices [AMD] nee ATI RS780 [Radeon HD 3200] [1002:9610]
           |            \-05.1  Advanced Micro Devices [AMD] nee ATI RS780 HDMI Audio [Radeon HD 3000-3300 Series] [1002:960f]
           +-02.0-[02-07]----00.0-[03-07]--+-01.0-[04]----00.0  Agere Systems FW643 PCI Express 1394b Controller (PHY/Link) [11c1:5901]
           |                               +-02.0-[05]----00.0  Agere Systems FW643 PCI Express 1394b Controller (PHY/Link) [11c1:5901]
           |                               +-03.0-[06]--
           |                               \-04.0-[07]--
           +-04.0-[08-09]----00.0-[09]----00.0  Texas Instruments XIO2213A/B/XIO2221 IEEE-1394b OHCI Controller [Cheetah Express] [104c:823f]
           +-05.0-[0a]----00.0  JMicron Technology Corp. IEEE 1394 Host Controller [197b:2380]
           +-06.0-[0b]----00.0  Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller [10ec:8168]
           +-11.0  Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode] [1002:4391]
           +-12.0  Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 USB OHCI0 Controller [1002:4397]
           +-12.1  Advanced Micro Devices [AMD] nee ATI SB7x0 USB OHCI1 Controller [1002:4398]
           +-12.2  Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 USB EHCI Controller [1002:4396]
           +-13.0  Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 USB OHCI0 Controller [1002:4397]
           +-13.1  Advanced Micro Devices [AMD] nee ATI SB7x0 USB OHCI1 Controller [1002:4398]
           +-13.2  Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 USB EHCI Controller [1002:4396]
           +-14.0  Advanced Micro Devices [AMD] nee ATI SBx00 SMBus Controller [1002:4385]
           +-14.1  Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 IDE Controller [1002:439c]
           +-14.2  Advanced Micro Devices [AMD] nee ATI SBx00 Azalia (Intel HDA) [1002:4383]
           +-14.3  Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 LPC host controller [1002:439d]
           +-14.4-[0c-10]----06.0  Ricoh Co Ltd RL5c475 [1180:0475]
           +-14.5  Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 USB OHCI2 Controller [1002:4399]
           +-18.0  Advanced Micro Devices [AMD] Family 10h Processor HyperTransport Configuration [1022:1200]
           +-18.1  Advanced Micro Devices [AMD] Family 10h Processor Address Map [1022:1201]
           +-18.2  Advanced Micro Devices [AMD] Family 10h Processor DRAM Controller [1022:1202]
           +-18.3  Advanced Micro Devices [AMD] Family 10h Processor Miscellaneous Control [1022:1203]
           \-18.4  Advanced Micro Devices [AMD] Family 10h Processor Link Control [1022:1204]

-- 
Stefan Richter
-=====-===-- -=-= ----=
http://arcgraph.de/sr/
