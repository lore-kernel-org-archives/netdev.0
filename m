From: Mark Jackson <mpfj-list@mimc.co.uk>
Subject: Re: [PATCH 0/3] Dual EMAC mode implementation of CPSW
Date: Tue, 16 Apr 2013 12:09:16 +0100
Message-ID: <516D315C.90306@mimc.co.uk>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com> <516B0098.4040809@mimc.co.uk> <516C33D2.4050105@ti.com> <516C38B9.50904@mimc.co.uk> <516C3A0D.70903@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <516C3A0D.70903@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/04/13 18:34, Mugunthan V N wrote:
> On 4/15/2013 10:58 PM, Mark Jackson wrote:
>> On 15/04/13 18:07, Mugunthan V N wrote:
>>> On 4/15/2013 12:46 AM, Mark Jackson wrote:
>>
>> <snip>
>>
>>>>
>>>> Notice that at the end, the nfs link appears to come back "ok", but
>>>> the "ps" command never completes.
>>>>
>>>> Any ideas of what's going on ?
>>>
>>> I have tried ping on both the interface fine. Will verify with ps again
>>> later in this week.
>>> Can you provide below details details
>>> - Are you using EVMsk or custom build EVM?
>>
>> This is a custom board (based on the BeagleBone design) with dual Ethernet, NAND, NOR and FRAM.
>>
>> The dual emac thing is (one of) the last things to get signed off, so I'm willing to assist in tracking this down.
> 
> After testing the scenario i may be able to send you an update later in this week.

Just a quick update ...

I've now setup our board to boot entirely from NAND (UBoot -> Kernel -> UBIFS) so
that I'm no longer using NFS (just to isolate any issues there).

I am still *unable* to get a connection on either Ethernet port.

*HOWEVER* ... I *can* ping my board from another PC on the network:-

mpfj@mpfj-nanobone:~/uboot/u-boot$ ping 10.0.101.111 -c 5
PING 10.0.101.111 (10.0.101.111) 56(84) bytes of data.
64 bytes from 10.0.101.111: icmp_req=1 ttl=64 time=0.692 ms
64 bytes from 10.0.101.111: icmp_req=2 ttl=64 time=0.551 ms
64 bytes from 10.0.101.111: icmp_req=3 ttl=64 time=0.462 ms
64 bytes from 10.0.101.111: icmp_req=4 ttl=64 time=0.409 ms
64 bytes from 10.0.101.111: icmp_req=5 ttl=64 time=0.344 ms

--- 10.0.101.111 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 3998ms
rtt min/avg/max/mdev = 0.344/0.491/0.692/0.123 ms

So I can't ping *out*, but I can ping *in* !!

Note that I've only tried this ping test to/from eth0 ... I'll
setup another box on the correct IP range so I can also test eth1.

I've added my boot log below.

Cheers
Mark J.
---
U-Boot SPL 2013.04-rc2-00065-g7450e4d-dirty (Apr 16 2013 - 11:36:17)


U-Boot 2013.04-rc2-00065-g7450e4d-dirty (Apr 16 2013 - 11:36:17)

I2C:   ready
DRAM:  256 MiB
WARNING: Caches not enabled
NAND:  256 MiB
MMC:   OMAP SD/MMC: 0, OMAP SD/MMC: 1
Net:   cpsw:0 is connected to cpsw.  Reconnecting to cpsw
cpsw
Hit any key to stop autoboot:  0

NAND read: device 0 offset 0x200000, size 0x400000
 4194304 bytes read: OK
## Booting kernel from Legacy Image at 80200000 ...
   Image Name:   Linux 3.9.0-rc7-00023-gfcc38a5
   Image Type:   ARM Linux Kernel Image (uncompressed)
   Data Size:    2997518 Bytes = 2.9 MiB
   Load Address: 80008000
   Entry Point:  80008000
   Verifying Checksum ... OK
   Loading Kernel Image ... OK
OK

