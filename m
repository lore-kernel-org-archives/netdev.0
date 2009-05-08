From: Kasper Sandberg <lkml@metanurb.dk>
Subject: WARNING: at net/sched/sch_generic.c:226 kernel 2.6.29.2
Date: Fri, 08 May 2009 13:59:43 +0200
Message-ID: <1241783983.29072.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Mario Limonciello <mario_limonciello@dell.com>,
	netdev@vger.kernel.org
To: LKML Mailinglist <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:44758 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753578AbZEHM0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2009 08:26:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Im having some problems with the nic on my d945gclf atom board:
01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8101E/RTL8102E PCI Express Fast Ethernet controller (rev 02)

this is on 2.6.29.2

basically, under load, it comes with the warning message:
[49086.000030] ------------[ cut here ]------------
[49086.000038] WARNING: at net/sched/sch_generic.c:226 dev_watchdog
+0xf6/0x18b()
[49086.000043] Hardware name:
[49086.000047] NETDEV WATCHDOG: eth0 (r8169): transmit timed out
[49086.000056] Modules linked in: nf_nat_ftp nf_nat_irc nf_conntrack_irc
nf_conntrack_ftp ipt_MASQUERADE iptable_nat nf_nat ipt_REJECT xt_tcpudp
ipt_LOG xt_limit xt_state nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4
iptable_filter ip_tables x_tables smsc47m1 smsc47m192 hwmon_vid loop
button snd_pcsp i2c_i801 psmouse snd_pcm snd_timer i2c_core serio_raw
snd soundcore snd_page_alloc rng_core iTCO_wdt evdev ext3 jbd mbcache
sd_mod usbhid hid piix usb_storage ide_pci_generic ide_core ata_generic
ata_piix libata ehci_hcd uhci_hcd 8139too scsi_mod usbcore r8169 mii
thermal processor fan thermal_sys
[49086.000155] Pid: 0, comm: swapper Not tainted 2.6.29.2 #1
[49086.000159] Call Trace:
[49086.000169]  [<c012621c>] warn_slowpath+0x80/0xb6
[49086.000178]  [<c011ab86>] activate_task+0x1c/0x21
[49086.000184]  [<c0121115>] try_to_wake_up+0x160/0x169
[49086.000193]  [<c013609f>] autoremove_wake_function+0xd/0x2d
[49086.000199]  [<c011b103>] __wake_up_common+0x34/0x59
[49086.000205]  [<c011b9ac>] __wake_up+0x29/0x39
[49086.000212]  [<c0279b87>] sk_reset_timer+0xc/0x19
[49086.000220]  [<c02b6432>] tcp_v4_rcv+0x40e/0x642
[49086.000241]  [<f8033e74>] rtl8139_interrupt+0x3a9/0x3b4 [8139too]
[49086.000248]  [<c0111a88>] ack_apic_level+0x88/0x221
[49086.000255]  [<c0290c8c>] dev_watchdog+0xf6/0x18b
[49086.000268]  [<c01039c7>] common_interrupt+0x27/0x2c
[49086.000275]  [<c0290b83>] __netdev_watchdog_up+0x3f/0x52
[49086.000281]  [<c0290b96>] dev_watchdog+0x0/0x18b
[49086.000287]  [<c0290b96>] dev_watchdog+0x0/0x18b
[49086.000295]  [<c012da4c>] run_timer_softirq+0x14a/0x1b4
[49086.000301]  [<c0290b96>] dev_watchdog+0x0/0x18b
[49086.000307]  [<c012a7d0>] __do_softirq+0x8c/0x115
[49086.000313]  [<c012a89e>] do_softirq+0x45/0x53
[49086.000319]  [<c012a9c3>] irq_exit+0x35/0x62
[49086.000325]  [<c0110604>] smp_apic_timer_interrupt+0x71/0x7b
[49086.000331]  [<c0103ae0>] apic_timer_interrupt+0x28/0x30
[49086.000339]  [<c010889d>] mwait_idle+0x4c/0x5a
[49086.000345]  [<c01024f3>] cpu_idle+0x60/0x79
[49086.000349] ---[ end trace 31545b0747da8e68 ]---
[49086.023022] r8169: eth0: link up

now, the time till it comes and responds again varies, from a few
seconds to minutes.

lspci -vvx:
01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8101E/RTL8102E PCI Express Fast Ethernet controller (rev 02)
        Subsystem: Intel Corporation Device 0001
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 27
        Region 0: I/O ports at 2000 [size=256]
        Region 2: Memory at 48200000 (64-bit, non-prefetchable)
[size=4K]
        Region 4: Memory at 48000000 (64-bit, prefetchable) [size=64K]
        Expansion ROM at 48020000 [disabled] [size=128K]
        Capabilities: [40] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1
+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
Queue=0/0 Enable+
                Address: 00000000fee0300c  Data: 4181
        Capabilities: [70] Express (v2) Endpoint, MSI 01
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
<512ns, L1 <8us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+
TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <512ns, L1 <64us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [ac] MSI-X: Enable- Mask- TabSize=2
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00000800
        Capabilities: [cc] Vital Product Data <?>
        Kernel driver in use: r8169
        Kernel modules: r8169
