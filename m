From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Thu, 21 Aug 2008 09:53:40 -0700 (PDT)
Message-ID: <198958.27259.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Vivek Goyal <vgoyal@redhat.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82105.mail.mud.yahoo.com ([209.191.84.218]:45676 "HELO
	web82105.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752085AbYHUQxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 12:53:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > I will try to provide the entire output tonight or tomorrow.  It will be
> > difficult, though:  it looks like I have to try to fit the info from about
> > 60 of the printk's in your patch onto the 80x25 VGA screen, and still
> > make it understandable enough to be useful.
> >
> 
> with hpet=disable?

Oh, well that's easy.  (See below.)  I assumed you needed the data for a
hanging kernel, not one with the workaround enabled.

I can still try to provide the output of the printk's in your patch later,
in that would have any value.  Here is 'dmesg' for a recent kernel with
"hpet=disable":

==================================
$ git show |head
commit 30a2f3c60a84092c8084dfe788b710f8d0768cd4
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue Aug 12 18:55:39 2008 -0700

    Linux 2.6.27-rc3

diff --git a/Makefile b/Makefile
index fd3ca6e..53bf6ec 100644
--- a/Makefile
+++ b/Makefile

$ dmesg
Linux version 2.6.27-rc3.test (dawitbro@fileserver) (gcc version 4.3.1 (Debian 4.3.1-2) ) #1 SMP Thu Aug 21 09:11:13 EDT 2008
Command line: root=/dev/hda1 ro video=uvesafb:1280x1024-16@60,mtrr:3 fbcon=scrollback:256k,font:10x18 debug hpet=disable
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
 BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 0000000077fe0000 (usable)
 BIOS-e820: 0000000077fe0000 - 0000000077fe3000 (ACPI NVS)
 BIOS-e820: 0000000077fe3000 - 0000000077ff0000 (ACPI data)
 BIOS-e820: 0000000077ff0000 - 0000000078000000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (Kernel code) [200000, 56ce41]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (Kernel code) [200000, 56ce41]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (Kernel data) [56ce42, 6d5f3f]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (Kernel data) [56ce42, 6d5f3f]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (Kernel bss) [773000, 7b7647]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (Kernel bss) [773000, 7b7647]
last_pfn = 0x77fe0 max_arch_pfn = 0x3ffffffff
init_memory_mapping
 0000000000 - 0077e00000 page 2M
 0077e00000 - 0077fe0000 page 4k
kernel direct mapping tables up to 77fe0000 @ 8000-c000
last_map_addr: 77fe0000 end: 77fe0000
DMI 2.5 present.
ACPI: RSDP 000F7B80, 0024 (r2 RS690 )
ACPI: RSDT 77FE3040, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD        0)
ACPI: FACP 77FE30C0, 0074 (r1 RS690  AWRDACPI 42302E31 AWRD        0)
ACPI: DSDT 77FE3180, 4B0B (r1 RS690  AWRDACPI     1000 MSFT  3000000)
ACPI: FACS 77FE0000, 0040
ACPI: SSDT 77FE7DC0, 028A (r1 PTLTD  POWERNOW        1  LTP        1)
ACPI: HPET 77FE80C0, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD       98)
ACPI: MCFG 77FE8140, 003C (r1 RS690  AWRDACPI 42302E31 AWRD        0)
ACPI: APIC 77FE7D00, 0068 (r1 RS690  AWRDACPI 42302E31 AWRD        0)
No NUMA configuration found
Faking a node at 0000000000000000-0000000077fe0000
Bootmem setup node 0 0000000000000000-0000000077fe0000
  NODE_DATA [0000000000001000 - 0000000000004fff]
  bootmap [000000000000a000 -  0000000000018fff] pages f
