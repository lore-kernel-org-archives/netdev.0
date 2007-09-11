From: Jan Gukelberger <g.u.g.i@gmx.de>
Subject: Re: BUG: skge ethernet breakage (PCI: Unable to reserve mem region)
Date: Tue, 11 Sep 2007 15:39:01 +0200
Message-ID: <1189517941.4069.15.camel@localhost>
References: <1189183355.3784.11.camel@localhost>
	 <20070911102110.1f32fa7e@oldman> <1189508304.4069.5.camel@localhost>
	 <20070911143701.628c8d18@oldman>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-piyPvoO5zPjPnU5hgUHf"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:41494 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751723AbXIKNjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 09:39:06 -0400
In-Reply-To: <20070911143701.628c8d18@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-piyPvoO5zPjPnU5hgUHf
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2007-09-11 at 14:37 +0200, Stephen Hemminger wrote:
> On Tue, 11 Sep 2007 12:58:24 +0200
> Jan Gukelberger <g.u.g.i@gmx.de> wrote:
> 
> > On Tue, 2007-09-11 at 10:21 +0200, Stephen Hemminger wrote:
> > > On Fri, 07 Sep 2007 18:42:35 +0200
> > > Jan Gukelberger <g.u.g.i@gmx.de> wrote:
> > [...]
> > > > The key problem seem to be the following lines in dmesg:
> > > > ------------------------------------------------------------------------
> > > > ACPI: PCI Interrupt 0000:04:04.0[A] -> GSI 19 (level, low) -> IRQ 19
> > > > PCI: Unable to reserve mem region #1:4000@ff9f8000 for device 0000:04:04.0
> > > > skge 0000:04:04.0: cannot obtain PCI resources
> > > > ACPI: PCI interrupt for device 0000:04:04.0 disabled
> > > > skge: probe of 0000:04:04.0 failed with error -16
> > > > ------------------------------------------------------------------------
> > > > 
> > > 
> > > There is some kind of device conflict, please provide lspci -vvvxx output.
> > 
> > I'm attaching the output of 'lspci -vvvxx' on the working 2.6.20 kernel
> > as well as the output of 'lspci -vvxxx' on 2.6.23-rc5 which I recorded
> > earlier.
> > I you specifically need 'lspci -vvvxx' on 2.6.23-rc5 please drop me a
> > note and I'll reboot quickly.
> > 
> > Thanks,
> > Jan
> 
> All looks in order, on the PCI tables. There is a firewire control just
> above the skge device, perhaps you enabled one of the firewire stacks
> in the configuration? 

I did a quick diff of the respective kernel .config's (this is the
configuration you mean, right?) and haven't found any notable
differences in the firewire options.

>  Perhaps the console (dmesg) output will show some clue.

I'm attaching a diff between dmesg of a working and a non-working boot.
You can find the full dmesg records in my first mail and in the Debian
BTS respectively.

The only thing I can see there is the old  kernel having some problems
with the SATA controller - even though I did never notice any unusual
behaviour apart from these messages:
------------------------------------------------------------------------
PCI: Device 0000:02:00.0 not available because of resource collisions
ahci: probe of 0000:02:00.0 failed with error -22
JMB363: IDE controller at PCI slot 0000:02:00.0
PCI: Device 0000:02:00.0 not available because of resource collisions
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
JMB363: BIOS configuration fixed.
------------------------------------------------------------------------

Don't know whether this could be related?

Thanks,
Jan

--=-piyPvoO5zPjPnU5hgUHf
Content-Disposition: attachment; filename=dmesg.diff
Content-Type: text/x-patch; name=dmesg.diff; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

--- /home/jan/dmesg-2.6.20	2007-09-07 17:17:09.000000000 +0200
+++ dmesg-2.6.23-rc5	2007-09-07 18:13:09.000000000 +0200
@@ -1,4 +1,4 @@
-Linux version 2.6.20-1-amd64 (Debian 2.6.20-3) (waldi@debian.org) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #1 SMP Tue Apr 24 21:10:58 UTC 2007
+Linux version 2.6.23-rc5-amd64 (Debian 2.6.23~rc5-1~experimental.1~snapshot.9462) (waldi@debian.org) (gcc version 4.1.3 20070718 (prerelease) (Debian 4.1.2-14+1)) #1 SMP Thu Sep 6 06:18:52 UTC 2007
 Command line: root=/dev/sda6 ro quiet vga=791 
 BIOS-provided physical RAM map:
  BIOS-e820: 0000000000000000 - 000000000009ec00 (usable)
