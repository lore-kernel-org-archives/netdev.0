From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Fri, 28 Jul 2006 12:11:09 +0200
Message-ID: <20060728101109.GA25854@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tbm@cyrius.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:20394 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S932607AbWG1KLL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 06:11:11 -0400
To: romieu@fr.zoreil.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

We're currently working on getting the Thecus n2100 supported in 2.6.

	http://www.thecus.com/products_over.php?cid=1&pid=1

Amongst other nice goodies, it has two on-board RTL8110SB gigabit
controllers.  The realtek-supplied 'r1000' driver kind of sort of works,
if you don't mind the machine hanging or crashing if you unplug the cable
at the wrong moment.

The in-kernel 'r8169' drivers in 2.6.17 and 2.6.18-rc2 appear to work
initially, but they don't actually seem to transmit any packets on the
wire, nor do they receive any.

Boot logs from 2.6.17 and 2.6.18-rc2 attached.  Apart from the MAC
address for eth1 being incorrect (boot loader bug, being worked on)
there don't seem to be any strange messages or errors.

It doesn't seem to be a PHY configuration issue -- with a custom program
to dump the MDIO registers (is there any reason r8169 doesn't support
mii-tool, by the way?  will you take a patch to add that?), we get the
following results, with only minor differences that shouldn't be causing
this issue:

r1000
0000  1000 796d 001c c913 0de1 45e1 0007 2001
0008  45e1 0300 0000 0000 1007 f880 0000 3000
0010  0060 6c00 0000 2d40 0060 0000 0400 2108
0018  2740 8c00 0040 0162 846c 0000 0123 0000

r8169
0000  1000 796d 001c c913 0de1 45e1 0007 2001
0008  45e1 0200 0000 0000 1007 f880 0000 3000
0010  0060 6c00 0000 2c40 0060 0000 0400 2108
0018  2740 8c00 0040 0162 846c 0000 0123 0000

Just wondering if you've seen this kind of behavior before before I dig
into it further?  I'm pretty sure the hardware is okay, since r1000 works,
and the on-board SATA and UHCI/EHCI USB work fine as well.


cheers,
Lennert



2.6.18-rc2, r8169
=================
Using base address 0x00218000 and length 0x0017e3a8
Uncompressing Linux.............................................................
Linux version 2.6.18-rc2 (buytenh@psi.wantstofly.org) (gcc version 4.0.1) #6 We6
CPU: XScale-80219 [69052e30] revision 0 (ARMv5TE), cr=0000397f
Machine: Thecus N2100
Memory policy: ECC disabled, Data cache writeback
CPU0: D VIVT undefined 5 cache
CPU0: I cache: 32768 bytes, associativity 32, 32 byte lines, 32 sets
CPU0: D cache: 32768 bytes, associativity 32, 32 byte lines, 32 sets
Built 1 zonelists.  Total pages: 32768
Kernel command line: console=ttyS0,115200 root=/dev/nfs ip=bootp mem=128M
PID hash table entries: 1024 (order: 10, 4096 bytes)
Console: colour dummy device 80x30
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
Memory: 128MB = 128MB total
Memory: 126592KB available (2681K code, 459K data, 104K init)
Mount-cache hash table entries: 512
CPU: Testing write buffer coherency: ok
NET: Registered protocol family 16
PCI: bus0: Fast back to back transfers disabled
SCSI subsystem initialized
NET: Registered protocol family 2
IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
TCP established hash table entries: 4096 (order: 2, 16384 bytes)
TCP bind hash table entries: 2048 (order: 1, 8192 bytes)
TCP: Hash tables configured (established 4096 bind 2048)
TCP reno registered
NetWinder Floating Point Emulator V0.97 (double precision)
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
JFFS2 version 2.2. (NAND) (C) 2001-2006 Red Hat, Inc.
SGI XFS with ACLs, security attributes, no debug enabled
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
serial8250.0: ttyS0 at MMIO 0xfe800000 (irq = 0) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 8192K size 1024 blocksize
Intel(R) PRO/1000 Network Driver - version 7.1.9-k2-NAPI
Copyright (c) 1999-2006 Intel Corporation.
e100: Intel(R) PRO/100 Network Driver, 3.5.10-k2-NAPI
e100: Copyright(c) 1999-2005 Intel Corporation
r8169 Gigabit Ethernet driver 2.2LK loaded
eth0: RTL8169 at 0xc8850200, 00:14:fd:10:27:72, IRQ 27
r8169 Gigabit Ethernet driver 2.2LK loaded
eth1: RTL8169 at 0xc8852300, 00:14:fd:10:00:00, IRQ 28
physmap platform flash device: 01000000 at f0000000
physmap-flash.0: Found 1 x16 devices at 0x0 in 16-bit bank
 Intel/Sharp Extended Query Table at 0x0031
