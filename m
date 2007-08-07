From: "Jean-Baptiste Vignaud" <vignaud@xandmail.fr>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue,  7 Aug 2007 10:10:34 +0200
Message-ID: <JME9DM$ADEFA900BA9A4E6A40FE3AEF8CADB888@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "cebbert" <cebbert@redhat.com>, "mingo" <mingo@elte.hu>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	"tglx" <tglx@linutronix.de>,
	"torvalds" <torvalds@linux-foundation.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"shemminger" <shemminger@linux-foundation.org>,
	"linux-net" <linux-net@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>,
	"akpm" <akpm@linux-foundation.org>,
	"alan" <alan@lxorguk.ukuu.org.uk>
To: "jarkao2" <jarkao2@o2.pl>
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> BTW: Jean-Babtiste, could you send or point to you current configs?
> I mean at least proc/interrupts, but with dmesg and .config it would
> be even better. (I assume this last report was about the revert patch
> mentioned by Chuck, not the one below your message?)

Sure. 

Last reports are with the 2.6.22.1-41.fc7 kernel, which has in changelog :

* Sat Jul 28 2007 Chuck Ebbert <cebbert@redhat.com>
- revert upstream "genirq: do not mask interrupts by default"


* interrupts (i use irqbalance, but problem was the same without)

[root@loki ~]# cat /proc/interrupts 
           CPU0       CPU1       
  0:       4487    4910668   IO-APIC-edge      timer
  1:        241         58   IO-APIC-edge      i8042
  8:          0          0   IO-APIC-edge      rtc0
  9:          0          0   IO-APIC-fasteoi   acpi
 12:          2        139   IO-APIC-edge      i8042
 14:          0          0   IO-APIC-edge      libata
 15:          0          0   IO-APIC-edge      libata
 16:      72625         96   IO-APIC-fasteoi   eth1
 17:       4667        128   IO-APIC-fasteoi   eth2
 20:       4156      39870   IO-APIC-fasteoi   sata_nv
 21:      34794       9177   IO-APIC-fasteoi   sata_nv
 22:          0          0   IO-APIC-fasteoi   ehci_hcd:usb2
 23:       6005       1565   IO-APIC-fasteoi   ohci_hcd:usb1, sata_nv
2297:          3     492180   PCI-MSI-edge      eth0
NMI:          0          0 
LOC:    4915345    4915282 
ERR:          0

problems are with eth1 and eth2 here. never had any problems with the onboard (eth0).

* pci

00:00.0 RAM memory: nVidia Corporation MCP55 Memory Controller (rev a1)
00:01.0 ISA bridge: nVidia Corporation MCP55 LPC Bridge (rev a2)
00:01.1 SMBus: nVidia Corporation MCP55 SMBus (rev a2)
00:01.2 RAM memory: nVidia Corporation MCP55 Memory Controller (rev a2)
00:02.0 USB Controller: nVidia Corporation MCP55 USB Controller (rev a1)
00:02.1 USB Controller: nVidia Corporation MCP55 USB Controller (rev a2)
00:04.0 IDE interface: nVidia Corporation MCP55 IDE (rev a1)
00:05.0 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2)
00:05.1 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2)
00:05.2 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2)
00:06.0 PCI bridge: nVidia Corporation MCP55 PCI bridge (rev a2)
00:08.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a2)
00:0a.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
00:0b.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
00:0c.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
00:0d.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
00:0e.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
00:0f.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
01:06.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 78)
01:07.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 78)
07:00.0 VGA compatible controller: nVidia Corporation NV44 [GeForce 6200 LE] (rev a1)

* dmesg (from a reboot this morning)

Linux version 2.6.22.1-41.fc7 (kojibuilder@xenbuilder1.fedora.redhat.com) (gcc version 4.1.2 20070502 (Red Hat 4.1.2-12)) #1 SMP Fri Jul 27 18:21:43 EDT 2007
Command line: ro root=/dev/all/root
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f000 (usable)
 BIOS-e820: 000000000009f000 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
 BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NVS)
 BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI data)
 BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserved)
 BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
