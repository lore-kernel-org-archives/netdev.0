From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 15 Jan 2009 10:20:34 -0800
Message-ID: <20090115182034.GA9091@ovro.caltech.edu>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901151358.34250.arnd@arndb.de> <20090115165359.GA2230@ovro.caltech.edu> <200901151853.52202.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:47499 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758073AbZAOSUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 13:20:36 -0500
Content-Disposition: inline
In-Reply-To: <200901151853.52202.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 06:53:51PM +0100, Arnd Bergmann wrote:
> On Thursday 15 January 2009, Ira Snyder wrote:
> > 
> > These are PCI boards, not PCIe. The host computers are all Pentium3-M
> > systems. I tried enabling MSI on the Freescale boards in the driver, by
> > calling pci_enable_msi() during probe(), and it failed. 
> 
> That doesn't really mean anything, just that the PCI endpoint doesn't
> announce its capability to do MSI in the config space, or that it
> does not have an interrupt line. Since you basically implement the
> device on the FSL board, you should also be able to define the interrupt
> capabilities by writing to the config space.
> 
> Do you know what kind of chipset the host uses? It should be fairly
> simple to find out whether or not it can do MSI.
> 

Some sort of Broadcom chipset, I think. Full dmesg and lspci output are
appended.

The PCI bridge does mention MSI, so maybe it does support it. Would
using the DMA from the host mean that the guest system couldn't use the
DMA controller at all? All of the channels share the same interrupt line
on the guest. I need one channel on the DMA controller on the guest to
do realtime transfers from some data processing FPGAs on the board.

This stuff is never easy, is it? :)

Thanks for the help so far, I really appreciate it.
Ira


