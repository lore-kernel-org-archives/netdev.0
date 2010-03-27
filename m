From: =?ISO-8859-15?Q?Thomas_M=FCller?= <thomas@mathtm.de>
Subject: Regression in virtio_net causing kernel BUG when running under VirtualBox
 (bisected)
Date: Sat, 27 Mar 2010 15:32:39 +0100
Message-ID: <4BAE1707.2050803@mathtm.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020604050800030104080406"
Cc: linux-kernel@vger.kernel.org,
	=?ISO-8859-15?Q?Thomas_M=FCller?= <thomas@mathtm.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:62422 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348Ab0C0Oco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 10:32:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020604050800030104080406
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Hello,

I'm running Linux under VirtualBox 3.1.6 with a single virtual CPU
without any third party drivers.

Commit 9ab86bbcf8be755256f0a5e994e0b38af6b4d399
(virtio_net: Defer skb allocation in receive path)
caused a regression which results in a kernel bug and subsequent
hang at every boot.

I have attached the complete output during boot.

Please CC me on reply as I'm not subscribed to the mailing lists.


Best regards,
Thomas



------------[ cut here ]------------
kernel BUG at include/linux/scatterlist.h:65!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/devices/virtual/tty/tty56/uevent
CPU 0
Pid: 299, comm: modprobe Not tainted 2.6.33-rc5-00614-g9ab86bb #15 /VirtualBox
RIP: 0010:[<ffffffffa0026271>]  [<ffffffffa0026271>] sg_set_buf+0x46/0x74 [virtio_net]
RSP: 0000:ffff88007a615bd8  EFLAGS: 00010286
RAX: ffffea0001ac86b0 RBX: ffff88007a615c18 RCX: 0000000087654321
RDX: 0000000000000246 RSI: ffff88007a6fa2b0 RDI: ffff88007a6fa2b0
RBP: ffff88007a615bf8 R08: 0000000000000020 R09: 0000000000000640
R10: ffff88007a615c08 R11: ffff88007d098000 R12: ffff88007a6fa2b0
R13: 000000000000000a R14: 0000160000000000 R15: ffff88007a615c98
FS:  00007f9d6b27c700(0000) GS:ffff880004a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fec3fcd72c0 CR3: 000000007a43c000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 299, threadinfo ffff88007a614000, task ffff88007b8b2470)
Stack:
 ffff88007a615bf8 ffff88007a6fa280 ffff88007a615c18 ffff88007b980880
<0> ffff88007a615c88 ffffffffa0026a08 ffff88007a615c18 ffffffff8107d5c1
<0> ffff88007a615c48 0000000000000246 0000000000000010 ffff88007b980000
Call Trace:
 [<ffffffffa0026a08>] add_recvbuf_small+0x66/0xac [virtio_net]
 [<ffffffff8107d5c1>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff81454932>] ? mutex_unlock+0xe/0x10
 [<ffffffff813ccae6>] ? __rtnl_unlock+0x15/0x17
 [<ffffffffa0026b55>] try_fill_recv+0x107/0x155 [virtio_net]
 [<ffffffff813ccacf>] ? rtnl_unlock+0xe/0x10
 [<ffffffffa0026f6b>] virtnet_probe+0x3c8/0x46f [virtio_net]
 [<ffffffffa0026151>] ? skb_recv_done+0x0/0x3f [virtio_net]
 [<ffffffffa002610d>] ? skb_xmit_done+0x0/0x44 [virtio_net]
 [<ffffffffa000007c>] ? add_status+0x32/0x3a [virtio]
 [<ffffffffa00002df>] virtio_dev_probe+0xb7/0xdb [virtio]
 [<ffffffff812e30a3>] driver_probe_device+0xed/0x21a
 [<ffffffff812e322d>] __driver_attach+0x5d/0x81
 [<ffffffff812e31d0>] ? __driver_attach+0x0/0x81
 [<ffffffff812e2507>] bus_for_each_dev+0x59/0x8e
 [<ffffffff812e2e2a>] driver_attach+0x1e/0x20
 [<ffffffff812e2a4a>] bus_add_driver+0xd8/0x242
 [<ffffffff812e3534>] driver_register+0x9e/0x10f
 [<ffffffffa000b000>] ? init+0x0/0x12 [virtio_net]
 [<ffffffffa0000441>] register_virtio_driver+0x27/0x2a [virtio]
 [<ffffffffa000b010>] init+0x10/0x12 [virtio_net]
 [<ffffffff8100207d>] do_one_initcall+0x72/0x18a
 [<ffffffff8108b116>] sys_init_module+0xd8/0x23a
 [<ffffffff81009bf2>] system_call_fastpath+0x16/0x1b
