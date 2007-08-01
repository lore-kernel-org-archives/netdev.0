From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Tue, 31 Jul 2007 17:45:22 -0700
Message-ID: <20070731174522.b141178a.akpm@linux-foundation.org>
References: <200707311128.32528.joachim.deguara@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "lkml List" <linux-kernel@vger.kernel.org>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org
To: "Joachim Deguara" <joachim.deguara@amd.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <200707311128.32528.joachim.deguara@amd.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Jul 2007 11:28:32 +0200 "Joachim Deguara" <joachim.deguara@amd.com> wrote:

> On my Acer Ferrari 1000 the tg3 ethernet no longer is available after a 
> suspend to ram with the latet 2.6.23-rc1-git9.

Thanks. cc's added, body retained..


>  The tg3 works fine with s2ram 
> in 2.6.22.1.  The tell tail signs that is dead is this message from the 
> kernel log:
> 
> [    6.754133] tg3: eth0: No firmware running.
> [    6.816140] tg3: tg3_load_tso_firmware fails for eth0 to set CPU PC, is 
> ffffffff should be 00010000
> [    7.285797] ACPI: EC: Handler for query 0x80 is not found!
> [    8.016223] tg3: tg3_abort_hw timed out for eth0, TX_MODE_ENABLE will not 
> clear MAC_TX_MODE=ffffffff
> 
> and trying to bring the link up resuls in:
> 
> # ifconfig eth0 up
> SIOCSIFFLAGS: No such device
> 
> Full kernel log follows.
> 
> -Joachim
> 
> [    0.000000] Linux version 2.6.23-rc1-git9 (joachim@avanti) (gcc version 
> 4.2.1 20070705 (prerelease) (SUSE Linux)) #13 SMP PREEMPT Tue Jul 31 11:15:02 
> CEST 2007
> [    0.000000] Command line: 
> root=/dev/disk/by-id/scsi-SATA_Hitachi_HTS5416_SB2404SJHNT7YE-part6 
> sysrq_always_enable resume=/dev/sda5 splash=silent showopts
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000]  BIOS-e820: 0000000000000000 - 000000000009dc00 (usable)
> [    0.000000]  BIOS-e820: 000000000009dc00 - 00000000000a0000 (reserved)
> [    0.000000]  BIOS-e820: 00000000000d0000 - 0000000000100000 (reserved)
> [    0.000000]  BIOS-e820: 0000000000100000 - 000000007be80000 (usable)
> [    0.000000]  BIOS-e820: 000000007be80000 - 000000007be95000 (ACPI data)
> [    0.000000]  BIOS-e820: 000000007be95000 - 000000007bf00000 (ACPI NVS)
> [    0.000000]  BIOS-e820: 000000007bf00000 - 0000000080000000 (reserved)
> [    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
> [    0.000000] Entering add_active_range(0, 0, 157) 0 entries of 3200 used
> [    0.000000] Entering add_active_range(0, 256, 507520) 1 entries of 3200 
> used
> [    0.000000] end_pfn_map = 1048576
> [    0.000000] DMI present.
> [    0.000000] ACPI: RSDP 000F81A0, 0014 (r0 PTLTD )
> [    0.000000] ACPI: RSDT 7BE8D65C, 003C (r1 ACRSYS ACRPRDCT  6040000  LTP        
> 0)
> [    0.000000] ACPI: FACP 7BE94B9A, 0074 (r1 ATI    Bowfin    6040000 ATI     
> F4240)
> [    0.000000] ACPI: DSDT 7BE8D698, 7502 (r1    ATI    SB460  6040000 MSFT  
> 2000002)
> [    0.000000] ACPI: FACS 7BE95FC0, 0040
> [    0.000000] ACPI: SSDT 7BE94C0E, 01C4 (r1 PTLTD  POWERNOW  6040000  LTP        
> 1)
> [    0.000000] ACPI: APIC 7BE94DD2, 0054 (r1 PTLTD  	 APIC    6040000  LTP        
> 0)
> [    0.000000] ACPI: MCFG 7BE94E26, 003C (r1 PTLTD    MCFG    6040000  LTP        
> 0)
> [    0.000000] ACPI: BOOT 7BE94E62, 0028 (r1 PTLTD  $SBFTBL$  6040000  LTP        
> 1)
> [    0.000000] ACPI: SLIC 7BE94E8A, 0176 (r1 ACRSYS ACRPRDCT  6040000 acer        
> 0)
> [    0.000000] Scanning NUMA topology in Northbridge 24
> [    0.000000] CPU has 2 num_cores
> [    0.000000] No NUMA configuration found
> [    0.000000] Faking a node at 0000000000000000-000000007be80000
> [    0.000000] Entering add_active_range(0, 0, 157) 0 entries of 3200 used
> [    0.000000] Entering add_active_range(0, 256, 507520) 1 entries of 3200 
> used
> [    0.000000] Bootmem setup node 0 0000000000000000-000000007be80000
> [    0.000000] Zone PFN ranges:
> [    0.000000]   DMA             0 ->     4096
> [    0.000000]   DMA32        4096 ->  1048576
> [    0.000000]   Normal    1048576 ->  1048576
> [    0.000000] Movable zone start PFN for each node
> [    0.000000] early_node_map[2] active PFN ranges
> [    0.000000]     0:        0 ->      157
> [    0.000000]     0:      256 ->   507520
> [    0.000000] On node 0 totalpages: 507421
> [    0.000000]   DMA zone: 56 pages used for memmap
> [    0.000000]   DMA zone: 1957 pages reserved
> [    0.000000]   DMA zone: 1984 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 6882 pages used for memmap
> [    0.000000]   DMA32 zone: 496542 pages, LIFO batch:31
> [    0.000000]   Normal zone: 0 pages used for memmap
> [    0.000000]   Movable zone: 0 pages used for memmap
> [    0.000000] ATI board detected. Disabling timer routing over 8254.
> [    0.000000] ACPI: PM-Timer IO Port: 0x8008
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> [    0.000000] Processor #0 (Bootup-CPU)
> [    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
> [    0.000000] Processor #1
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
> [    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
> [    0.000000] IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Setting APIC routing to flat
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] swsusp: Registered nosave memory region: 000000000009d000 - 
> 000000000009e000
> [    0.000000] swsusp: Registered nosave memory region: 000000000009e000 - 
> 00000000000a0000
> [    0.000000] swsusp: Registered nosave memory region: 00000000000a0000 - 
> 00000000000d0000
> [    0.000000] swsusp: Registered nosave memory region: 00000000000d0000 - 
> 0000000000100000
> [    0.000000] Allocating PCI resources starting at 88000000 (gap: 
> 80000000:60000000)
> [    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
> [    0.000000] PERCPU: Allocating 32384 bytes of per cpu data
> [    0.000000] Built 1 zonelists in Node order.  Total pages: 498526
> [    0.000000] Policy zone: DMA32
> [    0.000000] Kernel command line: 
> root=/dev/disk/by-id/scsi-SATA_Hitachi_HTS5416_SB2404SJHNT7YE-part6 
> sysrq_always_enable resume=/dev/sda5 splash=silent showopts
> [    0.000000] Initializing CPU#0
> [    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
> [    0.000000] Marking TSC unstable due to TSCs unsynchronized
> [    9.332064] time.c: Detected 1800.121 MHz processor.
> [    9.334073] Console: colour VGA+ 80x25
> [    9.334077] console [tty0] enabled
> [    9.340370] Checking aperture...
> [    9.340460] CPU 0: aperture @ 109e000000 size 32 MB
> [    9.340550] Aperture too small (32 MB)
> [    9.352248] No AGP bridge found
> [    9.370894] Memory: 1990856k/2030080k available (4029k kernel code, 38828k 
> reserved, 2082k data, 316k init)
> [    9.371084] SLUB: Genslabs=23, HWalign=64, Order=0-1, MinObjects=4, CPUs=2, 
> Nodes=1
> [    9.449887] Calibrating delay using timer specific routine.. 3603.97 
> BogoMIPS (lpj=7207957)
> [    9.450344] Dentry cache hash table entries: 262144 (order: 9, 2097152 
> bytes)
> [    9.451787] Inode-cache hash table entries: 131072 (order: 8, 1048576 
> bytes)
> [    9.452539] Mount-cache hash table entries: 256
> [    9.452780] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 
> bytes/line)
> [    9.452872] CPU: L2 Cache: 512K (64 bytes/line)
> [    9.452962] CPU 0/0 -> Node 0
> [    9.453053] CPU: Physical Processor ID: 0
> [    9.453142] CPU: Processor Core ID: 0
> [    9.453274] SMP alternatives: switching to UP code
> [    9.455032] ACPI: Core revision 20070126
> [    9.942195] Using local APIC timer interrupts.
> [    9.997761] result 12500848
> [    9.997854] Detected 12.500 MHz APIC timer.
> [   10.001195] SMP alternatives: switching to SMP code
> [   10.002410] Booting processor 1/2 APIC 0x1
> [   10.012640] Initializing CPU#1
> [   10.093011] Calibrating delay using timer specific routine.. 3600.36 
> BogoMIPS (lpj=7200723)
> [   10.093018] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 
> bytes/line)
> [   10.093020] CPU: L2 Cache: 512K (64 bytes/line)
> [   10.093023] CPU 1/1 -> Node 0
> [   10.093025] CPU: Physical Processor ID: 0
> [   10.093026] CPU: Processor Core ID: 1
> [   10.093117] AMD Turion(tm) 64 X2 Mobile Technology TL-56 stepping 02
> [   10.096955] Brought up 2 CPUs
> [   10.098213] NET: Registered protocol family 16
> [   10.098601] ACPI: ACPI Dock Station Driver 
> [   10.099074] ACPI: bus type pci registered
> [   10.099450] PCI: Using MMCONFIG at e0000000 - e08fffff
> [   10.099581] PCI: No mmconfig possible on device 00:18
> [   10.104581] ACPI: System BIOS is requesting _OSI(Linux)
> [   10.104680] ACPI: If "acpi_osi=Linux" works better,
> [   10.104682] Please send dmidecode to linux-acpi@vger.kernel.org
> [   10.105170] ACPI: Interpreter enabled
> [   10.105263] ACPI: (supports S0 S3)
> [   10.105483] ACPI: Using IOAPIC for interrupt routing
> [   10.110906] ACPI: EC: GPE = 0x14, I/O: command/status = 0x66, data = 
> 0x62<6>ACPI: PCI Root Bridge [PCI0] (0000:00)
> [   10.141469] PCI: Transparent bridge - 0000:00:14.4
> [   10.141642] PCI: Bus #09 (-#0c) is hidden behind transparent bridge #08 
> (-#09) (try 'pci=assign-busses')
> [   10.141785] Please report the result to <bk@suse.de> to fix this 
> permanently
> [   10.141910] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> [   10.142100] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PB4_._PRT]
> [   10.142239] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PB6_._PRT]
> [   10.142372] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PB7_._PRT]
> [   10.142518] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P2P_._PRT]
> [   10.142653] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
> [   10.146589] ACPI: PCI Interrupt Link [LNKA] (IRQs 10 11) *0, disabled.
> [   10.147046] ACPI: PCI Interrupt Link [LNKB] (IRQs 10 11) *0, disabled.
> [   10.147496] ACPI: PCI Interrupt Link [LNKC] (IRQs 10 11) *0, disabled.
> [   10.147947] ACPI: PCI Interrupt Link [LNKD] (IRQs 10 11) *0, disabled.
> [   10.148400] ACPI: PCI Interrupt Link [LNKE] (IRQs 10 11) *0, disabled.
> [   10.148851] ACPI: PCI Interrupt Link [LNKF] (IRQs 10 11) *0, disabled.
> [   10.149307] ACPI: PCI Interrupt Link [LNKG] (IRQs 10 11) *0, disabled.
> [   10.149758] ACPI: PCI Interrupt Link [LNKH] (IRQs 10 11) *0, disabled.
> [   10.150210] ACPI: PCI Interrupt Link [LNKU] (IRQs 3 4 5 7) *0, disabled.
> [   10.150741] Linux Plug and Play Support v0.97 (c) Adam Belay
> [   10.150861] pnp: PnP ACPI init
> [   10.150959] ACPI: bus type pnp registered
> [   10.153898] pnp: PnP ACPI: found 11 devices
> [   10.153994] ACPI: ACPI bus type pnp unregistered
> [   10.154319] SCSI subsystem initialized
> [   10.154471] libata version 2.21 loaded.
> [   10.154590] usbcore: registered new interface driver usbfs
> [   10.154720] usbcore: registered new interface driver hub
> [   10.154858] usbcore: registered new device driver usb
> [   10.155099] PCI: Using ACPI for IRQ routing
> [   10.155192] PCI: If a device doesn't work, try "pci=routeirq".  If it 
> helps, post a report
> [   10.155336] PCI: Cannot allocate resource region 7 of bridge 0000:00:04.0
> [   10.155428] PCI: Cannot allocate resource region 8 of bridge 0000:00:04.0
> [   10.155522] PCI: Cannot allocate resource region 7 of bridge 0000:00:05.0
> [   10.155617] PCI: Cannot allocate resource region 8 of bridge 0000:00:05.0
> [   10.155712] PCI: Cannot allocate resource region 9 of bridge 0000:00:05.0
> [   10.155806] PCI: Cannot allocate resource region 7 of bridge 0000:00:06.0
> [   10.155901] PCI: Cannot allocate resource region 8 of bridge 0000:00:06.0
> [   10.173290] Bluetooth: Core ver 2.11
> [   10.173442] NET: Registered protocol family 31
> [   10.173536] Bluetooth: HCI device and connection manager initialized
> [   10.173632] Bluetooth: HCI socket layer initialized
> [   10.185298] pnp: 00:01: iomem range 0xe0000000-0xefffffff could not be 
> reserved
> [   10.185442] pnp: 00:01: iomem range 0xfec00000-0xfec00fff could not be 
> reserved
> [   10.185585] pnp: 00:01: iomem range 0xfee00000-0xfee00fff could not be 
> reserved
> [   10.185734] pnp: 00:08: ioport range 0x1080-0x1080 has been reserved
> [   10.185828] pnp: 00:08: ioport range 0x220-0x22f has been reserved
> [   10.185925] pnp: 00:09: iomem range 0xe0000-0xfffff could not be reserved
> [   10.186020] pnp: 00:09: iomem range 0xfff00000-0xffffffff could not be 
> reserved
> [   10.186161] pnp: 00:09: iomem range 0x0-0xfff could not be reserved
> [   10.186765] ACPI: PCI Interrupt 0000:08:09.1[B] -> GSI 21 (level, low) -> 
> IRQ 21
> [   10.237089] ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[21]  
> MMIO=[d0315000-d03157ff]  Max Packet=[2048]  IR/IT contexts=[4/8]
> [   10.237361] PCI: Bridge: 0000:00:01.0
> [   10.237454]   IO window: 9000-9fff
> [   10.237545]   MEM window: d0100000-d01fffff
> [   10.237637]   PREFETCH window: d4000000-d7ffffff
> [   10.237729] PCI: Bridge: 0000:00:04.0
> [   10.239481]   IO window: disabled.
> [   10.239572]   MEM window: disabled.
> [   10.239665]   PREFETCH window: disabled.
> [   10.239756] PCI: Bridge: 0000:00:05.0
> [   10.239848]   IO window: disabled.
> [   10.239939]   MEM window: disabled.
> [   10.240031]   PREFETCH window: disabled.
> [   10.240123] PCI: Bridge: 0000:00:06.0
> [   10.240211]   IO window: disabled.
> [   10.240300]   MEM window: disabled.
> [   10.240392]   PREFETCH window: disabled.
> [   10.240484] PCI: Bridge: 0000:00:07.0
> [   10.240575]   IO window: disabled.
> [   10.240667]   MEM window: d0200000-d02fffff
> [   10.240759]   PREFETCH window: d8000000-d80fffff
> [   10.240852] Time: acpi_pm clocksource has been installed.
> [   10.240950] PCI: Bus 9, cardbus bridge: 0000:08:09.0
> [   10.241042]   IO window: 00002000-000020ff
> [   10.241137]   IO window: 00002400-000024ff
> [   10.241231]   PREFETCH window: 88000000-8bffffff
> [   10.241323]   MEM window: 90000000-93ffffff
> [   10.241419] PCI: Bridge: 0000:00:14.4
> [   10.241513]   IO window: 2000-2fff
> [   10.241609]   MEM window: d0300000-d03fffff
> [   10.241703]   PREFETCH window: 88000000-8bffffff
> [   10.241810] PCI: Setting latency timer of device 0000:00:04.0 to 64
> [   10.241817] PCI: Setting latency timer of device 0000:00:05.0 to 64
> [   10.241823] PCI: Setting latency timer of device 0000:00:06.0 to 64
> [   10.241829] PCI: Enabling device 0000:00:07.0 (0000 -> 0002)
> [   10.241924] PCI: Setting latency timer of device 0000:00:07.0 to 64
> [   10.241946] PCI: Enabling device 0000:08:09.0 (0000 -> 0003)
> [   10.242044] ACPI: PCI Interrupt 0000:08:09.0[A] -> GSI 20 (level, low) -> 
> IRQ 20
> [   10.242307] NET: Registered protocol family 2
> [   10.285199] IP route cache hash table entries: 65536 (order: 7, 524288 
> bytes)
> [   10.286364] TCP established hash table entries: 262144 (order: 10, 6291456 
> bytes)
> [   10.289863] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
> [   10.290582] TCP: Hash tables configured (established 262144 bind 65536)
> [   10.290680] TCP reno registered
> [   10.305240] Unpacking initramfs... done
> [   10.417950] Freeing initrd memory: 3003k freed
> [   10.419932] Simple Boot Flag at 0x36 set to 0x1
> [   10.424565] NTFS driver 2.1.28 [Flags: R/W].
> [   10.424877] io scheduler noop registered
> [   10.425084] io scheduler cfq registered (default)
> [   10.425183] PCI: MSI quirk detected. MSI deactivated.
> [   10.425365] Boot video device is 0000:01:05.0
> [   10.425520] ACPI: PCI Interrupt 0000:01:05.0[A] -> GSI 17 (level, low) -> 
> IRQ 17
> [   10.425715] radeonfb (0000:01:05.0): cannot map FB
> [   10.425818] radeonfb: probe of 0000:01:05.0 failed with error -5
> [   10.427811] ACPI: AC Adapter [ACAD] (on-line)
> [   10.428003] ACPI: Battery Slot [BAT1] (battery absent)
> [   10.428233] input: Power Button (FF) as /devices/virtual/input/input0
> [   10.428328] ACPI: Power Button (FF) [PWRF]
> [   10.428516] input: Power Button (CM) as /devices/virtual/input/input1
> [   10.428609] ACPI: Power Button (CM) [PWRB]
> [   10.428797] input: Lid Switch as /devices/virtual/input/input2
> [   10.428890] ACPI: Lid Switch [LID]
> [   10.429061] input: Sleep Button (CM) as /devices/virtual/input/input3
> [   10.429155] ACPI: Sleep Button (CM) [SLPB]
> [   10.435776] ACPI: Thermal Zone [THRM] (59 C)
> [   10.438426] Real Time Clock Driver v1.12ac
> [   10.438651] Non-volatile memory driver v1.2
> [   10.438767] Linux agpgart interface v0.102
> [   10.438859] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ 
> sharing disabled
> [   10.439686] loop: module loaded
> [   10.439837] ACPI: PCI Interrupt 0000:08:09.2[A] -> GSI 20 (level, low) -> 
> IRQ 20
> [   10.440089] Intel(R) PRO/1000 Network Driver - version 7.3.20-k2
> [   10.440187] Copyright (c) 1999-2006 Intel Corporation.
> [   10.440323] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
> [   10.440416] e100: Copyright(c) 1999-2006 Intel Corporation
> [   10.440678] tg3.c:v3.79 (July 18, 2007)
> [   10.440794] ACPI: PCI Interrupt 0000:08:04.0[A] -> GSI 22 (level, low) -> 
> IRQ 22
> [   10.460548] tifm_core: MMC/SD card detected in socket 0:1
> [   10.482662] eth0: Tigon3 [partno(BCM95788) rev 3003 PHY(5705)] 
> (PCI:33MHz:32-bit) 10/100/1000Base-T Ethernet 00:16:36:d0:6b:85
> [   10.483042] eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] 
> TSOcap[1]
> [   10.483185] eth0: dma_rwctrl[763f0000] dma_mask[32-bit]
> [   10.483458] forcedeth.c: Reverse Engineered nForce ethernet driver. Version 
> 0.60.
> [   10.483639] tun: Universal TUN/TAP device driver, 1.6
> [   10.483732] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
> [   10.483904] bcm43xx driver
> [   10.484034] netconsole: not configured, aborting
> [   10.484127] Linux video capture interface: v2.00
> [   10.484653] sata_sil 0000:00:12.0: version 2.2
> [   10.484702] PCI: Enabling device 0000:00:12.0 (0005 -> 0007)
> [   10.484798] ACPI: PCI Interrupt 0000:00:12.0[A] -> GSI 22 (level, low) -> 
> IRQ 22
> [   10.485079] scsi0 : sata_sil
> [   10.485240] scsi1 : sata_sil
> [   10.485381] ata1: SATA max UDMA/100 cmd 0xffffc20000338080 ctl 
> 0xffffc2000033808a bmdma 0xffffc20000338000 irq 22
> [   10.485526] ata2: SATA max UDMA/100 cmd 0xffffc200003380c0 ctl 
> 0xffffc200003380ca bmdma 0xffffc20000338008 irq 22
> [   10.952123] ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 310)
> [   10.960743] ata1.00: ATA-7: Hitachi HTS541616J9SA00, SB4OC70P, max UDMA/100
> [   10.960837] ata1.00: 312581808 sectors, multi 16: LBA48 NCQ (not used)
> [   10.976713] ata1.00: configured for UDMA/100
> [   11.287593] ata2: SATA link down (SStatus 0 SControl 310)
> [   11.287777] scsi 0:0:0:0: Direct-Access     ATA      Hitachi HTS54161 SB4O 
> PQ: 0 ANSI: 5
> [   11.288015] sd 0:0:0:0: [sda] 312581808 512-byte hardware sectors (160042 
> MB)
> [   11.288119] sd 0:0:0:0: [sda] Write Protect is off
> [   11.288211] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> [   11.288229] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, 
> doesn't support DPO or FUA
> [   11.288414] sd 0:0:0:0: [sda] 312581808 512-byte hardware sectors (160042 
> MB)
> [   11.288517] sd 0:0:0:0: [sda] Write Protect is off
> [   11.288608] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> [   11.288624] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, 
> doesn't support DPO or FUA
> [   11.288769]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 sda8 >
> [   11.376058] sd 0:0:0:0: [sda] Attached SCSI disk
> [   11.376218] sd 0:0:0:0: Attached scsi generic sg0 type 0
> [   11.376469] PCI: Enabling device 0000:00:14.1 (0014 -> 0015)
> [   11.376566] ACPI: PCI Interrupt 0000:00:14.1[A] -> GSI 16 (level, low) -> 
> IRQ 16
> [   11.376792] PCI: Setting latency timer of device 0000:00:14.1 to 64
> [   11.376854] scsi2 : pata_atiixp
> [   11.377011] scsi3 : pata_atiixp
> [   11.377145] ata3: PATA max UDMA/100 cmd 0x00000000000101f0 ctl 
> 0x00000000000103f6 bmdma 0x0000000000018460 irq 14
> [   11.377290] ata4: PATA max UDMA/100 cmd 0x0000000000010170 ctl 
> 0x0000000000010376 bmdma 0x0000000000018468 irq 15
> [   11.377454] ata3: port disabled. ignoring.
> [   11.507405] ieee1394: Host added: ID:BUS[0-00:1023]  GUID[00c09f0000dc3542]
> [   11.531280] Fusion MPT base driver 3.04.05
> [   11.531373] Copyright (c) 1999-2007 LSI Logic Corporation
> [   11.531469] Fusion MPT SAS Host driver 3.04.05
> [   11.531673] video1394: Installed video1394 module
> [   11.531799] ieee1394: raw1394: /dev/raw1394 device initialized
> [   11.531950] usbmon: debugfs is not available
> [   11.532091] ACPI: PCI Interrupt 0000:00:13.2[A] -> GSI 19 (level, low) -> 
> IRQ 19
> [   11.532289] ehci_hcd 0000:00:13.2: EHCI Host Controller
> [   11.532439] ehci_hcd 0000:00:13.2: new USB bus registered, assigned bus 
> number 1
> [   11.532635] ehci_hcd 0000:00:13.2: irq 19, io mem 0xd0007000
> [   11.532740] ehci_hcd 0000:00:13.2: USB 2.0 started, EHCI 1.00, driver 10 
> Dec 2004
> [   11.533073] usb usb1: configuration #1 chosen from 1 choice
> [   11.533211] hub 1-0:1.0: USB hub found
> [   11.533310] hub 1-0:1.0: 8 ports detected
> [   11.635127] ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) 
> Driver
> [   11.635169] ACPI: PCI Interrupt 0000:00:13.0[A] -> GSI 19 (level, low) -> 
> IRQ 19
> [   11.635363] ohci_hcd 0000:00:13.0: OHCI Host Controller
> [   11.635493] ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus 
> number 2
> [   11.635647] ohci_hcd 0000:00:13.0: irq 19, io mem 0xd0005000
> [   11.691108] usb usb2: configuration #1 chosen from 1 choice
> [   11.691241] hub 2-0:1.0: USB hub found
> [   11.691343] hub 2-0:1.0: 4 ports detected
> [   11.794883] ACPI: PCI Interrupt 0000:00:13.1[A] -> GSI 19 (level, low) -> 
> IRQ 19
> [   11.795077] ohci_hcd 0000:00:13.1: OHCI Host Controller
> [   11.795206] ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus 
> number 3
> [   11.795359] ohci_hcd 0000:00:13.1: irq 19, io mem 0xd0006000
> [   11.850887] usb usb3: configuration #1 chosen from 1 choice
> [   11.851018] hub 3-0:1.0: USB hub found
> [   11.851120] hub 3-0:1.0: 4 ports detected
> [   11.874713] usb 1-7: new high speed USB device using ehci_hcd and address 2
> [   12.047389] usb 1-7: configuration #1 chosen from 1 choice
> [   12.589616] usb 3-4: new full speed USB device using ohci_hcd and address 2
> [   12.802424] usb 3-4: configuration #1 chosen from 1 choice
> [   12.804820] usbcore: registered new interface driver usblp
> [   12.804914] Initializing USB Mass Storage driver...
> [   12.805058] usbcore: registered new interface driver usb-storage
> [   12.805151] USB Mass Storage support registered.
> [   12.805331] PNP: PS/2 Controller [PNP0303:KBC0,PNP0f13:MSE0] at 0x60,0x64 
> irq 1,12
> [   12.807490] i8042.c: Detected active multiplexing controller, rev 1.1.
> [   12.810494] serio: i8042 KBD port at 0x60,0x64 irq 1
> [   12.810591] serio: i8042 AUX0 port at 0x60,0x64 irq 12
> [   12.810687] serio: i8042 AUX1 port at 0x60,0x64 irq 12
> [   12.810782] serio: i8042 AUX2 port at 0x60,0x64 irq 12
> [   12.810875] serio: i8042 AUX3 port at 0x60,0x64 irq 12
> [   12.811030] mice: PS/2 mouse device common for all mice
> [   12.843496] input: AT Translated Set 2 keyboard 
> as /devices/platform/i8042/serio0/input/input4
> [   12.979654] md: raid0 personality registered for level 0
> [   12.979755] md: raid1 personality registered for level 1
> [   12.979850] Bluetooth: HCI USB driver ver 2.9
> [   12.980065] usbcore: registered new interface driver hci_usb
> [   13.036963] usbcore: registered new interface driver usbhid
> [   13.037058] /home/joachim/kernel/2.6-git/drivers/hid/usbhid/hid-core.c: 
> v2.6:USB HID core driver
> [   13.037237] Advanced Linux Sound Architecture Driver Version 1.0.14 (Fri 
> Jul 20 09:12:58 2007 UTC).
> [   13.037491] ACPI: PCI Interrupt 0000:00:14.2[A] -> GSI 16 (level, low) -> 
> IRQ 16
> [   13.109129] ALSA device list:
> [   13.109242]   #0: HDA ATI SB at 0xd0000000 irq 16
> [   13.109404] oprofile: using NMI interrupt.
> [   13.109565] IPv4 over IPv4 tunneling driver
> [   13.109778] TCP cubic registered
> [   13.109886] Initializing XFRM netlink socket
> [   13.109994] NET: Registered protocol family 1
> [   13.110088] NET: Registered protocol family 17
> [   13.110182] NET: Registered protocol family 15
> [   13.110282] Bluetooth: L2CAP ver 2.8
> [   13.110374] Bluetooth: L2CAP socket layer initialized
> [   13.110479] Bluetooth: SCO (Voice Link) ver 0.5
> [   13.110571] Bluetooth: SCO socket layer initialized
> [   13.110690] Bluetooth: RFCOMM socket layer initialized
> [   13.110781] Bluetooth: RFCOMM ver 1.8
> [   13.110872] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
> [   13.111064] ieee80211: 802.11 data/management/control stack, git-1.1.13
> [   13.111162] ieee80211: Copyright (C) 2004-2005 Intel Corporation 
> <jketreno@linux.intel.com>
> [   13.111306] ieee80211_crypt: registered algorithm 'NULL'
> [   13.111308] ieee80211_crypt: registered algorithm 'WEP'
> [   13.111310] ieee80211_crypt: registered algorithm 'CCMP'
> [   13.111401] powernow-k8: Found 1 AMD Turion(tm) 64 X2 Mobile Technology 
> TL-56 processors (2 cpu cores) (version 2.00.00)
> [   13.111517] powernow-k8:    0 : fid 0xa (1800 MHz), vid 0x13
> [   13.111613] powernow-k8:    1 : fid 0x8 (1600 MHz), vid 0x15
> [   13.111706] powernow-k8:    2 : fid 0x0 (800 MHz), vid 0x1e
> [   13.112312] Freeing unused kernel memory: 316k freed
> [   13.376787] mmc0: new SD card at address b3df
> [   13.379000] mmcblk0: mmc0:b3df SD256 249088KiB 
> [   13.379138]  mmcblk0: p1
> [   13.701868] Synaptics Touchpad, model: 1, fw: 5.10, id: 0x258eb1, caps: 
> 0xa04713/0x0
> [   13.748179] input: SynPS/2 Synaptics TouchPad 
> as /devices/platform/i8042/serio4/input/input5
> [   13.803993] swsusp: Marking nosave pages: 000000000009d000 - 
> 0000000000100000
> [   13.804000] swsusp: Basic memory bitmaps created
> [   13.831072] swsusp: Basic memory bitmaps freed
> [   13.848203] Attempting manual resume
> [   14.229088] kjournald starting.  Commit interval 5 seconds
> [   14.229210] EXT3 FS on sda6, internal journal
> [   14.229345] EXT3-fs: mounted filesystem with ordered data mode.
> [   18.266036] Adding 3148700k swap on /dev/sda5.  Priority:-1 extents:1 
> across:3148700k
> [   18.390490] md: Autodetecting RAID arrays.
> [   18.390589] md: autorun ...
> [   18.390680] md: ... autorun DONE.
> [   19.440964] kjournald starting.  Commit interval 5 seconds
> [   19.441097] EXT3 FS on sda7, internal journal
> [   19.441231] EXT3-fs: mounted filesystem with ordered data mode.
> [   19.502969] NTFS volume version 3.1.
> [   19.503070] NTFS-fs warning (device sda2): load_system_files(): Volume is 
> dirty.  Will not be able to remount read-write.  Run chkdsk and mount in 
> Windows.
> [   33.416925] tg3: eth0: Link is up at 1000 Mbps, full duplex.
> [   33.416931] tg3: eth0: Flow control is on for TX and on for RX.
> [   34.800494] ACPI: EC: Handler for query 0x81 is not found!
> [   40.588481] Stopping tasks ... done.
> [   40.589928] Suspending console(s)
> [   41.223742] sd 0:0:0:0: [sda] Synchronizing SCSI cache
> [   41.223976] sd 0:0:0:0: [sda] Stopping disk
> [   41.707281] mmc0: card b3df removed
> [   41.707446] MMC: killing requests for dead queue
> [   41.707638] ACPI handle has no context!
> [   41.707658] ACPI: PCI interrupt for device 0000:08:09.2 disabled
> [   41.707665] ACPI handle has no context!
> [   41.720957] ACPI handle has no context!
> [   41.737176] ACPI: PCI interrupt for device 0000:00:14.2 disabled
> [   41.752920] ACPI: PCI interrupt for device 0000:00:14.1 disabled
> [   41.753010] ACPI: PCI interrupt for device 0000:00:13.2 disabled
> [   41.768858] ACPI: PCI interrupt for device 0000:00:13.1 disabled
> [   41.768894] ACPI: PCI interrupt for device 0000:00:13.0 disabled
> [   41.768978] ACPI: PCI interrupt for device 0000:00:12.0 disabled
> [   41.785175] Disabling non-boot CPUs ...
> [   41.801866] Broke affinity for irq 1
> [   41.801881] Broke affinity for irq 9
> [   41.801917] Broke affinity for irq 22
> [   41.904558] CPU 1 is now offline
> [   41.904561] SMP alternatives: switching to UP code
> [   41.906395] CPU1 is down
> [    0.360942] Back to C!
> [    0.361327] Enabling non-boot CPUs ...
> [    0.381083] SMP alternatives: switching to SMP code
> [    0.382068] Booting processor 1/2 APIC 0x1
> [    0.392138] Initializing CPU#1
> [    0.472858] Calibrating delay using timer specific routine.. 3600.39 
> BogoMIPS (lpj=7200794)
> [    0.472865] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 
> bytes/line)
> [    0.472867] CPU: L2 Cache: 512K (64 bytes/line)
> [    0.472870] CPU 1/1 -> Node 0
> [    0.472872] CPU: Physical Processor ID: 0
> [    0.472873] CPU: Processor Core ID: 1
> [    0.472956] AMD Turion(tm) 64 X2 Mobile Technology TL-56 stepping 02
> [    0.477189] CPU1 is up
> [    0.479439] PM: Writing back config space on device 0000:00:00.0 at offset 
> 3 (was 0, writing 4000)
> [    0.479449] PM: Writing back config space on device 0000:00:01.0 at offset 
> 9 (was 10001, writing d7f1d401)
> [    0.479454] PM: Writing back config space on device 0000:00:01.0 at offset 
> 7 (was 22209191, writing 2209191)
> [    0.479470] PM: Writing back config space on device 0000:00:04.0 at offset 
> 9 (was 10001, writing 1fff1)
> [    0.479473] PM: Writing back config space on device 0000:00:04.0 at offset 
> 8 (was 0, writing fff0)
> [    0.479477] PM: Writing back config space on device 0000:00:04.0 at offset 
> 7 (was 101, writing 1f1)
> [    0.479480] PM: Writing back config space on device 0000:00:04.0 at offset 
> 6 (was 0, writing 20200)
> [    0.479485] PM: Writing back config space on device 0000:00:04.0 at offset 
> 1 (was 100000, writing 100004)
> [    0.479498] PCI: Setting latency timer of device 0000:00:04.0 to 64
> [    0.479505] PM: Writing back config space on device 0000:00:05.0 at offset 
> 9 (was 10001, writing 1fff1)
> [    0.479509] PM: Writing back config space on device 0000:00:05.0 at offset 
> 8 (was 0, writing fff0)
> [    0.479512] PM: Writing back config space on device 0000:00:05.0 at offset 
> 7 (was 101, writing 1f1)
> [    0.479517] PM: Writing back config space on device 0000:00:05.0 at offset 
> 1 (was 100000, writing 100004)
> [    0.479528] PCI: Setting latency timer of device 0000:00:05.0 to 64
> [    0.479535] PM: Writing back config space on device 0000:00:06.0 at offset 
> 9 (was 10001, writing 1fff1)
> [    0.479539] PM: Writing back config space on device 0000:00:06.0 at offset 
> 8 (was 0, writing fff0)
> [    0.479542] PM: Writing back config space on device 0000:00:06.0 at offset 
> 7 (was 101, writing 1f1)
> [    0.479546] PM: Writing back config space on device 0000:00:06.0 at offset 
> 6 (was 0, writing 60600)
> [    0.479550] PM: Writing back config space on device 0000:00:06.0 at offset 
> 1 (was 100000, writing 100004)
> [    0.479561] PCI: Setting latency timer of device 0000:00:06.0 to 64
> [    0.479569] PM: Writing back config space on device 0000:00:07.0 at offset 
> 9 (was 10001, writing d801d801)
> [    0.479572] PM: Writing back config space on device 0000:00:07.0 at offset 
> 8 (was 0, writing d020d020)
> [    0.479576] PM: Writing back config space on device 0000:00:07.0 at offset 
> 7 (was 101, writing 200001f1)
> [    0.479579] PM: Writing back config space on device 0000:00:07.0 at offset 
> 6 (was 0, writing 70700)
> [    0.479584] PM: Writing back config space on device 0000:00:07.0 at offset 
> 1 (was 100000, writing 100006)
> [    0.479595] PCI: Setting latency timer of device 0000:00:07.0 to 64
> [    0.496881] ACPI: PCI Interrupt 0000:00:12.0[A] -> GSI 22 (level, low) -> 
> IRQ 22
> [    0.496902] ACPI: PCI Interrupt 0000:00:13.0[A] -> GSI 19 (level, low) -> 
> IRQ 19
> [    0.496946] PM: Writing back config space on device 0000:00:13.0 at offset 
> 3 (was 804008, writing 804010)
> [    0.496961] ACPI: PCI Interrupt 0000:00:13.1[A] -> GSI 19 (level, low) -> 
> IRQ 19
> [    0.512807] ACPI: PCI Interrupt 0000:00:13.2[A] -> GSI 19 (level, low) -> 
> IRQ 19
> [    0.512927] PM: Writing back config space on device 0000:00:14.1 at offset 
> f (was 100, writing 10b)
> [    0.512942] PM: Writing back config space on device 0000:00:14.1 at offset 
> 8 (was 1, writing 8461)
> [    0.512948] PM: Writing back config space on device 0000:00:14.1 at offset 
> 7 (was 1, writing 8471)
> [    0.512953] PM: Writing back config space on device 0000:00:14.1 at offset 
> 6 (was 1, writing 8479)
> [    0.512959] PM: Writing back config space on device 0000:00:14.1 at offset 
> 5 (was 1, writing 8475)
> [    0.512965] PM: Writing back config space on device 0000:00:14.1 at offset 
> 4 (was 1, writing 8481)
> [    0.512971] PM: Writing back config space on device 0000:00:14.1 at offset 
> 3 (was 0, writing 4000)
> [    0.512976] PM: Writing back config space on device 0000:00:14.1 at offset 
> 2 (was 1018280, writing 1018080)
> [    0.512982] PM: Writing back config space on device 0000:00:14.1 at offset 
> 1 (was 2300000, writing 2300015)
> [    0.513002] ACPI: PCI Interrupt 0000:00:14.1[A] -> GSI 16 (level, low) -> 
> IRQ 16
> [    0.528794] PM: Writing back config space on device 0000:00:14.2 at offset 
> f (was 100, writing b)
> [    0.528816] PM: Writing back config space on device 0000:00:14.2 at offset 
> 4 (was 4, writing d0000004)
> [    0.528822] PM: Writing back config space on device 0000:00:14.2 at offset 
> 3 (was 0, writing 4008)
> [    0.528829] PM: Writing back config space on device 0000:00:14.2 at offset 
> 1 (was 4100000, writing 4100002)
> [    0.528850] ACPI: PCI Interrupt 0000:00:14.2[A] -> GSI 16 (level, low) -> 
> IRQ 16
> [    0.585029] PM: Writing back config space on device 0000:00:14.4 at offset 
> 9 (was 0, writing 8bf08800)
> [    0.585035] PM: Writing back config space on device 0000:00:14.4 at offset 
> 8 (was 0, writing d030d030)
> [    0.585041] PM: Writing back config space on device 0000:00:14.4 at offset 
> 7 (was 22801111, writing 22802121)
> [    0.585052] PM: Writing back config space on device 0000:00:14.4 at offset 
> 3 (was 810000, writing 814000)
> [    0.585059] PM: Writing back config space on device 0000:00:14.4 at offset 
> 1 (was 2a00021, writing 2a00007)
> [    0.585114] ACPI: PCI Interrupt 0000:01:05.0[A] -> GSI 17 (level, low) -> 
> IRQ 17
> [    0.585132] PM: Writing back config space on device 0000:07:00.0 at offset 
> f (was 100, writing 10b)
> [    0.585151] PM: Writing back config space on device 0000:07:00.0 at offset 
> 6 (was c, writing d800000c)
> [    0.585157] PM: Writing back config space on device 0000:07:00.0 at offset 
> 4 (was 4, writing d0200004)
> [    0.585194] PM: Writing back config space on device 0000:08:09.0 at offset 
> f (was c001ff, writing 1c0010b)
> [    0.585200] PM: Writing back config space on device 0000:08:09.0 at offset 
> e (was 0, writing 24fc)
> [    0.585207] PM: Writing back config space on device 0000:08:09.0 at offset 
> d (was 0, writing 2400)
> [    0.585215] PM: Writing back config space on device 0000:08:09.0 at offset 
> c (was 0, writing 20fc)
> [    0.585221] PM: Writing back config space on device 0000:08:09.0 at offset 
> b (was 0, writing 2000)
> [    0.585227] PM: Writing back config space on device 0000:08:09.0 at offset 
> a (was 0, writing 93fff000)
> [    0.585236] PM: Writing back config space on device 0000:08:09.0 at offset 
> 9 (was 0, writing 90000000)
> [    0.585242] PM: Writing back config space on device 0000:08:09.0 at offset 
> 8 (was 0, writing 8bfff000)
> [    0.585249] PM: Writing back config space on device 0000:08:09.0 at offset 
> 7 (was 0, writing 88000000)
> [    0.585257] PM: Writing back config space on device 0000:08:09.0 at offset 
> 6 (was 0, writing b00c0908)
> [    0.585265] PM: Writing back config space on device 0000:08:09.0 at offset 
> 4 (was 0, writing d0314000)
> [    0.585273] PM: Writing back config space on device 0000:08:09.0 at offset 
> 3 (was 820000, writing 824008)
> [    0.585281] PM: Writing back config space on device 0000:08:09.0 at offset 
> 1 (was 2100000, writing 2100007)
> [    0.585313] ACPI: PCI Interrupt 0000:08:09.0[A] -> GSI 20 (level, low) -> 
> IRQ 20
> [    0.600687] PM: Writing back config space on device 0000:08:09.1 at offset 
> f (was 4030200, writing 403020b)
> [    0.600711] PM: Writing back config space on device 0000:08:09.1 at offset 
> 5 (was 0, writing d0310000)
> [    0.600718] PM: Writing back config space on device 0000:08:09.1 at offset 
> 4 (was 0, writing d0315000)
> [    0.600725] PM: Writing back config space on device 0000:08:09.1 at offset 
> 3 (was 800000, writing 804008)
> [    0.600735] PM: Writing back config space on device 0000:08:09.1 at offset 
> 1 (was 2100000, writing 2100016)
> [    0.650712] ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[21]  
> MMIO=[d0315000-d03157ff]  Max Packet=[2048]  IR/IT contexts=[4/8]
> [    0.664592] PM: Writing back config space on device 0000:08:09.2 at offset 
> f (was 40701ff, writing 407010b)
> [    0.664618] PM: Writing back config space on device 0000:08:09.2 at offset 
> 4 (was 0, writing d0316000)
> [    0.664625] PM: Writing back config space on device 0000:08:09.2 at offset 
> 3 (was 800000, writing 804008)
> [    0.664633] PM: Writing back config space on device 0000:08:09.2 at offset 
> 1 (was 2100000, writing 2100006)
> [    0.664656] ACPI: PCI Interrupt 0000:08:09.2[A] -> GSI 20 (level, low) -> 
> IRQ 20
> [    0.733792] ACPI: EC: Handler for query 0x80 is not found!
> [    0.752456] sd 0:0:0:0: [sda] Starting disk
> [    0.820363] ata2: SATA link down (SStatus 0 SControl 310)
> [    1.087869] mmc0: new SD card at address b3df
> [    1.087973] mmcblk0: mmc0:b3df SD256 249088KiB 
> [    1.088001]  mmcblk0: p1
> [    1.739362] ACPI: EC: Handler for query 0x80 is not found!
> [    3.716115] ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 310)
> [    3.744731] ata1.00: configured for UDMA/100
> [    3.761238] sd 0:0:0:0: [sda] 312581808 512-byte hardware sectors (160042 
> MB)
> [    3.761253] sd 0:0:0:0: [sda] Write Protect is off
> [    3.761256] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> [    3.761275] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, 
> doesn't support DPO or FUA
> [    4.701254] Restarting tasks ... <6>usb 1-7: USB disconnect, address 2
> [    4.707688] done.
> [    4.812091] usb 1-7: new high speed USB device using ehci_hcd and address 4
> [    4.865420] ACPI: EC: Handler for query 0x80 is not found!
> [    4.985101] usb 1-7: configuration #1 chosen from 1 choice
> [    6.302539] ACPI: EC: Handler for query 0x80 is not found!
> [    6.754133] tg3: eth0: No firmware running.
> [    6.816140] tg3: tg3_load_tso_firmware fails for eth0 to set CPU PC, is 
> ffffffff should be 00010000
> [    7.285797] ACPI: EC: Handler for query 0x80 is not found!
> [    8.016223] tg3: tg3_abort_hw timed out for eth0, TX_MODE_ENABLE will not 
> clear MAC_TX_MODE=ffffffff
> [    8.291669] ACPI: EC: Handler for query 0x80 is not found!
> [    9.296809] ACPI: EC: Handler for query 0x80 is not found!
> [    9.940778] usb 3-4: USB disconnect, address 2
> [   10.282030] ACPI: EC: Handler for query 0x81 is not found!
> [   10.367084] usb 3-4: new full speed USB device using ohci_hcd and address 3
> [   10.462150] usb 3-4: configuration #1 chosen from 1 choice
> [   10.727884] ACPI: EC: Handler for query 0x81 is not found!
> [   11.173888] ACPI: EC: Handler for query 0x81 is not found!
> [   12.512423] ACPI: EC: Handler for query 0x81 is not found!
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
