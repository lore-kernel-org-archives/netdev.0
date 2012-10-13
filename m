From: Ronny Meeus <ronny.meeus@gmail.com>
Subject: Re: Question: How to configure the Ethernet receive buffer allocation
 (was: (no subject)).
Date: Sat, 13 Oct 2012 12:14:25 +0200
Message-ID: <CAMJ=MEdu9EtYhYHFyXD04b7M4BseX6oDfmB=NB9CAfMo59pxow@mail.gmail.com>
References: <CAMJ=MEd89zzLhxt7FYOVCbh5OzW+8jAsx38uV53zCodXvVtfMQ@mail.gmail.com>
 <1350118698.21172.13737.camel@edumazet-glaptop> <CAMJ=MEcqAsg6tsy9ALzcGqXmL9fQ2cmW6xXxup40iB2MrfuT8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:55288 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810Ab2JMKOq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2012 06:14:46 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so3625046oag.19
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2012 03:14:46 -0700 (PDT)
In-Reply-To: <CAMJ=MEcqAsg6tsy9ALzcGqXmL9fQ2cmW6xXxup40iB2MrfuT8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 13, 2012 at 11:10 AM, Ronny Meeus <ronny.meeus@gmail.com> w=
rote:
> On Sat, Oct 13, 2012 at 10:58 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> On Sat, 2012-10-13 at 10:39 +0200, Ronny Meeus wrote:
>>> Hello
>>>
>>> I have an application that needs to handle a massive amount of
>>> Ethernet packets coming from an FPGA on a dedicated Ethernet link.
>>> I use a raw Ethernet socket for this. By increasing the receive buf=
fer
>>> of the socket, I'm able to capture all the packets and process them=
 in
