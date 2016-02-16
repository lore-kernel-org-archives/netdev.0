From: Simon Horman <horms@verge.net.au>
Subject: ravb: Possible Regression In "net: phy: Avoid polling PHY with
 PHY_IGNORE_INTERRUPTS"
Date: Tue, 16 Feb 2016 12:26:46 +0900
Message-ID: <20160216032642.GE23315@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Magnus Damm <magnus.damm@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

I have observed what appears to be a regression in the ravb ethernet driver
caused by d5c3d84657db ("net: phy: Avoid polling PHY with
PHY_IGNORE_INTERRUPTS").

When booting net-next configured with the ARM64 defconfig on the Renesas
r8a7795/salvator-x I see the following and the ravb is unable to access the
network. With the above mentioned patch reverted I am able to boot to
user-space using nfsroot.


[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 4.5.0-rc2+ (horms@ayumi.isobedori.kobe.vergenet.net) (gcc version 4.8.5 (Linaro GCC 4.8-2015.06) ) #90 SMP PREEMPT Tue Feb 16 12:22:08 JST 2016
[    0.000000] Boot CPU: AArch64 Processor [411fd073]
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] efi: UEFI not found.
[    0.000000] cma: Reserved 16 MiB at 0x000000007f000000
[    0.000000] On node 0 totalpages: 229376
[    0.000000]   DMA zone: 3584 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 229376 pages, LIFO batch:31
[    0.000000] psci: probing for conduit method from DT.
[    0.000000] psci: PSCIv1.0 detected in firmware.
[    0.000000] psci: Using standard PSCI v0.2 function IDs
[    0.000000] psci: Trusted OS migration not required
[    0.000000] PERCPU: Embedded 20 pages/cpu @ffffffc036f8f000 s42496 r8192 d31232 u81920
[    0.000000] pcpu-alloc: s42496 r8192 d31232 u81920 alloc=20*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 
[    0.000000] Detected PIPT I-cache on CPU0
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 225792
[    0.000000] Kernel command line: ignore_loglevel rw root=/dev/nfs ip=dhcp nfsroot=10.3.3.135:/srv/nfs/salvator-x-arm64
[    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
[    0.000000] log_buf_len total cpu_extra contributions: 12288 bytes
[    0.000000] log_buf_len min size: 16384 bytes
[    0.000000] log_buf_len: 32768 bytes
[    0.000000] early log buf free: 14796(90%)
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.000000] software IO TLB [mem 0x79c00000-0x7dc00000] (64MB) mapped at [ffffffc031c00000-ffffffc035bfffff]
[    0.000000] Memory: 805744K/917504K available (6468K kernel code, 593K rwdata, 2900K rodata, 724K init, 242K bss, 95376K reserved, 16384K cma-reserved)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vmalloc : 0xffffff8000000000 - 0xffffffbdbfff0000   (   246 GB)
[    0.000000]     vmemmap : 0xffffffbdc0000000 - 0xffffffbfc0000000   (     8 GB maximum)
[    0.000000]               0xffffffbdc1200000 - 0xffffffbdc2000000   (    14 MB actual)
[    0.000000]     fixed   : 0xffffffbffa7fd000 - 0xffffffbffac00000   (  4108 KB)
[    0.000000]     PCI I/O : 0xffffffbffae00000 - 0xffffffbffbe00000   (    16 MB)
[    0.000000]     modules : 0xffffffbffc000000 - 0xffffffc000000000   (    64 MB)
[    0.000000]     memory  : 0xffffffc000000000 - 0xffffffc038000000   (   896 MB)
[    0.000000]       .init : 0xffffffc0009a9000 - 0xffffffc000a5e000   (   724 KB)
[    0.000000]       .text : 0xffffffc000080000 - 0xffffffc0009a8244   (  9377 KB)
[    0.000000]       .data : 0xffffffc000a5e000 - 0xffffffc000af2600   (   594 KB)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]  Build-time adjustment of leaf fanout to 64.
[    0.000000]  RCU restricting CPUs from NR_CPUS=64 to nr_cpu_ids=4.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=4
[    0.000000] NR_IRQS:64 nr_irqs:64 0
[    0.000000] Architected cp15 timer(s) running at 16.66MHz (virt).
[    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x3d7a162dd, max_idle_ns: 440795202225 ns
[    0.000001] sched_clock: 56 bits at 16MHz, resolution 60ns, wraps every 2199023255551ns
[    0.000055] Console: colour dummy device 80x25
[    0.000217] console [tty0] enabled
[    0.000229] Calibrating delay loop (skipped), value calculated using timer frequency.. 33.32 BogoMIPS (lpj=66640)
[    0.000238] pid_max: default: 32768 minimum: 301
[    0.000263] Security Framework initialized
[    0.000278] Mount-cache hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000283] Mountpoint-cache hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000678] ASID allocator initialised with 65536 entries
[    0.020145] EFI services will not be available.
[    0.036098] Detected PIPT I-cache on CPU1
[    0.036121] CPU1: Booted secondary processor [411fd073]
[    0.048089] Detected PIPT I-cache on CPU2
[    0.048097] CPU2: Booted secondary processor [411fd073]
[    0.060095] Detected PIPT I-cache on CPU3
[    0.060104] CPU3: Booted secondary processor [411fd073]
[    0.060121] Brought up 4 CPUs
[    0.060146] SMP: Total of 4 processors activated.
[    0.060152] CPU: All CPU(s) started at EL1
[    0.060409] devtmpfs: initialized
[    0.061400] DMI not present or invalid.
[    0.061486] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.061670] pinctrl core: initialized pinctrl subsystem
[    0.062109] NET: Registered protocol family 16
[    0.072043] cpuidle: using governor menu
[    0.072107] vdso: 2 pages (1 code @ ffffffc000a65000, 1 data @ ffffffc000a64000)
[    0.072128] hw-breakpoint: found 6 breakpoint and 4 watchpoint registers.
[    0.072442] DMA: preallocated 256 KiB pool for atomic allocations
[    0.072531] Serial: AMBA PL011 UART driver
[    0.073660] sh-pfc e6060000.pfc: r8a77950_pfc support registered
[    0.088316] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.088974] vgaarb: loaded
[    0.089063] SCSI subsystem initialized
[    0.089121] libata version 3.00 loaded.
[    0.089222] usbcore: registered new interface driver usbfs
[    0.089244] usbcore: registered new interface driver hub
[    0.089266] usbcore: registered new device driver usb
[    0.089308] pps_core: LinuxPPS API ver. 1 registered
[    0.089312] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.089325] PTP clock support registered
[    0.089376] dmi: Firmware registration failed.
[    0.089732] Advanced Linux Sound Architecture Driver Initialized.
[    0.090006] clocksource: Switched to clocksource arch_sys_counter
[    0.090062] VFS: Disk quotas dquot_6.6.0
[    0.090084] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.092799] NET: Registered protocol family 2
[    0.092981] TCP established hash table entries: 8192 (order: 4, 65536 bytes)
[    0.093001] TCP bind hash table entries: 8192 (order: 5, 131072 bytes)
[    0.093048] TCP: Hash tables configured (established 8192 bind 8192)
[    0.093097] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.093105] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.093171] NET: Registered protocol family 1
[    0.093287] RPC: Registered named UNIX socket transport module.
[    0.093292] RPC: Registered udp transport module.
[    0.093296] RPC: Registered tcp transport module.
[    0.093300] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.093310] PCI: CLS 0 bytes, default 128
[    0.093516] hw perfevents: enabled with armv8_pmuv3 PMU driver, 7 counters available
[    0.093577] kvm [1]: HYP mode not available
[    0.094396] futex hash table entries: 1024 (order: 5, 131072 bytes)
[    0.094458] audit: initializing netlink subsys (disabled)
[    0.094483] audit: type=2000 audit(0.088:1): initialized
[    0.097585] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    0.097876] NFS: Registering the id_resolver key type
[    0.097899] Key type id_resolver registered
[    0.097903] Key type id_legacy registered
[    0.097990] fuse init (API version 7.24)
[    0.098207] 9p: Installing v9fs 9p2000 file system support
[    0.098925] io scheduler noop registered
[    0.098996] io scheduler cfq registered (default)
[    0.099465] gpio_rcar e6050000.gpio: driving 16 GPIOs
[    0.099567] gpio_rcar e6051000.gpio: driving 28 GPIOs
[    0.099629] gpio_rcar e6052000.gpio: driving 15 GPIOs
[    0.099686] gpio_rcar e6053000.gpio: driving 16 GPIOs
[    0.099747] gpio_rcar e6054000.gpio: driving 18 GPIOs
[    0.099818] gpio_rcar e6055000.gpio: driving 26 GPIOs
[    0.099896] gpio_rcar e6055400.gpio: driving 32 GPIOs
[    0.099943] gpio_rcar e6055800.gpio: driving 4 GPIOs
[    0.102240] xenfs: not registering filesystem on non-xen platform
[    0.103259] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.103771] SuperH (H)SCI(F) driver initialized
[    0.103894] e6e68000.serial: ttySC1 at MMIO 0xe6e68000 (irq = 77, base_baud = 0) is a scif
[    0.104112] e6e88000.serial: ttySC0 at MMIO 0xe6e88000 (irq = 78, base_baud = 0) is a scif
[    0.482589] console [ttySC0] enabled
[    0.484631] msm_serial: driver initialized
[    0.486847] Unable to detect cache hierarchy from DT for CPU 0
[    0.491419] loop: module loaded
[    0.493560] scsi host0: sata_rcar
[    0.495317] ata1: SATA max UDMA/133 irq 80
[    0.497576] tun: Universal TUN/TAP device driver, 1.6
[    0.500101] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    0.503319] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[    0.506230] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[    0.509198] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.3.0-k
[    0.512688] igb: Copyright (c) 2007-2014 Intel Corporation.
[    0.515484] igbvf: Intel(R) Gigabit Virtual Function Network Driver - version 2.0.2-k
[    0.519387] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[    0.522354] sky2: driver version 1.30
[    0.524472] libphy: ravb_mii: probed
[    0.526745] ravb e6800000.ethernet eth0: Base address at 0xe6800000, 2e:09:0a:00:83:92, IRQ 74.
[    0.531260] VFIO - User Level meta-driver version: 0.3
[    0.534057] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.537310] ehci-pci: EHCI PCI platform driver
[    0.539550] ehci-platform: EHCI generic platform driver
[    0.542184] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.545269] ohci-pci: OHCI PCI platform driver
[    0.547507] ohci-platform: OHCI generic platform driver
[    0.550157] usbcore: registered new interface driver usb-storage
[    0.553260] mousedev: PS/2 mouse device common for all mice
[    0.556529] i2c-rcar e6510000.i2c: probed
[    0.558697] sdhci: Secure Digital Host Controller Interface driver
[    0.561774] sdhci: Copyright(c) Pierre Ossman
[    0.563965] Synopsys Designware Multimedia Card Interface Driver
[    0.567020] sdhci-pltfm: SDHCI platform and OF driver helper
[    0.569913] ledtrig-cpu: registered to indicate activity on CPUs
[    0.573146] usbcore: registered new interface driver usbhid
[    0.575926] usbhid: USB HID core driver
[    0.580375] cs2000-cp 2-004f: revision - C1
[    0.582756] ak4613-codec 2-0010: No cache used with register defaults set!
[    0.588226] rcar_sound ec500000.sound: probed
[    0.590702] NET: Registered protocol family 17
[    0.592959] 9pnet: Installing 9P2000 support
[    0.595129] Key type dns_resolver registered
[    0.597492] registered taskstats version 1
[    0.600031] asoc-simple-card sound: ak4613-hifi <-> ec500000.sound mapping ok
[    0.606510] hctosys: unable to open rtc device (rtc0)
[    0.676475] ravb e6800000.ethernet eth0: limited PHY to 100Mbit/s
[    0.679528] Micrel KSZ9031 Gigabit PHY e6800000.etherne:00: attached PHY driver [Micrel KSZ9031 Gigabit PHY] (mii_bus:phy_addr=e6800000.etherne:00, irq=136)
[    0.902003] ata1: link resume succeeded after 1 retries
[    1.010734] ata1: SATA link down (SStatus 0 SControl 300)
[   10.686002] Waiting up to 110 more seconds for network.
...
