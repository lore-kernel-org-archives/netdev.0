From: "Denys" <denys@visp.net.lb>
Subject: Re: Possible 2.6.22 -> 2.6.23 HTB regression?
Date: Wed, 10 Oct 2007 16:06:53 +0300
Message-ID: <20071010130653.M55961@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:35123 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbXJJNHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 09:07:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Seems i am lost a bit. Now 2.6.22, i am not sure that working well. Possible 
it is related, that i booted kernel over kexec.

I will try to do full power cycle reboot if required, but it will cause for 
me serious downtime. Please tell me, which kernel prefferable to boot?

If it is interesting 
2.6.22 (but also non-functional now).

visp-1 ~ # cat /proc/net/psched
000003e8 00000400 000f4240 3b9aca00

maybe it is related to 
visp-1 ~ # dmesg|grep hpet
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
hpet0: 3 64-bit timers, 14318180 Hz
Time: hpet clocksource has been installed.
hpet_resources: 0xfed00000 is busy <<< - this?



Diff 2.6.22 -> 2.6.23 dmesg

--- log.2.6.22  2007-10-10 16:08:04.000000000 +0300
+++ log.2.6.23  2007-10-10 16:06:19.000000000 +0300
@@ -1,4 +1,4 @@
-Linux version 2.6.22-gentoo-r5-insat1 (root@livecd) (gcc version 4.1.1 
(Gentoo 4.1.1-r3)) #4 SMP Tue Sep 4 14:32:32 EEST 2007
+Linux version 2.6.23-insat1 (root@visp-1) (gcc version 4.1.1 (Gentoo 4.1.1-
r3)) #1 SMP Wed Oct 10 01:41:17 EEST 2007
 BIOS-provided physical RAM map:
  BIOS-e820: 0000000000000100 - 00000000000a0000 (usable)
  BIOS-e820: 0000000000100000 - 000000003ffa8000 (usable)
@@ -14,6 +14,7 @@
   DMA             0 ->     4096
   Normal       4096 ->   229376
   HighMem    229376 ->   262056
+Movable zone start PFN for each node
 early_node_map[1] active PFN ranges
     0:        0 ->   262056
 On node 0 totalpages: 262056
@@ -24,6 +25,7 @@
   Normal zone: 223520 pages, LIFO batch:31
   HighMem zone: 255 pages used for memmap
   HighMem zone: 32425 pages, LIFO batch:7
+  Movable zone: 0 pages used for memmap
 DMI 2.4 present.
 Using APIC driver default
 ACPI: RSDP 000F2620, 0024 (r2 DELL  )
@@ -74,45 +76,46 @@
 ACPI: HPET id: 0x8086a201 base: 0xfed00000
 Using ACPI (MADT) for SMP configuration information
 Allocating PCI resources starting at 50000000 (gap: 40000000:a0000000)
-Built 1 zonelists.  Total pages: 260009
+Built 1 zonelists in Zone order.  Total pages: 260009
 Kernel command line: root=/dev/sda3 panic=10 nmi_watchdog=1
-mapped APIC to ffffd000 (fee00000)
-mapped IOAPIC to ffffc000 (fec00000)
-mapped IOAPIC to ffffb000 (fec80000)
-mapped IOAPIC to ffffa000 (fec81000)
-mapped IOAPIC to ffff9000 (fec82000)
+mapped APIC to ffffb000 (fee00000)
+mapped IOAPIC to ffffa000 (fec00000)
+mapped IOAPIC to ffff9000 (fec80000)
+mapped IOAPIC to ffff8000 (fec81000)
+mapped IOAPIC to ffff7000 (fec82000)
 Enabling fast FPU save and restore... done.
 Enabling unmasked SIMD FPU exception support... done.
 Initializing CPU#0
-CPU 0 irqstacks, hard=c0508000 soft=c04e8000
+CPU 0 irqstacks, hard=c050e000 soft=c04ee000
 PID hash table entries: 4096 (order: 12, 16384 bytes)
-Detected 3192.172 MHz processor.
+Detected 3192.148 MHz processor.
 Console: colour VGA+ 80x25