@@ -14,18 +14,19 @@
 Entering add_active_range(0, 256, 520080) 1 entries of 3200 used
 end_pfn_map = 1048576
 DMI 2.4 present.
-ACPI: RSDP (v002 ACPIAM                                ) @ 0x00000000000fad70
-ACPI: XSDT (v001 NEC             0x05000730 MSFT 0x00000097) @ 0x000000007ef90100
-ACPI: FADT (v003 MSTEST OEMFACP  0x05000730 MSFT 0x00000097) @ 0x000000007ef90290
-ACPI: MADT (v001 MSTEST OEMAPIC  0x05000730 MSFT 0x00000097) @ 0x000000007ef90390
-ACPI: MCFG (v001 MSTEST OEMMCFG  0x05000730 MSFT 0x00000097) @ 0x000000007ef90400
-ACPI: SLIC (v001 NEC             0x05000730 MSFT 0x00000097) @ 0x000000007ef90440
-ACPI: OEMB (v001 MSTEST AMI_OEM  0x05000730 MSFT 0x00000097) @ 0x000000007ef9e040
-ACPI: HPET (v001 MSTEST OEMHPET  0x05000730 MSFT 0x00000097) @ 0x000000007ef9a250
-ACPI: GSCI (v001 MSTEST GMCHSCI  0x05000730 MSFT 0x00000097) @ 0x000000007ef9e0c0
-ACPI: SSDT (v001    AMI   CPU1PM 0x00000001 INTL 0x20060113) @ 0x000000007efa00f0
-ACPI: SSDT (v001    AMI   CPU2PM 0x00000001 INTL 0x20060113) @ 0x000000007efa02b0
-ACPI: DSDT (v001  A0579 A0579000 0x00000000 INTL 0x20060113) @ 0x0000000000000000
+ACPI: RSDP 000FAD70, 0024 (r2 ACPIAM)
+ACPI: XSDT 7EF90100, 006C (r1 NEC              5000730 MSFT       97)
+ACPI: FACP 7EF90290, 00F4 (r3 MSTEST OEMFACP   5000730 MSFT       97)
+ACPI: DSDT 7EF905C0, 9C85 (r1  A0579 A0579000        0 INTL 20060113)
+ACPI: FACS 7EF9E000, 0040
+ACPI: APIC 7EF90390, 006C (r1 MSTEST OEMAPIC   5000730 MSFT       97)
+ACPI: MCFG 7EF90400, 003C (r1 MSTEST OEMMCFG   5000730 MSFT       97)
+ACPI: SLIC 7EF90440, 0176 (r1 NEC              5000730 MSFT       97)
+ACPI: OEMB 7EF9E040, 007B (r1 MSTEST AMI_OEM   5000730 MSFT       97)
+ACPI: HPET 7EF9A250, 0038 (r1 MSTEST OEMHPET   5000730 MSFT       97)
+ACPI: GSCI 7EF9E0C0, 2024 (r1 MSTEST GMCHSCI   5000730 MSFT       97)
+ACPI: SSDT 7EFA00F0, 01BF (r1    AMI   CPU1PM        1 INTL 20060113)
+ACPI: SSDT 7EFA02B0, 0133 (r1    AMI   CPU2PM        1 INTL 20060113)
 No NUMA configuration found
 Faking a node at 0000000000000000-000000007ef90000
 Entering add_active_range(0, 0, 158) 0 entries of 3200 used
@@ -35,16 +36,18 @@
   DMA             0 ->     4096
   DMA32        4096 ->  1048576
   Normal    1048576 ->  1048576
+Movable zone start PFN for each node
 early_node_map[2] active PFN ranges
     0:        0 ->      158
     0:      256 ->   520080
 On node 0 totalpages: 519982
   DMA zone: 56 pages used for memmap
-  DMA zone: 972 pages reserved
-  DMA zone: 2970 pages, LIFO batch:0
+  DMA zone: 1044 pages reserved
+  DMA zone: 2898 pages, LIFO batch:0
   DMA32 zone: 7054 pages used for memmap
   DMA32 zone: 508930 pages, LIFO batch:31
   Normal zone: 0 pages used for memmap
+  Movable zone: 0 pages used for memmap
 ACPI: PM-Timer IO Port: 0x808
 ACPI: Local APIC address 0xfee00000
 ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
@@ -60,31 +63,35 @@
 ACPI: IRQ0 used by override.
 ACPI: IRQ2 used by override.
 ACPI: IRQ9 used by override.
