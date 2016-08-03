From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Kernel NFS boot failure
Date: Wed, 3 Aug 2016 14:41:00 +0300
Message-ID: <674e6841-d2c5-ccae-6633-a699e848e6d2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
 Sekhar Nori <nsekhar@ti.com>, linux-arm <linux-arm-kernel@lists.infradead.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi All,

We observe Kernel boot failure while running NFS boot stress test (1000 iterations):
- Linux version 4.7.0 
- am335x-evm (TI AM335x EVM)
- failure rate 10-20 times per test.
Originally this issue was reproduced using TI Kernel 4.4
( git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git, branch: ti-linux-4.4.y)
on both am335x-evm and am57xx-beagle-x15(am57xx-evm) platforms.
This issues has not been reproduced with TI Kernel 4.1 before.

The SysRq shows that system stuck in nfs_fs_mount()

[  207.904632] [<c07ab34c>] (schedule) from [<c0783554>] (rpc_wait_bit_killable+0x2c/0xd8)
[  207.912996] [<c0783554>] (rpc_wait_bit_killable) from [<c07ab7f0>] (__wait_on_bit+0x84/0xc0)
[  207.921812] [<c07ab7f0>] (__wait_on_bit) from [<c07ab890>] (out_of_line_wait_on_bit+0x64/0x70)
[  207.930810] [<c07ab890>] (out_of_line_wait_on_bit) from [<c07843f4>] (__rpc_execute+0x18c/0x544)
[  207.939988] [<c07843f4>] (__rpc_execute) from [<c0779f24>] (rpc_run_task+0x13c/0x158)
[  207.948166] [<c0779f24>] (rpc_run_task) from [<c0779f84>] (rpc_call_sync+0x44/0xc4)
[  207.956163] [<c0779f84>] (rpc_call_sync) from [<c077a04c>] (rpc_ping+0x48/0x68)
[  207.963796] [<c077a04c>] (rpc_ping) from [<c077a158>] (rpc_create_xprt+0xec/0x164)
[  207.971702] [<c077a158>] (rpc_create_xprt) from [<c077a2c0>] (rpc_create+0xf0/0x1a0)
[  207.979794] [<c077a2c0>] (rpc_create) from [<c0393088>] (nfs_create_rpc_client+0xd4/0xec)
[  207.988338] [<c0393088>] (nfs_create_rpc_client) from [<c0394d10>] (nfs_init_client+0x20/0x78)
[  207.997332] [<c0394d10>] (nfs_init_client) from [<c03949d4>] (nfs_create_server+0xa0/0x3bc)
[  208.006057] [<c03949d4>] (nfs_create_server) from [<c03b197c>] (nfs3_create_server+0x8/0x20)
[  208.014879] [<c03b197c>] (nfs3_create_server) from [<c03a34c4>] (nfs_try_mount+0xc4/0x1f0)
[  208.023513] [<c03a34c4>] (nfs_try_mount) from [<c03a2c48>] (nfs_fs_mount+0x290/0x910)
[  208.031702] [<c03a2c48>] (nfs_fs_mount) from [<c0294d24>] (mount_fs+0x44/0x168)

Has anyone else seen this issue?

I'd be appreciated for any help or advice related to this issue?

Thanks in advance.

regards,
-grygorii

=================== kernel log =======================

