From: Emil Goode <emil.fsw@goode.io>
Subject: Re: wlcore: Fix regression in wlcore_set_partition()
Date: Thu, 25 Feb 2016 01:11:46 +0100
Message-ID: <20160225001146.GA1839@lianli>
References: <20160210012216.GA18819@lianli>
 <20160212094526.EC572611CE@smtp.codeaurora.org>
 <CANfgCY02_AkRi2EMNZsneK8UdwLvAWxF_X0ts6WZbaM0=5c63A@mail.gmail.com>
 <87bn7gu19c.fsf@kamboji.qca.qualcomm.com>
 <CANfgCY0zHtE8Z8knNPsTgnZS-fumdeioU45F1E2KtvpLBckQDg@mail.gmail.com>
 <CANfgCY04juY=xaJ88UN9NE+T9Xne+AEczitjj7vrLxtG_eb+AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@codeaurora.org>, Shahar Patury <shaharp@ti.com>,
	Guy Mishol <guym@ti.com>,
	Igor Grinberg <grinberg@compulab.co.il>,
	Uri Mashiach <uri.mashiach@compulab.co.il>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Ross Green <rgkernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANfgCY04juY=xaJ88UN9NE+T9Xne+AEczitjj7vrLxtG_eb+AA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello Ross

On Wed, Feb 24, 2016 at 04:40:50PM +1100, Ross Green wrote:
> On Wed, Feb 17, 2016 at 4:34 PM, Ross Green <rgkernel@gmail.com> wrote:
> > Appreciate your efforts!
> >
> > Just trying to make sure it does not get lost.
> > Introduced in rc1, not fixed by ... rc4.
> >
> > Anyway, I will continue to test, lots of other things still to chase
> > even in rc4!
> >
> > Regards,
> >
> > Ross Green
> >
> > On Wed, Feb 17, 2016 at 2:24 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
> >> Ross Green <rgkernel@gmail.com> writes:
> >>
> >>> On Fri, Feb 12, 2016 at 8:45 PM, Kalle Valo <kvalo@codeaurora.org> wrote:
> >>>>
> >>>>> The commit 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio") introduced a
> >>>>> regression causing the wlcore to time out and go into recovery. Reverting the
> >>>>> changes regarding write of the last partition size brings the module back to
> >>>>> it's functional state.
> >>>>>
> >>>>> Fixes: 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio")
> >>>>> Reported-by: Ross Green <rgkernel@gmail.com>
> >>>>> Signed-off-by: Emil Goode <emil.fsw@goode.io>
> >>>>> [kvalo@codeaurora.org: improved commit log]
> >>>>
> >>>> Thanks, applied to wireless-drivers.git.
> >>>>
> >>>> Kalle Valo
> >>>
> >>> I just tested linux-4.5-rc4 it appears the above fix missed the release for rc4!
> >>> So the behaviour of firmware reset being called after the access of
> >>> the last partition timesout.
> >>>
> >>> Again tested patch with the new release - 4.5-rc4 and found everything
> >>> to work as expected again.
> >>>
> >>> So Hopefully for rc5 - Please!
> >>
> >> It takes some time to get patches into Linus' tree. And being in a
> >> conference and then getting sick is not really helping. I'm not sure if
> >> this patch makes to rc5 on time, but I'll try.
> >>
> >> --
> >> Kalle Valo
> 
> G'day all,
> 
> I have tested Emil's patch with each 4.5-rc release.
> 
> Seems to work fine with rc2, rc3, rc4.
> I tried it with rc5 and get the following output from dmesg see attachment.
> 
> So it looks like there is a reset that it recovers from and then proceeds OK.
> 
> I see the patch has been queued by David Miller so it might make it into rc6.
> That will be great. It still does not look quite as clean as it should
> be however, given the noise in the dmesg output from rc5
> 
> Regards,
> 
> 
> Ross Green

I'm unable to reproduce that ELP wakeup timeout with v4.5-rc5 on my pandaboard es.
Can you easily reproduce it and are you able to reproduce it with commit 3719c17e1816 reverted?

However, I'm seeing another bug that occurs when the wlan is not configured to connect to
an AP directly after boot (dmesg attached). It is not related to any recent changes and goes back
before the 3.14 kernel. There seem to be an issue with the looped IRQ handling implementation.
A scan on 2GHZ is performed and the wlcore_fw_status() call in wlcore_irq_locked() returns
WL1271_ACX_INTR_HW_AVAILABLE, then nothing seem to happen until the delayed work queue
scan_complete_work starts executing after the 30 sec timeout runs out and the wlcore goes into
recovery. I guess a new scan should be initiated after wlcore_fw_status() return hw available,
does anyone have input on that?

Best regards,