[    0.000000] Linux version 2.6.28-07812-g5fbbf5f (iws@labslcor1) (gcc version 4.1.2 (Gentoo 4.1.2 p1.1)) #4 Thu Jan 8 15:45:08 PST 2009
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   NSC Geode by NSC
[    0.000000]   Cyrix CyrixInstead
[    0.000000]   Centaur CentaurHauls
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000]   UMC UMC UMC UMC
[    0.000000] PAT WC disabled due to known CPU erratum.
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000ea800 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 0000000020000000 (usable)
[    0.000000]  BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
[    0.000000] DMI present.
[    0.000000] Phoenix BIOS detected: BIOS may corrupt low RAM, working it around.
[    0.000000] last_pfn = 0x20000 max_arch_pfn = 0x100000
[    0.000000] Scanning 0 areas for low memory corruption
[    0.000000] modified physical RAM map:
[    0.000000]  modified: 0000000000000000 - 0000000000010000 (reserved)
[    0.000000]  modified: 0000000000010000 - 000000000009f800 (usable)
[    0.000000]  modified: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  modified: 00000000000ea800 - 0000000000100000 (reserved)
[    0.000000]  modified: 0000000000100000 - 0000000020000000 (usable)
[    0.000000]  modified: 00000000fff80000 - 0000000100000000 (reserved)
[    0.000000] kernel direct mapping tables up to 20000000 @ 10000-15000
[    0.000000] ACPI Error (tbxfroot-0218): A valid RSDP was not found [20080926]
[    0.000000] 512MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 20000000
[    0.000000]   low ram: 00000000 - 20000000
[    0.000000]   bootmap 00011000 - 00015000
[    0.000000] (6 early reservations) ==> bootmem [0000000000 - 0020000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000100000 - 00007bf49c]    TEXT DATA BSS ==> [0000100000 - 00007bf49c]
[    0.000000]   #2 [00007c0000 - 00007c3000]    INIT_PG_TABLE ==> [00007c0000 - 00007c3000]
[    0.000000]   #3 [000008f400 - 0000100000]    BIOS reserved ==> [000008f400 - 0000100000]
[    0.000000]   #4 [0000010000 - 0000011000]          PGTABLE ==> [0000010000 - 0000011000]
[    0.000000]   #5 [0000011000 - 0000015000]          BOOTMAP ==> [0000011000 - 0000015000]
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x00020000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x00020000
[    0.000000] On node 0 totalpages: 130959
[    0.000000] free_area_init_node: node 0, pgdat c0395f60, node_mem_map c1000200
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3951 pages, LIFO batch:0
[    0.000000]   Normal zone: 992 pages used for memmap
[    0.000000]   Normal zone: 125984 pages, LIFO batch:31
[    0.000000] Local APIC disabled by BIOS -- you can enable it with "lapic"
[    0.000000] Allocating PCI resources starting at 30000000 (gap: 20000000:dff80000)
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 129935
[    0.000000] Kernel command line: console=ttyS0,19200 root=/dev/nfs ide0=noprobe ide1=noprobe nfsroot=/export/netboot/correlator_pvt/%s,tcp ip=::::::dhcp pci=biosirq BOOT_IMAGE=bzImage-labslcor1.correlator.pvt auto
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] CPU 0 irqstacks, hard=c03df000 soft=c03de000
[    0.000000] PID hash table entries: 2048 (order: 11, 8192 bytes)
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 1195.647 MHz processor.
[    0.004000] Console: colour VGA+ 80x25
[    0.004000] console [ttyS0] enabled
[    0.004000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.004000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.004000] ... MAX_LOCK_DEPTH:          48
[    0.004000] ... MAX_LOCKDEP_KEYS:        8191
[    0.004000] ... CLASSHASH_SIZE:          4096
[    0.004000] ... MAX_LOCKDEP_ENTRIES:     8192
[    0.004000] ... MAX_LOCKDEP_CHAINS:      16384
[    0.004000] ... CHAINHASH_SIZE:          8192
[    0.004000]  memory used by lock dependency info: 2335 kB
[    0.004000]  per task-struct memory footprint: 1152 bytes
[    0.004000] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.004000] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.004000] Memory: 512108k/524288k available (1795k kernel code, 11512k reserved, 890k data, 232k init, 0k highmem)
[    0.004000] virtual kernel memory layout:
[    0.004000]     fixmap  : 0xfffac000 - 0xfffff000   ( 332 kB)
[    0.004000]     vmalloc : 0xe0800000 - 0xfffaa000   ( 503 MB)
[    0.004000]     lowmem  : 0xc0000000 - 0xe0000000   ( 512 MB)
[    0.004000]       .init : 0xc03a1000 - 0xc03db000   ( 232 kB)
[    0.004000]       .data : 0xc02c0cee - 0xc039f7c8   ( 890 kB)
[    0.004000]       .text : 0xc0100000 - 0xc02c0cee   (1795 kB)
[    0.004000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.004000] SLUB: Genslabs=12, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.004025] Calibrating delay loop (skipped), value calculated using timer frequency.. 2391.29 BogoMIPS (lpj=4782588)
[    0.012060] Mount-cache hash table entries: 512
[    0.017091] CPU: L1 I cache: 16K, L1 D cache: 16K
[    0.024006] CPU: L2 cache: 512K
[    0.028010] Intel machine check architecture supported.
[    0.032008] Intel machine check reporting enabled on CPU#0.
[    0.036015] CPU: Intel(R) Pentium(R) III Mobile CPU      1200MHz stepping 01
[    0.048011] Checking 'hlt' instruction... OK.
[    0.070988] Freeing SMP alternatives: 0k freed
[    0.072007] ACPI: Core revision 20080926
[    0.076077] ACPI Exception (tbxface-0627): AE_NO_ACPI_TABLES, While loading namespace from ACPI tables [20080926]
[    0.088006] ACPI: Unable to load the System Description Tables
[    0.093401] net_namespace: 384 bytes
[    0.096363] NET: Registered protocol family 16
[    0.105855] PCI: PCI BIOS revision 2.10 entry at 0xfda10, last bus=2
[    0.108008] PCI: Using configuration type 1 for base access
[    0.120211] bio: create slab <bio-0> at 0
[    0.124230] ACPI: Interpreter disabled.
[    0.132405] usbcore: registered new interface driver usbfs
[    0.136165] usbcore: registered new interface driver hub
[    0.140180] usbcore: registered new device driver usb
[    0.148320] PCI: Probing PCI hardware
[    0.152051] PCI: Probing PCI hardware (bus 00)
[    0.152298] * The chipset may have PM-Timer Bug. Due to workarounds for a bug,
[    0.152302] * this clock source is slow. If you are sure your timer does not have
[    0.152305] * this bug, please use "acpi_pm_good" to disable the workaround
[    0.156074] * The chipset may have PM-Timer Bug. Due to workarounds for a bug,
[    0.156077] * this clock source is slow. If you are sure your timer does not have
[    0.156080] * this bug, please use "acpi_pm_good" to disable the workaround
[    0.160120] pci 0000:00:01.0: reg 10 32bit mmio: [0xf9020000-0xf9020fff]
[    0.160133] pci 0000:00:01.0: reg 14 io port: [0x1080-0x10bf]
[    0.160145] pci 0000:00:01.0: reg 18 32bit mmio: [0xf9000000-0xf901ffff]
[    0.160175] pci 0000:00:01.0: reg 30 32bit mmio: [0x000000-0x0fffff]
[    0.160204] pci 0000:00:01.0: supports D1 D2
[    0.160209] pci 0000:00:01.0: PME# supported from D0 D1 D2 D3hot
[    0.164011] pci 0000:00:01.0: PME# disabled
[    0.168051] pci 0000:00:02.0: reg 10 32bit mmio: [0xf9021000-0xf9021fff]
[    0.168063] pci 0000:00:02.0: reg 14 io port: [0x10c0-0x10ff]
[    0.168075] pci 0000:00:02.0: reg 18 32bit mmio: [0xf9040000-0xf905ffff]
[    0.168105] pci 0000:00:02.0: reg 30 32bit mmio: [0x000000-0x0fffff]
[    0.168134] pci 0000:00:02.0: supports D1 D2
[    0.168139] pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot
[    0.172010] pci 0000:00:02.0: PME# disabled
[    0.176062] pci 0000:00:04.0: reg 10 32bit mmio: [0xf9022000-0xf9022fff]
[    0.176074] pci 0000:00:04.0: reg 14 io port: [0x1000-0x107f]
[    0.176253] pci 0000:00:0f.1: reg 20 io port: [0x1400-0x140f]
[    0.176310] pci 0000:00:0f.2: reg 10 32bit mmio: [0xf9023000-0xf9023fff]
[    0.176491] pci 0000:01:0c.0: reg 10 32bit mmio: [0xf9100000-0xf91fffff]
[    0.176506] pci 0000:01:0c.0: reg 14 32bit mmio: [0xf9700000-0xf9700fff]
[    0.176532] pci 0000:01:0c.0: reg 18 64bit mmio: [0xf9600000-0xf96fffff]
[    0.176556] pci 0000:01:0c.0: reg 20 64bit mmio: [0xf9500000-0xf95fffff]
[    0.176668] pci 0000:01:0e.0: reg 10 32bit mmio: [0xf9200000-0xf92fffff]
[    0.176684] pci 0000:01:0e.0: reg 14 32bit mmio: [0xf9701000-0xf9701fff]
[    0.176708] pci 0000:01:0e.0: reg 18 64bit mmio: [0xf9900000-0xf99fffff]
[    0.176733] pci 0000:01:0e.0: reg 20 64bit mmio: [0xf9800000-0xf98fffff]
[    0.176840] pci 0000:00:04.0: bridge 32bit mmio: [0xf9100000-0xf92fffff]
[    0.176849] pci 0000:00:04.0: bridge 32bit mmio pref: [0xf9500000-0xf99fffff]
[    0.178609] PCI: Discovered peer bus 02
[    0.180189] pci 0000:02:03.0: reg 10 32bit mmio: [0xfa000000-0xfaffffff]
[    0.180235] pci 0000:02:03.0: reg 30 32bit mmio: [0x000000-0x03ffff]
[    0.181688] pnp: PnP ACPI: disabled
[    0.185421] pci 0000:00:04.0: PCI bridge, secondary bus 0000:01
[    0.220873] pci 0000:00:04.0:   IO window: disabled
[    0.250079] pci 0000:00:04.0:   MEM window: 0xf9100000-0xf92fffff
[    0.286569] pci 0000:00:04.0:   PREFETCH window: 0x000000f9500000-0x000000f99fffff
[    0.331918] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    0.331924] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffff]
[    0.331929] pci_bus 0000:01: resource 0 mem: [0x0-0x0]
[    0.331934] pci_bus 0000:01: resource 1 mem: [0xf9100000-0xf92fffff]
[    0.331940] pci_bus 0000:01: resource 2 mem: [0xf9500000-0xf99fffff]
[    0.331945] pci_bus 0000:01: resource 3 mem: [0x0-0x0]
[    0.331950] pci_bus 0000:02: resource 0 io:  [0x00-0xffff]
[    0.331954] pci_bus 0000:02: resource 1 mem: [0x000000-0xffffffff]
[    0.332010] NET: Registered protocol family 2
[    0.358447] IP route cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.401080] TCP established hash table entries: 65536 (order: 7, 524288 bytes)
[    0.446213] TCP bind hash table entries: 65536 (order: 9, 2097152 bytes)
[    0.500128] TCP: Hash tables configured (established 65536 bind 65536)
[    0.539299] TCP reno registered
[    0.558459] NET: Registered protocol family 1
[    0.585465] platform rtc_cmos: registered platform RTC device (no PNP device found)
[    0.631330] Machine check exception polling timer started.
[    0.665649] Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.712519] Scanning for low memory corruption every 60 seconds
[    0.760346] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    0.799493] fuse init (API version 7.11)
[    0.823571] msgmni has been set to 1000
[    0.847156] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    0.891466] io scheduler noop registered
[    0.914944] io scheduler deadline registered
[    0.940540] io scheduler cfq registered (default)
[    0.968910] pci 0000:00:02.0: Firmware left e100 interrupts enabled; disabling
[    1.012197] pci 0000:02:03.0: Boot video device
[    1.022963] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.061391] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    1.098302] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    1.135240] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k6-NAPI
[    1.171721] e100: Copyright(c) 1999-2006 Intel Corporation
[    1.227398] e100 0000:00:01.0: PME# disabled
[    1.253387] e100: eth0: e100_probe: addr 0xf9020000, irq 9, MAC addr 00:80:42:12:ad:ff
[    1.323517] e100 0000:00:02.0: PME# disabled
[    1.349416] e100: eth1: e100_probe: addr 0xf9021000, irq 11, MAC addr 00:80:42:12:ae:00
[    1.397462] console [netcon0] enabled
[    1.419373] netconsole: network logging started
[    1.446687] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.483733] ohci_hcd 0000:00:0f.2: OHCI Host Controller
[    1.516113] ohci_hcd 0000:00:0f.2: new USB bus registered, assigned bus number 1
[    1.560431] ohci_hcd 0000:00:0f.2: irq 10, io mem 0xf9023000
[    1.649658] usb usb1: configuration #1 chosen from 1 choice
[    1.683403] hub 1-0:1.0: USB hub found
[    1.705910] hub 1-0:1.0: 4 ports detected
[    1.731563] PNP: No PS/2 controller found. Probing ports directly.
[    1.771634] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.801376] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.832470] mice: PS/2 mouse device common for all mice
[    1.864545] rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
[    1.902681] rtc0: alarms up to one day, 114 bytes nvram
[    1.934085] cpuidle: using governor ladder
[    1.958642] cpuidle: using governor menu
[    1.984820] usbcore: registered new interface driver usbhid
[    2.018247] usbhid: v2.6:USB HID core driver
[    2.043923] TCP cubic registered
[    2.063273] NET: Registered protocol family 17
[    2.090467] RPC: Registered udp transport module.
[    2.118648] RPC: Registered tcp transport module.
[    2.146845] IO APIC resources could be not be allocated.
[    2.178672] Using IPI Shortcut mode
[    2.200498] rtc_cmos rtc_cmos: setting system clock to 2009-01-15 10:08:28 UTC (1232014108)
[    2.768492] e100 0000:00:01.0: firmware: using built-in firmware e100/d101s_ucode.bin
[    2.835120] e100: eth0 NIC Link is Up 100 Mbps Full Duplex
[    2.876469] e100 0000:00:02.0: firmware: using built-in firmware e100/d101s_ucode.bin
[    3.378827] Clocksource tsc unstable (delta = 115900197 ns)
[    3.970856] Sending DHCP requests ., OK
[    3.997668] IP-Config: Got DHCP answer from 192.168.5.13, my address is 192.168.17.13
[    4.005875] IP-Config: Complete:
[    4.008824]      device=eth0, addr=192.168.17.13, mask=255.255.255.0, gw=192.168.17.1,
[    4.026488]      host=192.168.17.13, domain=correlator.pvt fileserver.pvt ovro.pvt mmarray.org carma.pvt pr, nis-domain=(none),
[    4.028216]      bootserver=192.168.5.13, rootserver=192.168.5.13, rootpath=
[    4.041384] Looking up port of RPC 100003/2 on 192.168.5.13
[    4.050478] Looking up port of RPC 100005/1 on 192.168.5.13
[    4.129452] VFS: Mounted root (nfs filesystem) readonly on device 0:13.
[    4.133518] Freeing unused kernel memory: 232k freed
[    6.834682] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    6.863495] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4