Starting kernel ...

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 4.7.0 (lcpdbld@dflsdit-build06.dal.design.ti.com) (gcc version 4.9.3 20150413 (prerelease) (Linaro GCC 4.9-2015.05) ) #1 SMP Fri Jul 29 17:41:27 CDT 2016
[    0.000000] CPU: ARMv7 Processor [413fc082] revision 2 (ARMv7), cr=10c5387d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
[    0.000000] Machine model: TI AM335x EVM
[    0.000000] cma: Reserved 16 MiB at 0xbe800000
[    0.000000] Memory policy: Data cache writeback
[    0.000000] CPU: All CPU(s) started in SVC mode.
[    0.000000] AM335X ES2.1 (sgx neon )
[    0.000000] percpu: Embedded 15 pages/cpu @ef6b9000 s29440 r8192 d23808 u61440
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 259904
[    0.000000] Kernel command line: console=ttyO0,115200n8 earlyprintk=serial,ttyO0,115200n8 rootwait   ip=:::::eth0:dhcp  root=/dev/nfs rw nfsroot=192.168.0.1:/home/tigtfarm04/NFS_exports/linux/am335x-evm/autofs/bdb57ec4c06590e6172879867ab30d1e,nolock,v3,tcp,rsize=4096,wsize=4096 
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Memory: 999648K/1046528K available (7354K kernel code, 768K rwdata, 2360K rodata, 1024K init, 8122K bss, 30496K reserved, 16384K cma-reserved, 243712K highmem)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
[    0.000000]     vmalloc : 0xf0800000 - 0xff800000   ( 240 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf0000000   ( 768 MB)
[    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
[    0.000000]     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
[    0.000000]       .text : 0xc0008000 - 0xc0a7c8e8   (10707 kB)
[    0.000000]       .init : 0xc0b00000 - 0xc0c00000   (1024 kB)
[    0.000000]       .data : 0xc0c00000 - 0xc0cc0304   ( 769 kB)
[    0.000000]        .bss : 0xc0cc2000 - 0xc14b0a40   (8123 kB)
[    0.000000] Running RCU self tests
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU lockdep checking is enabled.
[    0.000000] 	Build-time adjustment of leaf fanout to 32.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=2 to nr_cpu_ids=1.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=32, nr_cpu_ids=1
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] IRQ: Found an INTC at 0xfa200000 (revision 5.0) with 128 interrupts
[    0.000000] OMAP clockevent source: timer2 at 24000000 Hz
[    0.000017] sched_clock: 32 bits at 24MHz, resolution 41ns, wraps every 89478484971ns
[    0.000039] clocksource: timer1: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 79635851949 ns
[    0.000090] OMAP clocksource: timer1 at 24000000 Hz
[    0.000600] clocksource_probe: no matching clocksources found
[    0.001543] Console: colour dummy device 80x30
[    0.001605] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.001615] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.001622] ... MAX_LOCK_DEPTH:          48
[    0.001630] ... MAX_LOCKDEP_KEYS:        8191
[    0.001637] ... CLASSHASH_SIZE:          4096
[    0.001645] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.001652] ... MAX_LOCKDEP_CHAINS:      65536
[    0.001659] ... CHAINHASH_SIZE:          32768
[    0.001667]  memory used by lock dependency info: 5167 kB
[    0.001675]  per task-struct memory footprint: 1536 bytes
[    0.001709] Calibrating delay loop... 996.14 BogoMIPS (lpj=4980736)
[    0.078684] pid_max: default: 32768 minimum: 301
[    0.079156] Security Framework initialized
[    0.079302] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.079317] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.082842] CPU: Testing write buffer coherency: ok
[    0.084628] CPU0: thread -1, cpu 0, socket -1, mpidr 0
[    0.084709] Setting up static identity map for 0x80100000 - 0x80100070
[    0.089402] Brought up 1 CPUs
[    0.089425] SMP: Total of 1 processors activated (996.14 BogoMIPS).
[    0.089436] CPU: All CPU(s) started in SVC mode.
[    0.093423] devtmpfs: initialized
[    0.133262] VFP support v0.3: implementor 41 architecture 3 part 30 variant c rev 3
[    0.134204] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
[    0.135944] pinctrl core: initialized pinctrl subsystem
[    0.141766] NET: Registered protocol family 16
[    0.147074] DMA: preallocated 256 KiB pool for atomic coherent allocations
[    0.203979] omap_hwmod: debugss: _wait_target_disable failed
[    0.261060] cpuidle: using governor menu
[    0.274990] OMAP GPIO hardware version 0.1
[    0.301030] omap-gpmc 50000000.gpmc: could not find pctldev for node /ocp/l4_wkup@44c00000/scm@210000/pinmux@800/nandflash_pins_s0, deferring probe
[    0.307161] No ATAGs?
[    0.307186] hw-breakpoint: debug architecture 0x4 unsupported.
[    0.307435] omap4_sram_init:Unable to allocate sram needed to handle errata I688
[    0.307451] omap4_sram_init:Unable to get sram pool needed to handle errata I688
[    0.354305] edma 49000000.edma: TI EDMA DMA engine driver
[    0.361450] SCSI subsystem initialized
[    0.363558] omap_i2c 44e0b000.i2c: could not find pctldev for node /ocp/l4_wkup@44c00000/scm@210000/pinmux@800/pinmux_i2c0_pins, deferring probe
[    0.363669] omap_i2c 4802a000.i2c: could not find pctldev for node /ocp/l4_wkup@44c00000/scm@210000/pinmux@800/pinmux_i2c1_pins, deferring probe
[    0.363964] pps_core: LinuxPPS API ver. 1 registered
[    0.363975] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.364026] PTP clock support registered
[    0.368809] clocksource: Switched to clocksource timer1
[    0.471686] VFS: Disk quotas dquot_6.6.0
[    0.471879] VFS: Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    0.504828] NET: Registered protocol family 2
[    0.507032] TCP established hash table entries: 8192 (order: 3, 32768 bytes)
[    0.507202] TCP bind hash table entries: 8192 (order: 6, 294912 bytes)
[    0.509721] TCP: Hash tables configured (established 8192 bind 8192)
[    0.510050] UDP hash table entries: 512 (order: 3, 40960 bytes)
[    0.510377] UDP-Lite hash table entries: 512 (order: 3, 40960 bytes)
[    0.511368] NET: Registered protocol family 1
[    0.513282] RPC: Registered named UNIX socket transport module.
[    0.513309] RPC: Registered udp transport module.
[    0.513320] RPC: Registered tcp transport module.
[    0.513330] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.516207] hw perfevents: enabled with armv7_cortex_a8 PMU driver, 5 counters available
[    0.521290] futex hash table entries: 256 (order: 2, 16384 bytes)
[    0.521519] audit: initializing netlink subsys (disabled)
[    0.521801] audit: type=2000 audit(0.510:1): initialized
[    0.525994] workingset: timestamp_bits=12 max_order=18 bucket_order=6
[    0.528964] NFS: Registering the id_resolver key type
[    0.529371] Key type id_resolver registered
[    0.529388] Key type id_legacy registered
[    0.529583] jffs2: version 2.2. (NAND) (SUMMARY)   2001-2006 Red Hat, Inc.
[    0.535376] bounce: pool size: 64 pages
[    0.535560] io scheduler noop registered
[    0.535575] io scheduler deadline registered
[    0.535632] io scheduler cfq registered (default)
[    0.538164] pinctrl-single 44e10800.pinmux: 142 pins at pa f9e10800 size 568
[    0.543123] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.549627] omap_uart 44e09000.serial: no wakeirq for uart0
[    0.550363] 44e09000.serial: ttyO0 at MMIO 0x44e09000 (irq = 158, base_baud = 3000000) is a OMAP UART0
[    1.280532] console [ttyO0] enabled
[    1.286200] omap_uart 48022000.serial: no wakeirq for uart1
[    1.292563] 48022000.serial: ttyO1 at MMIO 0x48022000 (irq = 159, base_baud = 3000000) is a OMAP UART1
[    1.343677] brd: module loaded
[    1.372084] loop: module loaded
[    1.378098] mtdoops: mtd device (mtddev=name/number) must be supplied
[    1.448758] davinci_mdio 4a101000.mdio: davinci mdio revision 1.6
[    1.455149] davinci_mdio 4a101000.mdio: detected phy mask fffffffe
[    1.466091] libphy: 4a101000.mdio: probed
[    1.470478] davinci_mdio 4a101000.mdio: phy[0]: device 4a101000.mdio:00, driver Atheros 8031 ethernet
[    1.481604] cpsw 4a100000.ethernet: Detected MACID = d0:ff:50:57:02:d9
[    1.494503] mousedev: PS/2 mouse device common for all mice
[    1.500507] i2c /dev entries driver
[    1.506791] omap_hsmmc 48060000.mmc: Got CD GPIO
[    1.629181] ledtrig-cpu: registered to indicate activity on CPUs
[    1.637125] oprofile: using arm/armv7
[    1.641883] Initializing XFRM netlink socket
[    1.646812] NET: Registered protocol family 10
[    1.657446] sit: IPv6 over IPv4 tunneling driver
[    1.664949] NET: Registered protocol family 17
[    1.669812] NET: Registered protocol family 15
[    1.674901] Key type dns_resolver registered
[    1.679650] omap_voltage_late_init: Voltage driver support not added
[    1.686325] sr_dev_init: No voltage domain specified for smartreflex0. Cannot initialize
[    1.694833] sr_dev_init: No voltage domain specified for smartreflex1. Cannot initialize
[    1.704103] ThumbEE CPU extension supported.
[    1.708687] Registering SWP/SWPB emulation handler
[    1.713694] SmartReflex Class3 initialized
[    1.727416] omap-gpmc 50000000.gpmc: omap_device: omap_device_enable() called from invalid state 1
[    1.736984] omap-gpmc 50000000.gpmc: use pm_runtime_put_sync_suspend() in driver?
[    1.744891] omap-gpmc 50000000.gpmc: GPMC revision 6.0
[    1.750534] gpmc_mem_init: disabling cs 0 mapped at 0x0-0x1000000
[    1.763255] nand: device found, Manufacturer ID: 0x2c, Chip ID: 0xda
[    1.770059] nand: Micron MT29F2G08ABAEAWP
[    1.774253] nand: 256 MiB, SLC, erase size: 128 KiB, page size: 2048, OOB size: 64
[    1.782278] nand: using OMAP_ECC_BCH8_CODE_HW ECC scheme
[    1.788157] 10 ofpart partitions found on MTD device 8000000.nand
[    1.794573] Creating 10 MTD partitions on "8000000.nand":
[    1.800255] 0x000000000000-0x000000020000 : "NAND.SPL"
[    1.813707] 0x000000020000-0x000000040000 : "NAND.SPL.backup1"
[    1.824552] 0x000000040000-0x000000060000 : "NAND.SPL.backup2"
[    1.835304] 0x000000060000-0x000000080000 : "NAND.SPL.backup3"
[    1.845935] 0x000000080000-0x0000000c0000 : "NAND.u-boot-spl-os"
[    1.856686] 0x0000000c0000-0x0000001c0000 : "NAND.u-boot"
[    1.867218] 0x0000001c0000-0x0000001e0000 : "NAND.u-boot-env"
[    1.877621] 0x0000001e0000-0x000000200000 : "NAND.u-boot-env.backup1"
[    1.888812] 0x000000200000-0x000000a00000 : "NAND.kernel"
[    1.901811] 0x000000a00000-0x000010000000 : "NAND.file-system"
[    2.029897] tps65910 0-002d: No interrupt support, no core IRQ
[    2.040322] vrtc: supplied by vbat
[    2.051821] vio: supplied by vbat
[    2.058770] vdd1: supplied by vbat
[    2.063500] vdd_mpu: Bringing 1325000uV into 1312500-1312500uV
[    2.072533] vdd2: supplied by vbat
[    2.082954] vdig1: supplied by vbat
[    2.089848] vdig2: supplied by vbat
[    2.096603] vpll: supplied by vbat
[    2.103298] vdac: supplied by vbat
[    2.110075] vaux1: supplied by vbat
[    2.116777] vaux2: supplied by vbat
[    2.123576] vaux33: supplied by vbat
[    2.130510] vmmc: supplied by vbat
[    2.137134] vbb: supplied by vbat
[    2.143675] omap_i2c 44e0b000.i2c: bus 0 rev0.11 at 400 kHz
[    2.154258] omap_i2c 4802a000.i2c: bus 1 rev0.11 at 100 kHz
[    2.161584] omap_hsmmc 48060000.mmc: Got CD GPIO
[    2.211668] hctosys: unable to open rtc device (rtc0)
[    2.216968] sr_init: No PMIC hook to init smartreflex
[    2.222637] sr_init: platform driver register failed for SR
[    2.247587] net eth0: initializing cpsw version 1.12 (0)
[    2.286454] mmc1: host does not support reading read-only switch, assuming write-enable
[    2.296952] mmc1: new high speed SDHC card at address 59b4
[    2.306618] mmcblk1: mmc1:59b4 NCard 7.51 GiB 
[    2.315976]  mmcblk1: p1 p2 p3
[    2.329789] Atheros 8031 ethernet 4a101000.mdio:00: attached PHY driver [Atheros 8031 ethernet] (mii_bus:phy_addr=4a101000.mdio:00, irq=-1)
[    2.343148] libphy: PHY 4a101000.mdio:01 not found
[    2.348160] net eth0: phy "4a101000.mdio:01" not found on slave 1, err -19
[    2.363596] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[    6.329622] cpsw 4a100000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[    6.338420] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    6.349476] Sending DHCP requests ., OK
[    6.409166] IP-Config: Got DHCP answer from 192.168.0.1, my address is 192.168.0.175
[    6.417934] IP-Config: Complete:
[    6.421439]      device=eth0, hwaddr=d0:ff:50:57:02:d9, ipaddr=192.168.0.175, mask=255.255.255.0, gw=192.168.0.1
[    6.432099]      host=192.168.0.175, domain=ti.com, nis-domain=(none)
[    6.438849]      bootserver=192.168.0.1, rootserver=192.168.0.1, rootpath=     nameserver0=192.0.2.2, nameserver1=192.0.2.3
[    6.450704] lis3_reg: disabling
[    6.453996] wlan-en-regulator: disabling
[  194.829109] random: nonblocking pool is initialized

