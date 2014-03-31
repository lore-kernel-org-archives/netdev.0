From: "Pascal Speck" <linux@iktek.de>
Subject: BUG: Kernel Panic: skb_over_panic with am335 <-> musb <-> ax88760
Date: Mon, 31 Mar 2014 13:04:58 +0200
Message-ID: <004c01cf4cd1$0e9511c0$2bbf3540$@de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 340.hostserv.eu ([82.220.37.15]:50289 "EHLO 340.hostserv.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561AbaCaLME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 07:12:04 -0400
Received: from xps (p4FF7C846.dip0.t-ipconnect.de [79.247.200.70])
	by 340.hostserv.eu (Postfix) with ESMTPA id 009D117E741
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 13:05:00 +0200 (CEST)
Content-Language: de
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello List, 

i'm not very familiar with reporting Bugs, this is my first Try, so please
be indulgent to me, when I do something wrong. 
I hope, I'm thinking on all Information you need and I have the right list.

I don't really know if the problem is sourced on musb or the ASIX driver. 
The error is reproducible every time I start the system over NFS and I have
the possibility to debug into the kernel within KGDB, but at this moment I
don't know the structure of musb networking, so I don't know where to start
debugging.

Could someone please give me answer, if I'm right on this way telling the
bug or if I should try something else and provide more information.
I really need this working driver for a very time-critical project of one of
my customers and I'm willing to work on a fix if you tell me how.

I have the following Problem:
When booting the Linux Kernel with the following constellation:

AM335 <->MUSB <-> AX88760 over NFS

I get the following Output:



[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.14.0-rc7+ (root@ThinkPad) (gcc version 4.7.3
(Buildroot 2013.11) ) #19 Sun Mar 30 18:55:05 CEST 2014
[    0.000000] CPU: ARMv7 Processor [413fc082] revision 2 (ARMv7),
cr=10c5387d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing
instruction cache
[    0.000000] Machine model: TI AM335x BeagleBone
[    0.000000] cma: CMA: reserved 16 MiB at 9f000000
[    0.000000] Memory policy: Data cache writeback
[    0.000000] CPU: All CPU(s) started in SVC mode.
[    0.000000] AM335X ES2.0 (sgx neon )
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total
pages: 130048
[    0.000000] Kernel command line: console=ttyO0,115200n8 root=/dev/nfs rw
nfsroot=192.168.30.235:/srv/root nolock rsize=4096 wsize=4096
ip=192.168.30.236:192.168.30.235:192.168.30.2:255.255.255.0:Xenon:eth1:off
kgdbwait kgdboc=ttyO0,115200
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144
bytes)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072
bytes)
[    0.000000] allocated 1048576 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want
memory cgroups
[    0.000000] Memory: 493272K/524288K available (6076K kernel code, 391K
rwdata, 1832K rodata, 191K init, 422K bss, 31016K reserved, 0K highmem)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
[    0.000000]     vmalloc : 0xe0800000 - 0xff000000   ( 488 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xe0000000   ( 512 MB)
[    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
[    0.000000]       .text : 0xc0008000 - 0xc07c14ac   (7910 kB)
[    0.000000]       .init : 0xc07c2000 - 0xc07f1d24   ( 192 kB)
[    0.000000]       .data : 0xc07f2000 - 0xc0853e60   ( 392 kB)
[    0.000000]        .bss : 0xc0853e60 - 0xc08bd878   ( 423 kB)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] IRQ: Found an INTC at 0xfa200000 (revision 5.0) with 128
interrupts
[    0.000000] Total of 128 interrupts on 1 active controller
[    0.000000] OMAP clockevent source: timer2 at 24000000 Hz
[    0.000009] sched_clock: 32 bits at 24MHz, resolution 41ns, wraps every
178956969942ns
[    0.000026] OMAP clocksource: timer1 at 24000000 Hz
[    0.000200] Console: colour dummy device 80x30
[    0.000226] Calibrating delay loop... 996.14 BogoMIPS (lpj=4980736)
[    0.089555] pid_max: default: 32768 minimum: 301
[    0.089684] Mount-cache hash table entries: 512
[    0.095009] Initializing cgroup subsys memory
[    0.095051] Initializing cgroup subsys devices
[    0.095061] Initializing cgroup subsys freezer
[    0.095069] Initializing cgroup subsys blkio
[    0.095076] Initializing cgroup subsys perf_event
[    0.095163] CPU: Testing write buffer coherency: ok
[    0.095499] Setting up static identity map for 0x805bdbb0 - 0x805bdc08
[    0.096401] devtmpfs: initialized
[    0.098173] VFP support v0.3: implementor 41 architecture 3 part 30
variant c rev 3
[    0.103513] omap_hwmod: tptc0 using broken dt data from edma
[    0.103575] omap_hwmod: tptc1 using broken dt data from edma
[    0.103628] omap_hwmod: tptc2 using broken dt data from edma
[    0.107500] omap_hwmod: debugss: _wait_target_disable failed
[    0.161906] pinctrl core: initialized pinctrl subsystem
[    0.162233] regulator-dummy: no parameters
[    0.163384] NET: Registered protocol family 16
[    0.165227] DMA: preallocated 256 KiB pool for atomic coherent
allocations
[    0.165779] cpuidle: using governor ladder
[    0.165790] cpuidle: using governor menu
[    0.171572] pinctrl-single 44e10800.pinmux: 142 pins at pa f9e10800 size
568
[    0.172142] platform 49000000.edma: alias fck already exists
[    0.172160] platform 49000000.edma: alias fck already exists
[    0.172172] platform 49000000.edma: alias fck already exists
[    0.172756] OMAP GPIO hardware version 0.1
[    0.178174] hw-breakpoint: debug architecture 0x4 unsupported.
[    0.185517] bio: create slab <bio-0> at 0
[    0.191270] edma-dma-engine edma-dma-engine.0: TI EDMA DMA engine driver
[    0.191708] vmmcsd_fixed: 3300 mV 
[    0.193393] SCSI subsystem initialized
[    0.193611] usbcore: registered new interface driver usbfs
[    0.193655] usbcore: registered new interface driver hub
[    0.193973] usbcore: registered new device driver usb
[    0.195893] DCDC1: at 1500 mV 
[    0.196649] vdd_mpu: 925 <--> 1325 mV at 1325 mV 
[    0.197377] vdd_core: 925 <--> 1150 mV at 1125 mV 
[    0.198083] LDO1: at 1800 mV 
[    0.198792] LDO2: at 3300 mV 
[    0.200007] LDO3: 1800 mV 
[    0.200730] LDO4: at 3300 mV 
[    0.201157] tps65217 0-0024: TPS65217 ID 0xe version 1.2
[    0.201289] omap_i2c 44e0b000.i2c: bus 0 rev0.11 at 400 kHz
[    0.202275] omap_i2c 4819c000.i2c: bus 2 rev0.11 at 100 kHz
[    0.202470] pps_core: LinuxPPS API ver. 1 registered
[    0.202478] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo
Giometti <giometti@linux.it>
[    0.202505] EDAC MC: Ver: 3.0.0
[    0.203254] Advanced Linux Sound Architecture Driver Initialized.
[    0.204053] cfg80211: Calling CRDA to update world regulatory domain
[    0.204441] Switched to clocksource timer1
[    0.204699] FS-Cache: Loaded
[    0.212597] NET: Registered protocol family 2
[    0.213079] TCP established hash table entries: 4096 (order: 2, 16384
bytes)
[    0.213121] TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
[    0.213159] TCP: Hash tables configured (established 4096 bind 4096)
[    0.213231] TCP: reno registered
[    0.213243] UDP hash table entries: 256 (order: 0, 4096 bytes)
[    0.213258] UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
[    0.213437] NET: Registered protocol family 1
[    0.213774] RPC: Registered named UNIX socket transport module.
[    0.213784] RPC: Registered udp transport module.
[    0.213790] RPC: Registered tcp transport module.
[    0.213795] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.214364] hw perfevents: enabled with ARMv7 Cortex-A8 PMU driver, 5
counters available
[    0.215827] futex hash table entries: 256 (order: -1, 2048 bytes)
[    0.215895] audit: initializing netlink subsys (disabled)
[    0.215944] audit: type=2000 audit(0.200:1): initialized
[    0.221793] VFS: Disk quotas dquot_6.5.2
[    0.221964] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    0.223543] NFS: Registering the id_resolver key type
[    0.223603] Key type id_resolver registered
[    0.223610] Key type id_legacy registered
[    0.223625] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[    0.223633] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    0.224715] fuse init (API version 7.22)
[    0.225204] msgmni has been set to 995
[    0.226944] Block layer SCSI generic (bsg) driver version 0.4 loaded
(major 250)
[    0.227056] io scheduler noop registered
[    0.227065] io scheduler deadline registered
[    0.227204] io scheduler cfq registered (default)
[    0.275737] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.277354] omap_uart 44e09000.serial: no wakeirq for uart0
[    0.277637] 44e09000.serial: ttyO0 at MMIO 0x44e09000 (irq = 88,
base_baud = 3000000) is a OMAP UART0
[    0.984228] console [ttyO0] enabled
[    0.988441] omap_uart 48022000.serial: no wakeirq for uart0
[    0.994508] 48022000.serial: ttyO1 at MMIO 0x48022000 (irq = 89,
base_baud = 3000000) is a OMAP UART1
[    1.004912] omap_rng 48310000.rng: OMAP Random Number Generator ver. 20
[    1.012013] at24 0-0050: 32768 byte 24c256 EEPROM, writable, 1
bytes/write
[    1.019299] at24 2-0054: 32768 byte 24c256 EEPROM, writable, 1
bytes/write
[    1.026564] at24 2-0055: 32768 byte 24c256 EEPROM, writable, 1
bytes/write
[    1.033804] at24 2-0056: 32768 byte 24c256 EEPROM, writable, 1
bytes/write
[    1.041061] at24 2-0057: 32768 byte 24c256 EEPROM, writable, 1
bytes/write
[    1.051498] RIspi: Probe
[    1.054719] Atmel at76x USB Wireless LAN Driver 0.17 loading
[    1.060700] usbcore: registered new interface driver at76c50x-usb
[    1.067190] Broadcom 43xx driver loaded [ Features: N ]
[    1.072849] usbcore: registered new interface driver zd1211rw
[    1.078936] usbcore: registered new interface driver rtl8187
[    1.084915] usbcore: registered new interface driver rndis_wlan
[    1.091151] usbcore: registered new interface driver zd1201
[    1.097068] usbcore: registered new interface driver usb8xxx
[    1.102999] libertas_sdio: Libertas SDIO driver
[    1.107758] libertas_sdio: Copyright Pierre Ossman
[    1.112808] libertas_spi: Libertas SPI driver
[    1.117565] usbcore: registered new interface driver rt2500usb
[    1.123716] usbcore: registered new interface driver rt73usb
[    1.129701] usbcore: registered new interface driver rt2800usb
[    1.135861] usbcore: registered new interface driver p54usb
[    1.141876] usbcore: registered new interface driver mwifiex_usb
[    1.148306] usbcore: registered new interface driver catc
[    1.153998] usbcore: registered new interface driver kaweth
[    1.159854] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ethernet
driver
[    1.167661] usbcore: registered new interface driver pegasus
[    1.173625] usbcore: registered new interface driver rtl8150
[    1.179608] usbcore: registered new interface driver r8152
[    1.185402] usbcore: registered new interface driver asix
[    1.191093] usbcore: registered new interface driver ax88179_178a
[    1.197524] usbcore: registered new interface driver cdc_ether
[    1.203670] usbcore: registered new interface driver smsc95xx
[    1.209750] usbcore: registered new interface driver rndis_host
[    1.216411] usbcore: registered new interface driver cdc_wdm
[    1.222382] usbcore: registered new interface driver usb-storage
[    1.228837] usbcore: registered new interface driver usbserial
[    1.235002] usbcore: registered new interface driver usbserial_generic
[    1.241877] usbserial: USB Serial support registered for generic
[    1.248218] usbcore: registered new interface driver aircable
[    1.254270] usbserial: USB Serial support registered for aircable
[    1.260703] usbcore: registered new interface driver ftdi_sio
[    1.266770] usbserial: USB Serial support registered for FTDI USB Serial
Device
[    1.274477] usbcore: registered new interface driver usb_serial_simple
[    1.281348] usbserial: USB Serial support registered for zio
[    1.287327] usbserial: USB Serial support registered for funsoft
[    1.293652] usbserial: USB Serial support registered for flashloader
[    1.300355] usbserial: USB Serial support registered for vivopay
[    1.306692] usbserial: USB Serial support registered for moto_modem
[    1.313290] usbserial: USB Serial support registered for hp4x
[    1.319354] usbserial: USB Serial support registered for suunto
[    1.325601] usbserial: USB Serial support registered for siemens_mpi
[    1.333444] 47401300.usb-phy supply vcc not found, using dummy regulator
[    1.341313] musb-hdrc musb-hdrc.0.auto: Failed to request rx1.
[    1.347505] musb-hdrc musb-hdrc.0.auto: musb_init_controller failed with
status -517
[    1.355672] platform musb-hdrc.0.auto: Driver musb-hdrc requests probe
deferral
[    1.363709] 47401b00.usb-phy supply vcc not found, using dummy regulator
[    1.371428] musb-hdrc musb-hdrc.1.auto: Failed to request rx1.
[    1.377603] musb-hdrc musb-hdrc.1.auto: musb_init_controller failed with
status -517
[    1.385763] platform musb-hdrc.1.auto: Driver musb-hdrc requests probe
deferral
[    1.399563] omap_rtc 44e3e000.rtc: rtc core: registered 44e3e000.rtc as
rtc0
[    1.407139] i2c /dev entries driver
[    1.411327] CirrusDSP: Probe
[    1.414629] Driver for 1-wire Dallas network protocol.
[    1.421064] omap_wdt: OMAP Watchdog Timer Rev 0x01: initial timeout 60
sec
[    1.428643] sdhci: Secure Digital Host Controller Interface driver
[    1.435148] sdhci: Copyright(c) Pierre Ossman
[    1.440343] 48060000.mmc supply vmmc_aux not found, using dummy regulator
[    1.484965] 481d8000.mmc supply vmmc_aux not found, using dummy regulator
[    1.522106] mmc0: host does not support reading read-only switch.
assuming write-enable.
[    1.530821] sdhci-pltfm: SDHCI platform and OF driver helper
[    1.537816] omap-aes 53500000.aes: OMAP AES hw accel rev: 3.2
[    1.544143] mmc0: new high speed SD card at address b368
[    1.550481] mmcblk0: mmc0:b368 AF UD 972 MiB 
[    1.555878] omap-sham 53100000.sham: hw accel on OMAP rev 4.3
[    1.563168]  mmcblk0: p1 p2
[    1.570520] platform sound.10: Driver asoc-simple-card requests probe
deferral
[    1.579108] oprofile: using arm/armv7
[    1.583134] TCP: cubic registered
[    1.586664] NET: Registered protocol family 17
[    1.591390] lib80211: common routines for IEEE802.11 drivers
[    1.597428] Key type dns_resolver registered
[    1.602419] ThumbEE CPU extension supported.
[    1.606955] Registering SWP/SWPB emulation handler
[    1.614544] registered taskstats version 1
[    1.618932] regulator-dummy: disabling
[    1.625158] musb-hdrc musb-hdrc.0.auto: MUSB HDRC host driver
[    1.631501] musb-hdrc musb-hdrc.0.auto: new USB bus registered, assigned
bus number 1
[    1.639985] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.647160] usb usb1: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    1.654743] usb usb1: Product: MUSB HDRC host driver
[    1.659948] usb usb1: Manufacturer: Linux 3.14.0-rc7+ musb-hcd
[    1.666085] usb usb1: SerialNumber: musb-hdrc.0.auto
[    1.671969] hub 1-0:1.0: USB hub found
[    1.675965] hub 1-0:1.0: 1 port detected
[    1.682280] musb-hdrc musb-hdrc.1.auto: MUSB HDRC host driver
[    1.688587] musb-hdrc musb-hdrc.1.auto: new USB bus registered, assigned
bus number 2
[    1.696990] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    1.704111] usb usb2: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    1.711702] usb usb2: Product: MUSB HDRC host driver
[    1.716917] usb usb2: Manufacturer: Linux 3.14.0-rc7+ musb-hcd
[    1.723033] usb usb2: SerialNumber: musb-hdrc.1.auto
[    1.728819] hub 2-0:1.0: USB hub found
[    1.732785] hub 2-0:1.0: 1 port detected
[    1.738633] asoc-simple-card sound.10: fpga-tdm <-> 48038000.mcasp
mapping ok
[    1.797608] mmc1: BKOPS_EN bit is not set
[    1.804135] mmc1: new high speed MMC card at address 0001
[    1.810211] davinci_mdio 4a101000.mdio: davinci mdio revision 1.6
[    1.816639] davinci_mdio 4a101000.mdio: detected phy mask fffffffe
[    1.823480] libphy: 4a101000.mdio: probed
[    1.827703] davinci_mdio 4a101000.mdio: phy[0]: device 4a101000.mdio:00,
driver unknown
[    1.836582] Detected MACID = 04:25:fe:ed:00:18
[    1.842009] omap_rtc 44e3e000.rtc: setting system clock to 2000-01-01
00:00:00 UTC (946684800)
[    1.853639] mmcblk1: mmc1:0001 MMC02G 1.78 GiB 
[    1.858665] mmcblk1boot0: mmc1:0001 MMC02G partition 1 1.00 MiB
[    1.865036] mmcblk1boot1: mmc1:0001 MMC02G partition 2 1.00 MiB
[    1.873128]  mmcblk1: p1 p2
[    1.877775]  mmcblk1boot1: unknown partition table
[    1.884114]  mmcblk1boot0: unknown partition table
[    2.184487] usb 2-1: new high-speed USB device number 2 using musb-hdrc
[    2.325663] usb 2-1: device v05e3 p0610 is not supported
[    2.331239] usb 2-1: New USB device found, idVendor=05e3, idProduct=0610
[    2.338281] usb 2-1: New USB device strings: Mfr=0, Product=1,
SerialNumber=0
[    2.345776] usb 2-1: Product: USB2.0 Hub
[    2.350649] hub 2-1:1.0: USB hub found
[    2.354868] hub 2-1:1.0: 4 ports detected
[    2.634665] usb 2-1.1: new high-speed USB device number 3 using musb-hdrc
[    2.754856] usb 2-1.1: device v0846 p9030 is not supported
[    2.760612] usb 2-1.1: New USB device found, idVendor=0846,
idProduct=9030
[    2.767836] usb 2-1.1: New USB device strings: Mfr=16, Product=32,
SerialNumber=48
[    2.775784] usb 2-1.1: Product: WNA1100
[    2.779804] usb 2-1.1: Manufacturer: NETGEAR WNA
[    2.784652] usb 2-1.1: SerialNumber: 12345
[    2.789303] usb 2-1.1: rejected 1 configuration due to insufficient
available bus power
[    2.797723] usb 2-1.1: no configuration chosen from 1 choice
[    2.884663] usb 2-1.3: new full-speed USB device number 4 using musb-hdrc
[    2.989401] usb 2-1.3: device v0403 p6001 is not supported
[    2.995169] usb 2-1.3: New USB device found, idVendor=0403,
idProduct=6001
[    3.002379] usb 2-1.3: New USB device strings: Mfr=1, Product=2,
SerialNumber=3
[    3.010052] usb 2-1.3: Product: TTL232R-3V3
[    3.014436] usb 2-1.3: Manufacturer: FTDI
[    3.018646] usb 2-1.3: SerialNumber: FTFVFPX1
[    3.025636] ftdi_sio 2-1.3:1.0: FTDI USB Serial Device converter detected
[    3.032881] usb 2-1.3: Detected FT232RL
[    3.036936] usb 2-1.3: Number of endpoints 2
[    3.041413] usb 2-1.3: Endpoint 1 MaxPacketSize 64
[    3.046461] usb 2-1.3: Endpoint 2 MaxPacketSize 64
[    3.051484] usb 2-1.3: Setting MaxPacketSize 64
[    3.056598] usb 2-1.3: FTDI USB Serial Device converter now attached to
ttyUSB0
[    3.144661] usb 2-1.4: new high-speed USB device number 5 using musb-hdrc
[    3.277159] usb 2-1.4: device v0b95 p772a is not supported
[    3.282914] usb 2-1.4: New USB device found, idVendor=0b95,
idProduct=772a
[    3.290137] usb 2-1.4: New USB device strings: Mfr=1, Product=2,
SerialNumber=3
[    3.297809] usb 2-1.4: Product: AX88772A
[    3.301920] usb 2-1.4: Manufacturer: ASIX Elec. Corp.
[    3.307223] usb 2-1.4: SerialNumber: 00181F
[    3.625338] asix 2-1.4:1.0 eth1: register 'asix' at
usb-musb-hdrc.1.auto-1.4, ASIX AX88772 USB 2.0 Ethernet, 00:0e:c6:00:18:1f
[    6.478064] asix 2-1.4:1.0 eth1: link up, 100Mbps, full-duplex, lpa
0xCDE1
[    6.504648] IP-Config: Complete:
[    6.508045]      device=eth1, hwaddr=00:0e:c6:00:18:1f,
ipaddr=192.168.30.236, mask=255.255.255.0, gw=192.168.30.2
[    6.518977]      host=Xenon, domain=, nis-domain=(none)
[    6.524496]      bootserver=192.168.30.235, rootserver=192.168.30.235,
rootpath=
[    6.532407] ALSA device list:
[    6.535537]   #0: 48038000.mcasp-fpga-tdm
[    6.545583] VFS: Mounted root (nfs filesystem) on device 0:12.
[    6.552149] devtmpfs: mounted
[    6.555505] Freeing unused kernel memory: 188K (c07c2000 - c07f1000)
[    6.564864] skbuff: skb_over_panic: text:c0423484 len:2542 put:2542
head:de482500 data:de482542 tail:0xde482f30 end:0xde482d80 dev:eth1
[    6.577645] ------------[ cut here ]------------
[    6.582482] Kernel BUG at c05b9d28 [verbose debug info unavailable]
[    6.589051] Internal error: Oops - BUG: 0 [#1] ARM
[    6.594078] CPU: 0 PID: 0 Comm: swapper Not tainted 3.14.0-rc7+ #19
[    6.600649] task: c07fc460 ti: c07f2000 task.ti: c07f2000
[    6.606321] PC is at skb_panic+0x50/0x5c
[    6.610430] LR is at skb_panic+0x50/0x5c
[    6.614540] pc : [<c05b9d28>]    lr : [<c05b9d28>]    psr: 60000193
[    6.614540] sp : c07f3dd0  ip : 000008d0  fp : 000011cc
[    6.626577] r10: de01e010  r9 : 00000000  r8 : de412f80
[    6.632053] r7 : c0777e6b  r6 : de482500  r5 : de482542  r4 : de482f30
[    6.638895] r3 : 00000000  r2 : c08088bc  r1 : 00000001  r0 : 0000007b
[    6.645739] Flags: nZCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment
kernel
[    6.653493] Control: 10c5387d  Table: 80004019  DAC: 00000015
[    6.659515] Process swapper (pid: 0, stack limit = 0xc07f2240)
[    6.665629] Stack: (0xc07f3dd0 to 0xc07f4000)
[    6.670195] 3dc0:                                     000009ee de482500
de482542 de482f30
[    6.678773] 3de0: de482d80 de382800 00000000 de482f30 000009ee 00000000
de44d180 c04d928c
[    6.687350] 3e00: de382ca0 de412f80 00000000 c0423484 c0423464 de412f80
60000193 de3f8000
[    6.695927] 3e20: 00000000 c042d024 de442000 de447700 de01e490 00000080
00000000 c044d630
[    6.704504] 3e40: de01e010 00000001 de01e490 de025068 de01e490 00000004
20000193 de01e010
[    6.713080] 3e60: 0000008e 00000080 00000000 c044f1b8 00000003 00000000
c07f3eb0 fffffdda
[    6.721657] 3e80: ffff8d60 ffffffff 00000000 de025068 de01e490 00000004
20000193 de01e010
[    6.730234] 3ea0: 00000080 c044f874 de404cc0 c04d4538 ffffffff 00000017
00000017 00000000
[    6.738812] 3ec0: c06587e8 00000000 de357000 00000004 9f041400 00000001
00000080 c0272714
[    6.747389] 3ee0: de36de40 de005080 00000021 00000000 00000000 c0853c9a
defff300 c005a090
[    6.755966] 3f00: de005080 de36de40 de005080 00000000 00000021 c085466c
c07fa000 413fc082
[    6.764543] 3f20: defff300 c005a21c de005080 c005c2cc 00000021 c0059b44
00000021 c000e3d4
[    6.773120] 3f40: 00000011 fa200000 c07f3f68 c000854c c000e510 c000e514
60000113 ffffffff
[    6.781697] 3f60: c07f3f9c c0010e00 ffffffed c0808a98 00000000 00000000
c07f2000 c0853e80
[    6.790274] 3f80: c07fa0a0 c07eaf00 c07fa000 413fc082 defff300 00000000
c0808a98 c07f3fb0
[    6.798850] 3fa0: c000e510 c000e514 60000113 ffffffff c0808a98 c0059994
00000000 c07c2a1c
[    6.807427] 3fc0: ffffffff ffffffff c07c24e8 00000000 00000000 c07eaf00
00000000 10c5387d
[    6.816004] 3fe0: c07fa01c c07eaefc c07fdf50 80004059 00000000 80008070
00000000 00000000
[    6.824603] [<c05b9d28>] (skb_panic) from [<c04d928c>]
(skb_put+0x44/0x50)
[    6.831821] [<c04d928c>] (skb_put) from [<c0423484>]
(rx_complete+0x20/0x1d0)
[    6.839316] [<c0423484>] (rx_complete) from [<c042d024>]
(__usb_hcd_giveback_urb+0x98/0x100)
[    6.848175] [<c042d024>] (__usb_hcd_giveback_urb) from [<c044d630>]
(musb_advance_schedule+0xe8/0x24c)
[    6.857940] [<c044d630>] (musb_advance_schedule) from [<c044f1b8>]
(cppi41_trans_done+0x3c/0x130)
[    6.867248] [<c044f1b8>] (cppi41_trans_done) from [<c044f874>]
(cppi41_dma_callback+0x1c0/0x220)
[    6.876474] [<c044f874>] (cppi41_dma_callback) from [<c0272714>]
(cppi41_irq+0x110/0x16c)
[    6.885064] [<c0272714>] (cppi41_irq) from [<c005a090>]
(handle_irq_event_percpu+0x2c/0x190)
[    6.893918] [<c005a090>] (handle_irq_event_percpu) from [<c005a21c>]
(handle_irq_event+0x28/0x38)
[    6.903228] [<c005a21c>] (handle_irq_event) from [<c005c2cc>]
(handle_level_irq+0xc4/0xd4)
[    6.911900] [<c005c2cc>] (handle_level_irq) from [<c0059b44>]
(generic_handle_irq+0x20/0x30)
[    6.920759] [<c0059b44>] (generic_handle_irq) from [<c000e3d4>]
(handle_IRQ+0x60/0x84)
[    6.929065] [<c000e3d4>] (handle_IRQ) from [<c000854c>]
(omap3_intc_handle_irq+0x60/0x74)
[    6.937648] [<c000854c>] (omap3_intc_handle_irq) from [<c0010e00>]
(__irq_svc+0x40/0x50)
[    6.946129] Exception stack(0xc07f3f68 to 0xc07f3fb0)
[    6.951426] 3f60:                   ffffffed c0808a98 00000000 00000000
c07f2000 c0853e80
[    6.960002] 3f80: c07fa0a0 c07eaf00 c07fa000 413fc082 defff300 00000000
c0808a98 c07f3fb0
[    6.968576] 3fa0: c000e510 c000e514 60000113 ffffffff
[    6.973877] [<c0010e00>] (__irq_svc) from [<c000e514>]
(arch_cpu_idle+0x30/0x38)
[    6.981636] [<c000e514>] (arch_cpu_idle) from [<c0059994>]
(cpu_startup_entry+0x6c/0xcc)
[    6.990130] [<c0059994>] (cpu_startup_entry) from [<c07c2a1c>]
(start_kernel+0x308/0x36c)
[    6.998707] Code: e1a0300c e58de010 e59f0008 ebfff553 (e7f001f2) 
[    7.005097] ---[ end trace 9ad24e3eaebb1c8c ]---
[    7.009935] Kernel panic - not syncing: Fatal exception in interrupt