Starting kernel ...

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 3.9.0-rc7-00023-gfcc38a5 (mpfj@mpfj-nanobone) (gcc version 4.5.4 (Buildroot 2012.11) ) #156 Tue Apr 16 08:55:28 BST 2013
[    0.000000] CPU: ARMv7 Processor [413fc082] revision 2 (ARMv7), cr=10c53c7d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
[    0.000000] Machine: Generic AM33XX (Flattened Device Tree), model: Newflow AM335x NanoBone
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] Memory policy: ECC disabled, Data cache writeback
[    0.000000] On node 0 totalpages: 65280
[    0.000000] free_area_init_node: node 0, pgdat c059a858, node_mem_map c0ac4000
[    0.000000]   Normal zone: 512 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 65280 pages, LIFO batch:15
[    0.000000] CPU: All CPU(s) started in SVC mode.
[    0.000000] AM335X ES1.0 (neon )
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64768
[    0.000000] Kernel command line: console=ttyO0,115200n8 noinitrd ip=off mem=256M rootwait=1 ubi.mtd=4,2048 rootfstype=ubifs root=ubi0:rootfs ignore_loglevel
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Memory: 255MB = 255MB total
[    0.000000] Memory: 247776k/247776k available, 14368k reserved, 0K highmem
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
[    0.000000]     vmalloc : 0xd0800000 - 0xff000000   ( 744 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xd0000000   ( 256 MB)
[    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
[    0.000000]       .text : 0xc0008000 - 0xc0517550   (5182 kB)
[    0.000000]       .init : 0xc0518000 - 0xc0549fdc   ( 200 kB)
[    0.000000]       .data : 0xc054a000 - 0xc059b420   ( 326 kB)
[    0.000000]        .bss : 0xc059b420 - 0xc0ac0210   (5268 kB)
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] IRQ: Found an INTC at 0xfa200000 (revision 5.0) with 128 interrupts
[    0.000000] Total of 128 interrupts on 1 active controller
[    0.000000] OMAP clockevent source: GPTIMER1 at 26000000 Hz
[    0.000000] sched_clock: 32 bits at 26MHz, resolution 38ns, wraps every 165191ms
[    0.000000] OMAP clocksource: GPTIMER2 at 26000000 Hz
[    0.000000] Console: colour dummy device 80x30
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3695 kB
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000847] Calibrating delay loop... 479.23 BogoMIPS (lpj=2396160)
[    0.109871] pid_max: default: 32768 minimum: 301
[    0.110137] Security Framework initialized
[    0.110240] Mount-cache hash table entries: 512
[    0.120776] CPU: Testing write buffer coherency: ok
[    0.122005] Setting up static identity map for 0xc0401520 - 0xc0401578
[    0.125334] devtmpfs: initialized
[    0.187056] pinctrl core: initialized pinctrl subsystem
[    0.192364] regulator-dummy: no parameters
[    0.194592] NET: Registered protocol family 16
[    0.195373] DMA: preallocated 256 KiB pool for atomic coherent allocations
[    0.213975] gpiochip_add: registered GPIOs 0 to 31 on device: gpio
[    0.214363] OMAP GPIO hardware version 0.1
[    0.217164] gpiochip_add: registered GPIOs 32 to 63 on device: gpio
[    0.219783] gpiochip_add: registered GPIOs 64 to 95 on device: gpio
[    0.222396] gpiochip_add: registered GPIOs 96 to 127 on device: gpio
[    0.237302] omap-gpmc 50000000.gpmc: could not find pctldev for node /pinmux@44e10800/gpmc_pins, deferring probe
[    0.237355] platform 50000000.gpmc: Driver omap-gpmc requests probe deferral
[    0.237973] No ATAGs?
[    0.237993] hw-breakpoint: debug architecture 0x4 unsupported.
[    0.276361] bio: create slab <bio-0> at 0
[    0.342986] omap-dma-engine omap-dma-engine: OMAP DMA engine driver
[    0.349442] usbcore: registered new interface driver usbfs
[    0.350031] usbcore: registered new interface driver hub
[    0.350724] usbcore: registered new device driver usb
[    0.351718] omap_i2c 44e0b000.i2c: could not find pctldev for node /pinmux@44e10800/i2c1_pins, deferring probe
[    0.351765] platform 44e0b000.i2c: Driver omap_i2c requests probe deferral
[    0.358976] cfg80211: Calling CRDA to update world regulatory domain
[    0.360721] Switching to clocksource gp_timer
[    0.410493] NET: Registered protocol family 2
[    0.412172] TCP established hash table entries: 2048 (order: 2, 16384 bytes)
[    0.412382] TCP bind hash table entries: 2048 (order: 4, 73728 bytes)
[    0.413327] TCP: Hash tables configured (established 2048 bind 2048)
[    0.413543] TCP: reno registered
[    0.413576] UDP hash table entries: 256 (order: 2, 20480 bytes)
[    0.413836] UDP-Lite hash table entries: 256 (order: 2, 20480 bytes)
[    0.414647] NET: Registered protocol family 1
[    0.416021] RPC: Registered named UNIX socket transport module.
[    0.416048] RPC: Registered udp transport module.
[    0.416062] RPC: Registered tcp transport module.
[    0.416076] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.416981] NetWinder Floating Point Emulator V0.97 (double precision)
[    0.417431] CPU PMU: probing PMU on CPU 0
[    0.417461] hw perfevents: enabled with ARMv7 Cortex-A8 PMU driver, 5 counters available
[    0.429858] msgmni has been set to 483
[    0.434203] io scheduler noop registered
[    0.434229] io scheduler deadline registered
[    0.434299] io scheduler cfq registered (default)
[    0.435365] pinctrl-single 44e10800.pinmux: 142 pins at pa f9e10800 size 568
[    0.436997] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.444362] 44e09000.serial: ttyO0 at MMIO 0x44e09000 (irq = 88) is a OMAP UART0
[    1.057074] console [ttyO0] enabled
[    1.063340] 48022000.serial: ttyO1 at MMIO 0x48022000 (irq = 89) is a OMAP UART1
[    1.072890] 48024000.serial: ttyO2 at MMIO 0x48024000 (irq = 90) is a OMAP UART2
[    1.082323] 481a6000.serial: ttyO3 at MMIO 0x481a6000 (irq = 60) is a OMAP UART3
[    1.091771] 481a8000.serial: ttyO4 at MMIO 0x481a8000 (irq = 61) is a OMAP UART4
[    1.101172] 481aa000.serial: ttyO5 at MMIO 0x481aa000 (irq = 62) is a OMAP UART5
[    1.135992] brd: module loaded
[    1.155121] loop: module loaded
[    1.161971] Generic platform RAM MTD, (c) 2004 Simtec Electronics
[    1.173565] usbcore: registered new interface driver rt2800usb
[    1.180130] usbcore: registered new interface driver asix
[    1.186291] usbcore: registered new interface driver cdc_ether
[    1.192897] usbcore: registered new interface driver smsc95xx
[    1.199347] usbcore: registered new interface driver net1080
[    1.205770] usbcore: registered new interface driver cdc_subset
[    1.212450] usbcore: registered new interface driver zaurus
[    1.218778] usbcore: registered new interface driver cdc_ncm
[    1.226712] usbcore: registered new interface driver cdc_wdm
[    1.233200] usbcore: registered new interface driver usbtest
[    1.239574] i2c /dev entries driver
[    1.246666] omap_wdt: OMAP Watchdog Timer Rev 0x01: initial timeout 60 sec
[    1.255267] omap_cpufreq_init: unable to get MPU regulator
[    1.263425] leds-gpio leds.3: pins are not configured from the driver
[    1.270281] of_get_named_gpio_flags exited with status 5
[    1.275978] of_get_named_gpio_flags exited with status 5
[    1.284737] usbcore: registered new interface driver usbhid
[    1.290643] usbhid: USB HID core driver
[    1.295943] oprofile: using arm/armv7
[    1.300536] TCP: cubic registered
[    1.304134] Initializing XFRM netlink socket
[    1.308766] NET: Registered protocol family 17
[    1.313610] NET: Registered protocol family 15
[    1.318770] Key type dns_resolver registered
[    1.323453] VFP support v0.3: implementor 41 architecture 3 part 30 variant c rev 3
[    1.331650] ThumbEE CPU extension supported.
[    1.340254] omap-gpmc 50000000.gpmc: GPMC revision 6.0
[    1.347867] enabling NAND BCH ecc with 8-bit correction
[    1.353814] ONFI param page 0 valid
[    1.357509] ONFI flash detected
[    1.360873] NAND device: Manufacturer ID: 0x2c, Chip ID: 0xda (Micron MT29F2G08ABAEAWP), 256MiB, page size: 2048, OOB size: 64
[    1.373151] 6 ofpart partitions found on MTD device omap2-nand.0
[    1.379506] Creating 6 MTD partitions on "omap2-nand.0":
[    1.385173] 0x000000000000-0x000000020000 : "spl"
[    1.392610] 0x000000020000-0x0000001e0000 : "boot"
[    1.399934] 0x0000001e0000-0x000000200000 : "env"
[    1.405820] 0x000000200000-0x000000600000 : "kernel"
[    1.415189] 0x000000600000-0x000004600000 : "rootfs"
[    1.476147] 0x000004600000-0x000010000000 : "data"
[    1.645387] omap_i2c 44e0b000.i2c: bus 0 rev0.11 at 400 kHz
[    1.652197] mcp230xx 0-0020: invalid or missing platform data
[    1.658321] mcp230xx: probe of 0-0020 failed with error -22
[    1.669107] DCDC1: at 1800 mV
[    1.674476] vdd_mpu: 925 <--> 1325 mV at 3300 mV
[    1.681644] vdd_core: 925 <--> 1150 mV at 1100 mV
[    1.688614] LDO1: at 1800 mV
[    1.693751] LDO2: at 3300 mV
[    1.698747] LDO3: at 1800 mV
[    1.703850] LDO4: at 2800 mV
[    1.708625] tps65217 0-0024: TPS65217 ID 0x7 version 1.1
[    1.715197] at24 0-0053: 256 byte 24c02 EEPROM, writable, 8 bytes/write
[    1.725928] rtc-ds1307 0-0068: rtc core: registered ds1307 as rtc0
[    1.732584] rtc-ds1307 0-0068: 56 bytes nvram
[    1.739183] UBI: attaching mtd4 to ubi0
[    2.062968] UBI: scanning is finished
[    2.074398] UBI warning: print_rsvd_warning: cannot reserve enough PEBs for bad PEB handling, reserved 4, need 40
[    2.089143] UBI: attached mtd4 (name "rootfs", size 64 MiB) to ubi0
[    2.095874] UBI: PEB size: 131072 bytes (128 KiB), LEB size: 126976 bytes
[    2.103085] UBI: min./max. I/O unit sizes: 2048/2048, sub-page size 512
[    2.110079] UBI: VID header offset: 2048 (aligned 2048), data offset: 4096
[    2.117376] UBI: good PEBs: 512, bad PEBs: 0, corrupted PEBs: 0
[    2.123661] UBI: user volume: 1, internal volumes: 1, max. volumes count: 128
[    2.131233] UBI: max/mean erase counter: 2/1, WL threshold: 4096, image sequence number: 1434266085
[    2.140824] UBI: available PEBs: 0, total reserved PEBs: 512, PEBs reserved for bad PEB handling: 4
[    2.151800] UBI: background thread "ubi_bgt0d" started, PID 591
[    2.220904] davinci_mdio 4a101000.mdio: davinci mdio revision 1.6
[    2.227366] davinci_mdio 4a101000.mdio: detected phy mask fffffffc
[    2.236894] libphy: 4a101000.mdio: probed
[    2.241232] davinci_mdio 4a101000.mdio: phy[0]: device 4a101000.mdio:00, driver SMSC LAN8710/LAN8720
[    2.250932] davinci_mdio 4a101000.mdio: phy[1]: device 4a101000.mdio:01, driver SMSC LAN8710/LAN8720
[    2.260831] Missing dual_emac_res_vlan in DT.
[    2.265440] Using 1 as Reserved VLAN for 0 slave
[    2.270383] Missing dual_emac_res_vlan in DT.
[    2.275018] Using 2 as Reserved VLAN for 1 slave
[    2.280057] Random MACID = 7a:9d:bf:22:b3:c7
[    2.287417] cpsw: Random MACID = 1a:48:dc:88:09:4d
[    2.295871] rtc-ds1307 0-0068: setting system clock to 2013-04-16 11:38:41 UTC (1366112321)
[    2.373950] UBIFS: mounted UBI device 0, volume 0, name "rootfs", R/O mode
[    2.381327] UBIFS: LEB size: 126976 bytes (124 KiB), min./max. I/O unit sizes: 2048 bytes/2048 bytes
[    2.391019] UBIFS: FS size: 60059648 bytes (57 MiB, 473 LEBs), journal size 7999488 bytes (7 MiB, 63 LEBs)
[    2.401254] UBIFS: reserved for root: 0 bytes (0 KiB)
[    2.406601] UBIFS: media format: w4/r0 (latest is w4/r0), UUID 93286679-C044-4BC4-8FCB-6E5055E65825, small LPT model
[    2.419981] VFS: Mounted root (ubifs filesystem) readonly on device 0:12.
[    2.429644] devtmpfs: mounted
[    2.433300] Freeing init memory: 196K
[    2.558990] UBIFS: background thread "ubifs_bgt0_0" started, PID 604
Starting logging: OK
Initializing random number generator... done.
Starting network...
[    2.870749] net eth0: initializing cpsw version 1.12 (0)
[    2.879972] net eth0: phy found : id is : 0x7c0f1
[    2.943874] net eth1: initializing cpsw version 1.12 (0)
[    2.952704] net eth1: phy found : id is : 0x7c0f1
ip: RTNETLINK answers: File exists
Starting dropbear sshd: OK
Starting lighttpd: OK