+console [tty0] enabled
 Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
 Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
-Memory: 1033592k/1048224k available (2456k kernel code, 14036k reserved, 
1265k data, 236k init, 130720k highmem)
+Memory: 1033564k/1048224k available (2453k kernel code, 14048k reserved, 
1305k data, 232k init, 130720k highmem)
 virtual kernel memory layout:
-    fixmap  : 0xffe16000 - 0xfffff000   (1956 kB)
+    fixmap  : 0xffe14000 - 0xfffff000   (1964 kB)
     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
     vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
     lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
-      .init : 0xc04a8000 - 0xc04e3000   ( 236 kB)
-      .data : 0xc03660d1 - 0xc04a289c   (1265 kB)
-      .text : 0xc0100000 - 0xc03660d1   (2456 kB)
+      .init : 0xc04b1000 - 0xc04eb000   ( 232 kB)
+      .data : 0xc036544c - 0xc04ab97c   (1305 kB)
+      .text : 0xc0100000 - 0xc036544c   (2453 kB)
 Checking if this processor honours the WP bit even in supervisor mode... Ok.
 SLUB: Genslabs=22, HWalign=64, Order=0-1, MinObjects=4, CPUs=4, Nodes=1
 hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
 hpet0: 3 64-bit timers, 14318180 Hz
-Calibrating delay using timer specific routine.. 6388.07 BogoMIPS 
(lpj=3194038)
+Calibrating delay using timer specific routine.. 6388.11 BogoMIPS 
(lpj=3194056)
 Mount-cache hash table entries: 512
-CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001
+CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001 00000000
 monitor/mwait feature present.
 using mwait in idle threads.
 CPU: Trace cache: 12K uops, L1 D cache: 16K
 CPU: L2 cache: 2048K
 CPU: Physical Processor ID: 0
 CPU: Processor Core ID: 0
-CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001
+CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001 00000000
 Intel machine check architecture supported.
 Intel machine check reporting enabled on CPU#0.
 CPU0: Intel P4/Xeon Extended MCE MSRs (24) available
@@ -123,114 +126,81 @@
 ACPI: Core revision 20070126
 Parsing all Control Methods:
 Table [DSDT](id 0001) - 295 Objects with 44 Devices 111 Methods 8 Regions
- tbxface-0587 [02] tb_load_namespace     : ACPI Tables successfully acquired
-evxfevnt-0079 [02] enable                : System is already in ACPI mode
+ tbxface-0598 [00] tb_load_namespace     : ACPI Tables successfully acquired
+evxfevnt-0079 [00] enable                : System is already in ACPI mode
 CPU0: Intel(R) Xeon(TM) CPU 3.20GHz stepping 04
 Booting processor 1/1 eip 2000
-CPU 1 irqstacks, hard=c0509000 soft=c04e9000
+CPU 1 irqstacks, hard=c050f000 soft=c04ef000
 Initializing CPU#1
-Calibrating delay using timer specific routine.. 6383.70 BogoMIPS 
(lpj=3191853)
-CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001
+Calibrating delay using timer specific routine.. 6383.75 BogoMIPS 
(lpj=3191875)
+CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001 00000000
 monitor/mwait feature present.
 CPU: Trace cache: 12K uops, L1 D cache: 16K
 CPU: L2 cache: 2048K
 CPU: Physical Processor ID: 0
 CPU: Processor Core ID: 0
-CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001
+CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001 00000000
 Intel machine check architecture supported.
 Intel machine check reporting enabled on CPU#1.
 CPU1: Intel P4/Xeon Extended MCE MSRs (24) available
 CPU1: Thermal monitoring enabled
 CPU1: Intel(R) Xeon(TM) CPU 3.20GHz stepping 04
 Booting processor 2/2 eip 2000
-CPU 2 irqstacks, hard=c050a000 soft=c04ea000
+CPU 2 irqstacks, hard=c0510000 soft=c04f0000
 Initializing CPU#2