Code: 49 89 f4 e8 f2 ce 00 e1 48 c1 e8 0c 48 b9 00 00 00 00 00 ea ff ff 48 8b 53 08 48 6b c0 38 48
01 c8 b9 21 43 65 87 48 39 0b 74 04 <0f> 0b eb fe f6 c2 01 74 04 0f 0b eb fe 83 e2 03 41 81 e4 ff 0f
RIP  [<ffffffffa0026271>] sg_set_buf+0x46/0x74 [virtio_net]
 RSP <ffff88007a615bd8>
---[ end trace 0110e718da6da1ad ]---

--------------020604050800030104080406
Content-Type: text/plain;
 name="boot.txt"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment;
 filename="boot.txt"

Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.33-rc5-00614-g9ab86bb (thomas@Rawhide-virt) (gcc version 4.4.3 20100226 (Red Hat 4.4.3-8) (GCC) ) #15 SMP Sat Mar 27 14:09:46 CET 2010
Command line: ro root=UUID=5bd27a38-a65f-451b-ad4d-096afb2dff69  LANG=de_DE.UTF-8 SYSFONT=latarcyrheb-sun16 KEYBOARDTYPE=pc KEYTABLE=de-latin1 vga=0x307 console=tty0 console=ttyS0,9600n8
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000007fff0000 (usable)
 BIOS-e820: 000000007fff0000 - 0000000080000000 (ACPI data)
 BIOS-e820: 00000000fffc0000 - 0000000100000000 (reserved)
NX (Execute Disable) protection: active
DMI 2.5 present.
No AGP bridge found
last_pfn = 0x7fff0 max_arch_pfn = 0x400000000
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
CPU MTRRs all blank - virtualized system.
found SMP MP-table at [ffff88000009fff0] 9fff0
init_memory_mapping: 0000000000000000-000000007fff0000
RAMDISK: 37c37000 - 37fef3d1
ACPI: RSDP 00000000000e0000 00024 (v02 VBOX  )
ACPI: XSDT 000000007fff0030 00034 (v01 VBOX   VBOXXSDT 00000001 ASL  00000061)
ACPI: FACP 000000007fff00f0 000F4 (v04 VBOX   VBOXFACP 00000001 ASL  00000061)
ACPI: DSDT 000000007fff0270 01A0C (v01 VBOX   VBOXBIOS 00000002 INTL 20050309)
ACPI: FACS 000000007fff01f0 00040
ACPI: APIC 000000007fff0230 00040 (v02 VBOX   VBOXAPIC 00000001 ASL  00000061)
No NUMA configuration found
Faking a node at 0000000000000000-000000007fff0000
Bootmem setup node 0 0000000000000000-000000007fff0000
  NODE_DATA [000000000000a000 - 0000000000022fff]
  bootmap [0000000000023000 -  0000000000032fff] pages 10
