From: Meelis Roos <mroos@linux.ee>
Subject: Re: Invalid sk_policy[] access (was Re: Recent spontaneous reboots
 on multiple machines)
Date: Tue, 23 Feb 2016 22:45:44 +0200 (EET)
Message-ID: <alpine.LRH.2.20.1602232238210.30129@math.ut.ee>
References: <20160107174105.GD23579@oracle.com> <alpine.LRH.2.20.1601072133480.29795@math.ut.ee> <20160107201445.GF23579@oracle.com> <20160108172022.GA3398@oracle.com> <alpine.LRH.2.20.1602051103140.5582@math.ut.ee> <20160214105131.GD20715@oracle.com>
 <alpine.LRH.2.20.1602150751180.29662@math.ut.ee> <20160222010201.GB23053@oracle.com> <20160223121244.GI28756@oracle.com> <alpine.LRH.2.20.1602232132190.30129@math.ut.ee> <20160223193913.GB4941@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: sparclinux@vger.kernel.org, edumazet@google.com,
	netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20160223193913.GB4941@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > However, I have not succeeded in reproducing the problem at will - git 
> > checkout of another release + subsequent compile still does not trigger 
> > it. But if it is the same problem, it seems to go int triple fault or 
> > something similar for me to cause it reboot with no trace in the 
> > console.

Just got something - not on the console but a livelock with 
4.5.0-rc5-dirty. However, this seems to be mm-related?

This one has git checkout of v4.3 + git checkout master running, ps 
hangs when reaching this process. Simple pstree works, pstree -plah 
hangs, pstree -cp whows 3 gits running, catting /proc/PID/cmdline of one 
of them is hanging again. wchan is vm_munmap, status shows state D as 
expected.

