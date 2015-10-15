From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: SoCFPGA ethernet broken
Date: Thu, 15 Oct 2015 13:03:19 -0700
Message-ID: <56200687.9040903@gmail.com>
References: <561FF9E2.30102@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: david.daney@cavium.com, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dinh Nguyen <dinguyen@opensource.altera.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561FF9E2.30102@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/10/15 12:09, Dinh Nguyen wrote:
> Hi,
> 
> commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus, not
> the bus' parent." seems to have broken ethernet support for the SoCFPGA
> platform which is using the stmmac ethernet driver.

It is not clear to me how this relates to what you are seeing yet.

> 
> It appears that during DHCP, it cannot get an IP address. This only
> happens if ethernet was not used by the bootloader to tftp an kernel
> image. If I use the bootloader to tftp an image then ethernet is working
> fine. So I think the PHY is not getting enabled properly.
> 
> If I revert this patch, then ethernet is back to working on the platform.

Is the Device Tree source for this platform available somewhere to look at?

> 
> I just tested this in the v4.3-rc5.
> 
> Will continue to debug, but was wondering if anyone has seen this issue.
> 
> Thanks for any help/comments.
> 
> Dinh
> 
> Bootlog below.
> ----
> [    0.000000] Booting Linux on physical CPU 0x0
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Linux version 4.3.0-rc5-00037-g5b5f145
> (dinguyen@linux-builds1) (gcc version 4.7.3 20130226 (prerelease) (crosstool
> -NG linaro-1.13.1-4.7-2013.03-20130313 - Linaro GCC 2013.03) ) #1 SMP
> Thu Oct 15 13:55:48 CDT 2015
> [    0.000000] CPU: ARMv7 Processor [413fc090] revision 0 (ARMv7),
> cr=10c5387d
> [    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing
> instruction cache
> [    0.000000] Machine model: Altera SOCFPGA Cyclone V SoC Development Kit
> [    0.000000] Truncating RAM at 0x00000000-0x40000000 to -0x2f800000
> [    0.000000] Consider using a HIGHMEM enabled kernel.
> [    0.000000] Memory policy: Data cache writealloc
> [    0.000000] On node 0 totalpages: 194560
> [    0.000000] free_area_init_node: node 0, pgdat c067c080, node_mem_map
> ef20b000
> [    0.000000]   Normal zone: 1520 pages used for memmap
> [    0.000000]   Normal zone: 0 pages reserved
> [    0.000000]   Normal zone: 194560 pages, LIFO batch:31
> [    0.000000] PERCPU: Embedded 13 pages/cpu @ef1df000 s21760 r8192
> d23296 u53248
> [    0.000000] pcpu-alloc: s21760 r8192 d23296 u53248 alloc=13*4096
> [    0.000000] pcpu-alloc: [0] 0 [0] 1
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
> Total pages: 193040
> [    0.000000] Kernel command line: console=ttyS0,115200 root=/dev/nfs
> rw nfsroot=137.57.160.210:/home/dinguyen/rootfs_yocto ip=dh
> cp debug
> [    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
> [    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288
> bytes)
> [    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144
> bytes)
> [    0.000000] Memory: 764368K/778240K available (4696K kernel code,
> 274K rwdata, 1328K rodata, 324K init, 131K bss, 13872K reserv
> ed, 0K cma-reserved)
> [    0.000000] Virtual kernel memory layout:
> [    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
> [    0.000000]     fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
> [    0.000000]     vmalloc : 0xf0000000 - 0xff000000   ( 240 MB)
> [    0.000000]     lowmem  : 0xc0000000 - 0xef800000   ( 760 MB)
> [    0.000000]     modules : 0xbf000000 - 0xc0000000   (  16 MB)
> [    0.000000]       .text : 0xc0008000 - 0xc05ea5f4   (6026 kB)
> [    0.000000]       .init : 0xc05eb000 - 0xc063c000   ( 324 kB)
> [    0.000000]       .data : 0xc063c000 - 0xc0680b30   ( 275 kB)
> [    0.000000]        .bss : 0xc0680b30 - 0xc06a1a38   ( 132 kB)
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000]  Build-time adjustment of leaf fanout to 32.
> [    0.000000] NR_IRQS:16 nr_irqs:16 16
> [    0.000000] L2C-310 enabling early BRESP for Cortex-A9
> [    0.000000] L2C-310 full line of zeros enabled for Cortex-A9
> [    0.000000] L2C-310 ID prefetch enabled, offset 1 lines
> [    0.000000] L2C-310 dynamic clock gating enabled, standby mode enabled
> [    0.000000] L2C-310 cache controller enabled, 8 ways, 512 kB
> [    0.000000] L2C-310: CACHE_ID 0x410030c9, AUX_CTRL 0x76060001
> [    0.000000] clocksource: timer1: mask: 0xffffffff max_cycles:
> 0xffffffff, max_idle_ns: 19112604467 ns
> [    0.000005] sched_clock: 32 bits at 100MHz, resolution 10ns, wraps
> every 21474836475ns
> [    0.000134] Console: colour dummy device 80x30
> [    0.000151] Calibrating delay loop... 1836.64 BogoMIPS (lpj=9183232)
> [    0.059867] pid_max: default: 32768 minimum: 301
> [    0.059938] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
> [    0.059947] Mountpoint-cache hash table entries: 2048 (order: 1, 8192
> bytes)
> [    0.060411] CPU: Testing write buffer coherency: ok
> [    0.060586] CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
> [    0.060735] Setting up static identity map for 0x8280 - 0x82d8
> [    0.119895] CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
> [    0.119954] Brought up 2 CPUs
> [    0.119968] SMP: Total of 2 processors activated (3679.84 BogoMIPS).
> [    0.119974] CPU: All CPU(s) started in SVC mode.
> [    0.120594] devtmpfs: initialized
> [    0.124057] VFP support v0.3: implementor 41 architecture 3 part 30
> variant 9 rev 4
> [    0.124296] clocksource: jiffies: mask: 0xffffffff max_cycles:
> 0xffffffff, max_idle_ns: 19112604462750000 ns
> [    0.125249] NET: Registered protocol family 16
> [    0.125991] DMA: preallocated 256 KiB pool for atomic coherent
> allocations
> [    0.129791] hw-breakpoint: found 5 (+1 reserved) breakpoint and 1
> watchpoint registers.
> [    0.129803] hw-breakpoint: maximum watchpoint size is 4 bytes.
> [    0.163465] SCSI subsystem initialized
> [    0.163736] usbcore: registered new interface driver usbfs
> [    0.163793] usbcore: registered new interface driver hub
> [    0.163848] usbcore: registered new device driver usb
> [    0.164469] pps_core: LinuxPPS API ver. 1 registered
> [    0.164478] pps_core: Software ver. 5.3.6 - Copyright 2005-2007
> Rodolfo Giometti <giometti@linux.it>
> [    0.164508] PTP clock support registered
> [    0.165340] clocksource: Switched to clocksource timer1
> [    0.188264] NET: Registered protocol family 2
> [    0.188761] TCP established hash table entries: 8192 (order: 3, 32768
> bytes)
> [    0.188839] TCP bind hash table entries: 8192 (order: 4, 65536 bytes)
> [    0.188961] TCP: Hash tables configured (established 8192 bind 8192)
> [    0.189040] UDP hash table entries: 512 (order: 2, 16384 bytes)
> [    0.189083] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
> [    0.189250] NET: Registered protocol family 1
> [    0.189570] RPC: Registered named UNIX socket transport module.
> [    0.189579] RPC: Registered udp transport module.
> [    0.189584] RPC: Registered tcp transport module.
> [    0.189589] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [    0.190622] futex hash table entries: 512 (order: 3, 32768 bytes)
> [    0.199426] ntfs: driver 2.1.32 [Flags: R/W].
> [    0.200257] io scheduler noop registered (default)
> [    0.204012] Serial: 8250/16550 driver, 2 ports, IRQ sharing disabled
> [    0.204920] console [ttyS0] disabled
> [    0.204954] ffc02000.serial0: ttyS0 at MMIO 0xffc02000 (irq = 34,
> base_baud = 6250000) is a 16550A
> [    0.740840] console [ttyS0] enabled
> [    0.744835] ffc03000.serial1: ttyS1 at MMIO 0xffc03000 (irq = 35,
> base_baud = 6250000) is a 16550A
> [    0.755333] brd: module loaded
> [    0.758903] CAN device driver interface
> [    0.763108] stmmac - user ID: 0x10, Synopsys ID: 0x37
> [    0.768216]  Ring mode enabled
> [    0.771259]  DMA HW capability register supported
> [    0.775776]  Enhanced/Alternate descriptors
> [    0.780122]  Enabled extended descriptors
> [    0.784112]  RX Checksum Offload Engine supported (type 2)
> [    0.789585]  TX Checksum insertion supported
> [    0.793835]  Enable RX Mitigation via HW Watchdog Timer
> [    0.804992] libphy: stmmac: probed
> [    0.808410] eth0: PHY ID 00221611 at 4 IRQ POLL (stmmac-0:04) active
> [    1.665377] dwc2 ffb40000.usb: DWC OTG Controller
> [    1.670086] dwc2 ffb40000.usb: new USB bus registered, assigned bus
> number 1
> [    1.677138] dwc2 ffb40000.usb: irq 36, io mem 0x00000000
> [    1.683139] hub 1-0:1.0: USB hub found
> [    1.686917] hub 1-0:1.0: 1 port detected
> [    1.691477] mousedev: PS/2 mouse device common for all mice
> [    1.697271] i2c /dev entries driver
> [    1.701325] Synopsys Designware Multimedia Card Interface Driver
> [    1.707550] dw_mmc ff704000.dwmmc0: IDMAC supports 32-bit address mode.
> [    1.714163] dw_mmc ff704000.dwmmc0: Using PIO mode.
> [    1.719035] dw_mmc ff704000.dwmmc0: Version ID is 240a
> [    1.724185] dw_mmc ff704000.dwmmc0: DW MMC controller at irq 30,32
> bit host data width,1024 deep fifo
> [    1.733502] dw_mmc ff704000.dwmmc0: Got CD GPIO
> [    1.775329] dw_mmc ff704000.dwmmc0: 1 slots initialized
> [    1.780769] usbcore: registered new interface driver usbhid
> [    1.786338] usbhid: USB HID core driver
> [    1.790327] oprofile: no performance counters
> [    1.794750] oprofile: using timer interrupt.
> [    1.799920] NET: Registered protocol family 10
> [    1.805084] sit: IPv6 over IPv4 tunneling driver
> [    1.810277] NET: Registered protocol family 17
> [    1.814726] NET: Registered protocol family 15
> [    1.819173] can: controller area network core (rev 20120528 abi 9)
> [    1.825384] NET: Registered protocol family 29
> [    1.829817] can: raw protocol (rev 20120528)
> [    1.834073] can: broadcast manager protocol (rev 20120528 t)
> [    1.839727] can: netlink gateway (rev 20130117) max_hops=1
> [    1.845361] 8021q: 802.1Q VLAN Support v1.8
> [    1.849630] ThumbEE CPU extension supported.
> [    1.853900] Registering SWP/SWPB emulation handler
> [    1.854029] mmc_host mmc0: Bus speed (slot 0) = 50000000Hz (slot req
> 50000000Hz, actual 50000000HZ div = 0)
> [    1.854079] mmc0: new high speed SDHC card at address aaaa
> [    1.854496] mmcblk0: mmc0:aaaa SU32G 29.7 GiB
> [    1.855953]  mmcblk0: p1 p2 p3
> [    1.985343] Sending DHCP requests ..
> [    5.955860] socfpga-dwmac ff702000.ethernet eth0: Link is Up -
> 1Gbps/Full - flow control rx/tx
> [    9.105279] .... timed out!
> [   85.166664] IP-Config: Retrying forever (NFS root)...
> [   85.256666] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> [   89.245860] socfpga-dwmac ff702000.ethernet eth0: Link is Up -
> 1Gbps/Full - flow control rx/tx
> [   89.255301] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [   89.275329] Sending DHCP requests ...... timed out!
> [  161.306641] IP-Config: Retrying forever (NFS root)...
> [  161.396643] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> [  165.385861] socfpga-dwmac ff702000.ethernet eth0: Link is Up -
> 1Gbps/Full - flow control rx/tx
> [  165.395301] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> 


-- 
Florian