(12 early reservations) ==> bootmem [0000000000 - 007fff0000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0001000000 - 00029b3020]    TEXT DATA BSS ==> [0001000000 - 00029b3020]
  #2 [0037c37000 - 0037fef3d1]          RAMDISK ==> [0037c37000 - 0037fef3d1]
  #3 [00029b4000 - 00029b4071]              BRK ==> [00029b4000 - 00029b4071]
  #4 [000009fc00 - 000009fff0]    BIOS reserved ==> [000009fc00 - 000009fff0]
  #5 [000009fff0 - 00000a0000]     MP-table mpf ==> [000009fff0 - 00000a0000]
  #6 [00000a0000 - 00000e1160]    BIOS reserved ==> [00000a0000 - 00000e1160]
  #7 [00000e1230 - 0000100000]    BIOS reserved ==> [00000e1230 - 0000100000]
  #8 [00000e1160 - 00000e1230]     MP-table mpc ==> [00000e1160 - 00000e1230]
  #9 [0000001000 - 0000003000]       TRAMPOLINE ==> [0000001000 - 0000003000]
  #10 [0000003000 - 0000007000]      ACPI WAKEUP ==> [0000003000 - 0000007000]
  #11 [0000008000 - 000000a000]          PGTABLE ==> [0000008000 - 000000a000]
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00100000
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x0007fff0
ACPI: PM-Timer IO Port: 0x4008
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-23
Using ACPI (MADT) for SMP configuration information
SMP: Allowing 1 CPUs, 0 hotplug CPUs
PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
Allocating PCI resources starting at 80000000 (gap: 80000000:7ffc0000)
Booting paravirtualized kernel on bare hardware
setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:1 nr_node_ids:1
PERCPU: Embedded 478 pages/cpu @ffff880004a00000 s1927256 r8192 d22440 u2097152
pcpu-alloc: s1927256 r8192 d22440 u2097152 alloc=1*2097152
pcpu-alloc: [0] 0 
Built 1 zonelists in Node order, mobility grouping on.  Total pages: 516903
Policy zone: DMA32
Kernel command line: ro root=UUID=5bd27a38-a65f-451b-ad4d-096afb2dff69  LANG=de_DE.UTF-8 SYSFONT=latarcyrheb-sun16 KEYBOARDTYPE=pc KEYTABLE=de-latin1 vga=0x307 console=tty0 console=ttyS0,9600n8
PID hash table entries: 4096 (order: 3, 32768 bytes)
Checking aperture...
No AGP bridge found
Memory: 2035136k/2097088k available (4471k kernel code, 388k absent, 61564k reserved, 7461k data, 2744k init)
SLUB: Genslabs=14, HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
Hierarchical RCU implementation.
NR_IRQS:4352 nr_irqs:256
Console: colour dummy device 80x25
console [tty0] enabled
console [ttyS0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:  8
... MAX_LOCK_DEPTH:          48
... MAX_LOCKDEP_KEYS:        8191
... CLASSHASH_SIZE:          4096
... MAX_LOCKDEP_ENTRIES:     16384
... MAX_LOCKDEP_CHAINS:      32768
... CHAINHASH_SIZE:          16384
 memory used by lock dependency info: 6367 kB
 per task-struct memory footprint: 2688 bytes
allocated 20971520 bytes of page_cgroup
please try 'cgroup_disable=memory' option if you don't want memory cgroups
Fast TSC calibration using PIT
Detected 2969.177 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 5938.35 BogoMIPS (lpj=2969177)
Security Framework initialized
SELinux:  Initializing.
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Mount-cache hash table entries: 256
Initializing cgroup subsys ns
Initializing cgroup subsys cpuacct
Initializing cgroup subsys memory
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
Initializing cgroup subsys net_cls
Initializing cgroup subsys blkio
mce: CPU supports 0 MCE banks
using mwait in idle threads.
Performance Events: unsupported p6 CPU model 23 no PMU driver, software events only.
SMP alternatives: switching to UP code
Freeing SMP alternatives: 29k freed
ACPI: Core revision 20091214
ftrace: converting mcount calls to 0f 1f 44 00 00
ftrace: allocating 21066 entries in 83 pages
Setting APIC routing to flat
..TIMER: vector=0x30 apic1=0 pin1=0 apic2=-1 pin2=-1
CPU0: Intel(R) Core(TM)2 Duo CPU     E8400  @ 3.00GHz stepping 06
Brought up 1 CPUs
Total of 1 processors activated (5938.35 BogoMIPS).
devtmpfs: initialized
regulator: core version 0.5
Time: 14:29:24  Date: 03/27/10
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: No dock devices found.
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci_root PNP0A03:00: ignoring host bridge windows from ACPI; boot with "pci=use_crs" to use them
ACPI: PCI Interrupt Link [LNKA] (IRQs *5 9 10 11)
ACPI: PCI Interrupt Link [LNKB] (IRQs 5 9 10 *11)
ACPI: PCI Interrupt Link [LNKC] (IRQs 5 9 *10 11)
ACPI: PCI Interrupt Link [LNKD] (IRQs 5 *9 10 11)
vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
vgaarb: loaded
SCSI subsystem initialized
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
Switching to clocksource tsc
kstop/0 used greatest stack depth: 6424 bytes left
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 6 devices
ACPI: ACPI bus type pnp unregistered
NET: Registered protocol family 2
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 10, 4718592 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
UDP hash table entries: 1024 (order: 5, 163840 bytes)
UDP-Lite hash table entries: 1024 (order: 5, 163840 bytes)
NET: Registered protocol family 1
pci 0000:00:00.0: Limiting direct PCI/PCI transfers
pci 0000:00:01.0: Activating ISA DMA hang workarounds
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 3808k freed
DMA-API: preallocated 32768 debug entries
DMA-API: debugging enabled by kernel config
platform rtc_cmos: registered platform RTC device (no PNP device found)
Intel PCLMULQDQ-NI instructions are not detected.
audit: initializing netlink socket (disabled)
type=2000 audit(1269700164.597:1): initialized
HugeTLB registered 2 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
EXT4-fs: Unable to register as ext3 (-16)
msgmni has been set to 3982
cryptomgr_test used greatest stack depth: 5880 bytes left
cryptomgr_test used greatest stack depth: 5592 bytes left
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
pciehp: PCI Express Hot Plug Controller Driver version: 0.4
acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
pci-stub: invalid id string ""
vesafb: framebuffer at 0xe0000000, mapped to 0xffffc90000d00000, using 2560k, total 32768k
vesafb: mode is 1280x1024x8, linelength=1280, pages=5
vesafb: scrolling: redraw
vesafb: Pseudocolor: size=8:8:8:8, shift=0:0:0:0
Console: switching to colour frame buffer device 160x64
fb0: VESA VGA frame buffer device
ACPI: AC Adapter [AC] (on-line)
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
ACPI: Power Button [PWRF]
input: Sleep Button as /devices/LNXSYSTM:00/LNXSLPBN:00/input/input1
ACPI: Sleep Button [SLPF]
Non-volatile memory driver v1.3
Linux agpgart interface v0.103
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
ÿserial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16450
brd: module loaded
loop: module loaded
input: Macintosh mouse button emulation as /devices/virtual/input/input2
ahci 0000:00:0d.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
ahci: SSS flag set, parallel bus scan disabled
ahci 0000:00:0d.0: AHCI 0001.0100 32 slots 1 ports 3 Gbps 0x1 impl SATA mode
ahci 0000:00:0d.0: flags: 64bit ncq stag only ccc 
scsi0 : ahci
ata1: SATA max UDMA/133 abar m8192@0xf0406000 port 0xf0406100 irq 21
scsi1 : ata_piix
scsi2 : ata_piix
ata2: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xd000 irq 14
ata3: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xd008 irq 15
Fixed MDIO Bus: probed
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:0b.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
ehci_hcd 0000:00:0b.0: EHCI Host Controller
ehci_hcd 0000:00:0b.0: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:0b.0: irq 19, io mem 0xf0405000
ehci_hcd 0000:00:0b.0: USB 2.0 started, EHCI 1.00
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.33-rc5-00614-g9ab86bb ehci_hcd
usb usb1: SerialNumber: 0000:00:0b.0
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 8 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:00:06.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
ohci_hcd 0000:00:06.0: OHCI Host Controller
ohci_hcd 0000:00:06.0: new USB bus registered, assigned bus number 2
ohci_hcd 0000:00:06.0: irq 22, io mem 0xf0404000
usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: OHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.33-rc5-00614-g9ab86bb ohci_hcd
usb usb2: SerialNumber: 0000:00:06.0
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 8 ports detected
uhci_hcd: USB Universal Host Controller Interface driver
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input3
rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one day, 114 bytes nvram
device-mapper: uevent: version 1.0.3
input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input4
device-mapper: ioctl: 4.16.0-ioctl (2009-11-05) initialised: dm-devel@redhat.com
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or
sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP cubic registered
NET: Registered protocol family 17
registered taskstats version 1
No TPM chip found, activating TPM-bypass!
  Magic number: 2:421:486
rtc_cmos rtc_cmos: setting system clock to 2010-03-27 14:29:25 UTC (1269700165)
Initalizing network drop monitor service
ata3.00: ATAPI: VBOX CD-ROM, 1.0, max UDMA/133
ata3.00: configured for UDMA/100
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-6: VBOX HARDDISK, 1.0, max UDMA/133
ata1.00: 104857600 sectors, multi 128: LBA48 NCQ (depth 31/32)
ata1.00: configured for UDMA/133
scsi 0:0:0:0: Direct-Access     ATA      VBOX HARDDISK    1.0  PQ: 0 ANSI: 5
sd 0:0:0:0: Attached scsi generic sg0 type 0
scsi 2:0:0:0: CD-ROM            VBOX     CD-ROM           1.0  PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 104857600 512-byte logical blocks: (53.6 GB/50.0 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sr0: scsi3-mmc drive: 32x/32x xa/form2 tray
Uniform CD-ROM driver Revision: 3.20
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sr 2:0:0:0: Attached scsi generic sg1 type 5
 sda: sda1 sda2 sda3
sd 0:0:0:0: [sda] Attached SCSI disk
Freeing unused kernel memory: 2744k freed
Write protecting the kernel read-only data: 10240k
Freeing unused kernel memory: 1652k freed
Freeing unused kernel memory: 1880k freed
mknod used greatest stack depth: 5424 bytes left
dracut: dracut-005-1.fc14
udevd used greatest stack depth: 5048 bytes left
udev: starting version 151
dracut: Starting plymouth daemon
%Gscsi_id used greatest stack depth: 4192 bytes left
virtio-pci 0000:00:03.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
async/2 used greatest stack depth: 3800 bytes left
%GEXT4-fs (sda3): mounted filesystem with ordered data mode
dracut: Mounted root filesystem /dev/sda3
dracut: Switching root
		Welcome to Fedora 
		Press 'I' to enter interactive startup.
udev starten: ------------[ cut here ]------------
kernel BUG at include/linux/scatterlist.h:65!
invalid opcode: 0000 [#1] SMP 
last sysfs file: /sys/devices/virtual/tty/tty56/uevent
CPU 0 
Pid: 299, comm: modprobe Not tainted 2.6.33-rc5-00614-g9ab86bb #15 /VirtualBox
RIP: 0010:[<ffffffffa0026271>]  [<ffffffffa0026271>] sg_set_buf+0x46/0x74 [virtio_net]
RSP: 0000:ffff88007a615bd8  EFLAGS: 00010286
RAX: ffffea0001ac86b0 RBX: ffff88007a615c18 RCX: 0000000087654321
RDX: 0000000000000246 RSI: ffff88007a6fa2b0 RDI: ffff88007a6fa2b0
RBP: ffff88007a615bf8 R08: 0000000000000020 R09: 0000000000000640
R10: ffff88007a615c08 R11: ffff88007d098000 R12: ffff88007a6fa2b0
R13: 000000000000000a R14: 0000160000000000 R15: ffff88007a615c98
FS:  00007f9d6b27c700(0000) GS:ffff880004a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fec3fcd72c0 CR3: 000000007a43c000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 299, threadinfo ffff88007a614000, task ffff88007b8b2470)
Stack:
 ffff88007a615bf8 ffff88007a6fa280 ffff88007a615c18 ffff88007b980880
<0> ffff88007a615c88 ffffffffa0026a08 ffff88007a615c18 ffffffff8107d5c1
<0> ffff88007a615c48 0000000000000246 0000000000000010 ffff88007b980000
Call Trace:
 [<ffffffffa0026a08>] add_recvbuf_small+0x66/0xac [virtio_net]
 [<ffffffff8107d5c1>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff81454932>] ? mutex_unlock+0xe/0x10
 [<ffffffff813ccae6>] ? __rtnl_unlock+0x15/0x17
 [<ffffffffa0026b55>] try_fill_recv+0x107/0x155 [virtio_net]
 [<ffffffff813ccacf>] ? rtnl_unlock+0xe/0x10
 [<ffffffffa0026f6b>] virtnet_probe+0x3c8/0x46f [virtio_net]
 [<ffffffffa0026151>] ? skb_recv_done+0x0/0x3f [virtio_net]
 [<ffffffffa002610d>] ? skb_xmit_done+0x0/0x44 [virtio_net]
 [<ffffffffa000007c>] ? add_status+0x32/0x3a [virtio]
 [<ffffffffa00002df>] virtio_dev_probe+0xb7/0xdb [virtio]
 [<ffffffff812e30a3>] driver_probe_device+0xed/0x21a
 [<ffffffff812e322d>] __driver_attach+0x5d/0x81
 [<ffffffff812e31d0>] ? __driver_attach+0x0/0x81
 [<ffffffff812e2507>] bus_for_each_dev+0x59/0x8e
 [<ffffffff812e2e2a>] driver_attach+0x1e/0x20
 [<ffffffff812e2a4a>] bus_add_driver+0xd8/0x242
 [<ffffffff812e3534>] driver_register+0x9e/0x10f
 [<ffffffffa000b000>] ? init+0x0/0x12 [virtio_net]
 [<ffffffffa0000441>] register_virtio_driver+0x27/0x2a [virtio]
 [<ffffffffa000b010>] init+0x10/0x12 [virtio_net]
 [<ffffffff8100207d>] do_one_initcall+0x72/0x18a
 [<ffffffff8108b116>] sys_init_module+0xd8/0x23a
 [<ffffffff81009bf2>] system_call_fastpath+0x16/0x1b
Code: 49 89 f4 e8 f2 ce 00 e1 48 c1 e8 0c 48 b9 00 00 00 00 00 ea ff ff 48 8b 53 08 48 6b c0 38 48 01 c8 b9 21 43 65 87 48 39 0b 74 04 <0f> 0b eb fe f6 c2 01 74 04 0f 0b eb fe 83 e2 03 41 81 e4 ff 0f 
RIP  [<ffffffffa0026271>] sg_set_buf+0x46/0x74 [virtio_net]
 RSP <ffff88007a615bd8>
---[ end trace 0110e718da6da1ad ]---
%Gparport_pc 00:05: reported by Plug and Play ACPI
ppdev: user-space parallel port driver
udevd-work[270]: '/sbin/modprobe -b virtio:d00000001v00001AF4' unexpected exit with status 0x000b


[  OK  ]

Rechnername Rawhide-virt einstellen:  [  OK  ]


--------------020604050800030104080406--
