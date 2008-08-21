From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Wed, 20 Aug 2008 21:07:33 -0700 (PDT)
Message-ID: <271523.9227.qm@web82105.mail.mud.yahoo.com>
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
Received: from web82105.mail.mud.yahoo.com ([209.191.84.218]:43996 "HELO
	web82105.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751618AbYHUEHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 00:07:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> please apply attached patch to see if insert_resource/request resource
> works on your conf

Yinghai,

Please advise me on how you would like me to handle 2.6.27 kernels.
If I use your patch on 2.6.27-rc3, the message scroll off the 80x25 
screen before I can see them... and then the kernel hangs.  I can run 
the kernel with "hpet=disable", but I'm not sure you want that.  If
you _do_ want that, just let me know.

As an alternative, I can alter your patch to use a log level of
something lower, like KERN_WARNING.  Then I could see the messages
from your patch if I set a "loglevel=4" boot parameter, even on a
kernel that hangs.  The normal messages should disappear, only
leaving the messages from your patch.


In the meantime, here is what I _did_ do to test your patch:

==================================
$ git checkout -f v2.6.27-rc3
HEAD is now at 30a2f3c... Linux 2.6.27-rc3

$ git apply --verbose --check ../yh_insert_resource_debug.patch 
Checking patch kernel/resource.c...

$ git apply --verbose ../yh_insert_resource_debug.patch 
Checking patch kernel/resource.c...
Applied patch kernel/resource.c cleanly.

$ git status
# Not currently on any branch.
# Changed but not updated:
#   (use "git add <file>..." to update what will be committed)
#
#    modified:   kernel/resource.c
#
no changes added to commit (use "git add" and/or "git commit -a")
==================================

This kernel boots and hangs, and I cannot see your patch messages.  But
I am sure they are there.  (See below.)


To see your patch messages without altering the patch, I checked out
an older revision that will boot.  Also, I just realized why I never get
the earliest boot log messages from 'dmesg':  the standard value of 
CONFIG_LOG_BUF_SHIFT is 15 (32 KB), which is too small to capture all
of my early boot messages.

In view of these things, I checked out the last kernel that will run for
me without hanging,

$ git checkout -f 700efc1b

and set CONFIG_LOG_BUF_SHIFT=18.  Your patch messages show up nicely this
way:
==================================
$ uname -r
2.6.25.test

$ dmesg
Linux version 2.6.25.test (dawitbro@fileserver) (gcc version 4.3.1 (Debian 4.3.1-2) ) #1 SMP Wed Aug 20 23:31:39 EDT 2008
Command line: root=/dev/hda1 ro video=uvesafb:1280x1024-16@60,mtrr:3 fbcon=scrollback:256k,font:10x18 debug
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
Entering add_active_range(0, 0, 159) 0 entries of 3200 used
Entering add_active_range(0, 256, 491488) 1 entries of 3200 used
end_pfn_map = 1048576
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
Entering add_active_range(0, 0, 159) 0 entries of 3200 used
Entering add_active_range(0, 256, 491488) 1 entries of 3200 used
Bootmem setup node 0 0000000000000000-0000000077fe0000
  NODE_DATA [000000000000c000 - 0000000000012fff]
  bootmap [0000000000013000 -  0000000000021fff] pages f
early res: 0 [0-fff] BIOS data page
early res: 1 [6000-7fff] SMP_TRAMPOLINE
early res: 2 [200000-7b5387] TEXT DATA BSS
early res: 3 [9f000-aefff] EBDA
early res: 4 [8000-bfff] PGTABLE
 [ffffe20000000000-ffffe200001fffff] PMD ->ffff810001200000 on node 0
 [ffffe20000200000-ffffe200003fffff] PMD ->ffff810001600000 on node 0
 [ffffe20000400000-ffffe200005fffff] PMD ->ffff810001a00000 on node 0
 [ffffe20000600000-ffffe200007fffff] PMD ->ffff810001e00000 on node 0
 [ffffe20000800000-ffffe200009fffff] PMD ->ffff810002200000 on node 0
 [ffffe20000a00000-ffffe20000bfffff] PMD ->ffff810002600000 on node 0
 [ffffe20000c00000-ffffe20000dfffff] PMD ->ffff810002a00000 on node 0
 [ffffe20000e00000-ffffe20000ffffff] PMD ->ffff810002e00000 on node 0
 [ffffe20001000000-ffffe200011fffff] PMD ->ffff810003200000 on node 0
 [ffffe20001200000-ffffe200013fffff] PMD ->ffff810003600000 on node 0
 [ffffe20001400000-ffffe200015fffff] PMD ->ffff810003a00000 on node 0
 [ffffe20001600000-ffffe200017fffff] PMD ->ffff810003e00000 on node 0
 [ffffe20001800000-ffffe200019fffff] PMD ->ffff810004200000 on node 0
 [ffffe20001a00000-ffffe20001bfffff] PMD ->ffff810004600000 on node 0
Zone PFN ranges:
  DMA             0 ->     4096
  DMA32        4096 ->  1048576
  Normal    1048576 ->  1048576
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0:        0 ->      159
    0:      256 ->   491488
On node 0 totalpages: 491391
  DMA zone: 56 pages used for memmap
  DMA zone: 1486 pages reserved
  DMA zone: 2457 pages, LIFO batch:0
  DMA32 zone: 6663 pages used for memmap
  DMA32 zone: 480729 pages, LIFO batch:31
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
ATI board detected. Disabling timer routing over 8254.
Detected use of extended apic ids on hypertransport bus
ACPI: PM-Timer IO Port: 0x4008
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
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Setting APIC routing to flat
ACPI: HPET id: 0x10b9a201 base: 0xfed00000
Using ACPI (MADT) for SMP configuration information
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (Local APIC) [fee00000, fee00fff]
    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (Local APIC) [fee00000, fee00fff]
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (System RAM) [0, 9f3ff] conflict 0
request_resource: root: (System RAM) [0, 9f3ff], new: (Kernel code) [200000, 557241] conflict 1
request_resource: root: (System RAM) [0, 9f3ff], new: (Kernel data) [557242, 6b4397] conflict 1
request_resource: root: (System RAM) [0, 9f3ff], new: (Kernel bss) [736000, 7b5387] conflict 1
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (reserved) [9f400, 9ffff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (reserved) [f0000, fffff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (System RAM) [100000, 77fdffff] conflict 0
request_resource: root: (System RAM) [100000, 77fdffff], new: (Kernel code) [200000, 557241] conflict 0
request_resource: root: (System RAM) [100000, 77fdffff], new: (Kernel data) [557242, 6b4397] conflict 0
request_resource: root: (System RAM) [100000, 77fdffff], new: (Kernel bss) [736000, 7b5387] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (ACPI Non-volatile Storage) [77fe0000, 77fe2fff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (ACPI Tables) [77fe3000, 77feffff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (reserved) [77ff0000, 77ffffff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (reserved) [e0000000, efffffff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (reserved) [fec00000, ffffffff] conflict 1
request_resource: root: (PCI IO) [0, ffff], new: (dma1) [0, 1f] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (pic1) [20, 21] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (timer0) [40, 43] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (timer1) [50, 53] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (keyboard) [60, 6f] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (dma page reg) [80, 8f] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (pic2) [a0, a1] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (dma2) [c0, df] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (fpu) [f0, ff] conflict 0
Allocating PCI resources starting at 80000000 (gap: 78000000:68000000)
PERCPU: Allocating 33672 bytes of per cpu data
Built 1 zonelists in Node order, mobility grouping on.  Total pages: 483186
Policy zone: DMA32
Kernel command line: root=/dev/hda1 ro video=uvesafb:1280x1024-16@60,mtrr:3 fbcon=scrollback:256k,font:10x18 debug
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
TSC calibrated against PM_TIMER
Marking TSC unstable due to TSCs unsynchronized
time.c: Detected 2499.726 MHz processor.
request_resource: root: (PCI IO) [0, ffff], new: (vga+) [3c0, 3df] conflict 0
Console: colour VGA+ 80x25
console [tty0] enabled
Checking aperture...
Node 0: aperture @ 2ecc000000 size 32 MB
Aperture beyond 4GB. Ignoring.
No AGP bridge found
Memory: 1930748k/1965952k available (3420k kernel code, 34816k reserved, 1396k data, 388k init)
CPA: page pool initialized 1 of 1 pages preallocated
SLUB: Genslabs=13, HWalign=64, Order=0-1, MinObjects=4, CPUs=2, Nodes=1
hpet clockevent registered
Calibrating delay using timer specific routine.. 5121.43 BogoMIPS (lpj=8531901)
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Mount-cache hash table entries: 256
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 0/0 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
Freeing SMP alternatives: 30k freed
ACPI: Core revision 20070126
Using local APIC timer interrupts.
APIC timer calibration result 12498622
Detected 12.498 MHz APIC timer.
Booting processor 1/2 APIC 0x1
Initializing CPU#1
Calibrating delay using timer specific routine.. 5001.83 BogoMIPS (lpj=8332542)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 1/1 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
AMD Processor model unknown stepping 02
Brought up 2 CPUs
net_namespace: 408 bytes
NET: Registered protocol family 16
No dock devices found.
ACPI: bus type pci registered
PCI: Using MMCONFIG at e0000000 - efffffff
PCI: Using configuration type 1
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Transparent bridge - 0000:00:14.4
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
 00:0d: mem resource (0xfed00000-0xfed000ff) overlaps 0000:00:14.0 BAR 1 (0xfed00000-0xfed003ff), disabling
pnp: PnP ACPI: found 14 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
request_resource: root: (PCI IO) [0, ffff], new: (PCI Bus #01) [e000, efff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (PCI Bus #01) [fdd00000, fdefffff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (PCI Bus #01) [d8000000, dfffffff] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (PCI Bus #02) [d000, dfff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (PCI Bus #02) [fdc00000, fdcfffff] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (PCI Bus #02) [fdf00000, fdffffff] conflict 0
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
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:14.0) [fed00000, fed003ff] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [1f0, 1f7] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [3f6, 3f6] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [170, 177] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [376, 376] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [f900, f90f] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:14.2) [fe020000, fe023fff] conflict 0
request_resource: root: (PCI Bus #01) [d8000000, dfffffff], new: (0000:01:05.0) [d8000000, dfffffff] conflict 0
request_resource: root: (PCI Bus #01) [fdd00000, fdefffff], new: (0000:01:05.0) [fdee0000, fdeeffff] conflict 0
request_resource: root: (PCI Bus #01) [e000, efff], new: (0000:01:05.0) [ee00, eeff] conflict 0
request_resource: root: (PCI Bus #01) [fdd00000, fdefffff], new: (0000:01:05.0) [fdd00000, fddfffff] conflict 0
request_resource: root: (PCI Bus #01) [fdd00000, fdefffff], new: (0000:01:05.2) [fdefc000, fdefffff] conflict 0
request_resource: root: (PCI Bus #02) [d000, dfff], new: (0000:02:05.0) [de00, deff] conflict 0
request_resource: root: (PCI Bus #02) [fdc00000, fdcfffff], new: (0000:02:05.0) [fdcff000, fdcff0ff] conflict 0
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 32-bit timers, 14318180 Hz
Switched to high resolution mode on CPU 0
Switched to high resolution mode on CPU 1
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
system 00:0d: iomem range 0xffff0000-0xffffffff has been reserved
system 00:0d: iomem range 0x0-0x9ffff could not be reserved
system 00:0d: iomem range 0x100000-0x77fdffff could not be reserved
system 00:0d: iomem range 0x78000000-0x7fffffff has been reserved
system 00:0d: iomem range 0xfec00000-0xfec00fff has been reserved
system 00:0d: iomem range 0xfee00000-0xfee00fff could not be reserved
system 00:0d: iomem range 0xfff80000-0xfffeffff has been reserved
PCI: Bridge: 0000:00:01.0
  IO window: e000-efff
  MEM window: 0xfdd00000-0xfdefffff
  PREFETCH window: 0x00000000d8000000-0x00000000dfffffff
PCI: Bridge: 0000:00:14.4
  IO window: d000-dfff
  MEM window: 0xfdc00000-0xfdcfffff
  PREFETCH window: 0x00000000fdf00000-0x00000000fdffffff
NET: Registered protocol family 2
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
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
ACPI: PNP0C0B:00 is registered as cooling_device0
ACPI: Fan [FAN] (on)
ACPI: ACPI0007:00 is registered as cooling_device1
ACPI: ACPI0007:01 is registered as cooling_device2
ACPI: LNXTHERM:01 is registered as thermal_zone0
ACPI: Thermal Zone [THRM] (24 C)
hpet_resources: 0xfed00000 is busy
Linux agpgart interface v0.103
loop: module loaded
r8169 Gigabit Ethernet driver 2.2LK loaded
ACPI: PCI Interrupt 0000:02:05.0[A] -> GSI 22 (level, low) -> IRQ 22
eth0: RTL8169sc/8110sc at 0xffffc2000032e000, 00:1b:b9:f4:88:d0, XID 18000000 IRQ 22
Uniform Multi-Platform E-IDE driver
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
SB600_PATA: IDE controller (0x1002:0x438c rev 0x00) at  PCI slot 0000:00:14.1
ACPI: PCI Interrupt 0000:00:14.1[A] -> GSI 16 (level, low) -> IRQ 16
SB600_PATA: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xf900-0xf907, BIOS settings: hda:DMA, hdb:DMA
Probing IDE interface ide0...
hda: Maxtor 6H500R0, ATA DISK drive
hdb: SAMSUNG DVD-ROM SD-616E, ATAPI CD/DVD-ROM drive
hda: host max PIO4 wanted PIO255(auto-tune) selected PIO4
hda: UDMA/100 mode selected
hdb: host max PIO4 wanted PIO255(auto-tune) selected PIO4
hdb: UDMA/33 mode selected
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
hda: max request size: 512KiB
hda: 976773168 sectors (500107 MB) w/16384KiB Cache, CHS=60801/255/63
hda: cache flushes supported
 hda: hda1 hda2 hda3 < hda5 hda6 hda7 hda8 hda9 >
hdb: ATAPI 48X DVD-ROM drive, 512kB Cache
Uniform CD-ROM driver Revision: 3.20
Driver 'sd' needs updating - please use bus_type methods
ahci 0000:00:12.0: version 3.0
ACPI: PCI Interrupt 0000:00:12.0[A] -> GSI 16 (level, low) -> IRQ 16
ahci 0000:00:12.0: controller can't do 64bit DMA, forcing 32bit
ahci 0000:00:12.0: controller can't do PMP, turning off CAP_PMP
ahci 0000:00:12.0: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0xf impl SATA mode
ahci 0000:00:12.0: flags: ncq sntf ilck led clo pio 
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
ACPI: PCI Interrupt 0000:00:13.5[D] -> GSI 19 (level, low) -> IRQ 19
ehci_hcd 0000:00:13.5: EHCI Host Controller
ehci_hcd 0000:00:13.5: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:13.5: debug port 1
ehci_hcd 0000:00:13.5: irq 19, io mem 0xfe029000
ehci_hcd 0000:00:13.5: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 10 ports detected
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ACPI: PCI Interrupt 0000:00:13.0[A] -> GSI 16 (level, low) -> IRQ 16
ohci_hcd 0000:00:13.0: OHCI Host Controller
ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 2
ohci_hcd 0000:00:13.0: irq 16, io mem 0xfe02e000
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:13.1[B] -> GSI 17 (level, low) -> IRQ 17
ohci_hcd 0000:00:13.1: OHCI Host Controller
ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus number 3
ohci_hcd 0000:00:13.1: irq 17, io mem 0xfe02d000
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:13.2[C] -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:13.2: OHCI Host Controller
ohci_hcd 0000:00:13.2: new USB bus registered, assigned bus number 4
ohci_hcd 0000:00:13.2: irq 18, io mem 0xfe02c000
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:13.3[B] -> GSI 17 (level, low) -> IRQ 17
ohci_hcd 0000:00:13.3: OHCI Host Controller
ohci_hcd 0000:00:13.3: new USB bus registered, assigned bus number 5
ohci_hcd 0000:00:13.3: irq 17, io mem 0xfe02b000
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:13.4[C] -> GSI 18 (level, low) -> IRQ 18
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
piix4_smbus 0000:00:14.0: Found 0000:00:14.0 device
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
Advanced Linux Sound Architecture Driver Version 1.0.16rc2 (Thu Jan 31 16:40:16 2008 UTC).
ACPI: PCI Interrupt 0000:00:14.2[A] -> GSI 16 (level, low) -> IRQ 16
hda_codec: Unknown model for ALC883, trying auto-probe from BIOS...
ACPI: PCI Interrupt 0000:01:05.2[B] -> GSI 19 (level, low) -> IRQ 19
ALSA device list:
  #0: HDA ATI SB at 0xfe020000 irq 16
  #1: HDA ATI HDMI at 0xfdefc000 irq 19
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
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
  insert_resource: first: (0000:00:14.0) [fed00000, fed003ff], new: (HPET 0) [fed00000, fed003ff]
  insert_resource: direct parent: (PCI mem) [0, ffffffffffffffff], new: (HPET 0) [fed00000, fed003ff]
    insert_resource: child: (0000:00:14.0) [fed00000, fed003ff], new: (HPET 0) [fed00000, fed003ff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (IOAPIC 0) [fec00000, fec00fff]
  insert_resource: first: (pnp 00:0d) [fec00000, fec00fff], new: (IOAPIC 0) [fec00000, fec00fff]
  insert_resource: direct parent: (PCI mem) [0, ffffffffffffffff], new: (IOAPIC 0) [fec00000, fec00fff]
    insert_resource: child: (pnp 00:0d) [fec00000, fec00fff], new: (IOAPIC 0) [fec00000, fec00fff]
insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (PCI MMCONFIG 0) [e0000000, efffffff]
  insert_resource: first: (reserved) [e0000000, efffffff], new: (PCI MMCONFIG 0) [e0000000, efffffff]
  insert_resource: direct parent: (PCI mem) [0, ffffffffffffffff], new: (PCI MMCONFIG 0) [e0000000, efffffff]
    insert_resource: child: (reserved) [e0000000, efffffff], new: (PCI MMCONFIG 0) [e0000000, efffffff]
input: ImExPS/2 Generic Explorer Mouse as /class/input/input2
input: AT Translated Set 2 keyboard as /class/input/input3
VFS: Mounted root (ext2 filesystem) readonly.
Freeing unused kernel memory: 388k freed
input: PC Speaker as /class/input/input4
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
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
Clocksource tsc unstable (delta = -87569023 ns)
warning: `ntpd' uses 32-bit capabilities (legacy support in use)
eth0: no IPv6 routers present
==================================

Just let me know how you would like me to handle a crashing kernel, if
this output is not sufficient.  I don't think all of your patch
messages would fit on one screen, though, even if I made the 
KERN_WARNING change that would allow me to see them.


Thanks,
Dave W.
