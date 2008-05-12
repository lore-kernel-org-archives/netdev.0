From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Mon, 12 May 2008 18:10:20 +0200
Message-ID: <BAY103-DAV20B0EEFFB30A41A8020C8B2CC0@phx.gbl>
References: <E1Jrtxr-0004in-00@gondolin.me.apana.org.au> <BAY103-DAV594320AC93E33D7335927B2DA0@phx.gbl> <BAY103-DAV122A113843FE9574256A0AB2D60@phx.gbl> <BAY103-DAV6446AEC1CBB678E5D0E52B2D30@phx.gbl> <20080509102509.GA11710@gondor.apana.org.au> <BAY103-DAV5B5CD83FC6A95A5DD48C9B2CC0@phx.gbl> <20080512074642.GA1416@gondor.apana.org.au> <BAY103-DAV521435E26209347B7646FB2CC0@phx.gbl> <BAY103-DAV2A04E519F35401C98403FB2CC0@phx.gbl>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s20.bay0.hotmail.com ([65.54.246.220]:26785 "EHLO
	bay0-omc3-s20.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752576AbYELQM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 12:12:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi wrote:

> Marco Berizzi wrote:
>
> > Herbert Xu wrote:
> >
> > > On Mon, May 12, 2008 at 09:14:54AM +0200, Marco Berizzi wrote:
> > > >
> > > > PS: linux version shown by dmesg is 2.6.24 but it
> > > > is the results of 'git bisect good v2.6.24' and
> > > > 'git bisect bad v2.6.25'
> > >
> > > So what's the changeset hash for the source that produced this
> > > kernel?
> >
> > root@Calimero:/tmp/GIT/herbert# git bisect good v2.6.24
> > You need to start by "git bisect start"
> > Do you want me to do it for you [Y/n]? Y
> > root@Calimero:/tmp/GIT/herbert# git bisect bad v2.6.25
> > Bisecting: 6353 revisions left to test after this
> > [dd5f5fed6c9458a7aa81eeef3732cc3a9891cfdf] Merge branch 'audit.b46'
of
> > git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current
> >
> > Then I have copied from 2.6.25 two files:
> >
> > net/ipv4/xfrm4_tunnel.c and ipcomp.c because
> > of these bugs:
> >
> >
>
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.24.y.git;a=commit;h=11b47c8828d4cd1df21636719603784ec5e26067
> >
>
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.24.y.git;a=commit;h=363c11d7e1c2b2cc30e33416a518cea5ef9e0cc8
> >
>
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.24.y.git;a=commit;h=cefe34bea77e194fd6b6a7a062e1620af2eef69f
> >
> > and finally I have run 'make menuconfig' and
> > 'make bzImage modules modules_install'
>
> ok, I have git bisected again:
>
> root@Calimero:/tmp/GIT/herbert# git bisect bad
> Bisecting: 3176 revisions left to test after this
> [fde3571fd8613483f1203d11394ae316c6b79a03] iwlwifi: avoid firmware
> command sending if rfkill is enabled
>
> and then copied always the two files from 2.6.25
> xfrm4_tunnel.c and ipcomp.c
>
> now this kernel is up for 4 hours (at least it
> doesn't crash at startup)
> I will keep you updated.
> Thanks for the feedback Herbert.

NAK: it crashed after 4 hours and few minutes with
this message:

BUG: unable to handle kernel paging request at virtual address 6b6b6b6f
printing eip: ca8931be *pde = 00000000
Oops: 0002 [#1]
Modules linked in: netconsole sch_sfq sch_htb cls_fw nf_nat_pptp
nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp
nf_conntrack_ftp 3c59x mii
Pid: 881, comm: squid Not tainted (2.6.24 #1)
EIP: 0060:[<ca8931be>] EFLAGS: 00010203 CPU: 0
EIP is at sfq_dequeue+0x6e/0x1f0 [sch_sfq]
EAX: 6b6b6b6b EBX: c91d0d14 ECX: c91d0d08 EDX: 000005e8
ESI: c91d0080 EDI: c559c540 EBP: c91d0000 ESP: c9149e9c
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process squid (pid: 881, ti=c9148000 task=c9fbd020 task.ti=c9148000)
Stack: c559c540 7e0039c1 00000000 fffffffe c913ed20 00000000 ca89b146
c905b468
       c2468012 c9e3d840 00000282 c905b388 00000282 000005ea 00000000
c905b168
       c905b288 000006e0 c905b060 00000000 c905b0e0 00000007 5c9a608b
00000003
Call Trace:
 [<ca89b146>] htb_dequeue+0x226/0x860 [sch_htb]
 [<c028189b>] dev_hard_start_xmit+0x1cb/0x230
 [<c0290bf5>] __qdisc_run+0xd5/0x130
 [<c0283129>] net_tx_action+0x39/0xd0
 [<c0283129>] net_tx_action+0x39/0xd0
 [<c0283177>] net_tx_action+0x87/0xd0
 [<c0118ad2>] __do_softirq+0x42/0x90
 [<c0118b46>] do_softirq+0x26/0x30
 [<c0104a9a>] do_IRQ+0x4a/0x80
 [<c0154891>] sys_read+0x41/0x70
 [<c010303f>] common_interrupt+0x23/0x28
 =======================
Code: 8d 14 85 00 00 00 00 8d 8c 16 a0 06 00 00 8b 41 0c 8d 59 0c 39 d8
89 04 24 0f 84 72 01 00 00 8b 3c 24 8b 07 ff 8c 16 b4 06 00 00 <89> 58
04 89 41 0c c7 47 04 00 00 00 00 c7 07 00 00 00 00 0f b6
EIP: [<ca8931be>] sfq_dequeue+0x6e/0x1f0 [sch_sfq] SS:ESP 0068:c9149e9c
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 5 seconds..Linux version 2.6.24 (root@Calimero) (gcc
version 4.2.3) #1 Mon May 12 11:12:56 CEST 2008
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000dc000 - 00000000000e0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000000a000000 (usable)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
160MB LOWMEM available.
Entering add_active_range(0, 0, 40960) 0 entries of 256 used
Zone PFN ranges:
  DMA             0 ->     4096
  Normal       4096 ->    40960
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    0:        0 ->    40960
On node 0 totalpages: 40960
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 4064 pages, LIFO batch:0
  Normal zone: 288 pages used for memmap
  Normal zone: 36576 pages, LIFO batch:7
  Movable zone: 0 pages used for memmap
DMI 2.1 present.
ACPI: DMI detected: Hewlett-Packard
Allocating PCI resources starting at 10000000 (gap: 0a000000:f5ff0000)
Built 1 zonelists in Zone order, mobility grouping on.  Total pages:
40640
Kernel command line: auto BOOT_IMAGE=Linux ro root=301 slub_debug
Local APIC disabled by BIOS -- you can enable it with "lapic"
mapped APIC to ffffb000 (01141000)
Enabling fast FPU save and restore... done.
Initializing CPU#0
PID hash table entries: 1024 (order: 10, 4096 bytes)
Detected 267.281 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
Memory: 158956k/163840k available (2010k kernel code, 4452k reserved,
606k data, 160k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffb5000 - 0xfffff000   ( 296 kB)
    vmalloc : 0xca800000 - 0xfffb3000   ( 855 MB)
    lowmem  : 0xc0000000 - 0xca000000   ( 160 MB)
      .init : 0xc0392000 - 0xc03ba000   ( 160 kB)
      .data : 0xc02f687e - 0xc038e280   ( 606 kB)
      .text : 0xc0100000 - 0xc02f687e   (2010 kB)
Checking if this processor honours the WP bit even in supervisor mode...
Ok.
SLUB: Genslabs=11, HWalign=32, Order=0-1, MinObjects=4, CPUs=1, Nodes=1
Calibrating delay using timer specific routine.. 535.28 BogoMIPS
(lpj=1070570)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: 0183f9ff 00000000 00000000 00000000
00000000 00000000 00000000 00000000
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: After all inits, caps: 0183f9ff 00000000 00000000 00000040 00000000
00000000 00000000 00000000
Compat vDSO mapped to ffffe000.
CPU: Intel Celeron (Covington) stepping 00
Checking 'hlt' instruction... OK.
Freeing SMP alternatives: 0k freed
ACPI: Core revision 20070126
ACPI Exception (tbxface-0629): AE_NO_ACPI_TABLES, While loading
namespace from ACPI tables [20070126]
ACPI: Unable to load the System Description Tables
net_namespace: 128 bytes
NET: Registered protocol family 16
PCI: PCI BIOS revision 2.10 entry at 0xfda61, last bus=1
PCI: Using configuration type 1
Setting up standard PCI resources
ACPI: Interpreter disabled.
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI: disabled
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
* Found PM-Timer Bug on the chipset. Due to workarounds for a bug,
* this clock source is slow. Consider trying other clock sources
PCI quirk: region 6100-613f claimed by PIIX4 ACPI
PCI quirk: region 5f00-5f0f claimed by PIIX4 SMB
PCI: Using IRQ router PIIX/ICH [8086/7110] at 0000:00:07.0
Time: tsc clocksource has been installed.
PCI: Bridge: 0000:00:01.0
  IO window: b000-bfff
  MEM window: efe00000-efefffff
  PREFETCH window: e5c00000-e7cfffff
NET: Registered protocol family 2
IP route cache hash table entries: 2048 (order: 1, 8192 bytes)
TCP established hash table entries: 8192 (order: 4, 65536 bytes)
TCP bind hash table entries: 8192 (order: 3, 32768 bytes)
TCP: Hash tables configured (established 8192 bind 8192)
TCP reno registered
SGI XFS with no debug enabled
io scheduler noop registered (default)
Limiting direct PCI/PCI transfers.
Boot video device is 0000:01:00.0
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with
idebus=xx
PIIX4: IDE controller (0x8086:0x7111 rev 0x01) at  PCI slot 0000:00:07.1
PIIX4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xffa0-0xffa7, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0xffa8-0xffaf, BIOS settings: hdc:DMA, hdd:pio
Probing IDE interface ide0...
hda: QUANTUM FIREBALL EX3.2A, ATA DISK drive
hda: host max PIO4 wanted PIO255(auto-tune) selected PIO4
hda: UDMA/33 mode selected
Probing IDE interface ide1...
hdc: CRD-8160B, ATAPI CD/DVD-ROM drive
hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO4
hdc: MWDMA2 mode selected
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
ide1 at 0x170-0x177,0x376 on irq 15
hda: max request size: 128KiB
hda: 6306048 sectors (3228 MB) w/418KiB Cache, CHS=6256/16/63
hda: cache flushes not supported
 hda: hda1 hda2 < hda5 hda6 hda7 hda8 hda9 >
PNP: No PS/2 controller found. Probing ports directly.
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
nf_conntrack version 0.5.0 (3072 buckets, 12288 max)
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
NET: Registered protocol family 15
Using IPI Shortcut mode
input: AT Translated Set 2 keyboard as
/devices/platform/i8042/serio0/input/input0
Filesystem "hda1": Disabling barriers, not supported by the underlying
device
XFS mounting filesystem hda1
Starting XFS recovery on filesystem: hda1 (logdev: internal)
Ending XFS recovery on filesystem: hda1 (logdev: internal)
VFS: Mounted root (xfs filesystem) readonly.
Freeing unused kernel memory: 160k freed
Adding 330584k swap on /dev/hda9.  Priority:-1 extents:1 across:330584k
Filesystem "hda1": Disabling barriers, not supported by the underlying
device
Filesystem "hda1": Disabling barriers, not supported by the underlying
device
PCI: setting IRQ 10 as level-triggered
PCI: Found IRQ 10 for device 0000:00:09.0
3c59x: Donald Becker and others.
0000:00:09.0: 3Com PCI 3c905 Boomerang 100baseTx at 0001dc00.
PCI: setting IRQ 11 as level-triggered
PCI: Found IRQ 11 for device 0000:00:0a.0
0000:00:0a.0: 3Com PCI 3c905 Boomerang 100baseTx at 0001da00.
PCI: setting IRQ 9 as level-triggered
PCI: Found IRQ 9 for device 0000:00:0b.0
PCI: Sharing IRQ 9 with 0000:00:07.2
0000:00:0b.0: 3Com PCI 3c905 Boomerang 100baseTx at 0001d800.
netconsole: local port 6665
netconsole: local IP 85.32.35.30
netconsole: interface eth0
netconsole: remote port 6666
netconsole: remote IP 80.204.235.230
netconsole: remote ethernet address 00:1b:d4:0a:43:d0
netconsole: device eth0 not up yet, forcing it
eth0:  setting full-duplex.
netconsole: carrier detect appears untrustworthy, waiting 4 seconds
console [netcon0] enabled
netconsole: network logging started
Filesystem "hda5": Disabling barriers, not supported by the underlying
device
XFS mounting filesystem hda5
Starting XFS recovery on filesystem: hda5 (logdev: internal)
Ending XFS recovery on filesystem: hda5 (logdev: internal)
Filesystem "hda6": Disabling barriers, not supported by the underlying
device
XFS mounting filesystem hda6
Starting XFS recovery on filesystem: hda6 (logdev: internal)
Ending XFS recovery on filesystem: hda6 (logdev: internal)
Filesystem "hda7": Disabling barriers, not supported by the underlying
device
XFS mounting filesystem hda7
Ending clean XFS mount for filesystem: hda7
Filesystem "hda8": Disabling barriers, not supported by the underlying
device
XFS mounting filesystem hda8
Starting XFS recovery on filesystem: hda8 (logdev: internal)
Ending XFS recovery on filesystem: hda8 (logdev: internal)