Emil Goode

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="dmesg_v4.5-rc5_wl1271"
Content-Transfer-Encoding: 8bit

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 4.5.0-rc5-armv7-x1-00001-gffdb57e (emil@lianli) (gcc version 4.9.3 20141031 (prerelease) (Linaro GCC 2014.11) ) #23 SMP Wed Feb 24 20:36:15 CET 2016
[    0.000000] CPU: ARMv7 Processor [412fc09a] revision 10 (ARMv7), cr=10c5387d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
[    0.000000] Machine model: TI OMAP4 PandaBoard-ES
[    0.000000] cma: Reserved 16 MiB at 0xbe800000
[    0.000000] Memory policy: Data cache writealloc
[    0.000000] OMAP4: Map 0xbfe00000 to fe600000 for dram barrier
[    0.000000] On node 0 totalpages: 261632
[    0.000000] free_area_init_node: node 0, pgdat c0cbab40, node_mem_map ef6f9000
[    0.000000]   Normal zone: 1728 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 196608 pages, LIFO batch:31
[    0.000000]   HighMem zone: 65024 pages, LIFO batch:15
[    0.000000] OMAP4460 ES1.1
[    0.000000] PERCPU: Embedded 14 pages/cpu @ef696000 s24832 r8192 d24320 u57344
[    0.000000] pcpu-alloc: s24832 r8192 d24320 u57344 alloc=14*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 259904
[    0.000000] Kernel command line: console=ttyO2,115200n8 root=/dev/mmcblk0p5 ro rootfstype=ext4 rootwait quiet
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Memory: 999440K/1046528K available (7346K kernel code, 810K rwdata, 2404K rodata, 1024K init, 8123K bss, 30704K reserved, 16384K cma-reserved, 243712K highmem)
[    0.000000] Virtual kernel memory layout:
    vector  : 0xffff0000 - 0xffff1000   (   4 kB)
    fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
    vmalloc : 0xf0800000 - 0xff800000   ( 240 MB)
    lowmem  : 0xc0000000 - 0xf0000000   ( 768 MB)
    pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
    modules : 0xbf000000 - 0xbfe00000   (  14 MB)
      .text : 0xc0008000 - 0xc0a85b08   (10743 kB)
      .init : 0xc0b00000 - 0xc0c00000   (1024 kB)
      .data : 0xc0c00000 - 0xc0cca874   ( 811 kB)
       .bss : 0xc0ccd000 - 0xc14bbfe0   (8124 kB)
