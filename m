From: Benjamin LaHaise <bcrl@kvack.org>
Subject: SKB BUG: Invalid truesize, current git
Date: Mon, 6 Nov 2006 14:07:26 -0500
Message-ID: <20061106190725.GW9057@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:6603 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1752432AbWKFTHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 14:07:39 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I managed to get a backtrace for the Invalid truesize bug.  The trigger is 
running LMbench2, but it's rater intermittent.  Traffic should be going 
over the loopback interface, but the main nic on the machine is e1000.  
Let me know if anyone has any ideas for things to try.

		-ben

Linux version 2.6.19-rc4 (root@woody.kvack.org) (gcc version 4.1.1 20060525 (Red Hat 4.1.1-1)) #73 SMP Mon Nov 6 13:13:44 EST 2006
Command line: ro root=LABEL=/1 console=ttyS0,38400
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009cc00 (usable)
 BIOS-e820: 000000000009cc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000cc000 - 00000000000d0000 (reserved)
 BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000bff60000 (usable)
 BIOS-e820: 00000000bff60000 - 00000000bff69000 (ACPI data)
 BIOS-e820: 00000000bff69000 - 00000000bff80000 (ACPI NVS)
 BIOS-e820: 00000000bff80000 - 00000000c0000000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000140000000 (usable)
Entering add_active_range(0, 0, 156) 0 entries of 256 used
Entering add_active_range(0, 256, 786272) 1 entries of 256 used
Entering add_active_range(0, 1048576, 1310720) 2 entries of 256 used
end_pfn_map = 1310720
DMI present.
ACPI: RSDP (v000 PTLTD                                 ) @ 0x00000000000f58d0
ACPI: RSDT (v001 PTLTD    RSDT   0x06040000  LTP 0x00000000) @ 0x00000000bff636df
ACPI: FADT (v001 INTEL  TUMWATER 0x06040000 PTL  0x00000003) @ 0x00000000bff68e48
ACPI: MADT (v001 PTLTD  	 APIC   0x06040000  LTP 0x00000000) @ 0x00000000bff68ebc
ACPI: MCFG (v001 PTLTD    MCFG   0x06040000  LTP 0x00000000) @ 0x00000000bff68f4c
ACPI: BOOT (v001 PTLTD  $SBFTBL$ 0x06040000  LTP 0x00000001) @ 0x00000000bff68f88
ACPI: SPCR (v001 PTLTD  $UCRTBL$ 0x06040000 PTL  0x00000001) @ 0x00000000bff68fb0
ACPI: SSDT (v001  PmRef    CpuPm 0x00003000 INTL 0x20050228) @ 0x00000000bff6371b
ACPI: DSDT (v001  Intel BLAKFORD 0x06040000 MSFT 0x0100000e) @ 0x0000000000000000
Entering add_active_range(0, 0, 156) 0 entries of 256 used
Entering add_active_range(0, 256, 786272) 1 entries of 256 used
Entering add_active_range(0, 1048576, 1310720) 2 entries of 256 used
Zone PFN ranges:
  DMA             0 ->     4096
  DMA32        4096 ->  1048576
  Normal    1048576 ->  1310720
early_node_map[3] active PFN ranges
    0:        0 ->      156
    0:      256 ->   786272
    0:  1048576 ->  1310720