Using buffer write method
cfi_cmdset_0001: Erase suspend on write enabled
cmdlinepart partition parsing not available
Searching for RedBoot partition table in physmap-flash.0 at offset 0xfe0000
6 RedBoot partitions found on MTD device physmap-flash.0
Creating 6 MTD partitions on "physmap-flash.0":
0x00000000-0x00040000 : "RedBoot"
0x00040000-0x00d40000 : "ramdisk"
0x00d40000-0x00ea0000 : "kernel"
0x00ea0000-0x00fc0000 : "user"
0x00fc0000-0x00fc1000 : "RedBoot config"
0x00fe0000-0x01000000 : "FIS directory"
mice: PS/2 mouse device common for all mice
i2c /dev entries driver
md: raid0 personality registered for level 0
md: raid1 personality registered for level 1
md: md driver 0.90.3 MAX_MD_DEVS=256, MD_SB_DISKS=27
md: bitmap version 4.39
device-mapper: ioctl: 4.7.0-ioctl (2006-06-24) initialised: dm-devel@redhat.com
TCP bic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
r8169: eth0: link down
r8169: eth1: link down
r8169: eth0: link up
Sending BOOTP requests ......
[ nothing happens, it never sends or receives any packets ]



2.6.17, r1000 (r1000 debug enabled)
=============
Linux version 2.6.17 (Debian 2.6.17-5) (maks@sternwelten.at) (gcc version 4.1.2 20060727 (prerelease)) #12 Fri Jul 28 08:21:17 UTC 2006
CPU: XScale-IOP8032x Family [69052e30] revision 0 (ARMv5TE)
Machine ID: 1101 (0x44d)
Machine: Thecus N2100
Memory policy: ECC disabled, Data cache writeback
On node 0 totalpages: 32768
  DMA zone: 32768 pages, LIFO batch:7
CPU0: D VIVT undefined 5 cache
CPU0: I cache: 32768 bytes, associativity 32, 32 byte lines, 32 sets
CPU0: D cache: 32768 bytes, associativity 32, 32 byte lines, 32 sets
Built 1 zonelists
Kernel command line: console=ttyS0,115200 root=/dev/sda3 mem=128M@0xa0000000
PID hash table entries: 1024 (order: 10, 4096 bytes)
Console: colour dummy device 80x30
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
Memory: 128MB = 128MB total
Memory: 127232KB available (2008K code, 475K data, 88K init)
Calibrating delay loop... 593.10 BogoMIPS (lpj=2965504)
Security Framework v1.0.0 initialized
Capability LSM initialized
Mount-cache hash table entries: 512
CPU: Testing write buffer coherency: ok
NET: Registered protocol family 16
PCI: bus0: Fast back to back transfers disabled
SCSI subsystem initialized
NET: Registered protocol family 2
IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
TCP established hash table entries: 4096 (order: 2, 16384 bytes)
TCP bind hash table entries: 2048 (order: 1, 8192 bytes)
TCP: Hash tables configured (established 4096 bind 2048)
TCP reno registered
NetWinder Floating Point Emulator V0.97 (double precision)
audit: initializing netlink socket (disabled)
audit(0.450:1): initialized
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
JFFS2 version 2.2. (NAND) (C) 2001-2003 Red Hat, Inc.
Initializing Cryptographic API
io scheduler noop registered
io scheduler anticipatory registered (default)
io scheduler deadline registered
io scheduler cfq registered
Serial: 8250/16550 driver $Revision: 1.90 $ 2 ports, IRQ sharing disabled
serial8250: ttyS0 at MMIO 0xfe800000 (irq = 28) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 8192K size 1024 blocksize
r1000: -------------------------- 
r1000: dev->mtu = 1500 
r1000: priv->curr_mtu_size = 1500 
r1000: priv->tx_pkt_len = 1514 
r1000: priv->rx_pkt_len = 1514 
r1000: priv->hw_rx_pkt_len = 1522 
r1000: -------------------------- 
eth0: Identified chip type is 'RTL8169SB/8110SB'.
eth0: r10001.02, the Linux device driver for Realtek Ethernet Controllers at 0xfe000000, 00:14:fd:10:27:74, IRQ 27
r1000: priv->mcfg=4, priv->pcfg=3
r1000: Set MAC Reg C+CR Offset 0x82h = 0x01h
eth0: Auto-negotiation Enabled.
eth0: 100Mbps Full-duplex operation.
r1000: priv->linkstatus = 0x08
Realtek RTL8169/8110 Family Gigabit Ethernet Network Adapter
Driver version:1.02
Released date:2006/02/23
Link Status:Linked
Link Speed:100Mbps
Duplex mode:Full-Duplex
I/O Base:0xFE000000(I/O port)
IRQ:27
r1000: -------------------------- 
r1000: dev->mtu = 1500 
r1000: priv->curr_mtu_size = 1500 
r1000: priv->tx_pkt_len = 1514 
r1000: priv->rx_pkt_len = 1514 
r1000: priv->hw_rx_pkt_len = 1522 
r1000: -------------------------- 
eth1: Identified chip type is 'RTL8169SB/8110SB'.
eth1: r10001.02, the Linux device driver for Realtek Ethernet Controllers at 0xfe000400, 00:14:fd:10:00:00, IRQ 28
r1000: priv->mcfg=4, priv->pcfg=3
r1000: Set MAC Reg C+CR Offset 0x82h = 0x01h
eth1: Auto-negotiation Enabled.
r1000: priv->linkstatus = 0x04
Realtek RTL8169/8110 Family Gigabit Ethernet Network Adapter
Driver version:1.02
Released date:2006/02/23
Link Status:Not Linked
I/O Base:0xFE000400(I/O port)
IRQ:28
libata version 1.20 loaded.
sata_sil 0000:00:03.0: version 0.9
ata1: SATA max UDMA/100 cmd 0xC885E080 ctl 0xC885E08A bmdma 0xC885E000 irq 29
ata2: SATA max UDMA/100 cmd 0xC885E0C0 ctl 0xC885E0CA bmdma 0xC885E008 irq 29
ata1: SATA link down (SStatus 0)
scsi0 : sata_sil
ata2: SATA link up 1.5 Gbps (SStatus 113)
ata2: dev 0 cfg 49:2f00 82:7c6b 83:7f69 84:4773 85:7c69 86:3e01 87:4763 88:207f
ata2: dev 0 ATA-7, max UDMA/133, 586114704 sectors: LBA48
ata2: dev 0 configured for UDMA/100
scsi1 : sata_sil
  Vendor: ATA       Model: Maxtor 6V300F0    Rev: VA11
  Type:   Direct-Access                      ANSI SCSI revision: 05
