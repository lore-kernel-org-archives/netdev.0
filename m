From: satpal parmar <systems.satpal@gmail.com>
Subject: PTP + H/W time stamping + CONFIG_PREEMPT_RT_FULL == Oops in slab
Date: Thu, 21 Jun 2012 20:09:11 +0530
Message-ID: <CAGgcXb662=PbdJaMff1QfBhW06mYXgNvM1o6snunZMe=Q36Q7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:37280 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758374Ab2FUOjM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 10:39:12 -0400
Received: by ghrr11 with SMTP id r11so520023ghr.19
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 07:39:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi  All!

Recently  I successfully  integrated a certain
(http://sourceforge.net/scm/?type=3Dsvn&group_id=3D503885) open source
implementation of PTP protocol with Linux  3.0.1 running on ARM based
SoC. Since Phy  (Phyter DP 83640) on board  supported  H/W time
stamping support I am using for that for the same. Integration worked
smoothly  until I applied RT patch and enabled full preemption
(CONFIG_PREEMPT_RT_FULL).

After applying RT patch and enabling full preemption  I start getting
oops in slab allocator. I did some goggling  but got mixed results.
Some of the articles says slabs are not stable with RT patch while the
code comments in slab allocator says its preemption safe. Since I am
getting this oops only while running PTP client I am not certain if
its slab corruption issue (network traffic running smoothly).  I did
little debugging and I figure out that If I comment out h/w time
stamping in TX buy commenting out  skb_tx_timestamp from  network
drivers ndo_start_xmit function I am not getting any oops. Moreover if
I run ptp as high priority rt thread ,again I am not egtting nay oops.
Now I am got little confused as there are too many black boxes to
debug.  With RT patch, slabs, network driver, PTP client  I am not
sure which way to go. I am just wondering If anyone tried what I am
doing and came across similar issues. Or if anyone well verse in
either of these subsystem can help me eliminate some of the
possibilities.

I am not sure if this is the right mailing list. If anyone know better
forum please direct me to that.  Appreciate your patience and time.

-Satpal

Logs:

1. With CONFIG_PREEMPT_RT_FULL=3Dy

tarting kernel ...

Uncompressing Linux... done, booting the kernel.
Linux version 3.0.1-rt11-svn7595 (satpal@BTS-Server) (gcc version
4.3.3 (Sourcery G++ Lite 2009q1-203) ) #29 PREEMPT RT Thu Jun 21
19:47:06 IST 2012
CPU: ARMv7 Processor [413fc082] revision 2 (ARMv7), cr=3D10c53c7f
CPU: VIPT nonaliasing data cache, VIPT aliasing instruction cache
Machine: picodmb
Truncating RAM at 80000000-bfffffff to -afffffff (vmalloc region overla=
p).
reserved size =3D 0 at 0
Memory policy: ECC disabled, Data cache writeback
OMAP chip is TI8148
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 19=
5072
Kernel command line: console=3DttyO0,115200n8 mem=3D1024MB root=3D/dev/=
ram
rw initrd=3D0x82000000,20MB ramdisk_size=3D131072 earlyprintk
mtdparts=3Dphysmap-flash.0:512k@0(bdp0)ro,512k(bdp1)ro,128k(env0)ro,128=
k(env1)ro,2M(Kernel0),2M(Kernel1),10M(rootfs0),10M(rootfs1),10M(logs),1=
0M(rw-fs),512k(Factory)ro,128k(post),1M(misc),-(FreeNOR)
run_app=3Dno
PID hash table entries: 4096 (order: 2, 16384 bytes)
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 768MB =3D 768MB total
Memory: 754044k/754044k available, 32388k reserved, 0K highmem
Virtual kernel memory layout:
    vector  : 0xffff0000 - 0xffff1000   (   4 kB)
    fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
    DMA     : 0xffc00000 - 0xffe00000   (   2 MB)
    vmalloc : 0xf0800000 - 0xf8000000   ( 120 MB)
    lowmem  : 0xc0000000 - 0xf0000000   ( 768 MB)
    modules : 0xbf000000 - 0xc0000000   (  16 MB)
      .init : 0xc0008000 - 0xc0032000   ( 168 kB)
      .text : 0xc0032000 - 0xc045f000   (4276 kB)
      .data : 0xc0460000 - 0xc04984a0   ( 226 kB)
       .bss : 0xc04984c4 - 0xc04cb470   ( 204 kB)
Preemptible hierarchical RCU implementation.
        Verbose stalled-CPUs detection is disabled.
NR_IRQS:375
IRQ: Found an INTC at 0xfa200000 (revision 5.0) with 128 interrupts
Total of 128 interrupts on 1 active controller
OMAP clockevent source: GPTIMER1 at 20000000 Hz
Console: colour dummy device 80x30
Calibrating delay loop... 597.60 BogoMIPS (lpj=3D2988032)
pid_max: default: 32768 minimum: 301
Security Framework initialized
Mount-cache hash table entries: 512
CPU: Testing write buffer coherency: ok
devtmpfs: initialized
omap_hwmod: _populate_mpu_rt_base found no _mpu_rt_va for l3_slow
omap_hwmod: _populate_mpu_rt_base found no _mpu_rt_va for l4_slow
print_constraints: dummy:
NET: Registered protocol family 16
GPMC revision 6.0
Trying to set irq flags for IRQ375
ahci : Failed to get AHCI clock
Registered ti81xx_fb device
NSS Crypto DMA hardware revision 1.9 @ IRQ 116
bio: create slab <bio-0> at 0
omap_i2c omap_i2c.1: bus 1 rev4.0 at 100 kHz
pps_core: LinuxPPS API ver. 1 registered
pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti
<giometti@linux.it>
PTP clock support registered
Switching to clocksource gp timer
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 8, 1572864 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
UDP hash table entries: 512 (order: 3, 32768 bytes)
UDP-Lite hash table entries: 512 (order: 3, 32768 bytes)
NET: Registered protocol family 1
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
Trying to unpack rootfs image as initramfs...
rootfs image is not initramfs (no cpio magic); looks like an initrd
=46reeing initrd memory: 20480K
NetWinder Floating Point Emulator V0.97 (double precision)
omap-iommu omap-iommu.0: ducati registered
omap-iommu omap-iommu.1: sys registered
JFFS2 version 2.2. (NAND) =C2=A9 2001-2006 Red Hat, Inc.
msgmni has been set to 1512
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
omap_uart.0: ttyO0 at MMIO 0x48020000 (irq =3D 72) is a OMAP UART0
console [ttyO0] enabled
omap_uart.1: ttyO1 at MMIO 0x48022000 (irq =3D 73) is a OMAP UART1
omap_uart.2: ttyO2 at MMIO 0x48024000 (irq =3D 74) is a OMAP UART2
omap_uart.3: ttyO3 at MMIO 0x481a6000 (irq =3D 44) is a OMAP UART3
omap_uart.4: ttyO4 at MMIO 0x481a8000 (irq =3D 45) is a OMAP UART4
omap_uart.5: ttyO5 at MMIO 0x481aa000 (irq =3D 46) is a OMAP UART5
brd: module loaded
loop: module loaded
physmap platform flash device: 04000000 at 08000000
physmap-flash.0: Found 1 x16 devices at 0x0 in 16-bit bank.
Manufacturer ID 0x000089 Chip ID 0x008965
Intel/Sharp Extended Query Table at 0x010A
Intel/Sharp Extended Query Table at 0x010A
Intel/Sharp Extended Query Table at 0x010A
Intel/Sharp Extended Query Table at 0x010A
Intel/Sharp Extended Query Table at 0x010A
Using buffer write method
Using auto-unlock on power-up/resume
cfi_cmdset_0001: Erase suspend on write enabled
14 cmdlinepart partitions found on MTD device physmap-flash.0
Creating 14 MTD partitions on "physmap-flash.0":
0x000000000000-0x000000080000 : "bdp0"
0x000000080000-0x000000100000 : "bdp1"
0x000000100000-0x000000120000 : "env0"
0x000000120000-0x000000140000 : "env1"
0x000000140000-0x000000340000 : "Kernel0"
0x000000340000-0x000000540000 : "Kernel1"
0x000000540000-0x000000f40000 : "rootfs0"
0x000000f40000-0x000001940000 : "rootfs1"
0x000001940000-0x000002340000 : "logs"
0x000002340000-0x000002d40000 : "rw-fs"
0x000002d40000-0x000002dc0000 : "Factory"
0x000002dc0000-0x000002de0000 : "post"
0x000002de0000-0x000002ee0000 : "misc"
0x000002ee0000-0x000004000000 : "FreeNOR"
Generic platform RAM MTD, (c) 2004 Simtec Electronics
davinci_mdio davinci_mdio.0: davinci mdio revision 1.6
davinci_mdio davinci_mdio.0: detected phy mask fffffffd
davinci_mdio.0: probed
davinci_mdio davinci_mdio.0: phy[1]: device 0:01, driver NatSemi DP8364=
0
mousedev: PS/2 mouse device common for all mice
lm73 1-0048: hwmon0: sensor 'lm73'
lm73 1-0049: hwmon1: sensor 'lm73'
omap_i2c omap_i2c.1: controller timed out
omap_i2c omap_i2c.1: controller timed out
OMAP Watchdog Timer Rev 0x00: initial timeout 60 sec
nss_aes_mod_init: loading NSS AES driver
nss-aes nss-aes: NSS AES hw accel rev: 3.2 (context 0 @0x41140000)
nss-aes nss-aes: NSS AES hw accel rev: 3.2 (context 1 @0x41141000)
nss-aes nss-aes: NSS AES hw accel rev: 3.2 (context 2 @0x411a0000)
nss-aes nss-aes: NSS AES hw accel rev: 3.2 (context 3 @0x411a1000)
nss_aes_probe: probe() done
nss_des_mod_init: loading NSS DES driver
nss-des nss-des: NSS DES hw accel rev: 2.2 (context 0 @0x41160000)
nss-des nss-des: NSS DES hw accel rev: 2.2 (context 1 @0x41161000)
nss_des_probe: probe() done
nss_sham_mod_init: loading NSS SHA/MD5 driver
nss-sham nss-sham: NSS SHA/MD5 hw accel rev: 4.03 (context 0 @0x4110000=
0)
nss-sham nss-sham: NSS SHA/MD5 hw accel rev: 4.03 (context 1 @0x4110100=
0)
nss-sham nss-sham: NSS SHA/MD5 hw accel rev: 4.03 (context 2 @0x411c000=
0)
nss-sham nss-sham: NSS SHA/MD5 hw accel rev: 4.03 (context 3 @0x411c100=
0)
nss_sham_probe: probe() done
dsp_hpi: initialized
fpga: initialized
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 10
NET: Registered protocol family 17
NET: Registered protocol family 15
sctp: Hash tables configured (established 32768 bind 43690)
Registering the dns_resolver key type
VFP support v0.3: implementor 41 architecture 3 part 30 variant c rev 3
clock: disabling unused clocks to save power
Detected MACID=3D3:2:1:2:e0:2

System initialization...

Mounting /sys          : [OK]
Populating /dev        : [OK]
Mounting fstab         : [OK]
Mounting devpts        : [OK]
Starting unconfigured  : [OK]
Starting Net           : ## Error: "ue" not defined
[OK]
Starting Logging       : [OK]
Starting telnet daemon : [OK]
Starting setup.sh      : [OK]
Executing setup        : [OK]
---- Warning application (/root/lm_cp_pico.elf) not started -----
Starting ptpd: [OK]

Please press Enter to activate this console. env variable run_app=3Dno,
so supervisor will "free run", (to keep init happy)
RAMDISK: gzip image found at block 0
VFS: Mounted root (ext2 filesystem) on device 1:0.
devtmpfs: mounted
=46reeing init memory: 168K

CPSW phy found : id is : 0x20005ce1
**************phy_start****************
c2cc0e00:phy_start:phydev->state:4

CPSW phyless for slave=3D1
ADDRCONF(NETDEV_UP): eth0: link is not ready
c2cc0e00:phy_start_aneg:phydev->state:5
PHY: 0:01 - Link is Up - 100/Full
link up on port 1, speed 1000, full duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
bug:slab names_cache, slabp->inuse=3D -1, cachep->num:1
kernel BUG at /home/satpal/sandbox/console_p/trunk/bts/source/vendor/li=
nux/mm/slab.c:3205!
Unable to handle kernel NULL pointer dereference at virtual address 000=
00000
pgd =3D e9e08000
[00000000] *pgd=3Dae31c831, *pte=3D00000000, *ppte=3D00000000
Internal error: Oops: 817 [#1] PREEMPT
Modules linked in:
CPU: 0    Not tainted  (3.0.1-rt11-svn7595 #29)
PC is at __bug+0x20/0x2c
LR is at vprintk+0x18c/0x470
pc : [<c0041ee0>]    lr : [<c005eaa0>]    psr: 60000013
sp : ef89fea8  ip : 60000013  fp : ef89feb4
r10: ef8009c0  r9 : ef811f20  r8 : ef807e00
r7 : 0000000c  r6 : 000000d0  r5 : ffffffff  r4 : c2cf92c0
r3 : 00000000  r2 : 00000000  r1 : ef89e000  r0 : 00000061
=46lags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 10c5387d  Table: a9e08019  DAC: 00000015
Process ptp-main (pid: 136, stack limit =3D 0xef89e2e8)
Stack: (0xef89fea8 to 0xef8a0000)
fea0:                   ef89ff04 ef89feb8 c00c3fd4 c0041ecc c04672a0 00=
000010
fec0: 000000d0 ef89e000 000000d0 ef811f44 ef811f30 ef811f28 ef89e000 00=
000000
fee0: ef89e000 c0484cdc ef8009c0 000000d0 ef89e000 00000000 ef89ff2c ef=
89ff08
ff00: c00c4628 c00c3d60 00120dc4 40b73490 00000002 00000000 c0462284 ef=
89e000
ff20: ef89ff54 ef89ff30 c00d2468 c00c4554 00000001 40b73490 00000002 ff=
ffff9c
ff40: c003ea28 ef89e000 ef89ff64 ef89ff58 c00d2548 c00d2450 ef89ff94 ef=
89ff68
ff60: c00c5780 c00d2540 00000002 00000000 00000026 00000100 00000000 40=
b73490
ff80: 40b72fc0 00000005 ef89ffa4 ef89ff98 c00c5840 c00c56d8 00000000 ef=
89ffa8
ffa0: c003e880 c00c5828 00000000 40b73490 00120dc4 00000002 00fc0a28 40=
b72da4
ffc0: 00000000 40b73490 40b72fc0 00000005 003d0f00 00000000 4007e134 40=
b72d94
ffe0: 00000000 40b72d68 4007b0a7 4007c154 80000010 00120dc4 a87ff0f3 7d=
3f11fa
Backtrace:
[<c0041ec0>] (__bug+0x0/0x2c) from [<c00c3fd4>] (cache_alloc_refill+0x2=
80/0x680)
[<c00c3d54>] (cache_alloc_refill+0x0/0x680) from [<c00c4628>]
(kmem_cache_alloc+0xe0/0x110)
[<c00c4548>] (kmem_cache_alloc+0x0/0x110) from [<c00d2468>]
(getname_flags+0x24/0xf0)
 r9:ef89e000 r8:c0462284 r7:00000000 r6:00000002 r5:40b73490
r4:00120dc4
[<c00d2444>] (getname_flags+0x0/0xf0) from [<c00d2548>] (getname+0x14/0=
x18)
 r9:ef89e000 r8:c003ea28 r7:ffffff9c r6:00000002 r5:40b73490
r4:00000001
[<c00d2534>] (getname+0x0/0x18) from [<c00c5780>] (do_sys_open+0xb4/0x1=
3c)
[<c00c56cc>] (do_sys_open+0x0/0x13c) from [<c00c5840>] (sys_open+0x24/0=
x28)
 r7:00000005 r6:40b72fc0 r5:40b73490 r4:00000000
[<c00c581c>] (sys_open+0x0/0x28) from [<c003e880>] (ret_fast_syscall+0x=
0/0x30)
Code: e1a01000 e59f000c eb0cb576 e3a03000 (e5833000)