Welcome to Buildroot
nanobone login: root
Password: 
[    5.951540] libphy: 4a101000.mdio:00 - Link is Up - 100/Full

# cat /etc/network/interfaces
# Configure Loopback
auto lo eth0 eth1
iface lo inet loopback
iface eth0 inet static
address 10.0.101.111
netmask 255.255.0.0
gateway 10.0.0.1
iface eth1 inet static
address 10.1.101.111
netmask 255.255.0.0
gateway 10.1.0.1

# ifconfig
eth0      Link encap:Ethernet  HWaddr 7A:9D:BF:22:B3:C7
          inet addr:10.0.101.111  Bcast:0.0.0.0  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:11 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:704 (704.0 B)  TX bytes:0 (0.0 B)
          Interrupt:56

eth1      Link encap:Ethernet  HWaddr 1A:48:DC:88:09:4D
          inet addr:10.1.101.111  Bcast:0.0.0.0  Mask:255.255.0.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

#
[   20.031081] libphy: 4a101000.mdio:00 - Link is Down
[   24.391357] libphy: 4a101000.mdio:01 - Link is Up - 100/Full
[   30.471110] libphy: 4a101000.mdio:01 - Link is Down
[   33.991395] libphy: 4a101000.mdio:00 - Link is Up - 100/Full
#
#
# ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1): 56 data bytes

--- 10.0.0.1 ping statistics ---
46 packets transmitted, 0 packets received, 100% packet loss
# 
# ping 10.0.101.111
PING 10.0.101.111 (10.0.101.111): 56 data bytes
64 bytes from 10.0.101.111: seq=0 ttl=64 time=0.364 ms
64 bytes from 10.0.101.111: seq=1 ttl=64 time=0.252 ms

--- 10.0.101.111 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.252/0.308/0.364 ms
# ping 127.0.0.1
PING 127.0.0.1 (127.0.0.1): 56 data bytes
64 bytes from 127.0.0.1: seq=0 ttl=64 time=0.751 ms
64 bytes from 127.0.0.1: seq=1 ttl=64 time=0.303 ms
#