- 20:53:45 [INFO] Boot attempt 1/1 failed
- 20:53:45 [INFO] Collecting kernel traces via sysrq...
- 20:53:55 [INFO] [  207.881249] sysrq: SysRq : Show State
[  207.885105]   task                PC stack   pid father
[  207.890567] swapper/0       D c07aaa40     0     1      0 0x00000000
[  207.897255] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  207.904632] [<c07ab34c>] (schedule) from [<c0783554>] (rpc_wait_bit_killable+0x2c/0xd8)
[  207.912996] [<c0783554>] (rpc_wait_bit_killable) from [<c07ab7f0>] (__wait_on_bit+0x84/0xc0)
[  207.921812] [<c07ab7f0>] (__wait_on_bit) from [<c07ab890>] (out_of_line_wait_on_bit+0x64/0x70)
[  207.930810] [<c07ab890>] (out_of_line_wait_on_bit) from [<c07843f4>] (__rpc_execute+0x18c/0x544)
[  207.939988] [<c07843f4>] (__rpc_execute) from [<c0779f24>] (rpc_run_task+0x13c/0x158)
[  207.948166] [<c0779f24>] (rpc_run_task) from [<c0779f84>] (rpc_call_sync+0x44/0xc4)
[  207.956163] [<c0779f84>] (rpc_call_sync) from [<c077a04c>] (rpc_ping+0x48/0x68)
[  207.963796] [<c077a04c>] (rpc_ping) from [<c077a158>] (rpc_create_xprt+0xec/0x164)
[  207.971702] [<c077a158>] (rpc_create_xprt) from [<c077a2c0>] (rpc_create+0xf0/0x1a0)
[  207.979794] [<c077a2c0>] (rpc_create) from [<c0393088>] (nfs_create_rpc_client+0xd4/0xec)
[  207.988338] [<c0393088>] (nfs_create_rpc_client) from [<c0394d10>] (nfs_init_client+0x20/0x78)
[  207.997332] [<c0394d10>] (nfs_init_client) from [<c03949d4>] (nfs_create_server+0xa0/0x3bc)
[  208.006057] [<c03949d4>] (nfs_create_server) from [<c03b197c>] (nfs3_create_server+0x8/0x20)
[  208.014879] [<c03b197c>] (nfs3_create_server) from [<c03a34c4>] (nfs_try_mount+0xc4/0x1f0)
[  208.023513] [<c03a34c4>] (nfs_try_mount) from [<c03a2c48>] (nfs_fs_mount+0x290/0x910)
[  208.031702] [<c03a2c48>] (nfs_fs_mount) from [<c0294d24>] (mount_fs+0x44/0x168)
[  208.039350] [<c0294d24>] (mount_fs) from [<c02b3420>] (vfs_kern_mount+0x54/0x134)
[  208.047171] [<c02b3420>] (vfs_kern_mount) from [<c02b6c40>] (do_mount+0x1d4/0xd30)
[  208.055078] [<c02b6c40>] (do_mount) from [<c02b7b08>] (SyS_mount+0x74/0x9c)
[  208.062363] [<c02b7b08>] (SyS_mount) from [<c0b014b4>] (mount_root+0x5c/0x124)
[  208.069910] [<c0b014b4>] (mount_root) from [<c0b016e0>] (prepare_namespace+0x164/0x1c8)
[  208.078272] [<c0b016e0>] (prepare_namespace) from [<c0b00f08>] (kernel_init_freeable+0x28c/0x2e0)
[  208.087541] [<c0b00f08>] (kernel_init_freeable) from [<c07a9418>] (kernel_init+0x8/0x118)
[  208.096092] [<c07a9418>] (kernel_init) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.103996] kthreadd        S c07aaa40     0     2      0 0x00000000
[  208.110653] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.118022] [<c07ab34c>] (schedule) from [<c015b258>] (kthreadd+0x220/0x248)
[  208.125386] [<c015b258>] (kthreadd) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.133017] ksoftirqd/0     S c07aaa40     0     3      2 0x00000000
[  208.139672] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.147037] [<c07ab34c>] (schedule) from [<c015e158>] (smpboot_thread_fn+0xd0/0x194)
[  208.155126] [<c015e158>] (smpboot_thread_fn) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.163034] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.170573] kworker/0:0     S c07aaa40     0     4      2 0x00000000
[  208.177243] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.184618] [<c07ab34c>] (schedule) from [<c01546e8>] (worker_thread+0xa4/0x4d0)
[  208.192344] [<c01546e8>] (worker_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.199889] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.207428] kworker/0:0H    S c07aaa40     0     5      2 0x00000000
[  208.214088] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.221452] [<c07ab34c>] (schedule) from [<c01546e8>] (worker_thread+0xa4/0x4d0)
[  208.229177] [<c01546e8>] (worker_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.236721] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.244260] kworker/u2:0    S c07aaa40     0     6      2 0x00000000
[  208.250918] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.258282] [<c07ab34c>] (schedule) from [<c01546e8>] (worker_thread+0xa4/0x4d0)
[  208.266007] [<c01546e8>] (worker_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.273551] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.281090] rcu_sched       S c07aaa40     0     7      2 0x00000000
[  208.287744] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.295120] [<c07ab34c>] (schedule) from [<c01ab8b8>] (rcu_gp_kthread+0x40/0x814)
[  208.302938] [<c01ab8b8>] (rcu_gp_kthread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.310573] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.318112] rcu_bh          S c07aaa40     0     8      2 0x00000000
[  208.324766] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.332130] [<c07ab34c>] (schedule) from [<c01ab8b8>] (rcu_gp_kthread+0x40/0x814)
[  208.339946] [<c01ab8b8>] (rcu_gp_kthread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.347581] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.355120] migration/0     S c07aaa40     0     9      2 0x00000000
[  208.361774] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.369137] [<c07ab34c>] (schedule) from [<c015e158>] (smpboot_thread_fn+0xd0/0x194)
[  208.377224] [<c015e158>] (smpboot_thread_fn) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.385131] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.392670] lru-add-drain   S c07aaa40     0    10      2 0x00000000
[  208.399328] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.406692] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  208.414600] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.422234] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.429774] cpuhp/0         S c07aaa40     0    11      2 0x00000000
[  208.436428] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.443791] [<c07ab34c>] (schedule) from [<c015e158>] (smpboot_thread_fn+0xd0/0x194)
[  208.451879] [<c015e158>] (smpboot_thread_fn) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.459785] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.467324] kdevtmpfs       S c07aaa40     0    12      2 0x00000000
[  208.473978] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.481353] [<c07ab34c>] (schedule) from [<c052a61c>] (devtmpfsd+0x2b8/0x2e4)
[  208.488809] [<c052a61c>] (devtmpfsd) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.495990] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.503529] netns           S c07aaa40     0    13      2 0x00000000
[  208.510188] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.517553] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  208.525460] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.533094] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.540633] kworker/0:1     S c07aaa40     0    14      2 0x00000000
[  208.547291] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.554655] [<c07ab34c>] (schedule) from [<c01546e8>] (worker_thread+0xa4/0x4d0)
[  208.562380] [<c01546e8>] (worker_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.569924] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.577463] oom_reaper      S c07aaa40     0    15      2 0x00000000
[  208.584116] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.591480] [<c07ab34c>] (schedule) from [<c0233250>] (oom_reaper+0x134/0x194)
[  208.599025] [<c0233250>] (oom_reaper) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.606297] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.613836] writeback       S c07aaa40     0    16      2 0x00000000
[  208.620494] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.627858] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  208.635765] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.643399] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.650939] kcompactd0      S c07aaa40     0    17      2 0x00000000
[  208.657593] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.664962] [<c07ab34c>] (schedule) from [<c025e868>] (kcompactd+0x490/0x5b0)
[  208.672417] [<c025e868>] (kcompactd) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.679598] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.687137] crypto          S c07aaa40     0    18      2 0x00000000
[  208.693795] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.701160] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  208.709067] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.716701] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.724240] bioset          S c07aaa40     0    19      2 0x00000000
[  208.730900] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.738264] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  208.746171] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.753805] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.761344] kblockd         S c07aaa40     0    20      2 0x00000000
[  208.768003] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.775367] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  208.783274] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.790909] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.798448] ata_sff         S c07aaa40     0    21      2 0x00000000
[  208.805105] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.812470] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  208.820376] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.828011] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.835550] watchdogd       S c07aaa40     0    22      2 0x00000000
[  208.842208] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.849572] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  208.857478] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.865112] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.872652] rpciod          S c07aaa40     0    23      2 0x00000000
[  208.879311] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.886674] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  208.894581] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.902216] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.909755] kswapd0         S c07aaa40     0    24      2 0x00000000
[  208.916409] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.923774] [<c07ab34c>] (schedule) from [<c024aca4>] (kswapd+0x9e4/0xb44)
[  208.930955] [<c024aca4>] (kswapd) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.937864] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.945403] vmstat          S c07aaa40     0    25      2 0x00000000
[  208.952062] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.959426] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  208.967333] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  208.974967] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  208.982506] nfsiod          S c07aaa40     0    26      2 0x00000000
[  208.989164] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  208.996528] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.004435] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.012070] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.019609] bioset          S c07aaa40     0    37      2 0x00000000
[  209.026267] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.033631] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.041537] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.049172] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.056711] bioset          S c07aaa40     0    38      2 0x00000000
[  209.063369] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.070733] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.078640] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.086274] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.093813] bioset          S c07aaa40     0    39      2 0x00000000
[  209.100472] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.107836] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.115743] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.123377] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.130916] bioset          S c07aaa40     0    40      2 0x00000000
[  209.137575] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.144939] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.152846] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.160480] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.168019] bioset          S c07aaa40     0    41      2 0x00000000
[  209.174677] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.182041] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.189948] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.197582] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.205122] bioset          S c07aaa40     0    42      2 0x00000000
[  209.211779] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.219144] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.227051] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.234685] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.242224] bioset          S c07aaa40     0    43      2 0x00000000
[  209.248883] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.256246] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.264153] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.271788] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.279327] bioset          S c07aaa40     0    44      2 0x00000000
[  209.285984] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.293348] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.301255] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.308889] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.316429] bioset          S c07aaa40     0    45      2 0x00000000
[  209.323087] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.330451] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.338358] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.345993] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.353532] bioset          S c07aaa40     0    46      2 0x00000000
[  209.360191] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.367555] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.375461] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.383096] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.390635] bioset          S c07aaa40     0    47      2 0x00000000
[  209.397293] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.404657] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.412564] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.420199] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.427738] bioset          S c07aaa40     0    48      2 0x00000000
[  209.434396] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.441760] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.449667] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.457301] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.464840] bioset          S c07aaa40     0    49      2 0x00000000
[  209.471498] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.478862] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.486768] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.494403] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.501942] bioset          S c07aaa40     0    50      2 0x00000000
[  209.508600] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.515964] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.523871] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.531505] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.539044] bioset          S c07aaa40     0    51      2 0x00000000
[  209.545702] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.553066] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.560974] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.568608] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.576147] bioset          S c07aaa40     0    52      2 0x00000000
[  209.582805] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.590169] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.598076] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.605711] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.613250] bioset          S c07aaa40     0    53      2 0x00000000
[  209.619908] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.627272] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.635179] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.642814] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.650353] bioset          S c07aaa40     0    54      2 0x00000000
[  209.657012] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.664375] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.672282] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.679917] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.687456] bioset          S c07aaa40     0    55      2 0x00000000
[  209.694115] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.701479] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.709386] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.717020] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.724559] bioset          S c07aaa40     0    56      2 0x00000000
[  209.731217] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.738581] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.746488] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.754122] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.761662] bioset          S c07aaa40     0    57      2 0x00000000
[  209.768320] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.775684] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.783590] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.791225] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.798764] bioset          S c07aaa40     0    58      2 0x00000000
[  209.805422] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.812786] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.820693] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.828327] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.835866] bioset          S c07aaa40     0    59      2 0x00000000
[  209.842524] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.849888] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.857795] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.865429] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.872969] bioset          S c07aaa40     0    60      2 0x00000000
[  209.879627] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.886991] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.894898] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.902532] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.910071] kworker/u2:1    S c07aaa40     0    61      2 0x00000000
[  209.916730] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.924094] [<c07ab34c>] (schedule) from [<c01546e8>] (worker_thread+0xa4/0x4d0)
[  209.931819] [<c01546e8>] (worker_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.939363] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.946902] ipv6_addrconf   S c07aaa40     0    63      2 0x00000000
[  209.953560] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.960924] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  209.968831] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  209.976465] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  209.984005] kworker/0:2     S c07aaa40     0    64      2 0x00000000
[  209.990663] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  209.998027] [<c07ab34c>] (schedule) from [<c01546e8>] (worker_thread+0xa4/0x4d0)
[  210.005752] [<c01546e8>] (worker_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.013296] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.020835] deferwq         S c07aaa40     0    65      2 0x00000000
[  210.027493] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.034857] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.042764] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.050398] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.057937] bioset          S c07aaa40     0    66      2 0x00000000
[  210.064595] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.071959] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.079866] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.087500] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.095039] bioset          S c07aaa40     0    67      2 0x00000000
[  210.101697] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.109061] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.116968] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.124602] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.132141] bioset          S c07aaa40     0    68      2 0x00000000
[  210.138799] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.146163] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.154070] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.161704] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.169243] bioset          S c07aaa40     0    69      2 0x00000000
[  210.175902] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.183266] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.191172] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.198807] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.206346] bioset          S c07aaa40     0    70      2 0x00000000
[  210.213004] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.220369] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.228275] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.235910] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.243449] bioset          S c07aaa40     0    71      2 0x00000000
[  210.250107] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.257471] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.265378] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.273012] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.280552] bioset          S c07aaa40     0    72      2 0x00000000
[  210.287210] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.294574] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.302481] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.310115] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.317654] bioset          S c07aaa40     0    73      2 0x00000000
[  210.324313] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.331677] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.339584] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.347218] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.354757] bioset          S c07aaa40     0    74      2 0x00000000
[  210.361416] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.368780] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.376687] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.384322] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.391861] bioset          S c07aaa40     0    75      2 0x00000000
[  210.398520] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.405884] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.413790] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.421425] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.428964] irq/160-44e0b00 S c07aaa40     0    76      2 0x00000000
[  210.435617] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.442990] [<c07ab34c>] (schedule) from [<c019ffc4>] (irq_thread+0xb0/0x200)
[  210.450444] [<c019ffc4>] (irq_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.457716] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.465255] irq/161-4802a00 S c07aaa40     0    77      2 0x00000000
[  210.471910] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.479273] [<c07ab34c>] (schedule) from [<c019ffc4>] (irq_thread+0xb0/0x200)
[  210.486726] [<c019ffc4>] (irq_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.493998] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.501537] irq/33-48060000 S c07aaa40     0    78      2 0x00000000
[  210.508191] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.515554] [<c07ab34c>] (schedule) from [<c019ffc4>] (irq_thread+0xb0/0x200)
[  210.523007] [<c019ffc4>] (irq_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.530279] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.537818] bioset          S c07aaa40     0    79      2 0x00000000
[  210.544477] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.551841] [<c07ab34c>] (schedule) from [<c0154da0>] (rescuer_thread+0x28c/0x300)
[  210.559748] [<c0154da0>] (rescuer_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.567382] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.574922] mmcqd/1         S c07aaa40     0    80      2 0x00000000
[  210.581575] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.588941] [<c07ab34c>] (schedule) from [<c0616eac>] (mmc_queue_thread+0x11c/0x174)
[  210.597030] [<c0616eac>] (mmc_queue_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.604846] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.612385] kworker/0:1H    S c07aaa40     0    81      2 0x00000000
[  210.619044] [<c07aaa40>] (__schedule) from [<c07ab34c>] (schedule+0x44/0x9c)
[  210.626407] [<c07ab34c>] (schedule) from [<c01546e8>] (worker_thread+0xa4/0x4d0)
[  210.634133] [<c01546e8>] (worker_thread) from [<c015a6b4>] (kthread+0xd4/0xf0)
[  210.641676] [<c015a6b4>] (kthread) from [<c01078d0>] (ret_from_fork+0x14/0x24)
[  210.649243] Sched Debug Version: v0.11, 4.7.0 #1
[  210.654064] ktime                                   : 210640.702525
[  210.660606] sched_clk                               : 210649.237069
[  210.667147] cpu_clk                                 : 210649.237403
[  210.673689] jiffies                                 : 4294958083
[  210.679956] 
[  210.681507] sysctl_sched
[  210.684148]   .sysctl_sched_latency                    : 6.000000
[  210.690508]   .sysctl_sched_min_granularity            : 0.750000
[  210.696868]   .sysctl_sched_wakeup_granularity         : 1.000000
[  210.703227]   .sysctl_sched_child_runs_first           : 0
[  210.708951]   .sysctl_sched_features                   : 44859
[  210.715038]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
[  210.721940] 
[  210.723493] cpu#0
[  210.725499]   .nr_running                    : 0
[  210.730316]   .load                          : 0
[  210.735133]   .nr_switches                   : 2637
[  210.740222]   .nr_load_updates               : 770
[  210.745221]   .nr_uninterruptible            : 1
[  210.750039]   .next_balance                  : 4294.937296
[  210.755763]   .curr->pid                     : 0
[  210.760581]   .clock                         : 207629.102789
[  210.766487]   .clock_task                    : 207629.102789
[  210.772392]   .cpu_load[0]                   : 0
[  210.777209]   .cpu_load[1]                   : 0
[  210.782026]   .cpu_load[2]                   : 0
[  210.786843]   .cpu_load[3]                   : 0
[  210.791659]   .cpu_load[4]                   : 0
[  210.796476]   .avg_idle                      : 1000000
[  210.801837]   .max_idle_balance_cost         : 500000
[  210.807541] 
[  210.807541] cfs_rq[0]:/
[  210.811644]   .exec_clock                    : 0.000000
[  210.817129]   .MIN_vruntime                  : 0.000001
[  210.822586]   .min_vruntime                  : 2219.665999
[  210.828311]   .max_vruntime                  : 0.000001
[  210.833764]   .spread                        : 0.000000
[  210.839217]   .spread0                       : 0.000000
[  210.844669]   .nr_spread_over                : 0
[  210.849486]   .nr_running                    : 0
[  210.854302]   .load                          : 0
[  210.859119]   .load_avg                      : 0
[  210.863936]   .runnable_load_avg             : 0
[  210.868753]   .util_avg                      : 0
[  210.873569]   .removed_load_avg              : 0
[  210.878386]   .removed_util_avg              : 0
[  210.883203]   .tg_load_avg_contrib           : 0
[  210.888020]   .tg_load_avg                   : 0
[  210.892836]   .throttled                     : 0
[  210.897653]   .throttle_count                : 0
[  210.902478] 
[  210.902478] rt_rq[0]:/
[  210.906482]   .rt_nr_running                 : 0
[  210.911298]   .rt_throttled                  : 0
[  210.916116]   .rt_time                       : 0.000000
[  210.921569]   .rt_runtime                    : 950.000000
[  210.927203] 
[  210.927203] dl_rq[0]:
[  210.931115]   .dl_nr_running                 : 0
[  210.935932]   .dl_bw->bw                     : 996147
[  210.941203]   .dl_bw->total_bw               : 0
[  210.946022] 
[  210.946022] runnable tasks:
[  210.946022]             task   PID         tree-key  switches  prio     wait-time             sum-exec        sum-sleep
[  210.946022] ----------------------------------------------------------------------------------------------------------
[  210.972885]        swapper/0     1      2156.149123       430   120         0.000000      1585.136238         0.000000 /
[  210.984271]         kthreadd     2      2038.321501        79   120         0.000000        14.037962         0.000000 /
[  210.995650]      ksoftirqd/0     3      2215.763039        52   120         0.000000         2.544000         0.000000 /
[  211.007028]      kworker/0:0     4      1904.921171        13   120         0.000000         1.389583         0.000000 /
[  211.018406]     kworker/0:0H     5      2041.204781         7   100         0.000000         8.077250         0.000000 /
[  211.029784]     kworker/u2:0     6      2217.179165       265   120         0.000000       381.272297         0.000000 /
[  211.041161]        rcu_sched     7      2154.556373        55   120         0.000000        21.241542         0.000000 /
[  211.052539]           rcu_bh     8        16.105444         2   120         0.000000         0.039626         0.000000 /
[  211.063916]      migration/0     9         0.000000         4     0         0.000000         0.423750         0.000000 /
[  211.075293]    lru-add-drain    10        21.168027         2   100         0.000000         0.085249         0.000000 /
[  211.086670]          cpuhp/0    11        23.208855         3   120         0.000000         0.058416         0.000000 /
[  211.098047]        kdevtmpfs    12      1928.760087       161   120         0.000000        26.371584         0.000000 /
[  211.109425]            netns    13        61.744445         2   100         0.000000         1.661750         0.000000 /
[  211.120802]      kworker/0:1    14      2219.665999       410   120         0.000000       247.404410         0.000000 /
[  211.132180]       oom_reaper    15       251.102895         2   120         0.000000         0.323084         0.000000 /
[  211.143558]        writeback    16       256.870256         2   100         0.000000         0.064208         0.000000 /
[  211.154935]       kcompactd0    17       258.964766         2   120         0.000000         0.111833         0.000000 /
[  211.166312]           crypto    18       260.919055         2   100         0.000000         0.062918         0.000000 /
[  211.177689]           bioset    19       262.941979         2   100         0.000000         0.053625         0.000000 /
[  211.189066]          kblockd    20       264.973202         2   100         0.000000         0.069207         0.000000 /
[  211.200443]          ata_sff    21       288.694669         2   100         0.000000         0.130875         0.000000 /
[  211.211820]        watchdogd    22       294.705832         2   100         0.000000         0.098167         0.000000 /
[  211.223197]           rpciod    23       428.119413         2   100         0.000000         0.182249         0.000000 /
[  211.234574]          kswapd0    24       547.316984         3   120         0.000000         0.383958         0.000000 /
[  211.245951]           vmstat    25       445.549286         2   100         0.000000         0.070042         0.000000 /
[  211.257327]           nfsiod    26       447.076801         2   100         0.000000         0.068708         0.000000 /
[  211.268704]           bioset    37      1238.234375         2   100         0.000000         0.071458         0.000000 /
[  211.280081]           bioset    38      1240.257845         2   100         0.000000         0.058250         0.000000 /
[  211.291458]           bioset    39      1242.275639         2   100         0.000000         0.048500         0.000000 /
[  211.302835]           bioset    40      1244.296648         2   100         0.000000         0.049625         0.000000 /
[  211.314212]           bioset    41      1246.314693         2   100         0.000000         0.047916         0.000000 /
[  211.325589]           bioset    42      1248.333430         2   100         0.000000         0.046458         0.000000 /
[  211.336966]           bioset    43      1250.353030         2   100         0.000000         0.048793         0.000000 /
[  211.348342]           bioset    44      1252.372277         2   100         0.000000         0.048999         0.000000 /
[  211.359719]           bioset    45      1254.392090         2   100         0.000000         0.047709         0.000000 /
[  211.371096]           bioset    46      1256.412263         2   100         0.000000         0.047791         0.000000 /
[  211.382473]           bioset    47      1258.433322         2   100         0.000000         0.051001         0.000000 /
[  211.393850]           bioset    48      1260.452184         2   100         0.000000         0.049375         0.000000 /
[  211.405227]           bioset    49      1262.471106         2   100         0.000000         0.047375         0.000000 /
[  211.416603]           bioset    50      1264.491916         2   100         0.000000         0.046917         0.000000 /
[  211.427980]           bioset    51      1266.512992         2   100         0.000000         0.051041         0.000000 /
[  211.439356]           bioset    52      1268.547806         2   100         0.000000         0.072042         0.000000 /
[  211.450734]           bioset    53      1300.699923         2   100         0.000000         0.073208         0.000000 /
[  211.462111]           bioset    54      1302.717044         2   100         0.000000         0.056417         0.000000 /
[  211.473487]           bioset    55      1304.740238         2   100         0.000000         0.063041         0.000000 /
[  211.484864]           bioset    56      1307.786364         2   100         0.000000         0.067750         0.000000 /
[  211.496241]           bioset    57      1309.803349         2   100         0.000000         0.055708         0.000000 /
[  211.507618]           bioset    58      1311.825130         2   100         0.000000         0.056334         0.000000 /
[  211.518995]           bioset    59      1313.847701         2   100         0.000000         0.060875         0.000000 /
[  211.530371]           bioset    60      1315.883544         2   100         0.000000         0.073334         0.000000 /
[  211.541749]     kworker/u2:1    61      1764.180582         3   120         0.000000         0.166875         0.000000 /
[  211.553126]    ipv6_addrconf    63      1437.655997         2   100         0.000000         0.164501         0.000000 /
[  211.564504]      kworker/0:2    64      1981.529376         7   120         0.000000         8.763625         0.000000 /
[  211.575881]          deferwq    65      1508.836081         2   100         0.000000         0.130291         0.000000 /
[  211.587258]           bioset    66      1581.328288         2   100         0.000000         0.097625         0.000000 /
[  211.598636]           bioset    67      1592.245439         2   100         0.000000         0.076042         0.000000 /
[  211.610012]           bioset    68      1602.178951         2   100         0.000000         0.074792         0.000000 /
[  211.621389]           bioset    69      1612.120004         2   100         0.000000         0.075666         0.000000 /
[  211.632766]           bioset    70      1622.244925         2   100         0.000000         0.078291         0.000000 /
[  211.644142]           bioset    71      1631.857791         2   100         0.000000         0.073042         0.000000 /
[  211.655519]           bioset    72      1641.419973         2   100         0.000000         0.073667         0.000000 /
[  211.666896]           bioset    73      1651.738637         2   100         0.000000         0.061791         0.000000 /
[  211.678273]           bioset    74      1664.070092         2   100         0.000000         0.073001         0.000000 /
[  211.689651]           bioset    75      1767.096034         2   100         0.000000         0.067125         0.000000 /
[  211.701027]  irq/160-44e0b00    76         0.000000       274    49         0.000000        13.390751         0.000000 /
[  211.712404]  irq/161-4802a00    77         0.000000         2    49         0.000000         0.099084         0.000000 /
[  211.723780]  irq/33-48060000    78         0.000000         2    49         0.000000         0.243458         0.000000 /
[  211.735156]           bioset    79      1910.880292         2   100         0.000000         0.076584         0.000000 /
[  211.746533]          mmcqd/1    80      1924.364590         4   120         0.000000         1.093001         0.000000 /
[  211.757910]     kworker/0:1H    81      2156.095694         9   100         0.000000         4.953916         0.000000 /
[  211.769289] 
[  211.770844] 
[  211.770844] Showing all locks held in the system:
[  211.777327] 
[  211.778879] =============================================
[  211.778879] 
[  211.786060] Showing busy workqueues and worker pools:


