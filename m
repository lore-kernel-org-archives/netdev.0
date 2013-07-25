From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH v5 0/3] ARM: shmobile: lager: enable Ether
Date: Thu, 25 Jul 2013 12:09:58 +0200
Message-ID: <3554825.Zlt5jMD3jh@avalon>
References: <1374656169-9241-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1374656169-9241-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Simon

Thank you for the patches.

On Wednesday 24 July 2013 17:56:06 Simon Horman wrote:
> this short series enables the on-board ethernet
> of the r8a7790 SoC for on lager board.
> 
> It has a run-time dependency on
> "sh_eth: add support for r8a7790 SoC"
> 
> It has been built on top of renesas-next-20130724v2.
> 
> Simon Horman (3):
>   ARM: shmobile: r8a7790: clocks for Ether support
>   ARM: shmobile: lager: enable Ether
>   ARM: shmobile: lager: enable nfsroot in DTS
> 
>  arch/arm/boot/dts/r8a7790-lager.dts    |  2 +-
>  arch/arm/mach-shmobile/board-lager.c   | 30 ++++++++++++++++++++++++++++++
>  arch/arm/mach-shmobile/clock-r8a7790.c |  4 ++++
>  3 files changed, 35 insertions(+), 1 deletion(-)

With this series and "[PATCH 0/2 v4 net-next repost] sh_eth: Add support for
r8a7790 SoC" applied on top of renesas-devel-20130725, booting the Lager
board usually (about 90% of the time) results in receive FIFO overflows and
disabling of the sh-eth IRQ:

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 3.11.0-rc2-ag5+ (laurent@avalon) (gcc version 4.7.3 20130205 (prerelease) (crosstool-NG linaro-1.13.1-4.7-2013.02-01-20130221 - Linaro GCC 2013.02) ) #678 SMP Thu Jul 25 12:3
[    0.000000] CPU: ARMv7 Processor [413fc0f2] revision 2 (ARMv7), cr=10c5387d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, PIPT instruction cache
[    0.000000] Machine: lager, model: Lager
[    0.000000] cma: CMA: reserved 16 MiB at 6e800000
[    0.000000] Memory policy: ECC disabled, Data cache writealloc
[    0.000000] PERCPU: Embedded 7 pages/cpu @c14fa000 s8192 r8192 d12288 u32768
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 522768
[    0.000000] Kernel command line: console=ttySC6,115200 root=/dev/nfs ip=dhcp nfsroot=,rsize=4096,wsize=4096 rw
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Memory: 2058432K/2097152K available (3139K kernel code, 376K rwdata, 1092K rodata, 200K init, 191K bss, 38720K reserved, 1318912K highmem)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
[    0.000000]     vmalloc : 0xf0000000 - 0xff000000   ( 240 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xef800000   ( 760 MB)
[    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
[    0.000000]     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
[    0.000000]       .text : 0xc0008000 - 0xc042af1c   (4236 kB)
[    0.000000]       .init : 0xc042b000 - 0xc045d000   ( 200 kB)
[    0.000000]       .data : 0xc045e000 - 0xc04bc1e0   ( 377 kB)
[    0.000000]        .bss : 0xc04bc1e0 - 0xc04ec0d8   ( 192 kB)
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU restricting CPUs from NR_CPUS=4 to nr_cpu_ids=1.
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] Architected local timer running at 10.00MHz (virt).
[    0.000000] Switching to timer-based delay loop
[    0.000000] sched_clock: ARM arch timer >56 bits at 10000kHz, resolution 100ns
[    0.000000] sched_clock: 32 bits at 1kHz, resolution 976562ns, wraps every 4194303999ms
[    0.000000] Console: colour dummy device 80x30
[    0.000270] Calibrating delay loop (skipped), value calculated using timer frequency.. 20.41 BogoMIPS (lpj=9765)
[    0.000281] pid_max: default: 32768 minimum: 301
[    0.000385] Mount-cache hash table entries: 512
[    0.000935] CPU: Testing write buffer coherency: ok
[    0.001150] CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
[    0.001171] Setting up static identity map for 0xc03174e0 - 0xc0317538
[    0.001606] Brought up 1 CPUs
[    0.001614] SMP: Total of 1 processors activated (20.41 BogoMIPS).
[    0.001620] CPU: All CPU(s) started in SVC mode.
[    0.011784] pinctrl core: initialized pinctrl subsystem
[    0.012316] regulator-dummy: no parameters
[    0.012814] NET: Registered protocol family 16
[    0.013869] DMA: preallocated 256 KiB pool for atomic coherent allocations
[    0.016792] sh-pfc pfc-r8a7790: r8a77900_pfc support registered
[    0.019223] renesas_irqc renesas_irqc.0: driving 4 irqs
[    0.020277] No ATAGs?
[    0.030319] bio: create slab <bio-0> at 0
[    0.031065] fixed-3.3V: 3300 mV 
[    0.032184] usbcore: registered new interface driver usbfs
[    0.032300] usbcore: registered new interface driver hub
[    0.032436] usbcore: registered new device driver usb
[    0.032822] media: Linux media interface: v0.10
[    0.032927] Linux video capture interface: v2.00
[    0.033465] sh_cmt sh_cmt.0: used for clock events
[    0.034553] Switched to clocksource arch_sys_counter
[    0.045044] NET: Registered protocol family 2
[    0.045431] TCP established hash table entries: 8192 (order: 4, 65536 bytes)
[    0.045535] TCP bind hash table entries: 8192 (order: 4, 65536 bytes)
[    0.045637] TCP: Hash tables configured (established 8192 bind 8192)
[    0.045675] TCP: reno registered
[    0.045685] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.045709] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.045853] NET: Registered protocol family 1
[    0.046040] RPC: Registered named UNIX socket transport module.
[    0.046047] RPC: Registered udp transport module.
[    0.046052] RPC: Registered tcp transport module.
[    0.046058] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.047801] bounce pool size: 64 pages
[    0.048179] msgmni has been set to 1476
[    0.048406] io scheduler noop registered (default)
[    0.048640] gpio_rcar gpio_rcar.0: driving 32 GPIOs
[    0.048850] gpio_rcar gpio_rcar.1: driving 32 GPIOs
[    0.049059] gpio_rcar gpio_rcar.2: driving 32 GPIOs
[    0.049320] gpio_rcar gpio_rcar.3: driving 32 GPIOs
[    0.049543] gpio_rcar gpio_rcar.4: driving 32 GPIOs
[    0.049746] gpio_rcar gpio_rcar.5: driving 32 GPIOs
[    0.050568] SuperH (H)SCI(F) driver initialized
[    0.050670] sh-sci.0: ttySC0 at MMIO 0xe6c40000 (irq = 176) is a scifa
[    0.050940] sh-sci.1: ttySC1 at MMIO 0xe6c50000 (irq = 177) is a scifa
[    0.051219] sh-sci.2: ttySC2 at MMIO 0xe6c20000 (irq = 180) is a scifb
[    0.051486] sh-sci.3: ttySC3 at MMIO 0xe6c30000 (irq = 181) is a scifb
[    0.051748] sh-sci.4: ttySC4 at MMIO 0xe6ce0000 (irq = 182) is a scifb
[    0.052000] sh-sci.5: ttySC5 at MMIO 0xe6c60000 (irq = 183) is a scifa
[    0.052480] sh-sci.6: ttySC6 at MMIO 0xe6e60000 (irq = 184) is a scif
[    0.562695] console [ttySC6] enabled
[    0.566727] sh-sci.7: ttySC7 at MMIO 0xe6e68000 (irq = 185) is a scif
[    0.573653] sh-sci.8: ttySC8 at MMIO 0xe62c0000 (irq = 186) is a hscif
[    0.580596] sh-sci sh-sci.9: Attempting to register port 10 when only 9 are available.
[    0.588686] sh-sci sh-sci.9: Consider bumping CONFIG_SERIAL_SH_SCI_NR_UARTS!
[    0.595897] sh-sci: probe of sh-sci.9 failed with error -22
[    0.601828] [drm] Initialized drm 1.1.0 20060810
[    0.624313] libphy: sh_mii: probed
[    0.627795] Base address at 0xee700000, 2e:09:0a:00:3d:aa, IRQ 194.
[    0.634411] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.641098] ehci-platform: EHCI generic platform driver
[    0.646611] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.652929] ohci-platform: OHCI generic platform driver
[    0.661136] rcar_thermal rcar_thermal: 1 sensor probed
[    0.666557] cpuidle: using governor ladder
[    0.670759] cpuidle: using governor menu
[    0.675980] usbcore: registered new interface driver usbhid
[    0.681689] usbhid: USB HID core driver
[    0.685698] TCP: cubic registered
[    0.689090] NET: Registered protocol family 17
[    0.693670] VFP support v0.3: implementor 41 architecture 4 part 30 variant f rev 0
[    0.701519] Registering SWP/SWPB emulation handler
[    0.707617] input: gpio-keys as /devices/platform/gpio-keys/input/input0
[    0.718635] net eth0: attached phy 1 to driver Generic PHY
[    0.735734] Sending DHCP requests .
[    2.725075] libphy: r8a7790-ether-ff:01 - Link is Up - 100/Full
., OK
[    3.429541] IP-Config: Got DHCP answer from 192.168.1.47, my address is 192.168.1.254
[    3.437647] IP-Config: Complete:
[    3.440956]      device=eth0, hwaddr=2e:09:0a:00:3d:aa, ipaddr=192.168.1.254, mask=255.255.255.0, gw=255.255.255.255
[    3.451707]      host=192.168.1.254, domain=, nis-domain=(none)
[    3.457759]      bootserver=192.168.1.47, rootserver=192.168.1.47, rootpath=/home/laurent/src/iob/netboot/renesas
[    3.468062]      nameserver0=192.168.1.47
[    3.477641] VFS: Mounted root (nfs filesystem) on device 0:10.
[    3.483731] Freeing unused kernel memory: 200K (c042b000 - c045d000)
INIT: version 2.86 booting
Please wait: booting...
Starting udev
[    8.201044] udevd (365): /proc/365/oom_adj is deprecated, please use /proc/365/oom_score_adj instead.
[    8.635199] sh_mmcif sh_mmcif.1: driver version 2010-04-28
[    8.885323] mmc0: BKOPS_EN bit is not set
[    8.945013] net eth0: Receive FIFO Overflow
[    9.028893] net eth0: Receive FIFO Overflow
[    9.112777] net eth0: Receive FIFO Overflow
[    9.321193] irq 194: nobody cared (try booting with the "irqpoll" option)
[    9.328121] CPU: 0 PID: 6 Comm: kworker/u2:0 Not tainted 3.11.0-rc2-ag5+ #678
[    9.335411] Workqueue: kmmcd mmc_rescan
[    9.339330] Backtrace: 
[    9.341850] [<c0012474>] (dump_backtrace+0x0/0x10c) from [<c0012758>] (show_stack+0x18/0x1c)
[    9.350458]  r6:000000c2 r5:00000000 r4:00000000 r3:ee05c000
[    9.356275] [<c0012740>] (show_stack+0x0/0x1c) from [<c0312710>] (dump_stack+0x88/0xbc)
[    9.364446] [<c0312688>] (dump_stack+0x0/0xbc) from [<c0077e90>] (__report_bad_irq+0x28/0xc8)
[    9.373142]  r4:ee00fb40 r3:ee05c000
[    9.376809] [<c0077e68>] (__report_bad_irq+0x0/0xc8) from [<c00783ec>] (note_interrupt+0x1e8/0x244)
[    9.386036]  r6:000000c2 r5:00000000 r4:ee00fb40 r3:0001863c
[    9.391846] [<c0078204>] (note_interrupt+0x0/0x244) from [<c0075fdc>] (handle_irq_event_percpu+0xb0/0x19c)
[    9.401698] [<c0075f2c>] (handle_irq_event_percpu+0x0/0x19c) from [<c007612c>] (handle_irq_event+0x64/0x84)
[    9.411638] [<c00760c8>] (handle_irq_event+0x0/0x84) from [<c00791b0>] (handle_fasteoi_irq+0x84/0x168)
[    9.421131]  r6:ee05dd58 r5:000000c2 r4:ee00fb40 r3:00000000
[    9.426941] [<c007912c>] (handle_fasteoi_irq+0x0/0x168) from [<c007591c>] (generic_handle_irq+0x28/0x38)
[    9.436611]  r4:000000c2 r3:c007912c
[    9.440276] [<c00758f4>] (generic_handle_irq+0x0/0x38) from [<c000fe38>] (handle_IRQ+0x40/0x9c)
[    9.449149]  r4:c045bd14 r3:000007d4
[    9.452813] [<c000fdf8>] (handle_IRQ+0x0/0x9c) from [<c000939c>] (gic_handle_irq+0x30/0x64)
[    9.461332]  r6:ee05dc68 r5:c046680c r4:f000200c r3:000001a0
[    9.467141] [<c000936c>] (gic_handle_irq+0x0/0x64) from [<c0013300>] (__irq_svc+0x40/0x50)
[    9.475572] Exception stack(0xee05dc68 to 0xee05dcb0)
[    9.480725] dc60:                   00000003 00000000 c04cec80 00000000 00000002 0000001b
[    9.489069] dc80: 00000000 ee05c000 c0460080 60000113 00000006 ee05dcfc ee05dcb0 ee05dcb0
[    9.497411] dca0: c002ccac c002cd28 80000113 ffffffff
[    9.502562]  r7:ee05dc9c r6:ffffffff r5:80000113 r4:c002cd28
[    9.508374] [<c002cc94>] (__do_softirq+0x0/0x1e0) from [<c002d1c8>] (irq_exit+0x9c/0xd4)
[    9.516630] [<c002d12c>] (irq_exit+0x0/0xd4) from [<c000fe3c>] (handle_IRQ+0x44/0x9c)
[    9.524617]  r4:c045bd14 r3:000007d4
[    9.528281] [<c000fdf8>] (handle_IRQ+0x0/0x9c) from [<c000939c>] (gic_handle_irq+0x30/0x64)
[    9.536799]  r6:ee05dd58 r5:c046680c r4:f000200c r3:000001a0
[    9.542608] [<c000936c>] (gic_handle_irq+0x0/0x64) from [<c0013300>] (__irq_svc+0x40/0x50)
[    9.551039] Exception stack(0xee05dd58 to 0xee05dda0)
[    9.556190] dd40:                                                       c04bdec0 60000193
[    9.564534] dd60: c048e300 ee05c000 c04bdec0 00000001 0000001d ee05c000 60000113 60000113
[    9.572877] dd80: 00000006 ee05de04 ee05dd50 ee05dda0 c0026ca0 c00273ec 60000113 ffffffff
[    9.581218]  r7:ee05dd8c r6:ffffffff r5:60000113 r4:c00273ec
[    9.587034] [<c00271b4>] (vprintk_emit+0x0/0x4e4) from [<c0311304>] (printk+0x3c/0x44)
[    9.595114] [<c03112c8>] (printk+0x0/0x44) from [<c024ff64>] (mmc_init_card+0x14e8/0x155c)
[    9.603544]  r3:ee28fc00 r2:000007dc r1:edac54c0 r0:c03fa4d4
[    9.609355] [<c024ea7c>] (mmc_init_card+0x0/0x155c) from [<c02501b4>] (mmc_attach_mmc+0xb4/0x1c8)
[    9.618409] [<c0250100>] (mmc_attach_mmc+0x0/0x1c8) from [<c024ca94>] (mmc_rescan+0x280/0x2e4)
[    9.627193]  r5:c0358e60 r4:ee28fe78
[    9.630862] [<c024c814>] (mmc_rescan+0x0/0x2e4) from [<c003f110>] (process_one_work+0x124/0x374)
[    9.639824]  r8:ee037c00 r7:ee05c000 r6:ee023200 r5:ee28fe78 r4:ee034e40 r3:c024c814
[    9.647868] [<c003efec>] (process_one_work+0x0/0x374) from [<c003f824>] (worker_thread+0x138/0x3a8)
[    9.657103] [<c003f6ec>] (worker_thread+0x0/0x3a8) from [<c0045944>] (kthread+0xac/0xb8)
[    9.665360] [<c0045898>] (kthread+0x0/0xb8) from [<c000f5f8>] (ret_from_fork+0x14/0x3c)
[    9.673523]  r7:00000000 r6:00000000 r5:c0045898 r4:ee04bd18
[    9.679329] handlers:
[    9.681647] [<c01eb77c>] sh_eth_interrupt
[    9.685743] Disabling IRQ #194
[    9.694575] mmc0: new high speed MMC card at address 0001
[    9.702216] mmcblk0: mmc0:0001 MMC08G 7.32 GiB 
[    9.707244] mmcblk0boot0: mmc0:0001 MMC08G partition 1 2.00 MiB
[    9.713407] mmcblk0boot1: mmc0:0001 MMC08G partition 2 2.00 MiB
[    9.722119]  mmcblk0: unknown partition table
[    9.729391]  mmcblk0boot1: unknown partition table
[    9.737484]  mmcblk0boot0: unknown partition table

-- 
Regards,

Laurent Pinchart