-Setting APIC routing to physical flat
+Setting APIC routing to flat
 ACPI: HPET id: 0x8086a202 base: 0xfed00000
 Using ACPI (MADT) for SMP configuration information
-Nosave address range: 000000000009e000 - 000000000009f000
-Nosave address range: 000000000009f000 - 00000000000a0000
-Nosave address range: 00000000000a0000 - 00000000000e4000
-Nosave address range: 00000000000e4000 - 0000000000100000
+swsusp: Registered nosave memory region: 000000000009e000 - 000000000009f000
+swsusp: Registered nosave memory region: 000000000009f000 - 00000000000a0000
+swsusp: Registered nosave memory region: 00000000000a0000 - 00000000000e4000
+swsusp: Registered nosave memory region: 00000000000e4000 - 0000000000100000
 Allocating PCI resources starting at 80000000 (gap: 7f000000:7fe00000)
 SMP: Allowing 4 CPUs, 2 hotplug CPUs
-PERCPU: Allocating 36992 bytes of per cpu data
-Built 1 zonelists.  Total pages: 511900
+PERCPU: Allocating 35176 bytes of per cpu data
+Built 1 zonelists in Node order.  Total pages: 511828
+Policy zone: DMA32
 Kernel command line: root=/dev/sda6 ro quiet vga=791 
 Initializing CPU#0
 PID hash table entries: 4096 (order: 12, 32768 bytes)
+Extended CMOS year: 2000
+time.c: Detected 2399.997 MHz processor.
 Console: colour dummy device 80x25
-Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
-Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
+console [tty0] enabled
 Checking aperture...
 Calgary: detecting Calgary via BIOS EBDA area
 Calgary: Unable to locate Rio Grande table in EBDA - bailing!
-Memory: 2038324k/2080320k available (1970k kernel code, 41604k reserved, 920k data, 284k init)
-Calibrating delay using timer specific routine.. 4804.04 BogoMIPS (lpj=9608092)
+Memory: 2041096k/2080320k available (2066k kernel code, 38832k reserved, 977k data, 304k init)
+Calibrating delay using timer specific routine.. 4803.34 BogoMIPS (lpj=9606690)
 Security Framework v1.0.0 initialized
 SELinux:  Disabled at boot.
 Capability LSM initialized
+Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
+Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
 Mount-cache hash table entries: 256
 CPU: L1 I cache: 32K, L1 D cache: 32K
 CPU: L2 cache: 4096K
@@ -94,14 +101,14 @@
 CPU: Processor Core ID: 0
 CPU0: Thermal monitoring enabled (TM2)
 SMP alternatives: switching to UP code
-ACPI: Core revision 20060707
+ACPI: Core revision 20070126
 Using local APIC timer interrupts.
-result 16666675
+result 16666629
 Detected 16.666 MHz APIC timer.
 SMP alternatives: switching to SMP code
 Booting processor 1/2 APIC 0x1
 Initializing CPU#1
-Calibrating delay using timer specific routine.. 4800.01 BogoMIPS (lpj=9600034)
+Calibrating delay using timer specific routine.. 4800.03 BogoMIPS (lpj=9600060)
 CPU: L1 I cache: 32K, L1 D cache: 32K
 CPU: L2 cache: 4096K
 CPU 1/1 -> Node 0
@@ -109,25 +116,20 @@
 CPU: Processor Core ID: 1
 CPU1: Thermal monitoring enabled (TM2)
 Intel(R) Core(TM)2 CPU          6600  @ 2.40GHz stepping 06
+checking TSC synchronization [CPU#0 -> CPU#1]: passed.
 Brought up 2 CPUs
-testing NMI watchdog ... OK.
-time.c: Using 14.318180 MHz WALL HPET GTOD HPET/TSC timer.
-time.c: Detected 2400.003 MHz processor.
-migration_cost=20
 NET: Registered protocol family 16
 ACPI: bus type pci registered
 PCI: BIOS Bug: MCFG area at e0000000 is not E820-reserved
 PCI: Not using MMCONFIG.
 PCI: Using configuration type 1
+ACPI: EC: Look up EC in DSDT
 ACPI: Interpreter enabled
+ACPI: (supports S0 S1 S3)
 ACPI: Using IOAPIC for interrupt routing
 ACPI: PCI Root Bridge [PCI0] (0000:00)
-PCI: Probing PCI hardware (bus 00)
 PCI quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
 PCI quirk: region 0480-04bf claimed by ICH6 GPIO
-Boot video device is 0000:01:00.0
-0000:02:00.0: cannot adjust BAR2 (not I/O)
-0000:02:00.0: cannot adjust BAR3 (not I/O)
 PCI: Transparent bridge - 0000:00:1e.0
 ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
 ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
@@ -142,8 +144,10 @@
 ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 *14 15)
 ACPI: PCI Interrupt Link [LNKG] (IRQs *3 4 5 6 7 10 11 12 14 15)
 ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *7 10 11 12 14 15)
