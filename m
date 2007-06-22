From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Fri, 22 Jun 2007 10:56:44 +0200
Message-ID: <4bacf17f0706220156j63c4ec4ah75ac13ba653a3e67@mail.gmail.com>
References: <4bacf17f0706161435g1bb7c08bpd427901f64d57fa@mail.gmail.com>
	 <20070618110849.GA2450@ff.dom.local>
	 <20070618081000.14da5186@localhost.localdomain>
	 <20070619055007.GB1649@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070619055007.GB1649@ff.dom.local>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/6/19, Jarek Poplawski <jarkao2@o2.pl>:
> On Mon, Jun 18, 2007 at 08:10:00AM -0700, Stephen Hemminger wrote:
> > On Mon, 18 Jun 2007 13:08:49 +0200
> > Jarek Poplawski <jarkao2@o2.pl> wrote:
> >
> > > On 16-06-2007 23:35, Marcin .lusarz wrote:
> > > > hi
> > > > after upgrading kernel from 2.6.20 to 2.6.21.3 i'm experiencing really
> > > > strange problem - my _both_ network cards dies after random uptime -
> > > > sometimes it's a few minutes, sometimes hours, sometimes it does not
> > > > happen for a couple of days...
> > > > today it happened for the first time without nvidia module and almost
> > > > immediately after system start
> > > >
> > > > here is the output of some commands which might help debug this:
> ...
> > > It looks like skge driver enables different device than probbed.
> > > Maybe you've something old/wrong about eth0/eth1 in /etc configs?
> >
> > More likely it is just user level device renaming. Most distro's
> > rename devices (if needed) using udev.
>
> On the other hand it's interesting, why it's not always, and why
> sometimes it took so long?

I'm sorry for delay, but i was offline for the last week and probably
will for some time :|

When I disable on-board network card in BIOS (controlled by skge)
ne2k-pci card is still locking up. So I think it's strictly ne2k-pci
card bug. I made some tests and I know how to reproduce it fast (on my
machine) - just make some heavy network traffic...

As I'm offline right now I can't bisect it, but i turned on more
debugging, maybe you can deduce something...