On node 0 totalpages: 1048316
  DMA zone: 56 pages used for memmap
  DMA zone: 1395 pages reserved
  DMA zone: 2545 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 767896 pages, LIFO batch:31
  Normal zone: 3584 pages used for memmap
  Normal zone: 258560 pages, LIFO batch:31
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
Processor #0 (Bootup-CPU)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x06] enabled)
Processor #6
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Processor #1
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x07] enabled)
Processor #7
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x03] address[0xfec80000] gsi_base[24])
IOAPIC[1]: apic_id 3, address 0xfec80000, GSI 24-47
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Setting APIC routing to flat
Using ACPI (MADT) for SMP configuration information
Nosave address range: 000000000009c000 - 000000000009d000
Nosave address range: 000000000009d000 - 00000000000a0000
Nosave address range: 00000000000a0000 - 00000000000cc000
Nosave address range: 00000000000cc000 - 00000000000d0000
Nosave address range: 00000000000d0000 - 00000000000e4000
Nosave address range: 00000000000e4000 - 0000000000100000
Nosave address range: 00000000bff60000 - 00000000bff69000
Nosave address range: 00000000bff69000 - 00000000bff80000
Nosave address range: 00000000bff80000 - 00000000c0000000
Nosave address range: 00000000c0000000 - 00000000e0000000
Nosave address range: 00000000e0000000 - 00000000f0000000
Nosave address range: 00000000f0000000 - 00000000fec00000
Nosave address range: 00000000fec00000 - 00000000fec10000
Nosave address range: 00000000fec10000 - 00000000fee00000
Nosave address range: 00000000fee00000 - 00000000fee01000
Nosave address range: 00000000fee01000 - 00000000ff000000
Nosave address range: 00000000ff000000 - 0000000100000000
Allocating PCI resources starting at c2000000 (gap: c0000000:20000000)
PERCPU: Allocating 33152 bytes of per cpu data
Built 1 zonelists.  Total pages: 1029001
Kernel command line: ro root=LABEL=/1 console=ttyS0,38400
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
Console: colour VGA+ 80x25
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
Checking aperture...
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing software IO TLB between 0x5c4b000 - 0x9c4b000
Memory: 4042384k/5242880k available (3363k kernel code, 150512k reserved, 1338k data, 268k init)
Calibrating delay using timer specific routine.. 5340.00 BogoMIPS (lpj=26700019)
Mount-cache hash table entries: 256
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
using mwait in idle threads.
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU0: Thermal monitoring handled by SMI
Freeing SMP alternatives: 36k freed
ACPI: Core revision 20060707
Using local APIC timer interrupts.
result 20833621
Detected 20.833 MHz APIC timer.
Booting processor 1/4 APIC 0x6
Initializing CPU#1
Calibrating delay using timer specific routine.. 5333.46 BogoMIPS (lpj=26667307)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 3
CPU: Processor Core ID: 0
CPU1: Thermal monitoring enabled (TM2)
Genuine Intel(R) CPU                  @ 2.66GHz stepping 04
Booting processor 2/4 APIC 0x1
Initializing CPU#2
Calibrating delay using timer specific routine.. 5333.47 BogoMIPS (lpj=26667385)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU2: Thermal monitoring enabled (TM2)
Genuine Intel(R) CPU                  @ 2.66GHz stepping 04
Booting processor 3/4 APIC 0x7
Initializing CPU#3
Calibrating delay using timer specific routine.. 5333.52 BogoMIPS (lpj=26667612)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 3
CPU: Processor Core ID: 1
CPU3: Thermal monitoring enabled (TM2)
Genuine Intel(R) CPU                  @ 2.66GHz stepping 04
Brought up 4 CPUs
testing NMI watchdog ... OK.
time.c: Using 1.193182 MHz WALL PIT GTOD PIT/TSC timer.
time.c: Detected 2666.705 MHz processor.
migration_cost=14,9811
checking if image is initramfs... it is
Freeing initrd memory: 867k freed
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: Using MMCONFIG at e0000000
PCI: No mmconfig possible on device 0b:01
ACPI: Interpreter enabled
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.1
PCI: PXH quirk detected, disabling MSI for SHPC device
PCI: PXH quirk detected, disabling MSI for SHPC device
Boot video device is 0000:0b:01.0
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMD0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMD0.BPD0.PXH0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMD0.BPD0.PXH1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMD0.BPD2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMF3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P6._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCIB._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 11 14 15) *9
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 6 7 10 11 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 *11 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 *10 11 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 4 5 6 7 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 4 5 6 7 10 11 14 15) *0, disabled.
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
pnp: PnP ACPI: found 13 devices
SCSI subsystem initialized
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
PCI-GART: No AMD northbridge found.
PCI: Bridge: 0000:03:00.0
  IO window: 2000-3fff
  MEM window: c8200000-c82fffff
  PREFETCH window: c2000000-c21fffff
PCI: Bridge: 0000:03:00.2
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:02:00.0
  IO window: 2000-3fff
  MEM window: c8200000-c82fffff
  PREFETCH window: c2000000-c21fffff