+ACPI Warning (tbutils-0217): Incorrect checksum in table [OEMB] -  CD, should be C4 [20070126]
 Linux Plug and Play Support v0.97 (c) Adam Belay
 pnp: PnP ACPI init
+ACPI: bus type pnp registered
 pnp: ACPI device : hid PNP0A08
 pnp: ACPI device : hid PNP0C01
 pnp: ACPI device : hid PNP0200
@@ -161,26 +165,39 @@
 pnp: ACPI device : hid PNP0C02
 pnp: ACPI device : hid PNP0C01
 pnp: PnP ACPI: found 16 devices
+ACPI: ACPI bus type pnp unregistered
 usbcore: registered new interface driver usbfs
 usbcore: registered new interface driver hub
 usbcore: registered new device driver usb
 PCI: Using ACPI for IRQ routing
 PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
-PCI: Cannot allocate resource region 2 of device 0000:02:00.0
-PCI: Cannot allocate resource region 3 of device 0000:02:00.0
 NET: Registered protocol family 8
 NET: Registered protocol family 20
+PCI-GART: No AMD northbridge found.
 hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
 hpet0: 3 64-bit timers, 14318180 Hz
-PCI-GART: No AMD northbridge found.
+ACPI: RTC can wake from S4
+Time: tsc clocksource has been installed.
 pnp: the driver 'system' has been registered
 pnp: match found with the PnP device '00:01' and the driver 'system'
+pnp: 00:01: iomem range 0xfed14000-0xfed19fff has been reserved
 pnp: match found with the PnP device '00:08' and the driver 'system'
 pnp: 00:08: ioport range 0x290-0x297 has been reserved
 pnp: match found with the PnP device '00:09' and the driver 'system'
+pnp: 00:09: iomem range 0xfed1c000-0xfed1ffff has been reserved
+pnp: 00:09: iomem range 0xfed20000-0xfed8ffff has been reserved
+pnp: 00:09: iomem range 0xff9fa000-0xff9fafff has been reserved
+pnp: 00:09: iomem range 0xfff00000-0xfffffffe could not be reserved
 pnp: match found with the PnP device '00:0b' and the driver 'system'
+pnp: 00:0b: iomem range 0xfec00000-0xfec00fff has been reserved
+pnp: 00:0b: iomem range 0xfee00000-0xfee00fff could not be reserved
 pnp: match found with the PnP device '00:0e' and the driver 'system'
+pnp: 00:0e: iomem range 0xe0000000-0xefffffff has been reserved
 pnp: match found with the PnP device '00:0f' and the driver 'system'
+pnp: 00:0f: iomem range 0x0-0x9ffff could not be reserved
+pnp: 00:0f: iomem range 0xc0000-0xcffff has been reserved
+pnp: 00:0f: iomem range 0xe0000-0xfffff could not be reserved
+pnp: 00:0f: iomem range 0x100000-0x7effffff could not be reserved
 PCI: Bridge: 0000:00:01.0
   IO window: 8000-afff
   MEM window: ff700000-ff7fffff
@@ -206,20 +223,21 @@
 PCI: Setting latency timer of device 0000:00:1e.0 to 64
 NET: Registered protocol family 2
 IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
-TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
+TCP established hash table entries: 262144 (order: 10, 6291456 bytes)
 TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
 TCP: Hash tables configured (established 262144 bind 65536)
 TCP reno registered
 checking if image is initramfs... it is
-Freeing initrd memory: 5937k freed
+Freeing initrd memory: 5950k freed
 audit: initializing netlink socket (disabled)
-audit(1181990747.912:1): initialized
+audit(1189181505.780:1): initialized
 VFS: Disk quotas dquot_6.5.1
 Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
 io scheduler noop registered
 io scheduler anticipatory registered
 io scheduler deadline registered
 io scheduler cfq registered (default)
+Boot video device is 0000:01:00.0
 PCI: Setting latency timer of device 0000:00:01.0 to 64
 assign_interrupt_mode Found MSI capability
 Allocate Port Service[0000:00:01.0:pcie00]
@@ -231,7 +249,7 @@
 assign_interrupt_mode Found MSI capability
 Allocate Port Service[0000:00:1c.4:pcie00]
 Allocate Port Service[0000:00:1c.4:pcie02]
