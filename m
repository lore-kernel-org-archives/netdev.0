From: "Abhimanyu Rapria" <Abhimanyu@Synotek.com>
Subject: 1/3rd packets dropped by tethereal
Date: Mon, 24 Apr 2006 13:23:58 +0530
Message-ID: <6291865b0604240053j79a23a7ft3bfd6dee58fbfd0e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from pproxy.gmail.com ([64.233.166.181]:49834 "EHLO pproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1750981AbWDXHyA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 03:54:00 -0400
Received: by pproxy.gmail.com with SMTP id i49so1040685pye
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2006 00:53:59 -0700 (PDT)
To: linux-net@vger.kernel.org, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

When i ran the below command on vicidial dialer:

[root@vicidial2 ~]# tethereal -i eth0 -a duration:300 -w sample.cap
Capturing on eth0
320167
147496 packets dropped

Machine configuration:
Linux vicidial2.esselshyam.net 2.6.11-1.1369_FC4smp #1 SMP Thu Jun 2
23:08:39 EDT 2005 i686 i686 i386 GNU/Linux
Machine Model: HP dx6120 MT
http://h50025.www5.hp.com/hpcom/in_en/14_30_146_4492_44289.html

RAM 1 GB
HDD 80 GB SATA


When i ran Acterna PVA-1000 on sample.cap it showed Max Jitter about
20 % and packet loss and echo as major cause of voice degradation. MQS
was also less 2.59 where as it should be around 5.0. are packets being
dropped at interface card or at kernel and how to correct it.

on net i found:



So "1000 packets captured" means, in Tethereal and tcpdump, "1000
packets read from libpcap and processed".

What "100 packets dropped" means is that, of all the packets supplied
to the kernel's packet capture mechanism that passed the filter, 100
of them were dropped because there wasn't enough room in the kernel's
buffer for them; this means that packets aren't being read from the
kernel's capture mechanism fast enough by the application.



dmesg output:
Linux version 2.6.11-1.1369_FC4smp
(bhcompile@decompose.build.redhat.com ) (gcc version 4.0.0 20050525
(Red Hat 4.0.0-9)) #1 SMP Thu Jun 2 23:08:39 EDT 2005
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e8000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000003f7e4000 (usable)
 BIOS-e820: 000000003f7e4000 - 0000000040000000 (reserved)
 BIOS-e820: 00000000d0000000 - 00000000e0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
119MB HIGHMEM available.
896MB LOWMEM available.
found SMP MP-table at 000fe700
Using x86 segment limits to approximate NX protection
On node 0 totalpages: 260068
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 225280 pages, LIFO batch:31
  HighMem zone: 30692 pages, LIFO batch:15
DMI 2.3 present.
Using APIC driver default
ACPI: RSDP (v000 COMPAQ                                ) @ 0x000e9c10
ACPI: RSDT (v001 COMPAQ CPQ0968  0x20050405  0x00000000) @ 0x3f7f4040
ACPI: FADT (v001 COMPAQ GRANTSD  0x00000001  0x00000000) @ 0x3f7f40ec
ACPI: SSDT (v001 COMPAQ  PROJECT 0x00000001 MSFT 0x0100000e) @ 0x3f7f565a
ACPI: MADT (v001 COMPAQ GRANTSD  0x00000001  0x00000000) @ 0x3f7f4160
ACPI: ASF! (v032 COMPAQ GRANTSD  0x00000001  0x00000000) @ 0x3f7f41c8
ACPI: MCFG (v001 COMPAQ GRANTSD  0x00000001  0x00000000) @ 0x3f7f422b
ACPI: DSDT (v001 COMPAQ     DSDT 0x00000001 MSFT 0x0100000e) @ 0x00000000
ACPI: PM-Timer IO Port: 0xf808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Processor #0 15:4 APIC version 20
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Processor #1 15:4 APIC version 20
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 1 already used, trying 2
IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at 40000000 (gap: 40000000:90000000)
Built 1 zonelists
Kernel command line: ro root=LABEL=/ rhgb quiet
mapped APIC to ffffd000 (fee00000)
mapped IOAPIC to ffffc000 (fec00000)
Initializing CPU#0
CPU 0 irqstacks, hard=c042a000 soft=c040a000
PID hash table entries: 4096 (order: 12, 65536 bytes)
Detected 3191.307 MHz processor.
Using pmtmr for high-res timesource
Console: colour VGA+ 80x25
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 1024416k/1040272k available (2084k kernel code, 14928k
reserved, 769k data, 232k init, 122768k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay loop... 6307.84 BogoMIPS (lpj=3153920)
Security Framework v1.0.0 initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
selinux_register_security:  Registering secondary module capability
Capability LSM initialized as secondary
Mount-cache hash table entries: 512
CPU: After generic identify, caps: bfebfbff 20000000 00000000 00000000
0000649d 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 20000000 00000000 00000000
0000649d 00000000 00000000
monitor/mwait feature present.
using mwait in idle threads.
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 2048K
CPU: Physical Processor ID: 0
CPU: After all inits, caps: bfebf3ff 20000000 00000000 00000080
0000649d 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU0: Intel P4/Xeon Extended MCE MSRs (24) available
CPU0: Thermal monitoring enabled
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
CPU0: Intel(R) Pentium(R) 4 CPU 3.20GHz stepping 03
Booting processor 1/1 eip 3000
CPU 1 irqstacks, hard=c042b000 soft=c040b000
Initializing CPU#1
Calibrating delay loop... 6422.52 BogoMIPS (lpj=3211264)
CPU: After generic identify, caps: bfebfbff 20000000 00000000 00000000
0000649d 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 20000000 00000000 00000000
0000649d 00000000 00000000
monitor/mwait feature present.
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 2048K
CPU: Physical Processor ID: 0
CPU: After all inits, caps: bfebf3ff 20000000 00000000 00000080
0000649d 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: Intel P4/Xeon Extended MCE MSRs (24) available
CPU1: Thermal monitoring enabled
CPU1: Intel(R) Pentium(R) 4 CPU 3.20GHz stepping 03
Total of 2 processors activated (12730.36 BogoMIPS).
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 pin1=2 pin2=-1
checking TSC synchronization across 2 CPUs: passed.
softlockup thread 0 started up.
Brought up 2 CPUs
softlockup thread 1 started up.
checking if image is initramfs... it is
Freeing initrd memory: 1169k freed
NET: Registered protocol family 16
PCI: PCI BIOS revision 2.20 entry at 0xec3b7, last bus=64
PCI: Using MMCONFIG
mtrr: v2.0 (20020519)
ACPI: Subsystem revision 20050309
ACPI: Interpreter enabled
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
Boot video device is 0000:00:02.0
PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.1
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCX1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCX2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB_._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 *10 11 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 6 7 10 11 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 *11 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 10 11 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 *11 14 15)
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 *10 11 14 15)
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 *11 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 10 11 14 15) *0, disabled.
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
pnp: PnP ACPI: found 15 devices
usbcore: registered new driver usbfs
usbcore: registered new driver hub
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
pnp: 00:0b: ioport range 0x400-0x41f has been reserved
pnp: 00:0b: ioport range 0x420-0x43f has been reserved
pnp: 00:0b: ioport range 0x440-0x45f has been reserved
pnp: 00:0b: ioport range 0x460-0x47f could not be reserved
pnp: 00:0b: ioport range 0x480-0x48f has been reserved
pnp: 00:0b: ioport range 0xf800-0xf81f could not be reserved
pnp: 00:0b: ioport range 0xf820-0xf83f could not be reserved
pnp: 00:0b: ioport range 0xf840-0xf85f has been reserved
pnp: 00:0c: ioport range 0x4d0-0x4d1 has been reserved
apm: BIOS not found.
audit: initializing netlink socket (disabled)
audit(1145875179.134:1): initialized
highmem bounce pool size: 64 pages
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
SELinux:  Registering netfilter hooks
Initializing Cryptographic API
ksign: Installing public key data
Loading keyring
- Added public key 42BD35A990375F72
- User ID: Red Hat, Inc. (Kernel Module GPG key)
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
PCI: Setting latency timer of device 0000:00:1c.0 to 64
pcie_portdrv_probe->Dev[2660:8086] has invalid IRQ. Check vendor BIOS
assign_interrupt_mode Found MSI capability
Allocate Port Service[pcie00]
Allocate Port Service[pcie02]
Allocate Port Service[pcie03]
ACPI: PCI Interrupt 0000:00:1c.1[B] -> GSI 17 (level, low) -> IRQ 185
PCI: Setting latency timer of device 0000:00:1c.1 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[pcie00]
Allocate Port Service[pcie02]
Allocate Port Service[pcie03]
ACPI: Processor [CPU0] (supports 8 throttling states)
ACPI: Processor [CPU1] (supports 8 throttling states)
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
Real Time Clock Driver v1.12
Linux agpgart interface v0.101 (c) Dave Jones
agpgart: Detected an Intel 915G Chipset.
agpgart: Detected 7932K stolen memory.
agpgart: AGP aperture is 256M @ 0xe0000000
PNP: PS/2 Controller [PNP0303:KBD,PNP0f0e:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
Serial: 8250/16550 driver $Revision: 1.90 $ 76 ports, IRQ sharing enabled
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered
RAMDISK driver initialized: 16 RAM disks of 16384K size 1024 blocksize
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ICH6: IDE controller at PCI slot 0000:00:1f.1
ACPI: PCI Interrupt 0000:00:1f.1[A] -> GSI 17 (level, low) -> IRQ 185
ICH6: chipset revision 3
ICH6: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x34e0-0x34e7, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0x34e8-0x34ef, BIOS settings: hdc:pio, hdd:pio
Probing IDE interface ide0...
hda: HL-DT-ST CD-ROM GCR-8523B, ATAPI CD/DVD-ROM drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
Probing IDE interface ide1...
hda: ATAPI 52X CD-ROM drive, 128kB Cache, DMA
Uniform CD-ROM driver Revision: 3.20
ide-floppy driver 0.99.newide
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.01:USB HID core driver
mice: PS/2 mouse device common for all mice
md: md driver 0.90.1 MAX_MD_DEVS=256, MD_SB_DISKS=27
NET: Registered protocol family 2
IP: routing cache hash table of 4096 buckets, 64Kbytes
TCP established hash table entries: 131072 (order: 9, 2097152 bytes)
TCP bind hash table entries: 65536 (order: 7, 786432 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
Initializing IPsec netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
ACPI wakeup devices:
PCI0 PEG1 PCX1 PCX2 PCX4  HUB COM1 USB1 USB2 USB3 USB4 EUSB PBTN
ACPI: (supports S0 S1 S3 S4 S5)
CPU0 attaching sched-domain:
 domain 0: span 00000003
  groups: 00000001 00000002
  domain 1: span 00000003
   groups: 00000003
CPU1 attaching sched-domain:
 domain 0: span 00000003
  groups: 00000002 00000001
  domain 1: span 00000003
   groups: 00000003
Freeing unused kernel memory: 232k freed
SCSI subsystem initialized
libata version 1.10 loaded.
ata_piix version 1.03
ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 19 (level, low) -> IRQ 201
PCI: Setting latency timer of device 0000:00:1f.2 to 64
ata1: SATA max UDMA/133 cmd 0x3818 ctl 0x3832 bmdma 0x34F0 irq 201
ata2: SATA max UDMA/133 cmd 0x3820 ctl 0x3836 bmdma 0x34F8 irq 201
ata1: dev 0 cfg 49:2f00 82:7069 83:7c01 84:4023 85:7069 86:3c01 87:4023 88:203f
ata1: dev 0 ATA, max UDMA/100, 156301488 sectors: lba48
ata1: dev 0 configured for UDMA/100
scsi0 : ata_piix
ATA: abnormal status 0x7F on port 0x3827
ata2: disabling port
scsi1 : ata_piix
  Vendor: ATA       Model: WDC WD800JD-60LU  Rev: 07.0
  Type:   Direct-Access                      ANSI SCSI revision: 05
SCSI device sda: 156301488 512-byte hdwr sectors (80026 MB)
SCSI device sda: drive cache: write back
SCSI device sda: 156301488 512-byte hdwr sectors (80026 MB)
SCSI device sda: drive cache: write back
 sda: sda1 sda2
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
security:  3 users, 6 roles, 764 types, 87 bools
security:  55 classes, 180131 rules
SELinux:  Completing initialization.
SELinux:  Setting up existing superblocks.
SELinux: initialized (dev sda1, type ext3), uses xattr
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev selinuxfs, type selinuxfs), uses genfs_contexts
SELinux: initialized (dev mqueue, type mqueue), not configured for labeling
SELinux: initialized (dev hugetlbfs, type hugetlbfs), not configured
for labeling
SELinux: initialized (dev devpts, type devpts), uses transition SIDs
SELinux: initialized (dev eventpollfs, type eventpollfs), uses genfs_contexts
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev futexfs, type futexfs), uses genfs_contexts
SELinux: initialized (dev pipefs, type pipefs), uses task SIDs
SELinux: initialized (dev sockfs, type sockfs), uses task SIDs
SELinux: initialized (dev cpuset, type cpuset), not configured for labeling
SELinux: initialized (dev proc, type proc), uses genfs_contexts
SELinux: initialized (dev bdev, type bdev), uses genfs_contexts
SELinux: initialized (dev rootfs, type rootfs), uses genfs_contexts
SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
SELinux: initialized (dev usbfs, type usbfs), uses genfs_contexts
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
tg3.c:v3.29 (May 23, 2005)
ACPI: PCI Interrupt 0000:40:00.0[A] -> GSI 17 (level, low) -> IRQ 185
PCI: Setting latency timer of device 0000:40:00.0 to 64
eth0: Tigon3 [partno(BCM95751) rev 4001 PHY(5750)]
(PCIX:100MHz:32-bit) 10/100/1000BaseT Ethernet 00:0f:fe:25:5a:0a
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
eth0: dma_rwctrl[76180000]
snd_intel8x0: Unknown parameter `'
ACPI: PCI Interrupt 0000:00:1e.2[A] -> GSI 21 (level, low) -> IRQ 209
PCI: Setting latency timer of device 0000:00:1e.2 to 64
intel8x0_measure_ac97_clock: measured 50021 usecs
intel8x0: clocking to 48000
hw_random hardware driver 1.0.0 loaded
shpchp: acpi_shpchprm:\_SB_.PCI0 evaluate _BBN fail=0x5
shpchp: acpi_shpchprm:get_device PCI ROOT HID fail=0x5
shpchp: acpi_shpchprm:\_SB_.PCI0 evaluate _BBN fail=0x5
shpchp: acpi_shpchprm:get_device PCI ROOT HID fail=0x5
Zapata Telephony Interface Registered on major 196
Zaptel Version: 1.2.4 Echo Canceller: KB1
ACPI: PCI Interrupt 0000:05:04.0[A] -> GSI 16 (level, low) -> IRQ 217
wcfxo: DAA mode is 'FCC'
Found a Wildcard FXO: Wildcard X100P
ACPI: PCI Interrupt 0000:00: 1d.7[A] -> GSI 20 (level, low) -> IRQ 225
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: debug port 1
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1d.7: irq 225, io mem 0xcfdc0000
PCI: cache line size of 128 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: USB 2.0 initialized, EHCI 1.00, driver 10 Dec 2004
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 8 ports detected
USB Universal Host Controller Interface driver v2.2
SELinux: initialized (dev debugfs, type debugfs), uses genfs_contexts
ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 20 (level, low) -> IRQ 225
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1d.0: irq 225, io base 0x00003440
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 18 (level, low) -> IRQ 233
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00: 1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1d.1: irq 233, io base 0x00003460
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00: 1d.2[C] -> GSI 21 (level, low) -> IRQ 209
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1d.2: irq 209, io base 0x00003480
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.3[D] -> GSI 22 (level, low) -> IRQ 50
PCI: Setting latency timer of device 0000:00: 1d.3 to 64
uhci_hcd 0000:00:1d.3: UHCI Host Controller
uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1d.3: irq 50, io base 0x000034a0
hub 5-0:1.0: USB hub found
hub 5-0: 1.0: 2 ports detected
ACPI: Power Button (FF) [PWRF]
ibm_acpi: ec object not found
md: Autodetecting RAID arrays.
md: autorun ...
md: ... autorun DONE.
device-mapper: 4.4.0-ioctl (2005-01-12) initialised: dm-devel@redhat.com
EXT3 FS on sda1, internal journal
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
Adding 6466152k swap on /dev/sda2.  Priority:-1 extents:1
SELinux: initialized (dev binfmt_misc, type binfmt_misc), uses genfs_contexts
tg3: eth0: Link is up at 1000 Mbps, full duplex.
tg3: eth0: Flow control is on for TX and on for RX.
SELinux: initialized (dev rpc_pipefs, type rpc_pipefs), uses genfs_contexts
i2c /dev entries driver
SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
NET: Registered protocol family 10
Disabled Privacy Extensions on device c037d640(lo)
IPv6 over IPv4 tunneling driver
eth0: no IPv6 routers present
Freed a Wildcard
Zapata Telephony Interface Unloaded
Zapata Telephony Interface Registered on major 196
Zaptel Version: 1.2.4 Echo Canceller: KB1
ACPI: PCI Interrupt 0000:05:04.0[A] -> GSI 16 (level, low) -> IRQ 217
wcfxo: DAA mode is 'FCC'
Found a Wildcard FXO: Wildcard X100P
Registered tone zone 0 (United States / North America)
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
