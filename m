From: Jon Povey <Jon.Povey@racelogic.co.uk>
Subject: New WARN from dm9000 since merge to 2.6.36-rc4
Date: Wed, 29 Sep 2010 11:32:49 +0100
Message-ID: <70E876B0EA86DD4BAF101844BC814DFE093EE3DF87@Cloud.RL.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Kevin Hilman <khilman@deeprootsystems.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback.mail.timico.net ([62.121.11.168]:42166 "EHLO
	fallback.mail.timico.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333Ab0I2KsY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 06:48:24 -0400
Received: from [62.121.20.91] (helo=relay.timico.net)
	by fallback.mail.timico.net with esmtp (Exim 4.69)
	(envelope-from <Jon.Povey@racelogic.co.uk>)
	id 1P0ty4-0008VM-UA
	for netdev@vger.kernel.org; Wed, 29 Sep 2010 10:32:56 +0000
Content-Class: urn:content-classes:message
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdevs,

I am working on TI DaVinci DM355 (ARM) with DM9000 ethernet, booting over DHCP+NFS.

I have been working based on 2.6.34 for a while, tried merging from 2.6.36-rc4 to look at some possible USB improvements, and get a new warning on boot.

This is on a custom board, not the EVM, but uses the same ethernet design, in the same way.
As far as I can tell the board and config are the same.
Kevin reported that he has seen this same warning on different hardware.

Given that this looks like something to do with dm9000, I tried reverting the suspicious
380fefb2d "dm9000: fix "BUG: spinlock recursion""
but that made no difference.

Any clues welcome, here's the console output with some uninteresting stuff snipped.

Linux version 2.6.36-rc4+ (jon@eroko) (gcc version 4.3.3 (Sourcery G++ Lite 2009q1-203) ) #33 PREEMPT Wed Sep 22 19:26:45 JST 2010
CPU: ARM926EJ-S [41069265] revision 5 (ARMv5TEJ), cr=00053177
CPU: VIVT data cache, VIVT instruction cache
Machine: Racelogic Video VBOX (SDPRO4)
Memory policy: ECC disabled, Data cache writeback
DaVinci dm355 variant 0x0
On node 0 totalpages: 32768
free_area_init_node: node 0, pgdat c038105c, node_mem_map c03ab000
  DMA zone: 256 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 32512 pages, LIFO batch:7
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32512
Kernel command line: console=ttyS0,115200n8 rw ip=dhcp root=/dev/nfs nfsroot=192.168.1.140:/home/jon/vidbox-gitkernel/dvnfs,nolock loglevel=8
PID hash table entries: 512 (order: -1, 2048 bytes)
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
Memory: 128MB = 128MB total
Memory: 126196k/126196k available, 4876k reserved, 0K highmem
Virtual kernel memory layout:
    vector  : 0xffff0000 - 0xffff1000   (   4 kB)
    fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
    DMA     : 0xff000000 - 0xffe00000   (  14 MB)
    vmalloc : 0xc8800000 - 0xfea00000   ( 866 MB)
    lowmem  : 0xc0000000 - 0xc8000000   ( 128 MB)
    modules : 0xbf000000 - 0xc0000000   (  16 MB)
      .init : 0xc0008000 - 0xc0026000   ( 120 kB)
      .text : 0xc0026000 - 0xc0361000   (3308 kB)
      .data : 0xc0362000 - 0xc0381960   ( 127 kB)
SLUB: Genslabs=11, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
Hierarchical RCU implementation.
        RCU-based detection of stalled CPUs is disabled.
        Verbose stalled-CPUs detection is disabled.
NR_IRQS:245
Calibrating delay loop... 134.34 BogoMIPS (lpj=671744)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 512
CPU: Testing write buffer coherency: ok
devtmpfs: initialized
DaVinci: 104 gpio irqs
...
Switching to clocksource timer0_1
NET: Registered protocol family 2
IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
TCP established hash table entries: 4096 (order: 3, 32768 bytes)
TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
TCP: Hash tables configured (established 4096 bind 4096)
TCP reno registered
UDP hash table entries: 256 (order: 0, 4096 bytes)
UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
NET: Registered protocol family 1
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
msgmni has been set to 246
...
dm9000 Ethernet Driver, V1.31
eth0: dm9000a at c8838000,c883c002 IRQ 65 MAC: 00:50:c2:68:00:10 (chip)
console [netcon0] enabled
netconsole: network logging started
...
TCP cubic registered
NET: Registered protocol family 17
rtc-m41t80 1-0068: setting system clock to 2010-09-23 02:40:56 UTC (1285209656)
eth0: link down
eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
Sending DHCP requests .
------------[ cut here ]------------
WARNING: at kernel/softirq.c:143 local_bh_enable+0x4c/0xc8()
Modules linked in:
Backtrace:
[<c002a3c8>] (dump_backtrace+0x0/0x114) from [<c0292f10>] (dump_stack+0x18/0x1c)
 r7:00000000 r6:c0040aec r5:c0319fef r4:0000008f
[<c0292ef8>] (dump_stack+0x0/0x1c) from [<c003abc4>] (warn_slowpath_common+0x54/0x6c)
[<c003ab70>] (warn_slowpath_common+0x0/0x6c) from [<c003ac00>] (warn_slowpath_null+0x24/0x2c)
 r9:00000015 r8:00000015 r7:0000015a r6:c6ffc240 r5:c786b3a0
r4:c0386860
[<c003abdc>] (warn_slowpath_null+0x0/0x2c) from [<c0040aec>] (local_bh_enable+0x4c/0xc8)
[<c0040aa0>] (local_bh_enable+0x0/0xc8) from [<c020f380>] (netif_rx+0xb0/0x21c)
 r5:c786b3a0 r4:00000000
[<c020f2d0>] (netif_rx+0x0/0x21c) from [<c01c41c4>] (dm9000_interrupt+0x1d4/0x334)
 r6:c786b000 r5:c786b3a0 r4:c6ffc240
[<c01c3ff0>] (dm9000_interrupt+0x0/0x334) from [<c006cb10>] (handle_IRQ_event+0x2c/0xfc)
[<c006cae4>] (handle_IRQ_event+0x0/0xfc) from [<c006f02c>] (handle_simple_irq+0x94/0xf4)
 r7:00000042 r6:00000041 r5:c036d728 r4:c7ad70c0
[<c006ef98>] (handle_simple_irq+0x0/0xf4) from [<c0030d5c>] (gpio_irq_handler+0xc0/0xf0)
 r7:00000042 r6:00000002 r5:00000041 r4:00000002
[<c0030c9c>] (gpio_irq_handler+0x0/0xf0) from [<c002607c>] (asm_do_IRQ+0x7c/0xa0)
[<c0026000>] (asm_do_IRQ+0x0/0xa0) from [<c0026b0c>] (__irq_svc+0x4c/0x90)
Exception stack(0xc0363f48 to 0xc0363f90)
3f40:                   00000000 0005317f 0005217f 60000013 c0362000 c0381a60
3f60: c002301c c0366840 80020ce8 41069265 80020cb4 c0363f9c 600000d3 c0363f90
3f80: c0027a4c c0027a58 60000013 ffffffff
 r5:fec48000 r4:ffffffff
[<c0027a24>] (default_idle+0x0/0x38) from [<c0027fd8>] (cpu_idle+0x78/0xe4)
[<c0027f60>] (cpu_idle+0x0/0xe4) from [<c0290940>] (rest_init+0xa8/0xc0)
 r5:c0381a60 r4:00000002
[<c0290898>] (rest_init+0x0/0xc0) from [<c00089f0>] (start_kernel+0x270/0x2c4)
 r5:c0381a60 r4:c0396584
[<c0008780>] (start_kernel+0x0/0x2c4) from [<80008034>] (0x80008034)
 r5:c0381b04 r4:00053175
---[ end trace af4a93804142fc65 ]---
, OK
IP-Config: Got DHCP answer from 192.168.1.1, my address is 192.168.1.142
IP-Config: Complete:
     device=eth0, addr=192.168.1.142, mask=255.255.255.0, gw=192.168.1.1,
     host=192.168.1.142, domain=, nis-domain=(none),
     bootserver=192.168.1.1, rootserver=192.168.1.140, rootpath=
Looking up port of RPC 100003/2 on 192.168.1.140
Looking up port of RPC 100005/1 on 192.168.1.140
VFS: Mounted root (nfs filesystem) on device 0:14.

--
Jon Povey
jon.povey@racelogic.co.uk

Racelogic is a limited company registered in England. Registered number 2743719 .
Registered Office Unit 10, Swan Business Centre, Osier Way, Buckingham, Bucks, MK18 1TB .

The information contained in this electronic mail transmission is intended by Racelogic Ltd for the use of the named individual or entity to which it is directed and may contain information that is confidential or privileged. If you have received this electronic mail transmission in error, please delete it from your system without copying or forwarding it, and notify the sender of the error by reply email so that the sender's address records can be corrected. The views expressed by the sender of this communication do not necessarily represent those of Racelogic Ltd. Please note that Racelogic reserves the right to monitor e-mail communications passing through its network