[    0.000000] Linux version 2.6.21.3 (root@joi) (gcc version 4.1.2
(Gentoo 4.1.2)) #4 PREEMPT Wed Jun 20 22:37:05 CEST 2007
[    0.000000] Command line: root=/dev/sda5 video=vesafb vga=794
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003ffb0000 (usable)
[    0.000000]  BIOS-e820: 000000003ffb0000 - 000000003ffc0000 (ACPI data)
[    0.000000]  BIOS-e820: 000000003ffc0000 - 000000003fff0000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003fff0000 - 0000000040000000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff780000 - 0000000100000000 (reserved)
[    0.000000] Entering add_active_range(0, 0, 159) 0 entries of 256 used
[    0.000000] Entering add_active_range(0, 256, 262064) 1 entries of 256 used
[    0.000000] end_pfn_map = 1048576
[    0.000000] DMI 2.3 present.
[    0.000000] ACPI: RSDP 000FA810, 0021 (r2 ACPIAM)
[    0.000000] ACPI: XSDT 3FFB0100, 003C (r1 A M I  OEMXSDT  10000427
MSFT       97)
[    0.000000] ACPI: FACP 3FFB0290, 00F4 (r3 A M I  OEMFACP  10000427
MSFT       97)
[    0.000000] ACPI: DSDT 3FFB03E0, 38A1 (r1  A0036 A0036001        1
MSFT  100000D)
[    0.000000] ACPI: FACS 3FFC0000, 0040
[    0.000000] ACPI: APIC 3FFB0390, 004A (r1 A M I  OEMAPIC  10000427
MSFT       97)
[    0.000000] ACPI: OEMB 3FFC0040, 003F (r1 A M I  OEMBIOS  10000427
MSFT       97)
[    0.000000] Entering add_active_range(0, 0, 159) 0 entries of 256 used
[    0.000000] Entering add_active_range(0, 256, 262064) 1 entries of 256 used
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   262064
[    0.000000] On node 0 totalpages: 261967
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 2549 pages reserved
[    0.000000]   DMA zone: 1394 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 3526 pages used for memmap
[    0.000000]   DMA32 zone: 254442 pages, LIFO batch:31
[    0.000000]   Normal zone: 0 pages used for memmap
[    0.000000] Looks like a VIA chipset. Disabling IOMMU. Override
with iommu=allowed
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] Processor #0 (Bootup-CPU)
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Setting APIC routing to flat
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] Nosave address range: 000000000009f000 - 00000000000a0000
[    0.000000] Nosave address range: 00000000000a0000 - 00000000000e4000
[    0.000000] Nosave address range: 00000000000e4000 - 0000000000100000
[    0.000000] Allocating PCI resources starting at 50000000 (gap:
40000000:bf780000)
[    0.000000] Built 1 zonelists.  Total pages: 255836
[    0.000000] Kernel command line: root=/dev/sda5 video=vesafb vga=794
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[    0.000000] Extended CMOS year: 2000
[   26.044738] time.c: Detected 2002.658 MHz processor.
[   26.044799] Console: colour dummy device 80x25
[   26.044856] Lock dependency validator: Copyright (c) 2006 Red Hat,
Inc., Ingo Molnar
[   26.044860] ... MAX_LOCKDEP_SUBCLASSES:    8
[   26.044863] ... MAX_LOCK_DEPTH:          30
[   26.044866] ... MAX_LOCKDEP_KEYS:        2048
[   26.044868] ... CLASSHASH_SIZE:           1024
[   26.044871] ... MAX_LOCKDEP_ENTRIES:     8192
[   26.044874] ... MAX_LOCKDEP_CHAINS:      16384
[   26.044876] ... CHAINHASH_SIZE:          8192
[   26.044879]  memory used by lock dependency info: 1648 kB
[   26.044882]  per task-struct memory footprint: 1680 bytes
[   26.045542] Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
[   26.046642] Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
[   26.058847] Memory: 1021348k/1048256k available (3717k kernel code,
26216k reserved, 1875k data, 224k init)
[   26.118666] Calibrating delay using timer specific routine..
4008.70 BogoMIPS (lpj=2004351)
[   26.118841] Mount-cache hash table entries: 256
[   26.119520] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
[   26.119525] CPU: L2 Cache: 512K (64 bytes/line)
[   26.119537] CPU: AMD Athlon(tm) 64 Processor 3200+ stepping 00
[   26.119548] ACPI: Core revision 20070126
[   26.127970] Parsing all Control Methods:
[   26.128081] Table [DSDT](id 0001) - 543 Objects with 51 Devices 146
Methods 25 Regions
[   26.128087]  tbxface-0587 [02] tb_load_namespace     : ACPI Tables
successfully acquired
[   26.128311] evxfevnt-0091 [02] enable                : Transition
to ACPI mode successful
[   26.139359] Using local APIC timer interrupts.
[   26.189266] result 12516628
[   26.189268] Detected 12.516 MHz APIC timer.
[   26.190215] NET: Registered protocol family 16
[   26.190738] ACPI: bus type pci registered
[   26.190758] PCI: Using configuration type 1
[   26.197813] evgpeblk-0952 [04] ev_create_gpe_block   : GPE 00 to 0F
[_GPE] 2 regs on int 0x9
[   26.203204] evgpeblk-1049 [03] ev_initialize_gpe_bloc: Found 7
Wake, Enabled 0 Runtime GPEs in this block
[   26.203623] Completing Region/Field/Buffer/Package
initialization:..........................................................................................................................
[   26.213486] Initialized 24/25 Regions 44/44 Fields 41/41 Buffers
13/14 Packages (552 nodes)
[   26.213492] Initializing Device/Processor/Thermal objects by
executing _INI methods:
[   26.213537] Executed 0 _INI methods requiring 0 _STA executions
(examined 54 objects)
[   26.213622] ACPI: Interpreter enabled
[   26.213626] ACPI: (supports S0 S1 S3 S4 S5)
[   26.213712] ACPI: Using IOAPIC for interrupt routing
[   26.242059] ACPI: PCI Root Bridge [PCI0] (0000:00)
[   26.242108] PCI: Probing PCI hardware (bus 00)
[   26.242281] PCI: Scanning bus 0000:00
[   26.242339] PCI: Found 0000:00:00.0 [1106/0282] 000600 00
[   26.242377] PCI: Calling quirk ffffffff8051f880 for 0000:00:00.0
[   26.242405] PCI: Found 0000:00:00.1 [1106/1282] 000600 00
[   26.242440] PCI: Calling quirk ffffffff8051f880 for 0000:00:00.1
[   26.242467] PCI: Found 0000:00:00.2 [1106/2282] 000600 00
[   26.242503] PCI: Calling quirk ffffffff8051f880 for 0000:00:00.2
[   26.242530] PCI: Found 0000:00:00.3 [1106/3282] 000600 00
[   26.242571] PCI: Calling quirk ffffffff8051f880 for 0000:00:00.3
[   26.242598] PCI: Found 0000:00:00.4 [1106/4282] 000600 00
[   26.242634] PCI: Calling quirk ffffffff8051f880 for 0000:00:00.4
[   26.242663] PCI: Found 0000:00:00.7 [1106/7282] 000600 00
[   26.242698] PCI: Calling quirk ffffffff8051f880 for 0000:00:00.7
[   26.242731] PCI: Found 0000:00:01.0 [1106/b188] 000604 01
[   26.242749] PCI: Calling quirk ffffffff8051f880 for 0000:00:01.0
[   26.242789] PCI: Found 0000:00:0c.0 [11f6/1401] 000200 00
[   26.242832] PCI: Calling quirk ffffffff8051f880 for 0000:00:0c.0
[   26.242872] PCI: Found 0000:00:0d.0 [109e/036e] 000400 00
[   26.242913] PCI: Calling quirk ffffffff8051f880 for 0000:00:0d.0
[   26.242954] PCI: Found 0000:00:0d.1 [109e/0878] 000480 00
[   26.242994] PCI: Calling quirk ffffffff8051f880 for 0000:00:0d.1
[   26.243039] PCI: Found 0000:00:0f.0 [1106/3149] 000104 00
[   26.243083] PCI: Calling quirk ffffffff8051f880 for 0000:00:0f.0
[   26.243118] PCI: Found 0000:00:0f.1 [1106/0571] 000101 00
[   26.243163] PCI: Calling quirk ffffffff8051f880 for 0000:00:0f.1
[   26.243205] PCI: Found 0000:00:10.0 [1106/3038] 000c03 00
[   26.243246] PCI: Calling quirk ffffffff8051f880 for 0000:00:10.0
[   26.243284] PCI: Found 0000:00:10.1 [1106/3038] 000c03 00
[   26.243325] PCI: Calling quirk ffffffff8051f880 for 0000:00:10.1
[   26.243360] PCI: Found 0000:00:10.2 [1106/3038] 000c03 00
[   26.243401] PCI: Calling quirk ffffffff8051f880 for 0000:00:10.2
[   26.243436] PCI: Found 0000:00:10.3 [1106/3038] 000c03 00
[   26.243477] PCI: Calling quirk ffffffff8051f880 for 0000:00:10.3
[   26.243511] PCI: Found 0000:00:10.4 [1106/3104] 000c03 00
[   26.243579] PCI: Calling quirk ffffffff8051f880 for 0000:00:10.4
[   26.243618] PCI: Found 0000:00:11.0 [1106/3227] 000601 00
[   26.243660] PCI: Calling quirk ffffffff80409e90 for 0000:00:11.0
[   26.243666] PCI: enabled onboard AC97/MC97 devices
[   26.243671] PCI: Calling quirk ffffffff80409de0 for 0000:00:11.0
[   26.243675] PCI: Calling quirk ffffffff804090f0 for 0000:00:11.0
[   26.243678] PCI: Calling quirk ffffffff8051f880 for 0000:00:11.0
[   26.243718] PCI: Found 0000:00:11.5 [1106/3059] 000401 00
[   26.243762] PCI: Calling quirk ffffffff8051f880 for 0000:00:11.5
[   26.243797] PCI: Found 0000:00:11.6 [1106/3068] 000780 00
[   26.243841] PCI: Calling quirk ffffffff8051f880 for 0000:00:11.6
[   26.243877] PCI: Found 0000:00:18.0 [1022/1100] 000600 00
[   26.243898] PCI: Calling quirk ffffffff8051f880 for 0000:00:18.0
[   26.243922] PCI: Found 0000:00:18.1 [1022/1101] 000600 00
[   26.243944] PCI: Calling quirk ffffffff8051f880 for 0000:00:18.1
[   26.243968] PCI: Found 0000:00:18.2 [1022/1102] 000600 00
[   26.243990] PCI: Calling quirk ffffffff8051f880 for 0000:00:18.2
[   26.244013] PCI: Found 0000:00:18.3 [1022/1103] 000600 00
[   26.244035] PCI: Calling quirk ffffffff8051f880 for 0000:00:18.3
[   26.244050] PCI: Fixups for bus 0000:00
[   26.244054] PCI: Scanning behind PCI bridge 0000:00:01.0, config
010100, pass 0
[   26.244182] PCI: Scanning bus 0000:01
[   26.244213] PCI: Found 0000:01:00.0 [10de/0322] 000300 00
[   26.244245] PCI: Calling quirk ffffffff8051f880 for 0000:01:00.0
[   26.244250] Boot video device is 0000:01:00.0
[   26.244280] PCI: Fixups for bus 0000:01
[   26.244289] PCI: Bus scan for 0000:01 returning with max=01
[   26.244295] PCI: Scanning behind PCI bridge 0000:00:01.0, config
010100, pass 1
[   26.244305] PCI: Bus scan for 0000:00 returning with max=01
[   26.244318] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[   26.271155] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 10 *11 14 15)
[   26.271414] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 *10 11 14 15)
[   26.271674] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 7 10 11 14 15)
[   26.271910] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 10 11 14
15) *0, disabled.
[   26.272145] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 10 11 14
15) *0, disabled.
[   26.272381] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 10 11 14
15) *0, disabled.
[   26.272624] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 7 10 11 14
15) *0, disabled.
[   26.272869] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 7 10 11 14
15) *0, disabled.
[   26.273098] Linux Plug and Play Support v0.97 (c) Adam Belay
[   26.273140] pnp: PnP ACPI init
[   26.285974] pnp: PnP ACPI: found 15 devices
[   26.287356] SCSI subsystem initialized
[   26.287450] libata version 2.20 loaded.
[   26.287710] usbcore: registered new interface driver usbfs
[   26.287860] usbcore: registered new interface driver hub
[   26.288016] usbcore: registered new device driver usb
[   26.288228] PCI: Using ACPI for IRQ routing
[   26.288233] PCI: If a device doesn't work, try "pci=routeirq".  If
it helps, post a report
[   26.288627] agpgart: Detected AGP bridge 0
[   26.291744] agpgart: AGP aperture is 64M @ 0xe8000000
[   26.292009] pnp: 00:09: ioport range 0x680-0x6ff has been reserved
[   26.292016] pnp: 00:09: ioport range 0x290-0x297 has been reserved
[   26.292036] pnp: 00:0b: iomem range 0xfec00000-0xfec00fff has been reserved
[   26.292042] pnp: 00:0b: iomem range 0xfee00000-0xfee00fff could not
be reserved
[   26.292049] pnp: 00:0b: iomem range 0xfff80000-0xffffffff could not
be reserved
[   26.292064] pnp: 00:0e: iomem range 0x0-0x9ffff could not be reserved
[   26.292069] pnp: 00:0e: iomem range 0xc0000-0xdffff has been reserved
[   26.292074] pnp: 00:0e: iomem range 0xe0000-0xfffff could not be reserved
[   26.292080] pnp: 00:0e: iomem range 0x100000-0x3ffeffff could not be reserved
[   26.292513] Time: tsc clocksource has been installed.
[   26.293377]   got res [1000:10ff] bus [1000:10ff] flags 101 for BAR
0 of 0000:00:11.6
[   26.293383] PCI: moved device 0000:00:11.6 resource 0 (101) to 1000
[   26.293386] PCI: Bridge: 0000:00:01.0
[   26.293389]   IO window: disabled.
[   26.293395]   MEM window: faf00000-fbffffff
[   26.293401]   PREFETCH window: f0000000-f9ffffff
[   26.293420] PCI: Calling quirk ffffffff80409bd0 for 0000:00:01.0
[   26.293426] PCI: Setting latency timer of device 0000:00:01.0 to 64
[   26.293487] NET: Registered protocol family 2
[   26.301599] IP route cache hash table entries: 32768 (order: 6, 262144 bytes)
[   26.302033] TCP established hash table entries: 32768 (order: 9,
2621440 bytes)
[   26.304812] TCP bind hash table entries: 32768 (order: 9, 2621440 bytes)
[   26.308521] TCP: Hash tables configured (established 32768 bind 32768)
[   26.308552] TCP reno registered
[   26.314409] Total HugeTLB memory allocated, 0
[   26.315431] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   26.316913] NTFS driver 2.1.28 [Flags: R/W].
[   26.316969] fuse init (API version 7.8)
[   26.317480] io scheduler noop registered
[   26.317509] io scheduler cfq registered (default)
[   26.317516] PCI: Calling quirk ffffffff8040a780 for 0000:00:00.0
[   26.317520] PCI: Calling quirk ffffffff804b85d0 for 0000:00:00.0
[   26.317525] PCI: Calling quirk ffffffff8040a780 for 0000:00:00.1
[   26.317528] PCI: Calling quirk ffffffff804b85d0 for 0000:00:00.1
[   26.317532] PCI: Calling quirk ffffffff8040a780 for 0000:00:00.2
[   26.317535] PCI: Calling quirk ffffffff804b85d0 for 0000:00:00.2
[   26.317539] PCI: Calling quirk ffffffff8040a780 for 0000:00:00.3
[   26.317541] PCI: Calling quirk ffffffff804b85d0 for 0000:00:00.3
[   26.317545] PCI: Calling quirk ffffffff8040a780 for 0000:00:00.4
[   26.317548] PCI: Calling quirk ffffffff804b85d0 for 0000:00:00.4
[   26.317552] PCI: Calling quirk ffffffff8040a780 for 0000:00:00.7
[   26.317555] PCI: Calling quirk ffffffff804b85d0 for 0000:00:00.7
[   26.317559] PCI: Calling quirk ffffffff8040a780 for 0000:00:01.0
[   26.317562] PCI: Calling quirk ffffffff804b85d0 for 0000:00:01.0
[   26.317566] PCI: Calling quirk ffffffff8040a780 for 0000:00:0c.0
[   26.317569] PCI: Calling quirk ffffffff804b85d0 for 0000:00:0c.0
[   26.317572] PCI: Calling quirk ffffffff8040a780 for 0000:00:0d.0
[   26.317575] PCI: Calling quirk ffffffff804b85d0 for 0000:00:0d.0
[   26.317579] PCI: Calling quirk ffffffff8040a780 for 0000:00:0d.1
[   26.317582] PCI: Calling quirk ffffffff804b85d0 for 0000:00:0d.1
[   26.317586] PCI: Calling quirk ffffffff8040a780 for 0000:00:0f.0
[   26.317589] PCI: Calling quirk ffffffff804b85d0 for 0000:00:0f.0
[   26.317593] PCI: Calling quirk ffffffff8040a780 for 0000:00:0f.1
[   26.317596] PCI: Calling quirk ffffffff804b85d0 for 0000:00:0f.1
[   26.317600] PCI: Calling quirk ffffffff8040a780 for 0000:00:10.0
[   26.317603] PCI: Calling quirk ffffffff804b85d0 for 0000:00:10.0
[   26.317620] PCI: Calling quirk ffffffff8040a780 for 0000:00:10.1
[   26.317623] PCI: Calling quirk ffffffff804b85d0 for 0000:00:10.1
[   26.317638] PCI: Calling quirk ffffffff8040a780 for 0000:00:10.2
[   26.317641] PCI: Calling quirk ffffffff804b85d0 for 0000:00:10.2
[   26.317655] PCI: Calling quirk ffffffff8040a780 for 0000:00:10.3
[   26.317658] PCI: Calling quirk ffffffff804b85d0 for 0000:00:10.3
[   26.317673] PCI: Calling quirk ffffffff8040a780 for 0000:00:10.4
[   26.317676] PCI: Calling quirk ffffffff804b85d0 for 0000:00:10.4
[   26.317708] PCI: Calling quirk ffffffff8040a780 for 0000:00:11.0
[   26.317710] PCI: Calling quirk ffffffff80409ae0 for 0000:00:11.0
[   26.317715] PCI: Calling quirk ffffffff804b85d0 for 0000:00:11.0
[   26.317719] PCI: Calling quirk ffffffff8040a780 for 0000:00:11.5
[   26.317722] PCI: Calling quirk ffffffff804b85d0 for 0000:00:11.5
[   26.317726] PCI: Calling quirk ffffffff8040a780 for 0000:00:11.6
[   26.317729] PCI: Calling quirk ffffffff804b85d0 for 0000:00:11.6
[   26.317733] PCI: Calling quirk ffffffff8040a780 for 0000:00:18.0
[   26.317736] PCI: Calling quirk ffffffff804b85d0 for 0000:00:18.0
[   26.317740] PCI: Calling quirk ffffffff8040a780 for 0000:00:18.1
[   26.317743] PCI: Calling quirk ffffffff804b85d0 for 0000:00:18.1
[   26.317746] PCI: Calling quirk ffffffff8040a780 for 0000:00:18.2
[   26.317749] PCI: Calling quirk ffffffff804b85d0 for 0000:00:18.2
[   26.317753] PCI: Calling quirk ffffffff8040a780 for 0000:00:18.3
[   26.317756] PCI: Calling quirk ffffffff804b85d0 for 0000:00:18.3
[   26.317760] PCI: Calling quirk ffffffff8040a780 for 0000:01:00.0
[   26.317763] PCI: Calling quirk ffffffff804b85d0 for 0000:01:00.0
[   26.318431] vesafb: framebuffer at 0xf0000000, mapped to
0xffffc20000080000, using 5120k, total 131072k
[   26.318437] vesafb: mode is 1280x1024x16, linelength=2560, pages=1
[   26.318441] vesafb: scrolling: redraw
[   26.318444] vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
[   26.379031] Console: switching to colour frame buffer device 160x64
[   26.434727] fb0: VESA VGA frame buffer device
[   26.435525] input: Power Button (FF) as /class/input/input0
[   26.435908] ACPI: Power Button (FF) [PWRF]
[   26.436414] input: Power Button (CM) as /class/input/input1
[   26.436794] ACPI: Power Button (CM) [PWRB]
[   26.437264] input: Sleep Button (CM) as /class/input/input2
[   26.437653] ACPI: Sleep Button (CM) [SLPB]
[   26.536507] Real Time Clock Driver v1.12ac
[   26.537072] Linux agpgart interface v0.102 (c) Dave Jones
[   26.537491] Hangcheck: starting hangcheck timer 0.9.0 (tick is 180
seconds, margin is 60 seconds).
[   26.538092] Hangcheck: Using get_cycles().
[   26.540885] RAMDISK driver initialized: 16 RAM disks of 4096K size
1024 blocksize
[   26.542705] loop: loaded (max 8 devices)
[   26.543826] sata_via 0000:00:0f.0: version 2.1
[   26.543851] ACPI: PCI Interrupt 0000:00:0f.0[B] -> GSI 20 (level,
low) -> IRQ 20
[   26.544403] PCI: Calling quirk ffffffff80409bd0 for 0000:00:0f.0
[   26.544435] sata_via 0000:00:0f.0: routed to hard irq line 10
[   26.545008] ata1: SATA max UDMA/133 cmd 0x000000000001d000 ctl
0x000000000001c802 bmdma 0x000000000001b800 irq 20
[   26.545812] ata2: SATA max UDMA/133 cmd 0x000000000001c400 ctl
0x000000000001c002 bmdma 0x000000000001b808 irq 20
[   26.546553] scsi0 : sata_via
[   26.747139] ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[   26.908768] ATA: abnormal status 0x7F on port 0x000000000001d007
[   26.919916] ATA: abnormal status 0x7F on port 0x000000000001d007
[   26.939155] ata1.00: ATA-6: WDC WD1600JD-00HBB0, 08.02D08, max UDMA/133
[   26.939600] ata1.00: 312581808 sectors, multi 16: LBA48
[   26.960135] ata1.00: configured for UDMA/133
[   26.960427] scsi1 : sata_via
[   27.160795] ata2: SATA link down 1.5 Gbps (SStatus 0 SControl 300)
[   27.171943] ATA: abnormal status 0x7F on port 0x000000000001c407
[   27.172737] scsi 0:0:0:0: Direct-Access     ATA      WDC
WD1600JD-00H 08.0 PQ: 0 ANSI: 5
[   27.173857] SCSI device sda: 312581808 512-byte hdwr sectors (160042 MB)
[   27.174329] sda: Write Protect is off
[   27.174575] sda: Mode Sense: 00 3a 00 00
[   27.174615] SCSI device sda: write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[   27.175637] SCSI device sda: 312581808 512-byte hdwr sectors (160042 MB)
[   27.176118] sda: Write Protect is off
[   27.176364] sda: Mode Sense: 00 3a 00 00
[   27.176404] SCSI device sda: write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[   27.189170]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 sda8 sda9 sda10 >
[   27.268831] sd 0:0:0:0: Attached scsi disk sda
[   27.282334] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   27.295873] pata_via 0000:00:0f.1: version 0.2.1
[   27.295910] ACPI: PCI Interrupt 0000:00:0f.1[A] -> GSI 20 (level,
low) -> IRQ 20
[   27.309842] PCI: Calling quirk ffffffff80409bd0 for 0000:00:0f.1
[   27.309989] ata3: PATA max UDMA/133 cmd 0x00000000000101f0 ctl
0x00000000000103f6 bmdma 0x000000000001fc00 irq 14
[   27.324748] ata4: PATA max UDMA/133 cmd 0x0000000000010170 ctl
0x0000000000010376 bmdma 0x000000000001fc08 irq 15
[   27.339501] scsi2 : pata_via
[   27.515698] ATA: abnormal status 0x8 on port 0x00000000000101f7
[   27.530966] scsi3 : pata_via
[   27.867411] ata4.00: ATAPI, max UDMA/33
[   28.055247] ata4.00: configured for UDMA/33
[   28.074812] scsi 3:0:0:0: CD-ROM            HL-DT-ST DVDRAM
GSA-4163B A102 PQ: 0 ANSI: 5
[   28.109938] sr0: scsi3-mmc drive: 40x/40x writer dvd-ram cd/rw
xa/form2 cdda tray
[   28.126803] Uniform CD-ROM driver Revision: 3.20
[   28.144093] sr 3:0:0:0: Attached scsi CD-ROM sr0
[   28.144346] sr 3:0:0:0: Attached scsi generic sg1 type 5
[   28.161743] usbmon: debugfs is not available
[   28.179418] ACPI: PCI Interrupt 0000:00:10.4[C] -> GSI 21 (level,
low) -> IRQ 21
[   28.197538] PCI: Calling quirk ffffffff80409bd0 for 0000:00:10.4
[   28.197560] ehci_hcd 0000:00:10.4: EHCI Host Controller
[   28.216428] ehci_hcd 0000:00:10.4: new USB bus registered, assigned
bus number 1
[   28.235286] ehci_hcd 0000:00:10.4: irq 21, io mem 0xfae00000
[   28.254191] ehci_hcd 0000:00:10.4: USB 2.0 started, EHCI 1.00,
driver 10 Dec 2004
[   28.274102] usb usb1: configuration #1 chosen from 1 choice
[   28.293861] hub 1-0:1.0: USB hub found
[   28.313588] hub 1-0:1.0: 8 ports detected
[   28.434475] Initializing USB Mass Storage driver...
[   28.454021] usbcore: registered new interface driver usb-storage
[   28.473538] USB Mass Storage support registered.
[   28.493132] usbcore: registered new interface driver usbhid
[   28.512623] drivers/usb/input/hid-core.c: v2.6:USB HID core driver
[   28.532461] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at
0x60,0x64 irq 1,12
[   28.552815] serio: i8042 KBD port at 0x60,0x64 irq 1
[   28.572776] serio: i8042 AUX port at 0x60,0x64 irq 12
[   28.592891] mice: PS/2 mouse device common for all mice
[   28.642647] input: AT Translated Set 2 keyboard as /class/input/input3
[   28.666382] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[   28.686306] rtc_cmos: probe of 00:02 failed with error -16
[   28.705968] EDAC MC: Ver: 2.0.1 Jun 20 2007
[   28.725670] Advanced Linux Sound Architecture Driver Version
1.0.14rc3 (Wed Mar 14 07:25:50 2007 UTC).
[   29.304386] input: ImPS/2 Generic Wheel Mouse as /class/input/input4
[   29.327009] ACPI: PCI Interrupt 0000:00:11.5[C] -> GSI 22 (level,
low) -> IRQ 22
[   29.346449] PCI: Calling quirk ffffffff80409bd0 for 0000:00:11.5
[   29.346818] PCI: Enabling bus mastering for device 0000:00:11.5
[   29.346823] PCI: Setting latency timer of device 0000:00:11.5 to 64
[   29.862503] ALSA device list:
[   29.881975]   #0: VIA 8237 with ALC850 at 0xe800, irq 22
[   29.901398] oprofile: using NMI interrupt.
[   29.920609] Netfilter messages via NETLINK v0.30.
[   29.939747] nf_conntrack version 0.5.0 (4094 buckets, 32752 max)
[   29.959648] ip_tables: (C) 2000-2006 Netfilter Core Team
[   29.979174] TCP cubic registered
[   29.998369] Initializing XFRM netlink socket
[   30.017657] NET: Registered protocol family 1
[   30.037162] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3200+
processors (version 2.00.00)
[   30.057095] powernow-k8:    0 : fid 0xc (2000 MHz), vid 0x6
[   30.076731] powernow-k8:    1 : fid 0xa (1800 MHz), vid 0x8
[   30.096008] powernow-k8:    2 : fid 0x2 (1000 MHz), vid 0x12
[   30.115370] powernow-k8: ph2 null fid transition 0xc
[   30.134342] drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
[   30.181037] kjournald starting.  Commit interval 5 seconds
[   30.199803] EXT3-fs: mounted filesystem with ordered data mode.
[   30.218611] VFS: Mounted root (ext3 filesystem) readonly.
[   30.237165] Freeing unused kernel memory: 224k freed
[   30.255764] Write protecting the kernel read-only data: 1460k
[   33.753755] ne2k-pci.c:v1.03 9/22/2003 D. Becker/P. Gortmaker
[   33.753758]   http://www.scyld.com/network/ne2k-pci.html
[   33.753841] ACPI: PCI Interrupt 0000:00:0c.0[A] -> GSI 17 (level,
low) -> IRQ 17
[   33.754191] eth0: Compex RL2000 found at 0xb000, IRQ 17, 00:80:48:DE:5E:89.
[   34.554337] Linux video capture interface: v2.00
[   34.575361] bttv: driver version 0.9.17 loaded
[   34.575365] bttv: using 8 buffers with 2080k (520 pages) each for capture
[   34.575474] bttv: Bt8xx card found (0).
[   34.575506] ACPI: PCI Interrupt 0000:00:0d.0[A] -> GSI 18 (level,
low) -> IRQ 18
[   34.575520] bttv0: Bt878 (rev 17) at 0000:00:0d.0, irq: 18,
latency: 64, mmio: 0xefe00000
[   34.575534] bttv0: using: Lifeview FlyVideo 2000 /FlyVideo A2/
Lifetec LT 9415 TV [LR90] [card=54,insmod option]
[   34.575571] bttv0: gpio: en=00000000, out=00000000 in=00d4dfe0 [init]
[   34.577304] bttv0: FlyVideo Radio=yes RemoteControl=yes Tuner=5 gpio=0xd4dfe0
[   34.577307] bttv0: FlyVideo  LR90=yes tda9821/tda9820=no  capture_only=no
[   34.577309] bttv0: using tuner=5
[   34.577313] bttv0: i2c: checking for MSP34xx @ 0x80... not found
[   34.578081] bttv0: i2c: checking for TDA9875 @ 0xb0... found
[   34.768938] tda9875: no such chip at 0xb0 (dic=0x7 rev=0x7)
[   34.768944] i2c_adapter i2c-0: Client creation failed at 0x58 (1)
[   34.769281] bttv0: i2c: checking for TDA7432 @ 0x8a... not found
[   34.770053] bttv0: i2c: checking for TDA9887 @ 0x86... not found
[   35.026056] tuner 0-0061: chip found @ 0xc2 (bt878 #0 [sw])
[   35.026595] tuner 0-0061: type set to 5 (Philips PAL_BG (FI1216 and
compatibles))
[   35.026600] tuner 0-0061: type set to 5 (Philips PAL_BG (FI1216 and
compatibles))
[   35.038039] bttv0: registered device video0
[   35.038106] bttv0: registered device vbi0
[   35.038174] bttv0: registered device radio0
[   35.038195] bttv0: PLL: 28636363 => 35468950 .. ok
[   36.796913] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports,
IRQ sharing disabled
[   36.797477] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   36.798246] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[   36.800910] 00:0c: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[   36.801270] 00:0d: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   38.859952] EXT3 FS on sda5, internal journal
[   39.691474] kjournald starting.  Commit interval 5 seconds
[   39.691850] EXT3 FS on sda6, internal journal
[   39.691859] EXT3-fs: mounted filesystem with ordered data mode.
[   39.711032] kjournald starting.  Commit interval 5 seconds
[   39.711382] EXT3 FS on sda8, internal journal
[   39.711391] EXT3-fs: mounted filesystem with ordered data mode.
[   39.728005] kjournald starting.  Commit interval 5 seconds
[   39.728414] EXT3 FS on sda10, internal journal
[   39.728422] EXT3-fs: mounted filesystem with ordered data mode.
[   39.759834] kjournald starting.  Commit interval 5 seconds
[   39.760067] EXT3 FS on sda7, internal journal
[   39.760075] EXT3-fs: mounted filesystem with ordered data mode.
[   39.880675] Adding 1020112k swap on /dev/sda2.  Priority:-1
extents:1 across:1020112k
[   51.948467] NET: Registered protocol family 17
[   55.425892] Time: acpi_pm clocksource has been installed.
[  396.368541] NETDEV WATCHDOG: eth0: transmit timed out
[  396.368551] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=247.
[  397.167874] NETDEV WATCHDOG: eth0: transmit timed out
[  397.167884] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=384.
[  398.167027] NETDEV WATCHDOG: eth0: transmit timed out
[  398.167037] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=500.
[  399.947117] NETDEV WATCHDOG: eth0: transmit timed out
[  399.947124] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=732.
[  402.403992] NETDEV WATCHDOG: eth0: transmit timed out
[  402.404002] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=370.
[  403.403148] NETDEV WATCHDOG: eth0: transmit timed out
[  403.403158] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=370.
[  403.971763] NETDEV WATCHDOG: eth0: transmit timed out
[  403.971770] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=370.
[  408.108310] NETDEV WATCHDOG: eth0: transmit timed out
[  408.108317] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=324.
[  412.299736] NETDEV WATCHDOG: eth0: transmit timed out
[  412.299746] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=247.
[  420.331554] NETDEV WATCHDOG: eth0: transmit timed out
[  420.331564] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=980.
[  424.349861] NETDEV WATCHDOG: eth0: transmit timed out
[  424.349868] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=980.
[  425.315492] NETDEV WATCHDOG: eth0: transmit timed out
[  425.315502] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=980.
[  426.314656] NETDEV WATCHDOG: eth0: transmit timed out
[  426.314665] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=980.
[  440.362038] NETDEV WATCHDOG: eth0: transmit timed out
[  440.362045] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=691.
[  440.861616] NETDEV WATCHDOG: eth0: transmit timed out
[  440.861624] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=691.
[  441.361203] NETDEV WATCHDOG: eth0: transmit timed out
[  441.361210] eth0: Tx timed out, lost interrupt? TSR=0x3, ISR=0x3, t=691.


ps: i think it's not udev which swaps cards because they are pinned to
ethernet addresses:
# PCI device 0x11f6:0x1401 (ne2k-pci)
SUBSYSTEM=="net", DRIVERS=="?*", ATTRS{address}=="00:80:48:de:5e:89",
NAME="eth0"

# PCI device 0x11ab:0x4320 (skge)
SUBSYSTEM=="net", DRIVERS=="?*", ATTRS{address}=="00:11:d8:60:74:55",
NAME="eth1"
