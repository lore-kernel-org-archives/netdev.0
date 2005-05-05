From: Peter Buckingham <peter@pantasys.com>
Subject: Re: Mystery packet killing tg3
Date: Thu, 05 May 2005 10:09:55 -0700
Message-ID: <427A5363.2080703@pantasys.com>
References: <20050502162405.65dfb4a9@localhost.localdomain> <20050502200251.38271b61.davem@davemloft.net> <m14qdiyhcn.fsf@muc.de> <42791825.2080204@pantasys.com> <20050505114327.GA51761@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050505114327.GA51761@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> "32bit e1000"? How did you get such a beast? AFAIK all e1000s are 64bit
> address capable. Please supply a full boot log without iommu=force 
> and describe what happens exactly.

that was my initial impression too :-(

basically what happens is when there is more that 4GB of RAM in this 
system packets will start disappearing. ie ping will drop packets. 
Initially our bios was not configuring the IOMMU correctly, that has 
changed now.

I can make it work without the iommu=force by forcing the DMA to be 
32bit in the initialisation, but this seems to be a bit of a hack..

I've attached a dmesg output from a while ago (you may remember it from 
when i was tracking down a serial console problem ;-)

peter

---
Linux version 2.6.8-24.11-smp (geeko@buildhost) (gcc version 3.3.3 (SuSE 
Linux)) #2 SMP Wed Mar 16 09:22:34 PST 2005
BIOS-provided physical RAM map:
  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
  BIOS-e820: 00000000000e6000 - 0000000000100000 (reserved)
  BIOS-e820: 0000000000100000 - 00000000b6ff0000 (usable)
  BIOS-e820: 00000000b6ff0000 - 00000000b6ffe000 (ACPI data)
  BIOS-e820: 00000000b6ffe000 - 00000000b7000000 (ACPI NVS)
  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
  BIOS-e820: 00000000ff780000 - 0000000100000000 (reserved)
  BIOS-e820: 0000000100000000 - 0000000200000000 (usable)