-vesafb: framebuffer at 0xc0000000, mapped to 0xffffc20000080000, using 3072k, total 16384k
+vesafb: framebuffer at 0xc0000000, mapped to 0xffffc20000b00000, using 3072k, total 16384k
 vesafb: mode is 1024x768x16, linelength=2048, pages=9
 vesafb: scrolling: redraw
 vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
@@ -239,7 +257,7 @@
 fb0: VESA VGA frame buffer device
 Real Time Clock Driver v1.12ac
 hpet_resources: 0xfed00000 is busy
-Linux agpgart interface v0.101 (c) Dave Jones
+Linux agpgart interface v0.102
 Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
 serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
 pnp: the driver 'serial' has been registered
@@ -257,11 +275,10 @@
 TCP bic registered
 NET: Registered protocol family 1
 NET: Registered protocol family 17
-ACPI: (supports S0 S1 S3 S4 S5)
-Freeing unused kernel memory: 284k freed
+Freeing unused kernel memory: 304k freed
 input: AT Translated Set 2 keyboard as /class/input/input0
-ACPI Exception (acpi_processor-0677): AE_NOT_FOUND, Processor Device is not present [20060707]
-ACPI Exception (acpi_processor-0677): AE_NOT_FOUND, Processor Device is not present [20060707]
+ACPI Exception (processor_core-0797): AE_NOT_FOUND, Processor Device is not present [20070126]
+ACPI Exception (processor_core-0797): AE_NOT_FOUND, Processor Device is not present [20070126]
 USB Universal Host Controller Interface driver v3.0
 ACPI: PCI Interrupt 0000:00:1a.0[A] -> GSI 16 (level, low) -> IRQ 16
 PCI: Setting latency timer of device 0000:00:1a.0 to 64
@@ -274,10 +291,9 @@
 Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
 ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
 pnp: the driver 'ide' has been registered