SCSI device sda: 586114704 512-byte hdwr sectors (300091 MB)
sda: Write Protect is off
sda: Mode Sense: 00 3a 00 00
SCSI device sda: drive cache: write back
SCSI device sda: 586114704 512-byte hdwr sectors (300091 MB)
sda: Write Protect is off
sda: Mode Sense: 00 3a 00 00
SCSI device sda: drive cache: write back
 sda: sda1 sda2 < sda5 > sda3
sd 1:0:0:0: Attached scsi disk sda
i2c /dev entries driver
NET: Registered protocol family 26
TCP bic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem).
Freeing init memory: 88K
Adding 506008k swap on /dev/sda5.  Priority:-1 extents:1 across:506008k
EXT3 FS on sda3, internal journal
r1000: Set MAC Reg C+CR Offset 0xE0: bit-3.
r1000: FIX PCS -> r1000_request_timer
r1000: request_timer at 0xc7d402d0
r1000: eth0: r1000_open() alloc_rxskb_cnt = 1024
r1000: r1000_start_xmit: TX pkt_size = 342
r1000: r1000_rx_interrupt: RX pkt_size = 590
r1000: r1000_start_xmit: TX pkt_size = 342
r1000: r1000_rx_interrupt: RX pkt_size = 590
r1000: r1000_start_xmit: TX pkt_size = 42
r1000: r1000_rx_interrupt: RX pkt_size = 60
r1000: r1000_start_xmit: TX pkt_size = 67
r1000: r1000_rx_interrupt: RX pkt_size = 142
r1000: r1000_start_xmit: TX pkt_size = 67
r1000: r1000_rx_interrupt: RX pkt_size = 142
r1000: r1000_start_xmit: TX pkt_size = 67
r1000: r1000_rx_interrupt: RX pkt_size = 142
r1000: r1000_start_xmit: TX pkt_size = 67
r1000: r1000_rx_interrupt: RX pkt_size = 142



2.6.17, r8169
=============
Linux version 2.6.17 (Debian 2.6.17-5) (maks@sternwelten.at) (gcc version 4.1.2 20060727 (prerelease)) #17 Fri Jul 28 09:07:36 UTC 2006
CPU: XScale-80219 [69052e30] revision 0 (ARMv5TE)
Machine ID: 1101 (0x44d)
Machine: Thecus N2100
Memory policy: ECC disabled, Data cache writeback
On node 0 totalpages: 32768
  DMA zone: 32768 pages, LIFO batch:7