Scanning NUMA topology in Northbridge 24
Number of nodes 4 (30030)
Node 0 MemBase 0000000000000000 Limit 000000007fffffff
Node 1 MemBase 0000000080000000 Limit 00000000ffffffff
Node 2 MemBase 0000000100000000 Limit 000000017fffffff
Node 3 MemBase 0000000180000000 Limit 00000001ffffffff
node 1 shift 24 addr ff000000 conflict 0
node 3 shift 25 addr 1fe000000 conflict 0
Using node hash shift of 26
Bootmem setup node 0 0000000000000000-000000007fffffff
Bootmem setup node 1 0000000080000000-00000000ffffffff
Bootmem setup node 2 0000000100000000-000000017fffffff
Bootmem setup node 3 0000000180000000-00000001ffffffff
No mptable found.
NVidia chipset found. Disabling timer override
ACPI: RSDP (v000 ACPIAM                                    ) @ 
0x00000000000f8510
ACPI: RSDT (v001 A M I  OEMRSDT  0x03000509 MSFT 0x00000097) @ 
0x00000000b6ff0000
ACPI: FADT (v002 A M I  OEMFACP  0x03000509 MSFT 0x00000097) @ 
0x00000000b6ff0200
ACPI: MADT (v001 A M I  OEMAPIC  0x03000509 MSFT 0x00000097) @ 
0x00000000b6ff0390
ACPI: OEMB (v001 A M I  AMI_OEM  0x03000509 MSFT 0x00000097) @ 
0x00000000b6ffe040
ACPI: MCFG (v001 A M I  OEMMCFG  0x03000509 MSFT 0x00000097) @ 
0x00000000b6ff65e0
ACPI: DSDT (v001  0ABGS 0ABGS020 0x00000020 INTL 0x02002026) @ 
0x0000000000000000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Processor #0 15:5 APIC version 16
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Processor #1 15:5 APIC version 16
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
Processor #2 15:5 APIC version 16
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
Processor #3 15:5 APIC version 16
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x84] disabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x85] disabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x86] disabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x87] disabled)
ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 4, version 17, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
Using ACPI (MADT) for SMP configuration information
Checking aperture...
CPU 0: aperture @ 16e0000000 size 64 MB
Aperture from northbridge cpu 0 beyond 4GB. Ignoring.
No AGP bridge found
Your BIOS doesn't leave a aperture memory hole
Please enable the IOMMU option in the BIOS setup
This costs you 64 MB of RAM
Mapping aperture over 65536 KB of RAM @ 4000000
Built 4 zonelists
Kernel command line: ip=dhcp nfsroot=10.2.128.1:/discovery iommu=force 
console=tty0 console=ttyS1,115200 BOOT_IMAGE=vmlinuz 
ip=10.2.135.253:10.2.128.1:0.0.0.0:255.255.128.0
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 131072 bytes)
time.c: Using 1.193182 MHz PIT timer.
time.c: Detected 2000.015 MHz processor.
Console: colour VGA+ 80x25
Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Memory: 6978140k/8388608k available (3860k kernel code, 0k reserved, 
2106k data, 240k init)
Mount-cache hash table entries: 256 (order: 0, 4096 bytes)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
Using local APIC NMI watchdog using perfctr0
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
CPU0: AMD Opteron(tm) Processor 846 HE stepping 0a
per-CPU timeslice cutoff: 1023.93 usecs.
task migration cache decay timeout: 2 msecs.
Booting processor 1/1 rip 6000 rsp 10101c3ff58
Initializing CPU#1
3940.35 BogoMIPS (lpj=1970176)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
AMD Opteron(tm) Processor 846 HE stepping 0a
Booting processor 2/2 rip 6000 rsp 1017ffa5f58
Initializing CPU#2
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
AMD Opteron(tm) Processor 846 HE stepping 0a
Booting processor 3/3 rip 6000 rsp 101fffb1f58
Initializing CPU#3
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
AMD Opteron(tm) Processor 846 HE stepping 0a
Total of 4 processors activated (15785.98 BogoMIPS).
Using local APIC timer interrupts.
Detected 12.500 MHz APIC timer.
checking TSC synchronization across 4 CPUs: passed.
time.c: Using PIT/TSC based timekeeping.
Brought up 4 CPUs
NET: Registered protocol family 16
PCI: Using configuration type 1
mtrr: v2.0 (20020519)
ACPI: Subsystem revision 20040715
ACPI: Interpreter enabled
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (00:00)
PCI: Probing PCI hardware (bus 00)
PCI: Transparent bridge - 0000:00:09.0
ACPI: PCI Interrupt Link [LNKA] (IRQs 16 17 18 19) *10
ACPI: PCI Interrupt Link [LNKB] (IRQs 16 17 18 19) *9
ACPI: PCI Interrupt Link [LNKC] (IRQs 16 17 18 19) *11
ACPI: PCI Interrupt Link [LNKD] (IRQs 16 17 18 19) *0, disabled.
ACPI: PCI Interrupt Link [LNKE] (IRQs 16 17 18 19) *0, disabled.
ACPI: PCI Interrupt Link [LUS0] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LUS1] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LUS2] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LKLN] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LAUI] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LKMO] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LKSM] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LTID] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LTIE] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LATA] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LN2A] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN2B] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN2C] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN2D] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LK2N] (IRQs 44 45 46 47) *0, disabled.
ACPI: PCI Interrupt Link [LT5D] (IRQs 44 45 46 47) *0, disabled.
ACPI: PCI Interrupt Link [LT2E] (IRQs 44 45 46 47) *0, disabled.
ACPI: PCI Interrupt Link [LN3A] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN3B] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN3C] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN3D] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN4A] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN4B] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN4C] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN4D] (IRQs 40 41 42 43) *0, disabled.
SCSI subsystem initialized
usbcore: registered new driver usbfs
usbcore: registered new driver hub
PCI: Using ACPI for IRQ routing
ACPI: PCI Interrupt Link [LKSM] enabled at IRQ 22
ACPI: PCI interrupt 0000:00:01.1[A] -> GSI 22 (level, low) -> IRQ 177
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 19
ACPI: PCI interrupt 0000:05:06.0[A] -> GSI 19 (level, low) -> IRQ 185
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 18
ACPI: PCI interrupt 0000:05:07.0[A] -> GSI 18 (level, low) -> IRQ 193
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 17
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 17 (level, low) -> IRQ 201
PCI-DMA: Disabling AGP.
PCI-DMA: aperture base @ 4000000 size 65536 KB

Kernel panic - not syncing: Cannot allocate iommu bitmap