(5 early reservations) ==> bootmem [0000000000 - 0077fe0000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
  #2 [0000200000 - 00007b7648]    TEXT DATA BSS ==> [0000200000 - 00007b7648]
  #3 [000009f000 - 0000100000]    BIOS reserved ==> [000009f000 - 0000100000]
  #4 [0000008000 - 000000a000]          PGTABLE ==> [0000008000 - 000000a000]
found SMP MP-table at [ffff8800000f3c80] 000f3c80
 [ffffe20000000000-ffffe20001bfffff] PMD -> [ffff880001200000-ffff880002dfffff] on node 0
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00100000
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x00077fe0
On node 0 totalpages: 491391
  DMA zone: 2376 pages, LIFO batch:0
  DMA32 zone: 480728 pages, LIFO batch:31
Detected use of extended apic ids on hypertransport bus
ACPI: PM-Timer IO Port: 0x4008
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Setting APIC routing to flat
ACPI: HPET id: 0x10b9a201 base: 0xfed00000
Using ACPI (MADT) for SMP configuration information
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (System RAM) [0, 9f3ff]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (System RAM) [0, 9f3ff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (reserved) [9f400, 9ffff]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (reserved) [9f400, 9ffff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (reserved) [f0000, fffff]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (reserved) [f0000, fffff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (System RAM) [100000, 77fdffff]
  insert_resource: first: (Kernel code) [200000, 56ce41], new: (System RAM) [100000, 77fdffff]
  insert_resource: direct parent: (PCI mem) [0, ffffffffffffffff], new: (System RAM) [100000, 77fdffff]
    insert_resource: child: (Kernel code) [200000, 56ce41], new: (System RAM) [100000, 77fdffff]
    insert_resource: child: (Kernel data) [56ce42, 6d5f3f], new: (System RAM) [100000, 77fdffff]
    insert_resource: child: (Kernel bss) [773000, 7b7647], new: (System RAM) [100000, 77fdffff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (ACPI Non-volatile Storage) [77fe0000, 77fe2fff]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (ACPI Non-volatile Storage) [77fe0000, 77fe2fff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (ACPI Tables) [77fe3000, 77feffff]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (ACPI Tables) [77fe3000, 77feffff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (reserved) [77ff0000, 77ffffff]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (reserved) [77ff0000, 77ffffff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (reserved) [e0000000, efffffff]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (reserved) [e0000000, efffffff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (reserved) [fec00000, ffffffff]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (reserved) [fec00000, ffffffff]
request_resource: root: (PCI IO) [0, ffff], new: (dma1) [0, 1f] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (pic1) [20, 21] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (timer0) [40, 43] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (timer1) [50, 53] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (keyboard) [60, 60] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (keyboard) [64, 64] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (dma page reg) [80, 8f] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (pic2) [a0, a1] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (dma2) [c0, df] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (fpu) [f0, ff] conflict 0
Allocating PCI resources starting at 80000000 (gap: 78000000:68000000)
PERCPU: Allocating 45224 bytes of per cpu data
NR_CPUS: 4, nr_cpu_ids: 4, nr_node_ids 1
Built 1 zonelists in Node order, mobility grouping on.  Total pages: 483104
Policy zone: DMA32
Kernel command line: root=/dev/hda1 ro video=uvesafb:1280x1024-16@60,mtrr:3 fbcon=scrollback:256k,font:10x18 debug hpet=disable
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
TSC calibrated against PM_TIMER
Detected 2499.716 MHz processor.
request_resource: root: (PCI IO) [0, ffff], new: (vga+) [3c0, 3df] conflict 0
Console: colour VGA+ 80x25
console [tty0] enabled
Checking aperture...
No AGP bridge found
Node 0: aperture @ 2ecc000000 size 32 MB
Aperture beyond 4GB. Ignoring.
Memory: 1930792k/1965952k available (3507k kernel code, 34772k reserved, 1444k data, 508k init)
CPA: page pool initialized 1 of 1 pages preallocated
SLUB: Genslabs=13, HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
Calibrating delay loop (skipped), value calculated using timer frequency.. 5001.74 BogoMIPS (lpj=8332386)
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Mount-cache hash table entries: 256
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 0/0 -> Node 0
tseg: 0000000000
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
using C1E aware idle routine
Freeing SMP alternatives: 28k freed
ACPI: Core revision 20080609
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: AMD Processor model unknown stepping 02
Using local APIC timer interrupts.
APIC timer calibration result 12498579
Detected 12.498 MHz APIC timer.
Booting processor 1/1 ip 6000
Initializing CPU#1
Calibrating delay using timer specific routine.. 5001.71 BogoMIPS (lpj=8332337)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 1/1 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU1: AMD Processor model unknown stepping 02
Brought up 2 CPUs
Total of 2 processors activated (10002.45 BogoMIPS).
CPU0 attaching sched-domain:
 domain 0: span 0-1 level CPU
  groups: 0 1
  domain 1: span 0-1 level NODE
   groups: 0-1
CPU1 attaching sched-domain:
 domain 0: span 0-1 level CPU
  groups: 1 0
  domain 1: span 0-1 level NODE
   groups: 0-1
net_namespace: 800 bytes
NET: Registered protocol family 16
No dock devices found.
node 0 link 0: io port [d000, ffff]
TOM: 0000000080000000 aka 2048M
node 0 link 0: mmio [a0000, bffff]
node 0 link 0: mmio [d8000000, dfffffff]
node 0 link 0: mmio [80000000, d7ffffff]
node 0 link 0: mmio [f0000000, fe02ffff]
node 0 link 0: mmio [e0000000, e02fffff]
bus: [00,02] on node 0 link 0
bus: 00 index 0 io port: [0, ffff]
bus: 00 index 1 mmio: [a0000, bffff]
bus: 00 index 2 mmio: [80000000, efffffff]
bus: 00 index 3 mmio: [f0000000, fcffffffff]
ACPI: bus type pci registered
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: MCFG area at e0000000 reserved in E820
PCI: Using MMCONFIG at e0000000 - efffffff
PCI: Using configuration type 1 for base access
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:13.5: supports D1
pci 0000:00:13.5: supports D2
pci 0000:00:13.5: PME# supported from D0 D1 D2 D3hot
pci 0000:00:13.5: PME# disabled
pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
pci 0000:00:14.2: PME# disabled
pci 0000:01:05.0: supports D1
pci 0000:01:05.0: supports D2
pci 0000:02:05.0: supports D1
pci 0000:02:05.0: supports D2
pci 0000:02:05.0: PME# supported from D1 D2 D3hot D3cold
pci 0000:02:05.0: PME# disabled
pci 0000:00:14.4: transparent bridge
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P2P_._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 6 7 10 11) *0, disabled.
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:0d: mem resource (0xfed00000-0xfed000ff) overlaps 0000:00:14.0 BAR 1 (0xfed00000-0xfed003ff), disabling
pnp: PnP ACPI: found 14 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
request_resource: root: (PCI IO) [0, ffff], new: (PCI Bus 0000:01) [e000, efff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (PCI Bus 0000:01) [fdd00000, fdefffff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (PCI Bus 0000:01) [d8000000, dfffffff] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (PCI Bus 0000:02) [d000, dfff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (PCI Bus 0000:02) [fdc00000, fdcfffff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (PCI Bus 0000:02) [fdf00000, fdffffff] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:12.0) [ff00, ff07] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:12.0) [fe00, fe03] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:12.0) [fd00, fd07] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:12.0) [fc00, fc03] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:12.0) [fb00, fb0f] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:12.0) [fe02f000, fe02f3ff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:13.0) [fe02e000, fe02efff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:13.1) [fe02d000, fe02dfff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:13.2) [fe02c000, fe02cfff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:13.3) [fe02b000, fe02bfff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:13.4) [fe02a000, fe02afff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:13.5) [fe029000, fe0290ff] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.0) [fa00, fa0f] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:14.0) [fed00000, fed003ff] conflict 1
pci 0000:00:14.0: BAR 1: can't allocate resource
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [1f0, 1f7] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [3f6, 3f6] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [170, 177] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [376, 376] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [f900, f90f] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:14.2) [fe020000, fe023fff] conflict 0
request_resource: root: (PCI Bus 0000:01) [d8000000, dfffffff], new: (0000:01:05.0) [d8000000, dfffffff] conflict 0
request_resource: root: (PCI Bus 0000:01) [fdd00000, fdefffff], new: (0000:01:05.0) [fdee0000, fdeeffff] conflict 0
request_resource: root: (PCI Bus 0000:01) [e000, efff], new: (0000:01:05.0) [ee00, eeff] conflict 0
request_resource: root: (PCI Bus 0000:01) [fdd00000, fdefffff], new: (0000:01:05.0) [fdd00000, fddfffff] conflict 0
request_resource: root: (PCI Bus 0000:01) [fdd00000, fdefffff], new: (0000:01:05.2) [fdefc000, fdefffff] conflict 0
request_resource: root: (PCI Bus 0000:02) [d000, dfff], new: (0000:02:05.0) [de00, deff] conflict 0
request_resource: root: (PCI Bus 0000:02) [fdc00000, fdcfffff], new: (0000:02:05.0) [fdcff000, fdcff0ff] conflict 0
system 00:01: ioport range 0x4100-0x411f has been reserved
system 00:01: ioport range 0x228-0x22f has been reserved
system 00:01: ioport range 0x40b-0x40b has been reserved
system 00:01: ioport range 0x4d6-0x4d6 has been reserved
system 00:01: ioport range 0xc00-0xc01 has been reserved
system 00:01: ioport range 0xc14-0xc14 has been reserved
system 00:01: ioport range 0xc50-0xc52 has been reserved
system 00:01: ioport range 0xc6c-0xc6d has been reserved
system 00:01: ioport range 0xc6f-0xc6f has been reserved
system 00:01: ioport range 0xcd0-0xcd1 has been reserved
system 00:01: ioport range 0xcd2-0xcd3 has been reserved
system 00:01: ioport range 0xcd4-0xcdf has been reserved
system 00:01: ioport range 0x4000-0x40fe has been reserved
system 00:01: ioport range 0x4210-0x4217 has been reserved
system 00:01: ioport range 0xb10-0xb1f has been reserved
system 00:07: ioport range 0x4d0-0x4d1 has been reserved
system 00:07: ioport range 0x220-0x225 has been reserved
system 00:07: ioport range 0xb00-0xb0f has been reserved
system 00:0c: iomem range 0xe0000000-0xefffffff could not be reserved
system 00:0d: iomem range 0xf0000-0xfffff could not be reserved
system 00:0d: iomem range 0x77fe0000-0x77ffffff could not be reserved
system 00:0d: iomem range 0xffff0000-0xffffffff could not be reserved
system 00:0d: iomem range 0x0-0x9ffff could not be reserved
system 00:0d: iomem range 0x100000-0x77fdffff could not be reserved
system 00:0d: iomem range 0x78000000-0x7fffffff has been reserved
system 00:0d: iomem range 0xfec00000-0xfec00fff could not be reserved
system 00:0d: iomem range 0xfee00000-0xfee00fff could not be reserved
system 00:0d: iomem range 0xfff80000-0xfffeffff could not be reserved
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: 0xe000-0xefff
pci 0000:00:01.0:   MEM window: 0xfdd00000-0xfdefffff
pci 0000:00:01.0:   PREFETCH window: 0x000000d8000000-0x000000dfffffff
pci 0000:00:14.4: PCI bridge, secondary bus 0000:02
pci 0000:00:14.4:   IO window: 0xd000-0xdfff
pci 0000:00:14.4:   MEM window: 0xfdc00000-0xfdcfffff
pci 0000:00:14.4:   PREFETCH window: 0x000000fdf00000-0x000000fdffffff
NET: Registered protocol family 2
Switched to high resolution mode on CPU 0
Switched to high resolution mode on CPU 1
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
NET: Registered protocol family 1
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
msgmni has been set to 3771
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci 0000:01:05.0: Boot video device
uvesafb: (C) 1988-2005, ATI Technologies Inc. RS69001.00, RS69001.00, 01.00, OEM: ATI ATOMBIOS(C) 1988-2005, ATI Technologies Inc. RS69001.00, VBE v3.0
uvesafb: VBIOS/hardware supports DDC2 transfers
uvesafb: no monitor limits have been set, default refresh rate will be used
uvesafb: scrolling: redraw
Console: switching to colour frame buffer device 128x56
uvesafb: framebuffer at 0xd8000000, mapped to 0xffffc20010980000, using 16384k, total 16384k
fb0: VESA VGA frame buffer device
input: Power Button (FF) as /class/input/input0
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input1
ACPI: Power Button (CM) [PWRB]
fan PNP0C0B:00: registered as cooling_device0
ACPI: Fan [FAN] (on)
processor ACPI0007:00: registered as cooling_device1
processor ACPI0007:01: registered as cooling_device2
thermal LNXTHERM:01: registered as thermal_zone0
ACPI: Thermal Zone [THRM] (18 C)
hpet_acpi_add: no address or irqs in _CRS
Linux agpgart interface v0.103
loop: module loaded
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:02:05.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
eth0: RTL8169sc/8110sc at 0xffffc20000330000, 00:1b:b9:f4:88:d0, XID 18000000 IRQ 22
Uniform Multi-Platform E-IDE driver
atiixp 0000:00:14.1: IDE controller (0x1002:0x438c rev 0x00)
ATIIXP_IDE 0000:00:14.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
atiixp 0000:00:14.1: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xf900-0xf907
Probing IDE interface ide0...
hda: Maxtor 6H500R0, ATA DISK drive
hdb: SAMSUNG DVD-ROM SD-616E, ATAPI CD/DVD-ROM drive
hda: host max PIO4 wanted PIO255(auto-tune) selected PIO4
hda: UDMA/100 mode selected
hdb: host max PIO4 wanted PIO255(auto-tune) selected PIO4
hdb: UDMA/33 mode selected
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
isa bounce pool size: 16 pages
ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
ide_generic: I/O resource 0x1F0-0x1F7 not free.
Probing IDE interface ide1...
ide1 at 0x170-0x177,0x376 on irq 15
hda: max request size: 512KiB
hda: 976773168 sectors (500107 MB) w/16384KiB Cache, CHS=60801/255/63
hda: cache flushes supported
 hda: hda1 hda2 hda3 < hda5 hda6 hda7 hda8 hda9 >
hdb: ATAPI 48X DVD-ROM drive, 512kB Cache
Uniform CD-ROM driver Revision: 3.20
Driver 'sd' needs updating - please use bus_type methods
ahci 0000:00:12.0: version 3.0
ahci 0000:00:12.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ahci 0000:00:12.0: controller can't do 64bit DMA, forcing 32bit
ahci 0000:00:12.0: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0xf impl SATA mode
ahci 0000:00:12.0: flags: ncq sntf ilck led clo pmp pio 
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
ata1: SATA max UDMA/133 abar m1024@0xfe02f000 port 0xfe02f100 irq 16
ata2: SATA max UDMA/133 abar m1024@0xfe02f000 port 0xfe02f180 irq 16
ata3: SATA max UDMA/133 abar m1024@0xfe02f000 port 0xfe02f200 irq 16
ata4: SATA max UDMA/133 abar m1024@0xfe02f000 port 0xfe02f280 irq 16
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-8: WDC WD5000AACS-00ZUB0, 01.01B01, max UDMA/133
ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: configured for UDMA/133
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: ATA-8: WDC WD5000AACS-00ZUB0, 01.01B01, max UDMA/133
ata2.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: configured for UDMA/133
ata3: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
scsi 0:0:0:0: Direct-Access     ATA      WDC WD5000AACS-0 01.0 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: unknown partition table
sd 0:0:0:0: [sda] Attached SCSI disk
scsi 1:0:0:0: Direct-Access     ATA      WDC WD5000AACS-0 01.0 PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdb: unknown partition table
sd 1:0:0:0: [sdb] Attached SCSI disk
ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level, low) -> IRQ 19
ehci_hcd 0000:00:13.5: EHCI Host Controller
ehci_hcd 0000:00:13.5: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:13.5: debug port 1
ehci_hcd 0000:00:13.5: irq 19, io mem 0xfe029000
ehci_hcd 0000:00:13.5: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 10 ports detected
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ohci_hcd 0000:00:13.0: OHCI Host Controller
ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 2
ohci_hcd 0000:00:13.0: irq 16, io mem 0xfe02e000
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
ohci_hcd 0000:00:13.1: OHCI Host Controller
ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus number 3
ohci_hcd 0000:00:13.1: irq 17, io mem 0xfe02d000
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:13.2: OHCI Host Controller
ohci_hcd 0000:00:13.2: new USB bus registered, assigned bus number 4
ohci_hcd 0000:00:13.2: irq 18, io mem 0xfe02c000
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level, low) -> IRQ 17
ohci_hcd 0000:00:13.3: OHCI Host Controller
ohci_hcd 0000:00:13.3: new USB bus registered, assigned bus number 5
ohci_hcd 0000:00:13.3: irq 17, io mem 0xfe02b000
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:13.4: OHCI Host Controller
ohci_hcd 0000:00:13.4: new USB bus registered, assigned bus number 6
ohci_hcd 0000:00:13.4: irq 18, io mem 0xfe02a000
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
i2c /dev entries driver
piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xfa00, revision 0
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
Advanced Linux Sound Architecture Driver Version 1.0.17.
HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level, low) -> IRQ 16
hda_codec: Unknown model for ALC883, trying auto-probe from BIOS...
HDA Intel 0000:01:05.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
ALSA device list:
  #0: HDA ATI SB at 0xfe020000 irq 16
  #1: HDA ATI HDMI at 0xfdefc000 irq 19
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 17
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
powernow-k8: Found 1 AMD Processor model unknown processors (2 cpu cores) (version 2.20.00)
powernow-k8:    0 : fid 0x11 (2500 MHz), vid 0xc
powernow-k8:    1 : fid 0x10 (2400 MHz), vid 0xd
powernow-k8:    2 : fid 0xe (2200 MHz), vid 0xf
powernow-k8:    3 : fid 0xc (2000 MHz), vid 0x11
powernow-k8:    4 : fid 0xa (1800 MHz), vid 0x13
powernow-k8:    5 : fid 0x2 (1000 MHz), vid 0x16
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (HPET 0) [fed00000, fed003ff]
  insert_resource: first: (reserved) [fec00000, ffffffff], new: (HPET 0) [fed00000, fed003ff]
    insert_resource: good with request direct parent: (reserved) [fec00000, ffffffff], new: (HPET 0) [fed00000, fed003ff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (Local APIC) [fee00000, fee00fff]
  insert_resource: first: (reserved) [fec00000, ffffffff], new: (Local APIC) [fee00000, fee00fff]
    insert_resource: good with request direct parent: (reserved) [fec00000, ffffffff], new: (Local APIC) [fee00000, fee00fff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (IOAPIC 0) [fec00000, fec00fff]
  insert_resource: first: (reserved) [fec00000, ffffffff], new: (IOAPIC 0) [fec00000, fec00fff]
    insert_resource: good with request direct parent: (reserved) [fec00000, ffffffff], new: (IOAPIC 0) [fec00000, fec00fff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (PCI MMCONFIG 0) [e0000000, efffffff]
  insert_resource: first: (reserved) [e0000000, efffffff], new: (PCI MMCONFIG 0) [e0000000, efffffff]
  insert_resource: direct parent: (PCI mem) [0, ffffffffffffffff], new: (PCI MMCONFIG 0) [e0000000, efffffff]
    insert_resource: child: (reserved) [e0000000, efffffff], new: (PCI MMCONFIG 0) [e0000000, efffffff]
input: ImExPS/2 Generic Explorer Mouse as /class/input/input2
input: AT Translated Set 2 keyboard as /class/input/input3
VFS: Mounted root (ext2 filesystem) readonly.
Freeing unused kernel memory: 508k freed
Write protecting the kernel read-only data: 4536k
input: PC Speaker as /class/input/input4
Adding 1951888k swap on /dev/hda2.  Priority:-1 extents:1 across:1951888k
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda9, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda8, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda6, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda7, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
r8169: eth0: link up
NET: Registered protocol family 10
Clocksource tsc unstable (delta = -63433933 ns)
warning: `ntpd' uses 32-bit capabilities (legacy support in use)
eth0: no IPv6 routers present