-Calibrating delay using timer specific routine.. 6383.76 BogoMIPS 
(lpj=3191884)
-CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001
+Calibrating delay using timer specific routine.. 6383.77 BogoMIPS 
(lpj=3191888)
+CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001 00000000
 monitor/mwait feature present.
 CPU: Trace cache: 12K uops, L1 D cache: 16K
 CPU: L2 cache: 2048K
 CPU: Physical Processor ID: 0
 CPU: Processor Core ID: 1
-CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001
+CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001 00000000
 Intel machine check architecture supported.
 Intel machine check reporting enabled on CPU#2.
 CPU2: Intel P4/Xeon Extended MCE MSRs (24) available
 CPU2: Thermal monitoring enabled
 CPU2: Intel(R) Xeon(TM) CPU 3.20GHz stepping 04
 Booting processor 3/3 eip 2000
-CPU 3 irqstacks, hard=c050b000 soft=c04eb000
+CPU 3 irqstacks, hard=c0511000 soft=c04f1000
 Initializing CPU#3
-Calibrating delay using timer specific routine.. 6383.78 BogoMIPS 
(lpj=3191894)
-CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001
+Calibrating delay using timer specific routine.. 6383.75 BogoMIPS 
(lpj=3191876)
+CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001 00000000
 monitor/mwait feature present.
 CPU: Trace cache: 12K uops, L1 D cache: 16K
 CPU: L2 cache: 2048K
 CPU: Physical Processor ID: 0
 CPU: Processor Core ID: 1
-CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001
+CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001 00000000
 Intel machine check architecture supported.
 Intel machine check reporting enabled on CPU#3.
 CPU3: Intel P4/Xeon Extended MCE MSRs (24) available
 CPU3: Thermal monitoring enabled
 CPU3: Intel(R) Xeon(TM) CPU 3.20GHz stepping 04
-Total of 4 processors activated (25539.33 BogoMIPS).
+Total of 4 processors activated (25539.39 BogoMIPS).
 ENABLING IO-APIC IRQs
 ..TIMER: vector=0x31 apic1=0 pin1=2 apic2=-1 pin2=-1