- 20:54:05 [INFO] [  218.145014] sysrq: SysRq : Show backtrace of all active CPUs
[  218.150957] Sending NMI to all CPUs:
[  218.154693] NMI backtrace for cpu 0
[  218.158341] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.7.0 #1
[  218.164430] Hardware name: Generic AM33XX (Flattened Device Tree)
[  218.170823] [<c011005c>] (unwind_backtrace) from [<c010c250>] (show_stack+0x10/0x14)
[  218.178926] [<c010c250>] (show_stack) from [<c047f49c>] (dump_stack+0xb0/0xe4)
[  218.186478] [<c047f49c>] (dump_stack) from [<c0482eb8>] (nmi_cpu_backtrace+0x7c/0x88)
[  218.194658] [<c0482eb8>] (nmi_cpu_backtrace) from [<c010dbf8>] (raise_nmi+0x60/0x70)
[  218.202746] [<c010dbf8>] (raise_nmi) from [<c0482f84>] (nmi_trigger_all_cpu_backtrace+0xc0/0xf4)
[  218.211933] [<c0482f84>] (nmi_trigger_all_cpu_backtrace) from [<c04f9424>] (__handle_sysrq+0xd4/0x248)
[  218.221662] [<c04f9424>] (__handle_sysrq) from [<c05147c8>] (serial_omap_irq+0x374/0x3bc)
[  218.230213] [<c05147c8>] (serial_omap_irq) from [<c019ea30>] (handle_irq_event_percpu+0x44/0x3fc)
[  218.239482] [<c019ea30>] (handle_irq_event_percpu) from [<c019ee20>] (handle_irq_event+0x38/0x5c)
[  218.248754] [<c019ee20>] (handle_irq_event) from [<c01a1f14>] (handle_level_irq+0xb8/0x14c)
[  218.257478] [<c01a1f14>] (handle_level_irq) from [<c019e05c>] (generic_handle_irq+0x20/0x34)
[  218.266293] [<c019e05c>] (generic_handle_irq) from [<c019e350>] (__handle_domain_irq+0x64/0xe0)
[  218.275382] [<c019e350>] (__handle_domain_irq) from [<c07b06b8>] (__irq_svc+0x58/0x78)
[  218.283661] [<c07b06b8>] (__irq_svc) from [<c010831c>] (arch_cpu_idle+0x20/0x3c)
[  218.291389] [<c010831c>] (arch_cpu_idle) from [<c01844d8>] (cpu_startup_entry+0x30c/0x3f0)
[  218.300034] [<c01844d8>] (cpu_startup_entry) from [<c0b00c08>] (start_kernel+0x340/0x3b4)
[  218.308579] [<c0b00c08>] (start_kernel) from [<8000807c>] (0x8000807c)
[  218.315407] Unable to handle kernel NULL pointer dereference at virtual address 00000000
[  218.323853] pgd = c0004000
[  218.326675] [00000000] *pgd=00000000
[  218.330423] Internal error: Oops: 80000005 [#1] SMP ARM
[  218.335880] Modules linked in:
[  218.339074] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.7.0 #1
[  218.345162] Hardware name: Generic AM33XX (Flattened Device Tree)
[  218.351523] task: c0c065c0 ti: c0c00000 task.ti: c0c00000
[  218.357157] PC is at 0x0
[  218.359802] LR is at nmi_trigger_all_cpu_backtrace+0xc0/0xf4
[  218.365709] pc : [<00000000>]    lr : [<c0482f84>]    psr: 60000193
[  218.365709] sp : c0c01e68  ip : 00000000  fp : c0c029cc
[  218.377694] r10: 00000061  r9 : 00000000  r8 : 00000007
[  218.383146] r7 : 00000000  r6 : c010db98  r5 : c0c037f8  r4 : 00000001
[  218.389960] r3 : 00000000  r2 : 00000000  r1 : 00000007  r0 : c0c037f8
[  218.396776] Flags: nZCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment none
[  218.404315] Control: 10c5387d  Table: 80004019  DAC: 00000051
[  218.410312] Process swapper/0 (pid: 0, stack limit = 0xc0c00218)
[  218.416582] Stack: (0xc0c01e68 to 0xc0c02000)
[  218.421134] 1e60:                   c0c87680 c0c4456c 0000006c 00000001 00000007 c04f9424
[  218.429675] 1e80: 00000000 00000000 c04f9350 c052eb88 eebae810 00000101 00000000 00000002
[  218.438217] 1ea0: 00000005 c05147c8 00000000 60000193 ee95c510 eee72b40 ee95c560 ee95c510
[  218.446757] 1ec0: 00000000 0000009e 00000000 00000000 c0c029cc c019ea30 60000193 00000000
[  218.455298] 1ee0: 60000193 ee95c500 ee95c560 ee95c500 ee95c560 ee95c510 00000000 00000001
[  218.463839] 1f00: ee814000 c0b759f8 c0cbcc26 c019ee20 ee95c500 ee95c560 ee95c510 c01a1f14
[  218.472381] 1f20: c0b74944 0000009e c0c035fc c019e05c c0b74944 c019e350 c010831c 20000013
[  218.480921] 1f40: ffffffff c0c01f8c c0c029cc c0cbde98 c0b759f8 c07b06b8 00000001 00000001
[  218.489462] 1f60: 00000000 c0c065c0 c0c02a38 00000000 00000000 c0cbde98 c0c029cc c0cbde98
[  218.498004] 1f80: c0b759f8 c0cbcc26 00000000 c0c01fa8 c018ff64 c010831c 20000013 ffffffff
[  218.506545] 1fa0: 00000051 c0108318 c0c02a38 c01844d8 c0cc2050 c0c02900 00000000 c0b00c08
[  218.515086] 1fc0: ffffffff ffffffff 00000000 c0b00684 00000000 c0b52a48 c0cc2214 c0c029ac
[  218.523627] 1fe0: c0b52a44 c0c08228 80004059 413fc082 00000000 8000807c 00000000 00000000
[  218.532170] [<c0482f84>] (nmi_trigger_all_cpu_backtrace) from [<c04f9424>] (__handle_sysrq+0xd4/0x248)
[  218.541892] [<c04f9424>] (__handle_sysrq) from [<c05147c8>] (serial_omap_irq+0x374/0x3bc)
[  218.550436] [<c05147c8>] (serial_omap_irq) from [<c019ea30>] (handle_irq_event_percpu+0x44/0x3fc)
[  218.559703] [<c019ea30>] (handle_irq_event_percpu) from [<c019ee20>] (handle_irq_event+0x38/0x5c)
[  218.568971] [<c019ee20>] (handle_irq_event) from [<c01a1f14>] (handle_level_irq+0xb8/0x14c)
[  218.577694] [<c01a1f14>] (handle_level_irq) from [<c019e05c>] (generic_handle_irq+0x20/0x34)
[  218.586508] [<c019e05c>] (generic_handle_irq) from [<c019e350>] (__handle_domain_irq+0x64/0xe0)
[  218.595594] [<c019e350>] (__handle_domain_irq) from [<c07b06b8>] (__irq_svc+0x58/0x78)
[  218.603865] [<c07b06b8>] (__irq_svc) from [<c010831c>] (arch_cpu_idle+0x20/0x3c)
[  218.611590] [<c010831c>] (arch_cpu_idle) from [<c01844d8>] (cpu_startup_entry+0x30c/0x3f0)
[  218.620224] [<c01844d8>] (cpu_startup_entry) from [<c0b00c08>] (start_kernel+0x340/0x3b4)
[  218.628765] [<c0b00c08>] (start_kernel) from [<8000807c>] (0x8000807c)
[  218.635581] Code: bad PC value
[  218.638788] ---[ end trace 99ddf7059abf1fd2 ]---
[  218.643609] Kernel panic - not syncing: Fatal exception in interrupt
[  218.650256] ---[ end Kernel panic - not syncing: Fatal exception in interrupt

- 20:54:16 [INFO] 
- 20:54:16 [INFO] Disconnected serial from am335x-evm
- 20:54:16 [INFO] Failed to boot on Iteration 61
- 20:54:16 [INFO] Disconnected all from am335x-evm
- 20:54:17 [INFO] Connected to am335x-evm via serial 
- 20:54:17 [INFO] Host: #check prompt
- 20:54:20 [ERROR] On command: #check prompt waiting for #check prompt.+?(?-mix:((?-mix:login:)|[Pp]assword)) >>> error: execution expired
- 20:54:20 [INFO] Target: 

- 20:54:20 [INFO] Host: #check prompt
- 20:54:22 [ERROR] On command: #check prompt waiting for #check prompt.+?(?-mix:[\w\d]+@.+[@:#]+) >>> error: execution expired
- 20:54:22 [INFO] Target: 

- 20:54:22 [INFO] Host: #check prompt
- 20:54:24 [ERROR] On command: #check prompt waiting for #check prompt.+?(?-mix:[\w\d]+@.+[@:#]+) >>> error: execution expired
- 20:54:24 [INFO] Target: 

- 20:54:24 [INFO] Host: #check prompt
- 20:54:26 [ERROR] On command: #check prompt waiting for #check prompt.+?(?-mix:[\w\d]+@.+[@:#]+) >>> error: execution expired
- 20:54:26 [INFO] Target: 

- 20:54:26 [INFO] Disconnected serial from am335x-evm
- 20:54:27 [INFO] Connected to am335x-evm via serial 
- 20:54:27 [INFO] Host: 
- 20:54:28 [INFO] Target: 
-- 
