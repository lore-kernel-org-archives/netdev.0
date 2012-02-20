From: Meelis Roos <mroos@linux.ee>
Subject: 3.3-rc3+ Crash in __neigh_for_each_release
Date: Mon, 20 Feb 2012 14:02:24 +0200 (EET)
Message-ID: <alpine.SOC.1.00.1202201359190.8004@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:38029 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753400Ab2BTMWF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 07:22:05 -0500
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp2.it.da.ut.ee (Postfix) with ESMTP id BB94373D96E
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 14:02:24 +0200 (EET)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id 848BA427977
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 14:02:24 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just tried 3.3-rc3+git and 3.3-rc4 on a generic i815+P3+e100 PC. It 
crashes consistently during the end of bootup, getning oops in 
__neigh_for_each_release during timer softirq. 3.2 works fine.

[    0.000000] Linux version 3.3.0-rc4 (mroos@rhn) (gcc version 4.6.2 (Debian 4.6.2-14) ) #16 PREEMPT Mon Feb 20 14:17:04 EET 2012
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000000fec0000 (usable)
[    0.000000]  BIOS-e820: 000000000fec0000 - 000000000fef8000 (ACPI data)
[    0.000000]  BIOS-e820: 000000000fef8000 - 000000000ff00000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000ffb80000 - 00000000ffc00000 (reserved)
[    0.000000]  BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
[    0.000000] Notice: NX (Execute Disable) protection missing in CPU!
[    0.000000] DMI 2.3 present.
[    0.000000] last_pfn = 0xfec0 max_arch_pfn = 0x100000
[    0.000000] PAT not supported by CPU.
[    0.000000] total RAM covered: 255M
[    0.000000] Found optimal setting for mtrr clean up
[    0.000000]  gran_size: 64K 	chunk_size: 2M 	num_reg: 2  	lose cover RAM: 0G
[    0.000000] init_memory_mapping: 0000000000000000-000000000fec0000
[    0.000000] ACPI: RSDP 000ff980 00014 (v00 AMI   )
[    0.000000] ACPI: RSDT 0fef0000 0002C (v01 D815EA D815EEA2 20021106 MSFT 00001011)
[    0.000000] ACPI: FACP 0fef1000 00074 (v01 D815EA EA81510A 20021106 MSFT 00001011)
[    0.000000] ACPI: DSDT 0fee0000 030E4 (v01 D815E2 EA81520A 00000023 MSFT 0100000B)
[    0.000000] ACPI: FACS 0fef8000 00040
[    0.000000] ACPI: SSDT 0fee30e4 00035 (v01 D815EA EA81510A 00000015 MSFT 0100000B)
[    0.000000] 254MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fec0000
[    0.000000]   low ram: 0 - 0fec0000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x0000fec0
[    0.000000] Movable zone start PFN for each node
[    0.000000] Early memory PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0000fec0
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] Found and enabled local APIC!
[    0.000000] Allocating PCI resources starting at ff00000 (gap: ff00000:efc80000)
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64593
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.3.0-rc4 root=/dev/sda1 ro lapic netconsole=1980@192.168.74.17/eth0,1975@192.168.74.24/00:50:8d:91:d9:f0
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Memory: 253772k/260864k available (2381k kernel code, 6640k reserved, 1365k data, 284k init, 0k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffe3000 - 0xfffff000   ( 112 kB)
[    0.000000]     vmalloc : 0xd06c0000 - 0xfffe1000   ( 761 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xcfec0000   ( 254 MB)
[    0.000000]       .init : 0xc13a9000 - 0xc13f0000   ( 284 kB)
[    0.000000]       .data : 0xc1253600 - 0xc13a8d20   (1365 kB)
[    0.000000]       .text : 0xc1000000 - 0xc1253600   (2381 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 930.270 MHz processor.
[    0.008004] Calibrating delay loop (skipped), value calculated using timer frequency.. 1860.54 BogoMIPS (lpj=3721080)
[    0.008208] pid_max: default: 32768 minimum: 301
[    0.008426] Mount-cache hash table entries: 512
[    0.008800] mce: CPU supports 5 MCE banks
[    0.008931] CPU: Intel Pentium III (Coppermine) stepping 06
[    0.009089] ACPI: Core revision 20120111
[    0.014061] ACPI: setting ELCR to 0200 (from 0e00)
[    0.015242] Performance Events: p6 PMU driver.
[    0.015358] ... version:                0
[    0.015450] ... bit width:              32
[    0.015543] ... generic registers:      2
[    0.015635] ... value mask:             00000000ffffffff
[    0.015731] ... max period:             000000007fffffff
[    0.015828] ... fixed-purpose events:   0
[    0.015921] ... event mask:             0000000000000003
[    0.016210] NMI watchdog enabled, takes one hw-pmu counter.
[    0.020001] NET: Registered protocol family 16
[    0.020001] ACPI: bus type pci registered
[    0.020001] PCI: PCI BIOS revision 2.10 entry at 0xfda95, last bus=1
[    0.020001] PCI: Using configuration type 1 for base access
[    0.025178] bio: create slab <bio-0> at 0
[    0.025598] ACPI: Added _OSI(Module Device)
[    0.025700] ACPI: Added _OSI(Processor Device)
[    0.025801] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.025901] ACPI: Added _OSI(Processor Aggregator Device)
[    0.029021] ACPI: Executed 1 blocks of module-level executable AML code
[    0.035893] ACPI: Interpreter enabled
[    0.036019] ACPI: (supports S0 S5)
[    0.036150] ACPI: Using PIC for interrupt routing
[    0.040239] ACPI: Power Resource [FDDP] (off)
[    0.041042] ACPI: Power Resource [URP1] (off)
[    0.041866] ACPI: Power Resource [URP2] (off)
[    0.042263] ACPI: Power Resource [LPTP] (off)
[    0.047848] ACPI: No dock devices found.
[    0.047978] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.048729] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.049988] PCI host bridge to bus 0000:00
[    0.050089] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.050189] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffff]
[    0.051366] pci 0000:00:1e.0: PCI bridge to [bus 01-01] (subtractive decode)
[    0.052417]  pci0000:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.056124] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12)
[    0.056466] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *9 10 11 12)
[    0.056792] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 12) *0, disabled.
[    0.057213] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11 12)
[    0.057534] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 *11 12)
[    0.057859] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12) *0, disabled.
[    0.058280] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12) *0, disabled.
[    0.058700] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 *10 11 12)
[    0.059320] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.059516] vgaarb: loaded
[    0.059610] vgaarb: bridge control possible 0000:00:02.0
[    0.060247] SCSI subsystem initialized
[    0.061156] PCI: Using ACPI for IRQ routing
[    0.062055] pnp: PnP ACPI init
[    0.062176] ACPI: bus type pnp registered
[    0.069500] system 00:0c: [mem 0x00000000-0x0009ffff] could not be reserved
[    0.069620] system 00:0c: [mem 0x000e0000-0x000fffff] could not be reserved
[    0.069729] system 00:0c: [mem 0x00100000-0x0fefffff] could not be reserved
[    0.069863] pnp: PnP ACPI: found 13 devices
[    0.069963] ACPI: ACPI bus type pnp unregistered
[    0.111918] Switching to clocksource acpi_pm
[    0.112079] pci 0000:00:1e.0: PCI bridge to [bus 01-01]
[    0.112185] pci 0000:00:1e.0:   bridge window [io  0xd000-0xdfff]
[    0.112296] pci 0000:00:1e.0:   bridge window [mem 0xff800000-0xff8fffff]
[    0.112405] pci 0000:00:1e.0:   bridge window [mem 0xf6a00000-0xf6afffff pref]
[    0.112807] NET: Registered protocol family 2
[    0.113046] IP route cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.113392] TCP established hash table entries: 8192 (order: 4, 65536 bytes)
[    0.113707] TCP bind hash table entries: 8192 (order: 3, 32768 bytes)
[    0.113911] TCP: Hash tables configured (established 8192 bind 8192)
[    0.114014] TCP reno registered
[    0.114113] UDP hash table entries: 256 (order: 0, 4096 bytes)
[    0.114226] UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
[    0.114498] NET: Registered protocol family 1
[    0.114737] pci 0000:01:08.0: Firmware left e100 interrupts enabled; disabling
[    0.117097] VFS: Disk quotas dquot_6.5.2
[    0.117248] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    0.117552] msgmni has been set to 495
[    0.118165] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    0.118358] io scheduler noop registered
[    0.118481] io scheduler cfq registered (default)
[    0.119025] Serial: 8250/16550 driver, 16 ports, IRQ sharing enabled
[    0.392083] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    0.668081] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    0.690295] 00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    0.710933] 00:09: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    0.711547] Non-volatile memory driver v1.3
[    0.711654] Linux agpgart interface v0.103
[    0.711795] agpgart-intel 0000:00:00.0: Intel i815 Chipset
[    0.711941] agpgart-intel 0000:00:00.0: detected gtt size: 65536K total, 65536K mappable
[    0.712863] agpgart-intel 0000:00:00.0: AGP aperture is 64M @ 0xf8000000
[    0.713087] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[    0.713272] Hangcheck: Using getrawmonotonic().
[    0.713478] [drm] Initialized drm 1.1.0 20060810
[    0.713833] Floppy drive(s): fd0 is 1.44M
[    0.731413] FDC 0 is a post-1991 82077
[    0.734129] scsi0 : ata_piix
[    0.734521] scsi1 : ata_piix
[    0.737239] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
[    0.737358] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
[    0.737993] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    0.738097] e100: Copyright(c) 1999-2006 Intel Corporation
[    0.738511] ACPI: PCI Interrupt Link [LNKE] enabled at IRQ 11
[    0.761695] e100 0000:01:08.0: eth0: addr 0xff86f000, irq 11, MAC addr 00:03:47:a4:64:d5
[    0.762240] i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
[    0.765652] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.765844] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.766395] mousedev: PS/2 mouse device common for all mice
[    0.766827] rtc_cmos 00:02: RTC can wake from S4
[    0.767132] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[    0.767265] rtc0: alarms up to one month, 114 bytes nvram
[    0.767456] cpuidle: using governor ladder
[    0.767554] cpuidle: using governor menu
[    0.769063] TCP cubic registered
[    0.771339] NET: Registered protocol family 17
[    0.771470] Registering the dns_resolver key type
[    0.771600] Using IPI Shortcut mode
[    0.772140] netconsole: local port 1980
[    0.772244] netconsole: local IP 192.168.74.17
[    0.772343] netconsole: interface 'eth0'
[    0.772439] netconsole: remote port 1975
[    0.772536] netconsole: remote IP 192.168.74.24
[    0.772636] netconsole: remote ethernet address 00:50:8d:91:d9:f0
[    0.772787] netconsole: device eth0 not up yet, forcing it
[    0.789721] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
[    0.792173] e100 0000:01:08.0: eth0: NIC Link is Up 100 Mbps Full Duplex
[    0.796023] netconsole: carrier detect appears untrustworthy, waiting 4 seconds
[    0.956500] ata1.00: ATA-6: ST380011A, 8.01, max UDMA/100
[    0.956605] ata1.00: 156301488 sectors, multi 16: LBA48 
[    0.972370] ata1.00: configured for UDMA/100
[    0.972800] scsi 0:0:0:0: Direct-Access     ATA      ST380011A        8.01 PQ: 0 ANSI: 5
[    0.973638] sd 0:0:0:0: [sda] 156301488 512-byte logical blocks: (80.0 GB/74.5 GiB)
[    0.973964] sd 0:0:0:0: [sda] Write Protect is off
[    0.974129] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    0.995686]  sda: sda1 sda2 sda3
[    0.996805] sd 0:0:0:0: [sda] Attached SCSI disk
[    1.112032] Refined TSC clocksource calibration: 930.314 MHz.
[    1.112149] Switching to clocksource tsc
[    4.801225] console [netcon0] enabled
[    4.801357] netconsole: network logging started
[    4.801532] rtc_cmos 00:02: setting system clock to 2012-02-20 12:55:15 UTC (1329742515)
[    4.817157] EXT3-fs (sda1): recovery required on readonly filesystem
[    4.817290] EXT3-fs (sda1): write access will be enabled during recovery
[    5.283547] kjournald starting.  Commit interval 5 seconds
[    5.283909] EXT3-fs (sda1): recovery complete
[    5.284026] EXT3-fs (sda1): mounted filesystem with writeback data mode
[    5.284171] VFS: Mounted root (ext3 filesystem) readonly on device 8:1.
[    5.284359] Freeing unused kernel memory: 284k freed
[    5.285311] Write protecting the kernel text: 2384k
[    5.285522] Write protecting the kernel read-only data: 1196k
[    7.550607] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input1
[    7.550827] ACPI: Power Button [PBTN]
[    7.551139] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
[    7.551322] ACPI: Power Button [PWRF]
[    7.659948] parport_pc 00:0a: reported by Plug and Play ACPI
[    7.660246] parport0: PC-style at 0x378 (0x778), irq 7, dma 3 [PCSPP,TRISTATE,COMPAT,ECP,DMA]
[    7.989627] usbcore: registered new interface driver usbfs
[    7.990381] usbcore: registered new interface driver hub
[    7.991881] usbcore: registered new device driver usb
[    8.062219] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    8.140339] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 9
[    8.148670] uhci_hcd: USB Universal Host Controller Interface driver
[    8.149220] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    8.149363] uhci_hcd 0000:00:1f.2: UHCI Host Controller
[    8.149481] uhci_hcd 0000:00:1f.2: new USB bus registered, assigned bus number 1
[    8.149716] uhci_hcd 0000:00:1f.2: irq 11, io base 0x0000ef40
[    8.149910] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
[    8.150031] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    8.150223] usb usb1: Product: UHCI Host Controller
[    8.150325] usb usb1: Manufacturer: Linux 3.3.0-rc4 uhci_hcd
[    8.150434] usb usb1: SerialNumber: 0000:00:1f.2
[    8.150793] hub 1-0:1.0: USB hub found
[    8.150908] hub 1-0:1.0: 2 ports detected
[    8.151363] ACPI: PCI Interrupt Link [LNKH] enabled at IRQ 10
[    8.151504] uhci_hcd 0000:00:1f.4: UHCI Host Controller
[    8.151622] uhci_hcd 0000:00:1f.4: new USB bus registered, assigned bus number 2
[    8.151858] uhci_hcd 0000:00:1f.4: irq 10, io base 0x0000ef80
[    8.159500] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    8.159644] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    8.159874] usb usb2: Product: UHCI Host Controller
[    8.159978] usb usb2: Manufacturer: Linux 3.3.0-rc4 uhci_hcd
[    8.160141] usb usb2: SerialNumber: 0000:00:1f.4
[    8.165932] hub 2-0:1.0: USB hub found
[    8.166086] hub 2-0:1.0: 2 ports detected
[    9.396043] intel8x0_measure_ac97_clock: measured 52271 usecs (2926 samples)
[    9.396191] intel8x0: clocking to 41159
[   10.231275] Adding 1048572k swap on /dev/sda2.  Priority:-1 extents:1 across:1048572k 
[   10.476088] EXT3-fs (sda1): using internal journal
[   10.595095] NTFS driver 2.1.30 [Flags: R/W MODULE].
[   10.824763] usbcore: registered new interface driver libusual
[   10.830985] Initializing USB Mass Storage driver...
[   10.832120] usbcore: registered new interface driver usb-storage
[   10.832255] USB Mass Storage support registered.
[   10.885221] smsc47m1: Found SMSC LPC47M10x/LPC47M112/LPC47M13x
[   10.885384] ACPI Warning: 0x00000804-0x00000804 SystemIO conflicts with Region \_SB_.PCI0.SBRG.RNT3 1 (20120111/utaddress-251)
[   10.885622] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   12.766616] EXT4-fs (sda3): mounted filesystem with ordered data mode. Opts: (null)
[   13.138202] NET: Registered protocol family 8
[   13.138341] NET: Registered protocol family 20
[   15.402941] NET: Registered protocol family 10
[   17.837703] RPC: Registered named UNIX socket transport module.
[   17.837917] RPC: Registered udp transport module.
[   17.838021] RPC: Registered tcp transport module.
[   17.838125] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   17.938275] Registering the id_resolver key type
[   17.969638] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   18.725603] fuse init (API version 7.18)
[   20.391759] input: ACPI Virtual Keyboard Device as /devices/virtual/input/input3
[   20.915381] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[   20.928931] NFSD: starting 90-second grace period
[   23.179451] lp0: using parport0 (interrupt-driven).
[   23.192176] ppdev: user-space parallel port driver
[   23.264048] BUG: unable to handle kernel NULL pointer dereference at 00000004
[   23.264241] IP: [<c11e4cfa>] __neigh_for_each_release+0x7c/0x92
[   23.264385] *pde = 00000000 
[   23.264493] Oops: 0000 [#1] PREEMPT 
[   23.264616] Modules linked in: ppdev lp uinput fuse nfsd nfs lockd auth_rpcgss nfs_acl sunrpc ipv6 clip atm ext4 jbd2 adm1025 hwmon_vid hwmon usb_storage usb_libusual udf crc_itu_t isofs zlib_inflate vfat fat eeprom ntfs snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd uhci_hcd i2c_i801 ehci_hcd evdev serio_raw usbcore usb_common soundcore snd_page_alloc parport_pc parport button processor
[   23.265997] 
[   23.266098] Pid: 0, comm: swapper Not tainted 3.3.0-rc4 #16                  /D815EEA2                       
[   23.266330] EIP: 0060:[<c11e4cfa>] EFLAGS: 00010286 CPU: 0
[   23.266438] EIP is at __neigh_for_each_release+0x7c/0x92
[   23.266544] EAX: d08f036c EBX: 00000000 ECX: 00000000 EDX: d08edf38
[   23.266655] ESI: 00000000 EDI: d08ede2b EBP: cf809f78 ESP: cf809f60
[   23.266766]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
[   23.266875] Process swapper (pid: 0, ti=cf808000 task=c1388460 task.ti=c1380000)
[   23.267065] Stack:
[   23.267163]  cf97d8a0 cf97d8a0 d08edf38 00000100 c141bc80 d08ede2b cf809f80 d08ede47
[   23.267455]  cf809fc4 c1022309 cf809fac c118a00d cf809fac c1030e0e cd5dc390 00000001
[   23.267756]  c141c68c c141c48c 00000000 cf809fb0 cf809fb0 cf809fb0 c141bb5c 00000001
[   23.268004] Call Trace:
[   23.268004]  [<d08edf38>] ? clip_seq_show+0x3b/0x3b [clip]
[   23.268004]  [<d08ede2b>] ? clip_seq_start+0x21/0x21 [clip]
[   23.268004]  [<d08ede47>] idle_timer_check+0x1c/0x4a [clip]
[   23.268004]  [<c1022309>] run_timer_softirq+0x140/0x1de
[   23.268004]  [<c118a00d>] ? scsi_softirq_done+0xbf/0xc7
[   23.268004]  [<c1030e0e>] ? put_cred_rcu+0x6f/0x76
[   23.268004]  [<c101e24a>] __do_softirq+0x5f/0xe8
[   23.268004]  [<c101e1eb>] ? send_remote_softirq+0x18/0x18
[   23.268004]  <IRQ> 
[   23.268004]  [<c101e44b>] ? irq_exit+0x34/0x8b
[   23.268004]  [<c1012644>] ? smp_apic_timer_interrupt+0x6e/0x79
[   23.268004]  [<c125225d>] ? apic_timer_interrupt+0x31/0x38
[   23.268004]  [<c1006f7e>] ? default_idle+0x29/0x3e
[   23.268004]  [<c1001574>] ? cpu_idle+0x73/0xa6
[   23.268004]  [<c1243453>] ? rest_init+0x77/0x79
[   23.268004]  [<c13a9653>] ? start_kernel+0x296/0x29c
[   23.268004]  [<c13a91ca>] ? obsolete_checksetup+0x8b/0x8b
[   23.268004]  [<c13a9044>] ? i386_start_kernel+0x44/0x46
[   23.268004] Code: 14 8b 52 08 f6 c2 08 74 0b 89 45 e8 e8 31 ca 06 00 8b 45 e8 85 c0 74 07 89 f8 e8 5c ff ff ff 8b 3b 85 ff 75 b2 89 f3 8b 75 ec 43 <8b> 4e 04 b8 01 00 00 00 d3 e0 39 c3 7c 8c 83 c4 0c 5b 5e 5f 5d 
[   23.268004] EIP: [<c11e4cfa>] __neigh_for_each_release+0x7c/0x92 SS:ESP 0068:cf809f60
[   23.268004] CR2: 0000000000000004
[   23.271899] ---[ end trace f4b1cbf2fb401c6c ]---
[   23.272011] Kernel panic - not syncing: Fatal exception in interrupt

-- 
Meelis Roos (mroos@linux.ee)
