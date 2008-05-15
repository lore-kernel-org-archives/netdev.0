From: Olaf Hering <olaf@aepfle.de>
Subject: dead network on JS21 with tg3 driver after flowcontrol changes
Date: Thu, 15 May 2008 14:13:40 +0200
Message-ID: <20080515121340.GA23033@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:51562 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbYEOMNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 08:13:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit ef167e27039eeaea6d3cdd5c547b082e89840bdd ([TG3]: Fix supporting
flowctrl code) breaks networking on IBM JS21 blade servers. If I revert
this change from 2.6.26-rc2-git4, nfsroot for example will work again.
There are no packages submitted, a tcpdump on a different host sees no
broadcast messages.

Any ideas how to fix this?
What info do you need from the system?
I started with arch/powerpc/configs/ppc64_defconfig and updated CONFIG_CMDLINE
for nfsroot.

....
tg3.c:v3.92 (May 2, 2008)
tg3 0000:10:04.0: enabling device (0000 -> 0002)
eth0: Tigon3 [partno(none) rev 8003 PHY(5780)] (PCIX:133MHz:64-bit) 1000Base-SX Ethernet 00:11:25:c9:07:22
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] WireSpeed[0] TSOcap[1]
eth0: dma_rwctrl[76144000] dma_mask[40-bit]
tg3 0000:10:04.1: enabling device (0000 -> 0002)
eth1: Tigon3 [partno(none) rev 8003 PHY(5780)] (PCIX:133MHz:64-bit) 1000Base-SX Ethernet 00:11:25:c9:07:23
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] TSOcap[1]
eth1: dma_rwctrl[76144000] dma_mask[40-bit]
...

full dmesg:

Using pSeries machine description
Page orders: linear mapping = 24, virtual = 12, io = 12
console [udbg0] enabled
Partition configured for 2 cpus.
CPU maps initialized for 1 thread per core
 (thread shift is 0)
Starting Linux PPC64 #3 SMP Thu May 15 13:47:10 CEST 2008
-----------------------------------------------------
ppc64_pft_size                = 0x19
physicalMemorySize            = 0x7a000000
htab_hash_mask                = 0x3ffff
-----------------------------------------------------
Initializing cgroup subsys cpuset
Linux version 2.6.26-rc2-git4 (olaf@lingonberry) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #3 SMP Thu May 15 13:47:10 CEST 2008
[boot]0012 Setup Arch
Entering add_active_range(0, 0, 499712) 0 entries of 256 used
PCI host bridge /pci@8000000f8000000  ranges:
  IO 0x00000100f4000000..0x00000100f43fffff -> 0x0000000000000000
 MEM 0x0000010080000000..0x00000100efffffff -> 0x0000000080000000 
PPC64 nvram contains 8192 bytes
Using dedicated idle loop
Top of RAM: 0x7a000000, Total RAM: 0x7a000000
Memory hole size: 0MB
Zone PFN ranges:
  DMA             0 ->   499712
  Normal     499712 ->   499712
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    0:        0 ->   499712
On node 0 totalpages: 499712
  DMA zone: 6832 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 492880 pages, LIFO batch:31
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
[boot]0015 Setup Done
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 492880
Kernel command line: debug panic=9 rw root=/dev/nfs nfsroot=10.10.4.97:/data/inst/nfs/olh ip=:::::eth1:dhcp 
[boot]0020 XICS Init
[boot]0021 XICS Done
pic: no ISA interrupt controller
PID hash table entries: 4096 (order: 12, 32768 bytes)
time_init: decrementer frequency = 14.318000 MHz
time_init: processor frequency   = 2597.400000 MHz
clocksource: timebase mult[1175e5e5] shift[22] registered
clockevent: decrementer mult[3aa] shift[16] cpu[0]
Console: colour dummy device 80x25
console handover: boot [udbg0] -> real [hvc0]
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Memory: 1942124k/1998848k available (8288k kernel code, 56096k reserved, 1412k data, 532k bss, 380k init)
SLUB: Genslabs=12, HWalign=128, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
Calibrating delay loop... 28.60 BogoMIPS (lpj=57216)
Mount-cache hash table entries: 256
clockevent: decrementer mult[3aa] shift[16] cpu[1]
Processor 1 found.
Brought up 2 CPUs
CPU0 attaching sched-domain:
 domain 0: span 0-1
  groups: 0 1