00:00.0 Host bridge: Broadcom CNB20LE Host Bridge (rev 06)
00:00.1 Host bridge: Broadcom CNB20LE Host Bridge (rev 06)
00:01.0 Ethernet controller: Intel Corporation 8255xER/82551IT Fast Ethernet Controller (rev 09)
00:02.0 Ethernet controller: Intel Corporation 8255xER/82551IT Fast Ethernet Controller (rev 09)
00:04.0 PCI bridge: Force Computers Device 0001 (rev 01)
00:0f.0 ISA bridge: Broadcom OSB4 South Bridge (rev 50)
00:0f.1 IDE interface: Broadcom OSB4 IDE Controller
00:0f.2 USB Controller: Broadcom OSB4/CSB5 OHCI USB Controller (rev 04)
01:0c.0 Power PC: Freescale Semiconductor Inc MPC8349E (rev 30)
01:0e.0 Power PC: Freescale Semiconductor Inc MPC8349E (rev 30)
02:03.0 VGA compatible controller: Chips and Technologies F69030 (rev 61)



00:00.0 Host bridge: Broadcom CNB20LE Host Bridge (rev 06)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 48, Cache Line Size: 32 bytes

00:00.1 Host bridge: Broadcom CNB20LE Host Bridge (rev 06)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes

00:01.0 Ethernet controller: Intel Corporation 8255xER/82551IT Fast Ethernet Controller (rev 09)
	Subsystem: Intel Corporation Device 100c
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 66 (2000ns min, 14000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 9
	Region 0: Memory at f9020000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at 1080 [size=64]
	Region 2: Memory at f9000000 (32-bit, non-prefetchable) [size=128K]
	[virtual] Expansion ROM at 30000000 [disabled] [size=1M]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-
	Kernel driver in use: e100

00:02.0 Ethernet controller: Intel Corporation 8255xER/82551IT Fast Ethernet Controller (rev 09)
	Subsystem: Intel Corporation Device 100c
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 66 (2000ns min, 14000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f9021000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at 10c0 [size=64]
	Region 2: Memory at f9040000 (32-bit, non-prefetchable) [size=128K]
	[virtual] Expansion ROM at 30100000 [disabled] [size=1M]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-
	Kernel driver in use: e100

00:04.0 PCI bridge: Force Computers Device 0001 (rev 01) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Region 0: Memory at f9022000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at 1000 [size=128]
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: f9100000-f92fffff
	Prefetchable memory behind bridge: f9500000-f99fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [fc] CompactPCI hot-swap <?>
	Capabilities: [f0] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable-
		Address: 00000000  Data: 0000
	Kernel modules: shpchp

00:0f.0 ISA bridge: Broadcom OSB4 South Bridge (rev 50)
	Subsystem: Broadcom OSB4 South Bridge
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

00:0f.1 IDE interface: Broadcom OSB4 IDE Controller (prog-if 8a [Master SecP PriP])
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64
	Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) [disabled] [size=8]
	Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable) [disabled] [size=1]
	Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) [disabled] [size=8]
	Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable) [disabled] [size=1]
	Region 4: I/O ports at 1400 [size=16]