+APIC timer registered as dummy, due to nmi_watchdog=1!
 checking TSC synchronization [CPU#0 -> CPU#1]: passed.
 checking TSC synchronization [CPU#0 -> CPU#2]:
-Measured 972 cycles TSC warp between CPUs, turning off TSC clock.
+Measured 1056 cycles TSC warp between CPUs, turning off TSC clock.
 Marking TSC unstable due to: check_tsc_sync_source failed.
 Brought up 4 CPUs
-migration_cost=1000,2000
 NET: Registered protocol family 16
 ACPI: bus type pci registered
 PCI: Using MMCONFIG
 Setting up standard PCI resources
-evgpeblk-0952 [04] ev_create_gpe_block   : GPE 00 to 1F [_GPE] 4 regs on int 
0x9
-evgpeblk-1048 [03] ev_initialize_gpe_bloc: Found 1 Wake, Enabled 0 Runtime 
GPEs in this block
-Completing Region/Field/Buffer/Package initialization:....................
-Initialized 8/8 Regions 0/0 Fields 9/9 Buffers 3/4 Packages (304 nodes)
-Initializing Device/Processor/Thermal objects by executing _INI 
methods:[ACPI Debug]  String: [0x0B] "Method _INI"
-.
+evgpeblk-0956 [00] ev_create_gpe_block   : GPE 00 to 1F [_GPE] 4 regs on int 
0x9
+evgpeblk-1052 [00] ev_initialize_gpe_bloc: Found 1 Wake, Enabled 0 Runtime 
GPEs in this block
+ACPI: EC: Look up EC in DSDT
+Completing Region/Field/Buffer/Package initialization:.................
+Initialized 5/8 Regions 0/0 Fields 9/9 Buffers 3/4 Packages (304 nodes)
+Initializing Device/Processor/Thermal objects by executing _INI methods:.
 Executed 1 _INI methods requiring 0 _STA executions (examined 54 objects)
 ACPI: Interpreter enabled
+ACPI: (supports S0 S5)
 ACPI: Using IOAPIC for interrupt routing
-[ACPI Debug]  String: [0x04] "_PIC"
-[ACPI Debug]  Integer: 0x00000001
-[ACPI Debug]  String: [0x04] "SWZL"
-[ACPI Debug]  Integer: 0x00000000
-[ACPI Debug]  String: [0x09] "FDC _STA "
-[ACPI Debug]  String: [0x06] "LDN:  "
-[ACPI Debug]  Integer: 0x00000000
-[ACPI Debug]  Integer: 0x0000000D
-[ACPI Debug]  String: [0x09] "FDC _STA "
-[ACPI Debug]  String: [0x06] "LDN:  "
-[ACPI Debug]  Integer: 0x00000000
-[ACPI Debug]  Integer: 0x0000000D
-[ACPI Debug]  String: [0x0A] "COMA _STA "
-[ACPI Debug]  String: [0x06] "LDN:  "
-[ACPI Debug]  Integer: 0x00000004
-[ACPI Debug]  Integer: 0x0000000F
-[ACPI Debug]  String: [0x0A] "COMA _STA "
-[ACPI Debug]  String: [0x06] "LDN:  "
-[ACPI Debug]  Integer: 0x00000004
-[ACPI Debug]  Integer: 0x0000000F
-[ACPI Debug]  String: [0x0A] "COMB _STA "
-[ACPI Debug]  String: [0x06] "LDN:  "
-[ACPI Debug]  Integer: 0x00000005
-[ACPI Debug]  Integer: 0x0000000F
-[ACPI Debug]  String: [0x0A] "COMB _STA "
-[ACPI Debug]  String: [0x06] "LDN:  "
-[ACPI Debug]  Integer: 0x00000005
-[ACPI Debug]  Integer: 0x0000000F
-[ACPI Debug]  String: [0x0A] "KYBD _STA "
-[ACPI Debug]  Integer: 0x00000000
-[ACPI Debug]  String: [0x09] "MOU _STA "
-[ACPI Debug]  Integer: 0x00000000
 ACPI: PCI Root Bridge [PCI0] (0000:00)
-PCI: Dell PowerEdge 1950 detected, enabling pci=bfsort.
-PCI: Probing PCI hardware (bus 00)
 PCI: PXH quirk detected, disabling MSI for SHPC device
 PCI: PXH quirk detected, disabling MSI for SHPC device
 PCI: Transparent bridge - 0000:00:1e.0
@@ -257,55 +227,6 @@
 Linux Plug and Play Support v0.97 (c) Adam Belay
 pnp: PnP ACPI init
 ACPI: bus type pnp registered
-[ACPI Debug]  String: [0x0D] "HB0 _CRS.TOMR"
-[ACPI Debug]  String: [0x04] "Min:"
-[ACPI Debug]  Integer: 0x40000000
-[ACPI Debug]  String: [0x04] "Max:"
-[ACPI Debug]  Integer: 0xFDFFFFFF
-[ACPI Debug]  String: [0x07] "Length:"
-[ACPI Debug]  Integer: 0xBE000000
-[ACPI Debug]  Buffer: [0x6E]
-[ACPI Debug]  String: [0x09] "DMA_ _CRS"
-[ACPI Debug]  String: [0x08] "FPU _CRS"
-[ACPI Debug]  String: [0x0B] "SB_NMI _CRS"
-[ACPI Debug]  String: [0x08] "RTC _CRS"
-[ACPI Debug]  String: [0x09] "FDC _STA "
-[ACPI Debug]  String: [0x06] "LDN:  "
-[ACPI Debug]  Integer: 0x00000000
-[ACPI Debug]  Integer: 0x0000000D
-[ACPI Debug]  String: [0x09] "FDC _PRS "
-[ACPI Debug]  String: [0x0A] "COMA _STA "
-[ACPI Debug]  String: [0x06] "LDN:  "
-[ACPI Debug]  Integer: 0x00000004
-[ACPI Debug]  Integer: 0x0000000F
-[ACPI Debug]  String: [0x0A] "COMA _CRS "
-[ACPI Debug]  String: [0x06] "LDN:  "
-[ACPI Debug]  Integer: 0x00000004
-[ACPI Debug]  Integer: 0x00000003
-[ACPI Debug]  Integer: 0x000000F8
-[ACPI Debug]  String: [0x01] " "
-[ACPI Debug]  Integer: 0x00000010
-[ACPI Debug]  Buffer: [0x7B]
-[ACPI Debug]  String: [0x0A] "COMB _STA "
-[ACPI Debug]  String: [0x06] "LDN:  "
-[ACPI Debug]  Integer: 0x00000005
-[ACPI Debug]  Integer: 0x0000000F
-[ACPI Debug]  String: [0x0A] "COMB _CRS "
-[ACPI Debug]  String: [0x06] "LDN:  "
-[ACPI Debug]  Integer: 0x00000005
-[ACPI Debug]  Integer: 0x00000002
-[ACPI Debug]  Integer: 0x000000F8
-[ACPI Debug]  String: [0x01] " "
-[ACPI Debug]  Integer: 0x00000008
-[ACPI Debug]  Buffer: [0x7B]
-[ACPI Debug]  String: [0x0A] "KYBD _STA "
-[ACPI Debug]  Integer: 0x00000000
-[ACPI Debug]  String: [0x09] "MOU _STA "
-[ACPI Debug]  Integer: 0x00000000
-[ACPI Debug]  String: [0x09] "PEHB _CRS"
-[ACPI Debug]  Buffer: [0x1C]
-[ACPI Debug]  String: [0x09] "HPET _CRS"
-[ACPI Debug]  Buffer: [0x1C]
 pnp: PnP ACPI: found 12 devices
 ACPI: ACPI bus type pnp unregistered
 SCSI subsystem initialized
@@ -314,12 +235,20 @@
 usbcore: registered new device driver usb
 PCI: Using ACPI for IRQ routing
 PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a 
report
+Time: hpet clocksource has been installed.
+Clockevents: could not switch to one-shot mode: lapic is not functional.
+Could not switch to high resolution mode on CPU 0
+Clockevents: could not switch to one-shot mode:<6>Clockevents: could not 
switch to one-shot mode: lapic is not functional.
+ lapic is not functional.
+Could not switch to high resolution mode on CPU 2
+Could not switch to high resolution mode on CPU 3
+Clockevents: could not switch to one-shot mode: lapic is not functional.
+Could not switch to high resolution mode on CPU 1
 pnp: 00:08: ioport range 0x800-0x87f has been reserved
 pnp: 00:08: ioport range 0x880-0x8bf has been reserved
 pnp: 00:08: ioport range 0x8c0-0x8df has been reserved
 pnp: 00:08: ioport range 0x8e0-0x8e3 has been reserved
 pnp: 00:08: ioport range 0xc00-0xc7f has been reserved
-Time: hpet clocksource has been installed.
 pnp: 00:08: ioport range 0xca0-0xca7 has been reserved
 pnp: 00:08: ioport range 0xca9-0xcab has been reserved
 pnp: 00:08: ioport range 0xcad-0xcaf has been reserved
@@ -468,56 +397,51 @@
 assign_interrupt_mode Found MSI capability
 Allocate Port Service[0000:06:01.0:pcie20]
 Allocate Port Service[0000:06:01.0:pcie21]
-Evaluate _OSC Set fails. Status = 0x0005
-Evaluate _OSC Set fails. Status = 0x0005
-aer_init: AER service init fails - Run ACPI _OSC fails
-aer: probe of 0000:00:02.0:pcie01 failed with error 2
-Evaluate _OSC Set fails. Status = 0x0005
-Evaluate _OSC Set fails. Status = 0x0005
-aer_init: AER service init fails - Run ACPI _OSC fails
-aer: probe of 0000:00:03.0:pcie01 failed with error 2
-Evaluate _OSC Set fails. Status = 0x0005
-Evaluate _OSC Set fails. Status = 0x0005
-aer_init: AER service init fails - Run ACPI _OSC fails
-aer: probe of 0000:00:04.0:pcie01 failed with error 2
-aer_init: AER service init fails - No ACPI _OSC support
-aer: probe of 0000:00:05.0:pcie01 failed with error 1
-aer_init: AER service init fails - No ACPI _OSC support
-aer: probe of 0000:00:06.0:pcie01 failed with error 1
-aer_init: AER service init fails - No ACPI _OSC support
-aer: probe of 0000:00:07.0:pcie01 failed with error 1
+AER service couldn't init device 0000:00:02.0:pcie01 - no _OSC support
+AER service couldn't init device 0000:00:03.0:pcie01 - no _OSC support
+AER service couldn't init device 0000:00:04.0:pcie01 - no _OSC support
+AER service couldn't init device 0000:00:05.0:pcie01 - no _OSC support
+AER service couldn't init device 0000:00:06.0:pcie01 - no _OSC support
+AER service couldn't init device 0000:00:07.0:pcie01 - no _OSC support
+input: Power Button (FF) as /class/input/input0
+ACPI: Power Button (FF) [PWRF]
 Real Time Clock Driver v1.12ac
-[ACPI Debug]  String: [0x09] "HPET _CRS"
-[ACPI Debug]  Buffer: [0x1C]
 hpet_resources: 0xfed00000 is busy
-ACPI Error (utglobal-0126): Unknown exception code: 0xFFFFFFF0 [20070126]
 intel_rng: FWH not detected
 Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin is 60 
seconds).
 Hangcheck: Using get_cycles().
-input: Power Button (FF) as /class/input/input0
-ACPI: Power Button (FF) [PWRF]
 Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
+serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
+serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
 00:07: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
+Clockevents: could not switch to one-shot mode:<6>Clockevents: could not 
switch to one-shot mode:<6>Clockevents: could not switch to one-shot mode: 
lapic is not functional.
+ lapic is not functional.
+Could not switch to high resolution mode on CPU 3
+Could not switch to high resolution mode on CPU 2
+Clockevents: could not switch to one-shot mode: lapic is not functional.
+Could not switch to high resolution mode on CPU 0
+ lapic is not functional.
+Could not switch to high resolution mode on CPU 1
 floppy0: no floppy controllers found
 RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
 loop: module loaded
-Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.5.11 (June 4, 2007)
-ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 16 (level, low) -> IRQ 16
-eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz 
found at mem f8000000, IRQ 16, node addr 001372f873ac
+Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.6.5 (September 20, 
2007)
 ACPI: PCI Interrupt 0000:08:00.0[A] -> GSI 16 (level, low) -> IRQ 16
-eth1: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz 
found at mem f4000000, IRQ 16, node addr 001372f873ae
+eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz 
found at mem f4000000, IRQ 16, node addr 001372f873ae
+ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 16 (level, low) -> IRQ 16
+eth1: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz 
found at mem f8000000, IRQ 16, node addr 001372f873ac
 Loading iSCSI transport class v2.0-724.
-Fusion MPT base driver 3.04.04
+Fusion MPT base driver 3.04.05
 Copyright (c) 1999-2007 LSI Logic Corporation
-Fusion MPT SPI Host driver 3.04.04
-Fusion MPT FC Host driver 3.04.04
-Fusion MPT SAS Host driver 3.04.04
+Fusion MPT SPI Host driver 3.04.05
+Fusion MPT FC Host driver 3.04.05
+Fusion MPT SAS Host driver 3.04.05
 PCI: Enabling device 0000:02:08.0 (0156 -> 0157)
 ACPI: PCI Interrupt 0000:02:08.0[A] -> GSI 64 (level, low) -> IRQ 17
 mptbase: Initiating ioc0 bringup
-ioc0: SAS1068: Capabilities={Initiator}
-scsi0 : ioc0: LSISAS1068, FwRev=00062800h, Ports=1, MaxQ=511, IRQ=17
+ioc0: LSISAS1068 B0: Capabilities={Initiator}
+scsi0 : ioc0: LSISAS1068 B0, FwRev=00062800h, Ports=1, MaxQ=511, IRQ=17
 scsi 0:0:0:0: Direct-Access     ATA      WDC WD800JD-75MS 1E04 PQ: 0 ANSI: 5
 sd 0:0:0:0: [sda] 156250000 512-byte hardware sectors (80000 MB)
 sd 0:0:0:0: [sda] Write Protect is off
@@ -530,7 +454,7 @@
  sda: sda1 sda2 sda3
 sd 0:0:0:0: [sda] Attached SCSI disk
 sd 0:0:0:0: Attached scsi generic sg0 type 0
-Fusion MPT misc device (ioctl) driver 3.04.04
+Fusion MPT misc device (ioctl) driver 3.04.05
 mptctl: Registered with Fusion MPT base driver
 mptctl: /dev/mptctl @ (major,minor=10,220)
 usbmon: debugfs is not available
@@ -576,12 +500,13 @@
 hub 1-5:1.0: USB hub found
 hub 1-5:1.0: 4 ports detected
 usbcore: registered new interface driver usblp
-drivers/usb/class/usblp.c: v0.13: USB Printer Device Class driver
 PNP: No PS/2 controller found. Probing ports directly.
 serio: i8042 KBD port at 0x60,0x64 irq 1
 serio: i8042 AUX port at 0x60,0x64 irq 12
 mice: PS/2 mouse device common for all mice
-EDAC MC: Ver: 2.0.1 Sep  4 2007
+EDAC MC: Ver: 2.1.0 Oct 10 2007
+EDAC MC0: Giving out device to 'i5000_edac.c' 'I5000': DEV 0000:00:10.0
+EDAC PCI0: Giving out device to module 'i5000_edac' controller 'EDAC PCI 
controller': DEV '0000:00:10.0' (POLLED)
 usb 3-2: new low speed USB device using uhci_hcd and address 2
 usb 3-2: configuration #1 chosen from 1 choice
 input: DELL DELL USB Keyboard as /class/input/input1
@@ -599,15 +524,21 @@
 EXT3-fs: recovery complete.
 EXT3-fs: mounted filesystem with ordered data mode.
 VFS: Mounted root (ext3 filesystem) readonly.
-Freeing unused kernel memory: 236k freed
+Freeing unused kernel memory: 232k freed
+net eth0_rename: device_rename: sysfs_create_symlink failed (-17)
+net eth0: device_rename: sysfs_create_symlink failed (-17)
+net eth1: device_rename: sysfs_create_symlink failed (-17)
 libata version 2.21 loaded.
-ata_piix 0000:00:1f.1: version 2.11
+ata_piix 0000:00:1f.1: version 2.12
 ACPI: PCI Interrupt 0000:00:1f.1[A] -> GSI 16 (level, low) -> IRQ 16
 PCI: Setting latency timer of device 0000:00:1f.1 to 64
 scsi1 : ata_piix
 scsi2 : ata_piix
 ata1: PATA max UDMA/100 cmd 0x000101f0 ctl 0x000103f6 bmdma 0x0001fc00 irq 14
 ata2: PATA max UDMA/100 cmd 0x00010170 ctl 0x00010376 bmdma 0x0001fc08 irq 15
+iTCO_wdt: Intel TCO WatchDog Timer Driver v1.02 (26-Jul-2007)
+iTCO_wdt: Found a 631xESB/632xESB TCO device (Version=2, TCOBASE=0x0860)
+iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
 ata1.00: ATAPI: TEAC CD-ROM CD-224E-N, 3.AB, max UDMA/33
 ata1.00: configured for UDMA/33
 ata2: port disabled. ignoring.
@@ -621,17 +552,65 @@
 IPMI System Interface driver.
 ipmi_si: Trying SMBIOS-specified kcs state machine at i/o address 0xca8, 
slave address 0x20, irq 0
 ipmi: Found new BMC (man_id: 0x0002a2,  prod_id: 0x0100, dev_id: 0x20)
- IPMI kcs interface initialized
+IPMI kcs interface initialized
 ipmi device interface
+IPMI Watchdog: Unable to register misc device
 IPMI Watchdog: driver initialized
 Unable to find swap-space signature
 bnx2: eth1: using MSI
 bnx2: eth0: using MSI
-bnx2: eth0 NIC Link is Up, 1000 Mbps full duplex
 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
 All bugs added by David S. Miller <davem@redhat.com>


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