[    0.000000] Running RCU self tests
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU lockdep checking is enabled.
[    0.000000] 	Build-time adjustment of leaf fanout to 32.
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] L2C: platform modifies aux control register: 0x0e070000 -> 0x3e470000
[    0.000000] L2C: DT/platform modifies aux control register: 0x0e070000 -> 0x3e470000
[    0.000000] L2C-310 enabling early BRESP for Cortex-A9
[    0.000000] OMAP L2C310: ROM does not support power control setting
[    0.000000] L2C-310 dynamic clock gating disabled, standby mode disabled
[    0.000000] L2C-310 cache controller enabled, 16 ways, 1024 kB
[    0.000000] L2C-310: CACHE_ID 0x410000c7, AUX_CTRL 0x4e470000
[    0.000000] ti_dt_clocks_register: failed to lookup clock node dss_fck
[    0.000000] ti_dt_clocks_register: failed to lookup clock node dss_fck
[    0.000000] ti_dt_clocks_register: failed to lookup clock node bandgap_fclk
[    0.000000] OMAP clockevent source: timer1 at 32768 Hz
[    0.000000] clocksource: 32k_counter: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 58327039986419 ns
[    0.000000] sched_clock: 32 bits at 32kHz, resolution 30517ns, wraps every 65535999984741ns
[    0.000000] OMAP clocksource: 32k_counter at 32768 Hz
[    0.001373] Console: colour dummy device 80x30
[    0.001434] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.001434] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.001464] ... MAX_LOCK_DEPTH:          48
[    0.001464] ... MAX_LOCKDEP_KEYS:        8191
[    0.001464] ... CLASSHASH_SIZE:          4096
[    0.001464] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.001495] ... MAX_LOCKDEP_CHAINS:      65536
[    0.001495] ... CHAINHASH_SIZE:          32768
[    0.001495]  memory used by lock dependency info: 5167 kB
[    0.001495]  per task-struct memory footprint: 1536 bytes
[    0.001525] Calibrating delay loop... 1397.55 BogoMIPS (lpj=6987776)
[    0.079437] pid_max: default: 32768 minimum: 301
[    0.079895] Security Framework initialized
[    0.080047] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.080078] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.083679] CPU: Testing write buffer coherency: ok
[    0.085357] CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
[    0.085449] Setting up static identity map for 0x80100000 - 0x80100070
[    0.179412] CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
[    0.180053] Brought up 2 CPUs
[    0.180053] SMP: Total of 2 processors activated (2795.11 BogoMIPS).
[    0.180084] CPU: All CPU(s) started in SVC mode.
[    0.183349] devtmpfs: initialized
[    0.240203] VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev 4
[    0.241119] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
[    0.243041] pinctrl core: initialized pinctrl subsystem
[    0.248199] NET: Registered protocol family 16
[    0.253479] DMA: preallocated 256 KiB pool for atomic coherent allocations
[    0.258422] omap_hwmod: l3_main_3 using broken dt data from ocp
[    0.263183] omap_hwmod: l3_main_2 using broken dt data from ocp
[    0.469573] cpuidle: using governor menu
[    0.483856] gpiochip_add_data: registered GPIOs 0 to 31 on device: gpio
[    0.485168] OMAP GPIO hardware version 0.1
[    0.486450] gpiochip_add_data: registered GPIOs 32 to 63 on device: gpio
[    0.488739] gpiochip_add_data: registered GPIOs 64 to 95 on device: gpio
[    0.491058] gpiochip_add_data: registered GPIOs 96 to 127 on device: gpio
[    0.493255] gpiochip_add_data: registered GPIOs 128 to 159 on device: gpio
[    0.495422] gpiochip_add_data: registered GPIOs 160 to 191 on device: gpio
[    0.497344] omap-gpmc 50000000.gpmc: GPMC revision 6.0
[    0.497497] gpmc_mem_init: disabling cs 0 mapped at 0x0-0x1000000
[    0.498565] irq: no irq domain found for /ocp/l4@4a000000/scm@100000/pinmux@40 !
[    0.499206] irq: no irq domain found for /ocp/l4@4a000000/scm@100000/pinmux@40 !
[    0.499908] irq: no irq domain found for /ocp/l4@4a000000/scm@100000/pinmux@40 !
[    0.522094] platform 4b501000.aes: Cannot lookup hwmod 'aes'
[    0.522644] platform 480a5000.des: Cannot lookup hwmod 'des'
[    0.532501] No ATAGs?
[    0.532592] hw-breakpoint: found 5 (+1 reserved) breakpoint and 1 watchpoint registers.
[    0.532623] hw-breakpoint: maximum watchpoint size is 4 bytes.
[    0.534942] OMAP DMA hardware revision 0.0
[    0.595001] omap-dma-engine 4a056000.dma-controller: OMAP DMA engine driver
[    0.596771] of_get_named_gpiod_flags: parsed 'gpio' property of node '/hsusb1_power_reg[0]' - status (0)
[    0.669830] reg-fixed-voltage wl12xx_vmmc: could not find pctldev for node /ocp/l4@4a000000/scm@100000/pinmux@40/pinmux_wl12xx_gpio, deferring probe
[    0.674224] SCSI subsystem initialized
[    0.674713] libata version 3.00 loaded.
[    0.675445] usb_phy_generic hsusb1_phy: GPIO lookup for consumer reset
[    0.675476] usb_phy_generic hsusb1_phy: using device tree for GPIO lookup
[    0.675537] of_get_named_gpiod_flags: parsed 'reset-gpios' property of node '/hsusb1_phy[0]' - status (0)
[    0.675598] no flags found for reset
[    0.675628] usb_phy_generic hsusb1_phy: GPIO lookup for consumer vbus-detect
[    0.675628] usb_phy_generic hsusb1_phy: using device tree for GPIO lookup
[    0.675659] of_get_named_gpiod_flags: can't parse 'vbus-detect-gpios' property of node '/hsusb1_phy[0]'
[    0.675659] of_get_named_gpiod_flags: can't parse 'vbus-detect-gpio' property of node '/hsusb1_phy[0]'
[    0.675689] usb_phy_generic hsusb1_phy: using lookup tables for GPIO lookup
[    0.675811] usb_phy_generic hsusb1_phy: lookup for GPIO vbus-detect failed
[    0.676910] omap_i2c 48070000.i2c: could not find pctldev for node /ocp/l4@4a000000/scm@100000/pinmux@40/pinmux_i2c1_pins, deferring probe
[    0.677001] omap_i2c 48072000.i2c: could not find pctldev for node /ocp/l4@4a000000/scm@100000/pinmux@40/pinmux_i2c2_pins, deferring probe
[    0.677093] omap_i2c 48060000.i2c: could not find pctldev for node /ocp/l4@4a000000/scm@100000/pinmux@40/pinmux_i2c3_pins, deferring probe
[    0.677185] omap_i2c 48350000.i2c: could not find pctldev for node /ocp/l4@4a000000/scm@100000/pinmux@40/pinmux_i2c4_pins, deferring probe
[    0.677581] pps_core: LinuxPPS API ver. 1 registered
[    0.677612] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.677642] PTP clock support registered
[    0.681610] clocksource: Switched to clocksource 32k_counter
[    0.791687] VFS: Disk quotas dquot_6.6.0
[    0.791870] VFS: Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    0.825286] NET: Registered protocol family 2
[    0.827362] TCP established hash table entries: 8192 (order: 3, 32768 bytes)
[    0.827545] TCP bind hash table entries: 8192 (order: 6, 294912 bytes)
[    0.829925] TCP: Hash tables configured (established 8192 bind 8192)
[    0.830230] UDP hash table entries: 512 (order: 3, 40960 bytes)
[    0.830566] UDP-Lite hash table entries: 512 (order: 3, 40960 bytes)
[    0.831726] NET: Registered protocol family 1
[    0.833190] RPC: Registered named UNIX socket transport module.
[    0.833221] RPC: Registered udp transport module.
[    0.833221] RPC: Registered tcp transport module.
[    0.833221] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.838531] hw perfevents: enabled with armv7_cortex_a9 PMU driver, 7 counters available
[    0.844146] futex hash table entries: 512 (order: 3, 32768 bytes)
[    0.844451] audit: initializing netlink subsys (disabled)
[    0.844665] audit: type=2000 audit(0.830:1): initialized
[    0.851715] NFS: Registering the id_resolver key type
[    0.852111] Key type id_resolver registered
[    0.852111] Key type id_legacy registered
[    0.852325] jffs2: version 2.2. (NAND) (SUMMARY)  © 2001-2006 Red Hat, Inc.
[    0.857574] bounce: pool size: 64 pages
[    0.857696] io scheduler noop registered
[    0.857727] io scheduler deadline registered
[    0.857757] io scheduler cfq registered (default)
[    0.861755] pinctrl-single 4a100040.pinmux: 203 pins at pa fc100040 size 406
[    0.862274] pinctrl-single 4a31e040.pinmux: 28 pins at pa fc31e040 size 56
[    0.869232] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.875091] omap_uart 4806a000.serial: no wakeirq for uart0
[    0.875122] of_get_named_gpiod_flags: can't parse 'rts-gpio' property of node '/ocp/serial@4806a000[0]'
[    0.875579] 4806a000.serial: ttyO0 at MMIO 0x4806a000 (irq = 226, base_baud = 3000000) is a OMAP UART0
[    0.877319] of_get_named_gpiod_flags: can't parse 'rts-gpio' property of node '/ocp/serial@4806c000[0]'
[    0.877593] 4806c000.serial: ttyO1 at MMIO 0x4806c000 (irq = 227, base_baud = 3000000) is a OMAP UART1
[    0.878723] of_get_named_gpiod_flags: can't parse 'rts-gpio' property of node '/ocp/serial@48020000[0]'
[    0.878997] 48020000.serial: ttyO2 at MMIO 0x48020000 (irq = 228, base_baud = 3000000) is a OMAP UART2
[    0.892547] console [ttyO2] enabled
[    0.893859] of_get_named_gpiod_flags: can't parse 'rts-gpio' property of node '/ocp/serial@4806e000[0]'
[    0.894134] 4806e000.serial: ttyO3 at MMIO 0x4806e000 (irq = 229, base_baud = 3000000) is a OMAP UART3
[    0.927947] brd: module loaded
[    0.948852] loop: module loaded
[    0.951965] mtdoops: mtd device (mtddev=name/number) must be supplied
[    0.972167] mousedev: PS/2 mouse device common for all mice
[    0.972198] i2c /dev entries driver
[    0.973693] omap_hsmmc 4809c000.mmc: GPIO lookup for consumer cd
[    0.973724] omap_hsmmc 4809c000.mmc: using device tree for GPIO lookup
[    0.973724] of_get_named_gpiod_flags: can't parse 'cd-gpios' property of node '/ocp/mmc@4809c000[0]'
[    0.973754] of_get_named_gpiod_flags: can't parse 'cd-gpio' property of node '/ocp/mmc@4809c000[0]'
[    0.973754] omap_hsmmc 4809c000.mmc: using lookup tables for GPIO lookup
[    0.973785] omap_hsmmc 4809c000.mmc: lookup for GPIO cd failed
[    0.973785] omap_hsmmc 4809c000.mmc: GPIO lookup for consumer wp
[    0.973815] omap_hsmmc 4809c000.mmc: using device tree for GPIO lookup
[    0.973815] of_get_named_gpiod_flags: can't parse 'wp-gpios' property of node '/ocp/mmc@4809c000[0]'
[    0.973846] of_get_named_gpiod_flags: can't parse 'wp-gpio' property of node '/ocp/mmc@4809c000[0]'
[    0.973846] omap_hsmmc 4809c000.mmc: using lookup tables for GPIO lookup
[    0.973876] omap_hsmmc 4809c000.mmc: lookup for GPIO wp failed
[    1.003784] omap_hsmmc 480d5000.mmc: GPIO lookup for consumer wp
[    1.003814] omap_hsmmc 480d5000.mmc: using device tree for GPIO lookup
[    1.003814] of_get_named_gpiod_flags: can't parse 'wp-gpios' property of node '/ocp/mmc@480d5000[0]'
[    1.003845] of_get_named_gpiod_flags: can't parse 'wp-gpio' property of node '/ocp/mmc@480d5000[0]'
[    1.003845] omap_hsmmc 480d5000.mmc: using lookup tables for GPIO lookup
[    1.003875] omap_hsmmc 480d5000.mmc: lookup for GPIO wp failed
[    1.032287] ledtrig-cpu: registered to indicate activity on CPUs
[    1.033538] oprofile: using arm/armv7-ca9
[    1.034271] Initializing XFRM netlink socket
[    1.034698] NET: Registered protocol family 10
[    1.037139] sit: IPv6 over IPv4 tunneling driver
[    1.039337] NET: Registered protocol family 17
[    1.039459] NET: Registered protocol family 15
[    1.039825] Key type dns_resolver registered
[    1.040069] twl: not initialized
[    1.043487] twl6030_uv_to_vsel:OUT OF RANGE! non mapped vsel for 1375000 Vs max 1316660
[    1.051879] twl6030_uv_to_vsel:OUT OF RANGE! non mapped vsel for 1375000 Vs max 1316660
[    1.060272] twl6030_uv_to_vsel:OUT OF RANGE! non mapped vsel for 1375000 Vs max 1316660
[    1.068695] twl6030_uv_to_vsel:OUT OF RANGE! non mapped vsel for 1375000 Vs max 1316660
[    1.077087] twl6030_uv_to_vsel:OUT OF RANGE! non mapped vsel for 1375000 Vs max 1316660
[    1.085479] twl6030_uv_to_vsel:OUT OF RANGE! non mapped vsel for 1375000 Vs max 1316660
[    1.093872] twl6030_uv_to_vsel:OUT OF RANGE! non mapped vsel for 1410000 Vs max 1316660
[    1.102294] omap2_set_init_voltage: unable to find boot up OPP for vdd_mpu
[    1.109497] omap2_set_init_voltage: unable to set vdd_mpu
[    1.115173] omap2_set_init_voltage: unable to find boot up OPP for vdd_core
[    1.122497] omap2_set_init_voltage: unable to set vdd_core
[    1.128234] omap2_set_init_voltage: unable to find boot up OPP for vdd_iva
[    1.135437] omap2_set_init_voltage: unable to set vdd_iva
[    1.143280] Power Management for TI OMAP4+ devices.
[    1.143280] OMAP4 PM: u-boot >= v2012.07 is required for full PM support
[    1.143585] ThumbEE CPU extension supported.
[    1.144744] Registering SWP/SWPB emulation handler
[    1.144744] SmartReflex Class3 initialized
[    1.150482] of_get_named_gpiod_flags: parsed 'gpio' property of node '/wl12xx_vmmc[0]' - status (0)
[    1.159118] Skipping twl internal clock init and using bootloader value (unknown osc rate)
[    1.172943] hw-breakpoint: Failed to enable monitor mode on CPU 0.
[    1.173767] hw-breakpoint: CPU 0 failed to disable vector catch
[    1.173919] twl 0-0048: PIH (irq 340) nested IRQs
[    1.201599] twl6040 0-004b: clk32k is not handled
[    1.205047] of_get_named_gpiod_flags: parsed 'ti,audpwron-gpio' property of node '/ocp/i2c@48070000/twl@4b[0]' - status (0)
[    1.207366] omap_i2c 48070000.i2c: bus 0 rev0.11 at 400 kHz
[    1.210357] omap_i2c 48072000.i2c: bus 1 rev0.11 at 400 kHz
[    1.212463] omap_i2c 48060000.i2c: bus 2 rev0.11 at 100 kHz
[    1.215057] omap_i2c 48350000.i2c: bus 3 rev0.11 at 400 kHz
[    1.215057] omap_hsmmc 4809c000.mmc: GPIO lookup for consumer cd
[    1.215698] omap_hsmmc 4809c000.mmc: using device tree for GPIO lookup
[    1.215698] of_get_named_gpiod_flags: can't parse 'cd-gpios' property of node '/ocp/mmc@4809c000[0]'
[    1.215728] of_get_named_gpiod_flags: can't parse 'cd-gpio' property of node '/ocp/mmc@4809c000[0]'
[    1.215728] omap_hsmmc 4809c000.mmc: using lookup tables for GPIO lookup
[    1.215759] omap_hsmmc 4809c000.mmc: lookup for GPIO cd failed
[    1.215820] omap_hsmmc 4809c000.mmc: GPIO lookup for consumer wp
[    1.215820] omap_hsmmc 4809c000.mmc: using device tree for GPIO lookup
[    1.215850] of_get_named_gpiod_flags: can't parse 'wp-gpios' property of node '/ocp/mmc@4809c000[0]'
[    1.215850] of_get_named_gpiod_flags: can't parse 'wp-gpio' property of node '/ocp/mmc@4809c000[0]'
[    1.215881] omap_hsmmc 4809c000.mmc: using lookup tables for GPIO lookup
[    1.215881] omap_hsmmc 4809c000.mmc: lookup for GPIO wp failed
[    1.216186] omap_hsmmc 4809c000.mmc: omap_device: omap_device_enable() called from invalid state 1
[    1.282104] omap_hsmmc 480d5000.mmc: GPIO lookup for consumer wp
[    1.282104] omap_hsmmc 480d5000.mmc: using device tree for GPIO lookup
[    1.282165] of_get_named_gpiod_flags: can't parse 'wp-gpios' property of node '/ocp/mmc@480d5000[0]'
[    1.282196] of_get_named_gpiod_flags: can't parse 'wp-gpio' property of node '/ocp/mmc@480d5000[0]'
[    1.282196] omap_hsmmc 480d5000.mmc: using lookup tables for GPIO lookup
[    1.282226] omap_hsmmc 480d5000.mmc: lookup for GPIO wp failed
[    1.282592] omap_hsmmc 480d5000.mmc: omap_device: omap_device_enable() called from invalid state 1
[    1.403289] hctosys: unable to open rtc device (rtc0)
[    1.403778] sr_init: No PMIC hook to init smartreflex
[    1.404144] smartreflex smartreflex.0: omap_sr_probe: SmartReflex driver initialized
[    1.404785] smartreflex smartreflex.1: omap_sr_probe: SmartReflex driver initialized
[    1.405303] smartreflex smartreflex.2: omap_sr_probe: SmartReflex driver initialized
[    1.452880] omap_hsmmc 480d5000.mmc: card claims to support voltages below defined range
[    1.453979] VDAC: disabling
[    1.454956] VANA: disabling
[    1.455902] VUSB: disabling
[    1.459991] Waiting for root device /dev/mmcblk0p5...
[    1.470062] mmc0: host does not support reading read-only switch, assuming write-enable
[    1.473083] mmc0: new high speed SDHC card at address e624
[    1.474975] mmc1: new SDIO card at address 0001
[    1.477569] mmcblk0: mmc0:e624 SE16G 14.8 GiB 
[    1.491607]  mmcblk0: p1 p2 < p5 p6 >
[    1.580749] EXT4-fs (mmcblk0p5): mounted filesystem with ordered data mode. Opts: (null)
[    1.580749] VFS: Mounted root (ext4 filesystem) readonly on device 179:5.
[    1.590820] devtmpfs: mounted
[    1.591949] Freeing unused kernel memory: 1024K (c0b00000 - c0c00000)
[    1.803192] random: systemd urandom read with 13 bits of entropy available
[    2.734191] systemd[1]: systemd-modules-load.service: main process exited, code=exited, status=1/FAILURE
[    2.791809] systemd[1]: Failed to start Load Kernel Modules.
[    2.798126] systemd[1]: Unit systemd-modules-load.service entered failed state.
[    3.156219] systemd-udevd[125]: starting version 215
[    4.275451] twl_rtc 48070000.i2c:twl@48:rtc: Enabling TWL-RTC
[    4.335205] twl_rtc 48070000.i2c:twl@48:rtc: rtc core: registered 48070000.i2c:twl@48 as rtc0
[    4.367614] of_get_named_gpiod_flags: parsed 'gpios' property of node '/ocp/bandgap[0]' - status (0)
[    4.516265] usbcore: registered new interface driver usbfs
[    4.516265] usbcore: registered new interface driver hub
[    4.517303] usbcore: registered new device driver usb
[    4.643615] HS USB OTG: no transceiver configured
[    4.649047] musb-hdrc musb-hdrc.0.auto: musb_init_controller failed with status -517
[    4.677398] omap_wdt: OMAP Watchdog Timer Rev 0x01: initial timeout 60 sec
[    4.679351] omap4-keypad 4a31c000.keypad: number of keypad rows/columns not specified
[    4.679351] omap_hwmod: ocp2scp_usb_phy: _wait_target_disable failed
[    4.687927] omap4-keypad: probe of 4a31c000.keypad failed with error -22
[    4.701110] musb-hdrc musb-hdrc.0.auto: MUSB HDRC host driver
[    4.702209] musb-hdrc musb-hdrc.0.auto: new USB bus registered, assigned bus number 1
[    4.706909] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    4.715728] ehci-omap: OMAP-EHCI Host Controller driver
[    4.722503] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    4.722503] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.722534] usb usb1: Product: MUSB HDRC host driver
[    4.722534] usb usb1: Manufacturer: Linux 4.5.0-rc5-armv7-x1-00001-gffdb57e musb-hcd
[    4.722564] usb usb1: SerialNumber: musb-hdrc.0.auto
[    4.731781] ehci-omap 4a064c00.ehci: EHCI Host Controller
[    4.742370] hub 1-0:1.0: USB hub found
[    4.743743] hub 1-0:1.0: 1 port detected
[    4.765441] ehci-omap 4a064c00.ehci: new USB bus registered, assigned bus number 2
[    4.766906] ehci-omap 4a064c00.ehci: irq 336, io mem 0x4a064c00
[    4.767913] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    4.772308] ohci-omap3: OHCI OMAP3 driver
[    4.784729] cpufreq: cpufreq_online: CPU0: Running at unlisted freq: 699977 KHz
[    4.785369] cpufreq: cpufreq_online: CPU0: Unlisted initial frequency changed to: 700000 KHz
[    4.792022] ehci-omap 4a064c00.ehci: USB 2.0 started, EHCI 1.00
[    4.799041] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    4.799102] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.799133] usb usb2: Product: EHCI Host Controller
[    4.799133] usb usb2: Manufacturer: Linux 4.5.0-rc5-armv7-x1-00001-gffdb57e ehci_hcd
[    4.799163] usb usb2: SerialNumber: 4a064c00.ehci
[    4.809844] hub 2-0:1.0: USB hub found
[    4.811401] hub 2-0:1.0: 3 ports detected
[    4.817260] ohci-omap3 4a064800.ohci: OHCI Host Controller
[    4.817260] ohci-omap3 4a064800.ohci: new USB bus registered, assigned bus number 3
[    4.817810] ohci-omap3 4a064800.ohci: irq 335, io mem 0x4a064800
[    4.839324] of_get_named_gpiod_flags: parsed 'gpios' property of node '/leds/heartbeat[0]' - status (0)
[    4.839324] of_get_named_gpiod_flags: parsed 'gpios' property of node '/leds/mmc[0]' - status (0)
[    4.922210] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    4.922271] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.922271] usb usb3: Product: OHCI Host Controller
[    4.922302] usb usb3: Manufacturer: Linux 4.5.0-rc5-armv7-x1-00001-gffdb57e ohci_hcd
[    4.922302] usb usb3: SerialNumber: 4a064800.ohci
[    4.948394] hub 3-0:1.0: USB hub found
[    4.952056] hub 3-0:1.0: 3 ports detected
[    4.984863] omap-abe-twl6040 sound: twl6040-legacy <-> 40132000.mcpdm mapping ok
[    5.136840] usb 2-1: new high-speed USB device number 2 using ehci-omap
[    5.293243] usb 2-1: New USB device found, idVendor=0424, idProduct=9514
[    5.293243] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    5.298767] hub 2-1:1.0: USB hub found
[    5.299499] hub 2-1:1.0: 5 ports detected
[    5.347503] EXT4-fs (mmcblk0p5): re-mounted. Opts: errors=remount-ro
[    5.624664] usb 2-1.1: new high-speed USB device number 3 using ehci-omap
[    5.732421] usb 2-1.1: New USB device found, idVendor=0424, idProduct=ec00
[    5.732421] usb 2-1.1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    5.831756] usb 2-1.2: new high-speed USB device number 4 using ehci-omap
[    5.942352] usb 2-1.2: New USB device found, idVendor=0409, idProduct=005a
[    5.942413] usb 2-1.2: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    5.945037] hub 2-1.2:1.0: USB hub found
[    5.945220] hub 2-1.2:1.0: 4 ports detected
[    6.135894] random: nonblocking pool is initialized
[    6.221710] usb 2-1.2.1: new low-speed USB device number 5 using ehci-omap
[    6.338348] usb 2-1.2.1: New USB device found, idVendor=0603, idProduct=0002
[    6.338348] usb 2-1.2.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    6.338439] usb 2-1.2.1: Product: USB Composite Device
[    6.338439] usb 2-1.2.1: Manufacturer: SINO WEALTH
[    6.606079] usbcore: registered new interface driver usbhid
[    6.606079] usbhid: USB HID core driver
[    6.614166] usbcore: registered new interface driver usbkbd
[    6.629364] systemd-journald[134]: Received request to flush runtime journal from PID 1
[    6.636413] usbcore: registered new interface driver usbmouse
[    6.702484] input: SINO WEALTH USB Composite Device as /devices/platform/44000000.ocp/4a064000.usbhshost/4a064c00.ehci/usb2/2-1/2-1.2/2-1.2.1/2-1.2.1:1.0/0003:0603:0002.0001/input/input0
[    6.752655] wlcore: loaded
[    6.761840] hid-generic 0003:0603:0002.0001: input: USB HID v1.10 Keyboard [SINO WEALTH USB Composite Device] on usb-4a064c00.ehci-1.2.1/input0
[    6.763793] input: SINO WEALTH USB Composite Device as /devices/platform/44000000.ocp/4a064000.usbhshost/4a064c00.ehci/usb2/2-1/2-1.2/2-1.2.1/2-1.2.1:1.1/0003:0603:0002.0002/input/input1
[    6.840820] hid-generic 0003:0603:0002.0002: input,hiddev0: USB HID v1.10 Mouse [SINO WEALTH USB Composite Device] on usb-4a064c00.ehci-1.2.1/input1
[    7.657531] smsc95xx v1.0.4
[    7.774017] smsc95xx 2-1.1:1.0 eth0: register 'smsc95xx' at usb-4a064c00.ehci-1.1, smsc95xx USB 2.0 Ethernet, 5e:f8:81:f6:c7:42
[    7.774291] usbcore: registered new interface driver smsc95xx
[   11.320007] wlcore: firmware booted (Rev 6.3.10.0.133)
[   11.532196] smsc95xx 2-1.1:1.0 eth0: hardware isn't capable of remote wakeup
[   13.042724] smsc95xx 2-1.1:1.0 eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1
[  141.113433] wlcore: Scan completed due to error.
[  141.113433] ------------[ cut here ]------------
[  141.113983] WARNING: CPU: 1 PID: 67 at drivers/net/wireless/ti/wlcore/main.c:787 wl12xx_queue_recovery_work.part.8+0x54/0x60 [wlcore]()
[  141.113983] Modules linked in: smsc95xx usbnet input_leds evdev arc4 hid_generic usbmouse usbkbd usbhid wl12xx wlcore mac80211 cfg80211 snd_soc_omap_abe_twl6040 omapfb snd_soc_twl6040 cfbfillrect cfbimgblt cfbcopyarea leds_gpio led_class cpufreq_dt ohci_omap3 omapdss ohci_hcd ehci_omap phy_omap_usb2 omap4_keypad ehci_hcd matrix_keymap omap_wdt omap2430 wlcore_sdio musb_hdrc udc_core usbcore ti_soc_thermal thermal_sys hwmon rtc_twl pwm_twl_led pwm_twl snd_soc_omap_mcpdm snd_soc_omap_mcbsp snd_soc_omap snd_soc_core snd_pcm_dmaengine snd_pcm snd_timer snd soundcore autofs4
[  141.113983] CPU: 1 PID: 67 Comm: kworker/u4:1 Not tainted 4.5.0-rc5-armv7-x1-00001-gffdb57e #23
[  141.114532] Hardware name: Generic OMAP4 (Flattened Device Tree)
[  141.114532] Workqueue: phy0 wl1271_scan_complete_work [wlcore]
[  141.114807] [<c0110cb4>] (unwind_backtrace) from [<c010cd28>] (show_stack+0x10/0x14)
[  141.114807] [<c010cd28>] (show_stack) from [<c0469060>] (dump_stack+0xb0/0xe4)
[  141.114807] [<c0469060>] (dump_stack) from [<c0136f54>] (warn_slowpath_common+0x78/0xb4)
[  141.115020] [<c0136f54>] (warn_slowpath_common) from [<c013702c>] (warn_slowpath_null+0x1c/0x24)
[  141.115020] [<c013702c>] (warn_slowpath_null) from [<bf499390>] (wl12xx_queue_recovery_work.part.8+0x54/0x60 [wlcore])
[  141.115020] [<bf499390>] (wl12xx_queue_recovery_work.part.8 [wlcore]) from [<bf4ae728>] (wl1271_scan_complete_work+0x10c/0x120 [wlcore])
[  141.115020] [<bf4ae728>] (wl1271_scan_complete_work [wlcore]) from [<c01515bc>] (process_one_work+0x1b0/0x528)
[  141.116180] [<c01515bc>] (process_one_work) from [<c015196c>] (worker_thread+0x38/0x4e8)
[  141.116180] [<c015196c>] (worker_thread) from [<c01577d8>] (kthread+0xd4/0xf0)
[  141.116180] [<c01577d8>] (kthread) from [<c0108510>] (ret_from_fork+0x14/0x24)
[  141.116180] ---[ end trace e7192270724dfef3 ]---
[  141.118103] wlcore: Hardware recovery in progress. FW ver: Rev 6.3.10.0.133
[  141.128051] wlcore: pc: 0x0, hint_sts: 0x00000020 count: 1
[  141.129791] wlcore: down
[  141.136169] ieee80211 phy0: Hardware restart was requested
[  141.654876] wlcore: firmware booted (Rev 6.3.10.0.133)
[  194.072662] wlcore: Scan completed due to error.
[  194.072662] ------------[ cut here ]------------
[  194.073242] WARNING: CPU: 1 PID: 67 at drivers/net/wireless/ti/wlcore/main.c:787 wl12xx_queue_recovery_work.part.8+0x54/0x60 [wlcore]()
[  194.073242] Modules linked in: smsc95xx usbnet input_leds evdev arc4 hid_generic usbmouse usbkbd usbhid wl12xx wlcore mac80211 cfg80211 snd_soc_omap_abe_twl6040 omapfb snd_soc_twl6040 cfbfillrect cfbimgblt cfbcopyarea leds_gpio led_class cpufreq_dt ohci_omap3 omapdss ohci_hcd ehci_omap phy_omap_usb2 omap4_keypad ehci_hcd matrix_keymap omap_wdt omap2430 wlcore_sdio musb_hdrc udc_core usbcore ti_soc_thermal thermal_sys hwmon rtc_twl pwm_twl_led pwm_twl snd_soc_omap_mcpdm snd_soc_omap_mcbsp snd_soc_omap snd_soc_core snd_pcm_dmaengine snd_pcm snd_timer snd soundcore autofs4
[  194.073242] CPU: 1 PID: 67 Comm: kworker/u4:1 Tainted: G        W       4.5.0-rc5-armv7-x1-00001-gffdb57e #23
[  194.073791] Hardware name: Generic OMAP4 (Flattened Device Tree)
[  194.074066] Workqueue: phy0 wl1271_scan_complete_work [wlcore]
[  194.074066] [<c0110cb4>] (unwind_backtrace) from [<c010cd28>] (show_stack+0x10/0x14)
[  194.074066] [<c010cd28>] (show_stack) from [<c0469060>] (dump_stack+0xb0/0xe4)
[  194.074249] [<c0469060>] (dump_stack) from [<c0136f54>] (warn_slowpath_common+0x78/0xb4)
[  194.074249] [<c0136f54>] (warn_slowpath_common) from [<c013702c>] (warn_slowpath_null+0x1c/0x24)
[  194.074249] [<c013702c>] (warn_slowpath_null) from [<bf499390>] (wl12xx_queue_recovery_work.part.8+0x54/0x60 [wlcore])
[  194.075012] [<bf499390>] (wl12xx_queue_recovery_work.part.8 [wlcore]) from [<bf4ae728>] (wl1271_scan_complete_work+0x10c/0x120 [wlcore])
[  194.075286] [<bf4ae728>] (wl1271_scan_complete_work [wlcore]) from [<c01515bc>] (process_one_work+0x1b0/0x528)
[  194.075286] [<c01515bc>] (process_one_work) from [<c015196c>] (worker_thread+0x38/0x4e8)
[  194.075378] [<c015196c>] (worker_thread) from [<c01577d8>] (kthread+0xd4/0xf0)
[  194.075378] [<c01577d8>] (kthread) from [<c0108510>] (ret_from_fork+0x14/0x24)
[  194.075439] ---[ end trace e7192270724dfef4 ]---
[  194.075653] wlcore: Hardware recovery in progress. FW ver: Rev 6.3.10.0.133
[  194.079010] wlcore: pc: 0x0, hint_sts: 0x00000020 count: 2
[  194.080413] wlcore: down
[  194.085205] ieee80211 phy0: Hardware restart was requested
[  194.623474] wlcore: firmware booted (Rev 6.3.10.0.133)

--4Ckj6UjgE2iN1+kY--