00: ec 10 36 81 07 04 10 00 02 00 00 02 10 00 00 00
10: 01 20 00 00 00 00 00 00 04 00 20 48 00 00 00 00
20: 0c 00 00 48 00 00 00 00 00 00 00 00 86 80 01 00
30: 00 00 fe ff 40 00 00 00 00 00 00 00 0b 01 00 00


this also occurs in 2.6.26, i know lots of people have issues with it on
debian lenny. it also happens on other hardware supported by the r8169
driver, for instance, on a d945gclf2 board i have, with "RTL8111/8168B".

i read on debian forums that ubuntu users have tried the driver which
realtek provides with success, i havent tried that myself though.

can i be of assistance with any other data(kernel log at bottom)?

Thanks!

------
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.29.2 (root@redeeevm) (gcc version 4.3.2
(Debian 4.3.2-1.1) ) #1 SMP Thu May 7 23:08:05 CEST 2009
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   NSC Geode by NSC
[    0.000000]   Cyrix CyrixInstead
[    0.000000]   Centaur CentaurHauls
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000]   UMC UMC UMC UMC
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000008f000 (usable)
[    0.000000]  BIOS-e820: 000000000008f000 - 00000000000a0000
(reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000
(reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003f533000 (usable)
[    0.000000]  BIOS-e820: 000000003f533000 - 000000003f53b000
(reserved)
[    0.000000]  BIOS-e820: 000000003f53b000 - 000000003f5cb000 (usable)
[    0.000000]  BIOS-e820: 000000003f5cb000 - 000000003f5cf000
(reserved)
[    0.000000]  BIOS-e820: 000000003f5cf000 - 000000003f661000 (usable)
[    0.000000]  BIOS-e820: 000000003f661000 - 000000003f6f0000 (ACPI
NVS)
[    0.000000]  BIOS-e820: 000000003f6f0000 - 000000003f6f2000 (usable)
[    0.000000]  BIOS-e820: 000000003f6f2000 - 000000003f6ff000 (ACPI
data)
[    0.000000]  BIOS-e820: 000000003f6ff000 - 000000003f700000 (usable)
[    0.000000]  BIOS-e820: 000000003f700000 - 0000000040000000
(reserved)
[    0.000000]  BIOS-e820: 00000000f0000000 - 0000000100000000
(reserved)
[    0.000000] DMI 2.4 present.
[    0.000000] last_pfn = 0x3f700 max_arch_pfn = 0x100000
[    0.000000] kernel direct mapping tables up to 377fe000 @ 7000-c000
[    0.000000] RAMDISK: 379e7000 - 37fefc41
[    0.000000] Allocated new RAMDISK: 004ab000 - 00ab3c41
[    0.000000] Move RAMDISK from 00000000379e7000 - 0000000037fefc40 to
004ab000 - 00ab3c40
[    0.000000] ACPI: RSDP 000FE020, 0014 (r0 INTEL )
[    0.000000] ACPI: RSDT 3F6FD038, 003C (r1 INTEL  D945GLF        43
1000013)
[    0.000000] ACPI: FACP 3F6FC000, 0074 (r1 INTEL  D945GLF        43
MSFT  1000013)
[    0.000000] FADT: X_PM1a_EVT_BLK.bit_width (16) does not match
PM1_EVT_LEN (4)
[    0.000000] ACPI: DSDT 3F6F7000, 477C (r1 INTEL  D945GLF        43
MSFT  1000013)
[    0.000000] ACPI: FACS 3F6A3000, 0040
[    0.000000] ACPI: APIC 3F6F6000, 0078 (r1 INTEL  D945GLF        43
MSFT  1000013)
[    0.000000] ACPI: WDDT 3F6F5000, 0040 (r1 INTEL  D945GLF        43
MSFT  1000013)
[    0.000000] ACPI: MCFG 3F6F4000, 003C (r1 INTEL  D945GLF        43
MSFT  1000013)
[    0.000000] ACPI: ASF! 3F6F3000, 00A6 (r32 INTEL  D945GLF        43
MSFT  1000013)
[    0.000000] ACPI: HPET 3F6F2000, 0038 (r1 INTEL  D945GLF        43
MSFT  1000013)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 127MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 00000000 - 377fe000
[    0.000000]   bootmap 00008000 - 0000ef00
[    0.000000] (9 early reservations) ==> bootmem [0000000000 -
00377fe000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==>
[0000000000 - 0000001000]
[    0.000000]   #1 [0000001000 - 0000002000]    EX TRAMPOLINE ==>
[0000001000 - 0000002000]
[    0.000000]   #2 [0000006000 - 0000007000]       TRAMPOLINE ==>
[0000006000 - 0000007000]
[    0.000000]   #3 [0000100000 - 00004a74c4]    TEXT DATA BSS ==>
[0000100000 - 00004a74c4]
[    0.000000]   #4 [00004a8000 - 00004ab000]    INIT_PG_TABLE ==>
[00004a8000 - 00004ab000]
[    0.000000]   #5 [000009fc00 - 0000100000]    BIOS reserved ==>
[000009fc00 - 0000100000]
[    0.000000]   #6 [0000007000 - 0000008000]          PGTABLE ==>
[0000007000 - 0000008000]
[    0.000000]   #7 [00004ab000 - 0000ab3c41]      NEW RAMDISK ==>
[00004ab000 - 0000ab3c41]
[    0.000000]   #8 [0000008000 - 000000f000]          BOOTMAP ==>
[0000008000 - 000000f000]
[    0.000000] found SMP MP-table at [c00fe200] 000fe200
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x000377fe
[    0.000000]   HighMem  0x000377fe -> 0x0003f700
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[6] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000008f
[    0.000000]     0: 0x00000100 -> 0x0003f533
[    0.000000]     0: 0x0003f53b -> 0x0003f5cb
[    0.000000]     0: 0x0003f5cf -> 0x0003f661
[    0.000000]     0: 0x0003f6f0 -> 0x0003f6f2
[    0.000000]     0: 0x0003f6ff -> 0x0003f700
[    0.000000] On node 0 totalpages: 259559
[    0.000000] free_area_init_node: node 0, pgdat c03b4f00, node_mem_map
c1000000
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3951 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 221486 pages, LIFO batch:31
[    0.000000]   HighMem zone: 255 pages used for memmap
[    0.000000]   HighMem zone: 32091 pages, LIFO batch:7
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI
0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high
level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] SMP: Allowing 4 CPUs, 2 hotplug CPUs
[    0.000000] nr_irqs_gsi: 24
[    0.000000] PM: Registered nosave memory: 000000000008f000 -
00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 -
00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 -
0000000000100000
[    0.000000] Allocating PCI resources starting at 50000000 (gap:
40000000:b0000000)
[    0.000000] NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Allocating 32768 bytes of per cpu data
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
Total pages: 257528
[    0.000000] Kernel command line: root=/dev/sda1 ro quiet
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 16384 bytes)
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 1596.411 MHz processor.
[    0.004000] Console: colour VGA+ 80x25
[    0.004000] console [tty0] enabled
[    0.004000] Dentry cache hash table entries: 131072 (order: 7, 524288
bytes)
[    0.004000] Inode-cache hash table entries: 65536 (order: 6, 262144
bytes)
[    0.004000] Memory: 1018892k/1039360k available (1960k kernel code,
19032k reserved, 908k data, 328k init, 129384k highmem)
[    0.004000] virtual kernel memory layout:
[    0.004000]     fixmap  : 0xfff50000 - 0xfffff000   ( 700 kB)
[    0.004000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.004000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.004000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.004000]       .init : 0xc03d3000 - 0xc0425000   ( 328 kB)
[    0.004000]       .data : 0xc02ea3d3 - 0xc03cd728   ( 908 kB)
[    0.004000]       .text : 0xc0100000 - 0xc02ea3d3   (1960 kB)
[    0.004000] Checking if this processor honours the WP bit even in
supervisor mode...Ok.
[    0.004000] hpet clockevent registered
[    0.004000] HPET: 3 timers in total, 0 timers will be used for
per-cpu timer
[    0.004000] Calibrating delay loop (skipped), value calculated using
timer frequency.. 3192.82 BogoMIPS (lpj=6385644)
[    0.004000] Security Framework initialized
[    0.004000] SELinux:  Disabled at boot.
[    0.004000] Mount-cache hash table entries: 512
[    0.004000] Initializing cgroup subsys ns
[    0.004000] Initializing cgroup subsys cpuacct
[    0.004000] Initializing cgroup subsys devices
[    0.004000] CPU: L1 I cache: 32K, L1 D cache: 24K
[    0.004000] CPU: L2 cache: 512K
[    0.004000] CPU: Physical Processor ID: 0
[    0.004000] CPU: Processor Core ID: 0
[    0.004000] Intel machine check architecture supported.
[    0.004000] Intel machine check reporting enabled on CPU#0.
[    0.004000] using mwait in idle threads.
[    0.004000] Checking 'hlt' instruction... OK.
[    0.018906] ACPI: Core revision 20081204
[    0.028440] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.068219] CPU0: Intel(R) Atom(TM) CPU  230   @ 1.60GHz stepping 02
[    0.072001] Booting processor 1 APIC 0x1 ip 0x6000
[    0.004000] Initializing CPU#1
[    0.004000] Calibrating delay using timer specific routine.. 3192.12
BogoMIPS (lpj=6384255)
[    0.004000] CPU: L1 I cache: 32K, L1 D cache: 24K
[    0.004000] CPU: L2 cache: 512K
[    0.004000] CPU: Physical Processor ID: 0
[    0.004000] CPU: Processor Core ID: 0
[    0.004000] Intel machine check architecture supported.
[    0.004000] Intel machine check reporting enabled on CPU#1.
[    0.160290] CPU1: Intel(R) Atom(TM) CPU  230   @ 1.60GHz stepping 02
[    0.160328] checking TSC synchronization [CPU#0 -> CPU#1]: passed.
[    0.164051] Brought up 2 CPUs
[    0.164058] Total of 2 processors activated (6384.94 BogoMIPS).
[    0.164115] CPU0 attaching sched-domain:
[    0.164120]  domain 0: span 0-1 level SIBLING
[    0.164125]   groups: 0 1
[    0.164134] CPU1 attaching sched-domain:
[    0.164138]  domain 0: span 0-1 level SIBLING
[    0.164142]   groups: 1 0
[    0.164265] net_namespace: 1056 bytes
[    0.164265] Booting paravirtualized kernel on bare hardware
[    0.164562] NET: Registered protocol family 16
[    0.164562] ACPI: bus type pci registered
[    0.164562] PCI: Found Intel Corporation 945G/GZ/P/PL Express Memory
Controller Hub without MMCONFIG support.
[    0.168487] PCI: Using configuration type 1 for base access
[    0.168526] bio: create slab <bio-0> at 0
[    0.172368] ACPI: EC: Look up EC in DSDT
[    0.177923] ACPI: Interpreter enabled
[    0.177932] ACPI: (supports S0 S1 S3 S4 S5)
[    0.177977] ACPI: Using IOAPIC for interrupt routing
[    0.186144] ACPI: No dock devices found.
[    0.186144] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.186144] pci 0000:00:02.0: reg 10 32bit mmio:
[0x48300000-0x4837ffff]
[    0.186144] pci 0000:00:02.0: reg 14 io port: [0x30e0-0x30e7]
[    0.186144] pci 0000:00:02.0: reg 18 32bit mmio:
[0x40000000-0x47ffffff]
[    0.186144] pci 0000:00:02.0: reg 1c 32bit mmio:
[0x48380000-0x4839ffff]
[    0.186144] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.186144] pci 0000:00:1c.0: PME# disabled
[    0.186144] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.186144] pci 0000:00:1c.2: PME# disabled
[    0.186144] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.186144] pci 0000:00:1c.3: PME# disabled
[    0.186144] pci 0000:00:1d.0: reg 20 io port: [0x3080-0x309f]
[    0.186144] pci 0000:00:1d.1: reg 20 io port: [0x3060-0x307f]
[    0.186144] pci 0000:00:1d.2: reg 20 io port: [0x3040-0x305f]
[    0.186144] pci 0000:00:1d.3: reg 20 io port: [0x3020-0x303f]
[    0.186144] pci 0000:00:1d.7: reg 10 32bit mmio:
[0x483a0000-0x483a03ff]
[    0.186144] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.186144] pci 0000:00:1d.7: PME# disabled
[    0.186144] pci 0000:00:1f.0: quirk: region 0400-047f claimed by ICH6
ACPI/GPIO/TCO
[    0.186144] pci 0000:00:1f.0: quirk: region 0500-053f claimed by ICH6
GPIO
[    0.186144] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at
0680 (mask 007f)
[    0.186144] pci 0000:00:1f.1: reg 10 io port: [0x30d8-0x30df]
[    0.188008] pci 0000:00:1f.1: reg 14 io port: [0x30f4-0x30f7]
[    0.188018] pci 0000:00:1f.1: reg 18 io port: [0x30d0-0x30d7]
[    0.188028] pci 0000:00:1f.1: reg 1c io port: [0x30f0-0x30f3]
[    0.188038] pci 0000:00:1f.1: reg 20 io port: [0x30b0-0x30bf]
[    0.188084] pci 0000:00:1f.2: reg 10 io port: [0x30c8-0x30cf]
[    0.188093] pci 0000:00:1f.2: reg 14 io port: [0x30ec-0x30ef]
[    0.188102] pci 0000:00:1f.2: reg 18 io port: [0x30c0-0x30c7]
[    0.188111] pci 0000:00:1f.2: reg 1c io port: [0x30e8-0x30eb]
[    0.188121] pci 0000:00:1f.2: reg 20 io port: [0x30a0-0x30af]
[    0.188159] pci 0000:00:1f.2: PME# supported from D3hot
[    0.188165] pci 0000:00:1f.2: PME# disabled
[    0.188214] pci 0000:00:1f.3: reg 20 io port: [0x3000-0x301f]
[    0.188284] pci 0000:01:00.0: reg 10 io port: [0x2000-0x20ff]
[    0.188309] pci 0000:01:00.0: reg 18 64bit mmio:
[0x48200000-0x48200fff]
[    0.188328] pci 0000:01:00.0: reg 20 64bit mmio:
[0x48000000-0x4800ffff]
[    0.188340] pci 0000:01:00.0: reg 30 32bit mmio:
[0xfffe0000-0xffffffff]
[    0.188398] pci 0000:01:00.0: supports D1 D2
[    0.188402] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot
D3cold
[    0.188410] pci 0000:01:00.0: PME# disabled
[    0.188467] pci 0000:00:1c.0: bridge io port: [0x2000-0x2fff]
[    0.188474] pci 0000:00:1c.0: bridge 32bit mmio:
[0x48200000-0x482fffff]
[    0.188484] pci 0000:00:1c.0: bridge 64bit mmio pref:
[0x48000000-0x480fffff]
[    0.188612] pci 0000:04:00.0: reg 10 io port: [0x1000-0x10ff]
[    0.188622] pci 0000:04:00.0: reg 14 32bit mmio:
[0x48100000-0x481000ff]
[    0.188654] pci 0000:04:00.0: reg 30 32bit mmio:
[0xfffe0000-0xffffffff]
[    0.188689] pci 0000:04:00.0: supports D1 D2
[    0.188693] pci 0000:04:00.0: PME# supported from D1 D2 D3hot
[    0.188700] pci 0000:04:00.0: PME# disabled
[    0.188751] pci 0000:00:1e.0: transparent bridge
[    0.188758] pci 0000:00:1e.0: bridge io port: [0x1000-0x1fff]
[    0.188765] pci 0000:00:1e.0: bridge 32bit mmio:
[0x48100000-0x481fffff]
[    0.188793] pci_bus 0000:00: on NUMA node 0
[    0.188806] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.189156] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P32_._PRT]
[    0.189527] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
[    0.189653] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2._PRT]
[    0.189777] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3._PRT]
[    0.196421] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 9 10 *11
12)
[    0.196421] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 9 10 11 12)
*0, disabled.
[    0.196613] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 9 10 *11
12)
[    0.196824] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 *10 11
12)
[    0.197033] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 9 10 11 12)
*0, disabled.
[    0.197246] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 *9 10 11
12)
[    0.197455] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 7 9 10 11 12)
*0, disabled.
[    0.197668] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 7 *9 10 11
12)
[    0.200140] PCI: Using ACPI for IRQ routing
[    0.216033] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.216045] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.240393] pnp: PnP ACPI init
[    0.240413] ACPI: bus type pnp registered
[    0.245421] pnp: PnP ACPI: found 10 devices
[    0.245428] ACPI: ACPI bus type pnp unregistered
[    0.245435] PnPBIOS: Disabled by ACPI PNP
[    0.245457] system 00:01: iomem range 0xf0000000-0xf3ffffff has been
reserved
[    0.245463] system 00:01: iomem range 0xfed13000-0xfed13fff has been
reserved
[    0.245470] system 00:01: iomem range 0xfed14000-0xfed17fff has been
reserved
[    0.245476] system 00:01: iomem range 0xfed18000-0xfed18fff has been
reserved
[    0.245482] system 00:01: iomem range 0xfed19000-0xfed19fff has been
reserved
[    0.245488] system 00:01: iomem range 0xfed1c000-0xfed1ffff has been
reserved
[    0.245495] system 00:01: iomem range 0xfed20000-0xfed3ffff has been
reserved
[    0.245501] system 00:01: iomem range 0xfed45000-0xfed99fff has been
reserved
[    0.245507] system 00:01: iomem range 0xc0000-0xdffff could not be
reserved
[    0.245514] system 00:01: iomem range 0xe0000-0xfffff could not be
reserved
[    0.245530] system 00:06: ioport range 0x500-0x53f has been reserved
[    0.245536] system 00:06: ioport range 0x400-0x47f has been reserved
[    0.245542] system 00:06: ioport range 0x680-0x6ff has been reserved
[    0.282762] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:01
[    0.282769] pci 0000:00:1c.0:   IO window: 0x2000-0x2fff
[    0.282778] pci 0000:00:1c.0:   MEM window: 0x48200000-0x482fffff
[    0.282786] pci 0000:00:1c.0:   PREFETCH window:
0x00000048000000-0x000000480fffff
[    0.282796] pci 0000:00:1c.2: PCI bridge, secondary bus 0000:02
[    0.282800] pci 0000:00:1c.2:   IO window: disabled
[    0.282807] pci 0000:00:1c.2:   MEM window: disabled
[    0.282813] pci 0000:00:1c.2:   PREFETCH window: disabled
[    0.282822] pci 0000:00:1c.3: PCI bridge, secondary bus 0000:03
[    0.282826] pci 0000:00:1c.3:   IO window: disabled
[    0.282833] pci 0000:00:1c.3:   MEM window: disabled
[    0.282839] pci 0000:00:1c.3:   PREFETCH window: disabled
[    0.282849] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:04
[    0.282855] pci 0000:00:1e.0:   IO window: 0x1000-0x1fff
[    0.282863] pci 0000:00:1e.0:   MEM window: 0x48100000-0x481fffff
[    0.282870] pci 0000:00:1e.0:   PREFETCH window:
0x00000050000000-0x000000500fffff
[    0.282897] pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low) -> IRQ
17
[    0.282905] pci 0000:00:1c.0: setting latency timer to 64
[    0.282919] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ
18
[    0.282926] pci 0000:00:1c.2: setting latency timer to 64
[    0.282938] pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low) -> IRQ
19
[    0.282945] pci 0000:00:1c.3: setting latency timer to 64
[    0.282955] pci 0000:00:1e.0: setting latency timer to 64
[    0.282963] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    0.282968] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffff]
[    0.282974] pci_bus 0000:01: resource 0 io:  [0x2000-0x2fff]
[    0.282979] pci_bus 0000:01: resource 1 mem: [0x48200000-0x482fffff]
[    0.282984] pci_bus 0000:01: resource 2 mem: [0x48000000-0x480fffff]
[    0.282989] pci_bus 0000:01: resource 3 mem: [0x0-0x0]
[    0.282994] pci_bus 0000:02: resource 0 mem: [0x0-0x0]
[    0.282998] pci_bus 0000:02: resource 1 mem: [0x0-0x0]
[    0.283003] pci_bus 0000:02: resource 2 mem: [0x0-0x0]
[    0.283007] pci_bus 0000:02: resource 3 mem: [0x0-0x0]
[    0.283012] pci_bus 0000:03: resource 0 mem: [0x0-0x0]
[    0.283016] pci_bus 0000:03: resource 1 mem: [0x0-0x0]
[    0.283021] pci_bus 0000:03: resource 2 mem: [0x0-0x0]
[    0.283025] pci_bus 0000:03: resource 3 mem: [0x0-0x0]
[    0.283030] pci_bus 0000:04: resource 0 io:  [0x1000-0x1fff]
[    0.283035] pci_bus 0000:04: resource 1 mem: [0x48100000-0x481fffff]
[    0.283040] pci_bus 0000:04: resource 2 mem: [0x50000000-0x500fffff]
[    0.283046] pci_bus 0000:04: resource 3 io:  [0x00-0xffff]
[    0.283050] pci_bus 0000:04: resource 4 mem: [0x000000-0xffffffff]
[    0.283161] NET: Registered protocol family 2
[    0.328519] IP route cache hash table entries: 32768 (order: 5,
131072 bytes)
[    0.329172] TCP established hash table entries: 131072 (order: 8,
1048576 bytes)
[    0.330151] TCP bind hash table entries: 65536 (order: 7, 524288
bytes)
[    0.330642] TCP: Hash tables configured (established 131072 bind
65536)
[    0.330648] TCP reno registered
[    0.340582] NET: Registered protocol family 1
[    0.340790] checking if image is initramfs...<7>Switched to high
resolution mode on CPU 1
[    0.503944] Switched to high resolution mode on CPU 0
[    0.702382]  it is
[    1.107280] Freeing initrd memory: 6179k freed
[    1.109153] audit: initializing netlink socket (disabled)
[    1.109177] type=2000 audit(1241734157.108:1): initialized
[    1.109513] highmem bounce pool size: 64 pages
[    1.109523] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[    1.109722] VFS: Disk quotas dquot_6.5.2
[    1.109790] Dquot-cache hash table entries: 1024 (order 0, 4096
bytes)
[    1.109898] msgmni has been set to 1749
[    1.110137] alg: No test for stdrng (krng)
[    1.110268] Block layer SCSI generic (bsg) driver version 0.4 loaded
(major 253)
[    1.110275] io scheduler noop registered
[    1.110279] io scheduler anticipatory registered
[    1.110283] io scheduler deadline registered
[    1.110318] io scheduler cfq registered (default)
[    1.110341] pci 0000:00:02.0: Boot video device
[    1.110736] pcieport-driver 0000:00:1c.0: setting latency timer to 64
[    1.110803] pcieport-driver 0000:00:1c.0: irq 24 for MSI/MSI-X
[    1.111031] pcieport-driver 0000:00:1c.2: setting latency timer to 64
[    1.111093] pcieport-driver 0000:00:1c.2: irq 25 for MSI/MSI-X
[    1.111317] pcieport-driver 0000:00:1c.3: setting latency timer to 64
[    1.111379] pcieport-driver 0000:00:1c.3: irq 26 for MSI/MSI-X
[    1.112196] isapnp: Scanning for PnP cards...
[    1.465196] isapnp: No Plug & Play device found
[    1.471293] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.475581] brd: module loaded
[    1.475905] PNP: No PS/2 controller found. Probing ports directly.
[    1.478910] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.478923] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.479269] mice: PS/2 mouse device common for all mice
[    1.479395] rtc_cmos 00:03: RTC can wake from S4
[    1.479520] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    1.479554] rtc0: alarms up to one month, 114 bytes nvram, hpet irqs
[    1.479629] cpuidle: using governor ladder
[    1.479635] cpuidle: using governor menu
[    1.479645] No iBFT detected.
[    1.480454] TCP cubic registered
[    1.480460] NET: Registered protocol family 17
[    1.480478] Using IPI No-Shortcut mode
[    1.480771] registered taskstats version 1
[    1.481058] rtc_cmos 00:03: setting system clock to 2009-05-07
22:09:18 UTC (1241734158)
[    1.481357] Freeing unused kernel memory: 328k freed
[    1.659184] processor ACPI_CPU:00: registered as cooling_device0
[    1.659319] processor ACPI_CPU:01: registered as cooling_device1
[    1.977367] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.977407] r8169 0000:01:00.0: PCI INT A -> GSI 16 (level, low) ->
IRQ 16
[    1.977432] r8169 0000:01:00.0: setting latency timer to 64
[    1.977584] r8169 0000:01:00.0: irq 27 for MSI/MSI-X
[    1.978295] eth0: RTL8102e at 0xf8092000, 00:1c:c0:6f:3a:03, XID
24a00000 IRQ 27
[    2.519177] usbcore: registered new interface driver usbfs
[    2.519256] usbcore: registered new interface driver hub
[    2.562783] usbcore: registered new device driver usb
[    2.640953] SCSI subsystem initialized
[    2.650879] 8139too Fast Ethernet driver 0.9.28
[    2.650957] 8139too 0000:04:00.0: PCI INT A -> GSI 21 (level, low) ->
IRQ 21
[    2.652253] eth1: RealTek RTL8139 at 0x1000, 00:11:6b:96:a6:04, IRQ
21
[    2.652261] eth1:  Identified 8139 chip type 'RTL-8100B/8139D'
[    2.662637] uhci_hcd: USB Universal Host Controller Interface driver
[    2.662739] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low)
-> IRQ 23
[    2.662759] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    2.662767] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    2.662857] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned
bus number 1
[    2.662910] uhci_hcd 0000:00:1d.0: irq 23, io base 0x00003080
[    2.663017] usb usb1: New USB device found, idVendor=1d6b,
idProduct=0001
[    2.663025] usb usb1: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    2.663032] usb usb1: Product: UHCI Host Controller
[    2.663038] usb usb1: Manufacturer: Linux 2.6.29.2 uhci_hcd
[    2.663043] usb usb1: SerialNumber: 0000:00:1d.0
[    2.663201] usb usb1: configuration #1 chosen from 1 choice
[    2.663289] hub 1-0:1.0: USB hub found
[    2.663310] hub 1-0:1.0: 2 ports detected
[    2.663640] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low)
-> IRQ 19
[    2.663660] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    2.663668] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    2.663733] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned
bus number 2
[    2.663795] uhci_hcd 0000:00:1d.1: irq 19, io base 0x00003060
[    2.663900] usb usb2: New USB device found, idVendor=1d6b,
idProduct=0001
[    2.663910] usb usb2: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    2.663917] usb usb2: Product: UHCI Host Controller
[    2.663923] usb usb2: Manufacturer: Linux 2.6.29.2 uhci_hcd
[    2.663928] usb usb2: SerialNumber: 0000:00:1d.1
[    2.664098] usb usb2: configuration #1 chosen from 1 choice
[    2.664183] hub 2-0:1.0: USB hub found
[    2.664205] hub 2-0:1.0: 2 ports detected
[    2.664478] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low)
-> IRQ 18
[    2.664495] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    2.664545] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    2.664616] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned
bus number 3
[    2.664671] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00003040
[    2.664770] usb usb3: New USB device found, idVendor=1d6b,
idProduct=0001
[    2.664778] usb usb3: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    2.664785] usb usb3: Product: UHCI Host Controller
[    2.664791] usb usb3: Manufacturer: Linux 2.6.29.2 uhci_hcd
[    2.664798] usb usb3: SerialNumber: 0000:00:1d.2
[    2.664958] usb usb3: configuration #1 chosen from 1 choice
[    2.665038] hub 3-0:1.0: USB hub found
[    2.665057] hub 3-0:1.0: 2 ports detected
[    2.665321] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level, low)
-> IRQ 16
[    2.665338] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    2.665347] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    2.665411] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned
bus number 4
[    2.665462] uhci_hcd 0000:00:1d.3: irq 16, io base 0x00003020
[    2.665557] usb usb4: New USB device found, idVendor=1d6b,
idProduct=0001
[    2.665565] usb usb4: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    2.665572] usb usb4: Product: UHCI Host Controller
[    2.665578] usb usb4: Manufacturer: Linux 2.6.29.2 uhci_hcd
[    2.665584] usb usb4: SerialNumber: 0000:00:1d.3
[    2.665727] usb usb4: configuration #1 chosen from 1 choice
[    2.665808] hub 4-0:1.0: USB hub found
[    2.665829] hub 4-0:1.0: 2 ports detected
[    2.673289] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI)
Driver
[    2.673298] Warning! ehci_hcd should always be loaded before uhci_hcd
and ohci_hcd, not after
[    2.673361] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low)
-> IRQ 23
[    2.673460] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    2.673470] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    2.673559] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned
bus number 5
[    2.677482] ehci_hcd 0000:00:1d.7: debug port 1
[    2.677495] ehci_hcd 0000:00:1d.7: cache line size of 32 is not
supported
[    2.677515] ehci_hcd 0000:00:1d.7: irq 23, io mem 0x483a0000
[    2.724038] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    2.724112] usb usb5: New USB device found, idVendor=1d6b,
idProduct=0002
[    2.724121] usb usb5: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    2.724129] usb usb5: Product: EHCI Host Controller
[    2.724135] usb usb5: Manufacturer: Linux 2.6.29.2 ehci_hcd
[    2.724141] usb usb5: SerialNumber: 0000:00:1d.7
[    2.724327] usb usb5: configuration #1 chosen from 1 choice
[    2.724415] hub 5-0:1.0: USB hub found
[    2.724439] hub 5-0:1.0: 8 ports detected
[    2.735291] libata version 3.00 loaded.
[    2.743963] ata_piix 0000:00:1f.1: version 2.12
[    2.743991] ata_piix 0000:00:1f.1: PCI INT A -> GSI 18 (level, low)
-> IRQ 18
[    2.744093] ata_piix 0000:00:1f.1: setting latency timer to 64
[    2.745652] scsi0 : ata_piix
[    2.745889] scsi1 : ata_piix
[    2.747004] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x30b0
irq 14
[    2.747014] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x30b8
irq 15
[    2.900637] ata2: port disabled. ignoring.
[    2.900696] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low)
-> IRQ 19
[    2.900705] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[    2.900766] ata_piix 0000:00:1f.2: setting latency timer to 64
[    2.900861] scsi2 : ata_piix
[    2.901427] scsi3 : ata_piix
[    2.901752] ata3: SATA max UDMA/133 cmd 0x30c8 ctl 0x30ec bmdma
0x30a0 irq 19
[    2.901762] ata4: SATA max UDMA/133 cmd 0x30c0 ctl 0x30e8 bmdma
0x30a8 irq 19
[    3.088022] usb 5-8: new high speed USB device using ehci_hcd and
address 3
[    3.234966] usb 5-8: New USB device found, idVendor=0951,
idProduct=1607
[    3.234976] usb 5-8: New USB device strings: Mfr=1, Product=2,
SerialNumber=3
[    3.234984] usb 5-8: Product: DataTraveler 2.0
[    3.234990] usb 5-8: Manufacturer: Kingston
[    3.234996] usb 5-8: SerialNumber: 001372982B41F940362E0309
[    3.235185] usb 5-8: configuration #1 chosen from 1 choice
[    3.279167] Uniform Multi-Platform E-IDE driver
[    3.294941] Initializing USB Mass Storage driver...
[    3.296656] scsi4 : SCSI emulation for USB Mass Storage devices
[    3.298134] usbcore: registered new interface driver usb-storage
[    3.298144] USB Mass Storage support registered.
[    3.298621] usb-storage: device found at 3
[    3.298627] usb-storage: waiting for device to settle before scanning
[    3.484026] usb 2-2: new low speed USB device using uhci_hcd and
address 2
[    3.663679] usb 2-2: New USB device found, idVendor=046d,
idProduct=c308
[    3.663686] usb 2-2: New USB device strings: Mfr=1, Product=2,
SerialNumber=0
[    3.663692] usb 2-2: Product: Logitech USB Keyboard
[    3.663696] usb 2-2: Manufacturer: Logitech
[    3.663855] usb 2-2: configuration #1 chosen from 1 choice
[    3.729615] usbcore: registered new interface driver hiddev
[    3.744498] input: Logitech Logitech USB Keyboard
as /class/input/input0
[    3.760150] generic-usb 0003:046D:C308.0001: input,hidraw0: USB HID
v1.10 Keyboard [Logitech Logitech USB Keyboard] on
usb-0000:00:1d.1-2/input0
[    3.797909] input: Logitech Logitech USB Keyboard
as /class/input/input1
[    3.820140] generic-usb 0003:046D:C308.0002: input,hidraw1: USB HID
v1.10 Mouse [Logitech Logitech USB Keyboard] on
usb-0000:00:1d.1-2/input1
[    3.820175] usbcore: registered new interface driver usbhid
[    3.820182] usbhid: v2.6:USB HID core driver
[    8.296731] usb-storage: device scan complete
[    8.297221] scsi 4:0:0:0: Direct-Access     Kingston DataTraveler 2.0
1.00 PQ: 0 ANSI: 2
[    8.332953] Driver 'sd' needs updating - please use bus_type methods
[    8.336062] sd 4:0:0:0: [sda] 3903578 512-byte hardware sectors:
(1.99 GB/1.86 GiB)
[    8.336556] sd 4:0:0:0: [sda] Write Protect is off
[    8.336563] sd 4:0:0:0: [sda] Mode Sense: 16 07 09 51
[    8.336567] sd 4:0:0:0: [sda] Assuming drive cache: write through
[    8.338561] sd 4:0:0:0: [sda] 3903578 512-byte hardware sectors:
(1.99 GB/1.86 GiB)
[    8.339053] sd 4:0:0:0: [sda] Write Protect is off
[    8.339060] sd 4:0:0:0: [sda] Mode Sense: 16 07 09 51
[    8.339064] sd 4:0:0:0: [sda] Assuming drive cache: write through
[    8.339108]  sda: sda1
[    8.340266] sd 4:0:0:0: [sda] Attached SCSI removable disk
[    8.540193] kjournald starting.  Commit interval 5 seconds
[    8.540204] EXT3-fs: mounted filesystem with ordered data mode.
[    9.636306] udevd version 125 started
[   11.597986] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.05
[   11.598349] iTCO_wdt: Found a ICH7 or ICH7R TCO device (Version=2,
TCOBASE=0x0460)
[   11.598464] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[   12.192439] intel_rng: Firmware space is locked read-only. If you
can't or
[   12.192444] intel_rng: don't want to disable this in firmware setup,
and if
[   12.192449] intel_rng: you are certain that your system has a
functional
[   12.192453] intel_rng: RNG, try using the 'no_fwh_detect' option.
[   13.080106] i801_smbus 0000:00:1f.3: PCI INT B -> GSI 19 (level, low)
-> IRQ 19
[   13.095289] input: PC Speaker as /class/input/input2
[   13.104952] input: Power Button (FF) as /class/input/input3
[   13.160136] ACPI: Power Button (FF) [PWRF]
[   13.160337] input: Sleep Button (CM) as /class/input/input4
[   13.192136] ACPI: Sleep Button (CM) [SLPB]
[   15.089928] EXT3 FS on sda1, internal journal
[   16.071782] loop: module loaded
[   16.216522] i2c-adapter i2c-0: found SMSC47M192 or compatible,
version 2, stepping A0
[   16.311383] smsc47m1: Found SMSC LPC47M15x/LPC47M192/LPC47M997
[   16.311459] ACPI: I/O resource smsc47m1 [0x680-0x6ff] conflicts with
ACPI region RUNT [0x680-0x6ff]
[   16.311467] ACPI: Device needs an ACPI driver
[   17.353751] eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
[   17.639430] r8169: eth0: link up
[   17.639440] r8169: eth0: link up
[   17.881015] ip_tables: (C) 2000-2006 Netfilter Core Team
[   24.225088] nf_conntrack version 0.5.0 (16240 buckets, 64960 max)
[   24.225335] CONFIG_NF_CT_ACCT is deprecated and will be removed soon.
Please use
[   24.225344] nf_conntrack.acct=1 kernel paramater, acct=1 nf_conntrack
module option or
[   24.225351] sysctl net.netfilter.nf_conntrack_acct=1 to enable it.