-SCSI subsystem initialized
-ieee1394: Initialized config rom entry `ip1394'
 Floppy drive(s): fd0 is 1.44M
-libata version 2.00 loaded.
+SCSI subsystem initialized
+libata version 2.21 loaded.
 FDC 0 is a post-1991 82077
 ACPI: PCI Interrupt 0000:00:1a.1[B] -> GSI 17 (level, low) -> IRQ 17
 PCI: Setting latency timer of device 0000:00:1a.1 to 64
@@ -312,8 +328,42 @@
 hub 5-0:1.0: USB hub found
 hub 5-0:1.0: 2 ports detected
 ACPI: PCI Interrupt 0000:04:04.0[A] -> GSI 19 (level, low) -> IRQ 19
-skge 1.9 addr 0xff9f8000 irq 19 chip Yukon-Lite rev 9
-skge eth0: addr 00:18:f3:90:8e:7b
+PCI: Unable to reserve mem region #1:4000@ff9f8000 for device 0000:04:04.0
+skge 0000:04:04.0: cannot obtain PCI resources
+ACPI: PCI interrupt for device 0000:04:04.0 disabled
+skge: probe of 0000:04:04.0 failed with error -16
+ACPI: PCI Interrupt 0000:04:03.0[A] -> GSI 21 (level, low) -> IRQ 21
+firewire_ohci: Added fw-ohci device 0000:04:03.0, OHCI version 1.10
+ahci 0000:00:1f.2: version 2.3
+ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 19 (level, low) -> IRQ 19
+firewire_core: created new fw device fw0 (0 config rom retries, S400)
+ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0x33 impl SATA mode
+ahci 0000:00:1f.2: flags: 64bit ncq sntf ilck stag pm led clo pmp pio slum part 
+PCI: Setting latency timer of device 0000:00:1f.2 to 64
+scsi0 : ahci
+scsi1 : ahci
+scsi2 : ahci
+scsi3 : ahci
+scsi4 : ahci
+scsi5 : ahci
+ata1: SATA max UDMA/133 cmd 0xffffc20000ac2900 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1276
+ata2: SATA max UDMA/133 cmd 0xffffc20000ac2980 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1276
+ata3: DUMMY
+ata4: DUMMY
+ata5: SATA max UDMA/133 cmd 0xffffc20000ac2b00 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1276
+ata6: SATA max UDMA/133 cmd 0xffffc20000ac2b80 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1276
+ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
+ata1.00: ATA-7: SAMSUNG HD401LJ, ZZ100-15, max UDMA7
+ata1.00: 781422768 sectors, multi 0: LBA48 NCQ (not used)
+ata1.00: configured for UDMA/133
+ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
+ata2.00: ATAPI: HL-DT-STDVD-RAM GSA-H30N, 1.01, max UDMA/100
+ata2.00: configured for UDMA/100
+ata5: SATA link down (SStatus 0 SControl 300)
+ata6: SATA link down (SStatus 0 SControl 300)
+scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HD401LJ  ZZ10 PQ: 0 ANSI: 5
+scsi 1:0:0:0: CD-ROM            HL-DT-ST DVD-RAM GSA-H30N 1.01 PQ: 0 ANSI: 5
+ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
 ACPI: PCI Interrupt 0000:00:1a.7[C] -> GSI 18 (level, low) -> IRQ 18
 PCI: Setting latency timer of device 0000:00:1a.7 to 64
 ehci_hcd 0000:00:1a.7: EHCI Host Controller
@@ -325,6 +375,15 @@
 usb usb6: configuration #1 chosen from 1 choice
 hub 6-0:1.0: USB hub found
 hub 6-0:1.0: 4 ports detected
+ahci 0000:02:00.0: AHCI 0001.0000 32 slots 2 ports 3 Gbps 0x3 impl SATA mode
+ahci 0000:02:00.0: flags: 64bit ncq pm led clo pmp pio slum part 
+PCI: Setting latency timer of device 0000:02:00.0 to 64
+scsi6 : ahci
+scsi7 : ahci
+ata7: SATA max UDMA/133 cmd 0xffffc20000ac4100 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 16
+ata8: SATA max UDMA/133 cmd 0xffffc20000ac4180 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 16
+ata7: SATA link down (SStatus 0 SControl 300)
+ata8: SATA link down (SStatus 0 SControl 300)
 ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 23 (level, low) -> IRQ 23
 PCI: Setting latency timer of device 0000:00:1d.7 to 64
 ehci_hcd 0000:00:1d.7: EHCI Host Controller
@@ -336,114 +395,69 @@
 usb usb7: configuration #1 chosen from 1 choice
 hub 7-0:1.0: USB hub found
 hub 7-0:1.0: 6 ports detected
-ACPI: PCI Interrupt 0000:04:03.0[A] -> GSI 21 (level, low) -> IRQ 21
-ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[21]  MMIO=[ff9ff000-ff9ff7ff]  Max Packet=[2048]  IR/IT contexts=[4/8]
-ahci 0000:00:1f.2: version 2.0
-ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 19 (level, low) -> IRQ 19
-PCI: Setting latency timer of device 0000:00:1f.2 to 64
-ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0x33 impl SATA mode
-ahci 0000:00:1f.2: flags: 64bit ncq ilck stag pm led clo pmp pio slum part 
-ata1: SATA max UDMA/133 cmd 0xFFFFC20000056900 ctl 0x0 bmdma 0x0 irq 1276
-ata2: SATA max UDMA/133 cmd 0xFFFFC20000056980 ctl 0x0 bmdma 0x0 irq 1276
-ata3: DUMMY
-ata4: DUMMY
-ata5: SATA max UDMA/133 cmd 0xFFFFC20000056B00 ctl 0x0 bmdma 0x0 irq 1276
-ata6: SATA max UDMA/133 cmd 0xFFFFC20000056B80 ctl 0x0 bmdma 0x0 irq 1276
-scsi0 : ahci
-ieee1394: Host added: ID:BUS[0-00:1023]  GUID[0011d80000ec51d2]
-ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
-ata1.00: ATA-7, max UDMA7, 781422768 sectors: LBA48 NCQ (depth 31/32)
-ata1.00: configured for UDMA/133
-scsi1 : ahci
-ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
-ata2.00: ATAPI, max UDMA/100
-ata2.00: configured for UDMA/100
-scsi2 : ahci
-scsi3 : ahci
-scsi4 : ahci
-ata5: SATA link down (SStatus 0 SControl 300)
-scsi5 : ahci
-ata6: SATA link down (SStatus 0 SControl 300)
-scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HD401LJ  ZZ10 PQ: 0 ANSI: 5
-scsi 1:0:0:0: CD-ROM            HL-DT-ST DVD-RAM GSA-H30N 1.01 PQ: 0 ANSI: 5
-PCI: Device 0000:02:00.0 not available because of resource collisions
-ahci: probe of 0000:02:00.0 failed with error -22
-JMB363: IDE controller at PCI slot 0000:02:00.0
-PCI: Device 0000:02:00.0 not available because of resource collisions
-ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
-JMB363: BIOS configuration fixed.
+sd 0:0:0:0: [sda] 781422768 512-byte hardware sectors (400088 MB)
+sd 0:0:0:0: [sda] Write Protect is off
+sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
+sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
+sd 0:0:0:0: [sda] 781422768 512-byte hardware sectors (400088 MB)
+sd 0:0:0:0: [sda] Write Protect is off
+sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
+sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
+ sda: sda1 sda2 sda3 < sda5 sda6 sda7 >
+sd 0:0:0:0: [sda] Attached SCSI disk
+JMB363: IDE controller at PCI slot 0000:02:00.1
+PCI: Enabling device 0000:02:00.1 (0000 -> 0001)
+ACPI: PCI Interrupt 0000:02:00.1[B] -> GSI 17 (level, low) -> IRQ 17
 JMB363: chipset revision 2
-JMB363: 100% native mode on irq 16
-JMB363: dma_base is invalid
-ide0: JMB363 Bus-Master DMA disabled (BIOS)
-JMB363: dma_base is invalid
-ide1: JMB363 Bus-Master DMA disabled (BIOS)
+JMB363: 100% native mode on irq 17
+PCI: Setting latency timer of device 0000:02:00.1 to 64
+    ide0: BM-DMA at 0xb400-0xb407, BIOS settings: hda:DMA, hdb:DMA
+    ide1: BM-DMA at 0xb408-0xb40f, BIOS settings: hdc:pio, hdd:pio
 Probing IDE interface ide0...
-SCSI device sda: 781422768 512-byte hdwr sectors (400088 MB)
-sda: Write Protect is off
-sda: Mode Sense: 00 3a 00 00
-SCSI device sda: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
-SCSI device sda: 781422768 512-byte hdwr sectors (400088 MB)
-sda: Write Protect is off
-sda: Mode Sense: 00 3a 00 00
-SCSI device sda: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
- sda: sda1 sda2 sda3 < sda5 sda6 >
-sd 0:0:0:0: Attached scsi disk sda
 sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa/form2 cdda tray
 Uniform CD-ROM driver Revision: 3.20
 sr 1:0:0:0: Attached scsi CD-ROM sr0
 sd 0:0:0:0: Attached scsi generic sg0 type 0
 sr 1:0:0:0: Attached scsi generic sg1 type 5
+hdb: WDC WD400BB-00AUA1, ATA DISK drive
+hdb: selected mode 0x45
+ide0 at 0xbc00-0xbc07,0xb882 on irq 17
 Probing IDE interface ide1...
-JMB363: IDE controller at PCI slot 0000:02:00.1
-PCI: Enabling device 0000:02:00.1 (0000 -> 0001)
-ACPI: PCI Interrupt 0000:02:00.1[B] -> GSI 17 (level, low) -> IRQ 17
-JMB363: chipset revision 2
-JMB363: 100% native mode on irq 17
-PCI: Setting latency timer of device 0000:02:00.1 to 64
-    ide2: BM-DMA at 0xb400-0xb407, BIOS settings: hde:DMA, hdf:DMA
-    ide3: BM-DMA at 0xb408-0xb40f, BIOS settings: hdg:pio, hdh:pio
-Probing IDE interface ide2...
-hdf: WDC WD400BB-00AUA1, ATA DISK drive
-hdf: hw_config=6b00
-hdf: hw_config=6b00
-ide2 at 0xbc00-0xbc07,0xb882 on irq 17
-Probing IDE interface ide3...
-hdf: max request size: 128KiB
-hdf: 78165360 sectors (40020 MB) w/2048KiB Cache, CHS=65535/16/63<6>hdf: hw_config=6b00
-, UDMA(100)
-hdf: cache flushes not supported
- hdf: hdf1 hdf2 < hdf5 hdf6 hdf7 hdf8 hdf9 hdf10 hdf11 >
+hdb: max request size: 128KiB
+hdb: 78165360 sectors (40020 MB) w/2048KiB Cache, CHS=65535/16/63, UDMA(100)
+hdb: cache flushes not supported
+ hdb: hdb1 hdb2 < hdb5 hdb6 hdb7 hdb8 hdb9 hdb10 hdb11 >
 kjournald starting.  Commit interval 5 seconds
 EXT3-fs: mounted filesystem with ordered data mode.
-eth1394: eth1: IEEE-1394 IPv4 over 1394 Ethernet (fw-host0)
-PCI: Enabling device 0000:00:1f.3 (0001 -> 0003)
-ACPI: PCI Interrupt 0000:00:1f.3[C] -> GSI 18 (level, low) -> IRQ 18
-agpgart: Detected an Intel 965G Chipset.
-agpgart: AGP aperture is 256M @ 0x0
-iTCO_wdt: Intel TCO WatchDog Timer Driver v1.01 (11-Nov-2006)
+input: PC Speaker as /class/input/input1
+iTCO_wdt: Intel TCO WatchDog Timer Driver v1.02 (26-Jul-2007)
 iTCO_wdt: Found a ICH8 or ICH8R TCO device (Version=2, TCOBASE=0x0860)
 iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
-input: PC Speaker as /class/input/input1
+input: Power Button (FF) as /class/input/input2
+ACPI: Power Button (FF) [PWRF]
+input: Power Button (CM) as /class/input/input3
+ACPI: Power Button (CM) [PWRB]
+ACPI: PCI Interrupt 0000:00:1b.0[A] -> GSI 22 (level, low) -> IRQ 22
+PCI: Setting latency timer of device 0000:00:1b.0 to 64
+hda_codec: Unknown model for AD1988, trying auto-probe from BIOS...
 Linux video capture interface: v2.00
+PCI: Enabling device 0000:00:1f.3 (0001 -> 0003)
+ACPI: PCI Interrupt 0000:00:1f.3[C] -> GSI 18 (level, low) -> IRQ 18
 logips2pp: Detected unknown logitech mouse model 95
 saa7146: register extension 'dvb'.
 ACPI: PCI Interrupt 0000:04:01.0[A] -> GSI 22 (level, low) -> IRQ 22
-saa7146: found saa7146 @ mem ffffc2000039c800 (revision 1, irq 22) (0x13c2,0x0003).
-DVB: registering new adapter (Technotrend/Hauppauge WinTV Nexus-S rev2.X).
-ACPI: PCI Interrupt 0000:00:1b.0[A] -> GSI 22 (level, low) -> IRQ 22
-PCI: Setting latency timer of device 0000:00:1b.0 to 64
+saa7146: found saa7146 @ mem ffffc20000ace800 (revision 1, irq 22) (0x13c2,0x0003).
+DVB: registering new adapter (Technotrend/Hauppauge WinTV Nexus-S rev2.X)
 adapter has MAC addr = 00:d0:5c:22:68:cc
 dvb-ttpci: gpioirq unknown type=0 len=0
 dvb-ttpci: info @ card 0: firm f0240009, rtsl b0250018, vid 71010068, app 80002622
 dvb-ttpci: firmware @ card 0 supports CI link layer interface
-hda_codec: Unknown model for AD1988, trying auto-probe from BIOS...
-input: ImExPS/2 Logitech Explorer Mouse as /class/input/input2
+input: ImExPS/2 Logitech Explorer Mouse as /class/input/input4
 dvb-ttpci: adac type set to 0 @ card 0
 saa7146_vv: saa7146 (0): registered device video0 [v4l2]
 saa7146_vv: saa7146 (0): registered device vbi0 [v4l2]
 DVB: registering frontend 0 (ST STV0299 DVB-S)...
-input: DVB on-card IR receiver as /class/input/input3
+input: DVB on-card IR receiver as /class/input/input5
 dvb-ttpci: found av7110-0.
 EXT3 FS on sda6, internal journal
 device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@redhat.com
@@ -452,23 +466,16 @@
 EXT3-fs: mounted filesystem with ordered data mode.
 kjournald starting.  Commit interval 5 seconds
 EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
-EXT3 FS on hdf10, internal journal
+EXT3 FS on sda7, internal journal
 EXT3-fs: mounted filesystem with ordered data mode.
-skge eth0: enabling interface
-skge eth0: Link is up at 1000 Mbps, full duplex, flow control both
 NET: Registered protocol family 10
 lo: Disabled Privacy Extensions
-input: Power Button (FF) as /class/input/input4
-ACPI: Power Button (FF) [PWRF]
-input: Power Button (CM) as /class/input/input5
-ACPI: Power Button (CM) [PWRB]
 pnp: the driver 'parport_pc' has been registered
 lp: driver loaded but no devices found
 ppdev: user-space parallel port driver
-eth0: no IPv6 routers present
 [drm] Initialized drm 1.1.0 20060810
 ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 16
-[drm] Initialized radeon 1.25.0 20060524 on minor 0
+[drm] Initialized radeon 1.28.0 20060524 on minor 0
 [drm] Setting GART location based on new memory map
 [drm] Loading R300 Microcode
 [drm] writeback test succeeded in 1 usecs

--=-piyPvoO5zPjPnU5hgUHf--