>>> the application. Since this processing can take some time I have
>>> increased the receive buffer to 500Mb. The size of the packets is
>>> 1000bytes so I'm able to capture 500k packets.
>>>
>>> What I observe is that the kernel allocates buffers from the
>>> slaballoctor for these packets but it takes buffers of 4k while in
>>> fact the packet is only 1k (This means 2G of kernel memory  is bein=
g
>>> used).
>>> Is it possible to fine-tune this or is that an alternative for this=
?
>>>
>>> I already investigated the PACKET_RX_RING solution. This has the
>>> advantage that the buffers can be 1k but  I do not want to consume
>>> 500Mb of virtual memory in my application which is running on MIPS =
in
>>> 32 bit mode where I only have 2G available in user space.
>>>
>>
>> Need some information
>>
>> - Kernel version
>> - Driver used
>> - MTU of the link  (default MTU is 1500)
>>
>
> - Kernel version is: Linux version 2.6.32.27-Cavium-Octeon
> - MTU:1500
> - About the driver I do not know how to see that but I use Cavium
> octeon reference board.  This is a part of the bootlog:
> Intel(R) PRO/1000 Network Driver - version 7.3.21-k5-NAPI
> Copyright (c) 1999-2006 Intel Corporation.
> e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
> e1000e: Copyright (c) 1999-2008 Intel Corporation.
> Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
> octeon_mgmt 1070000100000.ethernet: Version 2.0
> octeon_mgmt 1070000100800.ethernet: Version 2.0
>
> The complete log is below.
> Thanks.
>
> # dmesg
> Linux version 2.6.32.27-Cavium-Octeon (meeusr@devws156) (gcc version
> 4.3.3 (Cavium Inc. Version: 2_3_0 build 116) ) #34 SMP Mon Oct 8
> 14:38:02 CEST 2012
> CVMSEG size: 2 cache lines (256 bytes)pped:0
> Cavium Inc. SDK-2.30/statistics/tx_dropped:0
> bootconsole [early0] enabledics/multicast:0
> CPU revision is: 000d9008 (Cavium Octeon II)
> Checking for the multiply/shift bug... no.errors:0
> Checking for the daddiu bug... no._over_errors:0
> Determined physical RAM map:ics/rx_crc_errors:0
>  memory: 0000000000742000 @ 0000000000f9e000 (usable after init)
>  memory: 000000000a800000 @ 0000000001800000 (usable)
>  memory: 0000000003c00000 @ 000000000c200000 (usable)
>  memory: 000000006f800000 @ 0000000020000000 (usable)
> Wasting 223888 bytes for tracking 3998 unused pages
> Initrd not found or empty - disabling initrdrs:0
> Using passed Device Tree.istics/tx_heartbeat_errors:0
> Placing 0MB software IO TLB between a80000000341c000 - a80000000345c0=
00
> software IO TLB at phys 0x341c000 - 0x345c000:0
> Zone PFN ranges:gmt0/statistics/tx_compressed:0
>   DMA32    0x00000f9e -> 0x000f0000
>   Normal   0x000f0000 -> 0x000f0000.5.0 (November 4, 2008)
> Movable zone start PFN for each nodeVersion 2.0
> early_node_map[4] active PFN ranges Version 2.0
>     0: 0x00000f9e -> 0x000016e0
>     0: 0x00001800 -> 0x0000c000
>     0: 0x0000c200 -> 0x0000fe00
>     0: 0x00020000 -> 0x0008f800
> On node 0 totalpages: 516930
>   DMA32 zone: 7982 pages used for memmap
>   DMA32 zone: 0 pages reserved
>   DMA32 zone: 508948 pages, LIFO batch:31
> Cavium Hotplug: Available coremask 0x0
> PERCPU: Embedded 10 pages/cpu @a80000000347f000 s11264 r8192 d21504 u=
65536
> pcpu-alloc: s11264 r8192 d21504 u65536 alloc=3D16*4096
> pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 [0] 4 [0] 5
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: =
508948
> Kernel command line:  bootoctlinux 0 coremask=3D3f console=3DttyS0,11=
5200
> PID hash table entries: 4096 (order: 3, 32768 bytes)
> Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
> Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
> Primary instruction cache 37kB, virtually tagged, 37 way, 8 sets,
> linesize 128 bytes.
> Primary data cache 32kB, 32-way, 8 sets, linesize 128 bytes.
> Secondary unified cache 2048kB, 16-way, 1024 sets, linesize 128 bytes=
=2E
> Memory: 2027140k/2067720k available (6121k kernel code, 39892k
> reserved, 8843k data, 7432k init, 0k highmem)
> Hierarchical RCU implementation.
> NR_IRQS:453
> Calibrating delay loop (skipped) preset value.. 1600.00 BogoMIPS (lpj=
=3D8000000)
> Security Framework initialized
> Mount-cache hash table entries: 256
> Checking for the daddi bug... no.
> SMP: Booting CPU01 (CoreId  1)...
> CPU revision is: 000d9008 (Cavium Octeon II)
> SMP: Booting CPU02 (CoreId  2)...
> CPU revision is: 000d9008 (Cavium Octeon II)
> SMP: Booting CPU03 (CoreId  3)...
> CPU revision is: 000d9008 (Cavium Octeon II)
> SMP: Booting CPU04 (CoreId  4)...
> CPU revision is: 000d9008 (Cavium Octeon II)
> SMP: Booting CPU05 (CoreId  5)...
> CPU revision is: 000d9008 (Cavium Octeon II)
> Brought up 6 CPUs
> NET: Registered protocol family 16
> PCIe: Initializing port 0
> PCIe: Port 0 is SRIO, skipping.
> PCIe: Initializing port 1
> PCIe: Port 1 is SRIO, skipping.
> bio: create slab <bio-0> at 0
> SCSI subsystem initialized
> libata version 3.00 loaded.
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> Switching to clocksource OCTEON_CVMCOUNT
> NET: Registered protocol family 2
> IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
> TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
> TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
> TCP: Hash tables configured (established 262144 bind 65536)
> TCP reno registered
> NET: Registered protocol family 1
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> RPC: Registered tcp NFSv4.1 backchannel transport module.
> /proc/octeon_perf: Octeon performance counter interface loaded
> octeon_wdt: Initial granularity 5 Sec.
> octeon_gpio 1070000000800.gpio-controller: probed
> HugeTLB registered 2 MB page size, pre-allocated 0 pages
> JFFS2 version 2.2. (NAND) =A9 2001-2006 Red Hat, Inc.
> fuse init (API version 7.13)
> msgmni has been set to 3960
> alg: No test for stdrng (krng)
> io scheduler noop registered
> io scheduler anticipatory registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> Serial: 8250/16550 driver, 6 ports, IRQ sharing disabled
> brd: module loaded
> loop: module loaded
> Uniform Multi-Platform E-IDE driver
> ide-gd driver 1.18
> pata_octeon_cf 1d040000.compact-flash: version 2.2 16 bit, True IDE.
> scsi0 : pata_octeon_cf
> ata1: PATA max PIO6 cmd 900000001d040000 ctl 900000001d05000d irq 162
> SSFDC read-only Flash Translation layer
> slram: not enough parameters.
> mdio-octeon: probed
> mdio-octeon 1180000001800.mdio: Version 1.0
> mdio-octeon: probed
> mdio-octeon 1180000001900.mdio: Version 1.0
> Intel(R) PRO/1000 Network Driver - version 7.3.21-k5-NAPI
> Copyright (c) 1999-2006 Intel Corporation.
> e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
> e1000e: Copyright (c) 1999-2008 Intel Corporation.
> Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
> bonding: Warning: either miimon or arp_interval and arp_ip_target
> module parameters must be specified, otherwise bonding will not detec=
t
> link failures! see bonding.txt for detail.
> sky2 driver version 1.25
> octeon_mgmt 1070000100000.ethernet: Version 2.0
> octeon_mgmt 1070000100800.ethernet: Version 2.0
> ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> octeon-ehci 16f0000000000.ehci: Octeon EHCI
> octeon-ehci 16f0000000000.ehci: new USB bus registered, assigned bus =
number 1
> octeon-ehci 16f0000000000.ehci: irq 154, io mem 0x16f0000000000
> octeon-ehci 16f0000000000.ehci: USB 0.0 started, EHCI 1.00
> usb usb1: configuration #1 chosen from 1 choice
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 2 ports detected
> ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> octeon-ohci 16f0000000400.ohci: Octeon OHCI
> octeon-ohci 16f0000000400.ohci: new USB bus registered, assigned bus =
number 2
> octeon-ohci 16f0000000400.ohci: irq 154, io mem 0x16f0000000400
> usb usb2: configuration #1 chosen from 1 choice
> ata1.00: ATA-0: CF 1GB, 20071116, max MWDMA2
> ata1.00: 1981728 sectors, multi 0: LBA
> hub 2-0:1.0: USB hub found
> hub 2-0:1.0: 2 ports detected
> Initializing USB Mass Storage driver...
> usbcore: registered new interface driver usb-storage
> USB Mass Storage support registered.
> usbcore: registered new interface driver libusual
> i2c /dev entries driver
> i2c-octeon 1180000001000.i2c: version 2.0
> ata1.00: configured for PIO4
> rtc-ds1307 0-0068: rtc core: registered ds1337 as rtc0
> ata1.00: configured for PIO4
> ata1: EH complete
> scsi 0:0:0:0: Direct-Access     ATA      CF 1GB           2007 PQ: 0 =
ANSI: 5
> sd 0:0:0:0: [sda] 1981728 512-byte logical blocks: (1.01 GB/967 MiB)
> sd 0:0:0:0: [sda] Write Protect is off
> sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't
> support DPO or FUA
>  sda: sda1
> sd 0:0:0:0: [sda] Attached SCSI disk
> at24 0-0056: 32768 byte 24c256 EEPROM (writable)
> i2c-octeon 1180000001200.i2c: version 2.0
> i2c i2c-0: Added multiplexed i2c bus 2
> i2c i2c-0: Added multiplexed i2c bus 3
> i2c i2c-0: Added multiplexed i2c bus 4
> i2c i2c-0: Added multiplexed i2c bus 5
> i2c i2c-0: Added multiplexed i2c bus 6
> pcf857x 6-003e: gpios 248..255 on a pca8574
> i2c i2c-0: Added multiplexed i2c bus 7
> i2c i2c-0: Added multiplexed i2c bus 8
> i2c i2c-0: Added multiplexed i2c bus 9
> pca954x 0-0070: registered 8 multiplexed busses for I2C switch pca954=
8
> md: linear personality registered for level -1
> md: raid0 personality registered for level 0
> md: raid1 personality registered for level 1
> md: raid10 personality registered for level 10
> md: multipath personality registered for level -4
> md: faulty personality registered for level -5
> device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialised: dm-devel=
@redhat.com
> Registered led device: QLM0-Red
> Registered led device: QLM0-Green
> Registered led device: QLM1-Red
> Registered led device: QLM1-Green
> Registered led device: QLM2-Red
> Registered led device: QLM2-Green
> oprofile: using mips/octeon performance monitoring.
> ip_tables: (C) 2000-2006 Netfilter Core Team
> arp_tables: (C) 2002 David S. Miller
> TCP cubic registered
> NET: Registered protocol family 17
> Bridge firewalling registered
> 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
> All bugs added by David S. Miller <davem@redhat.com>
> L2 lock: TLB refill 256 bytes
> L2 lock: General exception 128 bytes
> L2 lock: low-level interrupt 128 bytes
> L2 lock: interrupt 640 bytes
> L2 lock: memcpy 1152 bytes
> 1180000000800.serial: ttyS0 at MMIO 0x1180000000800 (irq =3D 125) is =
a OCTEON
> console [ttyS0] enabled, bootconsole disabled
> 1180000000c00.serial: ttyS1 at MMIO 0x1180000000c00 (irq =3D 126) is =
a OCTEON
> Bootbus flash: Setting flash for 8MB flash at 0x1f400000
> phys_mapped_flash: Found 1 x16 devices at 0x0 in 8-bit bank
>  Amd/Fujitsu Extended Query Table at 0x0040
> phys_mapped_flash: Swapping erase regions for broken CFI table.
> number of CFI chips: 1
> cfi_cmdset_0002: Disabling erase-suspend-program due to code brokenne=
ss.
> NAND device: Manufacturer ID: 0x2c, Chip ID: 0x68 (Micron NAND 4GiB 3=
,3V 8-bit)
> Scanning device for bad blocks
> Bad eraseblock 0 at 0x000000000000
> Bad eraseblock 8 at 0x000000400000
> Bad eraseblock 9 at 0x000000480000
> Bad eraseblock 10 at 0x000000500000
> Bad eraseblock 11 at 0x000000580000
> Bad eraseblock 12 at 0x000000600000
> Bad eraseblock 13 at 0x000000680000
> Bad eraseblock 14 at 0x000000700000
> Bad eraseblock 72 at 0x000002400000
> Bad eraseblock 73 at 0x000002480000
> Bad eraseblock 74 at 0x000002500000
> Bad eraseblock 8080 at 0x0000fc800000
> SRIO0: Registering port
> SRIO0: Port in host mode
> SRIO1: Registering port
> SRIO1: Port in host mode
> rtc-ds1307 0-0068: setting system clock to 2001-09-17 19:32:48 UTC (1=
000755168)
> Freeing unused kernel memory: 7432k freed
> ioctl32(getty:990): Unknown cmd fd(0) cmd(00007416){t:'t';sz:0}
> arg(7f73ddc0) on /dev/ttyS0
> mgmt1: Link is up - 100/Full
> mgmt0: Link is up - 1000/Full
> device mgmt0 entered promiscuous mode
> #

The ideal solution would be to have a solution were we use a packet
ring to store the packets in but use a standard socket to receive the
packets from this ring. In this way we can combine the ideal memory
usage of the packet ring solution (in fact almost no overhead)
combined with the virtual memory that must not be wasted in the
application space.

I have no clue whether this is possible ...