CPU0: D VIVT undefined 5 cache
CPU0: I cache: 32768 bytes, associativity 32, 32 byte lines, 32 sets
CPU0: D cache: 32768 bytes, associativity 32, 32 byte lines, 32 sets
Built 1 zonelists
Kernel command line: console=ttyS0,115200 root=/dev/sda3 mem=128M@0xa0000000
PID hash table entries: 1024 (order: 10, 4096 bytes)
Console: colour dummy device 80x30
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
Memory: 128MB = 128MB total
Memory: 127232KB available (2012K code, 477K data, 88K init)
Calibrating delay loop... 593.10 BogoMIPS (lpj=2965504)
Security Framework v1.0.0 initialized
Capability LSM initialized
Mount-cache hash table entries: 512
CPU: Testing write buffer coherency: ok
NET: Registered protocol family 16
PCI: bus0: Fast back to back transfers disabled
SCSI subsystem initialized
NET: Registered protocol family 2
IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
TCP established hash table entries: 4096 (order: 2, 16384 bytes)
TCP bind hash table entries: 2048 (order: 1, 8192 bytes)
TCP: Hash tables configured (established 4096 bind 2048)
TCP reno registered
NetWinder Floating Point Emulator V0.97 (double precision)
audit: initializing netlink socket (disabled)
audit(0.560:1): initialized
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
JFFS2 version 2.2. (NAND) (C) 2001-2003 Red Hat, Inc.
Initializing Cryptographic API
io scheduler noop registered
io scheduler anticipatory registered (default)
io scheduler deadline registered
io scheduler cfq registered
Serial: 8250/16550 driver $Revision: 1.90 $ 2 ports, IRQ sharing disabled
serial8250: ttyS0 at MMIO 0xfe800000 (irq = 28) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 8192K size 1024 blocksize
r8169 Gigabit Ethernet driver 2.2LK loaded
r8169: mac_version == Unknown
r8169: phy_version == RTL_GIGA_PHY_VER_D (0000)
eth0: Identified chip type is 'RTL8169s/8110s'.
eth0: RTL8169 at 0xc885e200, 00:14:fd:10:27:74, IRQ 27
r8169: mac_version == Unknown
r8169: phy_version == RTL_GIGA_PHY_VER_D (0000)
r8169: MAC version != 0 && PHY version == 0 or 1
r8169: Do final_reg2.cfg
r8169: Set MAC Reg C+CR Offset 0x82h = 0x01h
r8169 Gigabit Ethernet driver 2.2LK loaded
r8169: mac_version == Unknown
r8169: phy_version == RTL_GIGA_PHY_VER_D (0000)
eth1: Identified chip type is 'RTL8169s/8110s'.
eth1: RTL8169 at 0xc8860300, 00:14:fd:10:00:00, IRQ 28
r8169: mac_version == Unknown
r8169: phy_version == RTL_GIGA_PHY_VER_D (0000)
r8169: MAC version != 0 && PHY version == 0 or 1
r8169: Do final_reg2.cfg
r8169: Set MAC Reg C+CR Offset 0x82h = 0x01h
libata version 1.20 loaded.
sata_sil 0000:00:03.0: version 0.9
sata_sil 0000:00:03.0: Applying R_ERR on DMA activate FIS errata fix
ata1: SATA max UDMA/100 cmd 0xC8862080 ctl 0xC886208A bmdma 0xC8862000 irq 29
ata2: SATA max UDMA/100 cmd 0xC88620C0 ctl 0xC88620CA bmdma 0xC8862008 irq 29
ata1: SATA link down (SStatus 0)
scsi0 : sata_sil
ata2: SATA link up 1.5 Gbps (SStatus 113)
ata2: dev 0 cfg 49:2f00 82:7c6b 83:7f69 84:4773 85:7c69 86:3e01 87:4763 88:007f
ata2: dev 0 ATA-7, max UDMA/133, 586114704 sectors: LBA48
ata2: dev 0 configured for UDMA/100
scsi1 : sata_sil
  Vendor: ATA       Model: Maxtor 6V300F0    Rev: VA11
  Type:   Direct-Access                      ANSI SCSI revision: 05
SCSI device sda: 586114704 512-byte hdwr sectors (300091 MB)
sda: Write Protect is off
sda: Mode Sense: 00 3a 00 00
SCSI device sda: drive cache: write back
SCSI device sda: 586114704 512-byte hdwr sectors (300091 MB)
sda: Write Protect is off
sda: Mode Sense: 00 3a 00 00
SCSI device sda: drive cache: write back
 sda: sda1 sda2 < sda5 > sda3
sd 1:0:0:0: Attached scsi disk sda
i2c /dev entries driver
NET: Registered protocol family 26
TCP bic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda3, internal journal
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem).
Freeing init memory: 88K
Adding 506008k swap on /dev/sda5.  Priority:-1 extents:1 across:506008k
EXT3 FS on sda3, internal journal
r8169: eth0: link up