Entering add_active_range(0, 0, 159) 0 entries of 3200 used
Entering add_active_range(0, 256, 524000) 1 entries of 3200 used
end_pfn_map = 1048576
DMI 2.4 present.
ACPI: RSDP 000F7620, 0024 (r2 Nvidia)
ACPI: XSDT 7FEE30C0, 0044 (r1 Nvidia ASUSACPI 42302E31 AWRD        0)
ACPI: FACP 7FEEC400, 00F4 (r3 Nvidia ASUSACPI 42302E31 AWRD        0)
ACPI: DSDT 7FEE3240, 9164 (r1 NVIDIA AWRDACPI     1000 MSFT  3000000)
ACPI: FACS 7FEE0000, 0040
ACPI: HPET 7FEEC600, 0038 (r1 Nvidia ASUSACPI 42302E31 AWRD       98)
ACPI: MCFG 7FEEC680, 003C (r1 Nvidia ASUSACPI 42302E31 AWRD        0)
ACPI: APIC 7FEEC540, 007C (r1 Nvidia ASUSACPI 42302E31 AWRD        0)
Scanning NUMA topology in Northbridge 24
No NUMA configuration found
Faking a node at 0000000000000000-000000007fee0000
Entering add_active_range(0, 0, 159) 0 entries of 3200 used
Entering add_active_range(0, 256, 524000) 1 entries of 3200 used
Bootmem setup node 0 0000000000000000-000000007fee0000
Zone PFN ranges:
  DMA             0 ->     4096
  DMA32        4096 ->  1048576
  Normal    1048576 ->  1048576
early_node_map[2] active PFN ranges
    0:        0 ->      159
    0:      256 ->   524000
On node 0 totalpages: 523903
  DMA zone: 56 pages used for memmap
  DMA zone: 1300 pages reserved
  DMA zone: 2643 pages, LIFO batch:0
  DMA32 zone: 7108 pages used for memmap
  DMA32 zone: 512796 pages, LIFO batch:31
  Normal zone: 0 pages used for memmap
ACPI: PM-Timer IO Port: 0x1008
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
Processor #0 (Bootup-CPU)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
Processor #1
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high edge)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
ACPI: IRQ14 used by override.
ACPI: IRQ15 used by override.
Setting APIC routing to flat
ACPI: HPET id: 0x10de8201 base: 0xfefff000
Using ACPI (MADT) for SMP configuration information
swsusp: Registered nosave memory region: 000000000009f000 - 00000000000a0000
swsusp: Registered nosave memory region: 00000000000a0000 - 00000000000f0000
swsusp: Registered nosave memory region: 00000000000f0000 - 0000000000100000
Allocating PCI resources starting at 80000000 (gap: 7ff00000:70100000)
SMP: Allowing 2 CPUs, 0 hotplug CPUs
PERCPU: Allocating 40968 bytes of per cpu data
Built 1 zonelists.  Total pages: 515439
Kernel command line: ro root=/dev/all/root
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
Extended CMOS year: 2000
Marking TSC unstable due to TSCs unsynchronized
time.c: Detected 2009.257 MHz processor.
Console: colour VGA+ 80x25
Checking aperture...
CPU 0: aperture @ 64000000 size 32 MB
Aperture too small (32 MB)
No AGP bridge found
Memory: 2057524k/2096000k available (2362k kernel code, 38088k reserved, 1401k data, 312k init)
SLUB: Genslabs=23, HWalign=64, Order=0-1, MinObjects=4, CPUs=2, Nodes=1
Calibrating delay using timer specific routine.. 4020.98 BogoMIPS (lpj=2010494)
Security Framework v1.0.0 initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
selinux_register_security:  Registering secondary module capability
Capability LSM initialized as secondary
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Mount-cache hash table entries: 256
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 0/0 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
SMP alternatives: switching to UP code
ACPI: Core revision 20070126
Using local APIC timer interrupts.
result 12557855
Detected 12.557 MHz APIC timer.
SMP alternatives: switching to SMP code
Booting processor 1/2 APIC 0x1
Initializing CPU#1
Calibrating delay using timer specific routine.. 4018.58 BogoMIPS (lpj=2009293)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 1/1 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepping 02
Brought up 2 CPUs
sizeof(vma)=176 bytes
sizeof(page)=56 bytes
sizeof(inode)=560 bytes
sizeof(dentry)=208 bytes
sizeof(ext3inode)=760 bytes
sizeof(buffer_head)=104 bytes
sizeof(skbuff)=232 bytes
sizeof(task_struct)=2048 bytes
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: Using MMCONFIG at f0000000 - f3ffffff
PCI: No mmconfig possible on device 00:18
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S3 S4 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
PCI: Transparent bridge - 0000:00:06.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 *11 14 15)
ACPI: PCI Interrupt Link [LNK2] (IRQs 5 *7 9 10 11 14 15)
ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 *10 11 14 15)
ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LUBA] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14 15)
ACPI: PCI Interrupt Link [LAZA] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LUB2] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LSID] (IRQs 5 7 9 10 *11 14 15)
ACPI: PCI Interrupt Link [LFID] (IRQs *5 7 9 10 11 14 15)
ACPI: PCI Interrupt Link [LSA2] (IRQs 5 7 9 *10 11 14 15)
ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0
ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0
ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0, disabled.
ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disabled.
ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disabled.
ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0
ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0, disabled.
ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disabled.
ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0, disabled.
ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0, disabled.
ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0, disabled.
ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0, disabled.
ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0, disabled.
ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0, disabled.
ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0, disabled.
ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 12 devices
ACPI: ACPI bus type pnp unregistered
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
hpet0: at MMIO 0xfefff000, IRQs 2, 8, 31
hpet0: 3 32-bit timers, 25000000 Hz
ACPI: RTC can wake from S4
pnp: 00:01: ioport range 0x1000-0x107f has been reserved
pnp: 00:01: ioport range 0x1080-0x10ff has been reserved
pnp: 00:01: ioport range 0x1400-0x147f has been reserved
Time: hpet clocksource has been installed.
pnp: 00:01: ioport range 0x1480-0x14ff has been reserved
pnp: 00:01: ioport range 0x1800-0x187f has been reserved
pnp: 00:01: ioport range 0x1880-0x18ff has been reserved
pnp: 00:0a: iomem range 0xf0000000-0xf3ffffff could not be reserved
pnp: 00:0b: iomem range 0xd1800-0xd3fff has been reserved
pnp: 00:0b: iomem range 0xf0000-0xf7fff could not be reserved
pnp: 00:0b: iomem range 0xf8000-0xfbfff could not be reserved
pnp: 00:0b: iomem range 0xfc000-0xfffff could not be reserved
PCI: Bridge: 0000:00:06.0
  IO window: a000-afff
  MEM window: fde00000-fdefffff
  PREFETCH window: 80000000-800fffff