CPU1 attaching sched-domain:
 domain 0: span 0-1
  groups: 1 0
khelper used greatest stack depth: 12896 bytes left
khelper used greatest stack depth: 12320 bytes left
khelper used greatest stack depth: 11904 bytes left
net_namespace: 936 bytes
xor: measuring software checksum speed
   8regs     :  5830.000 MB/sec
   8regs_prefetch:  4644.000 MB/sec
   32regs    :  5751.000 MB/sec
   32regs_prefetch:  4601.000 MB/sec
xor: using function: 8regs (5830.000 MB/sec)
NET: Registered protocol family 16
IBM eBus Device Driver
PCI: Probing PCI hardware
IOMMU table initialized, virtual merging enabled
PCI: Probing PCI hardware done
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
NET: Registered protocol family 2
Switched to high resolution mode on CPU 0
Switched to high resolution mode on CPU 1
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
NET: Registered protocol family 1
RTAS daemon started
Total HugeTLB memory allocated, 0
JFS: nTxBlock = 8192, nTxLock = 65536
msgmni has been set to 3794 for ipc namespace c00000000082cfe8
async_tx: api initialized (sync-only)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
io scheduler noop registered
io scheduler anticipatory registered (default)
io scheduler deadline registered
io scheduler cfq registered
khelper used greatest stack depth: 10864 bytes left
vio_register_driver: driver hvc_console registering
HVSI: registered 0 devices
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
TX39/49 Serial driver version 1.11
brd: module loaded
loop: module loaded
Intel(R) PRO/1000 Network Driver - version 7.3.20-k2
Copyright (c) 1999-2006 Intel Corporation.
pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
tg3.c:v3.92 (May 2, 2008)
tg3 0000:10:04.0: enabling device (0000 -> 0002)
eth0: Tigon3 [partno(none) rev 8003 PHY(5780)] (PCIX:133MHz:64-bit) 1000Base-SX Ethernet 00:11:25:c9:07:22
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] WireSpeed[0] TSOcap[1]
eth0: dma_rwctrl[76144000] dma_mask[40-bit]
tg3 0000:10:04.1: enabling device (0000 -> 0002)
eth1: Tigon3 [partno(none) rev 8003 PHY(5780)] (PCIX:133MHz:64-bit) 1000Base-SX Ethernet 00:11:25:c9:07:23
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] TSOcap[1]
eth1: dma_rwctrl[76144000] dma_mask[40-bit]
console [netcon0] enabled
netconsole: network logging started
Uniform Multi-Platform E-IDE driver
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ipr: IBM Power RAID SCSI Device Driver version: 2.4.1 (April 24, 2007)
ipr 0000:01:01.0: Found IOA with IRQ: 26
ipr 0000:01:01.0: Starting IOA initialization sequence.
ipr 0000:01:01.0: Adapter firmware version: 0616002F
ipr 0000:01:01.0: IOA initialized.
scsi0 : IBM 572E Storage Adapter
scsi 0:0:1:0: Direct-Access     IBM-ESXS ST936701SS       B51B PQ: 0 ANSI: 5
scsi 0:1:1:0: Direct-Access     IBM-ESXS ST936701SS       B51B PQ: 0 ANSI: 5
scsi: unknown device type 31
scsi 0:255:255:255: No Device         IBM      572E001          0150 PQ: 0 ANSI: 0
vio_register_driver: driver ibmvscsi registering
st: Version 20080224, fixed bufsize 32768, s/g segs 256
Driver 'st' needs updating - please use bus_type methods
Driver 'sd' needs updating - please use bus_type methods
sd 0:0:1:0: [sda] 71096640 512-byte hardware sectors (36401 MB)
sd 0:0:1:0: [sda] Write Protect is off
sd 0:0:1:0: [sda] Mode Sense: bb 00 10 08
sd 0:0:1:0: [sda] Write cache: disabled, read cache: enabled, supports DPO and FUA
sd 0:0:1:0: [sda] 71096640 512-byte hardware sectors (36401 MB)
sd 0:0:1:0: [sda] Write Protect is off
sd 0:0:1:0: [sda] Mode Sense: bb 00 10 08
sd 0:0:1:0: [sda] Write cache: disabled, read cache: enabled, supports DPO and FUA
 sda: sda1 sda2 sda3
