From: Emil Goode <emilgoode@gmail.com>
Subject: Re: [PATCH] brcmfmac: Fix off by one bug in
 brcmf_count_20mhz_channels()
Date: Tue, 23 Sep 2014 01:08:33 +0200
Message-ID: <20140922230833.GB10356@lianli>
References: <1411253932-27973-1-git-send-email-emilgoode@gmail.com>
 <541FF25B.9000404@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Cc: Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:48680 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768AbaIVXIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 19:08:44 -0400
Content-Disposition: inline
In-Reply-To: <541FF25B.9000404@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello Arend,

Sorry for the late reply. I have attached a kernel log with brcmfmac
debugging enabled (without my patch applied).

Let me know if I can provide any other useful information.

Best regards,

Emil

On Mon, Sep 22, 2014 at 11:56:43AM +0200, Arend van Spriel wrote:
> On 09/21/14 00:58, Emil Goode wrote:
> >In the brcmf_count_20mhz_channels function we are looping through a list
> >of channels received from firmware. Since the index of the first channel
> >is 0 the condition leads to an off by one bug. This is causing us to hit
> >the WARN_ON_ONCE(1) calls in the brcmu_d11n_decchspec function, which is
> >how I discovered the bug.
> 
> The fix is fine. Would like to know what exactly is going wrong. Can you
> provide a kernel log with brcmfmac debugging enabled, ie. insmod brcmfmac.ko
> debug=0x1416
> 
> Regards,
> Arend
> 
> >Introduced by:
> >commit b48d891676f756d48b4d0ee131e4a7a5d43ca417
> >("brcmfmac: rework wiphy structure setup")
> >
> >Signed-off-by: Emil Goode<emilgoode@gmail.com>
> >---
> >  drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> >diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
> >index 02fe706..93b5dd9 100644
> >--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
> >+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
> >@@ -4918,7 +4918,7 @@ static void brcmf_count_20mhz_channels(struct brcmf_cfg80211_info *cfg,
> >  	struct brcmu_chan ch;
> >  	int i;
> >
> >-	for (i = 0; i<= total; i++) {
> >+	for (i = 0; i<  total; i++) {
> >  		ch.chspec = (u16)le32_to_cpu(chlist->element[i]);
> >  		cfg->d11inf.decchspec(&ch);
> >
> 

--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg_brcmfmac_debug.out"

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.17.0-rc6-armv7-x2 (emil@lianli) (gcc version 4.8.3 20140401 (prerelease) (crosstool-NG linaro-1.13.1-4.8-2014.04 - Linaro GCC 4.8-2014.04) ) #3 SMP Mon Sep 22 21:25:25 CEST 2014
[    0.000000] CPU: ARMv7 Processor [412fc09a] revision 10 (ARMv7), cr=10c5387d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
[    0.000000] Machine model: Wandboard i.MX6 Quad Board
[    0.000000] cma: Reserved 16 MiB at 3e800000
[    0.000000] Memory policy: Data cache writealloc
[    0.000000] On node 0 totalpages: 524288
[    0.000000] free_area_init_node: node 0, pgdat c0f66b40, node_mem_map ed7f0000
[    0.000000]   Normal zone: 1520 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 194560 pages, LIFO batch:31
[    0.000000]   HighMem zone: 2576 pages used for memmap
[    0.000000]   HighMem zone: 329728 pages, LIFO batch:31
[    0.000000] PERCPU: Embedded 9 pages/cpu @ed7ab000 s14336 r8192 d14336 u36864
[    0.000000] pcpu-alloc: s14336 r8192 d14336 u36864 alloc=9*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 522768
[    0.000000] Kernel command line: console=ttymxc0,115200 console=tty0 brcmfmac.debug=0x1416 root=/dev/mmcblk0p5 ro rootfstype=ext4 rootwait video=HDMI-A-1:1024x768@60e
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] allocated 4194304 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] Memory: 2042336K/2097152K available (10309K kernel code, 926K rwdata, 3788K rodata, 830K init, 922K bss, 54816K reserved, 1318912K highmem)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     fixmap  : 0xffc00000 - 0xffe00000   (2048 kB)
[    0.000000]     vmalloc : 0xf0000000 - 0xff000000   ( 240 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xef800000   ( 760 MB)
[    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
[    0.000000]     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
[    0.000000]       .text : 0xc0008000 - 0xc0dcca40   (14099 kB)
[    0.000000]       .init : 0xc0dcd000 - 0xc0e9c800   ( 830 kB)
[    0.000000]       .data : 0xc0e9e000 - 0xc0f859b8   ( 927 kB)
[    0.000000]        .bss : 0xc0f859b8 - 0xc106c51c   ( 923 kB)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] L2C-310 erratum 769419 enabled
[    0.000000] L2C-310 enabling early BRESP for Cortex-A9
[    0.000000] L2C-310 full line of zeros enabled for Cortex-A9
[    0.000000] L2C-310 ID prefetch enabled, offset 1 lines
[    0.000000] L2C-310 dynamic clock gating enabled, standby mode enabled
[    0.000000] L2C-310 cache controller enabled, 16 ways, 1024 kB
[    0.000000] L2C-310: CACHE_ID 0x410000c7, AUX_CTRL 0x76070001
[    0.000000] Switching to timer-based delay loop, resolution 15ns
[    0.000008] sched_clock: 32 bits at 66MHz, resolution 15ns, wraps every 65075262448ns
[    0.001524] Console: colour dummy device 80x30
[    0.002213] console [tty0] enabled
[    0.002248] Calibrating delay loop (skipped), value calculated using timer frequency.. 132.00 BogoMIPS (lpj=660000)
[    0.002287] pid_max: default: 32768 minimum: 301
[    0.002430] Security Framework initialized
[    0.002474] AppArmor: AppArmor disabled by boot time parameter
[    0.002496] Yama: becoming mindful.
[    0.002693] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.002726] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.003442] Initializing cgroup subsys memory
[    0.003492] Initializing cgroup subsys devices
[    0.003523] Initializing cgroup subsys freezer
[    0.003554] Initializing cgroup subsys net_cls
[    0.003587] Initializing cgroup subsys blkio
[    0.003612] Initializing cgroup subsys perf_event
[    0.003638] Initializing cgroup subsys net_prio
[    0.003703] CPU: Testing write buffer coherency: ok
[    0.003748] ftrace: allocating 34038 entries in 100 pages
[    0.060864] CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
[    0.061007] Setting up static identity map for 0x10955578 - 0x10955610
[    0.069916] CPU1: Booted secondary processor
[    0.069949] CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
[    0.071003] CPU2: Booted secondary processor
[    0.071028] CPU2: thread -1, cpu 2, socket 0, mpidr 80000002
[    0.072065] CPU3: Booted secondary processor
[    0.072090] CPU3: thread -1, cpu 3, socket 0, mpidr 80000003
[    0.072180] Brought up 4 CPUs
[    0.072265] SMP: Total of 4 processors activated.
[    0.072279] CPU: All CPU(s) started in SVC mode.
[    0.072969] devtmpfs: initialized
[    0.077467] VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev 4
[    0.084771] xor: measuring software checksum speed
[    0.179596]    arm4regs  :  1363.200 MB/sec
[    0.279593]    8regs     :   821.200 MB/sec
[    0.379596]    32regs    :   769.200 MB/sec
[    0.479596]    neon      :   888.800 MB/sec
[    0.479611] xor: using function: arm4regs (1363.200 MB/sec)
[    0.479658] pinctrl core: initialized pinctrl subsystem
[    0.480118] regulator-dummy: no parameters
[    0.487918] NET: Registered protocol family 16
[    0.491141] DMA: preallocated 256 KiB pool for atomic coherent allocations
[    0.492158] cpuidle: using governor ladder
[    0.492185] cpuidle: using governor menu
[    0.492551] CPU identified as i.MX6Q, silicon rev 1.2
[    0.501208] vdd1p1: 800 <--> 1375 mV at 1100 mV 
[    0.501691] vdd3p0: 2800 <--> 3150 mV at 3000 mV 
[    0.502148] vdd2p5: 2000 <--> 2750 mV at 2400 mV 
[    0.502604] vddarm: 725 <--> 1450 mV at 1150 mV 
[    0.503099] vddpu: 725 <--> 1450 mV at 1150 mV 
[    0.503569] vddsoc: 725 <--> 1450 mV at 1175 mV 
[    0.511979] No ATAGs?
[    0.512025] hw-breakpoint: found 5 (+1 reserved) breakpoint and 1 watchpoint registers.
[    0.512057] hw-breakpoint: maximum watchpoint size is 4 bytes.
[    0.513440] imx6q-pinctrl 20e0000.iomuxc: initialized IMX pinctrl driver
[    0.719826] raid6: int32x1    115 MB/s
[    0.889868] raid6: int32x2    144 MB/s
[    1.059773] raid6: int32x4    166 MB/s
[    1.229753] raid6: int32x8    192 MB/s
[    1.399641] raid6: neonx1     591 MB/s
[    1.569643] raid6: neonx2     655 MB/s
[    1.739665] raid6: neonx4     653 MB/s
[    1.909671] raid6: neonx8     506 MB/s
[    1.909688] raid6: using algorithm neonx2 (655 MB/s)
[    1.909704] raid6: using intx1 recovery algorithm
[    1.913666] mxs-dma 110000.dma-apbh: initialized
[    1.914243] edma-dma-engine edma-dma-engine.0: Can't allocate PaRAM dummy slot
[    1.914284] edma-dma-engine: probe of edma-dma-engine.0 failed with error -22
[    1.915034] 2P5V: 2500 mV 
[    1.915307] 3P3V: 3300 mV 
[    1.918426] SCSI subsystem initialized
[    1.918678] libata version 3.00 loaded.
[    1.918995] usbcore: registered new interface driver usbfs
[    1.919077] usbcore: registered new interface driver hub
[    1.919211] usbcore: registered new device driver usb
[    1.920512] i2c i2c-0: IMX I2C adapter registered
[    1.921426] i2c i2c-1: IMX I2C adapter registered
[    1.922000] media: Linux media interface: v0.10
[    1.922084] Linux video capture interface: v2.00
[    1.922195] pps_core: LinuxPPS API ver. 1 registered
[    1.922212] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    1.922256] PTP clock support registered
[    1.924088] NetLabel: Initializing
[    1.924112] NetLabel:  domain hash size = 128
[    1.924124] NetLabel:  protocols = UNLABELED CIPSOv4
[    1.924190] NetLabel:  unlabeled traffic allowed by default
[    1.924754] Switched to clocksource mxc_timer1
[    2.011235] NET: Registered protocol family 2
[    2.012117] TCP established hash table entries: 8192 (order: 3, 32768 bytes)
[    2.012227] TCP bind hash table entries: 8192 (order: 4, 65536 bytes)
[    2.012364] TCP: Hash tables configured (established 8192 bind 8192)
[    2.012463] TCP: reno registered
[    2.012487] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    2.012553] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    2.012878] NET: Registered protocol family 1
[    2.013390] RPC: Registered named UNIX socket transport module.
[    2.013413] RPC: Registered udp transport module.
[    2.013428] RPC: Registered tcp transport module.
[    2.013443] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    2.014319] hw perfevents: enabled with armv7_cortex_a9 PMU driver, 7 counters available
[    2.016732] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    2.016947] audit: initializing netlink subsys (disabled)
[    2.017005] audit: type=2000 audit(1.989:1): initialized
[    2.018432] zpool: loaded
[    2.018462] zbud: loaded
[    2.018835] VFS: Disk quotas dquot_6.5.2
[    2.018909] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    2.019706] NFS: Registering the id_resolver key type
[    2.019767] Key type id_resolver registered
[    2.019782] Key type id_legacy registered
[    2.019826] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[    2.020098] fuse init (API version 7.23)
[    2.020328] SGI XFS with ACLs, security attributes, realtime, no debug enabled
[    2.021201] msgmni has been set to 1444
[    2.022517] bounce: pool size: 64 pages
[    2.022593] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 249)
[    2.022779] io scheduler noop registered
[    2.022808] io scheduler deadline registered
[    2.022870] io scheduler cfq registered (default)
[    2.029919] imx-sdma 20ec000.sdma: Direct firmware load for imx/sdma/sdma-imx6q.bin failed with error -2
[    2.029957] imx-sdma 20ec000.sdma: firmware not found
[    2.033582] imx-sdma 20ec000.sdma: initialized
[    2.035822] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    2.037519] Serial: IMX driver
[    2.037853] 2020000.serial: ttymxc0 at MMIO 0x2020000 (irq = 58, base_baud = 5000000) is a IMX
[    2.920692] console [ttymxc0] enabled
[    2.925253] 21ec000.serial: ttymxc2 at MMIO 0x21ec000 (irq = 60, base_baud = 5000000) is a IMX
[    2.935201] serial: Freescale lpuart driver
[    2.940292] [drm] Initialized drm 1.1.0 20060810
[    2.945043] usbcore: registered new interface driver udl
[    2.950397] Error: Driver 'tfp410' is already registered, aborting...
[    2.957914] ipu_smfc_init: ioremap 0x02650000 -> f00de000
[    2.958649] imx-ipuv3 2400000.ipu: IPUv3H probed
[    2.963613] ipu_smfc_init: ioremap 0x02a50000 -> f012e000
[    2.964317] imx-ipuv3 2800000.ipu: IPUv3H probed
[    2.971162] ahci-imx 2200000.sata: fsl,transmit-level-mV not specified, using 00000024
[    2.979138] ahci-imx 2200000.sata: fsl,transmit-boost-mdB not specified, using 00000480
[    2.987185] ahci-imx 2200000.sata: fsl,transmit-atten-16ths not specified, using 00002000
[    2.995401] ahci-imx 2200000.sata: fsl,receive-eq-mdB not specified, using 05000000
[    3.006413] ahci-imx 2200000.sata: SSS flag set, parallel bus scan disabled
[    3.013427] ahci-imx 2200000.sata: AHCI 0001.0300 32 slots 1 ports 3 Gbps 0x1 impl platform mode
[    3.022269] ahci-imx 2200000.sata: flags: ncq sntf stag pm led clo only pmp pio slum part ccc apst 
[    3.032847] scsi host0: ahci_platform
[    3.037052] ata1: SATA max UDMA/133 mmio [mem 0x02200000-0x02203fff] port 0x100 irq 71
[    3.048923] 2188000.ethernet supply phy not found, using dummy regulator
[    3.079889] libphy: fec_enet_mii_bus: probed
[    3.084938] fec 2188000.ethernet eth0: registered PHC device 0
[    3.092045] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    3.098645] ehci-platform: EHCI generic platform driver
[    3.104132] ehci-omap: OMAP-EHCI Host Controller driver
[    3.109558] tegra-ehci: Tegra EHCI driver
[    3.113863] usbcore: registered new interface driver usb-storage
[    3.125348] 2184200.usb supply vbus not found, using dummy regulator
[    3.135534] ci_hdrc ci_hdrc.1: doesn't support gadget
[    3.140617] ci_hdrc ci_hdrc.1: EHCI Host Controller
[    3.145803] ci_hdrc ci_hdrc.1: new USB bus registered, assigned bus number 1
[    3.164796] ci_hdrc ci_hdrc.1: USB 2.0 started, EHCI 1.00
[    3.170462] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    3.177302] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    3.184547] usb usb1: Product: EHCI Host Controller
[    3.189456] usb usb1: Manufacturer: Linux 3.17.0-rc6-armv7-x2 ehci_hcd
[    3.196017] usb usb1: SerialNumber: ci_hdrc.1
[    3.201091] hub 1-0:1.0: USB hub found
[    3.204946] hub 1-0:1.0: 1 port detected
[    3.209614] using random self ethernet address
[    3.214084] using random host ethernet address
[    3.219173] usb0: HOST MAC 7e:c2:60:98:c7:5c
[    3.223522] usb0: MAC ae:68:07:e8:cf:a2
[    3.227444] using random self ethernet address
[    3.231908] using random host ethernet address
[    3.236427] g_ether gadget: Ethernet Gadget, version: Memorial Day 2008
[    3.243060] g_ether gadget: g_ether ready
[    3.247564] mousedev: PS/2 mouse device common for all mice
[    3.253753] i2c /dev entries driver
[    3.258260] IR XMP protocol handler initialized
[    3.265990] imx2-wdt 20bc000.wdog: timeout 60 sec (nowayout=1)
[    3.272628] sdhci: Secure Digital Host Controller Interface driver
[    3.278868] sdhci: Copyright(c) Pierre Ossman
[    3.283914] sdhci-pltfm: SDHCI platform and OF driver helper
[    3.290507] sdhci-esdhc-imx 2190000.usdhc: could not get ultra high speed state, work on normal mode
[    3.300855] sdhci-esdhc-imx 2190000.usdhc: No vmmc regulator found
[    3.307096] sdhci-esdhc-imx 2190000.usdhc: No vqmmc regulator found
[    3.354799] mmc0: SDHCI controller on 2190000.usdhc [2190000.usdhc] using ADMA
[    3.362393] sdhci-esdhc-imx 2194000.usdhc: could not get ultra high speed state, work on normal mode
[    3.372669] sdhci-esdhc-imx 2194000.usdhc: No vmmc regulator found
[    3.378904] sdhci-esdhc-imx 2194000.usdhc: No vqmmc regulator found
[    3.385254] ata1: SATA link down (SStatus 0 SControl 300)
[    3.390717] ahci-imx 2200000.sata: no device found, disabling link.
[    3.397030] ahci-imx 2200000.sata: pass ahci_imx..hotplug=1 to enable hotplug
[    3.444785] mmc1: SDHCI controller on 2194000.usdhc [2194000.usdhc] using ADMA
[    3.453278] sdhci-esdhc-imx 2198000.usdhc: could not get ultra high speed state, work on normal mode
[    3.462587] sdhci-esdhc-imx 2198000.usdhc: No vmmc regulator found
[    3.463805] mmc1: queuing unknown CIS tuple 0x80 (2 bytes)
[    3.465540] mmc1: queuing unknown CIS tuple 0x80 (3 bytes)
[    3.467273] mmc1: queuing unknown CIS tuple 0x80 (3 bytes)
[    3.470382] mmc1: queuing unknown CIS tuple 0x80 (7 bytes)
[    3.474857] mmc1: queuing unknown CIS tuple 0x80 (11 bytes)
[    3.496401] sdhci-esdhc-imx 2198000.usdhc: No vqmmc regulator found
[    3.524828] usb 1-1: new high-speed USB device number 2 using ci_hdrc
[    3.525468] mmc1: new high speed SDIO card at address 0001
[    3.544792] mmc2: SDHCI controller on 2198000.usdhc [2198000.usdhc] using ADMA
[    3.552740] ledtrig-cpu: registered to indicate activity on CPUs
[    3.558889] hidraw: raw HID events driver (C) Jiri Kosina
[    3.565255] usbcore: registered new interface driver usbhid
[    3.570850] usbhid: USB HID core driver
[    3.575518] ashmem: initialized
[    3.580904] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    3.587582] [drm] No driver support for vblank timestamp query.
[    3.593661] imx-drm display-subsystem: bound imx-ipuv3-crtc.0 (ops ipu_crtc_ops)
[    3.601223] imx-drm display-subsystem: bound imx-ipuv3-crtc.1 (ops ipu_crtc_ops)
[    3.608785] imx-drm display-subsystem: bound imx-ipuv3-crtc.4 (ops ipu_crtc_ops)
[    3.616319] imx-drm display-subsystem: bound imx-ipuv3-crtc.5 (ops ipu_crtc_ops)
[    3.623958] imx-hdmi 120000.hdmi: Detected HDMI controller 0x13:0xa:0xa0:0xc1
[    3.631237] imx-drm display-subsystem: bound 120000.hdmi (ops hdmi_ops)
[    3.638088] [drm] forcing HDMI-A-1 connector ON
[    3.649405] mmc2: host does not support reading read-only switch. assuming write-enable.
[    3.665380] mmc2: new high speed SDHC card at address aaaa
[    3.671344] mmcblk0: mmc2:aaaa SU16G 14.8 GiB 
[    3.678042]  mmcblk0: p1 p2 < p5 >
[    3.685299] usb 1-1: New USB device found, idVendor=0409, idProduct=005a
[    3.692027] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    3.700010] hub 1-1:1.0: USB hub found
[    3.703916] hub 1-1:1.0: 4 ports detected
[    3.985047] usb 1-1.1: new low-speed USB device number 3 using ci_hdrc
[    4.117542] usb 1-1.1: New USB device found, idVendor=0461, idProduct=4d03
[    4.124441] usb 1-1.1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    4.136260] input: HID 0461:4d03 as /devices/soc0/soc/2100000.aips-bus/2184200.usb/ci_hdrc.1/usb1/1-1/1-1.1/1-1.1:1.0/0003:0461:4D03.0001/input/input0
[    4.150241] hid-generic 0003:0461:4D03.0001: input,hidraw0: USB HID v1.00 Mouse [HID 0461:4d03] on usb-ci_hdrc.1-1.1/input0
[    4.255041] usb 1-1.3: new low-speed USB device number 4 using ci_hdrc
[    4.392168] usb 1-1.3: New USB device found, idVendor=04b4, idProduct=0101
[    4.399088] usb 1-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    4.406434] usb 1-1.3: Product: SteelS\xffffffec\xffffff80\xffffff81\xffffff80\xffffff81\xffffffcc\xffffff84\xffffff84\xffffffd0\xffffff89\xffffff89\xffffffcc\xffffff92\xffffff92DATA
[    4.411330] usb 1-1.3: Manufacturer: DATACOMP
[    4.438206] input: DATACOMP SteelS\xffffffec\xffffff80\xffffff81\xffffff80\xffffff81\xffffffcc\xffffff84\xffffff84\xffffffd0\xffffff89\xffffff89\xffffffcc\xffffff92\xffffff92DATA as /devices/soc0/soc/2100000.aips-bus/2184200.usb/ci_hdrc.1/usb1/1-1/1-1.3/1-1.3:1.0/0003:04B4:0101.0002/input/input1
[    4.453337] hid-generic 0003:04B4:0101.0002: input,hidraw1: USB HID v1.00 Keyboard [DATACOMP SteelS\xffffffec\xffffff80\xffffff81\xffffff80\xffffff81\xffffffcc\xffffff84\xffffff84\xffffffd0\xffffff89\xffffff89\xffffffcc\xffffff92\xffffff92DATA] on usb-ci_hdrc.1-1.3/input0
[    4.478521] input: DATACOMP SteelS\xffffffec\xffffff80\xffffff81\xffffff80\xffffff81\xffffffcc\xffffff84\xffffff84\xffffffd0\xffffff89\xffffff89\xffffffcc\xffffff92\xffffff92DATA as /devices/soc0/soc/2100000.aips-bus/2184200.usb/ci_hdrc.1/usb1/1-1/1-1.3/1-1.3:1.1/0003:04B4:0101.0003/input/input2
[    4.493623] hid-generic 0003:04B4:0101.0003: input,hidraw2: USB HID v1.00 Device [DATACOMP SteelS\xffffffec\xffffff80\xffffff81\xffffff80\xffffff81\xffffffcc\xffffff84\xffffff84\xffffffd0\xffffff89\xffffff89\xffffffcc\xffffff92\xffffff92DATA] on usb-ci_hdrc.1-1.3/input1
[    4.585051] usb 1-1.4: new low-speed USB device number 5 using ci_hdrc
[    4.720917] usb 1-1.4: New USB device found, idVendor=0603, idProduct=0002
[    4.727837] usb 1-1.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    4.735182] usb 1-1.4: Product: USB Composite Device
[    4.740164] usb 1-1.4: Manufacturer: SINO WEALTH
[    4.749184] input: SINO WEALTH USB Composite Device as /devices/soc0/soc/2100000.aips-bus/2184200.usb/ci_hdrc.1/usb1/1-1/1-1.4/1-1.4:1.0/0003:0603:0002.0004/input/input3
[    4.764626] hid-generic 0003:0603:0002.0004: input,hidraw3: USB HID v1.10 Keyboard [SINO WEALTH USB Composite Device] on usb-ci_hdrc.1-1.4/input0
[    4.785351] input: SINO WEALTH USB Composite Device as /devices/soc0/soc/2100000.aips-bus/2184200.usb/ci_hdrc.1/usb1/1-1/1-1.4/1-1.4:1.1/0003:0603:0002.0005/input/input4
[    4.801193] hid-generic 0003:0603:0002.0005: input,hiddev0,hidraw4: USB HID v1.10 Mouse [SINO WEALTH USB Composite Device] on usb-ci_hdrc.1-1.4/input1
[    6.234418] Console: switching to colour frame buffer device 128x48
[    6.246062] imx-drm display-subsystem: fb0:  frame buffer device
[    6.252150] imx-drm display-subsystem: registered panic notifier
[    6.324791] [drm] Initialized imx-drm 1.0.0 20120507 on minor 0
[    6.332822] oprofile: using arm/armv7-ca9
[    6.337152] TCP: cubic registered
[    6.340627] NET: Registered protocol family 10
[    6.346212] mip6: Mobile IPv6
[    6.349250] NET: Registered protocol family 17
[    6.353850] Key type dns_resolver registered
[    6.358214] mpls_gso: MPLS GSO support
[    6.364172] ThumbEE CPU extension supported.
[    6.368564] Registering SWP/SWPB emulation handler
[    6.373936] registered taskstats version 1
[    6.380867] Btrfs loaded
[    6.386419] drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
[    6.394862] sr_init: No PMIC hook to init smartreflex
[    6.402113] sr_init: platform driver register failed for SR
[    6.417198] PM: Hibernation image not present or could not be loaded.
[    6.439362] EXT4-fs (mmcblk0p5): mounted filesystem with ordered data mode. Opts: (null)
[    6.449628] VFS: Mounted root (ext4 filesystem) readonly on device 179:5.
[    6.463357] devtmpfs: mounted
[    6.469707] Freeing unused kernel memory: 828K (c0dcd000 - c0e9c000)
[    7.240832] udevd[199]: starting version 175
[    7.884268] snvs_rtc 20cc034.snvs-rtc-lp: rtc core: registered 20cc034.snvs-rtc-lp as rtc0
[    8.151673] sgtl5000 1-000a: sgtl5000 revision 0x11
[    8.164962] imx-sgtl5000 sound: ASoC: CODEC (null) not registered
[    8.186470] imx-sgtl5000 sound: snd_soc_register_card failed (-517)
[    8.201157] platform sound: Driver imx-sgtl5000 requests probe deferral
[    8.214101] imx-spdif sound-spdif: snd-soc-dummy-dai <-> 2004000.spdif mapping ok
[    8.219468] 1-000a: 1200 mV normal 
[    8.219541] sgtl5000 1-000a: Using internal LDO instead of VDDD
[    8.237027] cfg80211: Calling CRDA to update world regulatory domain
[    8.269419] imx-sgtl5000 sound: sgtl5000 <-> 2028000.ssi mapping ok
[    8.288297] brcmfmac: brcmf_sdiod_sgtable_alloc nents=35
[    8.288317] brcmfmac: brcmf_sdio_probe Enter
[    8.293231] brcmfmac: F1 signature read @0x18000000=0x16044330
[    8.293341] brcmfmac: brcmf_bus_change_state 0 -> 2
[    8.293695] brcmfmac: brcmf_chip_recognition found AXI chip: BCM4330, rev=4
[    8.298171] brcmfmac: brcmf_chip_cores_check  [1 ] core 0x800:39 base 0x18000000 wrap 0x18100000
[    8.298201] brcmfmac: brcmf_chip_cores_check  [2 ] core 0x812:25 base 0x18001000 wrap 0x18101000
[    8.298214] brcmfmac: brcmf_chip_cores_check  [3 ] core 0x829:7  base 0x18002000 wrap 0x18102000
[    8.298222] brcmfmac: brcmf_chip_cores_check  [4 ] core 0x82a:3  base 0x18003000 wrap 0x18103000
[    8.298230] brcmfmac: brcmf_chip_cores_check  [5 ] core 0x80e:13 base 0x18004000 wrap 0x18104000
[    8.298237] brcmfmac: brcmf_chip_cores_check  [6 ] core 0x81a:11 base 0x18005000 wrap 0x18105000
[    8.298245] brcmfmac: brcmf_chip_cores_check  [7 ] core 0x135:0  base 0x18108000 wrap 0x18106000
[    8.298493] brcmfmac: brcmf_chip_setup ccrev=39, pmurev=12, pmucaps=0x19583c0c
[    8.298834] brcmfmac: brcmf_sdio_kso_init Enter
[    8.299106] brcmfmac: brcmf_sdio_drivestrengthinit SDIO: 4 mA (req=6 mA) drive strength selected, set to 0x00000001
[    8.302079] brcmfmac: brcmf_attach Enter
[    8.302174] brcmfmac: brcmf_proto_attach Enter
[    8.302518] brcmfmac: brcmf_sdio_probe completed!!
[    8.302538] brcmfmac: brcmf_fw_get_firmwares enter: dev=mmc1:0001:1
[    8.328297] brcmfmac: brcmf_fw_request_code_done enter: dev=mmc1:0001:1
[    8.336630] brcmfmac: brcmf_fw_request_nvram_done enter: dev=mmc1:0001:1
[    8.336742] brcmfmac: brcmf_nvram_handle_key warning: ln=117:col=37: '=' expected, skip invalid key entry
[    8.336756] brcmfmac: brcmf_nvram_handle_key warning: ln=118:col=37: '=' expected, skip invalid key entry
[    8.336793] brcmfmac: brcmf_sdio_firmware_callback Enter: dev=mmc1:0001:1
[    8.336916] brcmfmac: brcmf_chip_enter_download Enter
[    8.339765] brcmfmac: brcmf_sdio_download_code_file Enter
[    8.355128] brcmfmac: brcmf_sdio_verifymemory Compare RAM dl & ul at 0x00000000; size=222126
[    8.394467] brcmfmac: brcmf_sdio_download_nvram Enter
[    8.394846] brcmfmac: brcmf_sdio_verifymemory Compare RAM dl & ul at 0x00047b18; size=1256
[    8.395209] brcmfmac: brcmf_chip_exit_download Enter
[    8.395933] brcmfmac: brcmf_bus_change_state 2 -> 3
[    8.505174] random: nonblocking pool is initialized
[    8.630982] cfg80211: World regulatory domain updated:
[    8.639267] cfg80211:  DFS Master region: unset
[    8.643726] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[    8.650197] brcmfmac: brcmf_sdio_firmware_callback enable F2: err=0
[    8.650292] brcmfmac: brcmf_chip_sr_capable Enter
[    8.650473] brcmfmac: brcmf_bus_start 
[    8.650480] brcmfmac: brcmf_add_if Enter, idx=0, ifidx=0
[    8.650483] brcmfmac: brcmf_add_if allocate netdev interface
[    8.650515] brcmfmac: brcmf_add_if  ==== pid:26, if:wlan%d (00:00:00:00:00:00) created ===
[    8.650518] brcmfmac: brcmf_bus_change_state 3 -> 4
[    8.650532] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.650573] brcmfmac: brcmf_sdio_isr Enter
[    8.650703] brcmfmac: brcmf_sdio_dpc Enter
[    8.650707] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.650784] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.651604] brcmfmac: brcmf_sdio_dpc Dongle reports CHIPACTIVE
[    8.651608] brcmfmac: brcmf_sdio_readframes Enter
[    8.651644] brcmfmac: brcmf_sdio_isr Enter
[    8.651885] brcmfmac: brcmf_sdio_read_control Enter
[    8.651953] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 36 expected 36
[    8.651963] brcmfmac: brcmf_fil_iovar_data_get name=cur_etheraddr, len=6
[    8.651966] brcmutil: data
[    8.651972] 00000000: fc 4d d4 c5 2b 66                                .M..+f
[    8.651979] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.651995] brcmfmac: brcmf_sdio_dpc Enter
[    8.652518] brcmfmac: brcmf_sdio_readframes Enter
[    8.652588] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.652661] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.652809] brcmfmac: brcmf_sdio_isr Enter
[    8.652964] brcmfmac: brcmf_sdio_dpc Enter
[    8.652970] brcmfmac: brcmf_sdio_readframes Enter
[    8.653060] brcmfmac: brcmf_sdio_read_control Enter
[    8.653200] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 276 expected 276
[    8.653207] brcmfmac: brcmf_fil_iovar_data_get name=ver, len=256
[    8.653211] brcmutil: data
[    8.653216] 00000000: 77 6c 30 3a 20 4f 63 74 20 32 35 20 32 30 31 31  wl0: Oct 25 2011
[    8.653220] 00000010: 20 31 39 3a 33 34 3a 31 32 20 76 65 72 73 69 6f   19:34:12 versio
[    8.653223] 00000020: 6e 20 35 2e 39 30 2e 31 32 35 2e 31 30 34 0a 00  n 5.90.125.104..
[    8.653226] 00000030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    8.653230] brcmfmac: brcmf_c_preinit_dcmds: Firmware version = wl0: Oct 25 2011 19:34:12 version 5.90.125.104
[    8.653236] brcmfmac: brcmf_fil_iovar_data_set name=mpc, len=4
[    8.653238] brcmutil: data
[    8.653241] 00000000: 01 00 00 00                                      ....
[    8.653245] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.653250] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.653316] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.653423] brcmfmac: brcmf_sdio_isr Enter
[    8.653544] brcmfmac: brcmf_sdio_dpc Enter
[    8.653552] brcmfmac: brcmf_sdio_readframes Enter
[    8.653614] brcmfmac: brcmf_sdio_read_control Enter
[    8.653666] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 24 expected 24
[    8.653675] brcmfmac: brcmf_fil_iovar_data_set name=bcn_timeout, len=4
[    8.653678] brcmutil: data
[    8.653682] 00000000: 03 00 00 00                                      ....
[    8.653687] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.653712] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.653784] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.653913] brcmfmac: brcmf_sdio_isr Enter
[    8.654033] brcmfmac: brcmf_sdio_dpc Enter
[    8.654040] brcmfmac: brcmf_sdio_readframes Enter
[    8.654103] brcmfmac: brcmf_sdio_read_control Enter
[    8.654158] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 32 expected 32
[    8.654167] brcmfmac: brcmf_fil_iovar_data_set name=roam_off, len=4
[    8.654169] brcmutil: data
[    8.654174] 00000000: 01 00 00 00                                      ....
[    8.654178] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.654202] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.654267] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.654413] brcmfmac: brcmf_sdio_isr Enter
[    8.654529] brcmfmac: brcmf_sdio_dpc Enter
[    8.654535] brcmfmac: brcmf_sdio_readframes Enter
[    8.654598] brcmfmac: brcmf_sdio_read_control Enter
[    8.654644] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 29 expected 29
[    8.654651] brcmfmac: brcmf_fil_iovar_data_set name=join_pref, len=8
[    8.654654] brcmutil: data
[    8.654659] 00000000: 04 02 08 01 01 02 00 00                          ........
[    8.654663] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.654692] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.654813] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.654860] brcmfmac: brcmf_sdio_isr Enter
[    8.654976] brcmfmac: brcmf_sdio_dpc Enter
[    8.654986] brcmfmac: brcmf_sdio_readframes Enter
[    8.655049] brcmfmac: brcmf_sdio_read_control Enter
[    8.655093] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.655099] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.655148] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.655213] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.655325] brcmfmac: brcmf_sdio_isr Enter
[    8.655445] brcmfmac: brcmf_sdio_dpc Enter
[    8.655452] brcmfmac: brcmf_sdio_readframes Enter
[    8.655515] brcmfmac: brcmf_sdio_read_control Enter
[    8.655569] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 44 expected 44
[    8.655577] brcmfmac: brcmf_fil_iovar_data_get name=event_msgs, len=17
[    8.655580] brcmutil: data
[    8.655585] 00000000: 00 00 00 00 00 00 60 00 00 04 00 00 00 00 00 00  ......`.........
[    8.655588] 00000010: 00                                               .
[    8.655593] brcmfmac: brcmf_fil_iovar_data_set name=event_msgs, len=17
[    8.655596] brcmutil: data
[    8.655599] 00000000: 00 00 00 00 00 00 60 00 00 04 00 00 00 00 00 00  ......`.........
[    8.655602] 00000010: 00                                               .
[    8.655606] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.655611] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.655681] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.655795] brcmfmac: brcmf_sdio_isr Enter
[    8.655914] brcmfmac: brcmf_sdio_dpc Enter
[    8.655921] brcmfmac: brcmf_sdio_readframes Enter
[    8.655982] brcmfmac: brcmf_sdio_read_control Enter
[    8.656045] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 44 expected 44
[    8.656054] brcmfmac: brcmf_fil_cmd_int_set cmd=185, value=40
[    8.656058] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.656084] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.656149] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.656226] brcmfmac: brcmf_sdio_isr Enter
[    8.656339] brcmfmac: brcmf_sdio_dpc Enter
[    8.656346] brcmfmac: brcmf_sdio_readframes Enter
[    8.656411] brcmfmac: brcmf_sdio_read_control Enter
[    8.656462] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[    8.656469] brcmfmac: brcmf_fil_cmd_int_set cmd=187, value=40
[    8.656473] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.656503] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.656562] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.656647] brcmfmac: brcmf_sdio_isr Enter
[    8.656762] brcmfmac: brcmf_sdio_dpc Enter
[    8.656769] brcmfmac: brcmf_sdio_readframes Enter
[    8.656831] brcmfmac: brcmf_sdio_read_control Enter
[    8.656883] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[    8.656898] brcmfmac: brcmf_fil_iovar_data_set name=pkt_filter_add, len=22
[    8.656901] brcmutil: data
[    8.656907] 00000000: 64 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  d...............
[    8.656911] 00000010: 01 00 00 00 01 00                                ......
[    8.656915] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.656921] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.656986] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.657282] brcmfmac: brcmf_sdio_isr Enter
[    8.657400] brcmfmac: brcmf_sdio_dpc Enter
[    8.657407] brcmfmac: brcmf_sdio_readframes Enter
[    8.657464] brcmfmac: brcmf_sdio_read_control Enter
[    8.657562] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 53 expected 53
[    8.657573] brcmfmac: brcmf_fil_iovar_data_set name=pkt_filter_enable, len=8
[    8.657575] brcmutil: data
[    8.657580] 00000000: 64 00 00 00 00 00 00 00                          d.......
[    8.657585] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.657591] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.657668] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.657955] brcmfmac: brcmf_sdio_isr Enter
[    8.658083] brcmfmac: brcmf_sdio_dpc Enter
[    8.658090] brcmfmac: brcmf_sdio_readframes Enter
[    8.658161] brcmfmac: brcmf_sdio_read_control Enter
[    8.658211] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 42 expected 42
[    8.658218] brcmfmac: brcmf_fil_iovar_data_set name=pkt_filter_mode, len=4
[    8.658221] brcmutil: data
[    8.658225] 00000000: 01 00 00 00                                      ....
[    8.658230] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.658291] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.658362] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.658656] brcmfmac: brcmf_sdio_isr Enter
[    8.658792] brcmfmac: brcmf_sdio_dpc Enter
[    8.658801] brcmfmac: brcmf_sdio_readframes Enter
[    8.658869] brcmfmac: brcmf_sdio_read_control Enter
[    8.658924] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 36 expected 36
[    8.658934] brcmfmac: brcmf_fil_iovar_data_set name=bus:txglom, len=4
[    8.658937] brcmutil: data
[    8.658942] 00000000: 00 00 00 00                                      ....
[    8.658946] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.658969] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.659029] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.659114] brcmfmac: brcmf_sdio_isr Enter
[    8.659237] brcmfmac: brcmf_sdio_dpc Enter
[    8.659243] brcmfmac: brcmf_sdio_readframes Enter
[    8.659305] brcmfmac: brcmf_sdio_read_control Enter
[    8.659357] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 31 expected 31
[    8.659365] brcmfmac: brcmf_fil_iovar_data_set name=bus:rxglom, len=4
[    8.659368] brcmutil: data
[    8.659373] 00000000: 01 00 00 00                                      ....
[    8.659379] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.659384] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.659445] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.659503] brcmfmac: brcmf_sdio_isr Enter
[    8.659625] brcmfmac: brcmf_sdio_dpc Enter
[    8.659632] brcmfmac: brcmf_sdio_readframes Enter
[    8.659692] brcmfmac: brcmf_sdio_read_control Enter
[    8.659743] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 31 expected 31
[    8.659751] brcmfmac: brcmf_fil_cmd_data Failed err=-23
[    8.659758] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.659796] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.659854] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.660114] brcmfmac: brcmf_sdio_isr Enter
[    8.660244] brcmfmac: brcmf_sdio_dpc Enter
[    8.660251] brcmfmac: brcmf_sdio_readframes Enter
[    8.660314] brcmfmac: brcmf_sdio_read_control Enter
[    8.660364] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 26 expected 26
[    8.660370] brcmfmac: brcmf_fil_cmd_data Failed err=-23
[    8.660374] brcmfmac: brcmf_fil_iovar_data_get name=mchan, len=4
[    8.660376] brcmutil: data
[    8.660383] 00000000: 80 5d be eb                                      .]..
[    8.660388] brcmfmac: brcmf_feat_iovar_int_get MCHAN feature check failed: -23
[    8.660452] brcmfmac: brcmf_fws_init FWS queueing will be avoided
[    8.660460] brcmfmac: brcmf_fws_macdesc_init enter: desc ebe15030 ea=fc:4d:d4:c5:2b:66, ifidx=0
[    8.660466] brcmfmac: brcmf_fws_add_interface added MACIF:0
[    8.660670] brcmfmac: brcmf_alloc_vif allocating virtual interface (size=2700)
[    8.660699] brcmfmac: brcmf_fweh_register event handler registered for LINK
[    8.660703] brcmfmac: brcmf_fweh_register event handler registered for DEAUTH_IND
[    8.660707] brcmfmac: brcmf_fweh_register event handler registered for DEAUTH
[    8.660710] brcmfmac: brcmf_fweh_register event handler registered for DISASSOC_IND
[    8.660713] brcmfmac: brcmf_fweh_register event handler registered for ASSOC_IND
[    8.660719] brcmfmac: brcmf_fweh_register event handler registered for REASSOC_IND
[    8.660722] brcmfmac: brcmf_fweh_register event handler registered for ROAM
[    8.660725] brcmfmac: brcmf_fweh_register event handler registered for MIC_ERROR
[    8.660728] brcmfmac: brcmf_fweh_register event handler registered for SET_SSID
[    8.660733] brcmfmac: brcmf_fweh_register event handler registered for PFN_NET_FOUND
[    8.660737] brcmfmac: brcmf_fweh_register event handler registered for IF
[    8.660741] brcmfmac: brcmf_fweh_register event handler registered for P2P_PROBEREQ_MSG
[    8.660745] brcmfmac: brcmf_fweh_register event handler registered for P2P_DISC_LISTEN_COMPLETE
[    8.660758] brcmfmac: brcmf_fweh_register event handler registered for ACTION_FRAME_RX
[    8.660767] brcmfmac: brcmf_fweh_register event handler registered for ACTION_FRAME_COMPLETE
[    8.660772] brcmfmac: brcmf_fweh_register event handler registered for ACTION_FRAME_OFF_CHAN_COMPLETE
[    8.660776] brcmfmac: brcmf_fweh_register event handler registered for ESCAN_RESULT
[    8.660783] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.660789] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.660872] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.660941] brcmfmac: brcmf_sdio_isr Enter
[    8.661072] brcmfmac: brcmf_sdio_dpc Enter
[    8.661080] brcmfmac: brcmf_sdio_readframes Enter
[    8.661147] brcmfmac: brcmf_sdio_read_control Enter
[    8.661222] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[    8.661229] brcmfmac: brcmf_fil_cmd_int_get cmd=1, value=1
[    8.661237] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.661266] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.661340] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.661605] brcmfmac: brcmf_sdio_isr Enter
[    8.661773] brcmfmac: brcmf_sdio_dpc Enter
[    8.661782] brcmfmac: brcmf_sdio_readframes Enter
[    8.661872] brcmfmac: brcmf_sdio_read_control Enter
[    8.661947] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 28 expected 28
[    8.661954] brcmfmac: brcmf_fil_cmd_data Failed err=-23
[    8.661958] brcmfmac: brcmf_fil_iovar_data_get name=vhtmode, len=4
[    8.661961] brcmutil: data
[    8.661967] 00000000: 00 00 00 00                                      ....
[    8.661974] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.662004] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.662069] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.662196] brcmfmac: brcmf_sdio_isr Enter
[    8.662317] brcmfmac: brcmf_sdio_dpc Enter
[    8.662324] brcmfmac: brcmf_sdio_readframes Enter
[    8.662389] brcmfmac: brcmf_sdio_read_control Enter
[    8.662440] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 26 expected 26
[    8.662448] brcmfmac: brcmf_fil_iovar_data_get name=nmode, len=4
[    8.662451] brcmutil: data
[    8.662455] 00000000: 01 00 00 00                                      ....
[    8.662461] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.662483] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.662546] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.662840] brcmfmac: brcmf_sdio_isr Enter
[    8.662971] brcmfmac: brcmf_sdio_dpc Enter
[    8.662978] brcmfmac: brcmf_sdio_readframes Enter
[    8.663045] brcmfmac: brcmf_sdio_read_control Enter
[    8.663095] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 27 expected 27
[    8.663104] brcmfmac: brcmf_fil_cmd_data Failed err=-23
[    8.663109] brcmfmac: brcmf_fil_iovar_data_get name=bw_cap, len=4
[    8.663111] brcmutil: data
[    8.663116] 00000000: 02 00 00 00                                      ....
[    8.663119] brcmfmac: brcmf_get_bwcap fallback to mimo_bw_cap info
[    8.663124] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.663146] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.663214] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.663378] brcmfmac: brcmf_sdio_isr Enter
[    8.663502] brcmfmac: brcmf_sdio_dpc Enter
[    8.663509] brcmfmac: brcmf_sdio_readframes Enter
[    8.663581] brcmfmac: brcmf_sdio_read_control Enter
[    8.663638] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 32 expected 32
[    8.663645] brcmfmac: brcmf_fil_iovar_data_get name=mimo_bw_cap, len=4
[    8.663650] brcmutil: data
[    8.663654] 00000000: 00 00 00 00                                      ....
[    8.663660] brcmfmac: brcmf_setup_wiphybands nmode=1, vhtmode=0, bw_cap=(1, 1)
[    8.663664] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.663686] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.663758] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.663879] brcmfmac: brcmf_sdio_isr Enter
[    8.664073] brcmfmac: brcmf_sdio_dpc Enter
[    8.664082] brcmfmac: brcmf_sdio_readframes Enter
[    8.664342] brcmfmac: brcmf_sdio_read_control Enter
[    8.664409] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 28 expected 28
[    8.664417] brcmfmac: brcmf_fil_iovar_data_get name=rxchain, len=4
[    8.664419] brcmutil: data
[    8.664424] 00000000: 01 00 00 00                                      ....
[    8.664429] brcmfmac: brcmf_setup_wiphybands nchain=1
[    8.664439] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.664446] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.664596] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.666618] brcmfmac: brcmf_sdio_isr Enter
[    8.666812] brcmfmac: brcmf_sdio_dpc Enter
[    8.666822] brcmfmac: brcmf_sdio_readframes Enter
[    8.666889] brcmfmac: brcmf_sdio_read_control Enter
[    8.667104] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 1562 expected 1562
[    8.667114] brcmfmac: brcmf_fil_iovar_data_get name=chanspecs, len=1536
[    8.667117] brcmutil: data
[    8.667122] 00000000: 11 00 00 00 01 2b 00 00 02 2b 00 00 03 2b 00 00  .....+...+...+..
[    8.667127] 00000010: 04 2b 00 00 05 2b 00 00 06 2b 00 00 07 2b 00 00  .+...+...+...+..
[    8.667130] 00000020: 08 2b 00 00 09 2b 00 00 0a 2b 00 00 0b 2b 00 00  .+...+...+...+..
[    8.667133] 00000030: 0c 2b 00 00 0d 2b 00 00 24 1b 00 00 28 1b 00 00  .+...+..$...(...
[    8.667138] ------------[ cut here ]------------
[    8.667158] WARNING: CPU: 1 PID: 38 at drivers/net/wireless/brcm80211/brcmutil/d11.c:128 brcmu_d11n_decchspec+0xfc/0x10c [brcmutil]()
[    8.667194] Modules linked in: brcmfmac brcmutil cfg80211 snd_soc_imx_spdif snd_soc_imx_sgtl5000 snd_soc_imx_audmux snd_soc_sgtl5000 snd_soc_fsl_ssi snd_soc_fsl_spdif imx_pcm_fiq imx_pcm_dma snd_soc_core snd_compress snd_pcm_dmaengine snd_pcm snd_seq snd_seq_device snd_timer snd soundcore rtc_snvs
[    8.667202] CPU: 1 PID: 38 Comm: kworker/1:1 Not tainted 3.17.0-rc6-armv7-x2 #3
[    8.667222] Workqueue: events request_firmware_work_func
[    8.667246] [<c0018e78>] (unwind_backtrace) from [<c0013978>] (show_stack+0x20/0x24)
[    8.667261] [<c0013978>] (show_stack) from [<c094cd68>] (dump_stack+0x8c/0x9c)
[    8.667284] [<c094cd68>] (dump_stack) from [<c0053f48>] (warn_slowpath_common+0x80/0x9c)
[    8.667295] [<c0053f48>] (warn_slowpath_common) from [<c0054020>] (warn_slowpath_null+0x2c/0x34)
[    8.667308] [<c0054020>] (warn_slowpath_null) from [<bf305b58>] (brcmu_d11n_decchspec+0xfc/0x10c [brcmutil])
[    8.667473] [<bf305b58>] (brcmu_d11n_decchspec [brcmutil]) from [<bf31b798>] (brcmf_cfg80211_attach+0x6e8/0x118c [brcmfmac])
[    8.667628] [<bf31b798>] (brcmf_cfg80211_attach [brcmfmac]) from [<bf32a408>] (brcmf_bus_start+0xe0/0x298 [brcmfmac])
[    8.667798] [<bf32a408>] (brcmf_bus_start [brcmfmac]) from [<bf32f0bc>] (brcmf_sdio_firmware_callback+0x48c/0x628 [brcmfmac])
[    8.667965] [<bf32f0bc>] (brcmf_sdio_firmware_callback [brcmfmac]) from [<bf32acb0>] (brcmf_fw_request_nvram_done+0x144/0x1dc [brcmfmac])
[    8.668060] [<bf32acb0>] (brcmf_fw_request_nvram_done [brcmfmac]) from [<c0603f08>] (request_firmware_work_func+0x40/0x60)
[    8.668083] [<c0603f08>] (request_firmware_work_func) from [<c006b2c0>] (process_one_work+0x158/0x3c4)
[    8.668105] [<c006b2c0>] (process_one_work) from [<c006bc44>] (worker_thread+0x68/0x534)
[    8.668122] [<c006bc44>] (worker_thread) from [<c00705bc>] (kthread+0xe8/0x100)
[    8.668140] [<c00705bc>] (kthread) from [<c000f858>] (ret_from_fork+0x14/0x20)
[    8.668145] ---[ end trace dfea49328ba94d5f ]---
[    8.668148] ------------[ cut here ]------------
[    8.668162] WARNING: CPU: 1 PID: 38 at drivers/net/wireless/brcm80211/brcmutil/d11.c:140 brcmu_d11n_decchspec+0x8c/0x10c [brcmutil]()
[    8.668196] Modules linked in: brcmfmac brcmutil cfg80211 snd_soc_imx_spdif snd_soc_imx_sgtl5000 snd_soc_imx_audmux snd_soc_sgtl5000 snd_soc_fsl_ssi snd_soc_fsl_spdif imx_pcm_fiq imx_pcm_dma snd_soc_core snd_compress snd_pcm_dmaengine snd_pcm snd_seq snd_seq_device snd_timer snd soundcore rtc_snvs
[    8.668202] CPU: 1 PID: 38 Comm: kworker/1:1 Tainted: G        W      3.17.0-rc6-armv7-x2 #3
[    8.668212] Workqueue: events request_firmware_work_func
[    8.668228] [<c0018e78>] (unwind_backtrace) from [<c0013978>] (show_stack+0x20/0x24)
[    8.668239] [<c0013978>] (show_stack) from [<c094cd68>] (dump_stack+0x8c/0x9c)
[    8.668267] [<c094cd68>] (dump_stack) from [<c0053f48>] (warn_slowpath_common+0x80/0x9c)
[    8.668277] [<c0053f48>] (warn_slowpath_common) from [<c0054020>] (warn_slowpath_null+0x2c/0x34)
[    8.668290] [<c0054020>] (warn_slowpath_null) from [<bf305ae8>] (brcmu_d11n_decchspec+0x8c/0x10c [brcmutil])
[    8.668390] [<bf305ae8>] (brcmu_d11n_decchspec [brcmutil]) from [<bf31b798>] (brcmf_cfg80211_attach+0x6e8/0x118c [brcmfmac])
[    8.668543] [<bf31b798>] (brcmf_cfg80211_attach [brcmfmac]) from [<bf32a408>] (brcmf_bus_start+0xe0/0x298 [brcmfmac])
[    8.668726] [<bf32a408>] (brcmf_bus_start [brcmfmac]) from [<bf32f0bc>] (brcmf_sdio_firmware_callback+0x48c/0x628 [brcmfmac])
[    8.668883] [<bf32f0bc>] (brcmf_sdio_firmware_callback [brcmfmac]) from [<bf32acb0>] (brcmf_fw_request_nvram_done+0x144/0x1dc [brcmfmac])
[    8.668967] [<bf32acb0>] (brcmf_fw_request_nvram_done [brcmfmac]) from [<c0603f08>] (request_firmware_work_func+0x40/0x60)
[    8.668982] [<c0603f08>] (request_firmware_work_func) from [<c006b2c0>] (process_one_work+0x158/0x3c4)
[    8.668993] [<c006b2c0>] (process_one_work) from [<c006bc44>] (worker_thread+0x68/0x534)
[    8.669002] [<c006bc44>] (worker_thread) from [<c00705bc>] (kthread+0xe8/0x100)
[    8.669013] [<c00705bc>] (kthread) from [<c000f858>] (ret_from_fork+0x14/0x20)
[    8.669019] ---[ end trace dfea49328ba94d60 ]---
[    8.669034] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.669042] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.669141] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.669237] brcmfmac: brcmf_sdio_isr Enter
[    8.669375] brcmfmac: brcmf_sdio_dpc Enter
[    8.669383] brcmfmac: brcmf_sdio_readframes Enter
[    8.669456] brcmfmac: brcmf_sdio_read_control Enter
[    8.669517] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.669525] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.669528] brcmutil: data
[    8.669533] 00000000: 03 00 00 00                                      ....
[    8.669543] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.669548] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.669616] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.669744] brcmfmac: brcmf_sdio_isr Enter
[    8.669892] brcmfmac: brcmf_sdio_dpc Enter
[    8.669900] brcmfmac: brcmf_sdio_readframes Enter
[    8.669989] brcmfmac: brcmf_sdio_read_control Enter
[    8.670051] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.670058] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.670060] brcmutil: data
[    8.670065] 00000000: 03 00 00 00                                      ....
[    8.670073] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.670102] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.670174] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.670280] brcmfmac: brcmf_sdio_isr Enter
[    8.670412] brcmfmac: brcmf_sdio_dpc Enter
[    8.670419] brcmfmac: brcmf_sdio_readframes Enter
[    8.670491] brcmfmac: brcmf_sdio_read_control Enter
[    8.670545] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.670553] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.670556] brcmutil: data
[    8.670561] 00000000: 03 00 00 00                                      ....
[    8.670567] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.670591] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.670657] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.670763] brcmfmac: brcmf_sdio_isr Enter
[    8.670892] brcmfmac: brcmf_sdio_dpc Enter
[    8.670899] brcmfmac: brcmf_sdio_readframes Enter
[    8.671887] brcmfmac: brcmf_sdio_read_control Enter
[    8.671939] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.671950] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.671954] brcmutil: data
[    8.671959] 00000000: 03 00 00 00                                      ....
[    8.671966] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.672028] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.672108] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.672217] brcmfmac: brcmf_sdio_isr Enter
[    8.672340] brcmfmac: brcmf_sdio_dpc Enter
[    8.672351] brcmfmac: brcmf_sdio_readframes Enter
[    8.672409] brcmfmac: brcmf_sdio_read_control Enter
[    8.672463] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.672471] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.672475] brcmutil: data
[    8.672480] 00000000: 03 00 00 00                                      ....
[    8.672489] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.672496] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.672554] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.672668] brcmfmac: brcmf_sdio_isr Enter
[    8.672794] brcmfmac: brcmf_sdio_dpc Enter
[    8.672803] brcmfmac: brcmf_sdio_readframes Enter
[    8.672899] brcmfmac: brcmf_sdio_read_control Enter
[    8.672971] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.672979] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.672982] brcmutil: data
[    8.672988] 00000000: 03 00 00 00                                      ....
[    8.672996] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.673030] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.673114] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.673226] brcmfmac: brcmf_sdio_isr Enter
[    8.673370] brcmfmac: brcmf_sdio_dpc Enter
[    8.673378] brcmfmac: brcmf_sdio_readframes Enter
[    8.673457] brcmfmac: brcmf_sdio_read_control Enter
[    8.673536] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.673543] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.673546] brcmutil: data
[    8.673551] 00000000: 03 00 00 00                                      ....
[    8.673559] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.673596] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.673667] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.673783] brcmfmac: brcmf_sdio_isr Enter
[    8.673916] brcmfmac: brcmf_sdio_dpc Enter
[    8.673924] brcmfmac: brcmf_sdio_readframes Enter
[    8.674031] brcmfmac: brcmf_sdio_read_control Enter
[    8.674091] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.674098] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.674101] brcmutil: data
[    8.674106] 00000000: 03 00 00 00                                      ....
[    8.674115] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.674153] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.674220] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.674338] brcmfmac: brcmf_sdio_isr Enter
[    8.674470] brcmfmac: brcmf_sdio_dpc Enter
[    8.674477] brcmfmac: brcmf_sdio_readframes Enter
[    8.674546] brcmfmac: brcmf_sdio_read_control Enter
[    8.674599] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.674609] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.674612] brcmutil: data
[    8.674617] 00000000: 03 00 00 00                                      ....
[    8.674624] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.674654] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.674721] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.674848] brcmfmac: brcmf_sdio_isr Enter
[    8.674962] brcmfmac: brcmf_sdio_dpc Enter
[    8.674970] brcmfmac: brcmf_sdio_readframes Enter
[    8.675031] brcmfmac: brcmf_sdio_read_control Enter
[    8.675098] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.675106] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.675108] brcmutil: data
[    8.675113] 00000000: 03 00 00 00                                      ....
[    8.675122] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.675128] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.675197] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.675312] brcmfmac: brcmf_sdio_isr Enter
[    8.675582] brcmfmac: brcmf_sdio_dpc Enter
[    8.675590] brcmfmac: brcmf_sdio_readframes Enter
[    8.675671] brcmfmac: brcmf_sdio_read_control Enter
[    8.675730] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.675740] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.675743] brcmutil: data
[    8.675749] 00000000: 03 00 00 00                                      ....
[    8.675757] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.675766] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.675831] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.675941] brcmfmac: brcmf_sdio_isr Enter
[    8.676073] brcmfmac: brcmf_sdio_dpc Enter
[    8.676080] brcmfmac: brcmf_sdio_readframes Enter
[    8.676145] brcmfmac: brcmf_sdio_read_control Enter
[    8.676200] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.676208] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.676211] brcmutil: data
[    8.676215] 00000000: 03 00 00 00                                      ....
[    8.676224] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.676252] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.676320] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.676434] brcmfmac: brcmf_sdio_isr Enter
[    8.676572] brcmfmac: brcmf_sdio_dpc Enter
[    8.676579] brcmfmac: brcmf_sdio_readframes Enter
[    8.676658] brcmfmac: brcmf_sdio_read_control Enter
[    8.676721] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.676728] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.676731] brcmutil: data
[    8.676735] 00000000: 03 00 00 00                                      ....
[    8.676746] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.676775] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.676840] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.676972] brcmfmac: brcmf_sdio_isr Enter
[    8.677152] brcmfmac: brcmf_sdio_dpc Enter
[    8.677185] brcmfmac: brcmf_sdio_readframes Enter
[    8.677343] brcmfmac: brcmf_sdio_read_control Enter
[    8.677424] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.677431] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.677434] brcmutil: data
[    8.677439] 00000000: 07 00 00 00                                      ....
[    8.677452] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.677545] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.677623] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.677732] brcmfmac: brcmf_sdio_isr Enter
[    8.677858] brcmfmac: brcmf_sdio_dpc Enter
[    8.677865] brcmfmac: brcmf_sdio_readframes Enter
[    8.677936] brcmfmac: brcmf_sdio_read_control Enter
[    8.677984] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.677992] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.677996] brcmutil: data
[    8.678000] 00000000: 07 00 00 00                                      ....
[    8.678007] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.678036] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.678102] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.678221] brcmfmac: brcmf_sdio_isr Enter
[    8.678541] brcmfmac: brcmf_sdio_dpc Enter
[    8.678548] brcmfmac: brcmf_sdio_readframes Enter
[    8.678626] brcmfmac: brcmf_sdio_read_control Enter
[    8.678683] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.678693] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.678696] brcmutil: data
[    8.678700] 00000000: 07 00 00 00                                      ....
[    8.678708] brcmfmac: brcmf_sdio_bus_txctl Enter
[    8.678734] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    8.678804] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    8.678943] brcmfmac: brcmf_sdio_isr Enter
[    8.680229] brcmfmac: brcmf_sdio_dpc Enter
[    8.680237] brcmfmac: brcmf_sdio_readframes Enter
[    8.680328] brcmfmac: brcmf_sdio_read_control Enter
[    8.680388] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 34 expected 34
[    8.680397] brcmfmac: brcmf_fil_bsscfg_data_get bssidx=0, name=per_chan_info, len=4
[    8.680401] brcmutil: data
[    8.680407] 00000000: 07 00 00 00                                      ....
[    8.680419] brcmfmac: brcmf_cfg80211_attach Registering custom regulatory
[    9.202144] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    9.213039] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    9.223880] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (N/A, 2000 mBm), (N/A)
[    9.234696] cfg80211:   (5170000 KHz - 5250000 KHz @ 80000 KHz), (N/A, 2000 mBm), (N/A)
[    9.245458] cfg80211:   (5735000 KHz - 5835000 KHz @ 80000 KHz), (N/A, 2000 mBm), (N/A)
[    9.256214] cfg80211:   (57240000 KHz - 63720000 KHz @ 2160000 KHz), (N/A, 0 mBm), (N/A)
[    9.267520] brcmfmac: brcmf_sdio_bus_txctl Enter
[    9.295616] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    9.295714] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    9.295772] brcmfmac: brcmf_sdio_isr Enter
[    9.295900] brcmfmac: brcmf_sdio_dpc Enter
[    9.295953] brcmfmac: brcmf_sdio_isr Enter
[    9.296086] brcmfmac: brcmf_sdio_dpc Dongle reports CHIPACTIVE
[    9.296098] brcmfmac: brcmf_sdio_readframes Enter
[    9.296162] brcmfmac: brcmf_sdio_read_control Enter
[    9.296237] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 27 expected 27
[    9.296252] brcmfmac: brcmf_fil_cmd_data Failed err=-23
[    9.296260] brcmfmac: brcmf_fil_iovar_data_get name=bw_cap, len=4
[    9.296266] brcmutil: data
[    9.296274] 00000000: 01 00 00 00                                      ....
[    9.296281] brcmfmac: brcmf_enable_bw40_2g fallback to mimo_bw_cap
[    9.296289] brcmfmac: brcmf_fil_iovar_data_set name=mimo_bw_cap, len=4
[    9.296294] brcmutil: data
[    9.296302] 00000000: 01 00 00 00                                      ....
[    9.296311] brcmfmac: brcmf_sdio_bus_txctl Enter
[    9.296332] brcmfmac: brcmf_sdio_dpc Enter
[    9.296351] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    9.296409] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    9.296534] brcmfmac: brcmf_sdio_isr Enter
[    9.296633] brcmfmac: brcmf_sdio_dpc Enter
[    9.296643] brcmfmac: brcmf_sdio_readframes Enter
[    9.296698] brcmfmac: brcmf_sdio_read_control Enter
[    9.296753] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 32 expected 32
[    9.296769] brcmfmac: brcmf_fil_cmd_data Failed err=-23
[    9.296777] brcmfmac: brcmf_btcoex_attach enter
[    9.296785] brcmfmac: brcmf_fil_iovar_data_set name=tdls_enable, len=4
[    9.296790] brcmutil: data
[    9.296797] 00000000: 01 00 00 00                                      ....
[    9.296804] brcmfmac: brcmf_sdio_bus_txctl Enter
[    9.296831] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    9.296883] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    9.297134] brcmfmac: brcmf_sdio_isr Enter
[    9.297230] brcmfmac: brcmf_sdio_dpc Enter
[    9.297240] brcmfmac: brcmf_sdio_readframes Enter
[    9.297294] brcmfmac: brcmf_sdio_read_control Enter
[    9.297349] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 32 expected 32
[    9.297363] brcmfmac: brcmf_fil_cmd_data Failed err=-23
[    9.297370] brcmfmac: brcmf_cfg80211_attach TDLS not enabled (-23)
[    9.297380] brcmfmac: brcmf_fweh_activate_events enable event SET_SSID
[    9.297387] brcmfmac: brcmf_fweh_activate_events enable event DEAUTH
[    9.297393] brcmfmac: brcmf_fweh_activate_events enable event DEAUTH_IND
[    9.297399] brcmfmac: brcmf_fweh_activate_events enable event ASSOC_IND
[    9.297406] brcmfmac: brcmf_fweh_activate_events enable event REASSOC_IND
[    9.297412] brcmfmac: brcmf_fweh_activate_events enable event DISASSOC_IND
[    9.297418] brcmfmac: brcmf_fweh_activate_events enable event LINK
[    9.297424] brcmfmac: brcmf_fweh_activate_events enable event MIC_ERROR
[    9.297430] brcmfmac: brcmf_fweh_activate_events enable event ROAM
[    9.297438] brcmfmac: brcmf_fweh_activate_events enable event PFN_NET_FOUND
[    9.297445] brcmfmac: brcmf_fweh_activate_events enable event IF
[    9.297451] brcmfmac: brcmf_fweh_activate_events enable event P2P_DISC_LISTEN_COMPLETE
[    9.297457] brcmfmac: brcmf_fweh_activate_events enable event ACTION_FRAME_COMPLETE
[    9.297464] brcmfmac: brcmf_fweh_activate_events enable event ESCAN_RESULT
[    9.297470] brcmfmac: brcmf_fweh_activate_events enable event ACTION_FRAME_OFF_CHAN_COMPLETE
[    9.297476] brcmfmac: brcmf_fweh_activate_events enable event P2P_PROBEREQ_MSG
[    9.297483] brcmfmac: brcmf_fweh_activate_events enable event ACTION_FRAME_RX
[    9.297489] brcmfmac: brcmf_fweh_activate_events enable event IF
[    9.297495] brcmfmac: brcmf_fil_iovar_data_set name=event_msgs, len=17
[    9.297500] brcmutil: data
[    9.297507] 00000000: ff 15 0b 00 02 03 c0 13 60 09 00 00 00 ec 9d b3  ........`.......
[    9.297514] 00000010: ec                                               .
[    9.297520] brcmfmac: brcmf_sdio_bus_txctl Enter
[    9.297548] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[    9.297604] brcmfmac: brcmf_sdio_bus_rxctl Enter
[    9.297714] brcmfmac: brcmf_sdio_isr Enter
[    9.297813] brcmfmac: brcmf_sdio_dpc Enter
[    9.297823] brcmfmac: brcmf_sdio_readframes Enter
[    9.297876] brcmfmac: brcmf_sdio_read_control Enter
[    9.297930] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 44 expected 44
[    9.297946] brcmfmac: brcmf_net_attach Enter, idx=0 mac=fc:4d:d4:c5:2b:66
[    9.298620] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[    9.298655] brcmfmac: brcmf_net_attach wlan0: Broadcom Dongle Host Driver
[   10.309372] EXT4-fs (mmcblk0p5): re-mounted. Opts: (null)
[   10.471555] EXT4-fs (mmcblk0p5): re-mounted. Opts: errors=remount-ro
[   10.750107] loop: module loaded
[   12.198301] EXT4-fs (mmcblk0p1): mounting ext2 file system using the ext4 subsystem
[   12.214301] EXT4-fs (mmcblk0p1): mounted filesystem without journal. Opts: (null)
[   13.016438] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   14.208955] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   14.209007] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   14.584652] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   18.384229] zram: Created 4 device(s) ...
[   18.602185] zram0: detected capacity change from 0 to 527245312
[   18.605456] zram1: detected capacity change from 0 to 527245312
[   18.608619] zram2: detected capacity change from 0 to 527245312
[   18.613187] zram3: detected capacity change from 0 to 527245312
[   19.273758] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   19.273856] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   19.345217] Bluetooth: Core ver 2.19
[   19.352959] NET: Registered protocol family 31
[   19.361112] Bluetooth: HCI device and connection manager initialized
[   19.371102] Bluetooth: HCI socket layer initialized
[   19.380603] Bluetooth: L2CAP socket layer initialized
[   19.389801] Bluetooth: SCO socket layer initialized
[   19.423502] Bluetooth: RFCOMM TTY layer initialized
[   19.423538] Bluetooth: RFCOMM socket layer initialized
[   19.423566] Bluetooth: RFCOMM ver 1.11
[   19.455197] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   19.455202] Bluetooth: BNEP filters: protocol multicast
[   19.455235] Bluetooth: BNEP socket layer initialized
[   19.578975] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   19.579163] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   19.621390] Adding 514884k swap on /dev/zram0.  Priority:100 extents:1 across:514884k SSFS
[   19.789953] Adding 514884k swap on /dev/zram1.  Priority:100 extents:1 across:514884k SSFS
[   19.905471] Adding 514884k swap on /dev/zram2.  Priority:100 extents:1 across:514884k SSFS
[   20.021249] Adding 514884k swap on /dev/zram3.  Priority:100 extents:1 across:514884k SSFS
[   20.318397] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.318486] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.319478] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.319550] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.319837] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.319890] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.425200] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.425326] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.426980] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.427048] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.427358] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.427416] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.427760] IPv6: ADDRCONF(NETDEV_UP): usb0: link is not ready
[   20.435745] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.435803] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.436012] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.436054] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.436264] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.436307] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.436502] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.436544] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.436741] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.436782] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.437268] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.437319] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.437568] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.437612] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.438087] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.438131] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.506082] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.506138] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.506701] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.506754] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.506950] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.506992] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.575185] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.575296] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.594413] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.594538] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.595062] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.595131] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.675333] fec 2188000.ethernet eth0: Freescale FEC PHY driver [Generic PHY] (mii_bus:phy_addr=2188000.ethernet:01, irq=-1)
[   20.689292] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   20.698255] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.698353] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.698702] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.698760] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.698993] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.699059] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.699268] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.699315] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.699543] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.699590] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.700136] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.700199] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.700435] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.700486] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.700823] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.700865] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.703195] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.703279] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.706078] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.706142] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.706414] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.706464] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.706627] brcmfmac: brcmf_netdev_open Enter, idx=0
[   20.706641] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.734998] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.735089] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.735146] brcmfmac: brcmf_sdio_isr Enter
[   20.735259] brcmfmac: brcmf_sdio_dpc Enter
[   20.735317] brcmfmac: brcmf_sdio_isr Enter
[   20.735426] brcmfmac: brcmf_sdio_dpc Dongle reports CHIPACTIVE
[   20.735435] brcmfmac: brcmf_sdio_readframes Enter
[   20.735493] brcmfmac: brcmf_sdio_read_control Enter
[   20.735572] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 27 expected 27
[   20.735583] brcmfmac: brcmf_sdio_dpc Enter
[   20.735588] brcmfmac: brcmf_fil_iovar_data_get name=toe_ol, len=4
[   20.735595] brcmutil: data
[   20.735600] 00000000: 00 00 00 00                                      ....
[   20.735608] brcmfmac: brcmf_fil_cmd_int_set cmd=2, value=0
[   20.735613] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.735618] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.735695] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.820144] brcmfmac: brcmf_sdio_isr Enter
[   20.820328] brcmfmac: brcmf_sdio_dpc Enter
[   20.820462] brcmfmac: brcmf_sdio_readframes Enter
[   20.820546] brcmfmac: brcmf_sdio_read_control Enter
[   20.820734] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[   20.820749] brcmfmac: brcmf_fil_cmd_int_set cmd=185, value=40
[   20.820757] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.820803] brcmfmac: brcmf_fweh_event_worker event IF (54) ifidx 0 bsscfg 0 addr fc:4d:d4:c5:2b:66
[   20.820823] brcmfmac: brcmf_fweh_event_worker   version 2 flags 0 status 0 reason 0
[   20.820832] brcmutil: event payload, len=5
[   20.820845] 00000000: 00 01 00 00 00                                   .....
[   20.820857] brcmfmac: brcmf_fweh_handle_if_event action: 1 idx: 0 bsscfg: 0 flags: 0 role: 0
[   20.820869] brcmfmac: brcmf_fweh_handle_if_event adding wl0 (fc:4d:d4:c5:2b:66)
[   20.820879] brcmfmac: brcmf_add_if Enter, idx=0, ifidx=0
[   20.820888] brcmfmac: brcmf_add_if: ERROR: netdev:wlan0 already exists
[   20.829489] brcmfmac: brcmf_add_if: ignore IF event
[   20.831147] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.831232] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.831307] brcmfmac: brcmf_sdio_isr Enter
[   20.831420] brcmfmac: brcmf_sdio_dpc Enter
[   20.831427] brcmfmac: brcmf_sdio_readframes Enter
[   20.831489] brcmfmac: brcmf_sdio_read_control Enter
[   20.831562] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[   20.831574] brcmfmac: brcmf_fil_cmd_int_set cmd=187, value=40
[   20.831578] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.831603] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.831665] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.831746] brcmfmac: brcmf_sdio_isr Enter
[   20.831858] brcmfmac: brcmf_sdio_dpc Enter
[   20.831864] brcmfmac: brcmf_sdio_readframes Enter
[   20.831922] brcmfmac: brcmf_sdio_read_control Enter
[   20.831983] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[   20.831994] brcmfmac: brcmf_fil_cmd_int_set cmd=258, value=120
[   20.831999] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.832022] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.832082] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.832165] brcmfmac: brcmf_sdio_isr Enter
[   20.832279] brcmfmac: brcmf_sdio_dpc Enter
[   20.832284] brcmfmac: brcmf_sdio_readframes Enter
[   20.832345] brcmfmac: brcmf_sdio_read_control Enter
[   20.832405] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[   20.832416] brcmfmac: brcmf_fil_cmd_int_set cmd=86, value=2
[   20.832420] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.832444] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.832504] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.832848] brcmfmac: brcmf_sdio_isr Enter
[   20.832957] brcmfmac: brcmf_sdio_dpc Enter
[   20.832963] brcmfmac: brcmf_sdio_readframes Enter
[   20.833023] brcmfmac: brcmf_sdio_read_control Enter
[   20.833084] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[   20.833094] brcmfmac: brcmf_config_dongle power save set to enabled
[   20.833098] brcmfmac: brcmf_dongle_roam Internal Roaming = On
[   20.833105] brcmfmac: brcmf_fil_iovar_data_set name=roam_off, len=4
[   20.833108] brcmutil: data
[   20.833112] 00000000: 00 00 00 00                                      ....
[   20.833117] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.833142] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.833205] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.833345] brcmfmac: brcmf_sdio_isr Enter
[   20.833460] brcmfmac: brcmf_sdio_dpc Enter
[   20.833467] brcmfmac: brcmf_sdio_readframes Enter
[   20.833527] brcmfmac: brcmf_sdio_read_control Enter
[   20.833587] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 29 expected 29
[   20.833598] brcmfmac: brcmf_fil_cmd_data_set cmd=55, len=8
[   20.833600] brcmutil: data
[   20.833605] 00000000: b5 ff ff ff 03 00 00 00                          ........
[   20.833608] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.833633] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.833695] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.833754] brcmfmac: brcmf_sdio_isr Enter
[   20.833866] brcmfmac: brcmf_sdio_dpc Enter
[   20.833872] brcmfmac: brcmf_sdio_readframes Enter
[   20.833930] brcmfmac: brcmf_sdio_read_control Enter
[   20.833991] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 24 expected 24
[   20.834001] brcmfmac: brcmf_fil_cmd_data_set cmd=57, len=8
[   20.834003] brcmutil: data
[   20.834007] 00000000: 14 00 00 00 03 00 00 00                          ........
[   20.834011] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.834038] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.834098] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.834158] brcmfmac: brcmf_sdio_isr Enter
[   20.834269] brcmfmac: brcmf_sdio_dpc Enter
[   20.834276] brcmfmac: brcmf_sdio_readframes Enter
[   20.834335] brcmfmac: brcmf_sdio_read_control Enter
[   20.834396] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 24 expected 24
[   20.834408] brcmfmac: brcmf_cfg80211_change_iface Enter, ndev=ebbe5800, type=2
[   20.834413] brcmfmac: brcmf_fil_cmd_int_set cmd=20, value=1
[   20.834417] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.834441] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.834504] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.834564] brcmfmac: brcmf_sdio_isr Enter
[   20.834676] brcmfmac: brcmf_sdio_dpc Enter
[   20.834682] brcmfmac: brcmf_sdio_readframes Enter
[   20.834786] brcmfmac: brcmf_sdio_read_control Enter
[   20.834858] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[   20.834863] brcmfmac: brcmf_cfg80211_change_iface IF Type = Infra
[   20.834872] brcmfmac: brcmf_cfg80211_change_iface Exit
[   20.834879] brcmfmac: brcmf_fil_iovar_data_set name=arp_ol, len=4
[   20.834882] brcmutil: data
[   20.834886] 00000000: 09 00 00 00                                      ....
[   20.834892] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.834927] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.835401] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.835444] brcmfmac: brcmf_sdio_isr Enter
[   20.835561] brcmfmac: brcmf_sdio_dpc Enter
[   20.835567] brcmfmac: brcmf_sdio_readframes Enter
[   20.835627] brcmfmac: brcmf_sdio_read_control Enter
[   20.835690] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 27 expected 27
[   20.835701] brcmfmac: brcmf_fil_iovar_data_set name=arpoe, len=4
[   20.835704] brcmutil: data
[   20.835707] 00000000: 01 00 00 00                                      ....
[   20.835711] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.835736] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.835797] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.835975] brcmfmac: brcmf_sdio_isr Enter
[   20.836088] brcmfmac: brcmf_sdio_dpc Enter
[   20.836095] brcmfmac: brcmf_sdio_readframes Enter
[   20.836158] brcmfmac: brcmf_sdio_read_control Enter
[   20.836221] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 26 expected 26
[   20.836231] brcmfmac: brcmf_configure_arp_offload successfully configured (1) ARP offload to 0x9
[   20.836269] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.836411] brcmfmac: brcmf_cfg80211_set_power_mgmt Enter
[   20.836416] brcmfmac: brcmf_cfg80211_set_power_mgmt power save enabled
[   20.836422] brcmfmac: brcmf_fil_cmd_int_set cmd=86, value=2
[   20.836427] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.836459] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.836499] brcmfmac: _brcmf_set_multicast_list Enter, idx=0
[   20.836517] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.836594] brcmfmac: brcmf_sdio_isr Enter
[   20.836718] brcmfmac: brcmf_sdio_dpc Enter
[   20.836726] brcmfmac: brcmf_sdio_readframes Enter
[   20.836792] brcmfmac: brcmf_sdio_read_control Enter
[   20.836862] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[   20.836881] brcmfmac: brcmf_cfg80211_set_power_mgmt Exit
[   20.837081] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.837133] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.837353] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.837392] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.838034] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.838087] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.838302] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.838342] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.838710] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.838746] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.843452] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.844885] brcmfmac: brcmf_fil_iovar_data_set name=mcast_list, len=16
[   20.844890] brcmutil: data
[   20.844897] 00000000: 02 00 00 00 33 33 00 00 00 01 01 00 5e 00 00 01  ....33......^...
[   20.844907] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.844917] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.845150] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.845206] brcmfmac: brcmf_sdio_isr Enter
[   20.845481] brcmfmac: brcmf_sdio_dpc Enter
[   20.845499] brcmfmac: brcmf_sdio_readframes Enter
[   20.846627] brcmfmac: brcmf_sdio_read_control Enter
[   20.854868] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 43 expected 43
[   20.854890] brcmfmac: brcmf_fil_iovar_data_set name=allmulti, len=4
[   20.854900] brcmutil: data
[   20.854911] 00000000: 00 00 00 00                                      ....
[   20.854920] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.855155] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.855245] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.855410] brcmfmac: brcmf_sdio_isr Enter
[   20.855581] brcmfmac: brcmf_sdio_dpc Enter
[   20.855595] brcmfmac: brcmf_sdio_readframes Enter
[   20.855662] brcmfmac: brcmf_sdio_read_control Enter
[   20.855732] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 29 expected 29
[   20.855751] brcmfmac: brcmf_fil_cmd_int_set cmd=10, value=0
[   20.855758] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.855789] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.855853] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.855922] brcmfmac: brcmf_sdio_isr Enter
[   20.856040] brcmfmac: brcmf_sdio_dpc Enter
[   20.856055] brcmfmac: brcmf_sdio_readframes Enter
[   20.856119] brcmfmac: brcmf_sdio_read_control Enter
[   20.856176] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[   20.856190] brcmfmac: _brcmf_set_multicast_list Enter, idx=0
[   20.856196] brcmfmac: brcmf_fil_iovar_data_set name=mcast_list, len=22
[   20.856200] brcmutil: data
[   20.856208] 00000000: 03 00 00 00 33 33 00 00 00 01 01 00 5e 00 00 01  ....33......^...
[   20.856226] 00000010: 33 33 ff c5 2b 66                                33..+f
[   20.856231] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.856257] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.856328] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.856455] brcmfmac: brcmf_sdio_isr Enter
[   20.856578] brcmfmac: brcmf_sdio_dpc Enter
[   20.856586] brcmfmac: brcmf_sdio_readframes Enter
[   20.856651] brcmfmac: brcmf_sdio_read_control Enter
[   20.856715] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 49 expected 49
[   20.856729] brcmfmac: brcmf_fil_iovar_data_set name=allmulti, len=4
[   20.856732] brcmutil: data
[   20.856737] 00000000: 00 00 00 00                                      ....
[   20.856742] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.856769] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.856834] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.856987] brcmfmac: brcmf_sdio_isr Enter
[   20.857115] brcmfmac: brcmf_sdio_dpc Enter
[   20.857122] brcmfmac: brcmf_sdio_readframes Enter
[   20.857189] brcmfmac: brcmf_sdio_read_control Enter
[   20.857254] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 29 expected 29
[   20.857266] brcmfmac: brcmf_fil_cmd_int_set cmd=10, value=0
[   20.857270] brcmfmac: brcmf_sdio_bus_txctl Enter
[   20.857296] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   20.857359] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   20.857420] brcmfmac: brcmf_sdio_isr Enter
[   20.857541] brcmfmac: brcmf_sdio_dpc Enter
[   20.857548] brcmfmac: brcmf_sdio_readframes Enter
[   20.857605] brcmfmac: brcmf_sdio_read_control Enter
[   20.857670] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[   20.858106] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.858179] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.864867] brcmfmac: brcmf_sdio_bus_txdata Enter: pkt: data ebcca01e len 94
[   20.864874] brcmfmac: brcmf_sdio_bus_txdata deferring pktq len 0
[   20.864985] brcmfmac: brcmf_sdio_dpc Enter
[   20.865002] brcmfmac: brcmf_sdio_sendfromq Enter
[   20.865009] brcmfmac: brcmf_sdio_txpkt Enter
[   20.947407] brcmfmac: brcmf_netdev_get_stats Enter, idx=0
[   20.947972] brcmfmac: brcmf_cfg80211_mgmt_frame_register Enter, frame_type 00d0, reg=1
[   20.948022] brcmfmac: brcmf_cfg80211_mgmt_frame_register Enter, frame_type 00d0, reg=1
[   20.948068] brcmfmac: brcmf_cfg80211_mgmt_frame_register Enter, frame_type 00d0, reg=1
[   20.948110] brcmfmac: brcmf_cfg80211_mgmt_frame_register Enter, frame_type 00d0, reg=1
[   20.948151] brcmfmac: brcmf_cfg80211_mgmt_frame_register Enter, frame_type 00d0, reg=1
[   20.948194] brcmfmac: brcmf_cfg80211_mgmt_frame_register Enter, frame_type 00d0, reg=1
[   20.948236] brcmfmac: brcmf_cfg80211_mgmt_frame_register Enter, frame_type 00d0, reg=1
[   21.025308] brcmfmac: brcmf_cfg80211_flush_pmksa Enter
[   21.025326] brcmfmac: brcmf_fil_iovar_data_set name=pmkid_info, len=360
[   21.025333] brcmutil: data
[   21.025342] 00000000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   21.025349] 00000010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   21.025356] 00000020: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   21.025362] 00000030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   21.025372] brcmfmac: brcmf_sdio_bus_txctl Enter
[   21.033023] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   21.033114] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   21.033246] brcmfmac: brcmf_sdio_isr Enter
[   21.033366] brcmfmac: brcmf_sdio_dpc Enter
[   21.033378] brcmfmac: brcmf_sdio_readframes Enter
[   21.033447] brcmfmac: brcmf_sdio_read_control Enter
[   21.033572] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 387 expected 387
[   21.033582] brcmfmac: brcmf_cfg80211_flush_pmksa Exit
[   21.046802] brcmfmac: brcmf_cfg80211_scan Enter
[   21.046824] brcmfmac: brcmf_vif_set_mgmt_ie bssidx 0, pktflag : 0x10
[   21.046836] brcmfmac: brcmf_fil_cmd_int_set cmd=49, value=0
[   21.046844] brcmfmac: brcmf_sdio_bus_txctl Enter
[   21.047064] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   21.047147] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   21.047208] brcmfmac: brcmf_sdio_isr Enter
[   21.047349] brcmfmac: brcmf_sdio_dpc Enter
[   21.047363] brcmfmac: brcmf_sdio_readframes Enter
[   21.047575] brcmfmac: brcmf_sdio_read_control Enter
[   21.047656] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 20 expected 20
[   21.047678] brcmfmac: brcmf_fil_iovar_data_set name=escan, len=144
[   21.047685] brcmutil: data
[   21.047696] 00000000: 01 00 00 00 01 00 34 12 00 00 00 00 00 00 00 00  ......4.........
[   21.047703] 00000010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   21.047710] 00000020: 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   21.047716] 00000030: ff ff 02 00 ff ff ff ff ff ff ff ff ff ff ff ff  ................
[   21.047726] brcmfmac: brcmf_sdio_bus_txctl Enter
[   21.047803] brcmfmac: brcmf_sdio_tx_ctrlframe Enter
[   21.047868] brcmfmac: brcmf_sdio_bus_rxctl Enter
[   21.048708] brcmfmac: brcmf_sdio_isr Enter
[   21.048814] brcmfmac: brcmf_sdio_dpc Enter
[   21.048826] brcmfmac: brcmf_sdio_readframes Enter
[   21.048881] brcmfmac: brcmf_sdio_read_control Enter
[   21.048976] brcmfmac: brcmf_sdio_bus_rxctl resumed on rxctl frame, got 166 expected 166
[   21.048987] brcmfmac: brcmf_cfg80211_scan Exit
[   21.064809] brcmfmac: brcmf_sdio_bus_txdata Enter: pkt: data ebcca01e len 94
[   21.064822] brcmfmac: brcmf_sdio_bus_txdata deferring pktq len 0
[   21.064861] brcmfmac: brcmf_sdio_dpc Enter
[   21.064940] brcmfmac: brcmf_sdio_sendfromq Enter
[   21.064952] brcmfmac: brcmf_sdio_txpkt Enter
[   21.279155] brcmfmac: brcmf_sdio_isr Enter
[   21.279282] brcmfmac: brcmf_sdio_dpc Enter
[   21.279379] brcmfmac: brcmf_sdio_readframes Enter
[   21.279557] brcmfmac: brcmf_fweh_event_worker event ESCAN_RESULT (69) ifidx 0 bsscfg 0 addr 00:00:00:00:00:00
[   21.279574] brcmfmac: brcmf_fweh_event_worker   version 2 flags 0 status 8 reason 0
[   21.279581] brcmutil: event payload, len=280

--C7zPtVaVf+AK4Oqc--