PCI: Bridge: 0000:02:02.0
  IO window: 4000-4fff
  MEM window: c8300000-c83fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:01:00.0
  IO window: 2000-4fff
  MEM window: c8200000-c83fffff
  PREFETCH window: c2000000-c21fffff
PCI: Bridge: 0000:01:00.3
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:02.0
  IO window: 2000-4fff
  MEM window: c8100000-c83fffff
  PREFETCH window: c2000000-c21fffff
PCI: Bridge: 0000:00:04.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:06.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1e.0
  IO window: 5000-5fff
  MEM window: c8400000-c84fffff
  PREFETCH window: d0000000-d7ffffff
ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:02.0 to 64
ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:01:00.0 to 64
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:02:00.0 to 64
PCI: Setting latency timer of device 0000:03:00.0 to 64
PCI: Setting latency timer of device 0000:03:00.2 to 64
ACPI: PCI Interrupt 0000:02:02.0[A] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:02:02.0 to 64
PCI: Setting latency timer of device 0000:01:00.3 to 64
ACPI: PCI Interrupt 0000:00:04.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:04.0 to 64
ACPI: PCI Interrupt 0000:00:06.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:06.0 to 64
ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1c.0 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
Simple Boot Flag at 0x38 set to 0x1
IA-32 Microcode Update Driver: v1.14a <tigran@veritas.com>
audit: initializing netlink socket (disabled)
audit(1162837221.420:1): initialized
io scheduler noop registered
io scheduler deadline registered (default)
io scheduler cfq registered
PCI: Setting latency timer of device 0000:00:02.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:02.0:pcie00]
Allocate Port Service[0000:00:02.0:pcie01]
PCI: Setting latency timer of device 0000:00:04.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:04.0:pcie00]
Allocate Port Service[0000:00:04.0:pcie01]
PCI: Setting latency timer of device 0000:00:06.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:06.0:pcie00]
Allocate Port Service[0000:00:06.0:pcie01]
PCI: Setting latency timer of device 0000:00:1c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.0:pcie00]
Allocate Port Service[0000:00:1c.0:pcie02]
Allocate Port Service[0000:00:1c.0:pcie03]
PCI: Setting latency timer of device 0000:01:00.0 to 64
Allocate Port Service[0000:01:00.0:pcie10]
Allocate Port Service[0000:01:00.0:pcie11]
PCI: Setting latency timer of device 0000:02:00.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:02:00.0:pcie20]
Allocate Port Service[0000:02:00.0:pcie21]
PCI: Setting latency timer of device 0000:02:02.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:02:02.0:pcie20]
Allocate Port Service[0000:02:02.0:pcie21]
Evaluate _OSC Set fails. Status = 0x0005
aer_init: AER service init fails - No ACPI _OSC support
aer: probe of 0000:00:02.0:pcie01 failed with error 1
Evaluate _OSC Set fails. Status = 0x0005
aer_init: AER service init fails - No ACPI _OSC support
aer: probe of 0000:00:04.0:pcie01 failed with error 1
Evaluate _OSC Set fails. Status = 0x0005
aer_init: AER service init fails - No ACPI _OSC support
aer: probe of 0000:00:06.0:pcie01 failed with error 1
ACPI: PCI Interrupt 0000:0b:01.0[A] -> GSI 18 (level, low) -> IRQ 18
radeonfb: Found Intel x86 BIOS ROM Image
radeonfb: Retrieved PLL infos from BIOS
radeonfb: Reference=27.00 MHz (RefDiv=60) Memory=200.00 Mhz, System=200.00 MHz
radeonfb: PLL min 12000 max 35000
i2c_adapter i2c-1: unable to read EDID block.
i2c_adapter i2c-1: unable to read EDID block.
i2c_adapter i2c-1: unable to read EDID block.
i2c_adapter i2c-3: unable to read EDID block.
i2c_adapter i2c-3: unable to read EDID block.
i2c_adapter i2c-3: unable to read EDID block.
radeonfb: Monitor 1 type CRT found
radeonfb: EDID probed
radeonfb: Monitor 2 type no found
radeonfb (0000:0b:01.0): ATI Radeon Q^ 
ACPI: Power Button (FF) [PWRF]
ACPI: Power Button (CM) [PWRB]
ACPI: Processor [CPU0] (supports 8 throttling states)
ACPI: Processor [CPU1] (supports 8 throttling states)
ACPI: Processor [CPU2] (supports 8 throttling states)
ACPI: Processor [CPU3] (supports 8 throttling states)
ACPI: Getting cpuindex for acpiid 0x4
ACPI: Getting cpuindex for acpiid 0x5
ACPI: Getting cpuindex for acpiid 0x6
ACPI: Getting cpuindex for acpiid 0x7
ibm_acpi: ec object not found
lp: driver loaded but no devices found
Real Time Clock Driver v1.12ac
Non-volatile memory driver v1.2
Linux agpgart interface v0.101 (c) Dave Jones
[drm] Initialized drm 1.0.1 20051102
[drm] Initialized radeon 1.25.0 20060524 on minor 0
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
00:09: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:0a: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
parport: PnPBIOS parport detected.
parport0: PC-style at 0x378 (0x778), irq 7, dma 3 [PCSPP,TRISTATE,COMPAT,EPP,ECP,DMA]
lp0: using parport0 (interrupt-driven).
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
RAMDISK driver initialized: 1 RAM disks of 4096K size 4096 blocksize
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 7.2.9-k4-NAPI
Copyright (c) 1999-2006 Intel Corporation.
ACPI: PCI Interrupt 0000:06:00.0[A] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:06:00.0 to 64
e1000: 0000:06:00.0: e1000_probe: (PCI Express:2.5Gb/s:32-bit) 00:30:48:31:97:6c
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI Interrupt 0000:06:00.1[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:06:00.1 to 64
e1000: 0000:06:00.1: e1000_probe: (PCI Express:2.5Gb/s:32-bit) 00:30:48:31:97:6d
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
pcnet32.c:v1.33-NAPI 27.Jun.2006 tsbogend@alpha.franken.de
e100: Intel(R) PRO/100 Network Driver, 3.5.17-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ESB2: IDE controller at PCI slot 0000:00:1f.1
ACPI: PCI Interrupt 0000:00:1f.1[A] -> GSI 18 (level, low) -> IRQ 18
ESB2: chipset revision 9
ESB2: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x1860-0x1867, BIOS settings: hda:DMA, hdb:pio
Probing IDE interface ide0...
hda: LITE-ON COMBO SOHC-5236V, ATAPI CD/DVD-ROM drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
hda: ATAPI 52X DVD-ROM CD-R/RW drive, 1536kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20
Loading iSCSI transport class v2.0-685.<7>libata version 2.00 loaded.
ahci 0000:00:1f.2: version 2.0
ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1f.2 to 64
ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 6 ports ? Gbps 0x3f impl SATA mode
ahci 0000:00:1f.2: flags: 64bit stag led pmp 
ata1: SATA max UDMA/133 cmd 0xFFFFC2000001E900 ctl 0x0 bmdma 0x0 irq 19
ata2: SATA max UDMA/133 cmd 0xFFFFC2000001E980 ctl 0x0 bmdma 0x0 irq 19
ata3: SATA max UDMA/133 cmd 0xFFFFC2000001EA00 ctl 0x0 bmdma 0x0 irq 19
ata4: SATA max UDMA/133 cmd 0xFFFFC2000001EA80 ctl 0x0 bmdma 0x0 irq 19
ata5: SATA max UDMA/133 cmd 0xFFFFC2000001EB00 ctl 0x0 bmdma 0x0 irq 19
ata6: SATA max UDMA/133 cmd 0xFFFFC2000001EB80 ctl 0x0 bmdma 0x0 irq 19
scsi0 : ahci
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-7, max UDMA/133, 234441648 sectors: LBA48 
ata1.00: ata1: dev 0 multi count 16
ata1.00: configured for UDMA/133
scsi1 : ahci
ata2: SATA link down (SStatus 0 SControl 300)
scsi2 : ahci
ata3: SATA link down (SStatus 0 SControl 300)
scsi3 : ahci
ata4: SATA link down (SStatus 0 SControl 300)
scsi4 : ahci
ata5: SATA link down (SStatus 0 SControl 300)
scsi5 : ahci
ata6: SATA link down (SStatus 0 SControl 300)
scsi 0:0:0:0: Direct-Access     ATA      WDC WD1200JS-00M 02.0 PQ: 0 ANSI: 5
SCSI device sda: 234441648 512-byte hdwr sectors (120034 MB)
sda: Write Protect is off
sda: Mode Sense: 00 3a 00 00
SCSI device sda: drive cache: write back
SCSI device sda: 234441648 512-byte hdwr sectors (120034 MB)
sda: Write Protect is off
sda: Mode Sense: 00 3a 00 00
SCSI device sda: drive cache: write back
 sda: sda1 sda2 sda3
sd 0:0:0:0: Attached scsi disk sda
sd 0:0:0:0: Attached scsi generic sg0 type 0
ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1d.7: debug port 1
PCI: cache line size of 32 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: irq 17, io mem 0xc8000400
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1d.0: irq 17, io base 0x00001800
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1d.1: irq 19, io base 0x00001820
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1d.2: irq 18, io base 0x00001840
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
usbcore: registered new interface driver usblp
drivers/usb/class/usblp.c: v0.13: USB Printer Device Class driver
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
usbcore: registered new interface driver usbhid
drivers/usb/input/hid-core.c: v2.6:USB HID core driver
PNP: PS/2 Controller [PNP0303:KBC0,PNP0f13:MSE0] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
mice: PS/2 mouse device common for all mice
md: linear personality registered for level -1
md: raid0 personality registered for level 0
md: raid1 personality registered for level 1
md: raid10 personality registered for level 10
input: AT Translated Set 2 keyboard as /class/input/input0
raid6: int64x1   2256 MB/s
raid6: int64x2   3099 MB/s
raid6: int64x4   3467 MB/s
raid6: int64x8   2151 MB/s
raid6: sse2x1    2295 MB/s
raid6: sse2x2    6972 MB/s
raid6: sse2x4    7378 MB/s
raid6: using algorithm sse2x4 (7378 MB/s)
md: raid6 personality registered for level 6
md: raid5 personality registered for level 5
md: raid4 personality registered for level 4
raid5: automatically using best checksumming function: generic_sse
   generic_sse:  9785.200 MB/sec
raid5: using function: generic_sse (9785.200 MB/sec)
md: multipath personality registered for level -4
md: faulty personality registered for level -5
device-mapper: ioctl: 4.10.0-ioctl (2006-09-14) initialised: dm-devel@redhat.com
device-mapper: multipath: version 1.0.5 loaded
device-mapper: multipath round-robin: version 1.0.0 loaded
device-mapper: multipath emc: version 0.0.3 loaded
EDAC MC: Ver: 2.0.1 Nov  6 2006
ACPI: PCI Interrupt 0000:00:08.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:08.0 to 64
Intel(R) I/OAT DMA Engine found, 4 channels
IPv4 over IPv4 tunneling driver
GRE over IPv4 tunneling driver
TCP bic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
Bridge firewalling registered
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
Freeing unused kernel memory: 268k freed
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
ACPI: PCI Interrupt 0000:04:01.0[A] -> GSI 16 (level, low) -> IRQ 16
eth2: ns83820.c: 0x22c: 00000000, subsystem: 0000:0000
eth2: detected 64 bit PCI data bus.
eth2: using 64 bit addressing.
eth2: ns83820 v0.22: DP83820 v1.2: 00:40:f4:21:ca:c0 io=0xc8204000 irq=16 f=h,sg
md: Autodetecting RAID arrays.
md: autorun ...
md: ... autorun DONE.
EXT3 FS on sda2, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
warning: process `kudzu' used the removed sysctl system call with 1.23.
eth0: link now down.
e1000: eth1: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex
SKB BUG: Invalid truesize (3952) len=16384, sizeof(sk_buff)=240

Call Trace:
 [<ffffffff80247e84>] sk_stream_rfree+0x34/0x70
 [<ffffffff8022aac0>] __kfree_skb+0xb0/0x110
 [<ffffffff8021e5eb>] tcp_recvmsg+0x98b/0xc00
 [<ffffffff80233cf0>] sock_common_recvmsg+0x30/0x50
 [<ffffffff802075b9>] find_get_page+0x29/0x60
 [<ffffffff804dd373>] sock_aio_read+0x103/0x130
 [<ffffffff8020cb1f>] do_sync_read+0xcf/0x120
 [<ffffffff802a3a10>] autoremove_wake_function+0x0/0x30
 [<ffffffff8020b420>] vfs_read+0xd0/0x180
 [<ffffffff8020b350>] vfs_read+0x0/0x180
 [<ffffffff80211db3>] sys_read+0x53/0x90
 [<ffffffff8026611e>] system_call+0x7e/0x83

SKB BUG: Invalid truesize (3952) len=16384, sizeof(sk_buff)=240

Call Trace:
 [<ffffffff80247e84>] sk_stream_rfree+0x34/0x70
 [<ffffffff8022aac0>] __kfree_skb+0xb0/0x110
 [<ffffffff8021e698>] tcp_recvmsg+0xa38/0xc00
 [<ffffffff80233cf0>] sock_common_recvmsg+0x30/0x50
 [<ffffffff802075b9>] find_get_page+0x29/0x60
 [<ffffffff804dd373>] sock_aio_read+0x103/0x130
 [<ffffffff8020cb1f>] do_sync_read+0xcf/0x120
 [<ffffffff802a3a10>] autoremove_wake_function+0x0/0x30
 [<ffffffff8020b420>] vfs_read+0xd0/0x180
 [<ffffffff8020b350>] vfs_read+0x0/0x180
 [<ffffffff80211db3>] sys_read+0x53/0x90
 [<ffffffff8026611e>] system_call+0x7e/0x83

SKB BUG: Invalid truesize (3952) len=16384, sizeof(sk_buff)=240

Call Trace:
 [<ffffffff80247e84>] sk_stream_rfree+0x34/0x70
 [<ffffffff8022aac0>] __kfree_skb+0xb0/0x110
 [<ffffffff8021e698>] tcp_recvmsg+0xa38/0xc00
 [<ffffffff80233cf0>] sock_common_recvmsg+0x30/0x50
 [<ffffffff802075b9>] find_get_page+0x29/0x60
 [<ffffffff804dd373>] sock_aio_read+0x103/0x130
 [<ffffffff8020cb1f>] do_sync_read+0xcf/0x120
 [<ffffffff802a3a10>] autoremove_wake_function+0x0/0x30
 [<ffffffff8020b420>] vfs_read+0xd0/0x180
 [<ffffffff8020b350>] vfs_read+0x0/0x180
 [<ffffffff80211db3>] sys_read+0x53/0x90
 [<ffffffff8026611e>] system_call+0x7e/0x83

SKB BUG: Invalid truesize (3952) len=16384, sizeof(sk_buff)=240

Call Trace:
 [<ffffffff80247e84>] sk_stream_rfree+0x34/0x70
 [<ffffffff8022aac0>] __kfree_skb+0xb0/0x110
 [<ffffffff8021e5eb>] tcp_recvmsg+0x98b/0xc00
 [<ffffffff80233cf0>] sock_common_recvmsg+0x30/0x50
 [<ffffffff802075b9>] find_get_page+0x29/0x60
 [<ffffffff804dd373>] sock_aio_read+0x103/0x130
 [<ffffffff8020cb1f>] do_sync_read+0xcf/0x120
 [<ffffffff802a3a10>] autoremove_wake_function+0x0/0x30
 [<ffffffff8020b420>] vfs_read+0xd0/0x180
 [<ffffffff8020b350>] vfs_read+0x0/0x180
 [<ffffffff80211db3>] sys_read+0x53/0x90
 [<ffffffff8026611e>] system_call+0x7e/0x83

SKB BUG: Invalid truesize (3952) len=16384, sizeof(sk_buff)=240

Call Trace:
 [<ffffffff80247e84>] sk_stream_rfree+0x34/0x70
 [<ffffffff8022aac0>] __kfree_skb+0xb0/0x110
 [<ffffffff8021e5eb>] tcp_recvmsg+0x98b/0xc00
 [<ffffffff80233cf0>] sock_common_recvmsg+0x30/0x50
 [<ffffffff802075b9>] find_get_page+0x29/0x60
 [<ffffffff804dd373>] sock_aio_read+0x103/0x130
 [<ffffffff8020cb1f>] do_sync_read+0xcf/0x120
 [<ffffffff802a3a10>] autoremove_wake_function+0x0/0x30
 [<ffffffff8026b483>] thread_return+0x0/0xfd
 [<ffffffff8026ab91>] __sched_text_start+0x161/0xa53
 [<ffffffff8020d6c5>] inotify_dentry_parent_queue_event+0x15/0xd0
 [<ffffffff8020b420>] vfs_read+0xd0/0x180
 [<ffffffff80211db3>] sys_read+0x53/0x90
 [<ffffffff8026611e>] system_call+0x7e/0x83

SKB BUG: Invalid truesize (3952) len=16384, sizeof(sk_buff)=240

Call Trace:
 [<ffffffff80247e84>] sk_stream_rfree+0x34/0x70
 [<ffffffff8022aac0>] __kfree_skb+0xb0/0x110
 [<ffffffff8021e698>] tcp_recvmsg+0xa38/0xc00
 [<ffffffff80233cf0>] sock_common_recvmsg+0x30/0x50
 [<ffffffff802075b9>] find_get_page+0x29/0x60
 [<ffffffff804dd373>] sock_aio_read+0x103/0x130
 [<ffffffff8020cb1f>] do_sync_read+0xcf/0x120
 [<ffffffff802a3a10>] autoremove_wake_function+0x0/0x30
 [<ffffffff8026b483>] thread_return+0x0/0xfd
 [<ffffffff8026ab91>] __sched_text_start+0x161/0xa53
 [<ffffffff8020d6c5>] inotify_dentry_parent_queue_event+0x15/0xd0
 [<ffffffff8020b420>] vfs_read+0xd0/0x180
 [<ffffffff80211db3>] sys_read+0x53/0x90
 [<ffffffff8026611e>] system_call+0x7e/0x83

SKB BUG: Invalid truesize (3952) len=16384, sizeof(sk_buff)=240

Call Trace:
 [<ffffffff80247e84>] sk_stream_rfree+0x34/0x70
 [<ffffffff8022aac0>] __kfree_skb+0xb0/0x110
 [<ffffffff8021e698>] tcp_recvmsg+0xa38/0xc00
 [<ffffffff80233cf0>] sock_common_recvmsg+0x30/0x50
 [<ffffffff802075b9>] find_get_page+0x29/0x60
 [<ffffffff804dd373>] sock_aio_read+0x103/0x130
 [<ffffffff8020cb1f>] do_sync_read+0xcf/0x120
 [<ffffffff802a3a10>] autoremove_wake_function+0x0/0x30
 [<ffffffff8026b483>] thread_return+0x0/0xfd
 [<ffffffff8026ab91>] __sched_text_start+0x161/0xa53
 [<ffffffff8020d6c5>] inotify_dentry_parent_queue_event+0x15/0xd0
 [<ffffffff8020b420>] vfs_read+0xd0/0x180
 [<ffffffff80211db3>] sys_read+0x53/0x90
 [<ffffffff8026611e>] system_call+0x7e/0x83

SKB BUG: Invalid truesize (3952) len=16384, sizeof(sk_buff)=240

Call Trace:
 [<ffffffff80247e84>] sk_stream_rfree+0x34/0x70
 [<ffffffff8022aac0>] __kfree_skb+0xb0/0x110
 [<ffffffff8021e5eb>] tcp_recvmsg+0x98b/0xc00
 [<ffffffff80233cf0>] sock_common_recvmsg+0x30/0x50
 [<ffffffff802075b9>] find_get_page+0x29/0x60
 [<ffffffff804dd373>] sock_aio_read+0x103/0x130
 [<ffffffff8020cb1f>] do_sync_read+0xcf/0x120
 [<ffffffff802a3a10>] autoremove_wake_function+0x0/0x30
 [<ffffffff8026b483>] thread_return+0x0/0xfd
 [<ffffffff8026ab91>] __sched_text_start+0x161/0xa53
 [<ffffffff8020d6c5>] inotify_dentry_parent_queue_event+0x15/0xd0
 [<ffffffff8020b420>] vfs_read+0xd0/0x180
 [<ffffffff80211db3>] sys_read+0x53/0x90
 [<ffffffff8026611e>] system_call+0x7e/0x83