sd 0:0:1:0: [sda] Attached SCSI disk
sd 0:1:1:0: [sdb] 71096640 512-byte hardware sectors (36401 MB)
sd 0:1:1:0: [sdb] Write Protect is off
sd 0:1:1:0: [sdb] Mode Sense: bb 00 10 08
sd 0:1:1:0: [sdb] Write cache: disabled, read cache: enabled, supports DPO and FUA
sd 0:1:1:0: [sdb] 71096640 512-byte hardware sectors (36401 MB)
sd 0:1:1:0: [sdb] Write Protect is off
sd 0:1:1:0: [sdb] Mode Sense: bb 00 10 08
sd 0:1:1:0: [sdb] Write cache: disabled, read cache: enabled, supports DPO and FUA
 sdb: sdb1 sdb2 sdb3
sd 0:1:1:0: [sdb] Attached SCSI disk
Driver 'sr' needs updating - please use bus_type methods
sd 0:0:1:0: Attached scsi generic sg0 type 0
sd 0:1:1:0: Attached scsi generic sg1 type 0
scsi 0:255:255:255: Attached scsi generic sg2 type 31
ieee1394: raw1394: /dev/raw1394 device initialized
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:40:00.0: OHCI Host Controller
ohci_hcd 0000:40:00.0: new USB bus registered, assigned bus number 1
ohci_hcd 0000:40:00.0: irq 19, io mem 0x100b0001000
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 3 ports detected
ohci_hcd 0000:40:00.1: OHCI Host Controller
ohci_hcd 0000:40:00.1: new USB bus registered, assigned bus number 2
ohci_hcd 0000:40:00.1: irq 19, io mem 0x100b0000000
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 3 ports detected
mice: PS/2 mouse device common for all mice
i2c /dev entries driver
md: linear personality registered for level -1
md: raid0 personality registered for level 0
md: raid1 personality registered for level 1
md: raid10 personality registered for level 10
raid6: int64x1   1389 MB/s
raid6: int64x2   1883 MB/s
raid6: int64x4   1900 MB/s
raid6: int64x8   1947 MB/s
raid6: altivecx1  3885 MB/s
raid6: altivecx2  4572 MB/s
raid6: altivecx4  5239 MB/s
raid6: altivecx8  4743 MB/s
raid6: using algorithm altivecx4 (5239 MB/s)
md: raid6 personality registered for level 6
md: raid5 personality registered for level 5
md: raid4 personality registered for level 4
device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initialised: dm-devel@redhat.com
EDAC MC: Ver: 2.1.0 May 15 2008
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
oprofile: using ppc64/970MP performance monitoring.
IPv4 over IPv4 tunneling driver
TCP cubic registered
NET: Registered protocol family 17
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
registered taskstats version 1
/home/olaf/kernel/git/bug390314/linux-2.6.26-rc2/drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
Sending DHCP requests .<6>tg3: eth1: Link is up at 1000 Mbps, full duplex.
tg3: eth1: Flow control is off for TX and off for RX.
., OK
IP-Config: Got DHCP answer from 10.10.4.97, my address is 10.10.1.110
IP-Config: Complete:
     device=eth1, addr=10.10.1.110, mask=255.255.0.0, gw=10.10.0.8,
     host=carambola, domain=suse.de, nis-domain=suse.de,
     bootserver=10.10.4.97, rootserver=10.10.4.97, rootpath=
md: Autodetecting RAID arrays.
md: Scanned 0 and added 0 devices.
md: autorun ...
md: ... autorun DONE.
Looking up port of RPC 100003/2 on 10.10.4.97
Looking up port of RPC 100005/1 on 10.10.4.97
VFS: Mounted root (nfs filesystem).
Freeing unused kernel memory: 380k freed
mount used greatest stack depth: 7504 bytes left