PCI: Bridge: 0000:00:0a.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:0b.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:0c.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:0d.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:0e.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:0f.0
  IO window: disabled.
  MEM window: fa000000-fcffffff
  PREFETCH window: e0000000-efffffff
PCI: Setting latency timer of device 0000:00:06.0 to 64
PCI: Setting latency timer of device 0000:00:0a.0 to 64
PCI: Setting latency timer of device 0000:00:0b.0 to 64
PCI: Setting latency timer of device 0000:00:0c.0 to 64
PCI: Setting latency timer of device 0000:00:0d.0 to 64
PCI: Setting latency timer of device 0000:00:0e.0 to 64
PCI: Setting latency timer of device 0000:00:0f.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 262144 (order: 10, 6291456 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
checking if image is initramfs... it is
Freeing initrd memory: 3938k freed
audit: initializing netlink socket (disabled)
audit(1186467404.666:1): initialized
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
SELinux:  Registering netfilter hooks
ksign: Installing public key data
Loading keyring
- Added public key 8321A2A758C22C88
- User ID: Red Hat, Inc. (Kernel Module GPG key)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
Boot video device is 0000:07:00.0
PCI: Setting latency timer of device 0000:00:0a.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:0a.0:pcie00]
Allocate Port Service[0000:00:0a.0:pcie03]
PCI: Setting latency timer of device 0000:00:0b.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:0b.0:pcie00]
Allocate Port Service[0000:00:0b.0:pcie03]
PCI: Setting latency timer of device 0000:00:0c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:0c.0:pcie00]
Allocate Port Service[0000:00:0c.0:pcie03]
PCI: Setting latency timer of device 0000:00:0d.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:0d.0:pcie00]
Allocate Port Service[0000:00:0d.0:pcie03]
PCI: Setting latency timer of device 0000:00:0e.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:0e.0:pcie00]
Allocate Port Service[0000:00:0e.0:pcie03]
PCI: Setting latency timer of device 0000:00:0f.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:0f.0:pcie00]
Allocate Port Service[0000:00:0f.0:pcie03]
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
ACPI: Fan [FAN] (on)
ACPI: Thermal Zone [THRM] (40 C)
hpet_resources: 0xfefff000 is busy
Generic RTC Driver v1.07
Non-volatile memory driver v1.2
Linux agpgart interface v0.102 (c) Dave Jones
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
RAMDISK driver initialized: 16 RAM disks of 16384K size 4096 blocksize
input: Macintosh mouse button emulation as /class/input/input0
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard as /class/input/input1
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
powernow-k8: Found 2 AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ processors (version 2.00.00)
powernow-k8: MP systems not supported by PSB BIOS structure
powernow-k8: MP systems not supported by PSB BIOS structure
drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
Freeing unused kernel memory: 312k freed
Write protecting the kernel read-only data: 1060k
USB Universal Host Controller Interface driver v3.0
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:02.0 to 64
ohci_hcd 0000:00:02.0: OHCI Host Controller
ohci_hcd 0000:00:02.0: new USB bus registered, assigned bus number 1
ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
input: PS2++ Logitech Wheel Mouse as /class/input/input2
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 10 ports detected
ACPI: PCI Interrupt Link [APCL] enabled at IRQ 22
ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] -> GSI 22 (level, low) -> IRQ 22
PCI: Setting latency timer of device 0000:00:02.1 to 64
ehci_hcd 0000:00:02.1: EHCI Host Controller
ehci_hcd 0000:00:02.1: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:02.1: debug port 1
PCI: cache line size of 64 is not supported by device 0000:00:02.1
ehci_hcd 0000:00:02.1: irq 22, io mem 0xfe02e000
ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 10 ports detected
raid5: automatically using best checksumming function: generic_sse
   generic_sse:  6160.000 MB/sec
