From: Meelis Roos <mroos@linux.ee>
Subject: suspicious RCU usage warnings in 3.3.0
Date: Wed, 28 Mar 2012 11:45:48 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1203281134090.13691@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This v3.3 release running on sparc64 UP (Sun Fire V100). Today I noticed 
it has gotten a bunch on RCU warnings from different netowrk-related 
places. Some are from tulip irq's, some are from network-related 
softirqs.

Is this the same RCU problem that was fixed after 3.3 (fix a potential 
rcu_read_lock() imbalance in rt6_fill_node())? My problem does not seem 
to be ipv6-only, most traces are from IPv6 but some for ip.

[    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.0.18 2002/05/23 18:22'
[    0.000000] PROMLIB: Root node compatible: sun4u
[    0.000000] Linux version 3.3.0 (mroos@janku) (gcc version 4.6.2 (Debian 4.6.2-9) ) #34 Mon Mar 19 13:26:20 EET 2012
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] bootconsole [earlyprom0] enabled
[    0.000000] ARCH: SUN4U
[    0.000000] Ethernet address: 00:03:ba:11:b3:71
[    0.000000] Kernel: Using 4 locked TLB entries for main kernel image.
[    0.000000] Remapping the kernel... done.
[    0.000000] OF stdout device is: /pci@1f,0/isa@7/serial@0,3f8
[    0.000000] PROM: Built device tree with 46445 bytes of memory.
[    0.000000] Top of RAM: 0x6fec6000, Total RAM: 0x3fe34000
[    0.000000] Memory hole size: 768MB
[    0.000000] [0000010000000000-fffff80000400000] page_structs=131072 node=0 entry=0/8192
[    0.000000] [0000010000000000-fffff80000800000] page_structs=131072 node=0 entry=1/8192
[    0.000000] [0000010000800000-fffff80000c00000] page_structs=131072 node=0 entry=2/8192
[    0.000000] [0000010000800000-fffff80001000000] page_structs=131072 node=0 entry=3/8192
[    0.000000] Zone PFN ranges:
[    0.000000]   Normal   0x00000000 -> 0x00037f63
[    0.000000] Movable zone start PFN for each node
[    0.000000] Early memory PFN ranges
[    0.000000]     0: 0x00000000 -> 0x00008000
[    0.000000]     0: 0x00010000 -> 0x00018000
[    0.000000]     0: 0x00020000 -> 0x00028000
[    0.000000]     0: 0x00030000 -> 0x000377ff
[    0.000000]     0: 0x00037800 -> 0x00037f00
[    0.000000]     0: 0x00037f40 -> 0x00037f58
[    0.000000]     0: 0x00037f60 -> 0x00037f63
[    0.000000] On node 0 totalpages: 130842
[    0.000000]   Normal zone: 1791 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 129051 pages, LIFO batch:15
[    0.000000] Booting Linux...
[    0.000000] CPU CAPS: [flush,stbar,swap,muldiv,v9,mul32,div32,v8plus]
[    0.000000] CPU CAPS: [vis]
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 129051
[    0.000000] Kernel command line: ro root=/dev/sda2 debug ignore_loglevel
[    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 1048576 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 524288 bytes)
[    0.000000] Memory: 1014928k available (3208k kernel code, 1536k data, 168k init) [fffff80000000000,000000006fec6000]
[    0.000000] NR_IRQS:255
[    0.000000] clocksource: mult[b400012e] shift[24]
[    0.000000] clockevent: mult[16c16bf] shift[32]
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled, bootconsole disabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 5855 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[   69.989909] Calibrating delay using timer specific routine.. 11.14 BogoMIPS (lpj=55721)
[   69.989978] pid_max: default: 32768 minimum: 301
[   69.990421] Security Framework initialized
[   69.990686] Mount-cache hash table entries: 512
[   69.998008] NET: Registered protocol family 16
[   69.999740] kworker/u:0 used greatest stack depth: 11056 bytes left
[   70.042048] /pci@1f,0: PCI IO[1fe02000000] MEM[1ff00000000]
[   70.042305] /pci@1f,0: SABRE PCI Bus Module ver[0:0]
[   70.042350] PCI: Scanning PBM /pci@1f,0
[   70.043882] sabre f0069d48: PCI host bridge to bus 0000:00
[   70.043947] pci_bus 0000:00: root bus resource [io  0x1fe02000000-0x1fe02ffffff]
[   70.044024] pci_bus 0000:00: root bus resource [mem 0x1ff00000000-0x1ffffffffff]
[   70.044608] pci 0000:00:03.0: quirk: [io  0x1fe02002000-0x1fe0200203f] claimed by ali7101 ACPI
[   70.044719] pci 0000:00:03.0: quirk: [io  0x1fe02004000-0x1fe0200401f] claimed by ali7101 SMB
[   70.045066] pci 0000:00:0c.0: PME# supported from D3hot D3cold
[   70.045426] pci 0000:00:05.0: PME# supported from D3hot D3cold
[   70.088833] bio: create slab <bio-0> at 0
[   70.092136] vgaarb: loaded
[   70.094524] SCSI subsystem initialized
[   70.096642] libata version 3.00 loaded.
[   70.101859] /pci@1f,0/isa@7/rtc@0,70: RTC regs at 0x1fe02000070
[   70.105994] Switching to clocksource hbtick
[   70.157926] NET: Registered protocol family 2
[   70.159040] IP route cache hash table entries: 8192 (order: 3, 65536 bytes)
[   70.162712] TCP established hash table entries: 32768 (order: 6, 524288 bytes)
[   70.165577] TCP bind hash table entries: 32768 (order: 8, 2097152 bytes)
[   70.180171] TCP: Hash tables configured (established 32768 bind 32768)
[   70.180459] TCP reno registered
[   70.180572] UDP hash table entries: 512 (order: 3, 81920 bytes)
[   70.181234] UDP-Lite hash table entries: 512 (order: 3, 81920 bytes)
[   70.182776] NET: Registered protocol family 1
[   70.182975] pci 0000:00:07.0: Activating ISA DMA hang workarounds
[   70.183149] PCI: Enabling device: (0000:00:0a.0), cmd 2
[   70.236405] PCI: CLS 0 bytes, default 64
[   70.236950] power: Control reg at 1fe02002000
[   70.250298] Initializing RT-Tester: OK
[   70.253366] VFS: Disk quotas dquot_6.5.2
[   70.253777] Dquot-cache hash table entries: 1024 (order 0, 8192 bytes)
[   70.254961] msgmni has been set to 1982
[   70.258438] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[   70.258629] io scheduler noop registered
[   70.258797] io scheduler cfq registered (default)
[   70.258856] start plist test
[   70.265462] end plist test
[   70.267899] f0076e0c: ttyS0 at MMIO 0x1fe020003f8 (irq = 7) is a 16550A
[   70.268032] Console: ttyS0 (SU)
[   77.354042] console [ttyS0] enabled
[   77.401563] f0078af8: ttyS1 at MMIO 0x1fe020002e8 (irq = 7) is a 16550A
[   77.492787] PCI: Enabling device: (0000:00:0d.0), cmd 5
[   77.569755] scsi0 : pata_ali
[   77.610176] scsi1 : pata_ali
[   77.649634] ata1: PATA max UDMA/66 cmd 0x1fe02010200 ctl 0x1fe02010218 bmdma 0x1fe02010220 irq 12
[   77.766347] ata2: PATA max UDMA/66 cmd 0x1fe02010210 ctl 0x1fe02010208 bmdma 0x1fe02010228 irq 12
[   77.885481] Linux Tulip driver version 1.1.15-NAPI (Feb 27, 2007)
[   77.968530] tulip0: Old style EEPROM with no media selection information
[   78.057030] tulip0:  MII transceiver #1 config 3100 status 7829 advertising 01e1
[   78.173420] net eth0: Davicom DM9102/DM9102A rev 49 at MMIO 0x1ff00000000, EEPROM not present, 00:03:ba:11:b3:71, IRQ 9
[   78.318285] tulip1: Old style EEPROM with no media selection information
[   78.406657] tulip1:  MII transceiver #1 config 3100 status 7809 advertising 01e1
[   78.511567] net eth1: Davicom DM9102/DM9102A rev 49 at MMIO 0x1ff00002000, EEPROM not present, 00:03:ba:11:b3:72, IRQ 10
[   78.657071] mousedev: PS/2 mouse device common for all mice
[   78.731670] ata2.00: ATA-6: ST3120026A, 3.06, max UDMA/100
[   78.803854] ata2.00: 234441648 sectors, multi 0: LBA48 
[   78.872638] ata2.01: ATAPI: CD-224E, 1.7A, max UDMA/33
[   78.940240] ata2.01: WARNING: ATAPI DMA disabled for reliability issues.  It can be enabled
[   79.050089] ata2.01: WARNING: via pata_ali.atapi_dma modparam or corresponding sysfs node.
[   79.161120] rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
[   79.244790] rtc0: no alarms, 114 bytes nvram
[   79.309942] TCP cubic registered
[   79.352357] NET: Registered protocol family 17
[   79.410783] Registering the dns_resolver key type
[   79.473107] registered taskstats version 1
[   79.528297] console [netcon0] enabled
[   79.576470] netconsole: network logging started
[   79.636063] rtc_cmos rtc_cmos: setting system clock to 2012-03-26 05:44:04 UTC (1332740644)
[   79.766627] ata2.00: configured for UDMA/66
[   79.836331] ata2.01: configured for UDMA/33
[   79.894238] scsi 1:0:0:0: Direct-Access     ATA      ST3120026A       3.06 PQ: 0 ANSI: 5
[   80.005842] sd 1:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/111 GiB)
[   80.107941] scsi 1:0:1:0: CD-ROM            TEAC     CD-224E          1.7A PQ: 0 ANSI: 5
[   80.215833] sd 1:0:0:0: [sda] Write Protect is off
[   80.278875] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   80.348777] sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   80.475976]  sda: sda1 sda2 sda3 sda4 sda5
[   80.538214] sd 1:0:0:0: [sda] Attached SCSI disk
[   80.617886] kjournald starting.  Commit interval 5 seconds
[   80.690279] EXT3-fs (sda2): mounted filesystem with writeback data mode
[   80.777592] VFS: Mounted root (ext3 filesystem) readonly on device 8:2.
[   81.516370] modprobe used greatest stack depth: 8360 bytes left
[   82.397903] ls used greatest stack depth: 6776 bytes left
[   83.456067] ps used greatest stack depth: 8 bytes left
[   85.644918] alim7101_wdt: Steve Hill <steve@navaho.co.uk>.
[   85.717182] alim7101_wdt: Detected old alim7101 revision 'a1d'.  If this is a cobalt board, set the 'use_gpio' module parameter.
[   86.469399] usbcore: registered new interface driver usbfs
[   86.542263] usbcore: registered new interface driver hub
[   86.612699] sr0: scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
[   86.694009] cdrom: Uniform CD-ROM driver Revision: 3.20
[   86.764895] sr 1:0:1:0: Attached scsi CD-ROM sr0
[   86.869215] usbcore: registered new device driver usb
[   87.162842] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   87.244150] ohci_hcd: block sizes: ed 80 td 96
[   87.302831] ohci_hcd 0000:00:0a.0: OHCI Host Controller
[   87.372686] drivers/usb/core/inode.c: creating file 'devices'
[   87.448598] drivers/usb/core/inode.c: creating file '001'
[   87.519684] ohci_hcd 0000:00:0a.0: new USB bus registered, assigned bus number 1
[   87.617272] ohci_hcd 0000:00:0a.0: created debug files
[   87.684947] ohci_hcd 0000:00:0a.0: irq 11, io mem 0x1ff01000000
[   87.820204] ohci_hcd 0000:00:0a.0: OHCI controller state
[   87.890563] ohci_hcd 0000:00:0a.0: OHCI 1.0, NO legacy support registers, rh state running
[   87.999432] ohci_hcd 0000:00:0a.0: control 0x083 HCFS=operational CBSR=3
[   88.087610] ohci_hcd 0000:00:0a.0: cmdstatus 0x00000 SOC=0
[   88.159714] ohci_hcd 0000:00:0a.0: intrstatus 0x00000044 RHSC SF
[   88.238671] ohci_hcd 0000:00:0a.0: intrenable 0x8000000a MIE RD WDH
[   88.321303] ohci_hcd 0000:00:0a.0: hcca frame #01fa
[   88.385410] ohci_hcd 0000:00:0a.0: roothub.a 02000202 POTPGT=2 NPS NDP=2(2)
[   88.476927] ohci_hcd 0000:00:0a.0: roothub.b 00000000 PPCM=0000 DR=0000
[   88.563895] ohci_hcd 0000:00:0a.0: roothub.status 00008000 DRWE
[   88.641732] ohci_hcd 0000:00:0a.0: roothub.portstatus [0] 0x00000100 PPS
[   88.729838] ohci_hcd 0000:00:0a.0: roothub.portstatus [1] 0x00000100 PPS
[   88.818463] usb usb1: default language 0x0409
[   88.875845] usb usb1: udev 1, busnum 1, minor = 0
[   88.937666] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
[   89.026901] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   89.121900] usb usb1: Product: OHCI Host Controller
[   89.185972] usb usb1: Manufacturer: Linux 3.3.0 ohci_hcd
[   89.255799] usb usb1: SerialNumber: 0000:00:0a.0
[   89.317926] usb usb1: usb_probe_device
[   89.367240] usb usb1: configuration #1 chosen from 1 choice
[   89.440940] usb usb1: adding 1-0:1.0 (config #1, interface 0)
[   89.517366] hub 1-0:1.0: usb_probe_interface
[   89.573463] hub 1-0:1.0: usb_probe_interface - got id
[   89.639856] hub 1-0:1.0: USB hub found
[   89.689224] hub 1-0:1.0: 2 ports detected
[   89.741879] hub 1-0:1.0: standalone hub
[   89.792262] hub 1-0:1.0: no power switching (usb 1.0)
[   89.858678] hub 1-0:1.0: global over-current protection
[   89.927356] hub 1-0:1.0: power on to power good time: 4ms
[   89.998581] hub 1-0:1.0: local power source is good
[   90.062749] hub 1-0:1.0: no over-current condition exists
[   90.133726] hub 1-0:1.0: trying to enable port power on non-switchable hub
[   90.225517] drivers/usb/core/inode.c: creating file '001'
[   90.297389] sched: RT throttling activated
[   90.490240] hub 1-0:1.0: state 7 ports 2 chg 0000 evt 0000
[   92.686636] Adding 3012176k swap on /dev/sda4.  Priority:-1 extents:1 across:3012176k 
[   93.212736] EXT3-fs (sda2): using internal journal
[   93.625108] loop: module loaded
[   98.063116] kjournald starting.  Commit interval 5 seconds
[   98.232699] EXT3-fs (sda1): using internal journal
[   98.295712] EXT3-fs (sda1): mounted filesystem with writeback data mode
[   98.408763] kjournald starting.  Commit interval 5 seconds
[   98.482162] EXT3-fs (sda5): using internal journal
[   98.545173] EXT3-fs (sda5): mounted filesystem with writeback data mode
[  104.240948] fuse init (API version 7.18)
[  107.466218] NET: Registered protocol family 10
[  117.616105] eth0: no IPv6 routers present
[13027.678644] 
[13027.698099] ------------[ cut here ]------------
[13027.698141] WARNING: at include/linux/rcupdate.h:242 __atomic_notifier_call_chain+0xa4/0x100()
[13027.698159] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13027.698212] Call Trace:
[13027.698242]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13027.698264]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13027.698285]  [0000000000473de4] __atomic_notifier_call_chain+0xa4/0x100
[13027.698307]  [0000000000473e54] atomic_notifier_call_chain+0x14/0x40
[13027.698339]  [00000000005eeb58] notify_write+0x18/0x40
[13027.698360]  [00000000005f213c] vt_console_print+0x17c/0x3e0
[13027.698382]  [000000000044f0e4] __call_console_drivers+0x84/0xa0
[13027.698404]  [000000000044f2f0] _call_console_drivers+0x70/0xc0
[13027.698426]  [000000000044f6ec] console_unlock+0x1cc/0x320
[13027.698446]  [000000000044fb14] vprintk+0x2d4/0x4c0
[13027.698475]  [000000000071f02c] printk+0x24/0x38
[13027.698495]  [0000000000488458] lockdep_rcu_suspicious+0x18/0xe0
[13027.698523]  [000000000066aea4] __netif_receive_skb+0x344/0x9e0
[13027.698545]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13027.698574]  [00000000006364e0] tulip_poll+0x380/0x640
[13027.698598]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13027.698613] ---[ end trace 3f96d049322e2aa3 ]---
[13027.698627] ------------[ cut here ]------------
[13027.698650] WARNING: at include/linux/rcupdate.h:248 __atomic_notifier_call_chain+0xd0/0x100()
[13027.698666] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13027.698710] Call Trace:
[13027.698729]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13027.698750]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13027.698771]  [0000000000473e10] __atomic_notifier_call_chain+0xd0/0x100
[13027.698792]  [0000000000473e54] atomic_notifier_call_chain+0x14/0x40
[13027.698816]  [00000000005eeb58] notify_write+0x18/0x40
[13027.698836]  [00000000005f213c] vt_console_print+0x17c/0x3e0
[13027.698857]  [000000000044f0e4] __call_console_drivers+0x84/0xa0
[13027.698879]  [000000000044f2f0] _call_console_drivers+0x70/0xc0
[13027.698901]  [000000000044f6ec] console_unlock+0x1cc/0x320
[13027.698921]  [000000000044fb14] vprintk+0x2d4/0x4c0
[13027.698943]  [000000000071f02c] printk+0x24/0x38
[13027.698961]  [0000000000488458] lockdep_rcu_suspicious+0x18/0xe0
[13027.698984]  [000000000066aea4] __netif_receive_skb+0x344/0x9e0
[13027.699005]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13027.699028]  [00000000006364e0] tulip_poll+0x380/0x640
[13027.699049]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13027.699063] ---[ end trace 3f96d049322e2aa4 ]---
[13030.823527] ===============================
[13030.878492] [ INFO: suspicious RCU usage. ]
[13030.933463] 3.3.0 #34 Tainted: G        W   
[13030.989571] -------------------------------
[13031.044542] include/linux/netpoll.h:70 suspicious rcu_dereference_check() usage!
[13031.141822] 
[13031.141829] other info that might help us debug this:
[13031.141838] 
[13031.247042] 
[13031.247048] rcu_scheduler_active = 1, debug_locks = 0
[13031.332879] RCU used illegally from extended quiescent state!
[13031.408423] no locks held by swapper/0.
[13031.458809] 
[13031.458815] stack backtrace:
[13031.516058] Call Trace:
[13031.548171]  [00000000004884f4] lockdep_rcu_suspicious+0xb4/0xe0
[13031.627155]  [000000000066aea4] __netif_receive_skb+0x344/0x9e0
[13031.704979]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13031.778233]  [00000000006364e0] tulip_poll+0x380/0x640
[13031.845771]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13031.916744]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13031.985427]  [000000000042b1c4] do_softirq+0x84/0xc0
[13032.050676]  [0000000000404a40] __handle_softirq+0x0/0x10
[13032.121651]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13032.194899]  [000000000042b688] cpu_idle+0x48/0x100
[13032.259004]  [00000000007149a0] rest_init+0x128/0x148
[13032.325401]  [00000000008ae794] start_kernel+0x328/0x338
[13032.395227]  [0000000000714870] tlb_fixup_done+0x88/0x90
[13032.465048]  [0000000000000000]           (null)
[13032.525811] ------------[ cut here ]------------
[13032.586439] WARNING: at include/linux/rcupdate.h:242 __netif_receive_skb+0x9ac/0x9e0()
[13032.690570] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13032.801579] Call Trace:
[13032.833619]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13032.910318]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13032.984713]  [000000000066b50c] __netif_receive_skb+0x9ac/0x9e0
[13033.062540]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13033.135795]  [00000000006364e0] tulip_poll+0x380/0x640
[13033.203331]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13033.274299]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13033.342981]  [000000000042b1c4] do_softirq+0x84/0xc0
[13033.408231]  [0000000000404a40] __handle_softirq+0x0/0x10
[13033.479204]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13033.552454]  [000000000042b688] cpu_idle+0x48/0x100
[13033.616564]  [00000000007149a0] rest_init+0x128/0x148
[13033.682961]  [00000000008ae794] start_kernel+0x328/0x338
[13033.752786]  [0000000000714870] tlb_fixup_done+0x88/0x90
[13033.822606]  [0000000000000000]           (null)
[13033.883282] ---[ end trace 3f96d049322e2aa5 ]---
[13033.943971] ------------[ cut here ]------------
[13034.004666] WARNING: at include/linux/rcupdate.h:242 ip_route_input_common+0xf7c/0x1060()
[13034.112217] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13034.223228] Call Trace:
[13034.255269]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13034.331963]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13034.406363]  [00000000006a0fdc] ip_route_input_common+0xf7c/0x1060
[13034.487623]  [00000000006d645c] arp_process+0x41c/0x820
[13034.556294]  [00000000006d694c] arp_rcv+0xec/0x180
[13034.619261]  [000000000066b384] __netif_receive_skb+0x824/0x9e0
[13034.697092]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13034.770346]  [00000000006364e0] tulip_poll+0x380/0x640
[13034.837882]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13034.908854]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13034.977534]  [000000000042b1c4] do_softirq+0x84/0xc0
[13035.042783]  [0000000000404a40] __handle_softirq+0x0/0x10
[13035.113760]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13035.187007]  [000000000042b688] cpu_idle+0x48/0x100
[13035.251118]  [00000000007149a0] rest_init+0x128/0x148
[13035.317509]  [00000000008ae794] start_kernel+0x328/0x338
[13035.387335] ---[ end trace 3f96d049322e2aa6 ]---
[13035.448015] ------------[ cut here ]------------
[13035.508701] WARNING: at include/linux/rcupdate.h:242 fib_table_lookup+0x580/0x5e0()
[13035.609406] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13035.720415] Call Trace:
[13035.752457]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13035.829153]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13035.903552]  [00000000006ee620] fib_table_lookup+0x580/0x5e0
[13035.977947]  [00000000006a0188] ip_route_input_common+0x128/0x1060
[13036.059205]  [00000000006d645c] arp_process+0x41c/0x820
[13036.127881]  [00000000006d694c] arp_rcv+0xec/0x180
[13036.190850]  [000000000066b384] __netif_receive_skb+0x824/0x9e0
[13036.268677]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13036.341932]  [00000000006364e0] tulip_poll+0x380/0x640
[13036.409467]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13036.480437]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13036.549119]  [000000000042b1c4] do_softirq+0x84/0xc0
[13036.614370]  [0000000000404a40] __handle_softirq+0x0/0x10
[13036.685340]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13036.758595]  [000000000042b688] cpu_idle+0x48/0x100
[13036.822703]  [00000000007149a0] rest_init+0x128/0x148
[13036.889098] ---[ end trace 3f96d049322e2aa7 ]---
[13036.949773] ------------[ cut here ]------------
[13037.010462] WARNING: at include/linux/rcupdate.h:248 fib_table_lookup+0x5c0/0x5e0()
[13037.111164] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13037.222174] Call Trace:
[13037.254215]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13037.330916]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13037.405306]  [00000000006ee660] fib_table_lookup+0x5c0/0x5e0
[13037.479711]  [00000000006a0188] ip_route_input_common+0x128/0x1060
[13037.560963]  [00000000006d645c] arp_process+0x41c/0x820
[13037.629643]  [00000000006d694c] arp_rcv+0xec/0x180
[13037.692606]  [000000000066b384] __netif_receive_skb+0x824/0x9e0
[13037.770440]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13037.843690]  [00000000006364e0] tulip_poll+0x380/0x640
[13037.911236]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13037.982197]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13038.050881]  [000000000042b1c4] do_softirq+0x84/0xc0
[13038.116128]  [0000000000404a40] __handle_softirq+0x0/0x10
[13038.187103]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13038.260353]  [000000000042b688] cpu_idle+0x48/0x100
[13038.324463]  [00000000007149a0] rest_init+0x128/0x148
[13038.390852] ---[ end trace 3f96d049322e2aa8 ]---
[13038.451534] ------------[ cut here ]------------
[13038.512224] WARNING: at include/linux/rcupdate.h:248 ip_route_input_common+0xfa8/0x1060()
[13038.619785] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13038.730793] Call Trace:
[13038.762833]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13038.839530]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13038.913933]  [00000000006a1008] ip_route_input_common+0xfa8/0x1060
[13038.995181]  [00000000006d645c] arp_process+0x41c/0x820
[13039.063865]  [00000000006d694c] arp_rcv+0xec/0x180
[13039.126829]  [000000000066b384] __netif_receive_skb+0x824/0x9e0
[13039.204655]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13039.277910]  [00000000006364e0] tulip_poll+0x380/0x640
[13039.345447]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13039.416414]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13039.485097]  [000000000042b1c4] do_softirq+0x84/0xc0
[13039.550348]  [0000000000404a40] __handle_softirq+0x0/0x10
[13039.621320]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13039.694574]  [000000000042b688] cpu_idle+0x48/0x100
[13039.758680]  [00000000007149a0] rest_init+0x128/0x148
[13039.825078]  [00000000008ae794] start_kernel+0x328/0x338
[13039.894900] ---[ end trace 3f96d049322e2aa9 ]---
[13039.955578] ------------[ cut here ]------------
[13040.016273] WARNING: at include/linux/rcupdate.h:242 neigh_lookup+0x2b4/0x320()
[13040.112399] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13040.223426] Call Trace:
[13040.255555]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13040.332249]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13040.406646]  [000000000067a0b4] neigh_lookup+0x2b4/0x320
[13040.476471]  [00000000006d633c] arp_process+0x2fc/0x820
[13040.545153]  [00000000006d694c] arp_rcv+0xec/0x180
[13040.608118]  [000000000066b384] __netif_receive_skb+0x824/0x9e0
[13040.685945]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13040.759201]  [00000000006364e0] tulip_poll+0x380/0x640
[13040.826741]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13040.897712]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13040.966389]  [000000000042b1c4] do_softirq+0x84/0xc0
[13041.031643]  [0000000000404a40] __handle_softirq+0x0/0x10
[13041.102610]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13041.175865]  [000000000042b688] cpu_idle+0x48/0x100
[13041.239972]  [00000000007149a0] rest_init+0x128/0x148
[13041.306367]  [00000000008ae794] start_kernel+0x328/0x338
[13041.376190] ---[ end trace 3f96d049322e2aaa ]---
[13041.436867] ------------[ cut here ]------------
[13041.497559] WARNING: at include/linux/rcupdate.h:248 neigh_lookup+0x2e8/0x320()
[13041.593690] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13041.704700] Call Trace:
[13041.736740]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13041.813434]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13041.887835]  [000000000067a0e8] neigh_lookup+0x2e8/0x320
[13041.957655]  [00000000006d633c] arp_process+0x2fc/0x820
[13042.026339]  [00000000006d694c] arp_rcv+0xec/0x180
[13042.089304]  [000000000066b384] __netif_receive_skb+0x824/0x9e0
[13042.167135]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13042.240388]  [00000000006364e0] tulip_poll+0x380/0x640
[13042.307926]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13042.378893]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13042.447577]  [000000000042b1c4] do_softirq+0x84/0xc0
[13042.512827]  [0000000000404a40] __handle_softirq+0x0/0x10
[13042.583798]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13042.657050]  [000000000042b688] cpu_idle+0x48/0x100
[13042.721161]  [00000000007149a0] rest_init+0x128/0x148
[13042.787555]  [00000000008ae794] start_kernel+0x328/0x338
[13042.857377] ---[ end trace 3f96d049322e2aab ]---
[13042.918064] ------------[ cut here ]------------
[13042.978744] WARNING: at include/linux/rcupdate.h:248 __netif_receive_skb+0x980/0x9e0()
[13043.082881] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13043.193888] Call Trace:
[13043.225927]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13043.302624]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13043.377022]  [000000000066b4e0] __netif_receive_skb+0x980/0x9e0
[13043.454848]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13043.528100]  [00000000006364e0] tulip_poll+0x380/0x640
[13043.595637]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13043.666607]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13043.735287]  [000000000042b1c4] do_softirq+0x84/0xc0
[13043.800538]  [0000000000404a40] __handle_softirq+0x0/0x10
[13043.871512]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13043.944769]  [000000000042b688] cpu_idle+0x48/0x100
[13044.008870]  [00000000007149a0] rest_init+0x128/0x148
[13044.075268]  [00000000008ae794] start_kernel+0x328/0x338
[13044.145093]  [0000000000714870] tlb_fixup_done+0x88/0x90
[13044.214911]  [0000000000000000]           (null)
[13044.275594] ---[ end trace 3f96d049322e2aac ]---
[13044.336386] ------------[ cut here ]------------
[13044.397079] WARNING: at include/linux/rcupdate.h:242 ip_local_deliver_finish+0x4b4/0x4e0()
[13044.505777] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13044.616782] Call Trace:
[13044.648823]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13044.725519]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13044.799928]  [00000000006a47f4] ip_local_deliver_finish+0x4b4/0x4e0
[13044.882320]  [00000000006a4ab0] ip_local_deliver+0x30/0xa0
[13044.954426]  [00000000006a3df4] ip_rcv_finish+0x174/0x6c0
[13045.025391]  [00000000006a4cd8] ip_rcv+0x1b8/0x2e0
[13045.088357]  [000000000066b384] __netif_receive_skb+0x824/0x9e0
[13045.166186]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13045.239442]  [00000000006364e0] tulip_poll+0x380/0x640
[13045.306978]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13045.377947]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13045.446629]  [000000000042b1c4] do_softirq+0x84/0xc0
[13045.511881]  [0000000000404a40] __handle_softirq+0x0/0x10
[13045.582850]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13045.656102]  [000000000042b688] cpu_idle+0x48/0x100
[13045.720210]  [00000000007149a0] rest_init+0x128/0x148
[13045.786601] ---[ end trace 3f96d049322e2aad ]---
[13045.847290] ------------[ cut here ]------------
[13045.907983] WARNING: at include/linux/rcupdate.h:248 ip_local_deliver_finish+0x488/0x4e0()
[13046.016680] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13046.127686] Call Trace:
[13046.159727]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13046.236421]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13046.310820]  [00000000006a47c8] ip_local_deliver_finish+0x488/0x4e0
[13046.393219]  [00000000006a4ab0] ip_local_deliver+0x30/0xa0
[13046.465330]  [00000000006a3df4] ip_rcv_finish+0x174/0x6c0
[13046.536295]  [00000000006a4cd8] ip_rcv+0x1b8/0x2e0
[13046.599260]  [000000000066b384] __netif_receive_skb+0x824/0x9e0
[13046.677089]  [000000000066b6ec] netif_receive_skb+0x4c/0x60
[13046.750346]  [00000000006364e0] tulip_poll+0x380/0x640
[13046.817881]  [000000000066eab8] net_rx_action+0x118/0x1e0
[13046.888856]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13046.957531]  [000000000042b1c4] do_softirq+0x84/0xc0
[13047.022782]  [0000000000404a40] __handle_softirq+0x0/0x10
[13047.093758]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13047.167007]  [000000000042b688] cpu_idle+0x48/0x100
[13047.231115]  [00000000007149a0] rest_init+0x128/0x148
[13047.297503] ---[ end trace 3f96d049322e2aae ]---
[13047.358514] ------------[ cut here ]------------
[13047.419319] WARNING: at include/linux/rcupdate.h:242 addrconf_verify+0x55c/0x5a0 [ipv6]()
[13047.526861] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13047.637860] Call Trace:
[13047.669909]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13047.746602]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13047.821047]  [00000000100b615c] addrconf_verify+0x55c/0x5a0 [ipv6]
[13047.902267]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[13047.977793]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13048.046470]  [000000000042b1c4] do_softirq+0x84/0xc0
[13048.111724]  [0000000000404a40] __handle_softirq+0x0/0x10
[13048.182694]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13048.255945]  [000000000042b688] cpu_idle+0x48/0x100
[13048.320052]  [00000000007149a0] rest_init+0x128/0x148
[13048.386452]  [00000000008ae794] start_kernel+0x328/0x338
[13048.456277]  [0000000000714870] tlb_fixup_done+0x88/0x90
[13048.526096]  [0000000000000000]           (null)
[13048.586774] ---[ end trace 3f96d049322e2aaf ]---
[13048.647462] ------------[ cut here ]------------
[13048.708201] WARNING: at include/linux/rcupdate.h:248 addrconf_verify+0x588/0x5a0 [ipv6]()
[13048.815714] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[13048.926717] Call Trace:
[13048.958762]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[13049.035455]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[13049.109897]  [00000000100b6188] addrconf_verify+0x588/0x5a0 [ipv6]
[13049.191113]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[13049.266647]  [0000000000455d1c] __do_softirq+0x9c/0x140
[13049.335329]  [000000000042b1c4] do_softirq+0x84/0xc0
[13049.400578]  [0000000000404a40] __handle_softirq+0x0/0x10
[13049.471551]  [0000000000439304] touch_nmi_watchdog+0x4/0x40
[13049.544803]  [000000000042b688] cpu_idle+0x48/0x100
[13049.608910]  [00000000007149a0] rest_init+0x128/0x148
[13049.675307]  [00000000008ae794] start_kernel+0x328/0x338
[13049.745133]  [0000000000714870] tlb_fixup_done+0x88/0x90
[13049.814952]  [0000000000000000]           (null)
[13049.875630] ---[ end trace 3f96d049322e2ab0 ]---
[183002.206660] ------------[ cut here ]------------
[183002.268724] WARNING: at include/linux/rcupdate.h:242 igmp6_send+0x840/0x960 [ipv6]()
[183002.371733] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183002.483876] Call Trace:
[183002.517076]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183002.594902]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183002.670508]  [00000000100d4d20] igmp6_send+0x840/0x960 [ipv6]
[183002.747287]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183002.832047]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183002.908700]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183002.978522]  [000000000042b1c4] do_softirq+0x84/0xc0
[183003.044918]  [0000000000404a40] __handle_softirq+0x0/0x10
[183003.117030]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183003.199427]  [000000000042b688] cpu_idle+0x48/0x100
[183003.264680]  [00000000007149a0] rest_init+0x128/0x148
[183003.332217]  [00000000008ae794] start_kernel+0x328/0x338
[183003.403184]  [0000000000714870] tlb_fixup_done+0x88/0x90
[183003.474147]  [0000000000000000]           (null)
[183003.535970] ---[ end trace 3f96d049322e2ab1 ]---
[183003.597794] ------------[ cut here ]------------
[183003.659686] WARNING: at include/linux/rcupdate.h:248 igmp6_send+0x86c/0x960 [ipv6]()
[183003.762719] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183003.874873] Call Trace:
[183003.908058]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183003.985895]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183004.061493]  [00000000100d4d4c] igmp6_send+0x86c/0x960 [ipv6]
[183004.138278]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183004.223025]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183004.299695]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183004.369517]  [000000000042b1c4] do_softirq+0x84/0xc0
[183004.435909]  [0000000000404a40] __handle_softirq+0x0/0x10
[183004.508022]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183004.590426]  [000000000042b688] cpu_idle+0x48/0x100
[183004.655669]  [00000000007149a0] rest_init+0x128/0x148
[183004.723211]  [00000000008ae794] start_kernel+0x328/0x338
[183004.794180]  [0000000000714870] tlb_fixup_done+0x88/0x90
[183004.865144]  [0000000000000000]           (null)
[183004.926961] ---[ end trace 3f96d049322e2ab2 ]---
[183004.988803] ------------[ cut here ]------------
[183005.050679] WARNING: at include/linux/rcupdate.h:242 icmp6_dst_alloc+0x328/0x360 [ipv6]()
[183005.159448] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183005.271581] Call Trace:
[183005.304768]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183005.382607]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183005.458198]  [00000000100bd9e8] icmp6_dst_alloc+0x328/0x360 [ipv6]
[183005.540604]  [00000000100d4828] igmp6_send+0x348/0x960 [ipv6]
[183005.617394]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183005.702126]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183005.778800]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183005.848625]  [000000000042b1c4] do_softirq+0x84/0xc0
[183005.915019]  [0000000000404a40] __handle_softirq+0x0/0x10
[183005.987135]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183006.069532]  [000000000042b688] cpu_idle+0x48/0x100
[183006.134778]  [00000000007149a0] rest_init+0x128/0x148
[183006.202317]  [00000000008ae794] start_kernel+0x328/0x338
[183006.273288]  [0000000000714870] tlb_fixup_done+0x88/0x90
[183006.344251]  [0000000000000000]           (null)
[183006.406072] ---[ end trace 3f96d049322e2ab3 ]---
[183006.467894] ------------[ cut here ]------------
[183006.529785] WARNING: at include/linux/rcupdate.h:248 icmp6_dst_alloc+0x2e8/0x360 [ipv6]()
[183006.638541] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183006.750690] Call Trace:
[183006.783877]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183006.861712]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183006.937306]  [00000000100bd9a8] icmp6_dst_alloc+0x2e8/0x360 [ipv6]
[183007.019718]  [00000000100d4828] igmp6_send+0x348/0x960 [ipv6]
[183007.096499]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183007.181233]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183007.257908]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183007.327732]  [000000000042b1c4] do_softirq+0x84/0xc0
[183007.394126]  [0000000000404a40] __handle_softirq+0x0/0x10
[183007.466238]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183007.548639]  [000000000042b688] cpu_idle+0x48/0x100
[183007.613887]  [00000000007149a0] rest_init+0x128/0x148
[183007.681426]  [00000000008ae794] start_kernel+0x328/0x338
[183007.752395]  [0000000000714870] tlb_fixup_done+0x88/0x90
[183007.823358]  [0000000000000000]           (null)
[183007.885179] ---[ end trace 3f96d049322e2ab4 ]---
[183007.947031] ------------[ cut here ]------------
[183008.008897] WARNING: at include/linux/rcupdate.h:242 ndisc_constructor+0x29c/0x2e0 [ipv6]()
[183008.119935] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183008.232083] Call Trace:
[183008.265272]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183008.343108]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183008.418703]  [00000000100c5cbc] ndisc_constructor+0x29c/0x2e0 [ipv6]
[183008.503342]  [000000000067be78] neigh_create+0x1d8/0xaa0
[183008.574345]  [00000000100ba014] ip6_neigh_lookup+0x2d4/0x360 [ipv6]
[183008.657894]  [00000000100bd904] icmp6_dst_alloc+0x244/0x360 [ipv6]
[183008.740300]  [00000000100d4828] igmp6_send+0x348/0x960 [ipv6]
[183008.817087]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183008.901819]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183008.978502]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183009.048319]  [000000000042b1c4] do_softirq+0x84/0xc0
[183009.114713]  [0000000000404a40] __handle_softirq+0x0/0x10
[183009.186832]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183009.269227]  [000000000042b688] cpu_idle+0x48/0x100
[183009.334475]  [00000000007149a0] rest_init+0x128/0x148
[183009.402015]  [00000000008ae794] start_kernel+0x328/0x338
[183009.472979] ---[ end trace 3f96d049322e2ab5 ]---
[183009.534797] ------------[ cut here ]------------
[183009.596689] WARNING: at include/linux/rcupdate.h:248 ndisc_constructor+0x2c8/0x2e0 [ipv6]()
[183009.707731] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183009.819878] Call Trace:
[183009.853066]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183009.930903]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183010.006499]  [00000000100c5ce8] ndisc_constructor+0x2c8/0x2e0 [ipv6]
[183010.091233]  [000000000067be78] neigh_create+0x1d8/0xaa0
[183010.162246]  [00000000100ba014] ip6_neigh_lookup+0x2d4/0x360 [ipv6]
[183010.245791]  [00000000100bd904] icmp6_dst_alloc+0x244/0x360 [ipv6]
[183010.328199]  [00000000100d4828] igmp6_send+0x348/0x960 [ipv6]
[183010.404984]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183010.489717]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183010.566393]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183010.636218]  [000000000042b1c4] do_softirq+0x84/0xc0
[183010.702613]  [0000000000404a40] __handle_softirq+0x0/0x10
[183010.774723]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183010.857137]  [000000000042b688] cpu_idle+0x48/0x100
[183010.922372]  [00000000007149a0] rest_init+0x128/0x148
[183010.989916]  [00000000008ae794] start_kernel+0x328/0x338
[183011.060875] ---[ end trace 3f96d049322e2ab6 ]---
[183011.122707] ------------[ cut here ]------------
[183011.184541] WARNING: at include/linux/rcupdate.h:242 inet_getpeer+0xb98/0xbc0()
[183011.281804] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183011.393973] Call Trace:
[183011.427248]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183011.505085]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183011.580625]  [00000000006a3a18] inet_getpeer+0xb98/0xbc0
[183011.651648]  [00000000100bcdd0] rt6_bind_peer+0x30/0x80 [ipv6]
[183011.729474]  [00000000100bce90] ipv6_cow_metrics+0x70/0xa0 [ipv6]
[183011.810831]  [00000000100bd87c] icmp6_dst_alloc+0x1bc/0x360 [ipv6]
[183011.893238]  [00000000100d4828] igmp6_send+0x348/0x960 [ipv6]
[183011.970028]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183012.054757]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183012.131433]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183012.201258]  [000000000042b1c4] do_softirq+0x84/0xc0
[183012.267650]  [0000000000404a40] __handle_softirq+0x0/0x10
[183012.339766]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183012.422164]  [000000000042b688] cpu_idle+0x48/0x100
[183012.487412]  [00000000007149a0] rest_init+0x128/0x148
[183012.554952]  [00000000008ae794] start_kernel+0x328/0x338
[183012.625916] ---[ end trace 3f96d049322e2ab7 ]---
[183012.687737] ------------[ cut here ]------------
[183012.749571] WARNING: at include/linux/rcupdate.h:248 inet_getpeer+0xb34/0xbc0()
[183012.846842] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183012.958998] Call Trace:
[183012.992183]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183013.070022]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183013.145566]  [00000000006a39b4] inet_getpeer+0xb34/0xbc0
[183013.216580]  [00000000100bcdd0] rt6_bind_peer+0x30/0x80 [ipv6]
[183013.294408]  [00000000100bce90] ipv6_cow_metrics+0x70/0xa0 [ipv6]
[183013.375662]  [00000000100bd87c] icmp6_dst_alloc+0x1bc/0x360 [ipv6]
[183013.458070]  [00000000100d4828] igmp6_send+0x348/0x960 [ipv6]
[183013.534855]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183013.619590]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183013.696266]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183013.766090]  [000000000042b1c4] do_softirq+0x84/0xc0
[183013.832484]  [0000000000404a40] __handle_softirq+0x0/0x10
[183013.904596]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183013.986999]  [000000000042b688] cpu_idle+0x48/0x100
[183014.052244]  [00000000007149a0] rest_init+0x128/0x148
[183014.119786]  [00000000008ae794] start_kernel+0x328/0x338
[183014.190750] ---[ end trace 3f96d049322e2ab8 ]---
[183014.252581] ------------[ cut here ]------------
[183014.314406] WARNING: at include/linux/rcupdate.h:242 fib_rules_lookup+0x340/0x380()
[183014.416249] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183014.528402] Call Trace:
[183014.561588]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183014.639426]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183014.714965]  [0000000000687ae0] fib_rules_lookup+0x340/0x380
[183014.790576]  [00000000100e5bc4] ip6mr_fib_lookup+0x24/0x60 [ipv6]
[183014.871932]  [00000000100e7968] mroute6_socket+0x48/0x80 [ipv6]
[183014.950988]  [00000000100aa45c] ip6_finish_output2+0x21c/0x600 [ipv6]
[183015.036811]  [00000000100ad128] ip6_finish_output+0xc8/0x260 [ipv6]
[183015.120353]  [00000000100ad314] ip6_output+0x54/0x220 [ipv6]
[183015.195904]  [00000000100d4864] igmp6_send+0x384/0x960 [ipv6]
[183015.272693]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183015.357426]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183015.434102]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183015.503925]  [000000000042b1c4] do_softirq+0x84/0xc0
[183015.570320]  [0000000000404a40] __handle_softirq+0x0/0x10
[183015.642433]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183015.724830]  [000000000042b688] cpu_idle+0x48/0x100
[183015.790074] ---[ end trace 3f96d049322e2ab9 ]---
[183015.851899] ------------[ cut here ]------------
[183015.913733] WARNING: at include/linux/rcupdate.h:248 fib_rules_lookup+0x36c/0x380()
[183016.015580] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183016.127730] Call Trace:
[183016.160917]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183016.238754]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183016.314291]  [0000000000687b0c] fib_rules_lookup+0x36c/0x380
[183016.389900]  [00000000100e5bc4] ip6mr_fib_lookup+0x24/0x60 [ipv6]
[183016.471258]  [00000000100e7968] mroute6_socket+0x48/0x80 [ipv6]
[183016.550305]  [00000000100aa45c] ip6_finish_output2+0x21c/0x600 [ipv6]
[183016.636137]  [00000000100ad128] ip6_finish_output+0xc8/0x260 [ipv6]
[183016.719676]  [00000000100ad314] ip6_output+0x54/0x220 [ipv6]
[183016.795230]  [00000000100d4864] igmp6_send+0x384/0x960 [ipv6]
[183016.872016]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183016.956756]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183017.033426]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183017.103252]  [000000000042b1c4] do_softirq+0x84/0xc0
[183017.169652]  [0000000000404a40] __handle_softirq+0x0/0x10
[183017.241761]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183017.324161]  [000000000042b688] cpu_idle+0x48/0x100
[183017.389401] ---[ end trace 3f96d049322e2aba ]---
[183017.451241] ------------[ cut here ]------------
[183017.513106] WARNING: at include/linux/rcupdate.h:242 ip6_finish_output2+0x5c0/0x600 [ipv6]()
[183017.625193] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183017.737344] Call Trace:
[183017.770531]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183017.848369]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183017.923951]  [00000000100aa800] ip6_finish_output2+0x5c0/0x600 [ipv6]
[183018.009785]  [00000000100ad128] ip6_finish_output+0xc8/0x260 [ipv6]
[183018.093323]  [00000000100ad314] ip6_output+0x54/0x220 [ipv6]
[183018.168875]  [00000000100d4864] igmp6_send+0x384/0x960 [ipv6]
[183018.245663]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183018.330394]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183018.407073]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183018.476896]  [000000000042b1c4] do_softirq+0x84/0xc0
[183018.543291]  [0000000000404a40] __handle_softirq+0x0/0x10
[183018.615402]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183018.697804]  [000000000042b688] cpu_idle+0x48/0x100
[183018.763051]  [00000000007149a0] rest_init+0x128/0x148
[183018.830590]  [00000000008ae794] start_kernel+0x328/0x338
[183018.901561]  [0000000000714870] tlb_fixup_done+0x88/0x90
[183018.972528] ---[ end trace 3f96d049322e2abb ]---
[183019.034356] ------------[ cut here ]------------
[183019.096192] WARNING: at include/linux/rcupdate.h:242 sock_def_write_space+0x1a0/0x1e0()
[183019.202599] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183019.314748] Call Trace:
[183019.347934]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183019.425773]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183019.501312]  [000000000065ba40] sock_def_write_space+0x1a0/0x1e0
[183019.581426]  [000000000065c840] sock_wfree+0x60/0x80
[183019.647835]  [0000000000670724] dev_hard_start_xmit+0x204/0x780
[183019.726793]  [000000000068b7fc] sch_direct_xmit+0x9c/0x2c0
[183019.800041]  [0000000000670fcc] dev_queue_xmit+0x32c/0xa40
[183019.873300]  [000000000067af68] neigh_resolve_output+0x108/0x240
[183019.953460]  [00000000100aa318] ip6_finish_output2+0xd8/0x600 [ipv6]
[183020.038139]  [00000000100ad128] ip6_finish_output+0xc8/0x260 [ipv6]
[183020.121675]  [00000000100ad314] ip6_output+0x54/0x220 [ipv6]
[183020.197232]  [00000000100d4864] igmp6_send+0x384/0x960 [ipv6]
[183020.274018]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183020.358755]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183020.435428]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183020.505253]  [000000000042b1c4] do_softirq+0x84/0xc0
[183020.571640] ---[ end trace 3f96d049322e2abc ]---
[183020.633466] ------------[ cut here ]------------
[183020.695299] WARNING: at include/linux/rcupdate.h:248 sock_def_write_space+0x1cc/0x1e0()
[183020.801718] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183020.913869] Call Trace:
[183020.947058]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183021.024893]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183021.100430]  [000000000065ba6c] sock_def_write_space+0x1cc/0x1e0
[183021.180549]  [000000000065c840] sock_wfree+0x60/0x80
[183021.246939]  [0000000000670724] dev_hard_start_xmit+0x204/0x780
[183021.325910]  [000000000068b7fc] sch_direct_xmit+0x9c/0x2c0
[183021.399159]  [0000000000670fcc] dev_queue_xmit+0x32c/0xa40
[183021.472417]  [000000000067af68] neigh_resolve_output+0x108/0x240
[183021.552575]  [00000000100aa318] ip6_finish_output2+0xd8/0x600 [ipv6]
[183021.637261]  [00000000100ad128] ip6_finish_output+0xc8/0x260 [ipv6]
[183021.720797]  [00000000100ad314] ip6_output+0x54/0x220 [ipv6]
[183021.796354]  [00000000100d4864] igmp6_send+0x384/0x960 [ipv6]
[183021.873138]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183021.957879]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183022.034549]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183022.104373]  [000000000042b1c4] do_softirq+0x84/0xc0
[183022.170759] ---[ end trace 3f96d049322e2abd ]---
[183022.232599] ------------[ cut here ]------------
[183022.294487] WARNING: at include/linux/rcupdate.h:248 ip6_finish_output2+0x594/0x600 [ipv6]()
[183022.406662] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183022.518808] Call Trace:
[183022.551993]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183022.629831]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183022.705417]  [00000000100aa7d4] ip6_finish_output2+0x594/0x600 [ipv6]
[183022.791248]  [00000000100ad128] ip6_finish_output+0xc8/0x260 [ipv6]
[183022.874784]  [00000000100ad314] ip6_output+0x54/0x220 [ipv6]
[183022.950345]  [00000000100d4864] igmp6_send+0x384/0x960 [ipv6]
[183023.027126]  [00000000100d52d0] igmp6_timer_handler+0x90/0xe0 [ipv6]
[183023.111862]  [000000000045c328] run_timer_softirq+0x168/0x2c0
[183023.188536]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183023.258362]  [000000000042b1c4] do_softirq+0x84/0xc0
[183023.324752]  [0000000000404a40] __handle_softirq+0x0/0x10
[183023.396867]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183023.479267]  [000000000042b688] cpu_idle+0x48/0x100
[183023.544517]  [00000000007149a0] rest_init+0x128/0x148
[183023.612057]  [00000000008ae794] start_kernel+0x328/0x338
[183023.683023]  [0000000000714870] tlb_fixup_done+0x88/0x90
[183023.753987] ---[ end trace 3f96d049322e2abe ]---
[183023.816112] ------------[ cut here ]------------
[183023.877973] WARNING: at include/linux/rcupdate.h:242 ip_finish_output+0x6e8/0x760()
[183023.979805] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183024.091953] Call Trace:
[183024.125140]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183024.202976]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183024.278519]  [00000000006aa728] ip_finish_output+0x6e8/0x760
[183024.354054]  [00000000006ab604] ip_output+0x84/0x160
[183024.420447]  [00000000006aa970] ip_local_out+0x30/0xc0
[183024.489131]  [00000000006ac084] ip_send_skb+0x4/0x80
[183024.555526]  [00000000006ac120] ip_push_pending_frames+0x20/0x40
[183024.635645]  [00000000006d79e4] icmp_push_reply+0xe4/0x120
[183024.708895]  [00000000006d7ef0] icmp_reply+0x190/0x2a0
[183024.777576]  [00000000006d8660] icmp_echo.part.4+0x40/0x60
[183024.850832]  [00000000006d86ac] icmp_echo+0x2c/0xc0
[183024.916081]  [00000000006d93bc] icmp_rcv+0x39c/0x560
[183024.982488]  [00000000006a44f0] ip_local_deliver_finish+0x1b0/0x4e0
[183025.066027]  [00000000006a4ab0] ip_local_deliver+0x30/0xa0
[183025.139284]  [00000000006a3df4] ip_rcv_finish+0x174/0x6c0
[183025.211387]  [00000000006a4cd8] ip_rcv+0x1b8/0x2e0
[183025.275488] ---[ end trace 3f96d049322e2abf ]---
[183025.337324] ------------[ cut here ]------------
[183025.399164] WARNING: at include/linux/rcupdate.h:248 ip_finish_output+0x640/0x760()
[183025.500992] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183025.613142] Call Trace:
[183025.646326]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183025.724168]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183025.799710]  [00000000006aa680] ip_finish_output+0x640/0x760
[183025.875247]  [00000000006ab604] ip_output+0x84/0x160
[183025.941644]  [00000000006aa970] ip_local_out+0x30/0xc0
[183026.010320]  [00000000006ac084] ip_send_skb+0x4/0x80
[183026.076717]  [00000000006ac120] ip_push_pending_frames+0x20/0x40
[183026.156835]  [00000000006d79e4] icmp_push_reply+0xe4/0x120
[183026.230087]  [00000000006d7ef0] icmp_reply+0x190/0x2a0
[183026.298770]  [00000000006d8660] icmp_echo.part.4+0x40/0x60
[183026.372025]  [00000000006d86ac] icmp_echo+0x2c/0xc0
[183026.437272]  [00000000006d93bc] icmp_rcv+0x39c/0x560
[183026.503676]  [00000000006a44f0] ip_local_deliver_finish+0x1b0/0x4e0
[183026.587219]  [00000000006a4ab0] ip_local_deliver+0x30/0xa0
[183026.660471]  [00000000006a3df4] ip_rcv_finish+0x174/0x6c0
[183026.732581]  [00000000006a4cd8] ip_rcv+0x1b8/0x2e0
[183026.796678] ---[ end trace 3f96d049322e2ac0 ]---
[183026.859386] ------------[ cut here ]------------
[183026.921235] WARNING: at include/linux/rcupdate.h:242 ipv6_rcv+0x6bc/0x840 [ipv6]()
[183027.021983] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183027.134143] Call Trace:
[183027.167417]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183027.245254]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183027.320836]  [00000000100af91c] ipv6_rcv+0x6bc/0x840 [ipv6]
[183027.395195]  [000000000066b384] __netif_receive_skb+0x824/0x9e0
[183027.474159]  [000000000066b5bc] process_backlog+0x7c/0x160
[183027.547414]  [000000000066eab8] net_rx_action+0x118/0x1e0
[183027.619521]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183027.689350]  [000000000042b1c4] do_softirq+0x84/0xc0
[183027.755742]  [0000000000404a40] __handle_softirq+0x0/0x10
[183027.827854]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183027.910256]  [000000000042b688] cpu_idle+0x48/0x100
[183027.975509]  [00000000007149a0] rest_init+0x128/0x148
[183028.043041]  [00000000008ae794] start_kernel+0x328/0x338
[183028.114008]  [0000000000714870] tlb_fixup_done+0x88/0x90
[183028.184973]  [0000000000000000]           (null)
[183028.246795] ---[ end trace 3f96d049322e2ac1 ]---
[183028.308629] ------------[ cut here ]------------
[183028.370500] WARNING: at include/linux/rcupdate.h:248 ipv6_rcv+0x778/0x840 [ipv6]()
[183028.471156] Modules linked in: ipv6 fuse loop ohci_hcd usbcore sr_mod cdrom usb_common flash
[183028.583308] Call Trace:
[183028.616494]  [000000000044eee4] warn_slowpath_common+0x44/0x80
[183028.694332]  [000000000044ef34] warn_slowpath_null+0x14/0x40
[183028.769914]  [00000000100af9d8] ipv6_rcv+0x778/0x840 [ipv6]
[183028.844272]  [000000000066b384] __netif_receive_skb+0x824/0x9e0
[183028.923236]  [000000000066b5bc] process_backlog+0x7c/0x160
[183028.996497]  [000000000066eab8] net_rx_action+0x118/0x1e0
[183029.068601]  [0000000000455d1c] __do_softirq+0x9c/0x140
[183029.138430]  [000000000042b1c4] do_softirq+0x84/0xc0
[183029.204819]  [0000000000404a40] __handle_softirq+0x0/0x10
[183029.276932]  [000000000049b6a0] touch_softlockup_watchdog+0x0/0x20
[183029.359332]  [000000000042b688] cpu_idle+0x48/0x100
[183029.424582]  [00000000007149a0] rest_init+0x128/0x148
[183029.492119]  [00000000008ae794] start_kernel+0x328/0x338
[183029.563086]  [0000000000714870] tlb_fixup_done+0x88/0x90
[183029.634053]  [0000000000000000]           (null)
[183029.695875] ---[ end trace 3f96d049322e2ac2 ]---


-- 
Meelis Roos (mroos@linux.ee)
