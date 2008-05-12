From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Mon, 12 May 2008 09:14:54 +0200
Message-ID: <BAY103-DAV5B5CD83FC6A95A5DD48C9B2CC0@phx.gbl>
References: <E1Jrtxr-0004in-00@gondolin.me.apana.org.au> <BAY103-DAV594320AC93E33D7335927B2DA0@phx.gbl> <BAY103-DAV122A113843FE9574256A0AB2D60@phx.gbl> <BAY103-DAV6446AEC1CBB678E5D0E52B2D30@phx.gbl> <20080509102509.GA11710@gondor.apana.org.au>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s36.bay0.hotmail.com ([65.54.246.108]:47788 "EHLO
	bay0-omc1-s36.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754902AbYELHRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 03:17:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

> On Fri, May 09, 2008 at 11:50:00AM +0200, Marco Berizzi wrote:
> >
> > I have rebooted the two boxes with slub_debug.
> > This is the output taken with network console.
> > Herbert does it help you?
> >
> > BUG: unable to handle kernel paging request at 6b6b6b9f
>
> Unfortunately this just confirms that your skb has been freed
> prematurely because 6b is the poison value.
>
> However, it doesn't point us at the offender.
>
> Although I wonder if there might be something in netfilter that's
> freeing it since that's the only thing that could've run on your
> machine between the previous access and the crash.  I'll take
> another look.

Here is the results of the first git bisect.
The error message is different from the message
subject, so I hope will be useful for you.
Now, this box is crashing immediately after the
network stack is up.

PS: linux version shown by dmesg is 2.6.24 but it
is the results of 'git bisect good v2.6.24' and
'git bisect bad v2.6.25'

Restarting system.
machine restart
Linux version 2.6.24 (root@Calimero) (gcc version 4.2.3) #1 Fri May 9
14:39:54 CEST 2008
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000dc000 - 00000000000e0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000000a000000 (usable)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
160MB LOWMEM available.
Scan SMP from c0000000 for 1024 bytes.
Scan SMP from c009fc00 for 1024 bytes.
Scan SMP from c00f0000 for 65536 bytes.
Scan SMP from c009f800 for 1024 bytes.
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
Detected 267.285 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
Memory: 158944k/163840k available (2005k kernel code, 4464k reserved,
603k data, 176k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffb5000 - 0xfffff000   ( 296 kB)
    vmalloc : 0xca800000 - 0xfffb3000   ( 855 MB)
    lowmem  : 0xc0000000 - 0xca000000   ( 160 MB)
      .init : 0xc0390000 - 0xc03bc000   ( 176 kB)
      .data : 0xc02f557a - 0xc038c2c0   ( 603 kB)
      .text : 0xc0100000 - 0xc02f557a   (2005 kB)
Checking if this processor honours the WP bit even in supervisor
mode...Ok.
SLUB: Genslabs=11, HWalign=32, Order=0-1, MinObjects=4, CPUs=1, Nodes=1
Calibrating delay using timer specific routine.. 535.25 BogoMIPS
(lpj=1070512)
Mount-cache hash table entries: 512
CPU: L1 I cache: 16K, L1 D cache: 16K
Compat vDSO mapped to ffffe000.
CPU: Intel Celeron (Covington) stepping 00
Checking 'hlt' instruction... OK.
Freeing SMP alternatives: 0k freed
ACPI: Core revision 20070126
ACPI Exception (tbxface-0629): AE_NO_ACPI_TABLES, While loading
namespace from ACPI tables [20070126]
ACPI: Unable to load the System Description Tables
net_namespace: 448 bytes
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
Ending clean XFS mount for filesystem: hda1
VFS: Mounted root (xfs filesystem) readonly.
Freeing unused kernel memory: 176k freed
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
Ending clean XFS mount for filesystem: hda5
Filesystem "hda6": Disabling barriers, not supported by the underlying
device
XFS mounting filesystem hda6
Ending clean XFS mount for filesystem: hda6
Filesystem "hda7": Disabling barriers, not supported by the underlying
device
XFS mounting filesystem hda7
Ending clean XFS mount for filesystem: hda7
Filesystem "hda8": Disabling barriers, not supported by the underlying
device
XFS mounting filesystem hda8
Ending clean XFS mount for filesystem: hda8
BUG: unable to handle kernel NULL pointer dereference at 00000224
IP: [<c02a07d3>] ip_route_input+0x33/0xe00
Oops: 0000 [#1]
Modules linked in: netconsole sch_sfq sch_htb cls_fw nf_nat_pptp
nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp
nf_conntrack_ftp 3c59x mii

Pid: 676, comm: ldconfig Not tainted (2.6.24 #1)
EIP: 0060:[<c02a07d3>] EFLAGS: 00010202 CPU: 0
EIP is at ip_route_input+0x33/0xe00
EAX: 00000000 EBX: c50112ac ECX: 00000000 EDX: 00000040
ESI: 00000002 EDI: c907ed80 EBP: 120110ac ESP: c90c3bd4
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process ldconfig (pid: 676, ti=c90c2000 task=c906f580 task.ti=c90c2000)
Stack: 00000000 c9e111e0 c9d18840 c90c3cac c02a010d 00000002 00000000
c90c3c14
       00014001 c90c3ce8 c03de660 c907eea0 c9077b60 00000000 00000001
00000001
       00000002 00000001 00000000 120110ac 1e232055 00000000 00000000
00000000
Call Trace:
 [<c02a010d>] __ip_route_output_key+0x4ad/0x840
 [<c02a04bc>] ip_route_output_flow+0x1c/0x200
 [<c02d38db>] ip_route_me_harder+0xab/0x290
 [<c02d87e2>] reject_tg+0x232/0x400
 [<c02d85b0>] reject_tg+0x0/0x400
 [<c02d793c>] ipt_do_table+0x2bc/0x4b0
 [<c02d7bc0>] ipt_hook+0x0/0x20
 [<c02968c7>] nf_iterate+0x57/0x80
 [<c02969c8>] nf_hook_slow+0x98/0xd0
 [<c02a4440>] ip_forward_finish+0x0/0x30
 [<c02a471a>] ip_forward+0x2aa/0x320
 [<c02a4440>] ip_forward_finish+0x0/0x30
 [<c02a307b>] ip_rcv_finish+0xeb/0x310
 [<c02a2f90>] ip_rcv_finish+0x0/0x310
 [<c02a3691>] ip_rcv+0x191/0x250
 [<c02a2f90>] ip_rcv_finish+0x0/0x310
 [<c02a3500>] ip_rcv+0x0/0x250
 [<c027dfb1>] netif_receive_skb+0x1f1/0x370
 [<c02806db>] process_backlog+0x5b/0xb0
 [<c0280224>] net_rx_action+0xb4/0x140
 [<c011a642>] __do_softirq+0x42/0x90
 [<c011a6b6>] do_softirq+0x26/0x30
 [<c010560a>] do_IRQ+0x4a/0x80
 [<c0151412>] check_object+0xc2/0x210
 [<c01039a7>] common_interrupt+0x23/0x28
 [<c0152480>] kmem_cache_alloc+0x30/0xa0
 [<c015d588>] getname+0x28/0xd0
 [<c015d588>] getname+0x28/0xd0
 [<c01541ee>] do_sys_open+0x1e/0xe0
 [<c01542ec>] sys_open+0x1c/0x20
 [<c0102ffe>] syscall_call+0x7/0xb
 [<c02f0000>] rest_init+0x20/0x40
 =======================
Code: 81 ec b8 00 00 00 89 44 24 30 8b 84 24 d0 00 00 8b 54 24 30 0f b6
8c 24 cc 00 00 00 8b 70 4c 8b 42 14 80 e1 1c 89 f2 c1 e2 05 <8b> b8 24
02 00 00 89 d8 31 ea 88 4c 24 53 e8 7a dd ff ff 8b 15
EIP: [<c02a07d3>] ip_route_input+0x33/0xe00 SS:ESP 0068:c90c3bd4
Kernel panic - not syncing: Fatal exception in interrupt
Linux version 2.6.24 (root@Calimero) (gcc version 4.2.3) #1 Fri May 9
14:39:54 CEST 2008
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000dc000 - 00000000000e0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000000a000000 (usable)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
160MB LOWMEM available.
Scan SMP from c0000000 for 1024 bytes.
Scan SMP from c009fc00 for 1024 bytes.
Scan SMP from c00f0000 for 65536 bytes.
Scan SMP from c009f800 for 1024 bytes.
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
Detected 267.289 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
Memory: 158944k/163840k available (2005k kernel code, 4464k reserved,
603k data, 176k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffb5000 - 0xfffff000   ( 296 kB)
    vmalloc : 0xca800000 - 0xfffb3000   ( 855 MB)
    lowmem  : 0xc0000000 - 0xca000000   ( 160 MB)
      .init : 0xc0390000 - 0xc03bc000   ( 176 kB)
      .data : 0xc02f557a - 0xc038c2c0   ( 603 kB)
      .text : 0xc0100000 - 0xc02f557a   (2005 kB)
Checking if this processor honours the WP bit even in supervisor
mode...Ok.
SLUB: Genslabs=11, HWalign=32, Order=0-1, MinObjects=4, CPUs=1, Nodes=1
Calibrating delay using timer specific routine.. 535.28 BogoMIPS
(lpj=1070571)
Mount-cache hash table entries: 512
CPU: L1 I cache: 16K, L1 D cache: 16K
Compat vDSO mapped to ffffe000.
CPU: Intel Celeron (Covington) stepping 00
Checking 'hlt' instruction... OK.
Freeing SMP alternatives: 0k freed
ACPI: Core revision 20070126
ACPI Exception (tbxface-0629): AE_NO_ACPI_TABLES, While loading
namespace from ACPI tables [20070126]
ACPI: Unable to load the System Description Tables
net_namespace: 448 bytes
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
Freeing unused kernel memory: 176k freed
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
Ending clean XFS mount for filesystem: hda5
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
Ending clean XFS mount for filesystem: hda8
BUG: unable to handle kernel NULL pointer dereference at 00000224
IP: [<c02a07d3>] ip_route_input+0x33/0xe00
Oops: 0000 [#1]
Modules linked in: netconsole sch_sfq sch_htb nf_nat_pptp
nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp
nf_conntrack_ftp 3c59x mii

Pid: 0, comm: swapper Not tainted (2.6.24 #1)
EIP: 0060:[<c02a07d3>] EFLAGS: 00010202 CPU: 0
EIP is at ip_route_input+0x33/0xe00
EAX: 00000000 EBX: 4b0112ac ECX: 00000000 EDX: 00000040
ESI: 00000002 EDI: c90807e0 EBP: f4ee46c3 ESP: c038fc4c
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c038e000 task=c03672e0 task.ti=c038e000)
Stack: 00000000 c9e151e0 c9d08840 c038fd24 c02a010d 00000000 00000000
c038fc8c
       00000000 c038fd60 c03de660 c9080360 c9f7da80 00000000 00000001
00000001
       00000002 00000001 00000000 f4ee46c3 1e232055 00000000 00000000
00000000
Call Trace:
 [<c02a010d>] __ip_route_output_key+0x4ad/0x840
 [<c02a04bc>] ip_route_output_flow+0x1c/0x200
 [<c02d38db>] ip_route_me_harder+0xab/0x290
 [<c02d87e2>] reject_tg+0x232/0x400
 [<c02d85b0>] reject_tg+0x0/0x400
 [<c02d793c>] ipt_do_table+0x2bc/0x4b0
 [<c02d7bc0>] ipt_hook+0x0/0x20
 [<c02968c7>] nf_iterate+0x57/0x80
 [<c02969c8>] nf_hook_slow+0x98/0xd0
 [<c02a4440>] ip_forward_finish+0x0/0x30
 [<c02a471a>] ip_forward+0x2aa/0x320
 [<c02a4440>] ip_forward_finish+0x0/0x30
 [<c02a307b>] ip_rcv_finish+0xeb/0x310
 [<c02a2f90>] ip_rcv_finish+0x0/0x310
 [<c02a3691>] ip_rcv+0x191/0x250
 [<c02a2f90>] ip_rcv_finish+0x0/0x310
 [<c02a3500>] ip_rcv+0x0/0x250
 [<c027dfb1>] netif_receive_skb+0x1f1/0x370
 [<c02806db>] process_backlog+0x5b/0xb0
 [<c0280224>] net_rx_action+0xb4/0x140
 [<c011a642>] __do_softirq+0x42/0x90
 [<c011a6b6>] do_softirq+0x26/0x30
 [<c010560a>] do_IRQ+0x4a/0x80
 [<c01039a7>] common_interrupt+0x23/0x28
 [<c012007b>] do_notify_parent+0x9b/0x170
 [<c0101c4d>] default_idle+0x4d/0x80
 [<c0101c00>] default_idle+0x0/0x80
 [<c0101a66>] cpu_idle+0x26/0x80
 =======================
Code: 81 ec b8 00 00 00 89 44 24 30 8b 84 24 d0 00 00 00 8b 54 24 30 0f
b6 8c 24 cc 00 00 00 8b 70 4c 8b 42 14 80 e1 1c 89 f2 c1 e2 05 <8b> b8
24 02 00 00 89 d8 31 ea 88 4c 24 53 e8 7a dd ff ff 8b 15
EIP: [<c02a07d3>] ip_route_input+0x33/0xe00 SS:ESP 0068:c038fc4c
Kernel panic - not syncing: Fatal exception in interrupt
atkbd.c: Unknown key released (translated set 2, code 0xe0 on
isa0060/serio0).
atkbd.c: Use 'setkeycodes e060 <keycode>' to make it known.
atkbd.c: Unknown key released (translated set 2, code 0xe0 on
isa0060/serio0).
atkbd.c: Use 'setkeycodes e060 <keycode>' to make it known.
Linux version 2.6.24 (root@Calimero) (gcc version 4.2.3) #1 Fri May 9
14:39:54 CEST 2008
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000dc000 - 00000000000e0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000000a000000 (usable)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
160MB LOWMEM available.
Scan SMP from c0000000 for 1024 bytes.
Scan SMP from c009fc00 for 1024 bytes.
Scan SMP from c00f0000 for 65536 bytes.
Scan SMP from c009f800 for 1024 bytes.
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
Detected 267.291 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
Memory: 158944k/163840k available (2005k kernel code, 4464k reserved,
603k data, 176k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffb5000 - 0xfffff000   ( 296 kB)
    vmalloc : 0xca800000 - 0xfffb3000   ( 855 MB)
    lowmem  : 0xc0000000 - 0xca000000   ( 160 MB)
      .init : 0xc0390000 - 0xc03bc000   ( 176 kB)
      .data : 0xc02f557a - 0xc038c2c0   ( 603 kB)
      .text : 0xc0100000 - 0xc02f557a   (2005 kB)
Checking if this processor honours the WP bit even in supervisor
mode...Ok.
SLUB: Genslabs=11, HWalign=32, Order=0-1, MinObjects=4, CPUs=1, Nodes=1
Calibrating delay using timer specific routine.. 535.26 BogoMIPS
(lpj=1070531)
Mount-cache hash table entries: 512
CPU: L1 I cache: 16K, L1 D cache: 16K
Compat vDSO mapped to ffffe000.
CPU: Intel Celeron (Covington) stepping 00
Checking 'hlt' instruction... OK.
Freeing SMP alternatives: 0k freed
ACPI: Core revision 20070126
ACPI Exception (tbxface-0629): AE_NO_ACPI_TABLES, While loading
namespace from ACPI tables [20070126]
ACPI: Unable to load the System Description Tables
net_namespace: 448 bytes
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
input: AT Raw Set 2 keyboard as
/devices/platform/i8042/serio0/input/input0
Filesystem "hda1": Disabling barriers, not supported by the underlying
device
XFS mounting filesystem hda1
Starting XFS recovery on filesystem: hda1 (logdev: internal)
Ending XFS recovery on filesystem: hda1 (logdev: internal)
VFS: Mounted root (xfs filesystem) readonly.
Freeing unused kernel memory: 176k freed
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
Ending clean XFS mount for filesystem: hda5
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
Ending clean XFS mount for filesystem: hda8
BUG: unable to handle kernel NULL pointer dereference at 00000224
IP: [<c02a07d3>] ip_route_input+0x33/0xe00
Oops: 0000 [#1]
Modules linked in: netconsole sch_sfq sch_htb cls_fw nf_nat_pptp
nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp
nf_conntrack_ftp 3c59x mii

Pid: 667, comm: rc.inetd Not tainted (2.6.24 #1)
EIP: 0060:[<c02a07d3>] EFLAGS: 00010202 CPU: 0
EIP is at ip_route_input+0x33/0xe00
EAX: 00000000 EBX: c50112ac ECX: 00000000 EDX: 00000040
ESI: 00000002 EDI: c9f4f120 EBP: 120110ac ESP: c9079bd4
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process rc.inetd (pid: 667, ti=c9078000 task=c9009580 task.ti=c9078000)
Stack: 00000000 c9e101e0 c9d14840 c9079cac c02a010d c03770b4 00000000
c9079c14
       b7f1a000 c9079ce8 c03de660 c9f4f5a0 c904ad20 00000060 00000001
00000001
       00000002 00000001 00000000 120110ac 1e232055 00000000 00000000
00000000
Call Trace:
 [<c02a010d>] __ip_route_output_key+0x4ad/0x840
 [<c02a04bc>] ip_route_output_flow+0x1c/0x200
 [<c02d38db>] ip_route_me_harder+0xab/0x290
 [<c02d87e2>] reject_tg+0x232/0x400
 [<c02d85b0>] reject_tg+0x0/0x400
 [<c02d793c>] ipt_do_table+0x2bc/0x4b0
 [<c02d7bc0>] ipt_hook+0x0/0x20
 [<c02968c7>] nf_iterate+0x57/0x80
 [<c02969c8>] nf_hook_slow+0x98/0xd0
 [<c02a4440>] ip_forward_finish+0x0/0x30
 [<c02a471a>] ip_forward+0x2aa/0x320
 [<c02a4440>] ip_forward_finish+0x0/0x30
 [<c02a307b>] ip_rcv_finish+0xeb/0x310
 [<c02a2f90>] ip_rcv_finish+0x0/0x310
 [<c02a3691>] ip_rcv+0x191/0x250
 [<c02a2f90>] ip_rcv_finish+0x0/0x310
 [<c02a3500>] ip_rcv+0x0/0x250
 [<c027dfb1>] netif_receive_skb+0x1f1/0x370
 [<c02806db>] process_backlog+0x5b/0xb0
 [<c0280224>] net_rx_action+0xb4/0x140
 [<c011a642>] __do_softirq+0x42/0x90
 [<c011a6b6>] do_softirq+0x26/0x30
 [<c010560a>] do_IRQ+0x4a/0x80
 [<c0151412>] check_object+0xc2/0x210
 [<c01039a7>] common_interrupt+0x23/0x28
 [<c0152480>] kmem_cache_alloc+0x30/0xa0
 [<c015d588>] getname+0x28/0xd0
 [<c015d588>] getname+0x28/0xd0
 [<c01541ee>] do_sys_open+0x1e/0xe0
 [<c01542ec>] sys_open+0x1c/0x20
 [<c0102ffe>] syscall_call+0x7/0xb
 [<c02f0000>] rest_init+0x20/0x40
 =======================
Code: 81 ec b8 00 00 00 89 44 24 30 8b 84 24 d0 00 00 00 8b 54 24 30 0f
b6 8c 24 cc 00 00 00 8b 70 4c 8b 42 14 80 e1 1c 89 f2 c1 e2 05 <8b> b8
24 02 00 00 89 d8 31 ea 88 4c 24 53 e8 7a dd ff ff 8b 15
EIP: [<c02a07d3>] ip_route_input+0x33/0xe00 SS:ESP 0068:c9079bd4
Kernel panic - not syncing: Fatal exception in interrupt
Linux version 2.6.24 (root@Calimero) (gcc version 4.2.3) #1 Fri May 9
14:39:54 CEST 2008
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000dc000 - 00000000000e0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000000a000000 (usable)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
160MB LOWMEM available.
Scan SMP from c0000000 for 1024 bytes.
Scan SMP from c009fc00 for 1024 bytes.
Scan SMP from c00f0000 for 65536 bytes.
Scan SMP from c009f800 for 1024 bytes.
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
Detected 267.276 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
Memory: 158944k/163840k available (2005k kernel code, 4464k reserved,
603k data, 176k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffb5000 - 0xfffff000   ( 296 kB)
    vmalloc : 0xca800000 - 0xfffb3000   ( 855 MB)
    lowmem  : 0xc0000000 - 0xca000000   ( 160 MB)
      .init : 0xc0390000 - 0xc03bc000   ( 176 kB)
      .data : 0xc02f557a - 0xc038c2c0   ( 603 kB)
      .text : 0xc0100000 - 0xc02f557a   (2005 kB)
Checking if this processor honours the WP bit even in supervisor
mode...Ok.
SLUB: Genslabs=11, HWalign=32, Order=0-1, MinObjects=4, CPUs=1, Nodes=1
Calibrating delay using timer specific routine.. 535.25 BogoMIPS
(lpj=1070500)
Mount-cache hash table entries: 512
CPU: L1 I cache: 16K, L1 D cache: 16K
Compat vDSO mapped to ffffe000.
CPU: Intel Celeron (Covington) stepping 00
Checking 'hlt' instruction... OK.
Freeing SMP alternatives: 0k freed
ACPI: Core revision 20070126
ACPI Exception (tbxface-0629): AE_NO_ACPI_TABLES, While loading
namespace from ACPI tables [20070126]
ACPI: Unable to load the System Description Tables
net_namespace: 448 bytes
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
input: AT Raw Set 2 keyboard as
/devices/platform/i8042/serio0/input/input0
input: AT Raw Set 2 keyboard as
/devices/platform/i8042/serio0/input/input1
Filesystem "hda1": Disabling barriers, not supported by the underlying
device
XFS mounting filesystem hda1
Starting XFS recovery on filesystem: hda1 (logdev: internal)
Ending XFS recovery on filesystem: hda1 (logdev: internal)
VFS: Mounted root (xfs filesystem) readonly.
Freeing unused kernel memory: 176k freed
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
Ending clean XFS mount for filesystem: hda5
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
Ending clean XFS mount for filesystem: hda8
BUG: unable to handle kernel NULL pointer dereference at 00000224
IP: [<c02a07d3>] ip_route_input+0x33/0xe00
Oops: 0000 [#1]
Modules linked in: netconsole sch_sfq sch_htb cls_fw nf_nat_pptp
nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp
nf_conntrack_ftp 3c59x mii

Pid: 0, comm: swapper Not tainted (2.6.24 #1)
EIP: 0060:[<c02a07d3>] EFLAGS: 00010202 CPU: 0
EIP is at ip_route_input+0x33/0xe00
EAX: 00000000 EBX: 2e0112ac ECX: 00000000 EDX: 00000040
ESI: 00000002 EDI: c90bf000 EBP: 020217ac ESP: c038fc4c
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c038e000 task=c03672e0 task.ti=c038e000)
Stack: 00000000 c9e201e0 c9d14840 c038fd24 c02a010d 00000002 00000000
c038fc8c
       00000003 c038fd60 c03de660 c90bf120 c9f6b1c0 00f6bb60 00000001
00000001
       00000002 00000001 00000000 020217ac 1e232055 00000000 00000000
00000000
Call Trace:
 [<c02a010d>] __ip_route_output_key+0x4ad/0x840
 [<c02a04bc>] ip_route_output_flow+0x1c/0x200
 [<c02d38db>] ip_route_me_harder+0xab/0x290
 [<c02d87e2>] reject_tg+0x232/0x400
 [<c02d85b0>] reject_tg+0x0/0x400
 [<c02d793c>] ipt_do_table+0x2bc/0x4b0
 [<c02d7bc0>] ipt_hook+0x0/0x20
 [<c02968c7>] nf_iterate+0x57/0x80
 [<c02969c8>] nf_hook_slow+0x98/0xd0
 [<c02a4440>] ip_forward_finish+0x0/0x30
 [<c02a471a>] ip_forward+0x2aa/0x320
 [<c02a4440>] ip_forward_finish+0x0/0x30
 [<c02a307b>] ip_rcv_finish+0xeb/0x310
 [<c02a2f90>] ip_rcv_finish+0x0/0x310
 [<c02a3691>] ip_rcv+0x191/0x250
 [<c02a2f90>] ip_rcv_finish+0x0/0x310
 [<c02a3500>] ip_rcv+0x0/0x250
 [<c027dfb1>] netif_receive_skb+0x1f1/0x370
 [<c02806db>] process_backlog+0x5b/0xb0
 [<c0280224>] net_rx_action+0xb4/0x140
 [<c011a642>] __do_softirq+0x42/0x90
 [<c011a6b6>] do_softirq+0x26/0x30
 [<c010560a>] do_IRQ+0x4a/0x80
 [<c01039a7>] common_interrupt+0x23/0x28
 [<c012007b>] do_notify_parent+0x9b/0x170
 [<c0101c4d>] default_idle+0x4d/0x80
 [<c0101c00>] default_idle+0x0/0x80
 [<c0101a66>] cpu_idle+0x26/0x80
 =======================
Code: 81 ec b8 00 00 00 89 44 24 30 8b 84 24 d0 00 00 00 8b 54 24 30 0f
b6 8c 24 cc 00 00 00 8b 70 4c 8b 42 14 80 e1 1c 89 f2 c1 e2 05 <8b> b8
24 02 00 00 89 d8 31 ea 88 4c 24 53 e8 7a dd ff ff 8b 15
EIP: [<c02a07d3>] ip_route_input+0x33/0xe00 SS:ESP 0068:c038fc4c
Kernel panic - not syncing: Fatal exception in interrupt