raid5: using function: generic_sse (6160.000 MB/sec)
raid6: int64x1   1738 MB/s
raid6: int64x2   2378 MB/s
raid6: int64x4   1812 MB/s
raid6: int64x8   1800 MB/s
raid6: sse2x1    2773 MB/s
raid6: sse2x2    3714 MB/s
raid6: sse2x4    3898 MB/s
raid6: using algorithm sse2x4 (3898 MB/s)
md: raid6 personality registered for level 6
md: raid5 personality registered for level 5
md: raid4 personality registered for level 4
SCSI subsystem initialized
libata version 2.21 loaded.
sata_nv 0000:00:05.0: version 3.4
ACPI: PCI Interrupt Link [APSI] enabled at IRQ 21
ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] -> GSI 21 (level, low) -> IRQ 21
PCI: Setting latency timer of device 0000:00:05.0 to 64
scsi0 : sata_nv
scsi1 : sata_nv
ata1: SATA max UDMA/133 cmd 0x00000000000109f0 ctl 0x0000000000010bf2 bmdma 0x000000000001dc00 irq 21
ata2: SATA max UDMA/133 cmd 0x0000000000010970 ctl 0x0000000000010b72 bmdma 0x000000000001dc08 irq 21
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-7: Maxtor 6V320F0, VA111900, max UDMA/133
ata1.00: 625142448 sectors, multi 1: LBA48 NCQ (depth 0/32)
ata1.00: configured for UDMA/133
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: ATA-7: Maxtor 6V320F0, VA111900, max UDMA/133
ata2.00: 625142448 sectors, multi 1: LBA48 NCQ (depth 0/32)
ata2.00: configured for UDMA/133
scsi 0:0:0:0: Direct-Access     ATA      Maxtor 6V320F0   VA11 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 625142448 512-byte hardware sectors (320073 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: [sda] 625142448 512-byte hardware sectors (320073 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2
sd 0:0:0:0: [sda] Attached SCSI disk
scsi 1:0:0:0: Direct-Access     ATA      Maxtor 6V320F0   VA11 PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 625142448 512-byte hardware sectors (320073 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:0:0: [sdb] 625142448 512-byte hardware sectors (320073 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdb: sdb1 sdb2
sd 1:0:0:0: [sdb] Attached SCSI disk
ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 20
ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] -> GSI 20 (level, low) -> IRQ 20
PCI: Setting latency timer of device 0000:00:05.1 to 64
scsi2 : sata_nv
scsi3 : sata_nv
ata3: SATA max UDMA/133 cmd 0x00000000000109e0 ctl 0x0000000000010be2 bmdma 0x000000000001c800 irq 20
ata4: SATA max UDMA/133 cmd 0x0000000000010960 ctl 0x0000000000010b62 bmdma 0x000000000001c808 irq 20
ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata3.00: ATA-7: Maxtor 6V320F0, VA111900, max UDMA/133
ata3.00: 625142448 sectors, multi 1: LBA48 NCQ (depth 0/32)
ata3.00: configured for UDMA/133
ata4: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata4.00: ATA-7: Maxtor 6V320F0, VA111900, max UDMA/133
ata4.00: 625142448 sectors, multi 1: LBA48 NCQ (depth 0/32)
ata4.00: configured for UDMA/133
scsi 2:0:0:0: Direct-Access     ATA      Maxtor 6V320F0   VA11 PQ: 0 ANSI: 5
sd 2:0:0:0: [sdc] 625142448 512-byte hardware sectors (320073 MB)
sd 2:0:0:0: [sdc] Write Protect is off
sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 2:0:0:0: [sdc] 625142448 512-byte hardware sectors (320073 MB)
sd 2:0:0:0: [sdc] Write Protect is off
sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdc: sdc1 sdc2
sd 2:0:0:0: [sdc] Attached SCSI disk
scsi 3:0:0:0: Direct-Access     ATA      Maxtor 6V320F0   VA11 PQ: 0 ANSI: 5
sd 3:0:0:0: [sdd] 625142448 512-byte hardware sectors (320073 MB)
sd 3:0:0:0: [sdd] Write Protect is off
sd 3:0:0:0: [sdd] Mode Sense: 00 3a 00 00
sd 3:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 3:0:0:0: [sdd] 625142448 512-byte hardware sectors (320073 MB)
sd 3:0:0:0: [sdd] Write Protect is off
sd 3:0:0:0: [sdd] Mode Sense: 00 3a 00 00
sd 3:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdd: sdd1 sdd2
sd 3:0:0:0: [sdd] Attached SCSI disk
ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 23
ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:05.2 to 64
scsi4 : sata_nv
scsi5 : sata_nv
ata5: SATA max UDMA/133 cmd 0x000000000001c400 ctl 0x000000000001c002 bmdma 0x000000000001b400 irq 23
ata6: SATA max UDMA/133 cmd 0x000000000001bc00 ctl 0x000000000001b802 bmdma 0x000000000001b408 irq 23
ata5: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata5.00: ATAPI: PLEXTOR DVDR   PX-760A, 1.03, max UDMA/66
ata5.00: configured for UDMA/66
ata6: SATA link down (SStatus 0 SControl 300)
scsi 4:0:0:0: CD-ROM            PLEXTOR  DVDR   PX-760A   1.03 PQ: 0 ANSI: 5
pata_amd 0000:00:04.0: version 0.3.8
PCI: Setting latency timer of device 0000:00:04.0 to 64
scsi6 : pata_amd
scsi7 : pata_amd
ata7: PATA max UDMA/133 cmd 0x00000000000101f0 ctl 0x00000000000103f6 bmdma 0x000000000001f000 irq 14
ata8: PATA max UDMA/133 cmd 0x0000000000010170 ctl 0x0000000000010376 bmdma 0x000000000001f008 irq 15
ata7: port disabled. ignoring.
ata8: port disabled. ignoring.
device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@redhat.com
md: md1 stopped.
md: bind<sdb2>
md: bind<sdc2>
md: bind<sdd2>
md: bind<sda2>
raid5: device sda2 operational as raid disk 0
raid5: device sdd2 operational as raid disk 3
raid5: device sdc2 operational as raid disk 2
raid5: device sdb2 operational as raid disk 1
raid5: allocated 4262kB for md1
raid5: raid level 5 set md1 active with 4 out of 4 devices, algorithm 2
RAID5 conf printout:
 --- rd:4 wd:4
 disk 0, o:1, dev:sda2
 disk 1, o:1, dev:sdb2
 disk 2, o:1, dev:sdc2
 disk 3, o:1, dev:sdd2
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
audit(1186467414.296:2): enforcing=1 old_enforcing=0 auid=4294967295
security:  3 users, 6 roles, 1829 types, 81 bools, 1 sens, 1024 cats
security:  61 classes, 69524 rules
SELinux:  Completing initialization.
SELinux:  Setting up existing superblocks.
SELinux: initialized (dev dm-0, type ext3), uses xattr
SELinux: initialized (dev usbfs, type usbfs), uses genfs_contexts
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev debugfs, type debugfs), uses genfs_contexts
SELinux: initialized (dev selinuxfs, type selinuxfs), uses genfs_contexts
SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses genfs_contexts
SELinux: initialized (dev devpts, type devpts), uses transition SIDs
SELinux: initialized (dev inotifyfs, type inotifyfs), uses genfs_contexts
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev futexfs, type futexfs), uses genfs_contexts
SELinux: initialized (dev anon_inodefs, type anon_inodefs), uses genfs_contexts
SELinux: initialized (dev pipefs, type pipefs), uses task SIDs
SELinux: initialized (dev sockfs, type sockfs), uses task SIDs
SELinux: initialized (dev cpuset, type cpuset), uses genfs_contexts
SELinux: initialized (dev proc, type proc), uses genfs_contexts
SELinux: initialized (dev bdev, type bdev), uses genfs_contexts
SELinux: initialized (dev rootfs, type rootfs), uses genfs_contexts
SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
audit(1186467414.533:3): policy loaded auid=4294967295
sd 0:0:0:0: Attached scsi generic sg0 type 0
sd 1:0:0:0: Attached scsi generic sg1 type 0
sd 2:0:0:0: Attached scsi generic sg2 type 0
sd 3:0:0:0: Attached scsi generic sg3 type 0
scsi 4:0:0:0: Attached scsi generic sg4 type 5
sr0: scsi3-mmc drive: 40x/40x writer cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 4:0:0:0: Attached scsi CD-ROM sr0
i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
forcedeth.c: Reverse Engineered nForce ethernet driver. Version 0.60.
ACPI: PCI Interrupt Link [APCH] enabled at IRQ 22
ACPI: PCI Interrupt 0000:00:08.0[A] -> Link [APCH] -> GSI 22 (level, low) -> IRQ 22
PCI: Setting latency timer of device 0000:00:08.0 to 64
forcedeth: using HIGHDMA
rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one year, y3k
eth0: forcedeth.c: subsystem: 01043:8239 bound to 0000:00:08.0
ACPI: PCI Interrupt Link [APC1] enabled at IRQ 16
ACPI: PCI Interrupt 0000:01:06.0[A] -> Link [APC1] -> GSI 16 (level, low) -> IRQ 16
3c59x: Donald Becker and others.
0000:01:06.0: 3Com PCI 3c905C Tornado at ffffc20000330000.
ACPI: PCI Interrupt Link [APC2] enabled at IRQ 17
ACPI: PCI Interrupt 0000:01:07.0[A] -> Link [APC2] -> GSI 17 (level, low) -> IRQ 17
0000:01:07.0: 3Com PCI 3c905C Tornado at ffffc2000037a000.
shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
loop: module loaded
floppy0: no floppy controllers found
lp: driver loaded but no devices found
No dock devices found.
input: Power Button (FF) as /class/input/input3
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input4
ACPI: Power Button (CM) [PWRB]
md: md0 stopped.
md: bind<sdb1>
md: bind<sdc1>
md: bind<sdd1>
md: bind<sda1>
md: raid1 personality registered for level 1
raid1: raid set md0 active with 4 out of 4 mirrors
EXT3 FS on dm-0, internal journal
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
kjournald starting.  Commit interval 5 seconds
EXT3 FS on dm-2, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
SELinux: initialized (dev dm-2, type ext3), uses xattr
kjournald starting.  Commit interval 5 seconds
EXT3 FS on md0, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
SELinux: initialized (dev md0, type ext3), uses xattr
Adding 4194296k swap on /dev/all/swap.  Priority:-1 extents:1 across:4194296k
SELinux: initialized (dev binfmt_misc, type binfmt_misc), uses genfs_contexts
ip_tables: (C) 2000-2006 Netfilter Core Team
Netfilter messages via NETLINK v0.30.
nf_conntrack version 0.5.0 (8192 buckets, 65536 max)
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
Mobile IPv6
eth1:  setting full-duplex.
eth2:  setting full-duplex.
eth0: no IPv6 routers present
audit(1186467437.499:4): avc:  denied  { search } for  pid=2244 comm="sm-notify" scontext=system_u:system_r:rpcd_t:s0 tcontext=system_u:object_r:sysctl_fs_t:s0 tclass=dir
audit(1186467437.533:5): avc:  denied  { search } for  pid=2243 comm="rpc.statd" scontext=system_u:system_r:rpcd_t:s0 tcontext=system_u:object_r:sysctl_fs_t:s0 tclass=dir
SELinux: initialized (dev rpc_pipefs, type rpc_pipefs), uses genfs_contexts
SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
eth1: no IPv6 routers present
eth2: no IPv6 routers present


* .config

i dont have it, it was the standard fedora one.

i'm not sure that the problem is related to 3com, because i replaced those cards by old card i had in spare :

01:06.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (rev 42)
01:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8029(AS)

and i had the exact same problem.

Those 3com cards were working 24/24 before i went to fedora 7 (and kernel 2.6.21 then).

jb