[    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.30.4.a 2010/01/06 14:45'
[    0.000000] PROMLIB: Root node compatible: 
[    0.000000] Linux version 4.5.0-rc5-dirty (mroos@v440) (gcc version 4.9.3 (Debian 4.9.3-2) ) #456 SMP Mon Feb 22 04:52:48 EET 2016
[    0.000000] bootconsole [earlyprom0] enabled
[    0.000000] ARCH: SUN4U
[    0.000000] Ethernet address: 00:03:ba:6f:14:39
[    0.000000] MM: PAGE_OFFSET is 0xfff0000000000000 (max_phys_bits == 42)
[    0.000000] MM: VMALLOC [0x0000000100000000 --> 0x000c000000000000]
[    0.000000] MM: VMEMMAP [0x000c000000000000 --> 0x0018000000000000]
[    0.000000] Kernel: Using 2 locked TLB entries for main kernel image.
[    0.000000] Remapping the kernel... done.
[    0.000000] OF stdout device is: /pci@1e,600000/isa@7/serial@0,3f8
[    0.000000] PROM: Built device tree with 147286 bytes of memory.
[    0.000000] Top of RAM: 0x223fef2000, Total RAM: 0x17fe88000
[    0.000000] Memory hole size: 134144MB
[    0.000000] Allocated 57344 bytes for kernel page tables.
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x0000000000000000-0x000000223fef1fff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000000000-0x000000003fffffff]
[    0.000000]   node   0: [mem 0x0000000200000000-0x000000023fffffff]
[    0.000000]   node   0: [mem 0x0000001000000000-0x000000103fffffff]
[    0.000000]   node   0: [mem 0x0000001200000000-0x000000123fffffff]
[    0.000000]   node   0: [mem 0x0000002000000000-0x000000203fffffff]
[    0.000000]   node   0: [mem 0x0000002200000000-0x000000223effdfff]
[    0.000000]   node   0: [mem 0x000000223f000000-0x000000223fe67fff]
[    0.000000]   node   0: [mem 0x000000223fe78000-0x000000223fe8ffff]
[    0.000000]   node   0: [mem 0x000000223fec0000-0x000000223fec7fff]
[    0.000000]   node   0: [mem 0x000000223fef0000-0x000000223fef1fff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x000000223fef1fff]
[    0.000000] On node 0 totalpages: 786244
[    0.000000]   Normal zone: 6911 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 786244 pages, LIFO batch:15
[    0.000000] Booting Linux...
[    0.000000] CPU CAPS: [flush,stbar,swap,muldiv,v9,ultra3,mul32,div32]
[    0.000000] CPU CAPS: [v8plus,vis,vis2]
[    0.000000] PERCPU: Embedded 8 pages/cpu @fff000223f800000 s22720 r8192 d34624 u1048576
[    0.000000] pcpu-alloc: s22720 r8192 d34624 u1048576 alloc=1*4194304
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 779333
[    0.000000] Kernel command line: root=/dev/sda1 ro
[    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 1048576 (order: 10, 8388608 bytes)
[    0.000000] Inode-cache hash table entries: 524288 (order: 9, 4194304 bytes)
[    0.000000] Sorting __ex_table...
[    0.000000] Memory: 6171600K/6289952K available (4308K kernel code, 279K rwdata, 1520K rodata, 192K init, 480K bss, 118352K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 64.
[    0.000000] NR_IRQS:2048 nr_irqs:2048 1
[  116.474391] clocksource: stick: mask: 0xffffffffffffffff max_cycles: 0x24e6a1710, max_idle_ns: 440795202120 ns
[  116.594070] clocksource: mult[64000000] shift[24]
[  116.650327] clockevent: mult[28f5c29] shift[32]
[  116.704588] Console: colour dummy device 80x25
[  116.757777] console [tty0] enabled
[  116.798517] bootconsole [earlyprom0] disabled
[  116.930658] Calibrating delay using timer specific routine.. 20.01 BogoMIPS (lpj=40035)
[  116.930672] pid_max: default: 32768 minimum: 301
[  116.930761] Security Framework initialized
[  116.930796] Mount-cache hash table entries: 16384 (order: 4, 131072 bytes)
[  116.930807] Mountpoint-cache hash table entries: 16384 (order: 4, 131072 bytes)
[  116.934067] CPU 0: synchronized TICK with master CPU (last diff 0 cycles, maxerr 5 cycles)
[  116.935030] CPU 1: synchronized TICK with master CPU (last diff 0 cycles, maxerr 5 cycles)
[  116.935994] CPU 3: synchronized TICK with master CPU (last diff 0 cycles, maxerr 5 cycles)
[  116.936018] Brought up 4 CPUs
[  116.936904] devtmpfs: initialized
[  116.962941] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[  116.963413] NET: Registered protocol family 16
[  116.963423] kworker/u8:0 (28) used greatest stack depth: 9384 bytes left
[  116.965469] IRQ pre handler NOT supported.
[  116.965488] IRQ pre handler NOT supported.
[  116.965499] IRQ pre handler NOT supported.
[  116.965509] IRQ pre handler NOT supported.
[  116.965534] IRQ pre handler NOT supported.
[  116.965650] IRQ pre handler NOT supported.
[  116.965676] IRQ pre handler NOT supported.
[  116.965858] IRQ pre handler NOT supported.
[  116.965877] IRQ pre handler NOT supported.
[  116.965895] IRQ pre handler NOT supported.
[  116.965912] IRQ pre handler NOT supported.
[  116.965928] IRQ pre handler NOT supported.
[  116.966025] IRQ pre handler NOT supported.
[  116.966049] IRQ pre handler NOT supported.
[  116.966066] IRQ pre handler NOT supported.
[  116.966083] IRQ pre handler NOT supported.
[  116.966100] IRQ pre handler NOT supported.
[  116.966438] IRQ pre handler NOT supported.
[  116.969404] IRQ pre handler NOT supported.
[  116.969513] IRQ pre handler NOT supported.
[  116.969624] IRQ pre handler NOT supported.
[  116.969716] IRQ pre handler NOT supported.
[  116.969975] IRQ pre handler NOT supported.
[  116.970106] IRQ pre handler NOT supported.
[  116.970226] IRQ pre handler NOT supported.
[  116.970581] IRQ pre handler NOT supported.
[  116.970600] IRQ pre handler NOT supported.
[  116.970618] IRQ pre handler NOT supported.
[  116.970635] IRQ pre handler NOT supported.
[  116.970651] IRQ pre handler NOT supported.
[  116.970795] IRQ pre handler NOT supported.
[  116.970827] IRQ pre handler NOT supported.
[  116.970946] IRQ pre handler NOT supported.
[  116.971195] IRQ pre handler NOT supported.
[  116.972985] /pci@1c,600000: TOMATILLO PCI Bus Module ver[4:0]
[  116.973014] /pci@1c,600000: PCI IO[7ce01000000] MEM[7cf00000000] MEM64[7cf00000000]
[  116.974433] PCI: Scanning PBM /pci@1c,600000
[  116.974597] schizo f006aac0: PCI host bridge to bus 0000:00
[  116.974626] pci_bus 0000:00: root bus resource [io  0x7ce01000000-0x7ce01ffffff] (bus address [0x0000-0xffffff])
[  116.974657] pci_bus 0000:00: root bus resource [mem 0x7cf00000000-0x7cfffffffff] (bus address [0x00000000-0xffffffff])
[  116.974687] pci_bus 0000:00: root bus resource [mem 0x7cf00000000-0x7cfffffffff] (bus address [0x00000000-0xffffffff])
[  116.974717] pci_bus 0000:00: root bus resource [bus 00]
[  116.975121] /pci@1d,700000: TOMATILLO PCI Bus Module ver[4:0]
[  116.975144] /pci@1d,700000: PCI IO[7c601000000] MEM[7c700000000] MEM64[7c700000000]
[  116.976539] PCI: Scanning PBM /pci@1d,700000
[  116.976694] schizo f0074324: PCI host bridge to bus 0001:00
[  116.976719] pci_bus 0001:00: root bus resource [io  0x7c601000000-0x7c601ffffff] (bus address [0x0000-0xffffff])
[  116.976750] pci_bus 0001:00: root bus resource [mem 0x7c700000000-0x7c7ffffffff] (bus address [0x00000000-0xffffffff])
[  116.976781] pci_bus 0001:00: root bus resource [mem 0x7c700000000-0x7c7ffffffff] (bus address [0x00000000-0xffffffff])
[  116.976810] pci_bus 0001:00: root bus resource [bus 00]
[  116.976911] /pci@1e,600000: TOMATILLO PCI Bus Module ver[4:0]
[  116.976932] /pci@1e,600000: PCI IO[7fe01000000] MEM[7ff00000000] MEM64[7ff00000000]
[  116.978335] PCI: Scanning PBM /pci@1e,600000
[  116.978502] schizo f007d694: PCI host bridge to bus 0002:00
[  116.978528] pci_bus 0002:00: root bus resource [io  0x7fe01000000-0x7fe01ffffff] (bus address [0x0000-0xffffff])
[  116.978559] pci_bus 0002:00: root bus resource [mem 0x7ff00000000-0x7ffffffffff] (bus address [0x00000000-0xffffffff])
[  116.978588] pci_bus 0002:00: root bus resource [mem 0x7ff00000000-0x7ffffffffff] (bus address [0x00000000-0xffffffff])
[  116.978618] pci_bus 0002:00: root bus resource [bus 00]
[  116.978929] pci 0002:00:06.0: quirk: [io  0x7fe01000800-0x7fe0100083f] claimed by ali7101 ACPI
[  116.978963] pci 0002:00:06.0: quirk: [io  0x7fe01000600-0x7fe0100061f] claimed by ali7101 SMB
[  116.979191] pci 0002:00:0a.0: PME# supported from D3cold
[  116.979402] pci 0002:00:0b.0: PME# supported from D3cold
[  116.980085] /pci@1f,700000: TOMATILLO PCI Bus Module ver[4:0]
[  116.980109] /pci@1f,700000: PCI IO[7f601000000] MEM[7f700000000] MEM64[7f700000000]
[  116.981520] PCI: Scanning PBM /pci@1f,700000
[  116.981695] schizo f0086bb0: PCI host bridge to bus 0003:00
[  116.981725] pci_bus 0003:00: root bus resource [io  0x7f601000000-0x7f601ffffff] (bus address [0x0000-0xffffff])
[  116.981756] pci_bus 0003:00: root bus resource [mem 0x7f700000000-0x7f7ffffffff] (bus address [0x00000000-0xffffffff])
[  116.981787] pci_bus 0003:00: root bus resource [mem 0x7f700000000-0x7f7ffffffff] (bus address [0x00000000-0xffffffff])
[  116.981816] pci_bus 0003:00: root bus resource [bus 00]
[  116.982105] pci 0003:00:02.0: supports D1 D2
[  116.982312] pci 0003:00:02.1: supports D1 D2
[  117.000419] vgaarb: loaded
[  117.000716] SCSI subsystem initialized
[  117.001416] /pci@1e,600000/isa@7/rtc@0,70: RTC regs at 0x7fe01000070
[  117.002808] clocksource: Switched to clocksource stick
[  117.013113] NET: Registered protocol family 2
[  117.013664] TCP established hash table entries: 65536 (order: 6, 524288 bytes)
[  117.014856] TCP bind hash table entries: 65536 (order: 7, 1048576 bytes)
[  117.016971] TCP: Hash tables configured (established 65536 bind 65536)
[  117.017103] UDP hash table entries: 4096 (order: 4, 131072 bytes)
[  117.017408] UDP-Lite hash table entries: 4096 (order: 4, 131072 bytes)
[  117.017930] NET: Registered protocol family 1
[  117.018017] pci 0002:00:07.0: Activating ISA DMA hang workarounds
[  117.018058] PCI: Enabling device: (0002:00:0a.0), cmd 2
[  117.070218] PCI: Enabling device: (0002:00:0b.0), cmd 2
[  117.126216] PCI: CLS mismatch (64 != 512), using 64 bytes
[  117.126445] power: Control reg at 7fe01000800
[  117.126908] chmc: UltraSPARC-IIIi memory controller at /memory-controller@0,0
[  117.126951] chmc: UltraSPARC-IIIi memory controller at /memory-controller@1,0
[  117.126988] chmc: UltraSPARC-IIIi memory controller at /memory-controller@2,0
[  117.127024] chmc: UltraSPARC-IIIi memory controller at /memory-controller@3,0
[  117.127942] futex hash table entries: 1024 (order: 3, 65536 bytes)
[  117.128189] audit: initializing netlink subsys (disabled)
[  117.128260] audit: type=2000 audit(0.284:1): initialized
[  117.141790] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[  117.141839] io scheduler noop registered
[  117.141996] io scheduler cfq registered (default)
[  117.142719] f00ac054: ttyS0 at MMIO 0x7fe010003f8 (irq = 20, base_baud = 115387) is a 16550A
[  117.142752] Console: ttyS0 (SU)
[  129.254553] console [ttyS0] enabled
[  129.300599] f00adba8: ttyS1 at MMIO 0x7fe010002e8 (irq = 20, base_baud = 115387) is a 16550A
[  129.412172] Fusion MPT base driver 3.04.20
[  129.465983] Copyright (c) 1999-2008 LSI Corporation
[  129.530058] Fusion MPT SPI Host driver 3.04.20
[  129.588702] mptbase: ioc0: Initiating bringup
[  130.122188] ioc0: LSI53C1030 B2: Capabilities={Initiator}
[  130.775735] scsi host0: ioc0: LSI53C1030 B2, FwRev=01030b01h, Ports=1, MaxQ=222, IRQ=31
[  132.308056] scsi 0:0:0:0: Direct-Access     SEAGATE  ST373307LSUN72G  0507 PQ: 0 ANSI: 3
[  132.414547] scsi target0:0:0: Beginning Domain Validation
[  132.497084] scsi target0:0:0: Ending Domain Validation
[  132.564645] scsi target0:0:0: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
[  132.707501] sd 0:0:0:0: [sda] 143374738 512-byte logical blocks: (73.4 GB/68.4 GiB)
[  132.959151] sd 0:0:0:0: [sda] Write Protect is off
[  133.022135] sd 0:0:0:0: [sda] Mode Sense: db 00 10 08
[  133.024436] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, supports DPO and FUA
[  133.024963] scsi 0:0:2:0: Direct-Access     SEAGATE  ST336607LSUN36G  0707 PQ: 0 ANSI: 3
[  133.024976] scsi target0:0:2: Beginning Domain Validation
[  133.036494] scsi target0:0:2: Ending Domain Validation
[  133.036573] scsi target0:0:2: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
[  133.528315]  sda: sda1 sda3 sda4
[  133.535658] sd 0:0:2:0: [sdb] 71132959 512-byte logical blocks: (36.4 GB/33.9 GiB)
[  133.537542] scsi 0:0:3:0: Direct-Access     FUJITSU  MAP3735N SUN72G  0401 PQ: 0 ANSI: 4
[  133.537557] scsi target0:0:3: Beginning Domain Validation
[  133.539185] sd 0:0:2:0: [sdb] Write Protect is off
[  133.539193] sd 0:0:2:0: [sdb] Mode Sense: db 00 10 08
[  133.543129] sd 0:0:2:0: [sdb] Write cache: disabled, read cache: enabled, supports DPO and FUA
[  133.556393] scsi target0:0:3: Ending Domain Validation
[  133.556471] scsi target0:0:3: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI PCOMP (6.25 ns, offset 127)
[  133.567503] sd 0:0:2:0: [sdb] Attached SCSI disk
[  134.278792] sd 0:0:0:0: [sda] Attached SCSI disk
[  134.597849] sd 0:0:3:0: [sdc] 143374738 512-byte logical blocks: (73.4 GB/68.4 GiB)
[  134.949155] sd 0:0:3:0: [sdc] Write Protect is off
[  135.012093] sd 0:0:3:0: [sdc] Mode Sense: b3 00 00 08
[  135.700334] sd 0:0:3:0: [sdc] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[  137.206280] mptbase: ioc1: Initiating bringup
[  137.742193] ioc1: LSI53C1030 B2: Capabilities={Initiator}
[  138.395846] scsi host1: ioc1: LSI53C1030 B2, FwRev=01030b01h, Ports=1, MaxQ=222, IRQ=32
[  139.926447] sd 0:0:3:0: [sdc] Attached SCSI disk
[  143.685531] Fusion MPT misc device (ioctl) driver 3.04.20
[  143.756675] mptctl: Registered with Fusion MPT base driver
[  143.828800] mptctl: /dev/mptctl @ (major,minor=10,220)
[  143.897480] rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
[  143.981065] rtc_cmos rtc_cmos: no alarms, 114 bytes nvram
[  144.052419] hidraw: raw HID events driver (C) Jiri Kosina
[  144.123946] NET: Registered protocol family 17
[  144.182396] Key type dns_resolver registered
[  144.239173] registered taskstats version 1
[  144.294017] Key type encrypted registered
[  144.347070] console [netcon0] enabled
[  144.395115] netconsole: network logging started
[  144.454645] rtc_cmos rtc_cmos: setting system clock to 2016-02-22 07:17:02 UTC (1456125422)
[  144.575662] EXT4-fs (sda1): couldn't mount as ext3 due to feature incompatibilities
[  144.677526] EXT4-fs (sda1): couldn't mount as ext2 due to feature incompatibilities
[  144.806601] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[  144.907391] VFS: Mounted root (ext4 filesystem) readonly on device 8:1.
[  145.013434] devtmpfs: mounted
[  145.664808] stty (628) used greatest stack depth: 8184 bytes left
[  146.671883] random: udevd urandom read with 30 bits of entropy available
[  147.339434] cassini: cassini.c:v1.6 (21 May 2008)
[  147.401590] PCI: Enabling device: (0000:00:02.0), cmd 146
[  147.402538] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[  147.404333] sd 0:0:0:0: Attached scsi generic sg0 type 0
[  147.404479] sd 0:0:2:0: Attached scsi generic sg1 type 0
[  147.404583] sd 0:0:3:0: Attached scsi generic sg2 type 0
[  147.406018] cassini 0000:00:02.0 eth0: Sun Cassini+ (64bit/66MHz PCI/Cu) Ethernet[6] 00:03:ba:6f:14:39
[  147.406609] PCI: Enabling device: (0003:00:01.0), cmd 146
[  147.411558] cassini 0003:00:01.0 eth1: Sun Cassini+ (64bit/66MHz PCI/Cu) Ethernet[29] 00:03:ba:6f:14:3a
[  147.414885] libata version 3.00 loaded.
[  147.438513] PCI: Enabling device: (0002:00:0d.0), cmd 5
[  147.439788] scsi host2: pata_ali
[  147.440218] scsi host3: pata_ali
[  147.440388] ata1: PATA max UDMA/100 cmd 0x7fe01000900 ctl 0x7fe01000918 bmdma 0x7fe01000920 irq 23
[  147.440391] ata2: PATA max UDMA/100 cmd 0x7fe01000910 ctl 0x7fe01000908 bmdma 0x7fe01000928 irq 23
[  147.546679] usbcore: registered new interface driver usbfs
[  147.546725] usbcore: registered new interface driver hub
[  147.546788] usbcore: registered new device driver usb
[  147.556609] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[  147.570536] ohci-pci: OHCI PCI platform driver
[  147.570625] ohci-pci 0002:00:0a.0: OHCI PCI host controller
[  147.570651] ohci-pci 0002:00:0a.0: new USB bus registered, assigned bus number 1
[  147.570762] ohci-pci 0002:00:0a.0: irq 21, io mem 0x7ff01000000
[  147.628847] net.agent (788) used greatest stack depth: 7056 bytes left
[  147.630551] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
[  147.630557] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  147.630560] usb usb1: Product: OHCI PCI host controller
[  147.630564] usb usb1: Manufacturer: Linux 4.5.0-rc5-dirty ohci_hcd
[  147.630568] usb usb1: SerialNumber: 0002:00:0a.0
[  147.631140] hub 1-0:1.0: USB hub found
[  147.631169] hub 1-0:1.0: 2 ports detected
[  147.631561] ohci-pci 0002:00:0b.0: OHCI PCI host controller
[  147.631579] ohci-pci 0002:00:0b.0: new USB bus registered, assigned bus number 2
[  147.631697] ohci-pci 0002:00:0b.0: irq 22, io mem 0x7ff02000000
[  147.663052] ata1.00: ATAPI: TOSHIBA DVD-ROM SD-C2612, 1011, max UDMA/33
[  147.663061] ata1.00: WARNING: ATAPI DMA disabled for reliability issues.  It can be enabled
[  147.663064] ata1.00: WARNING: via pata_ali.atapi_dma modparam or corresponding sysfs node.
[  147.686516] ata1.00: configured for UDMA/33
[  147.690326] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[  147.690331] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  147.690335] usb usb2: Product: OHCI PCI host controller
[  147.690338] usb usb2: Manufacturer: Linux 4.5.0-rc5-dirty ohci_hcd
[  147.690341] usb usb2: SerialNumber: 0002:00:0b.0
[  147.690798] hub 2-0:1.0: USB hub found
[  147.690826] hub 2-0:1.0: 2 ports detected
[  147.697727] scsi 2:0:0:0: CD-ROM            TOSHIBA  DVD-ROM SD-C2612 1011 PQ: 0 ANSI: 5
[  147.708414] scsi 2:0:0:0: Attached scsi generic sg3 type 5
[  148.005774] sr 2:0:0:0: [sr0] scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
[  148.005779] cdrom: Uniform CD-ROM driver Revision: 3.20
[  148.006471] sr 2:0:0:0: Attached scsi CD-ROM sr0
[  148.394794] ata_id (802) used greatest stack depth: 6920 bytes left
[  150.958294] alim7101_wdt: Detected old alim7101 revision 'a1d'.  If this is a cobalt board, set the 'use_gpio' module parameter.
[  151.142624] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[  151.213640] alim7101_wdt: Detected old alim7101 revision 'a1d'.  If this is a cobalt board, set the 'use_gpio' module parameter.
[  151.728013] Adding 3083320k swap on /dev/sda4.  Priority:-1 extents:1 across:3083320k 
[  151.890486] EXT4-fs (sda1): re-mounted. Opts: (null)
[  152.134658] EXT4-fs (sda1): re-mounted. Opts: errors=remount-ro
[  152.880966] loop: module loaded
[  153.750207] cassini 0000:00:02.0 eth0: Link up at 100 Mbps, full-duplex
[  153.837164] cassini 0000:00:02.0 eth0: Pause is disabled
[  153.903415] NET: Registered protocol family 10
[  153.966278] ip (1467) used greatest stack depth: 6856 bytes left
[  154.396019] rc (627) used greatest stack depth: 6792 bytes left
[  156.914123] udevd (760) used greatest stack depth: 5672 bytes left
[  264.306492] random: nonblocking pool is initialized
[ 5059.654398] kworker/dying (161) used greatest stack depth: 5096 bytes left
[37804.370601] BUG: Bad rss-counter state mm:fff000000071e1c0 idx:1 val:2
[37804.456516] BUG: non-zero nr_ptes on freeing mm: 1
[37804.519501] BUG: non-zero nr_pmds on freeing mm: 1
[41966.759068] Unable to handle kernel NULL pointer dereference
[41966.833581] tsk->{mm,active_mm}->context = 00000000000009ae
[41966.906861] tsk->{mm,active_mm}->pgd = fff000000401c000
[41966.975769]               \|/ ____ \|/
                             "@'/ .. \`@"
                             /_| \__/ |_\
                                \__U_/