00:0f.2 USB Controller: Broadcom OSB4/CSB5 OHCI USB Controller (rev 04) (prog-if 10 [OHCI])
	Subsystem: Broadcom OSB4/CSB5 OHCI USB Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (20000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at f9023000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci_hcd

01:0c.0 Power PC: Freescale Semiconductor Inc MPC8349E (rev 30)
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at f9100000 (32-bit, non-prefetchable) [size=1M]
	Region 1: Memory at f9700000 (32-bit, prefetchable) [size=4K]
	Region 2: Memory at f9600000 (64-bit, prefetchable) [size=1M]
	Region 4: Memory at f9500000 (64-bit, prefetchable) [size=1M]
	Capabilities: [48] CompactPCI hot-swap <?>

01:0e.0 Power PC: Freescale Semiconductor Inc MPC8349E (rev 30)
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f9200000 (32-bit, non-prefetchable) [size=1M]
	Region 1: Memory at f9701000 (32-bit, prefetchable) [size=4K]
	Region 2: Memory at f9900000 (64-bit, prefetchable) [size=1M]
	Region 4: Memory at f9800000 (64-bit, prefetchable) [size=1M]
	Capabilities: [48] CompactPCI hot-swap <?>

02:03.0 VGA compatible controller: Chips and Technologies F69030 (rev 61) (prog-if 00 [VGA controller])
	Subsystem: Chips and Technologies F69030
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 9
	Region 0: Memory at fa000000 (32-bit, non-prefetchable) [size=16M]
	[virtual] Expansion ROM at 30200000 [disabled] [size=256K]