[41967.169142] khugepaged(238): Oops [#1]
[41967.218401] CPU: 3 PID: 238 Comm: khugepaged Not tainted 4.5.0-rc5-dirty #456
[41967.312193] task: fff000223c910f80 ti: fff000223dc30000 task.ti: fff000223dc30000
[41967.410590] TSTATE: 0000004480001604 TPC: 0000000000496da4 TNPC: 0000000000496dbc Y: 00000000    Not tainted
[41967.539957] TPC: <down_read_trylock+0x4/0x40>
[41967.597236] g0: 0000000000000001 g1: 0000000000000000 g2: 0000000000000000 g3: 000c0000000cbe80
[41967.711626] g4: fff000223c910f80 g5: fff000223f0d0000 g6: fff000223dc30000 g7: 0000000000000000
[41967.826023] o0: 0000000000000008 o1: 0000000000000002 o2: 000000000095d800 o3: 00000000009fa7a0
[41967.940511] o4: 000c00000030c5f0 o5: 00000000009fa830 sp: fff000223dc32be1 ret_pc: 0000000000522cc4
[41968.059488] RPC: <page_lock_anon_vma_read+0x64/0x320>
[41968.125919] l0: 00000000009fa7a0 l1: 0000000000000000 l2: 000c00000030af08 l3: fff0000002a3ef88
[41968.240315] l4: 0000000000000000 l5: 8000000000000000 l6: 0000000000000000 l7: 0000000000000008
[41968.354711] i0: 000c0000000cbe80 i1: 0000000000000000 i2: 0000000000000008 i3: fff000223b9485f0
[41968.469203] i4: fff000223b9485f1 i5: 000c0000000cbe80 i6: fff000223dc32c91 i7: 00000000005230fc
[41968.583697] I7: <rmap_walk+0x17c/0x400>
[41968.634116] Call Trace:
[41968.666142]  [00000000005230fc] rmap_walk+0x17c/0x400
[41968.732533]  [000000000052374c] try_to_unmap+0x6c/0x180
[41968.801242]  [0000000000539fa8] migrate_pages+0x328/0x7e0
[41968.872273]  [000000000050fb98] compact_zone+0x458/0x640
[41968.942146]  [000000000050fdd8] compact_zone_order+0x58/0x80
[41969.016493]  [0000000000510430] try_to_compact_pages+0xd0/0x240
[41969.094272]  [00000000004f392c] __alloc_pages_direct_compact+0x2c/0x160
[41969.181213]  [00000000004f4294] __alloc_pages_nodemask+0x834/0xa20
[41969.262689]  [000000000053c0cc] khugepaged+0x72c/0x1400
[41969.331379]  [0000000000478128] kthread+0xa8/0xe0
[41969.393142]  [00000000004060e4] ret_from_fork+0x1c/0x2c
[41969.461778]  [0000000000000000]           (null)
[41969.522391] Disabling lock debugging due to kernel taint
[41969.592178] Caller[00000000005230fc]: rmap_walk+0x17c/0x400
[41969.665380] Caller[000000000052374c]: try_to_unmap+0x6c/0x180
[41969.740888] Caller[0000000000539fa8]: migrate_pages+0x328/0x7e0
[41969.818663] Caller[000000000050fb98]: compact_zone+0x458/0x640
[41969.895307] Caller[000000000050fdd8]: compact_zone_order+0x58/0x80
[41969.976521] Caller[0000000000510430]: try_to_compact_pages+0xd0/0x240
[41970.061176] Caller[00000000004f392c]: __alloc_pages_direct_compact+0x2c/0x160
[41970.154967] Caller[00000000004f4294]: __alloc_pages_nodemask+0x834/0xa20
[41970.243048] Caller[000000000053c0cc]: khugepaged+0x72c/0x1400
[41970.318559] Caller[0000000000478128]: kthread+0xa8/0xe0
[41970.387286] Caller[00000000004060e4]: ret_from_fork+0x1c/0x2c
[41970.462786] Caller[0000000000000000]:           (null)
[41970.530269] Instruction DUMP: 01000000  01000000  10680007 <c45a0000> c3f21002  80a08001  22600008  90102001  c45a0000 
[49483.789891] Unable to handle kernel NULL pointer dereference
[49483.864349] tsk->{mm,active_mm}->context = 00000000000019d6
[49483.937666] tsk->{mm,active_mm}->pgd = fff000000403c000
[49484.006366]               \|/ ____ \|/
                             "@'/ .. \`@"
                             /_| \__/ |_\
                                \__U_/
[49484.199719] git(24995): Oops [#2]
[49484.243252] CPU: 3 PID: 24995 Comm: git Tainted: G      D         4.5.0-rc5-dirty #456
[49484.347362] task: fff00000044c8f80 ti: fff000000077c000 task.ti: fff000000077c000
[49484.445830] TSTATE: 0000004411001600 TPC: 0000000000496da4 TNPC: 0000000000496dbc Y: 00000000    Tainted: G      D        
[49484.591131] TPC: <down_read_trylock+0x4/0x40>
[49484.648409] g0: fff000223d47cc98 g1: 0000000000000000 g2: 0000000000000000 g3: 000c0000001ce018
[49484.762908] g4: fff00000044c8f80 g5: fff000223f0d0000 g6: fff000000077c000 g7: 0000000300000000
[49484.877397] o0: 0000000000000008 o1: fff00000357fb8c8 o2: 0000000000000004 o3: 0000000000000001
[49484.991904] o4: fff0000014eb2000 o5: 0000000000000000 sp: fff000000077ec21 ret_pc: 0000000000522cc4
[49485.110966] RPC: <page_lock_anon_vma_read+0x64/0x320>
[49485.177406] l0: fff000223d0b0268 l1: 00000000009fa7a0 l2: 0000000300000045 l3: fff00000028d38a0
[49485.291906] l4: 0000000000000000 l5: 8000000000000000 l6: 0000000000000001 l7: 0000000000000008
[49485.406595] i0: 000c0000001ce018 i1: 000c0000002f10dc i2: 0000000000000008 i3: fff000223b9485f0
[49485.520994] i4: fff000223b9485f1 i5: 000c0000001ce018 i6: fff000000077ecd1 i7: 00000000005230fc
[49485.635479] I7: <rmap_walk+0x17c/0x400>
[49485.685801] Call Trace:
[49485.717828]  [00000000005230fc] rmap_walk+0x17c/0x400
[49485.784187]  [000000000052374c] try_to_unmap+0x6c/0x180
[49485.852812]  [0000000000539fa8] migrate_pages+0x328/0x7e0
[49485.923742]  [000000000050fb98] compact_zone+0x458/0x640
[49485.993612]  [000000000050fdd8] compact_zone_order+0x58/0x80
[49486.067974]  [0000000000510430] try_to_compact_pages+0xd0/0x240
[49486.145859]  [00000000004f392c] __alloc_pages_direct_compact+0x2c/0x160
[49486.232789]  [00000000004f3e98] __alloc_pages_nodemask+0x438/0xa20
[49486.314007]  [000000000053dd2c] do_huge_pmd_anonymous_page+0x10c/0x520
[49486.399812]  [0000000000518c34] handle_mm_fault+0xbb4/0x14e0
[49486.474268]  [000000000044dd3c] do_sparc64_fault+0x43c/0x720
[49486.548713]  [0000000000407c30] sparc64_realfault_common+0x10/0x20
[49486.629931] Caller[00000000005230fc]: rmap_walk+0x17c/0x400
[49486.703246] Caller[000000000052374c]: try_to_unmap+0x6c/0x180
[49486.778740] Caller[0000000000539fa8]: migrate_pages+0x328/0x7e0
[49486.856521] Caller[000000000050fb98]: compact_zone+0x458/0x640
[49486.933164] Caller[000000000050fdd8]: compact_zone_order+0x58/0x80
[49487.014386] Caller[0000000000510430]: try_to_compact_pages+0xd0/0x240
[49487.099029] Caller[00000000004f392c]: __alloc_pages_direct_compact+0x2c/0x160
[49487.192824] Caller[00000000004f3e98]: __alloc_pages_nodemask+0x438/0xa20
[49487.280913] Caller[000000000053dd2c]: do_huge_pmd_anonymous_page+0x10c/0x520
[49487.373664] Caller[0000000000518c34]: handle_mm_fault+0xbb4/0x14e0
[49487.454883] Caller[000000000044dd3c]: do_sparc64_fault+0x43c/0x720
[49487.536103] Caller[0000000000407c30]: sparc64_realfault_common+0x10/0x20
[49487.624366] Caller[00000000f4fffbfc]: 0xf4fffbfc
[49487.685011] Instruction DUMP: 01000000  01000000  10680007 <c45a0000> c3f21002  80a08001  22600008  90102001  c45a0000 

-- 
Meelis Roos (mroos@linux.ee)
