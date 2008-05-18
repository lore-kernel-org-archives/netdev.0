From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan problems
Date: Sun, 18 May 2008 17:09:08 +0200
Message-ID: <20080518150908.GA4606@yamamaya.is-a-geek.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:37646 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042AbYERPJs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 11:09:48 -0400
Content-Disposition: inline
In-Reply-To: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Diedrich wrote:
> Note that so far this is only tested on my system with hibernate
> using the 'shutdown' method.

Ok, I've run tests now:

=46irst Windoze:
Windoze, Standby (equiv. to Linux 'mem' state):  WOL borked, resumes fi=
ne
Windoze, Hibernate: WOL borked, resumes fine

Linux, unpatched:
Hibernate, shutdown method: Works with known caveats
Hibernate, platform method: WOL borked, resumes fine

Linux, patched:
Hibernate, shutdown method: Works
Hibernate, platform method: WOL borked, resumes fine
Suspend ('standby' state):
   WOL borked, USB borked after resume, kernel freeze
Suspend ('mem' state, text console):
   WOL borked, VGA stays dark, otherwise working
Suspend ('mem' state, radeonfb):
   WOL borked, VGA stays dark, userspace dead after resume (but pingabl=
e)

Summary: I suspect my BIOS sucks
        Version: ASUS M2N-SLI DELUXE ACPI BIOS Revision 0903
        Release Date: 02/13/2007

1 point for Linux, 0 points for Windows, Linux wins ;)

Serial Console Log (of some of the tries, I should've written down what
I tried in which order...):

[    0.000000] Linux version 2.6.26-rc2 (ranma@melchior) (gcc version 4=
=2E2.3 (Debian 4.2.3-5)) #6 PREEMPT Sun May 18 11:35:22 CEST 2008
[    0.000000] Command line: root=3D/dev/sda5 resume=3D/dev/sda6 vga=3D=
6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3Dnomsi ro
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
[    0.000000]  BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] max_pfn_mapped =3D 1048576
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000F7B80, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT 7FEE30C0, 004C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 7FEEC540, 00F4 (r3 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 7FEE3240, 92AD (r1 NVIDIA AWRDACPI     1000 M=
SFT  3000000)
[    0.000000] ACPI: FACS 7FEE0000, 0040
[    0.000000] ACPI: SSDT 7FEEC740, 0136 (r1 PTLTD  POWERNOW        1  =
LTP        1)
[    0.000000] ACPI: HPET 7FEEC8C0, 0038 (r1 Nvidia ASUSACPI 42302E31 A=
WRD       98)
[    0.000000] ACPI: MCFG 7FEEC940, 003C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: APIC 7FEEC680, 007C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-8eb01f] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-bfff] PGTABLE
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524000
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI=
 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 7ff0=
0000:70100000)
[14315324.233334] Built 1 zonelists in Zone order, mobility grouping on=
=2E  Total pages: 514863
[14315324.233334] Kernel command line: root=3D/dev/sda5 resume=3D/dev/s=
da6 vga=3D6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3D=
nomsi ro
[14315324.233334] Initializing CPU#0
[14315324.233334] PID hash table entries: 4096 (order: 12, 32768 bytes)
[14315324.233334] Extended CMOS year: 2000
[14315324.233334] TSC calibrated against PM_TIMER
[14315324.233334] time.c: Detected 2411.097 MHz processor.
[14315324.233334] Console: colour VGA+ 80x60
[14315324.233334] console [tty0] enabled
[14315324.233334] console [ttyS0] enabled
[14315324.233334] Dentry cache hash table entries: 262144 (order: 9, 20=
97152 bytes)
[14315324.233334] Inode-cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
[14315324.233334] Checking aperture...
[14315324.233334] Node 0: aperture @ a89c000000 size 32 MB
[14315324.233334] Aperture beyond 4GB. Ignoring.
[14315324.233334] No AGP bridge found
[14315324.233334] Memory: 2056088k/2096000k available (4489k kernel cod=
e, 39052k reserved, 1754k data, 256k init)
[14315324.316531] Calibrating delay using timer specific routine.. 4827=
=2E22 BogoMIPS (lpj=3D8041962)
[14315324.323021] Mount-cache hash table entries: 256
[14315324.326661] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64=
 bytes/line)
[14315324.329994] CPU: L2 Cache: 512K (64 bytes/line)
[14315324.333327] CPU: AMD Athlon(tm) 64 Processor 3800+ stepping 01
[14315324.339620] ACPI: Core revision 20080321
[14315324.353326] enabled ExtINT on CPU#0
[14315324.356659] ENABLING IO-APIC IRQs
[14315324.359992] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1
[14315324.396296] Using local APIC timer interrupts.
[14315324.403323] Detected 12.557 MHz APIC timer.
[14315324.406656] net_namespace: 1160 bytes
[14315324.409989] NET: Registered protocol family 16
[14315324.413322] No dock devices found.
[14315324.416655] TOM: 0000000080000000 aka 2048M
[14315324.419988] ACPI: bus type pci registered
[14315324.423321] PCI: Using configuration type 1 for base access
[14315324.438522] ACPI: Interpreter enabled
[14315324.442555] ACPI: (supports S0 S1 S3 S4 S5)
[14315324.447312] ACPI: Using IOAPIC for interrupt routing
[14315324.464178] ACPI: PCI Root Bridge [PCI0] (0000:00)
[14315324.469985] PCI: Transparent bridge - 0000:00:06.0
[14315324.538642] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.546647] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.553313] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.559229] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.566645] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.573312] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.579978] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.585900] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.593310] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.599977] ACPI: PCI Interrupt Link [LUBA] (IRQs *5 7 9 10 11 14=
 15)
[14315324.605897] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.612556] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.616642] ACPI: PCI Interrupt Link [LAZA] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.623308] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.629975] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.635896] ACPI: PCI Interrupt Link [LUB2] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.642554] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.649973] ACPI: PCI Interrupt Link [LSID] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.655893] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.662567] ACPI: PCI Interrupt Link [LSA2] (IRQs *5 7 9 10 11 14=
 15)
[14315324.666639] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disable=
d.
[14315324.672252] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disable=
d.
[14315324.678915] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[14315324.684588] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disable=
d.
[14315324.691665] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disable=
d.
[14315324.698740] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0, disable=
d.
[14315324.705579] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[14315324.711252] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disable=
d.
[14315324.718327] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[14315324.725311] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[14315324.732159] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[14315324.738822] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.746573] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.753230] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[14315324.758824] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[14315324.763301] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.769899] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.776573] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[14315324.782148] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[14315324.786634] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[14315324.789968] Linux Plug and Play Support v0.97 (c) Adam Belay
[14315324.793301] pnp: PnP ACPI init
[14315324.796634] ACPI: bus type pnp registered
[14315324.807299] pnp: PnP ACPI: found 13 devices
[14315324.811851] ACPI: ACPI bus type pnp unregistered
[14315324.816634] SCSI subsystem initialized
[14315324.819968] usbcore: registered new interface driver usbfs
[14315324.823301] usbcore: registered new interface driver hub
[14315324.826634] usbcore: registered new device driver usb
[14315324.829968] PCI: Using ACPI for IRQ routing
[14315324.833301] testing the IO APIC.......................
[14315324.836634]=20
[14315324.838690] .................................... done.
[14315324.853820] Bluetooth: Core ver 2.11
[14315324.857835] NET: Registered protocol family 31
[14315324.862643] Bluetooth: HCI device and connection manager initiali=
zed
[14315324.866634] Bluetooth: HCI socket layer initialized
[14315324.869968] DMAR:parse DMAR table failure.
[14315324.881201] system 00:01: ioport range 0x1000-0x107f has been res=
erved
[14315324.888087] system 00:01: ioport range 0x1080-0x10ff has been res=
erved
[14315324.894973] system 00:01: ioport range 0x1400-0x147f has been res=
erved
[14315324.901861] system 00:01: ioport range 0x1480-0x14ff has been res=
erved
[14315324.908748] system 00:01: ioport range 0x1800-0x187f has been res=
erved
[14315324.915634] system 00:01: ioport range 0x1880-0x18ff has been res=
erved
[14315324.922528] system 00:02: ioport range 0x4d0-0x4d1 has been reser=
ved
[14315324.929244] system 00:02: ioport range 0x800-0x87f has been reser=
ved
[14315324.935960] system 00:02: ioport range 0x290-0x297 has been reser=
ved
[14315324.942683] system 00:0b: iomem range 0xf0000000-0xf3ffffff could=
 not be reserved
[14315324.950612] system 00:0c: iomem range 0xd2800-0xd3fff has been re=
served
[14315324.957582] system 00:0c: iomem range 0xf0000-0xf7fff could not b=
e reserved
[14315324.966528] system 00:0c: iomem range 0xf8000-0xfbfff could not b=
e reserved
[14315324.973935] system 00:0c: iomem range 0xfc000-0xfffff could not b=
e reserved
[14315324.981341] system 00:0c: iomem range 0xfefff000-0xfefff0ff could=
 not be reserved
[14315324.989265] system 00:0c: iomem range 0x7fee0000-0x7fefffff could=
 not be reserved
[14315324.996721] system 00:0c: iomem range 0xffff0000-0xffffffff could=
 not be reserved
[14315325.004645] system 00:0c: iomem range 0x0-0x9ffff could not be re=
served
[14315325.011620] system 00:0c: iomem range 0x100000-0x7fedffff could n=
ot be reserved
[14315325.019585] system 00:0c: iomem range 0xfec00000-0xfec00fff could=
 not be reserved
[14315325.027351] system 00:0c: iomem range 0xfee00000-0xfeefffff could=
 not be reserved
[14315325.035275] system 00:0c: iomem range 0xfefff000-0xfeffffff could=
 not be reserved
[14315325.043227] system 00:0c: iomem range 0xfff80000-0xfff80fff could=
 not be reserved
[14315325.051152] system 00:0c: iomem range 0xfff90000-0xfffbffff could=
 not be reserved
[14315325.059105] system 00:0c: iomem range 0xfffed000-0xfffeffff could=
 not be reserved
[14315325.067386] PCI: Bridge: 0000:00:06.0
[14315325.071420]   IO window: 9000-9fff
[14315325.075191]   MEM window: 0xfde00000-0xfdefffff
[14315325.080088]   PREFETCH window: disabled.
[14315325.084381] PCI: Bridge: 0000:00:0a.0
[14315325.088412]   IO window: 8000-8fff
[14315325.093066]   MEM window: 0xfdd00000-0xfddfffff
[14315325.096844]   PREFETCH window: 0x00000000e8000000-0x00000000effff=
fff
[14315325.103559] PCI: Bridge: 0000:00:0b.0
[14315325.107590]   IO window: disabled.
[14315325.111362]   MEM window: disabled.
[14315325.116291]   PREFETCH window: disabled.
[14315325.120158] PCI: Bridge: 0000:00:0c.0
[14315325.124188]   IO window: disabled.
[14315325.127953]   MEM window: disabled.
[14315325.131813]   PREFETCH window: disabled.
[14315325.136130] PCI: Bridge: 0000:00:0d.0
[14315325.140160]   IO window: disabled.
[14315325.143926]   MEM window: disabled.
[14315325.147785]   PREFETCH window: disabled.
[14315325.152077] PCI: Bridge: 0000:00:0e.0
[14315325.156401]   IO window: 6000-7fff
[14315325.160173]   MEM window: 0xfdc00000-0xfdcfffff
[14315325.164217]   PREFETCH window: disabled.
[14315325.169123] PCI: Bridge: 0000:00:0f.0
[14315325.173153]   IO window: disabled.
[14315325.176925]   MEM window: disabled.
[14315325.180784]   PREFETCH window: disabled.
[14315325.185149] NET: Registered protocol family 2
[14315325.222333] IP route cache hash table entries: 65536 (order: 7, 5=
24288 bytes)
[14315325.230464] TCP established hash table entries: 262144 (order: 10=
, 4194304 bytes)
[14315325.240004] TCP bind hash table entries: 65536 (order: 7, 524288 =
bytes)
[14315325.253249] TCP: Hash tables configured (established 262144 bind =
65536)
[14315325.260225] TCP reno registered
[14315325.272072] NET: Registered protocol family 1
[14315325.277689] Installing knfsd (copyright (C) 1996 okir@monad.swb.d=
e).
[14315325.284628] JFFS2 version 2.2. (NAND) =C3=82=C2=A9 2001-2006 Red =
Hat, Inc.
[14315325.291051] fuse init (API version 7.9)
[14315325.295893] SGI XFS with security attributes, large block/inode n=
umbers, no debug enabled
[14315325.303556] msgmni has been set to 4016 for ipc namespace fffffff=
f807eda90
[14315325.310875] Block layer SCSI generic (bsg) driver version 0.4 loa=
ded (major 254)
[14315325.319525] io scheduler noop registered
[14315325.323814] io scheduler anticipatory registered
[14315325.328797] io scheduler deadline registered
[14315325.333428] io scheduler cfq registered (default)
[14315325.350469] pci 0000:00:05.0: Enabling HT MSI Mapping
[14315325.355893] pci 0000:00:05.1: Enabling HT MSI Mapping
[14315325.361007] pci 0000:00:05.2: Enabling HT MSI Mapping
[14315325.366441] pci 0000:00:06.0: Enabling HT MSI Mapping
[14315325.371878] pci 0000:00:08.0: Enabling HT MSI Mapping
[14315325.377304] pci 0000:00:09.0: Enabling HT MSI Mapping
[14315325.382744] pci 0000:00:0a.0: Enabling HT MSI Mapping
[14315325.388178] pci 0000:00:0b.0: Enabling HT MSI Mapping
[14315325.393602] pci 0000:00:0c.0: Enabling HT MSI Mapping
[14315325.399045] pci 0000:00:0d.0: Enabling HT MSI Mapping
[14315325.404469] pci 0000:00:0e.0: Enabling HT MSI Mapping
[14315325.409914] pci 0000:00:0f.0: Enabling HT MSI Mapping
[14315325.415447] assign_interrupt_mode Found MSI capability
[14315325.420841] assign_interrupt_mode Found MSI capability
[14315325.426463] assign_interrupt_mode Found MSI capability
[14315325.432042] assign_interrupt_mode Found MSI capability
[14315325.437606] assign_interrupt_mode Found MSI capability
[14315325.443198] assign_interrupt_mode Found MSI capability
[14315325.448973] input: Power Button (FF) as /class/input/input0
[14315325.454909] ACPI: Power Button (FF) [PWRF]
[14315325.459439] input: Power Button (CM) as /class/input/input1
[14315325.465375] ACPI: Power Button (CM) [PWRB]
[14315325.469941] ACPI: PNP0C0B:00 is registered as cooling_device0
[14315325.476048] ACPI: Fan [FAN] (on)
[14315325.479757] ACPI: ACPI0007:00 is registered as cooling_device1
[14315325.486750] ACPI: LNXTHERM:01 is registered as thermal_zone0
[14315325.493016] ACPI: Thermal Zone [THRM] (40 C)
[14315325.518404] Real Time Clock Driver v1.12ac
[14315325.522873] Linux agpgart interface v0.103
[14315325.525740] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, =
IRQ sharing disabled
n=C3=93=C2=8A=C2=AA=C2=9A=C2=92=C2=AAr=C2=AA=C2=9A=C2=AA=C3=82=C2=A2=C2=
=92=C3=AA=C2=81serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.542515] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.549033] loop: module loaded
[14315325.552546] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[14315325.557528] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[14315325.564026] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[14315325.570477] e100: Copyright(c) 1999-2006 Intel Corporation
[14315325.576375] tun: Universal TUN/TAP device driver, 1.6
[14315325.582561] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com=
>
[14315325.589189] Driver 'sd' needs updating - please use bus_type meth=
ods
[14315325.595927] Driver 'sr' needs updating - please use bus_type meth=
ods
[14315325.603157] ACPI: PCI Interrupt Link [APC7] enabled at IRQ 16
[14315325.609275] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315326.620343] ahci 0000:06:00.0: AHCI 0001.0000 32 slots 2 ports 3 =
Gbps 0x3 impl SATA mode
[14315326.628871] ahci 0000:06:00.0: flags: 64bit ncq pm led clo pmp pi=
o slum part=20
[14315326.636649] scsi0 : ahci
[14315326.639647] scsi1 : ahci
[14315326.642643] ata1: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe100 irq 16
[14315326.652272] ata2: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe180 irq 16
[14315326.978247] ata1: SATA link down (SStatus 0 SControl 300)
[14315327.301939] ata2: SATA link down (SStatus 0 SControl 300)
[14315327.307153] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
[14315327.313263] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315327.323287] sata_nv 0000:00:05.0: Using SWNCQ mode
[14315327.328619] scsi2 : sata_nv
[14315327.331840] scsi3 : sata_nv
[14315327.335189] ata3: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd=
c00 irq 23
[14315327.342592] ata4: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd=
c08 irq 23
[14315327.820935] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315327.853335] ata3.00: ATA-8: SAMSUNG HD501LJ, CR100-12, max UDMA7
[14315327.856670] ata3.00: 976773168 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
[14315327.873116] ata3.00: configured for UDMA/133
[14315328.194648] ata4: SATA link down (SStatus 0 SControl 300)
[14315328.222773] isa bounce pool size: 16 pages
[14315328.226733] scsi 2:0:0:0: Direct-Access     ATA      SAMSUNG HD50=
1LJ  CR10 PQ: 0 ANSI: 5
[14315328.234602] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.243110] sd 2:0:0:0: [sda] Write Protect is off
[14315328.247479] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.257002] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.264583] sd 2:0:0:0: [sda] Write Protect is off
[14315328.269792] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.279278]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[14315328.347106] sd 2:0:0:0: [sda] Attached SCSI disk
[14315328.364416] sd 2:0:0:0: Attached scsi generic sg0 type 0
[14315328.371483] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
[14315328.377609] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315328.386830] sata_nv 0000:00:05.1: Using SWNCQ mode
[14315328.392796] scsi4 : sata_nv
[14315328.396027] scsi5 : sata_nv
[14315328.399378] ata5: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc=
800 irq 22
[14315328.406784] ata6: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc=
808 irq 22
[14315328.732195] ata5: SATA link down (SStatus 0 SControl 300)
[14315329.065570] ata6: SATA link down (SStatus 0 SControl 300)
[14315329.093136] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 21
[14315329.096678] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315329.107410] sata_nv 0000:00:05.2: Using SWNCQ mode
[14315329.112738] scsi6 : sata_nv
[14315329.115965] scsi7 : sata_nv
[14315329.119315] ata7: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0=
xb400 irq 21
[14315329.126887] ata8: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0=
xb408 irq 21
[14315329.452312] ata7: SATA link down (SStatus 0 SControl 300)
[14315329.938650] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315329.953311] ata8.00: ATAPI: TSSTcorp CDDVDW SH-S203B, SB00, max U=
DMA/100
[14315329.972917] ata8.00: configured for UDMA/100
[14315329.989446] scsi 7:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S2=
03B  SB00 PQ: 0 ANSI: 5
[14315330.000002] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa=
/form2 cdda tray
[14315330.007923] Uniform CD-ROM driver Revision: 3.20
[14315330.013067] sr 7:0:0:0: Attached scsi generic sg1 type 5
[14315330.019665] block2mtd: version $Revision: 1.30 $
[14315330.025917] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 20
[14315330.032035] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315330.040156] ehci_hcd 0000:00:02.1: EHCI Host Controller
[14315330.045820] ehci_hcd 0000:00:02.1: new USB bus registered, assign=
ed bus number 1
[14315330.053686] ehci_hcd 0000:00:02.1: debug port 1
[14315330.059946] ehci_hcd 0000:00:02.1: irq 20, io mem 0xfe02e000
[14315330.075046] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, dr=
iver 10 Dec 2004
[14315330.089034] usb usb1: configuration #1 chosen from 1 choice
[14315330.093921] hub 1-0:1.0: USB hub found
[14315330.099960] hub 1-0:1.0: 10 ports detected
[14315330.205561] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[14315330.210004] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315330.220849] ohci_hcd 0000:00:02.0: OHCI Host Controller
[14315330.226500] ohci_hcd 0000:00:02.0: new USB bus registered, assign=
ed bus number 2
[14315330.234346] ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
[14315330.293335] usb usb2: configuration #1 chosen from 1 choice
[14315330.299300] hub 2-0:1.0: USB hub found
[14315330.303417] hub 2-0:1.0: 10 ports detected
[14315330.383215] hub 1-0:1.0: unable to enumerate USB device on port 1
[14315330.413224] USB Universal Host Controller Interface driver v3.0
[14315330.559481] hub 1-0:1.0: unable to enumerate USB device on port 3
[14315330.736213] hub 1-0:1.0: unable to enumerate USB device on port 4
[14315330.740043] usbcore: registered new interface driver usblp
[14315330.746524] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq =
1
[14315330.753060] PNP: PS/2 appears to have AUX port disabled, if this =
is incorrect please boot with i8042.nopnp
[14315330.763239] serio: i8042 KBD port at 0x60,0x64 irq 1
[14315330.769119] mice: PS/2 mouse device common for all mice
[14315330.797922] i2c /dev entries driver
[14315330.801894] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[14315330.808149] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[14315330.813652] it87: Found IT8716F chip at 0x290, revision 0
[14315330.819856] it87: in3 is VCC (+5V)
[14315330.823621] it87: in7 is VCCH (+5V Stand-By)
[14315330.840001] input: AT Translated Set 2 keyboard as /class/input/i=
nput2
[14315330.872509] md: raid1 personality registered for level 1
[14315330.876736] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initi=
alised: dm-devel@redhat.com
[14315330.885966] Bluetooth: HCI USB driver ver 2.9
[14315330.979513] usb 2-1: new low speed USB device using ohci_hcd and =
address 2
[14315331.126668] usb 2-1: configuration #1 chosen from 1 choice
[14315331.385512] usb 2-3: new low speed USB device using ohci_hcd and =
address 3
[14315331.543334] usb 2-3: configuration #1 chosen from 1 choice
[14315331.811891] usb 2-4: new full speed USB device using ohci_hcd and=
 address 4
[14315331.943338] usb 2-4: device descriptor read/64, error -62
[14315332.176671] usb 2-4: device descriptor read/64, error -62
[14315332.405479] usb 2-4: new full speed USB device using ohci_hcd and=
 address 5
[14315332.536671] usb 2-4: device descriptor read/64, error -62
[14315332.770004] usb 2-4: device descriptor read/64, error -62
[14315332.998827] usb 2-4: new full speed USB device using ohci_hcd and=
 address 6
[14315333.410717] usb 2-4: device not accepting address 6, error -62
[14315333.536027] usb 2-4: new full speed USB device using ohci_hcd and=
 address 7
[14315333.947967] usb 2-4: device not accepting address 7, error -62
[14315333.953337] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315333.959834] usbcore: registered new interface driver hci_usb
[14315333.966006] Bluetooth: HCI UART driver ver 2.2
[14315333.972080] Bluetooth: HCI H4 protocol initialized
[14315333.976897] Bluetooth: HCI BCSP protocol initialized
[14315333.982223] cpuidle: using governor ladder
[14315333.986685] cpuidle: using governor menu
[14315333.996667] input: Microsoft Microsoft 3-Button Mouse with Intell=
iEye(TM) as /class/input/input3
[14315334.027950] input: USB HID v1.10 Mouse [Microsoft Microsoft 3-But=
ton Mouse with IntelliEye(TM)] on usb-0000:00:02.0-1
[14315334.049254] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input4
[14315334.079854] input: USB HID v1.11 Keyboard [Microsoft Natural=C2=AE=
 Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.101369] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input5
[14315334.134705] input: USB HID v1.11 Device [Microsoft Natural=C2=AE =
Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.144902] usbcore: registered new interface driver usbhid
[14315334.150217] usbhid: v2.6:USB HID core driver
[14315334.156227] Advanced Linux Sound Architecture Driver Version 1.0.=
16.
[14315334.163095] ALSA device list:
[14315334.166432]   No soundcards found.
[14315334.168258] GACT probability on
[14315334.171768] Mirror/redirect action on
[14315334.175978] u32 classifier
[14315334.179130]     Performance counters on
[14315334.183331]     input device check on=20
[14315334.189926]     Actions configured=20
[14315334.194085] IPv4 over IPv4 tunneling driver
[14315334.198143] ip_tables: (C) 2000-2006 Netfilter Core Team
[14315334.203840] TCP bic registered
[14315334.207260] TCP cubic registered
[14315334.210850] TCP westwood registered
[14315334.214700] TCP htcp registered
[14315334.218205] TCP vegas registered
[14315334.223102] TCP yeah registered
[14315334.226606] Initializing XFRM netlink socket
[14315334.230243] NET: Registered protocol family 10
[14315334.236668] IPv6 over IPv4 tunneling driver
[14315334.241014] NET: Registered protocol family 17
[14315334.245820] NET: Registered protocol family 15
[14315334.250671] Bridge firewalling registered
[14315334.255849] Bluetooth: L2CAP ver 2.9
[14315334.259792] Bluetooth: L2CAP socket layer initialized
[14315334.264219] Bluetooth: SCO (Voice Link) ver 0.5
[14315334.269633] Bluetooth: SCO socket layer initialized
[14315334.274548] Bluetooth: RFCOMM socket layer initialized
[14315334.280056] Bluetooth: RFCOMM TTY layer initialized
[14315334.285296] Bluetooth: RFCOMM ver 1.8
[14315334.289319] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[14315334.294986] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[14315334.300350] RPC: Registered udp transport module.
[14315334.306544] RPC: Registered tcp transport module.
[14315334.311719] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelat=
ech.com>
[14315334.318859] All bugs added by David S. Miller <davem@redhat.com>
[14315334.325227] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3800=
+ processors (1 cpu cores) (version 2.20.00)
[14315334.335608] powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
[14315334.341625] powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
[14315334.346742] powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
[14315334.352687] powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
[14315334.358624] powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
[14315334.366238] md: Autodetecting RAID arrays.
[14315334.373335] md: Scanned 0 and added 0 devices.
[14315334.374821] md: autorun ...
[14315334.378154] md: ... autorun DONE.
[14315334.395291] kjournald starting.  Commit interval 5 seconds
[14315334.401138] EXT3-fs: mounted filesystem with ordered data mode.
[14315334.407419] VFS: Mounted root (ext3 filesystem) readonly.
[14315334.413188] Freeing unused kernel memory: 256k freed
[14315335.297045] Marking TSC unstable due to cpufreq changes
[14315335.730022] Clocksource tsc unstable (delta =3D -255125899 ns)
[14315336.612986] scsi8 : pata_amd
[14315336.621383] scsi9 : pata_amd
[14315336.625451] ata9: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf=
000 irq 14
[14315336.633239] ata10: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0x=
f008 irq 15
[14315336.820471] ata9.01: ATAPI: Pioneer DVD-ROM ATAPIModel DVD-106S 0=
122, E1.22, max UDMA/66
[14315336.837064] ata9.01: configured for UDMA/66
[14315336.856047] scsi 8:0:1:0: CD-ROM            PIONEER  DVD-ROM DVD-=
106  1.22 PQ: 0 ANSI: 5
[14315336.866671] sr1: scsi3-mmc drive: 15x/40x cd/rw xa/form2 cdda tra=
y
[14315336.872500] sr 8:0:1:0: Attached scsi generic sg2 type 5
[14315336.890009] forcedeth: Reverse Engineered nForce ethernet driver.=
 Version 0.61.
[14315336.898221] ACPI: PCI Interrupt Link [APCH] enabled at IRQ 22
[14315336.904345] ACPI: PCI Interrupt 0000:00:08.0[A] -> Link [APCH] ->=
 GSI 22 (level, low) -> IRQ 22
[14315337.430837] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @=
 1, addr 00:17:31:aa:1e:89
[14315337.439773] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315337.464710] gameport: EMU10K1 is pci0000:01:08.1/gameport0, io 0x=
9800, speed 1202kHz
[14315337.473390] ACPI: PCI Interrupt Link [APC3] enabled at IRQ 18
[14315337.482895] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315337.490942] ALSA sound/pci/emu10k1/emu10k1_main.c:1748: ACPI: PCI=
 Interrupt Link [AMC1] enabled at IRQ 21
[14315337.502374] ACPI: PCI Interrupt 0000:00:09.0[A] -> vendor=3D0x110=
2, device=3D0x2, subsystem_vendor_id=3D0x80641102, subsystem_id=3D0x806=
4
[14315337.516495] Link [AMC1] -> GSI 21 (level, low) -> IRQ 21
[14315337.520493] ALSA sound/pci/emu10k1/emu10k1_main.c:1773: Sound car=
d name=3DSB Live 5.1
[14315338.034296] forcedeth 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @=
 1, addr 00:17:31:ac:c6:64
[14315338.043434] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315339.351194] Adding 3911788k swap on /dev/sda6.  Priority:-1 exten=
ts:1 across:3911788k
[14315339.517709] EXT3 FS on sda5, internal journal
[14315344.154685] br0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM fe=
ature.
[14315387.143660] PM: Syncing filesystems ... done.
[14315387.153399] PM: Preparing system for standby sleep
[14315387.163835] Freezing user space processes ... (elapsed 0.00 secon=
ds) done.
[14315387.172575] Freezing remaining freezable tasks ... (elapsed 0.00 =
seconds) done.
[14315387.180551] PM: Entering standby sleep
[14315387.184081] Suspending console(s)
[14315387.676699] sd 2:0:0:0: [sda] Synchronizing SCSI cache
[14315387.676896] sd 2:0:0:0: [sda] Stopping disk
[14315388.096641] ACPI handle has no context!
[14315388.096641] serial 00:08: disabled
[14315388.123388] ACPI: PCI interrupt for device 0000:06:00.0 disabled
[14315388.143701] ACPI: PCI interrupt for device 0000:01:08.0 disabled
[14315388.143712] ACPI handle has no context!
[14315388.157025] ACPI: PCI interrupt for device 0000:00:09.0 disabled
[14315388.170300] ACPI: PCI interrupt for device 0000:00:08.0 disabled
[14315388.183374] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14315388.196698] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14315388.210032] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14315388.236683] ACPI: PCI interrupt for device 0000:00:02.1 disabled
[14315388.250018] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14315388.263477] ACPI: Preparing to enter system sleep state S1
[14315388.370835] Extended CMOS year: 2000
[14315388.373901] Back to C!
[14315388.373901] svm_cpu_init: svm_data is NULL on 0
[14315388.373901] Extended CMOS year: 2000
[14315388.382428] ACPI: Unable to turn cooling device [ffff81007f842890=
] 'off'
[14315388.393342] ohci_hcd 0000:00:02.0: enabling device (0000 -> 0002)
[14315388.393346] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315388.393350] PCI: Setting latency timer of device 0000:00:02.0 to =
64
[14315388.393354] PM: Writing back config space on device 0000:00:02.0 =
at offset f (was 1030100, writing 1030105)
[14315388.393360] PM: Writing back config space on device 0000:00:02.0 =
at offset 4 (was 0, writing fe02f000)
[14315388.393363] PM: Writing back config space on device 0000:00:02.0 =
at offset 1 (was b00006, writing b00007)
[14315388.433830] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315388.445221] PCI: Setting latency timer of device 0000:00:02.1 to =
64
[14315388.488792] PM: Writing back config space on device 0000:00:04.0 =
at offset 8 (was 1, writing f001)
[14315388.496105] PM: Writing back config space on device 0000:00:04.0 =
at offset 1 (was b00000, writing b00005)
[14315388.508738] PCI: Setting latency timer of device 0000:00:04.0 to =
64
[14315389.072605] PM: Writing back config space on device 0000:00:05.0 =
at offset f (was 1030100, writing 103010a)
[14315389.169283] PM: Writing back config space on device 0000:00:05.0 =
at offset 9 (was 0, writing fe02d000)
[14315389.229073] PM: Writing back config space on device 0000:00:05.0 =
at offset 8 (was 1, writing dc01)
[14315389.272562] PM: Writing back config space on device 0000:00:05.0 =
at offset 7 (was 1, writing b71)
[14315389.332482] PM: Writing back config space on device 0000:00:05.0 =
at offset 6 (was 1, writing 971)
[14315389.415869] PM: Writing back config space on device 0000:00:05.0 =
at offset 5 (was 1, writing bf1)
[14315389.458915] PM: Writing back config space on device 0000:00:05.0 =
at offset 4 (was 1, writing 9f1)
[14315389.542350] PM: Writing back config space on device 0000:00:05.0 =
at offset 1 (was b00000, writing b00007)
[14315389.731960] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315389.825907] PCI: Setting latency timer of device 0000:00:05.0 to =
64
[14315389.993101] PM: Writing back config space on device 0000:00:05.1 =
at offset f (was 1030200, writing 103020b)
[14315389.994983] PM: Writing back config space on device 0000:00:05.1 =
at offset 9 (was 0, writing fe02c000)
[14315389.995687] PM: Writing back config space on device 0000:00:05.1 =
at offset 8 (was 1, writing c801)
[14315389.996391] PM: Writing back config space on device 0000:00:05.1 =
at offset 7 (was 1, writing b61)
[14315389.996861] PM: Writing back config space on device 0000:00:05.1 =
at offset 6 (was 1, writing 961)
[14315390.015438] PM: Writing back config space on device 0000:00:05.1 =
at offset 5 (was 1, writing be1)
[14315390.016143] PM: Writing back config space on device 0000:00:05.1 =
at offset 4 (was 1, writing 9e1)
[14315390.016849] PM: Writing back config space on device 0000:00:05.1 =
at offset 1 (was b00000, writing b00007)
[14315390.033312] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315390.065531] PCI: Setting latency timer of device 0000:00:05.1 to =
64
[14315390.123213] PM: Writing back config space on device 0000:00:05.2 =
at offset f (was 1030300, writing 1030305)
[14315390.125094] PM: Writing back config space on device 0000:00:05.2 =
at offset 9 (was 0, writing fe02b000)
[14315390.125799] PM: Writing back config space on device 0000:00:05.2 =
at offset 8 (was 1, writing b401)
[14315390.126270] PM: Writing back config space on device 0000:00:05.2 =
at offset 7 (was 1, writing b801)
[14315390.126975] PM: Writing back config space on device 0000:00:05.2 =
at offset 6 (was 1, writing bc01)
[14315390.128857] PM: Writing back config space on device 0000:00:05.2 =
at offset 5 (was 1, writing c001)
[14315390.129328] PM: Writing back config space on device 0000:00:05.2 =
at offset 4 (was 1, writing c401)
[14315390.130267] PM: Writing back config space on device 0000:00:05.2 =
at offset 1 (was b00000, writing b00007)
[14315390.132891] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315390.168889] PCI: Setting latency timer of device 0000:00:05.2 to =
64
[14315390.179007] PCI: Setting latency timer of device 0000:00:06.0 to =
64
[14315390.230502] PM: Writing back config space on device 0000:00:08.0 =
at offset f (was 14010100, writing 1401010a)
[14315390.232619] PM: Writing back config space on device 0000:00:08.0 =
at offset 7 (was 0, writing fe028000)
[14315390.233323] PM: Writing back config space on device 0000:00:08.0 =
at offset 6 (was 0, writing fe029000)
[14315390.233794] PM: Writing back config space on device 0000:00:08.0 =
at offset 5 (was 1, writing b001)
[14315390.235675] PM: Writing back config space on device 0000:00:08.0 =
at offset 4 (was 0, writing fe02a000)
[14315390.236380] PM: Writing back config space on device 0000:00:08.0 =
at offset 1 (was b00000, writing b00007)
[14315390.486627] ata10: port disabled. ignoring.
[14315390.620919] eth0: no link during initialization.
[14315390.760598] PM: Writing back config space on device 0000:00:09.0 =
at offset f (was 14010100, writing 1401010a)
[14315390.762481] PM: Writing back config space on device 0000:00:09.0 =
at offset 7 (was 0, writing fe025000)
[14315390.763186] PM: Writing back config space on device 0000:00:09.0 =
at offset 6 (was 0, writing fe026000)
[14315390.763890] PM: Writing back config space on device 0000:00:09.0 =
at offset 5 (was 1, writing ac01)
[14315390.764171] PM: Writing back config space on device 0000:00:09.0 =
at offset 4 (was 0, writing fe027000)
[14315390.768644] PM: Writing back config space on device 0000:00:09.0 =
at offset 1 (was b00000, writing b00007)
[14315390.816382] ata6: SATA link down (SStatus 0 SControl 300)
[14315391.312966] ata5: SATA link down (SStatus 0 SControl 300)
[14315391.553089] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315391.557323] ata7: SATA link down (SStatus 0 SControl 300)
[14315391.796714] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315391.810176] ata4: SATA link down (SStatus 0 SControl 300)
[14315392.073450] ata8.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315392.076983] ata3.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315392.078628] ata3.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[14315392.185913] ata3.00: configured for UDMA/133
[14315392.197463] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315392.203347] sd 2:0:0:0: [sda] Write Protect is off
[14315392.203816] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[14315392.210176] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315392.229761] ata8.00: configured for UDMA/100
[14315392.243198] PCI: Setting latency timer of device 0000:00:0a.0 to =
64
[14315392.253082] PCI: Setting latency timer of device 0000:00:0b.0 to =
64
[14315392.262254] PCI: Setting latency timer of device 0000:00:0c.0 to =
64
[14315392.270015] PCI: Setting latency timer of device 0000:00:0d.0 to =
64
[14315392.278720] PCI: Setting latency timer of device 0000:00:0e.0 to =
64
[14315392.286777] PCI: Setting latency timer of device 0000:00:0f.0 to =
64
[14315394.402441] ata9.01: ACPI cmd ef/03:44:00:00:00:b0 filtered out
[14315394.402912] ata9.01: ACPI cmd ef/03:0c:00:00:00:b0 filtered out
[14315394.409031] ata9: nv_mode_filter: 0x1f01f&0x1f01f->0x1f01f, BIOS=3D=
0x1f000 (0xc50000) ACPI=3D0x1f01f (600:30:0x1c)
[14315394.477307] ata9.01: configured for UDMA/66
[14315394.482485] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315396.513830] PM: Writing back config space on device 0000:06:00.0 =
at offset 1 (was 100003, writing 100007)
[14315396.520186] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315396.522775] PCI: Setting latency timer of device 0000:06:00.0 to =
64
[14315397.861763] ata1: SATA link down (SStatus 0 SControl 300)
[14315397.882239] ata2: SATA link down (SStatus 0 SControl 300)
[14315398.642217] serial 00:08: activated
[14315398.662762] sd 2:0:0:0: [sda] Starting disk
[14315412.889342] PM: Finishing wakeup.
[14315412.949676] Restarting tasks ... <6>usb 2-4: new full speed USB d=
evice using ohci_hcd and address 8
[14315415.262472] done.
[    0.000000] Command line: root=3D/dev/sda5 resume=3D/dev/sda6 vga=3D=
6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3Dnomsi ro
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
[    0.000000]  BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] max_pfn_mapped =3D 1048576
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000F7B80, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT 7FEE30C0, 004C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 7FEEC540, 00F4 (r3 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 7FEE3240, 92AD (r1 NVIDIA AWRDACPI     1000 M=
SFT  3000000)
[    0.000000] ACPI: FACS 7FEE0000, 0040
[    0.000000] ACPI: SSDT 7FEEC740, 0136 (r1 PTLTD  POWERNOW        1  =
LTP        1)
[    0.000000] ACPI: HPET 7FEEC8C0, 0038 (r1 Nvidia ASUSACPI 42302E31 A=
WRD       98)
[    0.000000] ACPI: MCFG 7FEEC940, 003C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: APIC 7FEEC680, 007C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-8eb01f] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-bfff] PGTABLE
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524000
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI=
 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 7ff0=
0000:70100000)
[14315324.233334] Built 1 zonelists in Zone order, mobility grouping on=
=2E  Total pages: 514863
[14315324.233334] Kernel command line: root=3D/dev/sda5 resume=3D/dev/s=
da6 vga=3D6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3D=
nomsi ro
[14315324.233334] Initializing CPU#0
[14315324.233334] PID hash table entries: 4096 (order: 12, 32768 bytes)
[14315324.233334] Extended CMOS year: 2000
[14315324.233334] TSC calibrated against PM_TIMER
[14315324.233334] time.c: Detected 2411.097 MHz processor.
[14315324.233334] Console: colour VGA+ 80x60
[14315324.233334] console [tty0] enabled
[14315324.233334] console [ttyS0] enabled
[14315324.233334] Dentry cache hash table entries: 262144 (order: 9, 20=
97152 bytes)
[14315324.233334] Inode-cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
[14315324.233334] Checking aperture...
[14315324.233334] Node 0: aperture @ a89c000000 size 32 MB
[14315324.233334] Aperture beyond 4GB. Ignoring.
[14315324.233334] No AGP bridge found
[14315324.233334] Memory: 2056088k/2096000k available (4489k kernel cod=
e, 39052k reserved, 1754k data, 256k init)
[14315324.316530] Calibrating delay using timer specific routine.. 4827=
=2E22 BogoMIPS (lpj=3D8041952)
[14315324.323020] Mount-cache hash table entries: 256
[14315324.326661] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64=
 bytes/line)
[14315324.329994] CPU: L2 Cache: 512K (64 bytes/line)
[14315324.333327] CPU: AMD Athlon(tm) 64 Processor 3800+ stepping 01
[14315324.339623] ACPI: Core revision 20080321
[14315324.353326] enabled ExtINT on CPU#0
[14315324.356659] ENABLING IO-APIC IRQs
[14315324.359992] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1
[14315324.396296] Using local APIC timer interrupts.
[14315324.403323] Detected 12.557 MHz APIC timer.
[14315324.406656] net_namespace: 1160 bytes
[14315324.409989] NET: Registered protocol family 16
[14315324.413322] No dock devices found.
[14315324.416655] TOM: 0000000080000000 aka 2048M
[14315324.419988] ACPI: bus type pci registered
[14315324.423321] PCI: Using configuration type 1 for base access
[14315324.438523] ACPI: Interpreter enabled
[14315324.442551] ACPI: (supports S0 S1 S3 S4 S5)
[14315324.447301] ACPI: Using IOAPIC for interrupt routing
[14315324.464039] ACPI: PCI Root Bridge [PCI0] (0000:00)
[14315324.469925] PCI: Transparent bridge - 0000:00:06.0
[14315324.538605] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.546647] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.553313] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.559236] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.566645] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.573312] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.579978] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.585890] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.593310] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.599977] ACPI: PCI Interrupt Link [LUBA] (IRQs *5 7 9 10 11 14=
 15)
[14315324.605881] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.612557] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.616642] ACPI: PCI Interrupt Link [LAZA] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.623308] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.629975] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.635895] ACPI: PCI Interrupt Link [LUB2] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.642561] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.649973] ACPI: PCI Interrupt Link [LSID] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.655893] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.662560] ACPI: PCI Interrupt Link [LSA2] (IRQs *5 7 9 10 11 14=
 15)
[14315324.666639] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disable=
d.
[14315324.672243] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disable=
d.
[14315324.678907] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[14315324.683304] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disable=
d.
[14315324.688906] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disable=
d.
[14315324.695570] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0, disable=
d.
[14315324.702246] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[14315324.707916] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disable=
d.
[14315324.714994] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[14315324.721977] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[14315324.728824] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[14315324.735482] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.743240] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.749904] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[14315324.755483] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[14315324.759968] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.766573] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.773239] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[14315324.778814] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[14315324.783301] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[14315324.786634] Linux Plug and Play Support v0.97 (c) Adam Belay
[14315324.789968] pnp: PnP ACPI init
[14315324.793301] ACPI: bus type pnp registered
[14315324.803955] pnp: PnP ACPI: found 13 devices
[14315324.808500] ACPI: ACPI bus type pnp unregistered
[14315324.813301] SCSI subsystem initialized
[14315324.816635] usbcore: registered new interface driver usbfs
[14315324.819968] usbcore: registered new interface driver hub
[14315324.823301] usbcore: registered new device driver usb
[14315324.826635] PCI: Using ACPI for IRQ routing
[14315324.829968] testing the IO APIC.......................
[14315324.833301]=20
[14315324.835357] .................................... done.
[14315324.850590] Bluetooth: Core ver 2.11
[14315324.854615] NET: Registered protocol family 31
[14315324.859421] Bluetooth: HCI device and connection manager initiali=
zed
[14315324.863301] Bluetooth: HCI socket layer initialized
[14315324.866634] DMAR:parse DMAR table failure.
[14315324.877859] system 00:01: ioport range 0x1000-0x107f has been res=
erved
[14315324.884742] system 00:01: ioport range 0x1080-0x10ff has been res=
erved
[14315324.891630] system 00:01: ioport range 0x1400-0x147f has been res=
erved
[14315324.898517] system 00:01: ioport range 0x1480-0x14ff has been res=
erved
[14315324.905405] system 00:01: ioport range 0x1800-0x187f has been res=
erved
[14315324.912292] system 00:01: ioport range 0x1880-0x18ff has been res=
erved
[14315324.919184] system 00:02: ioport range 0x4d0-0x4d1 has been reser=
ved
[14315324.925894] system 00:02: ioport range 0x800-0x87f has been reser=
ved
[14315324.932608] system 00:02: ioport range 0x290-0x297 has been reser=
ved
[14315324.939330] system 00:0b: iomem range 0xf0000000-0xf3ffffff could=
 not be reserved
[14315324.947260] system 00:0c: iomem range 0xd2800-0xd3fff has been re=
served
[14315324.954229] system 00:0c: iomem range 0xf0000-0xf7fff could not b=
e reserved
[14315324.963183] system 00:0c: iomem range 0xf8000-0xfbfff could not b=
e reserved
[14315324.970591] system 00:0c: iomem range 0xfc000-0xfffff could not b=
e reserved
[14315324.977998] system 00:0c: iomem range 0xfefff000-0xfefff0ff could=
 not be reserved
[14315324.985923] system 00:0c: iomem range 0x7fee0000-0x7fefffff could=
 not be reserved
[14315324.993380] system 00:0c: iomem range 0xffff0000-0xffffffff could=
 not be reserved
[14315325.001308] system 00:0c: iomem range 0x0-0x9ffff could not be re=
served
[14315325.008281] system 00:0c: iomem range 0x100000-0x7fedffff could n=
ot be reserved
[14315325.016242] system 00:0c: iomem range 0xfec00000-0xfec00fff could=
 not be reserved
[14315325.024006] system 00:0c: iomem range 0xfee00000-0xfeefffff could=
 not be reserved
[14315325.031931] system 00:0c: iomem range 0xfefff000-0xfeffffff could=
 not be reserved
[14315325.039884] system 00:0c: iomem range 0xfff80000-0xfff80fff could=
 not be reserved
[14315325.047809] system 00:0c: iomem range 0xfff90000-0xfffbffff could=
 not be reserved
[14315325.055762] system 00:0c: iomem range 0xfffed000-0xfffeffff could=
 not be reserved
[14315325.064042] PCI: Bridge: 0000:00:06.0
[14315325.068076]   IO window: 9000-9fff
[14315325.071847]   MEM window: 0xfde00000-0xfdefffff
[14315325.076744]   PREFETCH window: disabled.
[14315325.081037] PCI: Bridge: 0000:00:0a.0
[14315325.085067]   IO window: 8000-8fff
[14315325.089722]   MEM window: 0xfdd00000-0xfddfffff
[14315325.093501]   PREFETCH window: 0x00000000e8000000-0x00000000effff=
fff
[14315325.100216] PCI: Bridge: 0000:00:0b.0
[14315325.104246]   IO window: disabled.
[14315325.108011]   MEM window: disabled.
[14315325.112940]   PREFETCH window: disabled.
[14315325.116806] PCI: Bridge: 0000:00:0c.0
[14315325.120836]   IO window: disabled.
[14315325.124601]   MEM window: disabled.
[14315325.128461]   PREFETCH window: disabled.
[14315325.132779] PCI: Bridge: 0000:00:0d.0
[14315325.136809]   IO window: disabled.
[14315325.140575]   MEM window: disabled.
[14315325.144434]   PREFETCH window: disabled.
[14315325.148726] PCI: Bridge: 0000:00:0e.0
[14315325.153050]   IO window: 6000-7fff
[14315325.156822]   MEM window: 0xfdc00000-0xfdcfffff
[14315325.160867]   PREFETCH window: disabled.
[14315325.165772] PCI: Bridge: 0000:00:0f.0
[14315325.169805]   IO window: disabled.
[14315325.173577]   MEM window: disabled.
[14315325.177436]   PREFETCH window: disabled.
[14315325.181801] NET: Registered protocol family 2
[14315325.219002] IP route cache hash table entries: 65536 (order: 7, 5=
24288 bytes)
[14315325.227132] TCP established hash table entries: 262144 (order: 10=
, 4194304 bytes)
[14315325.236670] TCP bind hash table entries: 65536 (order: 7, 524288 =
bytes)
[14315325.249901] TCP: Hash tables configured (established 262144 bind =
65536)
[14315325.256879] TCP reno registered
[14315325.268720] NET: Registered protocol family 1
[14315325.274357] Installing knfsd (copyright (C) 1996 okir@monad.swb.d=
e).
[14315325.281294] JFFS2 version 2.2. (NAND) =C3=82=C2=A9 2001-2006 Red =
Hat, Inc.
[14315325.287716] fuse init (API version 7.9)
[14315325.292566] SGI XFS with security attributes, large block/inode n=
umbers, no debug enabled
[14315325.300232] msgmni has been set to 4016 for ipc namespace fffffff=
f807eda90
[14315325.307551] Block layer SCSI generic (bsg) driver version 0.4 loa=
ded (major 254)
[14315325.316199] io scheduler noop registered
[14315325.320488] io scheduler anticipatory registered
[14315325.325471] io scheduler deadline registered
[14315325.330102] io scheduler cfq registered (default)
[14315325.347149] pci 0000:00:05.0: Enabling HT MSI Mapping
[14315325.352574] pci 0000:00:05.1: Enabling HT MSI Mapping
[14315325.357691] pci 0000:00:05.2: Enabling HT MSI Mapping
[14315325.363123] pci 0000:00:06.0: Enabling HT MSI Mapping
[14315325.368561] pci 0000:00:08.0: Enabling HT MSI Mapping
[14315325.373986] pci 0000:00:09.0: Enabling HT MSI Mapping
[14315325.379427] pci 0000:00:0a.0: Enabling HT MSI Mapping
[14315325.384861] pci 0000:00:0b.0: Enabling HT MSI Mapping
[14315325.390287] pci 0000:00:0c.0: Enabling HT MSI Mapping
[14315325.395729] pci 0000:00:0d.0: Enabling HT MSI Mapping
[14315325.401153] pci 0000:00:0e.0: Enabling HT MSI Mapping
[14315325.406597] pci 0000:00:0f.0: Enabling HT MSI Mapping
[14315325.412131] assign_interrupt_mode Found MSI capability
[14315325.417523] assign_interrupt_mode Found MSI capability
[14315325.423144] assign_interrupt_mode Found MSI capability
[14315325.428724] assign_interrupt_mode Found MSI capability
[14315325.434286] assign_interrupt_mode Found MSI capability
[14315325.439871] assign_interrupt_mode Found MSI capability
[14315325.445649] input: Power Button (FF) as /class/input/input0
[14315325.451583] ACPI: Power Button (FF) [PWRF]
[14315325.456113] input: Power Button (CM) as /class/input/input1
[14315325.462050] ACPI: Power Button (CM) [PWRB]
[14315325.466617] ACPI: PNP0C0B:00 is registered as cooling_device0
[14315325.472729] ACPI: Fan [FAN] (on)
[14315325.476438] ACPI: ACPI0007:00 is registered as cooling_device1
[14315325.483431] ACPI: LNXTHERM:01 is registered as thermal_zone0
[14315325.489698] ACPI: Thermal Zone [THRM] (40 C)
[14315325.518384] Real Time Clock Driver v1.12ac
[14315325.522856] Linux agpgart interface v0.103
[14315325.525742] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, =
IRQ sharing disabled
[14315325.535844] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550=
A
[14315325.542516] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.549032] loop: module loaded
[14315325.552547] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[14315325.557531] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[14315325.564028] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[14315325.570480] e100: Copyright(c) 1999-2006 Intel Corporation
[14315325.576376] tun: Universal TUN/TAP device driver, 1.6
[14315325.582553] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com=
>
[14315325.589180] Driver 'sd' needs updating - please use bus_type meth=
ods
[14315325.595917] Driver 'sr' needs updating - please use bus_type meth=
ods
[14315325.603139] ACPI: PCI Interrupt Link [APC7] enabled at IRQ 16
[14315325.609256] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315326.620342] ahci 0000:06:00.0: AHCI 0001.0000 32 slots 2 ports 3 =
Gbps 0x3 impl SATA mode
[14315326.628874] ahci 0000:06:00.0: flags: 64bit ncq pm led clo pmp pi=
o slum part=20
[14315326.636652] scsi0 : ahci
[14315326.639650] scsi1 : ahci
[14315326.642644] ata1: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe100 irq 16
[14315326.652273] ata2: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe180 irq 16
[14315326.978245] ata1: SATA link down (SStatus 0 SControl 300)
[14315327.301941] ata2: SATA link down (SStatus 0 SControl 300)
[14315327.307154] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
[14315327.313264] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315327.323282] sata_nv 0000:00:05.0: Using SWNCQ mode
[14315327.328612] scsi2 : sata_nv
[14315327.331834] scsi3 : sata_nv
[14315327.335183] ata3: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd=
c00 irq 23
[14315327.342586] ata4: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd=
c08 irq 23
[14315327.820930] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315327.853335] ata3.00: ATA-8: SAMSUNG HD501LJ, CR100-12, max UDMA7
[14315327.856670] ata3.00: 976773168 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
[14315327.873107] ata3.00: configured for UDMA/133
[14315328.194656] ata4: SATA link down (SStatus 0 SControl 300)
[14315328.222777] isa bounce pool size: 16 pages
[14315328.226733] scsi 2:0:0:0: Direct-Access     ATA      SAMSUNG HD50=
1LJ  CR10 PQ: 0 ANSI: 5
[14315328.234602] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.243112] sd 2:0:0:0: [sda] Write Protect is off
[14315328.247482] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.257006] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.264587] sd 2:0:0:0: [sda] Write Protect is off
[14315328.269795] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.279273]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[14315328.314287] sd 2:0:0:0: [sda] Attached SCSI disk
[14315328.319333] sd 2:0:0:0: Attached scsi generic sg0 type 0
[14315328.326400] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
[14315328.332524] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315328.342822] sata_nv 0000:00:05.1: Using SWNCQ mode
[14315328.347699] scsi4 : sata_nv
[14315328.350929] scsi5 : sata_nv
[14315328.354278] ata5: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc=
800 irq 22
[14315328.362588] ata6: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc=
808 irq 22
[14315328.688522] ata5: SATA link down (SStatus 0 SControl 300)
[14315329.035554] ata6: SATA link down (SStatus 0 SControl 300)
[14315329.063136] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 21
[14315329.066678] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315329.077416] sata_nv 0000:00:05.2: Using SWNCQ mode
[14315329.082744] scsi6 : sata_nv
[14315329.085972] scsi7 : sata_nv
[14315329.089322] ata7: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0=
xb400 irq 21
[14315329.096894] ata8: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0=
xb408 irq 21
[14315329.422318] ata7: SATA link down (SStatus 0 SControl 300)
[14315329.908652] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315329.923311] ata8.00: ATAPI: TSSTcorp CDDVDW SH-S203B, SB00, max U=
DMA/100
[14315329.942912] ata8.00: configured for UDMA/100
[14315329.959304] scsi 7:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S2=
03B  SB00 PQ: 0 ANSI: 5
[14315329.970002] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa=
/form2 cdda tray
[14315329.977924] Uniform CD-ROM driver Revision: 3.20
[14315329.983069] sr 7:0:0:0: Attached scsi generic sg1 type 5
[14315329.989543] block2mtd: version $Revision: 1.30 $
[14315329.995793] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 20
[14315330.001911] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315330.010032] ehci_hcd 0000:00:02.1: EHCI Host Controller
[14315330.015697] ehci_hcd 0000:00:02.1: new USB bus registered, assign=
ed bus number 1
[14315330.023565] ehci_hcd 0000:00:02.1: debug port 1
[14315330.029826] ehci_hcd 0000:00:02.1: irq 20, io mem 0xfe02e000
[14315330.045049] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, dr=
iver 10 Dec 2004
[14315330.059027] usb usb1: configuration #1 chosen from 1 choice
[14315330.063911] hub 1-0:1.0: USB hub found
[14315330.069949] hub 1-0:1.0: 10 ports detected
[14315330.175550] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[14315330.180004] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315330.190855] ohci_hcd 0000:00:02.0: OHCI Host Controller
[14315330.196498] ohci_hcd 0000:00:02.0: new USB bus registered, assign=
ed bus number 2
[14315330.204344] ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
[14315330.263335] usb usb2: configuration #1 chosen from 1 choice
[14315330.269298] hub 2-0:1.0: USB hub found
[14315330.273415] hub 2-0:1.0: 10 ports detected
[14315330.353213] hub 1-0:1.0: unable to enumerate USB device on port 1
[14315330.383222] USB Universal Host Controller Interface driver v3.0
[14315330.529487] hub 1-0:1.0: unable to enumerate USB device on port 3
[14315330.706234] hub 1-0:1.0: unable to enumerate USB device on port 4
[14315330.710043] usbcore: registered new interface driver usblp
[14315330.716531] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq =
1
[14315330.723065] PNP: PS/2 appears to have AUX port disabled, if this =
is incorrect please boot with i8042.nopnp
[14315330.733249] serio: i8042 KBD port at 0x60,0x64 irq 1
[14315330.739127] mice: PS/2 mouse device common for all mice
[14315330.767924] i2c /dev entries driver
[14315330.771901] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[14315330.778150] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[14315330.783652] it87: Found IT8716F chip at 0x290, revision 0
[14315330.789856] it87: in3 is VCC (+5V)
[14315330.793621] it87: in7 is VCCH (+5V Stand-By)
[14315330.810001] input: AT Translated Set 2 keyboard as /class/input/i=
nput2
[14315330.842092] md: raid1 personality registered for level 1
[14315330.846736] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initi=
alised: dm-devel@redhat.com
[14315330.855965] Bluetooth: HCI USB driver ver 2.9
[14315330.949512] usb 2-1: new low speed USB device using ohci_hcd and =
address 2
[14315331.096668] usb 2-1: configuration #1 chosen from 1 choice
[14315331.355512] usb 2-3: new low speed USB device using ohci_hcd and =
address 3
[14315331.513334] usb 2-3: configuration #1 chosen from 1 choice
[14315331.781896] usb 2-4: new full speed USB device using ohci_hcd and=
 address 4
[14315331.913338] usb 2-4: device descriptor read/64, error -62
[14315332.146671] usb 2-4: device descriptor read/64, error -62
[14315332.375534] usb 2-4: new full speed USB device using ohci_hcd and=
 address 5
[14315332.506671] usb 2-4: device descriptor read/64, error -62
[14315332.740004] usb 2-4: device descriptor read/64, error -62
[14315332.968873] usb 2-4: new full speed USB device using ohci_hcd and=
 address 6
[14315333.380723] usb 2-4: device not accepting address 6, error -62
[14315333.506026] usb 2-4: new full speed USB device using ohci_hcd and=
 address 7
[14315333.917967] usb 2-4: device not accepting address 7, error -62
[14315333.923337] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315333.929832] usbcore: registered new interface driver hci_usb
[14315333.936004] Bluetooth: HCI UART driver ver 2.2
[14315333.942070] Bluetooth: HCI H4 protocol initialized
[14315333.946888] Bluetooth: HCI BCSP protocol initialized
[14315333.952219] cpuidle: using governor ladder
[14315333.956681] cpuidle: using governor menu
[14315333.966667] input: Microsoft Microsoft 3-Button Mouse with Intell=
iEye(TM) as /class/input/input3
[14315333.997948] input: USB HID v1.10 Mouse [Microsoft Microsoft 3-But=
ton Mouse with IntelliEye(TM)] on usb-0000:00:02.0-1
[14315334.019251] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input4
[14315334.049853] input: USB HID v1.11 Keyboard [Microsoft Natural=C2=AE=
 Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.071366] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input5
[14315334.104703] input: USB HID v1.11 Device [Microsoft Natural=C2=AE =
Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.114898] usbcore: registered new interface driver usbhid
[14315334.120214] usbhid: v2.6:USB HID core driver
[14315334.126225] Advanced Linux Sound Architecture Driver Version 1.0.=
16.
[14315334.133091] ALSA device list:
[14315334.136421]   No soundcards found.
[14315334.138247] GACT probability on
[14315334.141757] Mirror/redirect action on
[14315334.145967] u32 classifier
[14315334.149119]     Performance counters on
[14315334.153321]     input device check on=20
[14315334.159916]     Actions configured=20
[14315334.164074] IPv4 over IPv4 tunneling driver
[14315334.168134] ip_tables: (C) 2000-2006 Netfilter Core Team
[14315334.173831] TCP bic registered
[14315334.177249] TCP cubic registered
[14315334.180839] TCP westwood registered
[14315334.184689] TCP htcp registered
[14315334.188194] TCP vegas registered
[14315334.193092] TCP yeah registered
[14315334.196595] Initializing XFRM netlink socket
[14315334.200233] NET: Registered protocol family 10
[14315334.206667] IPv6 over IPv4 tunneling driver
[14315334.211011] NET: Registered protocol family 17
[14315334.215820] NET: Registered protocol family 15
[14315334.220672] Bridge firewalling registered
[14315334.225831] Bluetooth: L2CAP ver 2.9
[14315334.229773] Bluetooth: L2CAP socket layer initialized
[14315334.234210] Bluetooth: SCO (Voice Link) ver 0.5
[14315334.239623] Bluetooth: SCO socket layer initialized
[14315334.244544] Bluetooth: RFCOMM socket layer initialized
[14315334.250051] Bluetooth: RFCOMM TTY layer initialized
[14315334.255294] Bluetooth: RFCOMM ver 1.8
[14315334.259317] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[14315334.264984] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[14315334.270349] RPC: Registered udp transport module.
[14315334.276543] RPC: Registered tcp transport module.
[14315334.281716] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelat=
ech.com>
[14315334.288855] All bugs added by David S. Miller <davem@redhat.com>
[14315334.295221] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3800=
+ processors (1 cpu cores) (version 2.20.00)
[14315334.305605] powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
[14315334.311620] powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
[14315334.316740] powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
[14315334.322685] powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
[14315334.328622] powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
[14315334.336246] md: Autodetecting RAID arrays.
[14315334.343335] md: Scanned 0 and added 0 devices.
[14315334.344817] md: autorun ...
[14315334.348151] md: ... autorun DONE.
[14315334.361059] EXT3-fs: INFO: recovery required on readonly filesyst=
em.
[14315334.367772] EXT3-fs: write access will be enabled during recovery=
=2E
[14315334.390121] kjournald starting.  Commit interval 5 seconds
[14315334.397608] EXT3-fs: recovery complete.
[14315334.402032] EXT3-fs: mounted filesystem with ordered data mode.
[14315334.408489] VFS: Mounted root (ext3 filesystem) readonly.
[14315334.414999] Freeing unused kernel memory: 256k freed
[14315335.296887] Marking TSC unstable due to cpufreq changes
[14315335.730020] Clocksource tsc unstable (delta =3D -255346287 ns)
[14315336.661510] scsi8 : pata_amd
[14315336.668506] scsi9 : pata_amd
[14315336.672504] ata9: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf=
000 irq 14
[14315336.679925] ata10: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0x=
f008 irq 15
[14315336.876026] ata9.01: ATAPI: Pioneer DVD-ROM ATAPIModel DVD-106S 0=
122, E1.22, max UDMA/66
[14315336.898328] ata9.01: configured for UDMA/66
[14315336.921223] scsi 8:0:1:0: CD-ROM            PIONEER  DVD-ROM DVD-=
106  1.22 PQ: 0 ANSI: 5
[14315336.933337] sr1: scsi3-mmc drive: 15x/40x cd/rw xa/form2 cdda tra=
y
[14315336.941180] sr 8:0:1:0: Attached scsi generic sg2 type 5
[14315336.950008] forcedeth: Reverse Engineered nForce ethernet driver.=
 Version 0.61.
[14315336.958236] ACPI: PCI Interrupt Link [APCH] enabled at IRQ 22
[14315336.964350] ACPI: PCI Interrupt 0000:00:08.0[A] -> Link [APCH] ->=
 GSI 22 (level, low) -> IRQ 22
[14315337.490995] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @=
 1, addr 00:17:31:aa:1e:89
[14315337.499807] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315337.526670] gameport: EMU10K1 is pci0000:01:08.1/gameport0, io 0x=
9800, speed 1200kHz
[14315337.533882] ACPI: PCI Interrupt Link [APC3] enabled at IRQ 18
[14315337.540240] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315337.549970] ALSA sound/pci/emu10k1/emu10k1_main.c:1748: ACPI: PCI=
 Interrupt Link [AMC1] enabled at IRQ 21
[14315337.560230] ACPI: PCI Interrupt 0000:00:09.0[A] -> vendor=3D0x110=
2, device=3D0x2, subsystem_vendor_id=3D0x80641102, subsystem_id=3D0x806=
4
[14315337.572822] ALSA sound/pci/emu10k1/emu10k1_main.c:1773: Link [AMC=
1] -> GSI 21 (level, low) -> IRQ 21
[14315337.583298] Sound card name=3DSB Live 5.1
[14315338.097625] forcedeth 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @=
 1, addr 00:17:31:ac:c6:64
[14315338.106769] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315338.675219] Adding 3911788k swap on /dev/sda6.  Priority:-1 exten=
ts:1 across:3911788k
[14315338.841782] EXT3 FS on sda5, internal journal
[14315343.994089] br0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM fe=
ature.
[14315397.707169] PM: Syncing filesystems ... done.
[14315397.717263] PM: Preparing system for mem sleep
[14315397.728472] Freezing user space processes ... (elapsed 0.00 secon=
ds) done.
[14315397.736666] Freezing remaining freezable tasks ... (elapsed 0.00 =
seconds) done.
[14315397.745029] PM: Entering mem sleep
[14315397.747942] Suspending console(s)
[14315398.240223] sd 2:0:0:0: [sda] Stopping disk
[14315398.659996] ACPI handle has no context!
[14315398.659996] serial 00:08: disabled
[14315398.686720] ACPI: PCI interrupt for device 0000:06:00.0 disabled
[14315398.707319] ACPI: PCI interrupt for device 0000:01:08.0 disabled
[14315398.707330] ACPI handle has no context!
[14315398.720356] ACPI: PCI interrupt for device 0000:00:09.0 disabled
[14315398.733637] ACPI: PCI interrupt for device 0000:00:08.0 disabled
[14315398.746706] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14315398.760029] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14315398.773363] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14315398.800015] ACPI: PCI interrupt for device 0000:00:02.1 disabled
[14315398.813351] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14315398.826809] ACPI: Preparing to enter system sleep state S3
[14315398.934192] Extended CMOS year: 2000
[14315398.934192] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70=
10600070106
[14315398.934490] Back to C!
[14315398.934504] svm_cpu_init: svm_data is NULL on 0
[14315398.934720] Extended CMOS year: 2000
[14315398.938908] ACPI: Unable to turn cooling device [ffff81007f842890=
] 'off'
[14315398.938926] PM: Writing back config space on device 0000:00:00.0 =
at offset f (was 0, writing ff)
[14315398.951199] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315398.951204] PCI: Setting latency timer of device 0000:00:02.0 to =
64
[14315398.987802] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315398.987806] PCI: Setting latency timer of device 0000:00:02.1 to =
64
[14315399.001124] PCI: Setting latency timer of device 0000:00:04.0 to =
64
[14315399.001699] ata10: port disabled. ignoring.
[14315399.014434] PM: Writing back config space on device 0000:00:05.0 =
at offset 1 (was b00000, writing b00007)
[14315399.014443] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315399.014446] PCI: Setting latency timer of device 0000:00:05.0 to =
64
[14315399.027745] PM: Writing back config space on device 0000:00:05.1 =
at offset 1 (was b00000, writing b00007)
[14315399.027753] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315399.027757] PCI: Setting latency timer of device 0000:00:05.1 to =
64
[14315399.041057] PM: Writing back config space on device 0000:00:05.2 =
at offset 1 (was b00000, writing b00007)
[14315399.041065] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315399.041068] PCI: Setting latency timer of device 0000:00:05.2 to =
64
[14315399.041322] PCI: Setting latency timer of device 0000:00:06.0 to =
64
[14315399.054366] PM: Writing back config space on device 0000:00:08.0 =
at offset f (was 14010100, writing 1401010a)
[14315399.054371] PM: Writing back config space on device 0000:00:08.0 =
at offset 7 (was 0, writing fe028000)
[14315399.054374] PM: Writing back config space on device 0000:00:08.0 =
at offset 6 (was 0, writing fe029000)
[14315399.054377] PM: Writing back config space on device 0000:00:08.0 =
at offset 5 (was 1, writing b001)
[14315399.054380] PM: Writing back config space on device 0000:00:08.0 =
at offset 4 (was 0, writing fe02a000)
[14315399.054383] PM: Writing back config space on device 0000:00:08.0 =
at offset 1 (was b00000, writing b00007)
[14315399.054963] eth0: no link during initialization.
[14315399.067678] PM: Writing back config space on device 0000:00:09.0 =
at offset f (was 14010100, writing 1401010a)
[14315399.067683] PM: Writing back config space on device 0000:00:09.0 =
at offset 7 (was 0, writing fe025000)
[14315399.067686] PM: Writing back config space on device 0000:00:09.0 =
at offset 6 (was 0, writing fe026000)
[14315399.067689] PM: Writing back config space on device 0000:00:09.0 =
at offset 5 (was 1, writing ac01)
[14315399.067692] PM: Writing back config space on device 0000:00:09.0 =
at offset 4 (was 0, writing fe027000)
[14315399.067695] PM: Writing back config space on device 0000:00:09.0 =
at offset 1 (was b00000, writing b00007)
[14315399.068585] PCI: Setting latency timer of device 0000:00:0a.0 to =
64
[14315399.068597] PM: Writing back config space on device 0000:00:0b.0 =
at offset 1 (was 100000, writing 100004)
[14315399.068603] PCI: Setting latency timer of device 0000:00:0b.0 to =
64
[14315399.068613] PM: Writing back config space on device 0000:00:0c.0 =
at offset 1 (was 100000, writing 100004)
[14315399.068619] PCI: Setting latency timer of device 0000:00:0c.0 to =
64
[14315399.068630] PM: Writing back config space on device 0000:00:0d.0 =
at offset 1 (was 100000, writing 100004)
[14315399.068636] PCI: Setting latency timer of device 0000:00:0d.0 to =
64
[14315399.068650] PCI: Setting latency timer of device 0000:00:0e.0 to =
64
[14315399.068661] PM: Writing back config space on device 0000:00:0f.0 =
at offset 1 (was 100000, writing 100004)
[14315399.068667] PCI: Setting latency timer of device 0000:00:0f.0 to =
64
[14315399.080996] PM: Writing back config space on device 0000:01:08.0 =
at offset 1 (was 2900005, writing 2900001)
[14315399.081006] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315399.088903] PM: Writing back config space on device 0000:01:08.1 =
at offset 4 (was 1, writing 9801)
[14315399.088907] PM: Writing back config space on device 0000:01:08.1 =
at offset 3 (was 800000, writing 802000)
[14315399.088911] PM: Writing back config space on device 0000:01:08.1 =
at offset 1 (was 2900000, writing 2900005)
[14315399.088944] PM: Writing back config space on device 0000:02:00.0 =
at offset f (was 1ff, writing 10b)
[14315399.088948] PM: Writing back config space on device 0000:02:00.0 =
at offset c (was 0, writing fddc0000)
[14315399.088955] PM: Writing back config space on device 0000:02:00.0 =
at offset 6 (was 0, writing fddf0000)
[14315399.088958] PM: Writing back config space on device 0000:02:00.0 =
at offset 5 (was 1, writing 8c01)
[14315399.088962] PM: Writing back config space on device 0000:02:00.0 =
at offset 4 (was 8, writing e8000008)
[14315399.088965] PM: Writing back config space on device 0000:02:00.0 =
at offset 3 (was 800000, writing 800008)
[14315399.088970] PM: Writing back config space on device 0000:02:00.0 =
at offset 1 (was 100000, writing 100007)
[14315399.088991] PM: Writing back config space on device 0000:02:00.1 =
at offset 4 (was 0, writing fdde0000)
[14315399.088994] PM: Writing back config space on device 0000:02:00.1 =
at offset 3 (was 0, writing 8)
[14315399.100964] PM: Writing back config space on device 0000:06:00.0 =
at offset f (was 100, writing 10b)
[14315399.100971] PM: Writing back config space on device 0000:06:00.0 =
at offset c (was 0, writing fdce0000)
[14315399.100977] PM: Writing back config space on device 0000:06:00.0 =
at offset 9 (was 0, writing fdcfe000)
[14315399.100987] PM: Writing back config space on device 0000:06:00.0 =
at offset 3 (was 800000, writing 800008)
[14315399.100992] PM: Writing back config space on device 0000:06:00.0 =
at offset 1 (was 100000, writing 100007)
[14315399.101009] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315399.101014] PCI: Setting latency timer of device 0000:06:00.0 to =
64
[14315399.171859] ata9.01: ACPI cmd ef/03:44:00:00:00:b0 filtered out
[14315399.171861] ata9.01: ACPI cmd ef/03:0c:00:00:00:b0 filtered out
[14315399.171882] ata9: nv_mode_filter: 0x1f01f&0x1f01f->0x1f01f, BIOS=3D=
0x1f000 (0xc50000) ACPI=3D0x1f01f (600:30:0x1c)
[14315399.185109] ata9.01: configured for UDMA/66
[14315399.334690] ata4: SATA link down (SStatus 0 SControl 300)
[14315399.339188] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315399.362345] ata5: SATA link down (SStatus 0 SControl 300)
[14315399.366829] ata7: SATA link down (SStatus 0 SControl 300)
[14315399.371315] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315399.371352] ata6: SATA link down (SStatus 0 SControl 300)
[14315399.405514] ata8.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315399.435465] ata8.00: configured for UDMA/100
[14315400.103387] PM: Writing back config space on device 0000:06:00.1 =
at offset 8 (was 1, writing 6c01)
[14315400.103391] PM: Writing back config space on device 0000:06:00.1 =
at offset 7 (was 1, writing 7001)
[14315400.103394] PM: Writing back config space on device 0000:06:00.1 =
at offset 6 (was 1, writing 7401)
[14315400.103397] PM: Writing back config space on device 0000:06:00.1 =
at offset 5 (was 1, writing 7801)
[14315400.103401] PM: Writing back config space on device 0000:06:00.1 =
at offset 4 (was 1, writing 7c41)
[14315400.104354] serial 00:08: activated
[14315400.104389] sd 2:0:0:0: [sda] Starting disk
[14315400.423345] ata1: SATA link down (SStatus 0 SControl 300)
[14315400.423359] ata2: SATA link down (SStatus 0 SControl 300)
[14315406.543348] ata3.00: NODEV after polling detection
[14315406.543350] ata3.00: revalidation failed (errno=3D-2)
[14315406.543352] ata3: failed to recover some devices, retrying in 5 s=
ecs
[14315411.866672] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315411.890053] ata3.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315411.890055] ata3.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[14315411.896763] ata3.00: configured for UDMA/133
[14315411.896822] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315411.896836] sd 2:0:0:0: [sda] Write Protect is off
[14315411.896838] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[14315411.896859] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315413.007807] PM: Finishing wakeup.
[14315413.011872] Restarting tasks ... done.
[14315413.260004] usb 2-4: device descriptor read/64, error -62
[14315413.493337] usb 2-4: device descriptor read/64, error -62
[14315413.846670] usb 2-4: device descriptor read/64, error -62
[14315414.080004] usb 2-4: device descriptor read/64, error -62
[14315414.713340] usb 2-4: device not accepting address 10, error -62
[14315415.246670] usb 2-4: device not accepting address 11, error -62
[14315415.253522] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315612.296667] Restarting system.
[    0.000000] Linux version 2.6.26-rc2 (ranma@melchior) (gcc version 4=
=2E2.3 (Debian 4.2.3-5)) #6 PREEMPT Sun May 18 11:35:22 CEST 2008
[    0.000000] Command line: root=3D/dev/sda5 resume=3D/dev/sda6 vga=3D=
6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3Dnomsi ro
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
[    0.000000]  BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] max_pfn_mapped =3D 1048576
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000F7B80, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT 7FEE30C0, 004C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 7FEEC540, 00F4 (r3 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 7FEE3240, 92AD (r1 NVIDIA AWRDACPI     1000 M=
SFT  3000000)
[    0.000000] ACPI: FACS 7FEE0000, 0040
[    0.000000] ACPI: SSDT 7FEEC740, 0136 (r1 PTLTD  POWERNOW        1  =
LTP        1)
[    0.000000] ACPI: HPET 7FEEC8C0, 0038 (r1 Nvidia ASUSACPI 42302E31 A=
WRD       98)
[    0.000000] ACPI: MCFG 7FEEC940, 003C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: APIC 7FEEC680, 007C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-8eb01f] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-bfff] PGTABLE
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524000
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI=
 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 7ff0=
0000:70100000)
[14315324.233334] Built 1 zonelists in Zone order, mobility grouping on=
=2E  Total pages: 514863
[14315324.233334] Kernel command line: root=3D/dev/sda5 resume=3D/dev/s=
da6 vga=3D6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3D=
nomsi ro
[14315324.233334] Initializing CPU#0
[14315324.233334] PID hash table entries: 4096 (order: 12, 32768 bytes)
[14315324.233334] Extended CMOS year: 2000
[14315324.233334] TSC calibrated against PM_TIMER
[14315324.233334] time.c: Detected 2411.120 MHz processor.
[14315324.233334] Console: colour VGA+ 80x60
[14315324.233334] console [tty0] enabled
[14315324.233334] console [ttyS0] enabled
[14315324.233334] Dentry cache hash table entries: 262144 (order: 9, 20=
97152 bytes)
[14315324.233334] Inode-cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
[14315324.233334] Checking aperture...
[14315324.233334] Node 0: aperture @ a89c000000 size 32 MB
[14315324.233334] Aperture beyond 4GB. Ignoring.
[14315324.233334] No AGP bridge found
[14315324.233334] Memory: 2056088k/2096000k available (4489k kernel cod=
e, 39052k reserved, 1754k data, 256k init)
[14315324.316531] Calibrating delay using timer specific routine.. 4827=
=2E21 BogoMIPS (lpj=3D8041950)
[14315324.323020] Mount-cache hash table entries: 256
[14315324.326661] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64=
 bytes/line)
[14315324.329994] CPU: L2 Cache: 512K (64 bytes/line)
[14315324.333327] CPU: AMD Athlon(tm) 64 Processor 3800+ stepping 01
[14315324.339621] ACPI: Core revision 20080321
[14315324.353326] enabled ExtINT on CPU#0
[14315324.356659] ENABLING IO-APIC IRQs
[14315324.359992] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1
[14315324.396295] Using local APIC timer interrupts.
[14315324.403323] Detected 12.557 MHz APIC timer.
[14315324.406656] net_namespace: 1160 bytes
[14315324.409989] NET: Registered protocol family 16
[14315324.413322] No dock devices found.
[14315324.416655] TOM: 0000000080000000 aka 2048M
[14315324.419988] ACPI: bus type pci registered
[14315324.423321] PCI: Using configuration type 1 for base access
[14315324.438522] ACPI: Interpreter enabled
[14315324.442554] ACPI: (supports S0 S1 S3 S4 S5)
[14315324.447312] ACPI: Using IOAPIC for interrupt routing
[14315324.464177] ACPI: PCI Root Bridge [PCI0] (0000:00)
[14315324.469985] PCI: Transparent bridge - 0000:00:06.0
[14315324.538599] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.546647] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.553313] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.559235] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.566645] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.573312] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.579978] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.585898] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.593310] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.599977] ACPI: PCI Interrupt Link [LUBA] (IRQs *5 7 9 10 11 14=
 15)
[14315324.605872] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.612555] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.616642] ACPI: PCI Interrupt Link [LAZA] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.623308] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.629975] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.635896] ACPI: PCI Interrupt Link [LUB2] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.642552] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.649973] ACPI: PCI Interrupt Link [LSID] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.655875] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.662558] ACPI: PCI Interrupt Link [LSA2] (IRQs *5 7 9 10 11 14=
 15)
[14315324.666639] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disable=
d.
[14315324.672244] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disable=
d.
[14315324.678909] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[14315324.683304] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disable=
d.
[14315324.688915] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disable=
d.
[14315324.695579] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0, disable=
d.
[14315324.702248] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[14315324.707916] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disable=
d.
[14315324.714994] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[14315324.721976] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[14315324.728799] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[14315324.735483] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.743231] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.749880] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[14315324.755472] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[14315324.762132] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.769881] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.776562] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[14315324.782148] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[14315324.788805] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[14315324.793301] Linux Plug and Play Support v0.97 (c) Adam Belay
[14315324.796634] pnp: PnP ACPI init
[14315324.799968] ACPI: bus type pnp registered
[14315324.810354] pnp: PnP ACPI: found 13 devices
[14315324.814902] ACPI: ACPI bus type pnp unregistered
[14315324.819992] SCSI subsystem initialized
[14315324.824206] usbcore: registered new interface driver usbfs
[14315324.829968] usbcore: registered new interface driver hub
[14315324.833301] usbcore: registered new device driver usb
[14315324.836635] PCI: Using ACPI for IRQ routing
[14315324.839968] testing the IO APIC.......................
[14315324.843301]=20
[14315324.845349] .................................... done.
[14315324.860815] Bluetooth: Core ver 2.11
[14315324.864839] NET: Registered protocol family 31
[14315324.869646] Bluetooth: HCI device and connection manager initiali=
zed
[14315324.873301] Bluetooth: HCI socket layer initialized
[14315324.876634] DMAR:parse DMAR table failure.
[14315324.887862] system 00:01: ioport range 0x1000-0x107f has been res=
erved
[14315324.894747] system 00:01: ioport range 0x1080-0x10ff has been res=
erved
[14315324.901634] system 00:01: ioport range 0x1400-0x147f has been res=
erved
[14315324.908520] system 00:01: ioport range 0x1480-0x14ff has been res=
erved
[14315324.915410] system 00:01: ioport range 0x1800-0x187f has been res=
erved
[14315324.922294] system 00:01: ioport range 0x1880-0x18ff has been res=
erved
[14315324.929188] system 00:02: ioport range 0x4d0-0x4d1 has been reser=
ved
[14315324.935897] system 00:02: ioport range 0x800-0x87f has been reser=
ved
[14315324.942611] system 00:02: ioport range 0x290-0x297 has been reser=
ved
[14315324.949335] system 00:0b: iomem range 0xf0000000-0xf3ffffff could=
 not be reserved
[14315324.957263] system 00:0c: iomem range 0xd2800-0xd3fff has been re=
served
[14315324.964233] system 00:0c: iomem range 0xf0000-0xf7fff could not b=
e reserved
[14315324.973183] system 00:0c: iomem range 0xf8000-0xfbfff could not b=
e reserved
[14315324.980589] system 00:0c: iomem range 0xfc000-0xfffff could not b=
e reserved
[14315324.987997] system 00:0c: iomem range 0xfefff000-0xfefff0ff could=
 not be reserved
[14315324.995923] system 00:0c: iomem range 0x7fee0000-0x7fefffff could=
 not be reserved
[14315325.003378] system 00:0c: iomem range 0xffff0000-0xffffffff could=
 not be reserved
[14315325.011302] system 00:0c: iomem range 0x0-0x9ffff could not be re=
served
[14315325.018278] system 00:0c: iomem range 0x100000-0x7fedffff could n=
ot be reserved
[14315325.026241] system 00:0c: iomem range 0xfec00000-0xfec00fff could=
 not be reserved
[14315325.034006] system 00:0c: iomem range 0xfee00000-0xfeefffff could=
 not be reserved
[14315325.041932] system 00:0c: iomem range 0xfefff000-0xfeffffff could=
 not be reserved
[14315325.049882] system 00:0c: iomem range 0xfff80000-0xfff80fff could=
 not be reserved
[14315325.057807] system 00:0c: iomem range 0xfff90000-0xfffbffff could=
 not be reserved
[14315325.065760] system 00:0c: iomem range 0xfffed000-0xfffeffff could=
 not be reserved
[14315325.074037] PCI: Bridge: 0000:00:06.0
[14315325.078065]   IO window: 9000-9fff
[14315325.081837]   MEM window: 0xfde00000-0xfdefffff
[14315325.086733]   PREFETCH window: disabled.
[14315325.091028] PCI: Bridge: 0000:00:0a.0
[14315325.095058]   IO window: 8000-8fff
[14315325.099712]   MEM window: 0xfdd00000-0xfddfffff
[14315325.103489]   PREFETCH window: 0x00000000e8000000-0x00000000effff=
fff
[14315325.110202] PCI: Bridge: 0000:00:0b.0
[14315325.114224]   IO window: disabled.
[14315325.117990]   MEM window: disabled.
[14315325.122921]   PREFETCH window: disabled.
[14315325.126787] PCI: Bridge: 0000:00:0c.0
[14315325.130818]   IO window: disabled.
[14315325.134590]   MEM window: disabled.
[14315325.138441]   PREFETCH window: disabled.
[14315325.142758] PCI: Bridge: 0000:00:0d.0
[14315325.146790]   IO window: disabled.
[14315325.150554]   MEM window: disabled.
[14315325.154413]   PREFETCH window: disabled.
[14315325.158706] PCI: Bridge: 0000:00:0e.0
[14315325.163030]   IO window: 6000-7fff
[14315325.166794]   MEM window: 0xfdc00000-0xfdcfffff
[14315325.170837]   PREFETCH window: disabled.
[14315325.175744] PCI: Bridge: 0000:00:0f.0
[14315325.179776]   IO window: disabled.
[14315325.183548]   MEM window: disabled.
[14315325.187399]   PREFETCH window: disabled.
[14315325.191763] NET: Registered protocol family 2
[14315325.229003] IP route cache hash table entries: 65536 (order: 7, 5=
24288 bytes)
[14315325.237129] TCP established hash table entries: 262144 (order: 10=
, 4194304 bytes)
[14315325.246670] TCP bind hash table entries: 65536 (order: 7, 524288 =
bytes)
[14315325.259888] TCP: Hash tables configured (established 262144 bind =
65536)
[14315325.266865] TCP reno registered
[14315325.278698] NET: Registered protocol family 1
[14315325.284352] Installing knfsd (copyright (C) 1996 okir@monad.swb.d=
e).
[14315325.291285] JFFS2 version 2.2. (NAND) =C3=82=C2=A9 2001-2006 Red =
Hat, Inc.
[14315325.297708] fuse init (API version 7.9)
[14315325.302554] SGI XFS with security attributes, large block/inode n=
umbers, no debug enabled
[14315325.310218] msgmni has been set to 4016 for ipc namespace fffffff=
f807eda90
[14315325.317536] Block layer SCSI generic (bsg) driver version 0.4 loa=
ded (major 254)
[14315325.326186] io scheduler noop registered
[14315325.330474] io scheduler anticipatory registered
[14315325.335459] io scheduler deadline registered
[14315325.340091] io scheduler cfq registered (default)
[14315325.357115] pci 0000:00:05.0: Enabling HT MSI Mapping
[14315325.362537] pci 0000:00:05.1: Enabling HT MSI Mapping
[14315325.367651] pci 0000:00:05.2: Enabling HT MSI Mapping
[14315325.373084] pci 0000:00:06.0: Enabling HT MSI Mapping
[14315325.378521] pci 0000:00:08.0: Enabling HT MSI Mapping
[14315325.383948] pci 0000:00:09.0: Enabling HT MSI Mapping
[14315325.389388] pci 0000:00:0a.0: Enabling HT MSI Mapping
[14315325.394822] pci 0000:00:0b.0: Enabling HT MSI Mapping
[14315325.400246] pci 0000:00:0c.0: Enabling HT MSI Mapping
[14315325.405689] pci 0000:00:0d.0: Enabling HT MSI Mapping
[14315325.411113] pci 0000:00:0e.0: Enabling HT MSI Mapping
[14315325.416557] pci 0000:00:0f.0: Enabling HT MSI Mapping
[14315325.422091] assign_interrupt_mode Found MSI capability
[14315325.427484] assign_interrupt_mode Found MSI capability
[14315325.433105] assign_interrupt_mode Found MSI capability
[14315325.438686] assign_interrupt_mode Found MSI capability
[14315325.444250] assign_interrupt_mode Found MSI capability
[14315325.449841] assign_interrupt_mode Found MSI capability
[14315325.455617] input: Power Button (FF) as /class/input/input0
[14315325.461553] ACPI: Power Button (FF) [PWRF]
[14315325.466082] input: Power Button (CM) as /class/input/input1
[14315325.472021] ACPI: Power Button (CM) [PWRB]
[14315325.476585] ACPI: PNP0C0B:00 is registered as cooling_device0
[14315325.482691] ACPI: Fan [FAN] (on)
[14315325.486398] ACPI: ACPI0007:00 is registered as cooling_device1
[14315325.493392] ACPI: LNXTHERM:01 is registered as thermal_zone0
[14315325.499659] ACPI: Thermal Zone [THRM] (40 C)
[14315325.525106] Real Time Clock Driver v1.12ac
[14315325.529568] Linux agpgart interface v0.103
[14315325.532399] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, =
IRQ sharing disabled
[14315325.542501] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550=
A
[14315325.549175] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.555688] loop: module loaded
[14315325.559203] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[14315325.564187] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[14315325.570682] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[14315325.577137] e100: Copyright(c) 1999-2006 Intel Corporation
[14315325.583032] tun: Universal TUN/TAP device driver, 1.6
[14315325.589210] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com=
>
[14315325.595839] Driver 'sd' needs updating - please use bus_type meth=
ods
[14315325.602576] Driver 'sr' needs updating - please use bus_type meth=
ods
[14315325.609805] ACPI: PCI Interrupt Link [APC7] enabled at IRQ 16
[14315325.615923] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315326.627019] ahci 0000:06:00.0: AHCI 0001.0000 32 slots 2 ports 3 =
Gbps 0x3 impl SATA mode
[14315326.635549] ahci 0000:06:00.0: flags: 64bit ncq pm led clo pmp pi=
o slum part=20
[14315326.643329] scsi0 : ahci
[14315326.646322] scsi1 : ahci
[14315326.649308] ata1: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe100 irq 16
[14315326.658929] ata2: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe180 irq 16
[14315326.984914] ata1: SATA link down (SStatus 0 SControl 300)
[14315327.308606] ata2: SATA link down (SStatus 0 SControl 300)
[14315327.313816] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
[14315327.319931] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315327.329949] sata_nv 0000:00:05.0: Using SWNCQ mode
[14315327.335279] scsi2 : sata_nv
[14315327.338502] scsi3 : sata_nv
[14315327.341852] ata3: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd=
c00 irq 23
[14315327.349253] ata4: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd=
c08 irq 23
[14315327.827599] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315327.843335] ata3.00: ATA-8: SAMSUNG HD501LJ, CR100-12, max UDMA7
[14315327.846670] ata3.00: 976773168 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
[14315327.863118] ata3.00: configured for UDMA/133
[14315328.184653] ata4: SATA link down (SStatus 0 SControl 300)
[14315328.212768] isa bounce pool size: 16 pages
[14315328.216734] scsi 2:0:0:0: Direct-Access     ATA      SAMSUNG HD50=
1LJ  CR10 PQ: 0 ANSI: 5
[14315328.224604] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.233113] sd 2:0:0:0: [sda] Write Protect is off
[14315328.237481] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.247004] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.254585] sd 2:0:0:0: [sda] Write Protect is off
[14315328.259796] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.269280]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[14315328.313519] sd 2:0:0:0: [sda] Attached SCSI disk
[14315328.329875] sd 2:0:0:0: Attached scsi generic sg0 type 0
[14315328.336942] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
[14315328.343065] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315328.353047] sata_nv 0000:00:05.1: Using SWNCQ mode
[14315328.359946] scsi4 : sata_nv
[14315328.360002] scsi5 : sata_nv
[14315328.363351] ata5: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc=
800 irq 22
[14315328.373142] ata6: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc=
808 irq 22
[14315328.698536] ata5: SATA link down (SStatus 0 SControl 300)
[14315329.045554] ata6: SATA link down (SStatus 0 SControl 300)
[14315329.073141] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 21
[14315329.076678] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315329.087412] sata_nv 0000:00:05.2: Using SWNCQ mode
[14315329.092739] scsi6 : sata_nv
[14315329.095966] scsi7 : sata_nv
[14315329.099316] ata7: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0=
xb400 irq 21
[14315329.106890] ata8: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0=
xb408 irq 21
[14315329.432325] ata7: SATA link down (SStatus 0 SControl 300)
[14315329.918655] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315329.933316] ata8.00: ATAPI: TSSTcorp CDDVDW SH-S203B, SB00, max U=
DMA/100
[14315329.952913] ata8.00: configured for UDMA/100
[14315329.969254] scsi 7:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S2=
03B  SB00 PQ: 0 ANSI: 5
[14315329.980029] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa=
/form2 cdda tray
[14315329.987953] Uniform CD-ROM driver Revision: 3.20
[14315329.993096] sr 7:0:0:0: Attached scsi generic sg1 type 5
[14315329.999493] block2mtd: version $Revision: 1.30 $
[14315330.005699] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 20
[14315330.011822] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315330.021056] ehci_hcd 0000:00:02.1: EHCI Host Controller
[14315330.026715] ehci_hcd 0000:00:02.1: new USB bus registered, assign=
ed bus number 1
[14315330.034576] ehci_hcd 0000:00:02.1: debug port 1
[14315330.039724] ehci_hcd 0000:00:02.1: irq 20, io mem 0xfe02e000
[14315330.055048] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, dr=
iver 10 Dec 2004
[14315330.069012] usb usb1: configuration #1 chosen from 1 choice
[14315330.073896] hub 1-0:1.0: USB hub found
[14315330.079936] hub 1-0:1.0: 10 ports detected
[14315330.185539] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[14315330.190004] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315330.200849] ohci_hcd 0000:00:02.0: OHCI Host Controller
[14315330.206492] ohci_hcd 0000:00:02.0: new USB bus registered, assign=
ed bus number 2
[14315330.214339] ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
[14315330.273335] usb usb2: configuration #1 chosen from 1 choice
[14315330.279299] hub 2-0:1.0: USB hub found
[14315330.283419] hub 2-0:1.0: 10 ports detected
[14315330.363216] hub 1-0:1.0: unable to enumerate USB device on port 1
[14315330.393223] USB Universal Host Controller Interface driver v3.0
[14315330.539480] hub 1-0:1.0: unable to enumerate USB device on port 3
[14315330.716234] hub 1-0:1.0: unable to enumerate USB device on port 4
[14315330.720044] usbcore: registered new interface driver usblp
[14315330.726530] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq =
1
[14315330.733065] PNP: PS/2 appears to have AUX port disabled, if this =
is incorrect please boot with i8042.nopnp
[14315330.743243] serio: i8042 KBD port at 0x60,0x64 irq 1
[14315330.749124] mice: PS/2 mouse device common for all mice
[14315330.777923] i2c /dev entries driver
[14315330.781899] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[14315330.788147] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[14315330.793649] it87: Found IT8716F chip at 0x290, revision 0
[14315330.799853] it87: in3 is VCC (+5V)
[14315330.803618] it87: in7 is VCCH (+5V Stand-By)
[14315330.820001] input: AT Translated Set 2 keyboard as /class/input/i=
nput2
[14315330.852149] md: raid1 personality registered for level 1
[14315330.856737] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initi=
alised: dm-devel@redhat.com
[14315330.865968] Bluetooth: HCI USB driver ver 2.9
[14315330.959508] usb 2-1: new low speed USB device using ohci_hcd and =
address 2
[14315331.106668] usb 2-1: configuration #1 chosen from 1 choice
[14315331.365522] usb 2-3: new low speed USB device using ohci_hcd and =
address 3
[14315331.523334] usb 2-3: configuration #1 chosen from 1 choice
[14315331.791882] usb 2-4: new full speed USB device using ohci_hcd and=
 address 4
[14315331.923338] usb 2-4: device descriptor read/64, error -62
[14315332.156671] usb 2-4: device descriptor read/64, error -62
[14315332.385512] usb 2-4: new full speed USB device using ohci_hcd and=
 address 5
[14315332.516671] usb 2-4: device descriptor read/64, error -62
[14315332.750004] usb 2-4: device descriptor read/64, error -62
[14315332.978854] usb 2-4: new full speed USB device using ohci_hcd and=
 address 6
[14315333.390748] usb 2-4: device not accepting address 6, error -62
[14315333.516035] usb 2-4: new full speed USB device using ohci_hcd and=
 address 7
[14315333.928002] usb 2-4: device not accepting address 7, error -62
[14315333.933337] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315333.939833] usbcore: registered new interface driver hci_usb
[14315333.946005] Bluetooth: HCI UART driver ver 2.2
[14315333.952074] Bluetooth: HCI H4 protocol initialized
[14315333.956891] Bluetooth: HCI BCSP protocol initialized
[14315333.962216] cpuidle: using governor ladder
[14315333.966677] cpuidle: using governor menu
[14315333.976667] input: Microsoft Microsoft 3-Button Mouse with Intell=
iEye(TM) as /class/input/input3
[14315334.007962] input: USB HID v1.10 Mouse [Microsoft Microsoft 3-But=
ton Mouse with IntelliEye(TM)] on usb-0000:00:02.0-1
[14315334.029231] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input4
[14315334.059819] input: USB HID v1.11 Keyboard [Microsoft Natural=C2=AE=
 Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.080001] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input5
[14315334.114671] input: USB HID v1.11 Device [Microsoft Natural=C2=AE =
Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.124868] usbcore: registered new interface driver usbhid
[14315334.130216] usbhid: v2.6:USB HID core driver
[14315334.136227] Advanced Linux Sound Architecture Driver Version 1.0.=
16.
[14315334.143100] ALSA device list:
[14315334.146439]   No soundcards found.
[14315334.148263] GACT probability on
[14315334.151775] Mirror/redirect action on
[14315334.155986] u32 classifier
[14315334.159139]     Performance counters on
[14315334.163338]     input device check on=20
[14315334.169933]     Actions configured=20
[14315334.174093] IPv4 over IPv4 tunneling driver
[14315334.178153] ip_tables: (C) 2000-2006 Netfilter Core Team
[14315334.183852] TCP bic registered
[14315334.187272] TCP cubic registered
[14315334.190861] TCP westwood registered
[14315334.194711] TCP htcp registered
[14315334.198216] TCP vegas registered
[14315334.203110] TCP yeah registered
[14315334.206615] Initializing XFRM netlink socket
[14315334.210252] NET: Registered protocol family 10
[14315334.216668] IPv6 over IPv4 tunneling driver
[14315334.221013] NET: Registered protocol family 17
[14315334.225821] NET: Registered protocol family 15
[14315334.230672] Bridge firewalling registered
[14315334.235850] Bluetooth: L2CAP ver 2.9
[14315334.239790] Bluetooth: L2CAP socket layer initialized
[14315334.244216] Bluetooth: SCO (Voice Link) ver 0.5
[14315334.249632] Bluetooth: SCO socket layer initialized
[14315334.254546] Bluetooth: RFCOMM socket layer initialized
[14315334.260053] Bluetooth: RFCOMM TTY layer initialized
[14315334.265294] Bluetooth: RFCOMM ver 1.8
[14315334.269316] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[14315334.274983] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[14315334.280349] RPC: Registered udp transport module.
[14315334.286542] RPC: Registered tcp transport module.
[14315334.291717] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelat=
ech.com>
[14315334.298856] All bugs added by David S. Miller <davem@redhat.com>
[14315334.305222] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3800=
+ processors (1 cpu cores) (version 2.20.00)
[14315334.315605] powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
[14315334.321621] powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
[14315334.326741] powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
[14315334.332684] powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
[14315334.338630] powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
[14315334.346244] md: Autodetecting RAID arrays.
[14315334.353335] md: Scanned 0 and added 0 devices.
[14315334.354818] md: autorun ...
[14315334.358151] md: ... autorun DONE.
[14315334.378465] kjournald starting.  Commit interval 5 seconds
[14315334.383342] EXT3-fs: mounted filesystem with ordered data mode.
[14315334.389624] VFS: Mounted root (ext3 filesystem) readonly.
[14315334.395651] Freeing unused kernel memory: 256k freed
[14315335.296988] Marking TSC unstable due to cpufreq changes
[14315335.730021] Clocksource tsc unstable (delta =3D -255207325 ns)
[14315336.584945] scsi8 : pata_amd
[14315336.589421] scsi9 : pata_amd
[14315336.596373] ata9: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf=
000 irq 14
[14315336.601147] ata10: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0x=
f008 irq 15
[14315336.790573] ata9.01: ATAPI: Pioneer DVD-ROM ATAPIModel DVD-106S 0=
122, E1.22, max UDMA/66
[14315336.812378] ata9.01: configured for UDMA/66
[14315336.827906] scsi 8:0:1:0: CD-ROM            PIONEER  DVD-ROM DVD-=
106  1.22 PQ: 0 ANSI: 5
[14315336.840004] sr1: scsi3-mmc drive: 15x/40x cd/rw xa/form2 cdda tra=
y
[14315336.846642] sr 8:0:1:0: Attached scsi generic sg2 type 5
[14315336.860007] forcedeth: Reverse Engineered nForce ethernet driver.=
 Version 0.61.
[14315336.867120] ACPI: PCI Interrupt Link [APCH] enabled at IRQ 22
[14315336.873231] ACPI: PCI Interrupt 0000:00:08.0[A] -> Link [APCH] ->=
 GSI 22 (level, low) -> IRQ 22
[14315337.397509] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @=
 1, addr 00:17:31:aa:1e:89
[14315337.406414] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315337.432801] gameport: EMU10K1 is pci0000:01:08.1/gameport0, io 0x=
9800, speed 1200kHz
[14315337.439479] ACPI: PCI Interrupt Link [APC3] enabled at IRQ 18
[14315337.445834] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315337.456517] ALSA sound/pci/emu10k1/emu10k1_main.c:1748: vendor=3D=
0x1102, device=3D0x2, subsystem_vendor_id=3D0x80641102, subsystem_id=3D=
0x8064
[14315337.468844] ALSA sound/pci/emu10k1/emu10k1_main.c:1773: ACPI: PCI=
 Interrupt Link [AMC1] enabled at IRQ 21
[14315337.480007] ACPI: PCI Interrupt 0000:00:09.0[A] -> Link [AMC1] ->=
 GSI 21 (level, low) -> IRQ 21
[14315337.489810] Sound card name=3DSB Live 5.1
[14315338.004296] forcedeth 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @=
 1, addr 00:17:31:ac:c6:64
[14315338.013438] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315338.345625] Adding 3911788k swap on /dev/sda6.  Priority:-1 exten=
ts:1 across:3911788k
[14315338.512227] EXT3 FS on sda5, internal journal
[14315343.026843] br0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM fe=
ature.
[14315551.930261] PM: Syncing filesystems ... done.
[14315551.946724] PM: Preparing system for mem sleep
[14315551.960679] Freezing user space processes ... (elapsed 0.00 secon=
ds) done.
[14315551.969984] Freezing remaining freezable tasks ... (elapsed 0.00 =
seconds) done.
[14315551.978208] PM: Entering mem sleep
[14315551.981210] Suspending console(s)
[    0.000000] Command line: root=3D/dev/sda5 resume=3D/dev/sda6 vga=3D=
6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3Dnomsi ro
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
[    0.000000]  BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] max_pfn_mapped =3D 1048576
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000F7B80, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT 7FEE30C0, 004C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 7FEEC540, 00F4 (r3 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 7FEE3240, 92AD (r1 NVIDIA AWRDACPI     1000 M=
SFT  3000000)
[    0.000000] ACPI: FACS 7FEE0000, 0040
[    0.000000] ACPI: SSDT 7FEEC740, 0136 (r1 PTLTD  POWERNOW        1  =
LTP        1)
[    0.000000] ACPI: HPET 7FEEC8C0, 0038 (r1 Nvidia ASUSACPI 42302E31 A=
WRD       98)
[    0.000000] ACPI: MCFG 7FEEC940, 003C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: APIC 7FEEC680, 007C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-8eb01f] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-bfff] PGTABLE
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524000
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI=
 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 7ff0=
0000:70100000)
[14315324.233334] Built 1 zonelists in Zone order, mobility grouping on=
=2E  Total pages: 514863
[14315324.233334] Kernel command line: root=3D/dev/sda5 resume=3D/dev/s=
da6 vga=3D6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3D=
nomsi ro
[14315324.233334] Initializing CPU#0
[14315324.233334] PID hash table entries: 4096 (order: 12, 32768 bytes)
[14315324.233334] Extended CMOS year: 2000
[14315324.233334] TSC calibrated against PM_TIMER
[14315324.233334] time.c: Detected 2411.108 MHz processor.
[14315324.233334] Console: colour VGA+ 80x60
[14315324.233334] console [tty0] enabled
[14315324.233334] console [ttyS0] enabled
[14315324.233334] Dentry cache hash table entries: 262144 (order: 9, 20=
97152 bytes)
[14315324.233334] Inode-cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
[14315324.233334] Checking aperture...
[14315324.233334] Node 0: aperture @ a89c000000 size 32 MB
[14315324.233334] Aperture beyond 4GB. Ignoring.
[14315324.233334] No AGP bridge found
[14315324.233334] Memory: 2056088k/2096000k available (4489k kernel cod=
e, 39052k reserved, 1754k data, 256k init)
[14315324.316531] Calibrating delay using timer specific routine.. 4827=
=2E21 BogoMIPS (lpj=3D8041950)
[14315324.323020] Mount-cache hash table entries: 256
[14315324.326661] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64=
 bytes/line)
[14315324.329994] CPU: L2 Cache: 512K (64 bytes/line)
[14315324.333327] CPU: AMD Athlon(tm) 64 Processor 3800+ stepping 01
[14315324.339619] ACPI: Core revision 20080321
[14315324.353326] enabled ExtINT on CPU#0
[14315324.356659] ENABLING IO-APIC IRQs
[14315324.359992] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1
[14315324.396295] Using local APIC timer interrupts.
[14315324.403323] Detected 12.557 MHz APIC timer.
[14315324.406656] net_namespace: 1160 bytes
[14315324.409989] NET: Registered protocol family 16
[14315324.413322] No dock devices found.
[14315324.416655] TOM: 0000000080000000 aka 2048M
[14315324.419988] ACPI: bus type pci registered
[14315324.423321] PCI: Using configuration type 1 for base access
[14315324.438519] ACPI: Interpreter enabled
[14315324.442555] ACPI: (supports S0 S1 S3 S4 S5)
[14315324.447312] ACPI: Using IOAPIC for interrupt routing
[14315324.464178] ACPI: PCI Root Bridge [PCI0] (0000:00)
[14315324.469985] PCI: Transparent bridge - 0000:00:06.0
[14315324.538630] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.546647] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.553313] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.559229] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.566645] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.573312] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.579978] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.585889] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.593310] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.599977] ACPI: PCI Interrupt Link [LUBA] (IRQs *5 7 9 10 11 14=
 15)
[14315324.605890] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.612563] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.616642] ACPI: PCI Interrupt Link [LAZA] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.623308] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.629975] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.635888] ACPI: PCI Interrupt Link [LUB2] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.642536] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.649973] ACPI: PCI Interrupt Link [LSID] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.655892] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.662558] ACPI: PCI Interrupt Link [LSA2] (IRQs *5 7 9 10 11 14=
 15)
[14315324.666639] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disable=
d.
[14315324.672252] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disable=
d.
[14315324.678915] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[14315324.683304] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disable=
d.
[14315324.688913] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disable=
d.
[14315324.695579] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0, disable=
d.
[14315324.702246] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[14315324.707918] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disable=
d.
[14315324.714996] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[14315324.721986] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[14315324.728817] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[14315324.735489] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.743242] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.749905] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[14315324.755473] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[14315324.759968] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.766572] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.773230] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[14315324.778806] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[14315324.783301] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[14315324.786634] Linux Plug and Play Support v0.97 (c) Adam Belay
[14315324.789968] pnp: PnP ACPI init
[14315324.793301] ACPI: bus type pnp registered
[14315324.803953] pnp: PnP ACPI: found 13 devices
[14315324.808500] ACPI: ACPI bus type pnp unregistered
[14315324.813301] SCSI subsystem initialized
[14315324.816635] usbcore: registered new interface driver usbfs
[14315324.819968] usbcore: registered new interface driver hub
[14315324.823301] usbcore: registered new device driver usb
[14315324.826635] PCI: Using ACPI for IRQ routing
[14315324.829968] testing the IO APIC.......................
[14315324.833301]=20
[14315324.835357] .................................... done.
[14315324.850590] Bluetooth: Core ver 2.11
[14315324.854607] NET: Registered protocol family 31
[14315324.859414] Bluetooth: HCI device and connection manager initiali=
zed
[14315324.863301] Bluetooth: HCI socket layer initialized
[14315324.866634] DMAR:parse DMAR table failure.
[14315324.877859] system 00:01: ioport range 0x1000-0x107f has been res=
erved
[14315324.884744] system 00:01: ioport range 0x1080-0x10ff has been res=
erved
[14315324.891632] system 00:01: ioport range 0x1400-0x147f has been res=
erved
[14315324.898518] system 00:01: ioport range 0x1480-0x14ff has been res=
erved
[14315324.905407] system 00:01: ioport range 0x1800-0x187f has been res=
erved
[14315324.912293] system 00:01: ioport range 0x1880-0x18ff has been res=
erved
[14315324.919186] system 00:02: ioport range 0x4d0-0x4d1 has been reser=
ved
[14315324.925902] system 00:02: ioport range 0x800-0x87f has been reser=
ved
[14315324.932618] system 00:02: ioport range 0x290-0x297 has been reser=
ved
[14315324.939340] system 00:0b: iomem range 0xf0000000-0xf3ffffff could=
 not be reserved
[14315324.947269] system 00:0c: iomem range 0xd2800-0xd3fff has been re=
served
[14315324.954239] system 00:0c: iomem range 0xf0000-0xf7fff could not b=
e reserved
[14315324.963192] system 00:0c: iomem range 0xf8000-0xfbfff could not b=
e reserved
[14315324.970599] system 00:0c: iomem range 0xfc000-0xfffff could not b=
e reserved
[14315324.978004] system 00:0c: iomem range 0xfefff000-0xfefff0ff could=
 not be reserved
[14315324.985931] system 00:0c: iomem range 0x7fee0000-0x7fefffff could=
 not be reserved
[14315324.993388] system 00:0c: iomem range 0xffff0000-0xffffffff could=
 not be reserved
[14315325.001315] system 00:0c: iomem range 0x0-0x9ffff could not be re=
served
[14315325.008289] system 00:0c: iomem range 0x100000-0x7fedffff could n=
ot be reserved
[14315325.016251] system 00:0c: iomem range 0xfec00000-0xfec00fff could=
 not be reserved
[14315325.024016] system 00:0c: iomem range 0xfee00000-0xfeefffff could=
 not be reserved
[14315325.031942] system 00:0c: iomem range 0xfefff000-0xfeffffff could=
 not be reserved
[14315325.039894] system 00:0c: iomem range 0xfff80000-0xfff80fff could=
 not be reserved
[14315325.047820] system 00:0c: iomem range 0xfff90000-0xfffbffff could=
 not be reserved
[14315325.055771] system 00:0c: iomem range 0xfffed000-0xfffeffff could=
 not be reserved
[14315325.064052] PCI: Bridge: 0000:00:06.0
[14315325.068086]   IO window: 9000-9fff
[14315325.071858]   MEM window: 0xfde00000-0xfdefffff
[14315325.076753]   PREFETCH window: disabled.
[14315325.081045] PCI: Bridge: 0000:00:0a.0
[14315325.085078]   IO window: 8000-8fff
[14315325.089731]   MEM window: 0xfdd00000-0xfddfffff
[14315325.093510]   PREFETCH window: 0x00000000e8000000-0x00000000effff=
fff
[14315325.100223] PCI: Bridge: 0000:00:0b.0
[14315325.104256]   IO window: disabled.
[14315325.108028]   MEM window: disabled.
[14315325.112956]   PREFETCH window: disabled.
[14315325.116823] PCI: Bridge: 0000:00:0c.0
[14315325.120854]   IO window: disabled.
[14315325.124627]   MEM window: disabled.
[14315325.128486]   PREFETCH window: disabled.
[14315325.132804] PCI: Bridge: 0000:00:0d.0
[14315325.136833]   IO window: disabled.
[14315325.140598]   MEM window: disabled.
[14315325.144457]   PREFETCH window: disabled.
[14315325.148749] PCI: Bridge: 0000:00:0e.0
[14315325.153075]   IO window: 6000-7fff
[14315325.156848]   MEM window: 0xfdc00000-0xfdcfffff
[14315325.160891]   PREFETCH window: disabled.
[14315325.165799] PCI: Bridge: 0000:00:0f.0
[14315325.169829]   IO window: disabled.
[14315325.173594]   MEM window: disabled.
[14315325.177452]   PREFETCH window: disabled.
[14315325.181817] NET: Registered protocol family 2
[14315325.219002] IP route cache hash table entries: 65536 (order: 7, 5=
24288 bytes)
[14315325.227130] TCP established hash table entries: 262144 (order: 10=
, 4194304 bytes)
[14315325.236670] TCP bind hash table entries: 65536 (order: 7, 524288 =
bytes)
[14315325.249900] TCP: Hash tables configured (established 262144 bind =
65536)
[14315325.256879] TCP reno registered
[14315325.268719] NET: Registered protocol family 1
[14315325.274357] Installing knfsd (copyright (C) 1996 okir@monad.swb.d=
e).
[14315325.281295] JFFS2 version 2.2. (NAND) =C3=82=C2=A9 2001-2006 Red =
Hat, Inc.
[14315325.287717] fuse init (API version 7.9)
[14315325.292566] SGI XFS with security attributes, large block/inode n=
umbers, no debug enabled
[14315325.300231] msgmni has been set to 4016 for ipc namespace fffffff=
f807eda90
[14315325.307546] Block layer SCSI generic (bsg) driver version 0.4 loa=
ded (major 254)
[14315325.316197] io scheduler noop registered
[14315325.320488] io scheduler anticipatory registered
[14315325.325471] io scheduler deadline registered
[14315325.330093] io scheduler cfq registered (default)
[14315325.347124] pci 0000:00:05.0: Enabling HT MSI Mapping
[14315325.352550] pci 0000:00:05.1: Enabling HT MSI Mapping
[14315325.357664] pci 0000:00:05.2: Enabling HT MSI Mapping
[14315325.363096] pci 0000:00:06.0: Enabling HT MSI Mapping
[14315325.368532] pci 0000:00:08.0: Enabling HT MSI Mapping
[14315325.373958] pci 0000:00:09.0: Enabling HT MSI Mapping
[14315325.379400] pci 0000:00:0a.0: Enabling HT MSI Mapping
[14315325.384832] pci 0000:00:0b.0: Enabling HT MSI Mapping
[14315325.390257] pci 0000:00:0c.0: Enabling HT MSI Mapping
[14315325.395702] pci 0000:00:0d.0: Enabling HT MSI Mapping
[14315325.401128] pci 0000:00:0e.0: Enabling HT MSI Mapping
[14315325.406570] pci 0000:00:0f.0: Enabling HT MSI Mapping
[14315325.412103] assign_interrupt_mode Found MSI capability
[14315325.417495] assign_interrupt_mode Found MSI capability
[14315325.423117] assign_interrupt_mode Found MSI capability
[14315325.428699] assign_interrupt_mode Found MSI capability
[14315325.434261] assign_interrupt_mode Found MSI capability
[14315325.439852] assign_interrupt_mode Found MSI capability
[14315325.445630] input: Power Button (FF) as /class/input/input0
[14315325.451566] ACPI: Power Button (FF) [PWRF]
[14315325.456096] input: Power Button (CM) as /class/input/input1
[14315325.462032] ACPI: Power Button (CM) [PWRB]
[14315325.466597] ACPI: PNP0C0B:00 is registered as cooling_device0
[14315325.472703] ACPI: Fan [FAN] (on)
[14315325.476412] ACPI: ACPI0007:00 is registered as cooling_device1
[14315325.483407] ACPI: LNXTHERM:01 is registered as thermal_zone0
[14315325.489672] ACPI: Thermal Zone [THRM] (40 C)
[14315325.515084] Real Time Clock Driver v1.12ac
[14315325.519551] Linux agpgart interface v0.103
[14315325.522405] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, =
IRQ sharing disabled
[14315325.532506] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550=
A
[14315325.539181] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.545695] loop: module loaded
[14315325.549211] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[14315325.554192] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[14315325.560689] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[14315325.567142] e100: Copyright(c) 1999-2006 Intel Corporation
[14315325.573040] tun: Universal TUN/TAP device driver, 1.6
[14315325.579215] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com=
>
[14315325.585843] Driver 'sd' needs updating - please use bus_type meth=
ods
[14315325.592581] Driver 'sr' needs updating - please use bus_type meth=
ods
[14315325.599810] ACPI: PCI Interrupt Link [APC7] enabled at IRQ 16
[14315325.605928] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315326.617012] ahci 0000:06:00.0: AHCI 0001.0000 32 slots 2 ports 3 =
Gbps 0x3 impl SATA mode
[14315326.625543] ahci 0000:06:00.0: flags: 64bit ncq pm led clo pmp pi=
o slum part=20
[14315326.633318] scsi0 : ahci
[14315326.636318] scsi1 : ahci
[14315326.639310] ata1: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe100 irq 16
[14315326.648938] ata2: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe180 irq 16
[14315326.974913] ata1: SATA link down (SStatus 0 SControl 300)
[14315327.298606] ata2: SATA link down (SStatus 0 SControl 300)
[14315327.303821] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
[14315327.309930] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315327.319951] sata_nv 0000:00:05.0: Using SWNCQ mode
[14315327.325283] scsi2 : sata_nv
[14315327.328505] scsi3 : sata_nv
[14315327.331854] ata3: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd=
c00 irq 23
[14315327.339256] ata4: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd=
c08 irq 23
[14315327.817593] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315327.850001] ata3.00: ATA-8: SAMSUNG HD501LJ, CR100-12, max UDMA7
[14315327.853336] ata3.00: 976773168 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
[14315327.869783] ata3.00: configured for UDMA/133
[14315328.191322] ata4: SATA link down (SStatus 0 SControl 300)
[14315328.219446] isa bounce pool size: 16 pages
[14315328.223400] scsi 2:0:0:0: Direct-Access     ATA      SAMSUNG HD50=
1LJ  CR10 PQ: 0 ANSI: 5
[14315328.231269] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.239780] sd 2:0:0:0: [sda] Write Protect is off
[14315328.244146] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.253670] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.261251] sd 2:0:0:0: [sda] Write Protect is off
[14315328.266462] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.275948]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[14315328.354882] sd 2:0:0:0: [sda] Attached SCSI disk
[14315328.361206] sd 2:0:0:0: Attached scsi generic sg0 type 0
[14315328.368274] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
[14315328.374396] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315328.383609] sata_nv 0000:00:05.1: Using SWNCQ mode
[14315328.389578] scsi4 : sata_nv
[14315328.392808] scsi5 : sata_nv
[14315328.396161] ata5: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc=
800 irq 22
[14315328.403566] ata6: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc=
808 irq 22
[14315328.728977] ata5: SATA link down (SStatus 0 SControl 300)
[14315329.062242] ata6: SATA link down (SStatus 0 SControl 300)
[14315329.089804] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 21
[14315329.093344] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315329.104073] sata_nv 0000:00:05.2: Using SWNCQ mode
[14315329.109399] scsi6 : sata_nv
[14315329.112628] scsi7 : sata_nv
[14315329.115977] ata7: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0=
xb400 irq 21
[14315329.123550] ata8: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0=
xb408 irq 21
[14315329.448978] ata7: SATA link down (SStatus 0 SControl 300)
[14315329.935319] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315329.949981] ata8.00: ATAPI: TSSTcorp CDDVDW SH-S203B, SB00, max U=
DMA/100
[14315329.969583] ata8.00: configured for UDMA/100
[14315329.985939] scsi 7:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S2=
03B  SB00 PQ: 0 ANSI: 5
[14315329.996671] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa=
/form2 cdda tray
[14315330.004588] Uniform CD-ROM driver Revision: 3.20
[14315330.009734] sr 7:0:0:0: Attached scsi generic sg1 type 5
[14315330.016179] block2mtd: version $Revision: 1.30 $
[14315330.022430] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 20
[14315330.028547] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315330.037781] ehci_hcd 0000:00:02.1: EHCI Host Controller
[14315330.043442] ehci_hcd 0000:00:02.1: new USB bus registered, assign=
ed bus number 1
[14315330.051310] ehci_hcd 0000:00:02.1: debug port 1
[14315330.056460] ehci_hcd 0000:00:02.1: irq 20, io mem 0xfe02e000
[14315330.071715] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, dr=
iver 10 Dec 2004
[14315330.085697] usb usb1: configuration #1 chosen from 1 choice
[14315330.090582] hub 1-0:1.0: USB hub found
[14315330.096621] hub 1-0:1.0: 10 ports detected
[14315330.202222] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[14315330.206671] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315330.217516] ohci_hcd 0000:00:02.0: OHCI Host Controller
[14315330.223160] ohci_hcd 0000:00:02.0: new USB bus registered, assign=
ed bus number 2
[14315330.231006] ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
[14315330.290001] usb usb2: configuration #1 chosen from 1 choice
[14315330.295968] hub 2-0:1.0: USB hub found
[14315330.300086] hub 2-0:1.0: 10 ports detected
[14315330.379883] hub 1-0:1.0: unable to enumerate USB device on port 1
[14315330.409890] USB Universal Host Controller Interface driver v3.0
[14315330.556147] hub 1-0:1.0: unable to enumerate USB device on port 3
[14315330.732887] hub 1-0:1.0: unable to enumerate USB device on port 4
[14315330.736710] usbcore: registered new interface driver usblp
[14315330.743197] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq =
1
[14315330.749732] PNP: PS/2 appears to have AUX port disabled, if this =
is incorrect please boot with i8042.nopnp
[14315330.759913] serio: i8042 KBD port at 0x60,0x64 irq 1
[14315330.765795] mice: PS/2 mouse device common for all mice
[14315330.794589] i2c /dev entries driver
[14315330.798559] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[14315330.804806] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[14315330.810309] it87: Found IT8716F chip at 0x290, revision 0
[14315330.816515] it87: in3 is VCC (+5V)
[14315330.820287] it87: in7 is VCCH (+5V Stand-By)
[14315330.836668] input: AT Translated Set 2 keyboard as /class/input/i=
nput2
[14315330.868855] md: raid1 personality registered for level 1
[14315330.873403] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initi=
alised: dm-devel@redhat.com
[14315330.882630] Bluetooth: HCI USB driver ver 2.9
[14315330.976170] usb 2-1: new low speed USB device using ohci_hcd and =
address 2
[14315331.123334] usb 2-1: configuration #1 chosen from 1 choice
[14315331.382183] usb 2-3: new low speed USB device using ohci_hcd and =
address 3
[14315331.540000] usb 2-3: configuration #1 chosen from 1 choice
[14315331.808552] usb 2-4: new full speed USB device using ohci_hcd and=
 address 4
[14315331.940004] usb 2-4: device descriptor read/64, error -62
[14315332.173337] usb 2-4: device descriptor read/64, error -62
[14315332.402153] usb 2-4: new full speed USB device using ohci_hcd and=
 address 5
[14315332.533337] usb 2-4: device descriptor read/64, error -62
[14315332.766671] usb 2-4: device descriptor read/64, error -62
[14315332.995496] usb 2-4: new full speed USB device using ohci_hcd and=
 address 6
[14315333.407402] usb 2-4: device not accepting address 6, error -62
[14315333.532699] usb 2-4: new full speed USB device using ohci_hcd and=
 address 7
[14315333.944651] usb 2-4: device not accepting address 7, error -62
[14315333.950004] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315333.956499] usbcore: registered new interface driver hci_usb
[14315333.962673] Bluetooth: HCI UART driver ver 2.2
[14315333.968739] Bluetooth: HCI H4 protocol initialized
[14315333.973557] Bluetooth: HCI BCSP protocol initialized
[14315333.978882] cpuidle: using governor ladder
[14315333.983344] cpuidle: using governor menu
[14315333.993334] input: Microsoft Microsoft 3-Button Mouse with Intell=
iEye(TM) as /class/input/input3
[14315334.024614] input: USB HID v1.10 Mouse [Microsoft Microsoft 3-But=
ton Mouse with IntelliEye(TM)] on usb-0000:00:02.0-1
[14315334.045900] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input4
[14315334.076496] input: USB HID v1.11 Keyboard [Microsoft Natural=C2=AE=
 Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.098026] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input5
[14315334.131356] input: USB HID v1.11 Device [Microsoft Natural=C2=AE =
Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.141553] usbcore: registered new interface driver usbhid
[14315334.146883] usbhid: v2.6:USB HID core driver
[14315334.152895] Advanced Linux Sound Architecture Driver Version 1.0.=
16.
[14315334.159761] ALSA device list:
[14315334.163099]   No soundcards found.
[14315334.164923] GACT probability on
[14315334.168433] Mirror/redirect action on
[14315334.172645] u32 classifier
[14315334.175798]     Performance counters on
[14315334.179997]     input device check on=20
[14315334.186593]     Actions configured=20
[14315334.190754] IPv4 over IPv4 tunneling driver
[14315334.194812] ip_tables: (C) 2000-2006 Netfilter Core Team
[14315334.200510] TCP bic registered
[14315334.203930] TCP cubic registered
[14315334.207519] TCP westwood registered
[14315334.211369] TCP htcp registered
[14315334.214874] TCP vegas registered
[14315334.219769] TCP yeah registered
[14315334.223274] Initializing XFRM netlink socket
[14315334.226913] NET: Registered protocol family 10
[14315334.233334] IPv6 over IPv4 tunneling driver
[14315334.237681] NET: Registered protocol family 17
[14315334.242488] NET: Registered protocol family 15
[14315334.247337] Bridge firewalling registered
[14315334.252514] Bluetooth: L2CAP ver 2.9
[14315334.256455] Bluetooth: L2CAP socket layer initialized
[14315334.260884] Bluetooth: SCO (Voice Link) ver 0.5
[14315334.266300] Bluetooth: SCO socket layer initialized
[14315334.271215] Bluetooth: RFCOMM socket layer initialized
[14315334.276722] Bluetooth: RFCOMM TTY layer initialized
[14315334.281964] Bluetooth: RFCOMM ver 1.8
[14315334.285986] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[14315334.291653] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[14315334.297017] RPC: Registered udp transport module.
[14315334.303211] RPC: Registered tcp transport module.
[14315334.308385] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelat=
ech.com>
[14315334.315522] All bugs added by David S. Miller <davem@redhat.com>
[14315334.321890] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3800=
+ processors (1 cpu cores) (version 2.20.00)
[14315334.332273] powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
[14315334.338288] powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
[14315334.343408] powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
[14315334.349345] powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
[14315334.355282] powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
[14315334.362884] md: Autodetecting RAID arrays.
[14315334.367252] md: Scanned 0 and added 0 devices.
[14315334.373309] md: autorun ...
[14315334.376465] md: ... autorun DONE.
[14315334.386667] EXT3-fs: INFO: recovery required on readonly filesyst=
em.
[14315334.393336] EXT3-fs: write access will be enabled during recovery=
=2E
[14315334.416725] kjournald starting.  Commit interval 5 seconds
[14315334.423089] EXT3-fs: recovery complete.
[14315334.435971] EXT3-fs: mounted filesystem with ordered data mode.
[14315334.439949] VFS: Mounted root (ext3 filesystem) readonly.
[14315334.446615] Freeing unused kernel memory: 256k freed
[14315335.296886] Marking TSC unstable due to cpufreq changes
[14315335.730020] Clocksource tsc unstable (delta =3D -255347879 ns)
[14315336.670291] scsi8 : pata_amd
[14315336.674553] scsi9 : pata_amd
[14315336.678547] ata9: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf=
000 irq 14
[14315336.685975] ata10: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0x=
f008 irq 15
[14315336.874470] ata9.01: ATAPI: Pioneer DVD-ROM ATAPIModel DVD-106S 0=
122, E1.22, max UDMA/66
[14315336.894149] ata9.01: configured for UDMA/66
[14315336.931286] scsi 8:0:1:0: CD-ROM            PIONEER  DVD-ROM DVD-=
106  1.22 PQ: 0 ANSI: 5
[14315336.943338] sr1: scsi3-mmc drive: 15x/40x cd/rw xa/form2 cdda tra=
y
[14315336.949995] sr 8:0:1:0: Attached scsi generic sg2 type 5
[14315336.956855] forcedeth: Reverse Engineered nForce ethernet driver.=
 Version 0.61.
[14315336.964127] ACPI: PCI Interrupt Link [APCH] enabled at IRQ 22
[14315336.970252] ACPI: PCI Interrupt 0000:00:08.0[A] -> Link [APCH] ->=
 GSI 22 (level, low) -> IRQ 22
[14315337.500998] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @=
 1, addr 00:17:31:aa:1e:89
[14315337.509811] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315337.536133] gameport: EMU10K1 is pci0000:01:08.1/gameport0, io 0x=
9800, speed 1200kHz
[14315337.543025] ACPI: PCI Interrupt Link [APC3] enabled at IRQ 18
[14315337.549160] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315337.560074] ALSA sound/pci/emu10k1/emu10k1_main.c:1748: vendor=3D=
0x1102, device=3D0x2, subsystem_vendor_id=3D0x80641102, subsystem_id=3D=
0x8064
[14315337.572708] ALSA sound/pci/emu10k1/emu10k1_main.c:1773: ACPI: PCI=
 Interrupt Link [AMC1] enabled at IRQ 21
[14315337.583341] ACPI: PCI Interrupt 0000:00:09.0[A] -> Sound card nam=
e=3DSB Live 5.1
[14315337.596675] Link [AMC1] -> GSI 21 (level, low) -> IRQ 21
[14315338.117626] forcedeth 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @=
 1, addr 00:17:31:ac:c6:64
[14315338.126767] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315339.355589] Adding 3911788k swap on /dev/sda6.  Priority:-1 exten=
ts:1 across:3911788k
[14315339.505606] EXT3 FS on sda5, internal journal
[14315344.943338] br0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM fe=
ature.
[14315426.797857] PM: Hibernation mode set to 'platform'
[14315426.810335] PM: Marking nosave pages: 000000000009f000 - 00000000=
00100000
[14315426.817965] PM: Basic memory bitmaps created
[14315426.822685] PM: Syncing filesystems ... done.
[14315426.830565] Freezing user space processes ... (elapsed 0.00 secon=
ds) done.
[14315426.839564] Freezing remaining freezable tasks ... (elapsed 0.00 =
seconds) done.
[14315426.847567] PM: Shrinking memory...  =08-=08done (0 pages freed)
[14315426.970882] PM: Freed 0 kbytes in 0.11 seconds (0.00 MB/s)
[14315426.977551] Suspending console(s)
[14315426.981319] sd 2:0:0:0: [sda] Synchronizing SCSI cache
[14315426.981542] ACPI handle has no context!
[14315426.983937] serial 00:08: disabled
[14315427.010050] ACPI: PCI interrupt for device 0000:06:00.0 disabled
[14315427.017068] ACPI: PCI interrupt for device 0000:01:08.0 disabled
[14315427.017078] ACPI handle has no context!
[14315427.030353] ACPI: PCI interrupt for device 0000:00:09.0 disabled
[14315427.043622] ACPI: PCI interrupt for device 0000:00:08.0 disabled
[14315427.056707] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14315427.056732] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14315427.056758] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14315427.056794] ACPI: PCI interrupt for device 0000:00:02.1 disabled
[14315427.056804] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14315427.056939] ACPI: Preparing to enter system sleep state S4
[14315427.057420] Extended CMOS year: 2000
[14315427.057466] PM: Creating hibernation image:=20
[14315427.059998] PM: Need to copy 58014 pages
[14315427.059998] PM: Normal pages needed: 58014 + 1024 + 38, available=
 pages: 465888
[14315427.059998] PM: Hibernation image created (58014 pages copied)
[14315427.059998] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70=
10600070106
[14315427.059998] svm_cpu_init: svm_data is NULL on 0
[14315427.059998] Extended CMOS year: 2000
[14315427.069771] ACPI: Unable to turn cooling device [ffff81007f842890=
] 'off'
[14315427.069821] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315427.069826] PCI: Setting latency timer of device 0000:00:02.0 to =
64
[14315427.090058] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315427.090062] PCI: Setting latency timer of device 0000:00:02.1 to =
64
[14315427.090076] PM: Writing back config space on device 0000:00:04.0 =
at offset 1 (was b00001, writing b00005)
[14315427.090082] PCI: Setting latency timer of device 0000:00:04.0 to =
64
[14315427.090095] PM: Writing back config space on device 0000:00:05.0 =
at offset 1 (was b00003, writing b00007)
[14315427.090102] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315427.090105] PCI: Setting latency timer of device 0000:00:05.0 to =
64
[14315427.090117] PM: Writing back config space on device 0000:00:05.1 =
at offset 1 (was b00003, writing b00007)
[14315427.090123] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315427.090126] PCI: Setting latency timer of device 0000:00:05.1 to =
64
[14315427.090137] PM: Writing back config space on device 0000:00:05.2 =
at offset 1 (was b00003, writing b00007)
[14315427.090143] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315427.090147] PCI: Setting latency timer of device 0000:00:05.2 to =
64
[14315427.090160] PCI: Setting latency timer of device 0000:00:06.0 to =
64
[14315427.091283] ata10: port disabled. ignoring.
[14315427.103340] PM: Writing back config space on device 0000:00:08.0 =
at offset f (was 14010100, writing 1401010a)
[14315427.103345] PM: Writing back config space on device 0000:00:08.0 =
at offset 7 (was 0, writing fe028000)
[14315427.103347] PM: Writing back config space on device 0000:00:08.0 =
at offset 6 (was 0, writing fe029000)
[14315427.103350] PM: Writing back config space on device 0000:00:08.0 =
at offset 5 (was 1, writing b001)
[14315427.103353] PM: Writing back config space on device 0000:00:08.0 =
at offset 4 (was 0, writing fe02a000)
[14315427.103356] PM: Writing back config space on device 0000:00:08.0 =
at offset 1 (was b00000, writing b00007)
[14315427.103668] eth0: no link during initialization.
[14315427.116673] PM: Writing back config space on device 0000:00:09.0 =
at offset f (was 14010100, writing 1401010a)
[14315427.116677] PM: Writing back config space on device 0000:00:09.0 =
at offset 7 (was 0, writing fe025000)
[14315427.116680] PM: Writing back config space on device 0000:00:09.0 =
at offset 6 (was 0, writing fe026000)
[14315427.116683] PM: Writing back config space on device 0000:00:09.0 =
at offset 5 (was 1, writing ac01)
[14315427.116685] PM: Writing back config space on device 0000:00:09.0 =
at offset 4 (was 0, writing fe027000)
[14315427.116689] PM: Writing back config space on device 0000:00:09.0 =
at offset 1 (was b00000, writing b00007)
[14315427.117148] PCI: Setting latency timer of device 0000:00:0a.0 to =
64
[14315427.117161] PCI: Setting latency timer of device 0000:00:0b.0 to =
64
[14315427.117172] PCI: Setting latency timer of device 0000:00:0c.0 to =
64
[14315427.117184] PCI: Setting latency timer of device 0000:00:0d.0 to =
64
[14315427.117195] PCI: Setting latency timer of device 0000:00:0e.0 to =
64
[14315427.117207] PCI: Setting latency timer of device 0000:00:0f.0 to =
64
[14315427.130013] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315427.137561] PM: Writing back config space on device 0000:06:00.0 =
at offset 1 (was 100003, writing 100007)
[14315427.137572] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315427.137576] PCI: Setting latency timer of device 0000:06:00.0 to =
64
[14315427.140558] serial 00:08: activated
[14315427.140593] sd 2:0:0:0: [sda] Starting disk
[14315427.273684] ata9.01: ACPI cmd ef/03:44:00:00:00:b0 filtered out
[14315427.273686] ata9.01: ACPI cmd ef/03:0c:00:00:00:b0 filtered out
[14315427.273705] ata9: nv_mode_filter: 0x1f01f&0x1f01f->0x1f01f, BIOS=3D=
0x1f000 (0xc50000) ACPI=3D0x1f01f (600:30:0x1c)
[14315427.286764] ata9.01: configured for UDMA/66
[14315427.410007] ata7: SATA link down (SStatus 0 SControl 300)
[14315427.420530] ata6: SATA link down (SStatus 0 SControl 300)
[14315427.431053] ata4: SATA link down (SStatus 0 SControl 300)
[14315427.441578] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315427.441635] ata5: SATA link down (SStatus 0 SControl 300)
[14315427.452239] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315427.452277] ata1: SATA link down (SStatus 0 SControl 300)
[14315427.457007] ata8.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315427.460007] ata2: SATA link down (SStatus 0 SControl 300)
[14315427.470059] ata8.00: configured for UDMA/100
[14315427.470115] ata3.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315427.470117] ata3.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[14315427.476763] ata3.00: configured for UDMA/133
[14315427.476819] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315427.476832] sd 2:0:0:0: [sda] Write Protect is off
[14315427.476834] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[14315427.476855] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315428.259602] PM: writing image.
[14315428.263115] PM: Free swap pages: 977947
[14315428.270383] PM: Saving image data pages (58128 pages) ...     =08=
=08=08=08  0%=08=08=08=08  1%=08=08=08=08  2%=08=08=08=08  3%=08=08=08=08=
  4%=08=08=08=08  5%=08=08=08=08  6%=08=08=08=08  7%=08=08=08=08  8%=08=
=08=08=08  9%=08=08=08=08 10%=08=08=08=08 11%=08=08=08=08 12%=08=08=08=08=
 13%=08=08=08=08 14%=08=08=08=08 15%=08=08=08=08 16%=08=08=08=08 17%=08=
=08=08=08 18%=08=08=08=08 19%=08=08=08=08 20%=08=08=08=08 21%=08=08=08=08=
 22%=08=08=08=08 23%=08=08=08=08 24%=08=08=08=08 25%=08=08=08=08 26%=08=
=08=08=08 27%=08=08=08=08 28%=08=08=08=08 29%=08=08=08=08 30%=08=08=08=08=
 31%=08=08=08=08 32%=08=08=08=08 33%=08=08=08=08 34%=08=08=08=08 35%=08=
=08=08=08 36%=08=08=08=08 37%=08=08=08=08 38%=08=08=08=08 39%=08=08=08=08=
 40%=08=08=08=08 41%=08=08=08=08 42%=08=08=08=08 43%=08=08=08=08 44%=08=
=08=08=08 45%=08=08=08=08 46%=08=08=08=08 47%=08=08=08=08 48%=08=08=08=08=
 49%=08=08=08=08 50%=08=08=08=08 51%=08=08=08=08 52%=08=08=08=08 53%=08=
=08=08=08 54%=08=08=08=08 55%=08=08=08=08 56%=08=08=08=08 57%=08=08=08=08=
 58%=08=08=08=08 59%=08=08=08=08 60%=08=08=08=08 61%=08=08=08=08 62%=08=
=08=08=08 63%=08=08=08=08 64%=08=08=08=08 65%=08=08=08=08 66%=08=08=08=08=
 67%=08=08=08=08 68%=08=08=08=08 69%=08=08=08=08 70%=08=08=08=08 71%=08=
=08=08=08 72%=08=08=08=08 73%=08=08=08=08 74%=08=08=08=08 75%=08=08=08=08=
 76%=08=08=08=08 77%=08=08=08=08 78%=08=08=08=08 79%=08=08=08=08 80%=08=
=08=08=08 81%=08=08=08=08 82%=08=08=08=08 83%=08=08=08=08 84%=08=08=08=08=
 85%=08=08=08=08 86%=08=08=08=08 87%=08=08=08=08 88%=08=08=08=08 89%=08=
=08=08=08 90%=08=08=08=08 91%=08=08=08=08 92%=08=08=08=08 93%=08=08=08=08=
 94%=08=08=08=08 95%=08=08=08=08 96%=08=08=08=08 97%=08=08=08=08 98%=08=
=08=08=08 99%=08=08=08=08100%=08=08=08=08done
[14315431.183335] PM: Wrote 232512 kbytes in 2.90 seconds (80.17 MB/s)
[14315431.191699] PM: S|
[14315431.444446] Suspending console(s)
[    0.000000] Command line: root=3D/dev/sda5 resume=3D/dev/sda6 vga=3D=
6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3Dnomsi ro
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
[    0.000000]  BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] max_pfn_mapped =3D 1048576
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000F7B80, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT 7FEE30C0, 004C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 7FEEC540, 00F4 (r3 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 7FEE3240, 92AD (r1 NVIDIA AWRDACPI     1000 M=
SFT  3000000)
[    0.000000] ACPI: FACS 7FEE0000, 0040
[    0.000000] ACPI: SSDT 7FEEC740, 0136 (r1 PTLTD  POWERNOW        1  =
LTP        1)
[    0.000000] ACPI: HPET 7FEEC8C0, 0038 (r1 Nvidia ASUSACPI 42302E31 A=
WRD       98)
[    0.000000] ACPI: MCFG 7FEEC940, 003C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: APIC 7FEEC680, 007C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-8eb01f] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-bfff] PGTABLE
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524000
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI=
 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 7ff0=
0000:70100000)
[14315324.233334] Built 1 zonelists in Zone order, mobility grouping on=
=2E  Total pages: 514863
[14315324.233334] Kernel command line: root=3D/dev/sda5 resume=3D/dev/s=
da6 vga=3D6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3D=
nomsi ro
[14315324.233334] Initializing CPU#0
[14315324.233334] PID hash table entries: 4096 (order: 12, 32768 bytes)
[14315324.233334] Extended CMOS year: 2000
[14315324.233334] TSC calibrated against PM_TIMER
[14315324.233334] time.c: Detected 2411.110 MHz processor.
[14315324.233334] Console: colour VGA+ 80x60
[14315324.233334] console [tty0] enabled
[14315324.233334] console [ttyS0] enabled
[14315324.233334] Dentry cache hash table entries: 262144 (order: 9, 20=
97152 bytes)
[14315324.233334] Inode-cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
[14315324.233334] Checking aperture...
[14315324.233334] Node 0: aperture @ 289c000000 size 32 MB
[14315324.233334] Aperture beyond 4GB. Ignoring.
[14315324.233334] No AGP bridge found
[14315324.233334] Memory: 2056088k/2096000k available (4489k kernel cod=
e, 39052k reserved, 1754k data, 256k init)
[14315324.316531] Calibrating delay using timer specific routine.. 4827=
=2E23 BogoMIPS (lpj=3D8041982)
[14315324.323020] Mount-cache hash table entries: 256
[14315324.326661] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64=
 bytes/line)
[14315324.329994] CPU: L2 Cache: 512K (64 bytes/line)
[14315324.333327] CPU: AMD Athlon(tm) 64 Processor 3800+ stepping 01
[14315324.339629] ACPI: Core revision 20080321
[14315324.353326] enabled ExtINT on CPU#0
[14315324.356659] ENABLING IO-APIC IRQs
[14315324.359992] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1
[14315324.396296] Using local APIC timer interrupts.
[14315324.403323] Detected 12.557 MHz APIC timer.
[14315324.406656] net_namespace: 1160 bytes
[14315324.409989] NET: Registered protocol family 16
[14315324.413322] No dock devices found.
[14315324.416655] TOM: 0000000080000000 aka 2048M
[14315324.419988] ACPI: bus type pci registered
[14315324.423321] PCI: Using configuration type 1 for base access
[14315324.438521] ACPI: Interpreter enabled
[14315324.442551] ACPI: (supports S0 S1 S3 S4 S5)
[14315324.447309] ACPI: Using IOAPIC for interrupt routing
[14315324.464177] ACPI: PCI Root Bridge [PCI0] (0000:00)
[14315324.469985] PCI: Transparent bridge - 0000:00:06.0
[14315324.538635] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.546647] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.553313] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.559235] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.566645] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.573312] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.579978] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.585899] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.593310] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.599977] ACPI: PCI Interrupt Link [LUBA] (IRQs *5 7 9 10 11 14=
 15)
[14315324.605880] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.612556] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.616642] ACPI: PCI Interrupt Link [LAZA] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.623308] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.629975] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.635894] ACPI: PCI Interrupt Link [LUB2] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.642560] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.649973] ACPI: PCI Interrupt Link [LSID] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.655882] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.662566] ACPI: PCI Interrupt Link [LSA2] (IRQs *5 7 9 10 11 14=
 15)
[14315324.666639] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disable=
d.
[14315324.672251] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disable=
d.
[14315324.678915] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[14315324.683304] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disable=
d.
[14315324.688904] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disable=
d.
[14315324.695579] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0, disable=
d.
[14315324.702245] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[14315324.707907] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disable=
d.
[14315324.714987] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[14315324.721976] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[14315324.728807] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[14315324.735481] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.743232] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.749906] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[14315324.755480] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[14315324.759968] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.766565] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.773239] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[14315324.778814] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[14315324.783301] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[14315324.786634] Linux Plug and Play Support v0.97 (c) Adam Belay
[14315324.789968] pnp: PnP ACPI init
[14315324.793301] ACPI: bus type pnp registered
[14315324.803957] pnp: PnP ACPI: found 13 devices
[14315324.808509] ACPI: ACPI bus type pnp unregistered
[14315324.813301] SCSI subsystem initialized
[14315324.816635] usbcore: registered new interface driver usbfs
[14315324.819968] usbcore: registered new interface driver hub
[14315324.823301] usbcore: registered new device driver usb
[14315324.826635] PCI: Using ACPI for IRQ routing
[14315324.829968] testing the IO APIC.......................
[14315324.833301]=20
[14315324.835356] .................................... done.
[14315324.850582] Bluetooth: Core ver 2.11
[14315324.854604] NET: Registered protocol family 31
[14315324.859413] Bluetooth: HCI device and connection manager initiali=
zed
[14315324.863301] Bluetooth: HCI socket layer initialized
[14315324.866634] DMAR:parse DMAR table failure.
[14315324.877861] system 00:01: ioport range 0x1000-0x107f has been res=
erved
[14315324.884754] system 00:01: ioport range 0x1080-0x10ff has been res=
erved
[14315324.891641] system 00:01: ioport range 0x1400-0x147f has been res=
erved
[14315324.898527] system 00:01: ioport range 0x1480-0x14ff has been res=
erved
[14315324.905414] system 00:01: ioport range 0x1800-0x187f has been res=
erved
[14315324.912301] system 00:01: ioport range 0x1880-0x18ff has been res=
erved
[14315324.919195] system 00:02: ioport range 0x4d0-0x4d1 has been reser=
ved
[14315324.925911] system 00:02: ioport range 0x800-0x87f has been reser=
ved
[14315324.932625] system 00:02: ioport range 0x290-0x297 has been reser=
ved
[14315324.939350] system 00:0b: iomem range 0xf0000000-0xf3ffffff could=
 not be reserved
[14315324.947279] system 00:0c: iomem range 0xd2800-0xd3fff has been re=
served
[14315324.954257] system 00:0c: iomem range 0xf0000-0xf7fff could not b=
e reserved
[14315324.963208] system 00:0c: iomem range 0xf8000-0xfbfff could not b=
e reserved
[14315324.970616] system 00:0c: iomem range 0xfc000-0xfffff could not b=
e reserved
[14315324.978022] system 00:0c: iomem range 0xfefff000-0xfefff0ff could=
 not be reserved
[14315324.985947] system 00:0c: iomem range 0x7fee0000-0x7fefffff could=
 not be reserved
[14315324.993402] system 00:0c: iomem range 0xffff0000-0xffffffff could=
 not be reserved
[14315325.001327] system 00:0c: iomem range 0x0-0x9ffff could not be re=
served
[14315325.008299] system 00:0c: iomem range 0x100000-0x7fedffff could n=
ot be reserved
[14315325.016264] system 00:0c: iomem range 0xfec00000-0xfec00fff could=
 not be reserved
[14315325.024032] system 00:0c: iomem range 0xfee00000-0xfeefffff could=
 not be reserved
[14315325.031957] system 00:0c: iomem range 0xfefff000-0xfeffffff could=
 not be reserved
[14315325.039908] system 00:0c: iomem range 0xfff80000-0xfff80fff could=
 not be reserved
[14315325.047836] system 00:0c: iomem range 0xfff90000-0xfffbffff could=
 not be reserved
[14315325.055787] system 00:0c: iomem range 0xfffed000-0xfffeffff could=
 not be reserved
[14315325.064066] PCI: Bridge: 0000:00:06.0
[14315325.068099]   IO window: 9000-9fff
[14315325.071872]   MEM window: 0xfde00000-0xfdefffff
[14315325.076768]   PREFETCH window: disabled.
[14315325.081061] PCI: Bridge: 0000:00:0a.0
[14315325.085091]   IO window: 8000-8fff
[14315325.089745]   MEM window: 0xfdd00000-0xfddfffff
[14315325.093523]   PREFETCH window: 0x00000000e8000000-0x00000000effff=
fff
[14315325.100238] PCI: Bridge: 0000:00:0b.0
[14315325.104270]   IO window: disabled.
[14315325.108042]   MEM window: disabled.
[14315325.112971]   PREFETCH window: disabled.
[14315325.116839] PCI: Bridge: 0000:00:0c.0
[14315325.120868]   IO window: disabled.
[14315325.124633]   MEM window: disabled.
[14315325.128491]   PREFETCH window: disabled.
[14315325.132810] PCI: Bridge: 0000:00:0d.0
[14315325.136842]   IO window: disabled.
[14315325.140614]   MEM window: disabled.
[14315325.144474]   PREFETCH window: disabled.
[14315325.148766] PCI: Bridge: 0000:00:0e.0
[14315325.153090]   IO window: 6000-7fff
[14315325.156863]   MEM window: 0xfdc00000-0xfdcfffff
[14315325.160906]   PREFETCH window: disabled.
[14315325.165813] PCI: Bridge: 0000:00:0f.0
[14315325.169843]   IO window: disabled.
[14315325.173608]   MEM window: disabled.
[14315325.177458]   PREFETCH window: disabled.
[14315325.181823] NET: Registered protocol family 2
[14315325.219002] IP route cache hash table entries: 65536 (order: 7, 5=
24288 bytes)
[14315325.227126] TCP established hash table entries: 262144 (order: 10=
, 4194304 bytes)
[14315325.236670] TCP bind hash table entries: 65536 (order: 7, 524288 =
bytes)
[14315325.249908] TCP: Hash tables configured (established 262144 bind =
65536)
[14315325.256885] TCP reno registered
[14315325.268726] NET: Registered protocol family 1
[14315325.274356] Installing knfsd (copyright (C) 1996 okir@monad.swb.d=
e).
[14315325.281292] JFFS2 version 2.2. (NAND) =C3=82=C2=A9 2001-2006 Red =
Hat, Inc.
[14315325.287715] fuse init (API version 7.9)
[14315325.292563] SGI XFS with security attributes, large block/inode n=
umbers, no debug enabled
[14315325.300227] msgmni has been set to 4016 for ipc namespace fffffff=
f807eda90
[14315325.307546] Block layer SCSI generic (bsg) driver version 0.4 loa=
ded (major 254)
[14315325.316196] io scheduler noop registered
[14315325.320488] io scheduler anticipatory registered
[14315325.325471] io scheduler deadline registered
[14315325.330100] io scheduler cfq registered (default)
[14315325.347130] pci 0000:00:05.0: Enabling HT MSI Mapping
[14315325.352552] pci 0000:00:05.1: Enabling HT MSI Mapping
[14315325.357669] pci 0000:00:05.2: Enabling HT MSI Mapping
[14315325.363103] pci 0000:00:06.0: Enabling HT MSI Mapping
[14315325.368540] pci 0000:00:08.0: Enabling HT MSI Mapping
[14315325.373965] pci 0000:00:09.0: Enabling HT MSI Mapping
[14315325.379405] pci 0000:00:0a.0: Enabling HT MSI Mapping
[14315325.384839] pci 0000:00:0b.0: Enabling HT MSI Mapping
[14315325.390264] pci 0000:00:0c.0: Enabling HT MSI Mapping
[14315325.395707] pci 0000:00:0d.0: Enabling HT MSI Mapping
[14315325.401132] pci 0000:00:0e.0: Enabling HT MSI Mapping
[14315325.406576] pci 0000:00:0f.0: Enabling HT MSI Mapping
[14315325.412109] assign_interrupt_mode Found MSI capability
[14315325.417503] assign_interrupt_mode Found MSI capability
[14315325.423123] assign_interrupt_mode Found MSI capability
[14315325.428704] assign_interrupt_mode Found MSI capability
[14315325.434268] assign_interrupt_mode Found MSI capability
[14315325.439860] assign_interrupt_mode Found MSI capability
[14315325.445637] input: Power Button (FF) as /class/input/input0
[14315325.451572] ACPI: Power Button (FF) [PWRF]
[14315325.456101] input: Power Button (CM) as /class/input/input1
[14315325.462038] ACPI: Power Button (CM) [PWRB]
[14315325.466603] ACPI: PNP0C0B:00 is registered as cooling_device0
[14315325.472710] ACPI: Fan [FAN] (on)
[14315325.476417] ACPI: ACPI0007:00 is registered as cooling_device1
[14315325.483409] ACPI: LNXTHERM:01 is registered as thermal_zone0
[14315325.489678] ACPI: Thermal Zone [THRM] (40 C)
[14315325.515082] Real Time Clock Driver v1.12ac
[14315325.519546] Linux agpgart interface v0.103
[14315325.522402] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, =
IRQ sharing disabled
[14315325.532504] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550=
A
[14315325.539177] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.545692] loop: module loaded
[14315325.549206] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[14315325.554189] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[14315325.560687] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[14315325.567138] e100: Copyright(c) 1999-2006 Intel Corporation
[14315325.573035] tun: Universal TUN/TAP device driver, 1.6
[14315325.579212] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com=
>
[14315325.585841] Driver 'sd' needs updating - please use bus_type meth=
ods
[14315325.592576] Driver 'sr' needs updating - please use bus_type meth=
ods
[14315325.599806] ACPI: PCI Interrupt Link [APC7] enabled at IRQ 16
[14315325.605924] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315326.617015] ahci 0000:06:00.0: AHCI 0001.0000 32 slots 2 ports 3 =
Gbps 0x3 impl SATA mode
[14315326.625541] ahci 0000:06:00.0: flags: 64bit ncq pm led clo pmp pi=
o slum part=20
[14315326.633320] scsi0 : ahci
[14315326.636319] scsi1 : ahci
[14315326.639308] ata1: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe100 irq 16
[14315326.648936] ata2: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe180 irq 16
[14315326.974915] ata1: SATA link down (SStatus 0 SControl 300)
[14315327.298612] ata2: SATA link down (SStatus 0 SControl 300)
[14315327.303820] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
[14315327.309930] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315327.319948] sata_nv 0000:00:05.0: Using SWNCQ mode
[14315327.325280] scsi2 : sata_nv
[14315327.328500] scsi3 : sata_nv
[14315327.331850] ata3: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd=
c00 irq 23
[14315327.339252] ata4: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd=
c08 irq 23
[14315327.817600] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315327.833335] ata3.00: ATA-8: SAMSUNG HD501LJ, CR100-12, max UDMA7
[14315327.836670] ata3.00: 976773168 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
[14315327.853117] ata3.00: configured for UDMA/133
[14315328.174650] ata4: SATA link down (SStatus 0 SControl 300)
[14315328.202771] isa bounce pool size: 16 pages
[14315328.206733] scsi 2:0:0:0: Direct-Access     ATA      SAMSUNG HD50=
1LJ  CR10 PQ: 0 ANSI: 5
[14315328.214599] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.223109] sd 2:0:0:0: [sda] Write Protect is off
[14315328.227477] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.237002] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.244582] sd 2:0:0:0: [sda] Write Protect is off
[14315328.249792] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.259278]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[14315328.321782] sd 2:0:0:0: [sda] Attached SCSI disk
[14315328.328113] sd 2:0:0:0: Attached scsi generic sg0 type 0
[14315328.335181] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
[14315328.341304] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315328.350058] sata_nv 0000:00:05.1: Using SWNCQ mode
[14315328.355400] scsi4 : sata_nv
[14315328.358625] scsi5 : sata_nv
[14315328.361977] ata5: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc=
800 irq 22
[14315328.369382] ata6: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc=
808 irq 22
[14315328.695882] ata5: SATA link down (SStatus 0 SControl 300)
[14315329.028901] ata6: SATA link down (SStatus 0 SControl 300)
[14315329.056470] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 21
[14315329.060011] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315329.070746] sata_nv 0000:00:05.2: Using SWNCQ mode
[14315329.076072] scsi6 : sata_nv
[14315329.079301] scsi7 : sata_nv
[14315329.082650] ata7: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0=
xb400 irq 21
[14315329.090223] ata8: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0=
xb408 irq 21
[14315329.415659] ata7: SATA link down (SStatus 0 SControl 300)
[14315329.901986] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315329.916644] ata8.00: ATAPI: TSSTcorp CDDVDW SH-S203B, SB00, max U=
DMA/100
[14315329.936252] ata8.00: configured for UDMA/100
[14315329.952582] scsi 7:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S2=
03B  SB00 PQ: 0 ANSI: 5
[14315329.963362] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa=
/form2 cdda tray
[14315329.971281] Uniform CD-ROM driver Revision: 3.20
[14315329.976425] sr 7:0:0:0: Attached scsi generic sg1 type 5
[14315329.982815] block2mtd: version $Revision: 1.30 $
[14315329.989019] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 20
[14315329.995141] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315330.004375] ehci_hcd 0000:00:02.1: EHCI Host Controller
[14315330.010034] ehci_hcd 0000:00:02.1: new USB bus registered, assign=
ed bus number 1
[14315330.017902] ehci_hcd 0000:00:02.1: debug port 1
[14315330.023053] ehci_hcd 0000:00:02.1: irq 20, io mem 0xfe02e000
[14315330.038380] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, dr=
iver 10 Dec 2004
[14315330.052366] usb usb1: configuration #1 chosen from 1 choice
[14315330.057252] hub 1-0:1.0: USB hub found
[14315330.063292] hub 1-0:1.0: 10 ports detected
[14315330.168892] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[14315330.173337] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315330.184188] ohci_hcd 0000:00:02.0: OHCI Host Controller
[14315330.189832] ohci_hcd 0000:00:02.0: new USB bus registered, assign=
ed bus number 2
[14315330.197677] ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
[14315330.256668] usb usb2: configuration #1 chosen from 1 choice
[14315330.262631] hub 2-0:1.0: USB hub found
[14315330.266750] hub 2-0:1.0: 10 ports detected
[14315330.346545] hub 1-0:1.0: unable to enumerate USB device on port 1
[14315330.373218] USB Universal Host Controller Interface driver v3.0
[14315330.522812] hub 1-0:1.0: unable to enumerate USB device on port 3
[14315330.699574] hub 1-0:1.0: unable to enumerate USB device on port 4
[14315330.703376] usbcore: registered new interface driver usblp
[14315330.709861] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq =
1
[14315330.716397] PNP: PS/2 appears to have AUX port disabled, if this =
is incorrect please boot with i8042.nopnp
[14315330.726578] serio: i8042 KBD port at 0x60,0x64 irq 1
[14315330.732459] mice: PS/2 mouse device common for all mice
[14315330.761257] i2c /dev entries driver
[14315330.765231] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[14315330.771478] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[14315330.776979] it87: Found IT8716F chip at 0x290, revision 0
[14315330.783176] it87: in3 is VCC (+5V)
[14315330.786941] it87: in7 is VCCH (+5V Stand-By)
[14315330.803334] input: AT Translated Set 2 keyboard as /class/input/i=
nput2
[14315330.835468] md: raid1 personality registered for level 1
[14315330.840069] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initi=
alised: dm-devel@redhat.com
[14315330.849335] Bluetooth: HCI USB driver ver 2.9
[14315330.942877] usb 2-1: new low speed USB device using ohci_hcd and =
address 2
[14315331.090001] usb 2-1: configuration #1 chosen from 1 choice
[14315331.348850] usb 2-3: new low speed USB device using ohci_hcd and =
address 3
[14315331.506667] usb 2-3: configuration #1 chosen from 1 choice
[14315331.775224] usb 2-4: new full speed USB device using ohci_hcd and=
 address 4
[14315331.906671] usb 2-4: device descriptor read/64, error -62
[14315332.140004] usb 2-4: device descriptor read/64, error -62
[14315332.368875] usb 2-4: new full speed USB device using ohci_hcd and=
 address 5
[14315332.500004] usb 2-4: device descriptor read/64, error -62
[14315332.733337] usb 2-4: device descriptor read/64, error -62
[14315332.962211] usb 2-4: new full speed USB device using ohci_hcd and=
 address 6
[14315333.374067] usb 2-4: device not accepting address 6, error -62
[14315333.499359] usb 2-4: new full speed USB device using ohci_hcd and=
 address 7
[14315333.911319] usb 2-4: device not accepting address 7, error -62
[14315333.916670] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315333.923165] usbcore: registered new interface driver hci_usb
[14315333.929333] Bluetooth: HCI UART driver ver 2.2
[14315333.935401] Bluetooth: HCI H4 protocol initialized
[14315333.940218] Bluetooth: HCI BCSP protocol initialized
[14315333.945544] cpuidle: using governor ladder
[14315333.950005] cpuidle: using governor menu
[14315333.960001] input: Microsoft Microsoft 3-Button Mouse with Intell=
iEye(TM) as /class/input/input3
[14315333.991282] input: USB HID v1.10 Mouse [Microsoft Microsoft 3-But=
ton Mouse with IntelliEye(TM)] on usb-0000:00:02.0-1
[14315334.012566] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input4
[14315334.043164] input: USB HID v1.11 Keyboard [Microsoft Natural=C2=AE=
 Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.064696] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input5
[14315334.098016] input: USB HID v1.11 Device [Microsoft Natural=C2=AE =
Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.108216] usbcore: registered new interface driver usbhid
[14315334.113552] usbhid: v2.6:USB HID core driver
[14315334.119564] Advanced Linux Sound Architecture Driver Version 1.0.=
16.
[14315334.126431] ALSA device list:
[14315334.129768]   No soundcards found.
[14315334.131593] GACT probability on
[14315334.135104] Mirror/redirect action on
[14315334.139314] u32 classifier
[14315334.142467]     Performance counters on
[14315334.146667]     input device check on=20
[14315334.153262]     Actions configured=20
[14315334.157422] IPv4 over IPv4 tunneling driver
[14315334.161479] ip_tables: (C) 2000-2006 Netfilter Core Team
[14315334.167179] TCP bic registered
[14315334.170598] TCP cubic registered
[14315334.174186] TCP westwood registered
[14315334.178037] TCP htcp registered
[14315334.181542] TCP vegas registered
[14315334.186438] TCP yeah registered
[14315334.189943] Initializing XFRM netlink socket
[14315334.193583] NET: Registered protocol family 10
[14315334.200001] IPv6 over IPv4 tunneling driver
[14315334.204347] NET: Registered protocol family 17
[14315334.209155] NET: Registered protocol family 15
[14315334.214005] Bridge firewalling registered
[14315334.219184] Bluetooth: L2CAP ver 2.9
[14315334.223125] Bluetooth: L2CAP socket layer initialized
[14315334.227554] Bluetooth: SCO (Voice Link) ver 0.5
[14315334.232972] Bluetooth: SCO socket layer initialized
[14315334.237893] Bluetooth: RFCOMM socket layer initialized
[14315334.243400] Bluetooth: RFCOMM TTY layer initialized
[14315334.248649] Bluetooth: RFCOMM ver 1.8
[14315334.252672] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[14315334.258338] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[14315334.263703] RPC: Registered udp transport module.
[14315334.269897] RPC: Registered tcp transport module.
[14315334.275072] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelat=
ech.com>
[14315334.282219] All bugs added by David S. Miller <davem@redhat.com>
[14315334.288584] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3800=
+ processors (1 cpu cores) (version 2.20.00)
[14315334.298968] powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
[14315334.304983] powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
[14315334.310102] powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
[14315334.316040] powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
[14315334.321985] powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
[14315334.334765] Freezing user space processes ... (elapsed 0.00 secon=
ds) done.
[14315334.342603] Freezing remaining freezable tasks ... (elapsed 0.00 =
seconds) done.
[14315334.350575] PM: Loading image data pages (58128 pages) ...     =08=
=08=08=08  0%=08=08=08=08  1%=08=08=08=08  2%=08=08=08=08  3%=08=08=08=08=
  4%=08=08=08=08  5%=08=08=08=08  6%=08=08=08=08  7%=08=08=08=08  8%=08=
=08=08=08  9%=08=08=08=08 10%=08=08=08=08 11%=08=08=08=08 12%=08=08=08=08=
 13%=08=08=08=08 14%=08=08=08=08 15%=08=08=08=08 16%=08=08=08=08 17%=08=
=08=08=08 18%=08=08=08=08 19%=08=08=08=08 20%=08=08=08=08 21%=08=08=08=08=
 22%=08=08=08=08 23%=08=08=08=08 24%=08=08=08=08 25%=08=08=08=08 26%Mar=
king TSC unstable due to cpufreq changes
[14315335.338247] =08=08=08=08 27%=08=08=08=08 28%=08=08=08=08 29%=08=08=
=08=08 30%=08=08=08=08 31%=08=08=08=08 32%=08=08=08=08 33%=08=08=08=08 =
34%=08=08=08=08 35%=08=08=08=08 36%=08=08=08=08 37%=08=08=08=08 38%=08=08=
=08=08 39%<4>Clocksource tsc unstable (delta =3D -234257146 ns)
[14315335.743561] =08=08=08=08 40%=08=08=08=08 41%=08=08=08=08 42%=08=08=
=08=08 43%=08=08=08=08 44%=08=08=08=08 45%=08=08=08=08 46%=08=08=08=08 =
47%=08=08=08=08 48%=08=08=08=08 49%=08=08=08=08 50%=08=08=08=08 51%=08=08=
=08=08 52%=08=08=08=08 53%=08=08=08=08 54%=08=08=08=08 55%=08=08=08=08 =
56%=08=08=08=08 57%=08=08=08=08 58%=08=08=08=08 59%=08=08=08=08 60%=08=08=
=08=08 61%=08=08=08=08 62%=08=08=08=08 63%=08=08=08=08 64%=08=08=08=08 =
65%=08=08=08=08 66%=08=08=08=08 67%=08=08=08=08 68%=08=08=08=08 69%=08=08=
=08=08 70%=08=08=08=08 71%=08=08=08=08 72%=08=08=08=08 73%=08=08=08=08 =
74%=08=08=08=08 75%=08=08=08=08 76%=08=08=08=08 77%=08=08=08=08 78%=08=08=
=08=08 79%=08=08=08=08 80%=08=08=08=08 81%=08=08=08=08 82%=08=08=08=08 =
83%=08=08=08=08 84%=08=08=08=08 85%=08=08=08=08 86%=08=08=08=08 87%=08=08=
=08=08 88%=08=08=08=08 89%=08=08=08=08 90%=08=08=08=08 91%=08=08=08=08 =
92%=08=08=08=08 93%=08=08=08=08 94%=08=08=08=08 95%=08=08=08=08 96%=08=08=
=08=08 97%=08=08=08=08 98%=08=08=08=08 99%=08=08=08=08100%=08=08=08=08d=
one
[14315337.613519] PM: Read 232512 kbytes in 3.25 seconds (71.54 MB/s)
[14315337.622034] Suspending console(s)
[14315426.981319] sd 2:0:0:0: [sda] Synchronizing SCSI cache
[14315426.981542] ACPI handle has no context!
[14315426.983937] serial 00:08: disabled
[14315427.010050] ACPI: PCI interrupt for device 0000:06:00.0 disabled
[14315427.017068] ACPI: PCI interrupt for device 0000:01:08.0 disabled
[14315427.017078] ACPI handle has no context!
[14315427.030353] ACPI: PCI interrupt for device 0000:00:09.0 disabled
[14315427.043622] ACPI: PCI interrupt for device 0000:00:08.0 disabled
[14315427.056707] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14315427.056732] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14315427.056758] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14315427.056794] ACPI: PCI interrupt for device 0000:00:02.1 disabled
[14315427.056804] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14315427.056939] ACPI: Preparing to enter system sleep state S4
[14315427.057420] Extended CMOS year: 2000
[14315427.057466] PM: Creating hibernation image:=20
[14315427.059998] PM: Need to copy 58014 pages
[14315427.059998] PM: Normal pages needed: 58014 + 1024 + 38, available=
 pages: 465888
[14315427.059998] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70=
10600070106
[14315427.059998] svm_cpu_init: svm_data is NULL on 0
[14315427.059998] Extended CMOS year: 2000
[14315427.069743] ACPI: Unable to turn cooling device [ffff81007f842890=
] 'off'
[14315427.069794] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315427.069798] PCI: Setting latency timer of device 0000:00:02.0 to =
64
[14315427.120866] usb usb2: root hub lost power or was reset
[14315427.120872] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315427.120876] PCI: Setting latency timer of device 0000:00:02.1 to =
64
[14315427.120885] usb usb1: root hub lost power or was reset
[14315427.120889] ehci_hcd 0000:00:02.1: debug port 1
[14315427.120891] PCI: cache line size of 64 is not supported by device=
 0000:00:02.1
[14315427.120898] PM: Writing back config space on device 0000:00:04.0 =
at offset b (was 82391043, writing 8239f043)
[14315427.120906] PCI: Setting latency timer of device 0000:00:04.0 to =
64
[14315427.120919] PM: Writing back config space on device 0000:00:05.0 =
at offset 1 (was b00003, writing b00007)
[14315427.120925] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315427.120928] PCI: Setting latency timer of device 0000:00:05.0 to =
64
[14315427.120940] PM: Writing back config space on device 0000:00:05.1 =
at offset 1 (was b00003, writing b00007)
[14315427.120946] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315427.120950] PCI: Setting latency timer of device 0000:00:05.1 to =
64
[14315427.120961] PM: Writing back config space on device 0000:00:05.2 =
at offset 1 (was b00003, writing b00007)
[14315427.120967] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315427.120970] PCI: Setting latency timer of device 0000:00:05.2 to =
64
[14315427.120984] PCI: Setting latency timer of device 0000:00:06.0 to =
64
[14315427.124043] ata10: port disabled. ignoring.
[14315427.133651] eth0: no link during initialization.
[14315427.147151] PCI: Setting latency timer of device 0000:00:0a.0 to =
64
[14315427.147164] PCI: Setting latency timer of device 0000:00:0b.0 to =
64
[14315427.147176] PCI: Setting latency timer of device 0000:00:0c.0 to =
64
[14315427.147187] PCI: Setting latency timer of device 0000:00:0d.0 to =
64
[14315427.147198] PCI: Setting latency timer of device 0000:00:0e.0 to =
64
[14315427.147210] PCI: Setting latency timer of device 0000:00:0f.0 to =
64
[14315427.160009] PM: Writing back config space on device 0000:01:08.0 =
at offset 1 (was 2900005, writing 2900001)
[14315427.160016] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315427.167566] PM: Writing back config space on device 0000:06:00.0 =
at offset 1 (was 100003, writing 100007)
[14315427.167576] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315427.167580] PCI: Setting latency timer of device 0000:06:00.0 to =
64
[14315427.170564] serial 00:08: activated
[14315427.170599] sd 2:0:0:0: [sda] Starting disk
[14315427.307022] ata9.01: ACPI cmd ef/03:44:00:00:00:b0 filtered out
[14315427.307024] ata9.01: ACPI cmd ef/03:0c:00:00:00:b0 filtered out
[14315427.307044] ata9: nv_mode_filter: 0x1f01f&0x1f01f->0x1f01f, BIOS=3D=
0x1f000 (0xc50000) ACPI=3D0x1f01f (600:30:0x1c)
[14315427.320098] ata9.01: configured for UDMA/66
[14315427.440007] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315427.440065] ata7: SATA link down (SStatus 0 SControl 300)
[14315427.450716] ata8.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315427.450777] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315427.450811] ata4: SATA link down (SStatus 0 SControl 300)
[14315427.461589] ata5: SATA link down (SStatus 0 SControl 300)
[14315427.472280] ata8.00: configured for UDMA/100
[14315427.472287] ata6: SATA link down (SStatus 0 SControl 300)
[14315427.482948] ata1: SATA link down (SStatus 0 SControl 300)
[14315427.482969] ata3.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315427.482971] ata3.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[14315427.490073] ata2: SATA link down (SStatus 0 SControl 300)
[14315427.490097] ata3.00: configured for UDMA/133
[14315427.490152] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315427.490166] sd 2:0:0:0: [sda] Write Protect is off
[14315427.490168] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[14315427.490189] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315428.233337] usb 2-1: reset low speed USB device using ohci_hcd an=
d address 2
[14315428.803336] usb 2-3: reset low speed USB device using ohci_hcd an=
d address 3
[14315429.655057] PM: Image restored successfully.
[14315429.706987] Restarting tasks ... done.
[14315429.717613] PM: Basic memory bitmaps freed
[14315430.076674] usb 2-4: device descriptor read/64, error -62
[14315430.313336] usb 2-4: device descriptor read/64, error -62
[14315430.666669] usb 2-4: device descriptor read/64, error -62
[14315430.900002] usb 2-4: device descriptor read/64, error -62
[14315431.533334] usb 2-4: device not accepting address 10, error -62
[14315432.063338] usb 2-4: device not accepting address 11, error -62
[14315432.073067] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315590.280012] Restarting system.
[    0.000000] Command line: root=3D/dev/sda5 resume=3D/dev/sda6 vga=3D=
6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3Dnomsi ro
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
[    0.000000]  BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] max_pfn_mapped =3D 1048576
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000F7B80, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT 7FEE30C0, 004C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 7FEEC540, 00F4 (r3 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 7FEE3240, 92AD (r1 NVIDIA AWRDACPI     1000 M=
SFT  3000000)
[    0.000000] ACPI: FACS 7FEE0000, 0040
[    0.000000] ACPI: SSDT 7FEEC740, 0136 (r1 PTLTD  POWERNOW        1  =
LTP        1)
[    0.000000] ACPI: HPET 7FEEC8C0, 0038 (r1 Nvidia ASUSACPI 42302E31 A=
WRD       98)
[    0.000000] ACPI: MCFG 7FEEC940, 003C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: APIC 7FEEC680, 007C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-8eb01f] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-bfff] PGTABLE
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524000
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI=
 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 7ff0=
0000:70100000)
[14315324.233334] Built 1 zonelists in Zone order, mobility grouping on=
=2E  Total pages: 514863
[14315324.233334] Kernel command line: root=3D/dev/sda5 resume=3D/dev/s=
da6 vga=3D6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3D=
nomsi ro
[14315324.233334] Initializing CPU#0
[14315324.233334] PID hash table entries: 4096 (order: 12, 32768 bytes)
[14315324.233334] Extended CMOS year: 2000
[14315324.233334] TSC calibrated against PM_TIMER
[14315324.233334] time.c: Detected 2411.102 MHz processor.
[14315324.233334] Console: colour VGA+ 80x60
[14315324.233334] console [tty0] enabled
[14315324.233334] console [ttyS0] enabled
[14315324.233334] Dentry cache hash table entries: 262144 (order: 9, 20=
97152 bytes)
[14315324.233334] Inode-cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
[14315324.233334] Checking aperture...
[14315324.233334] Node 0: aperture @ 289c000000 size 32 MB
[14315324.233334] Aperture beyond 4GB. Ignoring.
[14315324.233334] No AGP bridge found
[14315324.233334] Memory: 2056088k/2096000k available (4489k kernel cod=
e, 39052k reserved, 1754k data, 256k init)
[14315324.316530] Calibrating delay using timer specific routine.. 4827=
=2E21 BogoMIPS (lpj=3D8041944)
[14315324.323021] Mount-cache hash table entries: 256
[14315324.326661] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64=
 bytes/line)
[14315324.329994] CPU: L2 Cache: 512K (64 bytes/line)
[14315324.333327] CPU: AMD Athlon(tm) 64 Processor 3800+ stepping 01
[14315324.339629] ACPI: Core revision 20080321
[14315324.353326] enabled ExtINT on CPU#0
[14315324.356659] ENABLING IO-APIC IRQs
[14315324.359992] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1
[14315324.396296] Using local APIC timer interrupts.
[14315324.403323] Detected 12.557 MHz APIC timer.
[14315324.406656] net_namespace: 1160 bytes
[14315324.409989] NET: Registered protocol family 16
[14315324.413322] No dock devices found.
[14315324.416655] TOM: 0000000080000000 aka 2048M
[14315324.419988] ACPI: bus type pci registered
[14315324.423321] PCI: Using configuration type 1 for base access
[14315324.438508] ACPI: Interpreter enabled
[14315324.442537] ACPI: (supports S0 S1 S3 S4 S5)
[14315324.447295] ACPI: Using IOAPIC for interrupt routing
[14315324.464042] ACPI: PCI Root Bridge [PCI0] (0000:00)
[14315324.469922] PCI: Transparent bridge - 0000:00:06.0
[14315324.538635] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.546647] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.553313] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.559236] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.566645] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.573312] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.579978] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.585882] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.593310] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.599977] ACPI: PCI Interrupt Link [LUBA] (IRQs *5 7 9 10 11 14=
 15)
[14315324.605890] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.612556] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.616642] ACPI: PCI Interrupt Link [LAZA] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.623308] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.629975] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.635878] ACPI: PCI Interrupt Link [LUB2] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.642543] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.649973] ACPI: PCI Interrupt Link [LSID] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.655900] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.662559] ACPI: PCI Interrupt Link [LSA2] (IRQs *5 7 9 10 11 14=
 15)
[14315324.666639] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disable=
d.
[14315324.672252] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disable=
d.
[14315324.678917] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[14315324.683304] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disable=
d.
[14315324.688906] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disable=
d.
[14315324.695580] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0, disable=
d.
[14315324.702246] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[14315324.707919] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disable=
d.
[14315324.714994] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[14315324.721969] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[14315324.728825] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[14315324.735489] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.743242] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.749903] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[14315324.755483] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[14315324.759968] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.766573] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.773240] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[14315324.778824] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[14315324.783301] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[14315324.786634] Linux Plug and Play Support v0.97 (c) Adam Belay
[14315324.789968] pnp: PnP ACPI init
[14315324.793301] ACPI: bus type pnp registered
[14315324.803954] pnp: PnP ACPI: found 13 devices
[14315324.808508] ACPI: ACPI bus type pnp unregistered
[14315324.813301] SCSI subsystem initialized
[14315324.816635] usbcore: registered new interface driver usbfs
[14315324.819968] usbcore: registered new interface driver hub
[14315324.823301] usbcore: registered new device driver usb
[14315324.826635] PCI: Using ACPI for IRQ routing
[14315324.829968] testing the IO APIC.......................
[14315324.833301]=20
[14315324.835357] .................................... done.
[14315324.850556] Bluetooth: Core ver 2.11
[14315324.854570] NET: Registered protocol family 31
[14315324.859379] Bluetooth: HCI device and connection manager initiali=
zed
[14315324.863301] Bluetooth: HCI socket layer initialized
[14315324.866634] DMAR:parse DMAR table failure.
[14315324.877860] system 00:01: ioport range 0x1000-0x107f has been res=
erved
[14315324.884746] system 00:01: ioport range 0x1080-0x10ff has been res=
erved
[14315324.891631] system 00:01: ioport range 0x1400-0x147f has been res=
erved
[14315324.898518] system 00:01: ioport range 0x1480-0x14ff has been res=
erved
[14315324.905408] system 00:01: ioport range 0x1800-0x187f has been res=
erved
[14315324.912293] system 00:01: ioport range 0x1880-0x18ff has been res=
erved
[14315324.919185] system 00:02: ioport range 0x4d0-0x4d1 has been reser=
ved
[14315324.925895] system 00:02: ioport range 0x800-0x87f has been reser=
ved
[14315324.932609] system 00:02: ioport range 0x290-0x297 has been reser=
ved
[14315324.939334] system 00:0b: iomem range 0xf0000000-0xf3ffffff could=
 not be reserved
[14315324.947262] system 00:0c: iomem range 0xd2800-0xd3fff has been re=
served
[14315324.954232] system 00:0c: iomem range 0xf0000-0xf7fff could not b=
e reserved
[14315324.963186] system 00:0c: iomem range 0xf8000-0xfbfff could not b=
e reserved
[14315324.970592] system 00:0c: iomem range 0xfc000-0xfffff could not b=
e reserved
[14315324.977999] system 00:0c: iomem range 0xfefff000-0xfefff0ff could=
 not be reserved
[14315324.985925] system 00:0c: iomem range 0x7fee0000-0x7fefffff could=
 not be reserved
[14315324.993379] system 00:0c: iomem range 0xffff0000-0xffffffff could=
 not be reserved
[14315325.001305] system 00:0c: iomem range 0x0-0x9ffff could not be re=
served
[14315325.008278] system 00:0c: iomem range 0x100000-0x7fedffff could n=
ot be reserved
[14315325.016242] system 00:0c: iomem range 0xfec00000-0xfec00fff could=
 not be reserved
[14315325.024006] system 00:0c: iomem range 0xfee00000-0xfeefffff could=
 not be reserved
[14315325.031932] system 00:0c: iomem range 0xfefff000-0xfeffffff could=
 not be reserved
[14315325.039884] system 00:0c: iomem range 0xfff80000-0xfff80fff could=
 not be reserved
[14315325.047811] system 00:0c: iomem range 0xfff90000-0xfffbffff could=
 not be reserved
[14315325.055763] system 00:0c: iomem range 0xfffed000-0xfffeffff could=
 not be reserved
[14315325.064040] PCI: Bridge: 0000:00:06.0
[14315325.068076]   IO window: 9000-9fff
[14315325.071848]   MEM window: 0xfde00000-0xfdefffff
[14315325.076745]   PREFETCH window: disabled.
[14315325.081037] PCI: Bridge: 0000:00:0a.0
[14315325.085068]   IO window: 8000-8fff
[14315325.089723]   MEM window: 0xfdd00000-0xfddfffff
[14315325.093501]   PREFETCH window: 0x00000000e8000000-0x00000000effff=
fff
[14315325.100214] PCI: Bridge: 0000:00:0b.0
[14315325.104247]   IO window: disabled.
[14315325.108019]   MEM window: disabled.
[14315325.112948]   PREFETCH window: disabled.
[14315325.116814] PCI: Bridge: 0000:00:0c.0
[14315325.120847]   IO window: disabled.
[14315325.124619]   MEM window: disabled.
[14315325.128478]   PREFETCH window: disabled.
[14315325.132796] PCI: Bridge: 0000:00:0d.0
[14315325.136826]   IO window: disabled.
[14315325.140591]   MEM window: disabled.
[14315325.144450]   PREFETCH window: disabled.
[14315325.148742] PCI: Bridge: 0000:00:0e.0
[14315325.153066]   IO window: 6000-7fff
[14315325.156838]   MEM window: 0xfdc00000-0xfdcfffff
[14315325.160884]   PREFETCH window: disabled.
[14315325.165790] PCI: Bridge: 0000:00:0f.0
[14315325.169822]   IO window: disabled.
[14315325.173595]   MEM window: disabled.
[14315325.177454]   PREFETCH window: disabled.
[14315325.181819] NET: Registered protocol family 2
[14315325.219002] IP route cache hash table entries: 65536 (order: 7, 5=
24288 bytes)
[14315325.227131] TCP established hash table entries: 262144 (order: 10=
, 4194304 bytes)
[14315325.236670] TCP bind hash table entries: 65536 (order: 7, 524288 =
bytes)
[14315325.249908] TCP: Hash tables configured (established 262144 bind =
65536)
[14315325.256886] TCP reno registered
[14315325.268730] NET: Registered protocol family 1
[14315325.274356] Installing knfsd (copyright (C) 1996 okir@monad.swb.d=
e).
[14315325.281293] JFFS2 version 2.2. (NAND) =C3=82=C2=A9 2001-2006 Red =
Hat, Inc.
[14315325.287717] fuse init (API version 7.9)
[14315325.292568] SGI XFS with security attributes, large block/inode n=
umbers, no debug enabled
[14315325.300241] msgmni has been set to 4016 for ipc namespace fffffff=
f807eda90
[14315325.307561] Block layer SCSI generic (bsg) driver version 0.4 loa=
ded (major 254)
[14315325.316208] io scheduler noop registered
[14315325.320497] io scheduler anticipatory registered
[14315325.325481] io scheduler deadline registered
[14315325.330111] io scheduler cfq registered (default)
[14315325.347150] pci 0000:00:05.0: Enabling HT MSI Mapping
[14315325.352575] pci 0000:00:05.1: Enabling HT MSI Mapping
[14315325.357690] pci 0000:00:05.2: Enabling HT MSI Mapping
[14315325.363123] pci 0000:00:06.0: Enabling HT MSI Mapping
[14315325.368561] pci 0000:00:08.0: Enabling HT MSI Mapping
[14315325.373986] pci 0000:00:09.0: Enabling HT MSI Mapping
[14315325.379427] pci 0000:00:0a.0: Enabling HT MSI Mapping
[14315325.384859] pci 0000:00:0b.0: Enabling HT MSI Mapping
[14315325.390285] pci 0000:00:0c.0: Enabling HT MSI Mapping
[14315325.395729] pci 0000:00:0d.0: Enabling HT MSI Mapping
[14315325.401155] pci 0000:00:0e.0: Enabling HT MSI Mapping
[14315325.406597] pci 0000:00:0f.0: Enabling HT MSI Mapping
[14315325.412129] assign_interrupt_mode Found MSI capability
[14315325.417523] assign_interrupt_mode Found MSI capability
[14315325.423144] assign_interrupt_mode Found MSI capability
[14315325.428724] assign_interrupt_mode Found MSI capability
[14315325.434286] assign_interrupt_mode Found MSI capability
[14315325.439871] assign_interrupt_mode Found MSI capability
[14315325.445649] input: Power Button (FF) as /class/input/input0
[14315325.451586] ACPI: Power Button (FF) [PWRF]
[14315325.456116] input: Power Button (CM) as /class/input/input1
[14315325.462053] ACPI: Power Button (CM) [PWRB]
[14315325.466616] ACPI: PNP0C0B:00 is registered as cooling_device0
[14315325.472724] ACPI: Fan [FAN] (on)
[14315325.476430] ACPI: ACPI0007:00 is registered as cooling_device1
[14315325.483424] ACPI: LNXTHERM:01 is registered as thermal_zone0
[14315325.489691] ACPI: Thermal Zone [THRM] (40 C)
[14315325.515064] Real Time Clock Driver v1.12ac
[14315325.519532] Linux agpgart interface v0.103
[14315325.522407] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, =
IRQ sharing disabled
[14315325.532508] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550=
A
[14315325.539180] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.545698] loop: module loaded
[14315325.549212] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[14315325.554194] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[14315325.560690] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[14315325.567145] e100: Copyright(c) 1999-2006 Intel Corporation
[14315325.573040] tun: Universal TUN/TAP device driver, 1.6
[14315325.579216] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com=
>
[14315325.585843] Driver 'sd' needs updating - please use bus_type meth=
ods
[14315325.592580] Driver 'sr' needs updating - please use bus_type meth=
ods
[14315325.599809] ACPI: PCI Interrupt Link [APC7] enabled at IRQ 16
[14315325.605928] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315326.617011] ahci 0000:06:00.0: AHCI 0001.0000 32 slots 2 ports 3 =
Gbps 0x3 impl SATA mode
[14315326.625536] ahci 0000:06:00.0: flags: 64bit ncq pm led clo pmp pi=
o slum part=20
[14315326.633316] scsi0 : ahci
[14315326.636314] scsi1 : ahci
[14315326.639306] ata1: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe100 irq 16
[14315326.648935] ata2: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe180 irq 16
[14315326.974913] ata1: SATA link down (SStatus 0 SControl 300)
[14315327.298611] ata2: SATA link down (SStatus 0 SControl 300)
[14315327.303820] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
[14315327.309931] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315327.319949] sata_nv 0000:00:05.0: Using SWNCQ mode
[14315327.325281] scsi2 : sata_nv
[14315327.328510] scsi3 : sata_nv
[14315327.331859] ata3: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd=
c00 irq 23
[14315327.339261] ata4: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd=
c08 irq 23
[14315327.817599] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315327.850001] ata3.00: ATA-8: SAMSUNG HD501LJ, CR100-12, max UDMA7
[14315327.853336] ata3.00: 976773168 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
[14315327.869783] ata3.00: configured for UDMA/133
[14315328.191321] ata4: SATA link down (SStatus 0 SControl 300)
[14315328.219442] isa bounce pool size: 16 pages
[14315328.223399] scsi 2:0:0:0: Direct-Access     ATA      SAMSUNG HD50=
1LJ  CR10 PQ: 0 ANSI: 5
[14315328.231271] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.239780] sd 2:0:0:0: [sda] Write Protect is off
[14315328.244148] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.253671] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.261252] sd 2:0:0:0: [sda] Write Protect is off
[14315328.266461] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.275947]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[14315328.343550] sd 2:0:0:0: [sda] Attached SCSI disk
[14315328.360876] sd 2:0:0:0: Attached scsi generic sg0 type 0
[14315328.370002] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
[14315328.373346] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315328.384048] sata_nv 0000:00:05.1: Using SWNCQ mode
[14315328.389393] scsi4 : sata_nv
[14315328.392624] scsi5 : sata_nv
[14315328.395973] ata5: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc=
800 irq 22
[14315328.403380] ata6: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc=
808 irq 22
[14315328.728648] ata5: SATA link down (SStatus 0 SControl 300)
[14315329.062241] ata6: SATA link down (SStatus 0 SControl 300)
[14315329.089803] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 21
[14315329.093345] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315329.104075] sata_nv 0000:00:05.2: Using SWNCQ mode
[14315329.109401] scsi6 : sata_nv
[14315329.112630] scsi7 : sata_nv
[14315329.115980] ata7: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0=
xb400 irq 21
[14315329.123554] ata8: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0=
xb408 irq 21
[14315329.448988] ata7: SATA link down (SStatus 0 SControl 300)
[14315329.935320] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315329.949978] ata8.00: ATAPI: TSSTcorp CDDVDW SH-S203B, SB00, max U=
DMA/100
[14315329.969586] ata8.00: configured for UDMA/100
[14315329.985915] scsi 7:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S2=
03B  SB00 PQ: 0 ANSI: 5
[14315329.996699] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa=
/form2 cdda tray
[14315330.004622] Uniform CD-ROM driver Revision: 3.20
[14315330.009767] sr 7:0:0:0: Attached scsi generic sg1 type 5
[14315330.016157] block2mtd: version $Revision: 1.30 $
[14315330.022363] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 20
[14315330.028478] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315330.037711] ehci_hcd 0000:00:02.1: EHCI Host Controller
[14315330.043372] ehci_hcd 0000:00:02.1: new USB bus registered, assign=
ed bus number 1
[14315330.051239] ehci_hcd 0000:00:02.1: debug port 1
[14315330.056388] ehci_hcd 0000:00:02.1: irq 20, io mem 0xfe02e000
[14315330.071713] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, dr=
iver 10 Dec 2004
[14315330.085701] usb usb1: configuration #1 chosen from 1 choice
[14315330.090587] hub 1-0:1.0: USB hub found
[14315330.096636] hub 1-0:1.0: 10 ports detected
[14315330.202238] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[14315330.206670] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315330.217524] ohci_hcd 0000:00:02.0: OHCI Host Controller
[14315330.223175] ohci_hcd 0000:00:02.0: new USB bus registered, assign=
ed bus number 2
[14315330.231020] ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
[14315330.290001] usb usb2: configuration #1 chosen from 1 choice
[14315330.295965] hub 2-0:1.0: USB hub found
[14315330.300082] hub 2-0:1.0: 10 ports detected
[14315330.379882] hub 1-0:1.0: unable to enumerate USB device on port 1
[14315330.409888] USB Universal Host Controller Interface driver v3.0
[14315330.556145] hub 1-0:1.0: unable to enumerate USB device on port 3
[14315330.732886] hub 1-0:1.0: unable to enumerate USB device on port 4
[14315330.736710] usbcore: registered new interface driver usblp
[14315330.743197] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq =
1
[14315330.749729] PNP: PS/2 appears to have AUX port disabled, if this =
is incorrect please boot with i8042.nopnp
[14315330.759911] serio: i8042 KBD port at 0x60,0x64 irq 1
[14315330.765794] mice: PS/2 mouse device common for all mice
[14315330.794589] i2c /dev entries driver
[14315330.798566] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[14315330.804815] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[14315330.810317] it87: Found IT8716F chip at 0x290, revision 0
[14315330.816523] it87: in3 is VCC (+5V)
[14315330.820288] it87: in7 is VCCH (+5V Stand-By)
[14315330.836668] input: AT Translated Set 2 keyboard as /class/input/i=
nput2
[14315330.868735] md: raid1 personality registered for level 1
[14315330.873404] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initi=
alised: dm-devel@redhat.com
[14315330.882674] Bluetooth: HCI USB driver ver 2.9
[14315330.976223] usb 2-1: new low speed USB device using ohci_hcd and =
address 2
[14315331.123334] usb 2-1: configuration #1 chosen from 1 choice
[14315331.382180] usb 2-3: new low speed USB device using ohci_hcd and =
address 3
[14315331.540000] usb 2-3: configuration #1 chosen from 1 choice
[14315331.808554] usb 2-4: new full speed USB device using ohci_hcd and=
 address 4
[14315331.940004] usb 2-4: device descriptor read/64, error -62
[14315332.173337] usb 2-4: device descriptor read/64, error -62
[14315332.402156] usb 2-4: new full speed USB device using ohci_hcd and=
 address 5
[14315332.533337] usb 2-4: device descriptor read/64, error -62
[14315332.766671] usb 2-4: device descriptor read/64, error -62
[14315332.995493] usb 2-4: new full speed USB device using ohci_hcd and=
 address 6
[14315333.407390] usb 2-4: device not accepting address 6, error -62
[14315333.532695] usb 2-4: new full speed USB device using ohci_hcd and=
 address 7
[14315333.944640] usb 2-4: device not accepting address 7, error -62
[14315333.950004] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315333.956498] usbcore: registered new interface driver hci_usb
[14315333.962672] Bluetooth: HCI UART driver ver 2.2
[14315333.968739] Bluetooth: HCI H4 protocol initialized
[14315333.973557] Bluetooth: HCI BCSP protocol initialized
[14315333.978883] cpuidle: using governor ladder
[14315333.983344] cpuidle: using governor menu
[14315333.993334] input: Microsoft Microsoft 3-Button Mouse with Intell=
iEye(TM) as /class/input/input3
[14315334.024608] input: USB HID v1.10 Mouse [Microsoft Microsoft 3-But=
ton Mouse with IntelliEye(TM)] on usb-0000:00:02.0-1
[14315334.045905] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input4
[14315334.076513] input: USB HID v1.11 Keyboard [Microsoft Natural=C2=AE=
 Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.098028] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input5
[14315334.131364] input: USB HID v1.11 Device [Microsoft Natural=C2=AE =
Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.141560] usbcore: registered new interface driver usbhid
[14315334.146883] usbhid: v2.6:USB HID core driver
[14315334.152895] Advanced Linux Sound Architecture Driver Version 1.0.=
16.
[14315334.159761] ALSA device list:
[14315334.163099]   No soundcards found.
[14315334.164925] GACT probability on
[14315334.168436] Mirror/redirect action on
[14315334.172645] u32 classifier
[14315334.175798]     Performance counters on
[14315334.179997]     input device check on=20
[14315334.186592]     Actions configured=20
[14315334.190751] IPv4 over IPv4 tunneling driver
[14315334.194811] ip_tables: (C) 2000-2006 Netfilter Core Team
[14315334.200508] TCP bic registered
[14315334.203929] TCP cubic registered
[14315334.207517] TCP westwood registered
[14315334.211369] TCP htcp registered
[14315334.214872] TCP vegas registered
[14315334.219769] TCP yeah registered
[14315334.223275] Initializing XFRM netlink socket
[14315334.226913] NET: Registered protocol family 10
[14315334.233334] IPv6 over IPv4 tunneling driver
[14315334.237681] NET: Registered protocol family 17
[14315334.242496] NET: Registered protocol family 15
[14315334.247347] Bridge firewalling registered
[14315334.252534] Bluetooth: L2CAP ver 2.9
[14315334.256474] Bluetooth: L2CAP socket layer initialized
[14315334.260911] Bluetooth: SCO (Voice Link) ver 0.5
[14315334.266327] Bluetooth: SCO socket layer initialized
[14315334.271249] Bluetooth: RFCOMM socket layer initialized
[14315334.276754] Bluetooth: RFCOMM TTY layer initialized
[14315334.281996] Bluetooth: RFCOMM ver 1.8
[14315334.286019] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[14315334.291686] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[14315334.299916] RPC: Registered udp transport module.
[14315334.303335] RPC: Registered tcp transport module.
[14315334.308419] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelat=
ech.com>
[14315334.315567] All bugs added by David S. Miller <davem@redhat.com>
[14315334.321940] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3800=
+ processors (1 cpu cores) (version 2.20.00)
[14315334.332325] powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
[14315334.338338] powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
[14315334.343459] powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
[14315334.349398] powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
[14315334.355343] powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
[14315334.362984] md: Autodetecting RAID arrays.
[14315334.367449] md: Scanned 0 and added 0 devices.
[14315334.371557] md: autorun ...
[14315334.374891] md: ... autorun DONE.
[14315334.391967] kjournald starting.  Commit interval 5 seconds
[14315334.397819] EXT3-fs: mounted filesystem with ordered data mode.
[14315334.404101] VFS: Mounted root (ext3 filesystem) readonly.
[14315334.409871] Freeing unused kernel memory: 256k freed
[14315335.297020] Marking TSC unstable due to cpufreq changes
[14315335.730012] Clocksource tsc unstable (delta =3D -255154532 ns)
[14315336.547459] scsi8 : pata_amd
[14315336.556004] scsi9 : pata_amd
[14315336.559980] ata9: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf=
000 irq 14
[14315336.569559] ata10: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0x=
f008 irq 15
[14315336.753712] ata9.01: ATAPI: Pioneer DVD-ROM ATAPIModel DVD-106S 0=
122, E1.22, max UDMA/66
[14315336.774227] ata9.01: configured for UDMA/66
[14315336.792690] scsi 8:0:1:0: CD-ROM            PIONEER  DVD-ROM DVD-=
106  1.22 PQ: 0 ANSI: 5
[14315336.812244] sr1: scsi3-mmc drive: 15x/40x cd/rw xa/form2 cdda tra=
y
[14315336.822030] sr 8:0:1:0: Attached scsi generic sg2 type 5
[14315336.836673] forcedeth: Reverse Engineered nForce ethernet driver.=
 Version 0.61.
[14315336.846671] ACPI: PCI Interrupt Link [APCH] enabled at IRQ 22
[14315336.850017] ACPI: PCI Interrupt 0000:00:08.0[A] -> Link [APCH] ->=
 GSI 22 (level, low) -> IRQ 22
[14315337.374170] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @=
 1, addr 00:17:31:aa:1e:89
[14315337.383077] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315337.408097] gameport: EMU10K1 is pci0000:01:08.1/gameport0, io 0x=
9800, speed 1201kHz
[14315337.416746] ACPI: PCI Interrupt Link [APC3] enabled at IRQ 18
[14315337.426145] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 ACPI: PCI Interrupt Link [AMC1] enabled at IRQ 21
[14315337.436674] ACPI: PCI Interrupt 0000:00:09.0[A] -> GSI 18 (level,=
 low) -> IRQ 18
[14315337.443346] ALSA sound/pci/emu10k1/emu10k1_main.c:1748: vendor=3D=
0x1102, device=3D0x2, subsystem_vendor_id=3D0x80641102, subsystem_id=3D=
0x8064
[14315337.456880] Link [AMC1] -> GSI 21 (level, low) -> IRQ 21
[14315337.462937] ALSA sound/pci/emu10k1/emu10k1_main.c:1773: <7>PCI: S=
etting latency timer of device 0000:00:09.0 to 64
[14315337.474998] Sound card name=3DSB Live 5.1
[14315337.990957] forcedeth 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @=
 1, addr 00:17:31:ac:c6:64
[14315338.000093] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315339.206917] Adding 3911788k swap on /dev/sda6.  Priority:-1 exten=
ts:1 across:3911788k
[14315339.373498] EXT3 FS on sda5, internal journal
[14315343.910005] br0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM fe=
ature.
[14315512.846677] Restarting system.
[    0.000000] Linux version 2.6.26-rc2 (ranma@melchior) (gcc version 4=
=2E2.3 (Debian 4.2.3-5)) #6 PREEMPT Sun May 18 11:35:22 CEST 2008
[    0.000000] Command line: root=3D/dev/sda5 resume=3D/dev/sda6 vga=3D=
6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3Dnomsi ro
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
[    0.000000]  BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] max_pfn_mapped =3D 1048576
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000F7B80, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT 7FEE30C0, 004C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 7FEEC540, 00F4 (r3 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 7FEE3240, 92AD (r1 NVIDIA AWRDACPI     1000 M=
SFT  3000000)
[    0.000000] ACPI: FACS 7FEE0000, 0040
[    0.000000] ACPI: SSDT 7FEEC740, 0136 (r1 PTLTD  POWERNOW        1  =
LTP        1)
[    0.000000] ACPI: HPET 7FEEC8C0, 0038 (r1 Nvidia ASUSACPI 42302E31 A=
WRD       98)
[    0.000000] ACPI: MCFG 7FEEC940, 003C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: APIC 7FEEC680, 007C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-8eb01f] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-bfff] PGTABLE
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524000
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI=
 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 7ff0=
0000:70100000)
[14315324.233334] Built 1 zonelists in Zone order, mobility grouping on=
=2E  Total pages: 514863
[14315324.233334] Kernel command line: root=3D/dev/sda5 resume=3D/dev/s=
da6 vga=3D6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3D=
nomsi ro
[14315324.233334] Initializing CPU#0
[14315324.233334] PID hash table entries: 4096 (order: 12, 32768 bytes)
[14315324.233334] Extended CMOS year: 2000
[14315324.233334] TSC calibrated against PM_TIMER
[14315324.233334] time.c: Detected 2411.104 MHz processor.
[14315324.233334] Console: colour VGA+ 80x60
[14315324.233334] console [tty0] enabled
[14315324.233334] console [ttyS0] enabled
[14315324.233334] Dentry cache hash table entries: 262144 (order: 9, 20=
97152 bytes)
[14315324.233334] Inode-cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
[14315324.233334] Checking aperture...
[14315324.233334] Node 0: aperture @ 289c000000 size 32 MB
[14315324.233334] Aperture beyond 4GB. Ignoring.
[14315324.233334] No AGP bridge found
[14315324.233334] Memory: 2056088k/2096000k available (4489k kernel cod=
e, 39052k reserved, 1754k data, 256k init)
[14315324.316530] Calibrating delay using timer specific routine.. 4827=
=2E21 BogoMIPS (lpj=3D8041947)
[14315324.323022] Mount-cache hash table entries: 256
[14315324.326661] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64=
 bytes/line)
[14315324.329994] CPU: L2 Cache: 512K (64 bytes/line)
[14315324.333327] CPU: AMD Athlon(tm) 64 Processor 3800+ stepping 01
[14315324.339621] ACPI: Core revision 20080321
[14315324.353326] enabled ExtINT on CPU#0
[14315324.356659] ENABLING IO-APIC IRQs
[14315324.359992] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1
[14315324.396296] Using local APIC timer interrupts.
[14315324.403323] Detected 12.557 MHz APIC timer.
[14315324.406656] net_namespace: 1160 bytes
[14315324.409989] NET: Registered protocol family 16
[14315324.413322] No dock devices found.
[14315324.416655] TOM: 0000000080000000 aka 2048M
[14315324.419988] ACPI: bus type pci registered
[14315324.423321] PCI: Using configuration type 1 for base access
[14315324.438519] ACPI: Interpreter enabled
[14315324.442547] ACPI: (supports S0 S1 S3 S4 S5)
[14315324.447303] ACPI: Using IOAPIC for interrupt routing
[14315324.464177] ACPI: PCI Root Bridge [PCI0] (0000:00)
[14315324.469985] PCI: Transparent bridge - 0000:00:06.0
[14315324.538601] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.546647] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.553313] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.559218] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.566645] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.573312] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.579978] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.585891] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.593310] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.599977] ACPI: PCI Interrupt Link [LUBA] (IRQs *5 7 9 10 11 14=
 15)
[14315324.605891] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.612555] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.616642] ACPI: PCI Interrupt Link [LAZA] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.623308] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.630527] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.637909] ACPI: PCI Interrupt Link [LUB2] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.645287] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.653306] ACPI: PCI Interrupt Link [LSID] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.659217] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.665900] ACPI: PCI Interrupt Link [LSA2] (IRQs *5 7 9 10 11 14=
 15)
[14315324.669972] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disable=
d.
[14315324.675584] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disable=
d.
[14315324.682239] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[14315324.686638] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disable=
d.
[14315324.692240] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disable=
d.
[14315324.698914] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0, disable=
d.
[14315324.705578] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[14315324.711240] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disable=
d.
[14315324.718319] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[14315324.725300] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[14315324.732141] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[14315324.738814] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.746565] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.753240] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[14315324.758814] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[14315324.765483] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.773222] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.779905] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[14315324.785480] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[14315324.789968] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[14315324.793301] Linux Plug and Play Support v0.97 (c) Adam Belay
[14315324.796634] pnp: PnP ACPI init
[14315324.799968] ACPI: bus type pnp registered
[14315324.810627] pnp: PnP ACPI: found 13 devices
[14315324.815176] ACPI: ACPI bus type pnp unregistered
[14315324.820094] SCSI subsystem initialized
[14315324.824313] usbcore: registered new interface driver usbfs
[14315324.829968] usbcore: registered new interface driver hub
[14315324.833301] usbcore: registered new device driver usb
[14315324.836635] PCI: Using ACPI for IRQ routing
[14315324.839968] testing the IO APIC.......................
[14315324.843301]=20
[14315324.845351] .................................... done.
[14315324.860685] Bluetooth: Core ver 2.11
[14315324.864708] NET: Registered protocol family 31
[14315324.869516] Bluetooth: HCI device and connection manager initiali=
zed
[14315324.873301] Bluetooth: HCI socket layer initialized
[14315324.876634] DMAR:parse DMAR table failure.
[14315324.887858] system 00:01: ioport range 0x1000-0x107f has been res=
erved
[14315324.894743] system 00:01: ioport range 0x1080-0x10ff has been res=
erved
[14315324.901628] system 00:01: ioport range 0x1400-0x147f has been res=
erved
[14315324.908516] system 00:01: ioport range 0x1480-0x14ff has been res=
erved
[14315324.915405] system 00:01: ioport range 0x1800-0x187f has been res=
erved
[14315324.922290] system 00:01: ioport range 0x1880-0x18ff has been res=
erved
[14315324.929184] system 00:02: ioport range 0x4d0-0x4d1 has been reser=
ved
[14315324.935902] system 00:02: ioport range 0x800-0x87f has been reser=
ved
[14315324.942615] system 00:02: ioport range 0x290-0x297 has been reser=
ved
[14315324.949338] system 00:0b: iomem range 0xf0000000-0xf3ffffff could=
 not be reserved
[14315324.957269] system 00:0c: iomem range 0xd2800-0xd3fff has been re=
served
[14315324.964238] system 00:0c: iomem range 0xf0000-0xf7fff could not b=
e reserved
[14315324.973193] system 00:0c: iomem range 0xf8000-0xfbfff could not b=
e reserved
[14315324.980600] system 00:0c: iomem range 0xfc000-0xfffff could not b=
e reserved
[14315324.988007] system 00:0c: iomem range 0xfefff000-0xfefff0ff could=
 not be reserved
[14315324.995934] system 00:0c: iomem range 0x7fee0000-0x7fefffff could=
 not be reserved
[14315325.003388] system 00:0c: iomem range 0xffff0000-0xffffffff could=
 not be reserved
[14315325.011315] system 00:0c: iomem range 0x0-0x9ffff could not be re=
served
[14315325.018288] system 00:0c: iomem range 0x100000-0x7fedffff could n=
ot be reserved
[14315325.026250] system 00:0c: iomem range 0xfec00000-0xfec00fff could=
 not be reserved
[14315325.034015] system 00:0c: iomem range 0xfee00000-0xfeefffff could=
 not be reserved
[14315325.041941] system 00:0c: iomem range 0xfefff000-0xfeffffff could=
 not be reserved
[14315325.049894] system 00:0c: iomem range 0xfff80000-0xfff80fff could=
 not be reserved
[14315325.057820] system 00:0c: iomem range 0xfff90000-0xfffbffff could=
 not be reserved
[14315325.065770] system 00:0c: iomem range 0xfffed000-0xfffeffff could=
 not be reserved
[14315325.074050] PCI: Bridge: 0000:00:06.0
[14315325.078085]   IO window: 9000-9fff
[14315325.081858]   MEM window: 0xfde00000-0xfdefffff
[14315325.086754]   PREFETCH window: disabled.
[14315325.091046] PCI: Bridge: 0000:00:0a.0
[14315325.095076]   IO window: 8000-8fff
[14315325.099729]   MEM window: 0xfdd00000-0xfddfffff
[14315325.103500]   PREFETCH window: 0x00000000e8000000-0x00000000effff=
fff
[14315325.110213] PCI: Bridge: 0000:00:0b.0
[14315325.114245]   IO window: disabled.
[14315325.118017]   MEM window: disabled.
[14315325.122946]   PREFETCH window: disabled.
[14315325.126804] PCI: Bridge: 0000:00:0c.0
[14315325.130833]   IO window: disabled.
[14315325.134600]   MEM window: disabled.
[14315325.138458]   PREFETCH window: disabled.
[14315325.142769] PCI: Bridge: 0000:00:0d.0
[14315325.146801]   IO window: disabled.
[14315325.150573]   MEM window: disabled.
[14315325.154423]   PREFETCH window: disabled.
[14315325.158715] PCI: Bridge: 0000:00:0e.0
[14315325.163038]   IO window: 6000-7fff
[14315325.166811]   MEM window: 0xfdc00000-0xfdcfffff
[14315325.170857]   PREFETCH window: disabled.
[14315325.175763] PCI: Bridge: 0000:00:0f.0
[14315325.179795]   IO window: disabled.
[14315325.183566]   MEM window: disabled.
[14315325.187417]   PREFETCH window: disabled.
[14315325.191783] NET: Registered protocol family 2
[14315325.229002] IP route cache hash table entries: 65536 (order: 7, 5=
24288 bytes)
[14315325.237130] TCP established hash table entries: 262144 (order: 10=
, 4194304 bytes)
[14315325.246670] TCP bind hash table entries: 65536 (order: 7, 524288 =
bytes)
[14315325.259886] TCP: Hash tables configured (established 262144 bind =
65536)
[14315325.266864] TCP reno registered
[14315325.278702] NET: Registered protocol family 1
[14315325.284351] Installing knfsd (copyright (C) 1996 okir@monad.swb.d=
e).
[14315325.291286] JFFS2 version 2.2. (NAND) =C3=82=C2=A9 2001-2006 Red =
Hat, Inc.
[14315325.297709] fuse init (API version 7.9)
[14315325.302558] SGI XFS with security attributes, large block/inode n=
umbers, no debug enabled
[14315325.310222] msgmni has been set to 4016 for ipc namespace fffffff=
f807eda90
[14315325.317540] Block layer SCSI generic (bsg) driver version 0.4 loa=
ded (major 254)
[14315325.326190] io scheduler noop registered
[14315325.330478] io scheduler anticipatory registered
[14315325.335461] io scheduler deadline registered
[14315325.340092] io scheduler cfq registered (default)
[14315325.357112] pci 0000:00:05.0: Enabling HT MSI Mapping
[14315325.362538] pci 0000:00:05.1: Enabling HT MSI Mapping
[14315325.367654] pci 0000:00:05.2: Enabling HT MSI Mapping
[14315325.373088] pci 0000:00:06.0: Enabling HT MSI Mapping
[14315325.378525] pci 0000:00:08.0: Enabling HT MSI Mapping
[14315325.383949] pci 0000:00:09.0: Enabling HT MSI Mapping
[14315325.389391] pci 0000:00:0a.0: Enabling HT MSI Mapping
[14315325.394824] pci 0000:00:0b.0: Enabling HT MSI Mapping
[14315325.400251] pci 0000:00:0c.0: Enabling HT MSI Mapping
[14315325.405693] pci 0000:00:0d.0: Enabling HT MSI Mapping
[14315325.411118] pci 0000:00:0e.0: Enabling HT MSI Mapping
[14315325.416561] pci 0000:00:0f.0: Enabling HT MSI Mapping
[14315325.422095] assign_interrupt_mode Found MSI capability
[14315325.427487] assign_interrupt_mode Found MSI capability
[14315325.433108] assign_interrupt_mode Found MSI capability
[14315325.438688] assign_interrupt_mode Found MSI capability
[14315325.444251] assign_interrupt_mode Found MSI capability
[14315325.449836] assign_interrupt_mode Found MSI capability
[14315325.455611] input: Power Button (FF) as /class/input/input0
[14315325.461546] ACPI: Power Button (FF) [PWRF]
[14315325.466074] input: Power Button (CM) as /class/input/input1
[14315325.472006] ACPI: Power Button (CM) [PWRB]
[14315325.476568] ACPI: PNP0C0B:00 is registered as cooling_device0
[14315325.482677] ACPI: Fan [FAN] (on)
[14315325.486384] ACPI: ACPI0007:00 is registered as cooling_device1
[14315325.493377] ACPI: LNXTHERM:01 is registered as thermal_zone0
[14315325.499642] ACPI: Thermal Zone [THRM] (40 C)
[14315325.525116] Real Time Clock Driver v1.12ac
[14315325.529584] Linux agpgart interface v0.103
[14315325.532404] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, =
IRQ sharing disabled
[14315325.542506] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550=
A
[14315325.549179] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.555696] loop: module loaded
[14315325.559210] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[14315325.564192] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[14315325.570689] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[14315325.577143] e100: Copyright(c) 1999-2006 Intel Corporation
[14315325.583039] tun: Universal TUN/TAP device driver, 1.6
[14315325.589215] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com=
>
[14315325.595842] Driver 'sd' needs updating - please use bus_type meth=
ods
[14315325.602579] Driver 'sr' needs updating - please use bus_type meth=
ods
[14315325.609799] ACPI: PCI Interrupt Link [APC7] enabled at IRQ 16
[14315325.615919] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315326.627010] ahci 0000:06:00.0: AHCI 0001.0000 32 slots 2 ports 3 =
Gbps 0x3 impl SATA mode
[14315326.635542] ahci 0000:06:00.0: flags: 64bit ncq pm led clo pmp pi=
o slum part=20
[14315326.643321] scsi0 : ahci
[14315326.646316] scsi1 : ahci
[14315326.649311] ata1: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe100 irq 16
[14315326.658933] ata2: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe180 irq 16
[14315326.984916] ata1: SATA link down (SStatus 0 SControl 300)
[14315327.308608] ata2: SATA link down (SStatus 0 SControl 300)
[14315327.313818] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
[14315327.319931] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315327.329945] sata_nv 0000:00:05.0: Using SWNCQ mode
[14315327.335280] scsi2 : sata_nv
[14315327.338510] scsi3 : sata_nv
[14315327.341859] ata3: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd=
c00 irq 23
[14315327.349261] ata4: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd=
c08 irq 23
[14315327.827615] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315327.843335] ata3.00: ATA-8: SAMSUNG HD501LJ, CR100-12, max UDMA7
[14315327.846670] ata3.00: 976773168 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
[14315327.863111] ata3.00: configured for UDMA/133
[14315328.184651] ata4: SATA link down (SStatus 0 SControl 300)
[14315328.212771] isa bounce pool size: 16 pages
[14315328.216734] scsi 2:0:0:0: Direct-Access     ATA      SAMSUNG HD50=
1LJ  CR10 PQ: 0 ANSI: 5
[14315328.224599] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.233109] sd 2:0:0:0: [sda] Write Protect is off
[14315328.237478] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.247000] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.254580] sd 2:0:0:0: [sda] Write Protect is off
[14315328.259791] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.269276]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[14315328.323288] sd 2:0:0:0: [sda] Attached SCSI disk
[14315328.330130] sd 2:0:0:0: Attached scsi generic sg0 type 0
[14315328.336268] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
[14315328.342490] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315328.353291] sata_nv 0000:00:05.1: Using SWNCQ mode
[14315328.358638] scsi4 : sata_nv
[14315328.361866] scsi5 : sata_nv
[14315328.365218] ata5: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc=
800 irq 22
[14315328.372623] ata6: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc=
808 irq 22
[14315328.697890] ata5: SATA link down (SStatus 0 SControl 300)
[14315329.045558] ata6: SATA link down (SStatus 0 SControl 300)
[14315329.073128] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 21
[14315329.076678] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315329.087411] sata_nv 0000:00:05.2: Using SWNCQ mode
[14315329.092739] scsi6 : sata_nv
[14315329.095968] scsi7 : sata_nv
[14315329.099315] ata7: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0=
xb400 irq 21
[14315329.106890] ata8: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0=
xb408 irq 21
[14315329.432324] ata7: SATA link down (SStatus 0 SControl 300)
[14315329.918653] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315329.933312] ata8.00: ATAPI: TSSTcorp CDDVDW SH-S203B, SB00, max U=
DMA/100
[14315329.952917] ata8.00: configured for UDMA/100
[14315329.969307] scsi 7:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S2=
03B  SB00 PQ: 0 ANSI: 5
[14315329.980002] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa=
/form2 cdda tray
[14315329.987925] Uniform CD-ROM driver Revision: 3.20
[14315329.993069] sr 7:0:0:0: Attached scsi generic sg1 type 5
[14315329.999580] block2mtd: version $Revision: 1.30 $
[14315330.005787] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 20
[14315330.011906] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315330.020034] ehci_hcd 0000:00:02.1: EHCI Host Controller
[14315330.025697] ehci_hcd 0000:00:02.1: new USB bus registered, assign=
ed bus number 1
[14315330.033567] ehci_hcd 0000:00:02.1: debug port 1
[14315330.039828] ehci_hcd 0000:00:02.1: irq 20, io mem 0xfe02e000
[14315330.055050] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, dr=
iver 10 Dec 2004
[14315330.069021] usb usb1: configuration #1 chosen from 1 choice
[14315330.073904] hub 1-0:1.0: USB hub found
[14315330.079943] hub 1-0:1.0: 10 ports detected
[14315330.185545] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[14315330.190004] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315330.200850] ohci_hcd 0000:00:02.0: OHCI Host Controller
[14315330.206494] ohci_hcd 0000:00:02.0: new USB bus registered, assign=
ed bus number 2
[14315330.214338] ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
[14315330.273335] usb usb2: configuration #1 chosen from 1 choice
[14315330.279300] hub 2-0:1.0: USB hub found
[14315330.283418] hub 2-0:1.0: 10 ports detected
[14315330.363216] hub 1-0:1.0: unable to enumerate USB device on port 1
[14315330.393223] USB Universal Host Controller Interface driver v3.0
[14315330.539481] hub 1-0:1.0: unable to enumerate USB device on port 3
[14315330.716235] hub 1-0:1.0: unable to enumerate USB device on port 4
[14315330.720045] usbcore: registered new interface driver usblp
[14315330.726533] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq =
1
[14315330.733067] PNP: PS/2 appears to have AUX port disabled, if this =
is incorrect please boot with i8042.nopnp
[14315330.743247] serio: i8042 KBD port at 0x60,0x64 irq 1
[14315330.749128] mice: PS/2 mouse device common for all mice
[14315330.777922] i2c /dev entries driver
[14315330.781891] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[14315330.788138] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[14315330.793642] it87: Found IT8716F chip at 0x290, revision 0
[14315330.799837] it87: in3 is VCC (+5V)
[14315330.803602] it87: in7 is VCCH (+5V Stand-By)
[14315330.820001] input: AT Translated Set 2 keyboard as /class/input/i=
nput2
[14315330.852186] md: raid1 personality registered for level 1
[14315330.856737] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initi=
alised: dm-devel@redhat.com
[14315330.865963] Bluetooth: HCI USB driver ver 2.9
[14315330.959504] usb 2-1: new low speed USB device using ohci_hcd and =
address 2
[14315331.106668] usb 2-1: configuration #1 chosen from 1 choice
[14315331.365515] usb 2-3: new low speed USB device using ohci_hcd and =
address 3
[14315331.523334] usb 2-3: configuration #1 chosen from 1 choice
[14315331.791887] usb 2-4: new full speed USB device using ohci_hcd and=
 address 4
[14315331.923338] usb 2-4: device descriptor read/64, error -62
[14315332.156671] usb 2-4: device descriptor read/64, error -62
[14315332.385515] usb 2-4: new full speed USB device using ohci_hcd and=
 address 5
[14315332.516671] usb 2-4: device descriptor read/64, error -62
[14315332.750004] usb 2-4: device descriptor read/64, error -62
[14315332.978851] usb 2-4: new full speed USB device using ohci_hcd and=
 address 6
[14315333.390725] usb 2-4: device not accepting address 6, error -62
[14315333.516027] usb 2-4: new full speed USB device using ohci_hcd and=
 address 7
[14315333.927978] usb 2-4: device not accepting address 7, error -62
[14315333.933337] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315333.939825] usbcore: registered new interface driver hci_usb
[14315333.945995] Bluetooth: HCI UART driver ver 2.2
[14315333.952061] Bluetooth: HCI H4 protocol initialized
[14315333.956877] Bluetooth: HCI BCSP protocol initialized
[14315333.962203] cpuidle: using governor ladder
[14315333.966663] cpuidle: using governor menu
[14315333.976667] input: Microsoft Microsoft 3-Button Mouse with Intell=
iEye(TM) as /class/input/input3
[14315334.007940] input: USB HID v1.10 Mouse [Microsoft Microsoft 3-But=
ton Mouse with IntelliEye(TM)] on usb-0000:00:02.0-1
[14315334.029233] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input4
[14315334.059844] input: USB HID v1.11 Keyboard [Microsoft Natural=C2=AE=
 Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.081366] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input5
[14315334.114693] input: USB HID v1.11 Device [Microsoft Natural=C2=AE =
Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.124887] usbcore: registered new interface driver usbhid
[14315334.130213] usbhid: v2.6:USB HID core driver
[14315334.136227] Advanced Linux Sound Architecture Driver Version 1.0.=
16.
[14315334.143094] ALSA device list:
[14315334.146431]   No soundcards found.
[14315334.148254] GACT probability on
[14315334.151765] Mirror/redirect action on
[14315334.155975] u32 classifier
[14315334.159128]     Performance counters on
[14315334.163328]     input device check on=20
[14315334.169922]     Actions configured=20
[14315334.174081] IPv4 over IPv4 tunneling driver
[14315334.178142] ip_tables: (C) 2000-2006 Netfilter Core Team
[14315334.183841] TCP bic registered
[14315334.187260] TCP cubic registered
[14315334.190848] TCP westwood registered
[14315334.194698] TCP htcp registered
[14315334.198203] TCP vegas registered
[14315334.203098] TCP yeah registered
[14315334.206602] Initializing XFRM netlink socket
[14315334.210240] NET: Registered protocol family 10
[14315334.216668] IPv6 over IPv4 tunneling driver
[14315334.221013] NET: Registered protocol family 17
[14315334.225821] NET: Registered protocol family 15
[14315334.230670] Bridge firewalling registered
[14315334.235847] Bluetooth: L2CAP ver 2.9
[14315334.239786] Bluetooth: L2CAP socket layer initialized
[14315334.244214] Bluetooth: SCO (Voice Link) ver 0.5
[14315334.249630] Bluetooth: SCO socket layer initialized
[14315334.254543] Bluetooth: RFCOMM socket layer initialized
[14315334.260049] Bluetooth: RFCOMM TTY layer initialized
[14315334.265292] Bluetooth: RFCOMM ver 1.8
[14315334.269315] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[14315334.274982] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[14315334.280348] RPC: Registered udp transport module.
[14315334.286542] RPC: Registered tcp transport module.
[14315334.291716] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelat=
ech.com>
[14315334.298863] All bugs added by David S. Miller <davem@redhat.com>
[14315334.305229] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3800=
+ processors (1 cpu cores) (version 2.20.00)
[14315334.315605] powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
[14315334.321620] powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
[14315334.326740] powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
[14315334.332685] powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
[14315334.338629] powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
[14315334.346269] md: Autodetecting RAID arrays.
[14315334.350736] md: Scanned 0 and added 0 devices.
[14315334.354843] md: autorun ...
[14315334.358176] md: ... autorun DONE.
[14315334.378632] kjournald starting.  Commit interval 5 seconds
[14315334.383342] EXT3-fs: mounted filesystem with ordered data mode.
[14315334.389657] VFS: Mounted root (ext3 filesystem) readonly.
[14315334.395955] Freeing unused kernel memory: 256k freed
[14315335.297594] Marking TSC unstable due to cpufreq changes
[14315335.730019] Clocksource tsc unstable (delta =3D -254354539 ns)
[14315336.187994] scsi8 : pata_amd
[14315336.206951] scsi9 : pata_amd
[14315336.211289] ata9: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf=
000 irq 14
[14315336.230968] ata10: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0x=
f008 irq 15
[14315336.450486] ata9.01: ATAPI: Pioneer DVD-ROM ATAPIModel DVD-106S 0=
122, E1.22, max UDMA/66
[14315336.486799] ata9.01: configured for UDMA/66
[14315336.520587] scsi 8:0:1:0: CD-ROM            PIONEER  DVD-ROM DVD-=
106  1.22 PQ: 0 ANSI: 5
[14315336.533339] sr1: scsi3-mmc drive: 15x/40x cd/rw xa/form2 cdda tra=
y
[14315336.554239] sr 8:0:1:0: Attached scsi generic sg2 type 5
[14315336.595616] gameport: EMU10K1 is pci0000:01:08.1/gameport0, io 0x=
9800, speed 1200kHz
[14315336.609411] ACPI: PCI Interrupt Link [APC3] enabled at IRQ 18
[14315336.615888] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315336.626735] ALSA sound/pci/emu10k1/emu10k1_main.c:1748: vendor=3D=
0x1102, device=3D0x2, subsystem_vendor_id=3D0x80641102, subsystem_id=3D=
0x8064
[14315336.640098] ALSA sound/pci/emu10k1/emu10k1_main.c:1773: Sound car=
d name=3DSB Live 5.1
[14315336.815269] forcedeth: Reverse Engineered nForce ethernet driver.=
 Version 0.61.
[14315336.826591] ACPI: PCI Interrupt Link [APCH] enabled at IRQ 22
[14315336.830011] ACPI: PCI Interrupt 0000:00:08.0[A] -> Link [APCH] ->=
 GSI 22 (level, low) -> IRQ 22
[14315337.364191] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @=
 1, addr 00:17:31:aa:1e:89
[14315337.373122] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315337.386672] ACPI: PCI Interrupt Link [AMC1] enabled at IRQ 21
[14315337.392797] ACPI: PCI Interrupt 0000:00:09.0[A] -> Link [AMC1] ->=
 GSI 21 (level, low) -> IRQ 21
[14315337.917670] forcedeth 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @=
 1, addr 00:17:31:ac:c6:64
[14315337.926821] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315339.234610] Adding 3911788k swap on /dev/sda6.  Priority:-1 exten=
ts:1 across:3911788k
[14315339.384616] EXT3 FS on sda5, internal journal
[14315344.014128] br0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM fe=
ature.
[14315372.154367] PM: Hibernation mode set to 'platform'
[14315372.166833] PM: Marking nosave pages: 000000000009f000 - 00000000=
00100000
[14315372.174210] PM: Basic memory bitmaps created
[14315372.178928] PM: Syncing filesystems ... done.
[14315372.200197] Freezing user space processes ... (elapsed 0.00 secon=
ds) done.
[14315372.208527] Freezing remaining freezable tasks ... (elapsed 0.00 =
seconds) done.
[14315372.216672] PM: Shrinking memory...  =08-=08done (0 pages freed)
[14315372.367805] PM: Freed 0 kbytes in 0.14 seconds (0.00 MB/s)
[14315372.374473] Suspending console(s)
[14315372.380623] sd 2:0:0:0: [sda] Synchronizing SCSI cache
[14315372.400001] ACPI handle has no context!
[14315372.400001] serial 00:08: disabled
[14315372.426722] ACPI: PCI interrupt for device 0000:06:00.0 disabled
[14315372.433749] ACPI: PCI interrupt for device 0000:01:08.0 disabled
[14315372.433760] ACPI handle has no context!
[14315372.473374] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14315372.473400] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14315372.473426] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14315372.473462] ACPI: PCI interrupt for device 0000:00:02.1 disabled
[14315372.473472] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14315372.473607] ACPI: Preparing to enter system sleep state S4
[14315372.474088] Extended CMOS year: 2000
[14315372.474134] PM: Creating hibernation image:=20
[14315372.476670] PM: Need to copy 42177 pages
[14315372.476670] PM: Normal pages needed: 42177 + 1024 + 38, available=
 pages: 481725
[14315372.476670] PM: Hibernation image created (42177 pages copied)
[14315372.476670] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70=
10600070106
[14315372.476670] svm_cpu_init: svm_data is NULL on 0
[14315372.476670] Extended CMOS year: 2000
[14315372.486423] ACPI: Unable to turn cooling device [ffff81007f842890=
] 'off'
[14315372.486474] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315372.486478] PCI: Setting latency timer of device 0000:00:02.0 to =
64
[14315372.506677] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315372.506681] PCI: Setting latency timer of device 0000:00:02.1 to =
64
[14315372.506695] PM: Writing back config space on device 0000:00:04.0 =
at offset 1 (was b00001, writing b00005)
[14315372.506702] PCI: Setting latency timer of device 0000:00:04.0 to =
64
[14315372.506715] PM: Writing back config space on device 0000:00:05.0 =
at offset 1 (was b00003, writing b00007)
[14315372.506721] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315372.506724] PCI: Setting latency timer of device 0000:00:05.0 to =
64
[14315372.506736] PM: Writing back config space on device 0000:00:05.1 =
at offset 1 (was b00003, writing b00007)
[14315372.506742] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315372.506746] PCI: Setting latency timer of device 0000:00:05.1 to =
64
[14315372.506758] PM: Writing back config space on device 0000:00:05.2 =
at offset 1 (was b00003, writing b00007)
[14315372.506764] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315372.506767] PCI: Setting latency timer of device 0000:00:05.2 to =
64
[14315372.506780] PCI: Setting latency timer of device 0000:00:06.0 to =
64
[14315372.507902] ata10: port disabled. ignoring.
[14315372.520012] PM: Writing back config space on device 0000:00:08.0 =
at offset f (was 14010100, writing 1401010a)
[14315372.520017] PM: Writing back config space on device 0000:00:08.0 =
at offset 7 (was 0, writing fe028000)
[14315372.520020] PM: Writing back config space on device 0000:00:08.0 =
at offset 6 (was 0, writing fe029000)
[14315372.520022] PM: Writing back config space on device 0000:00:08.0 =
at offset 5 (was 1, writing b001)
[14315372.520025] PM: Writing back config space on device 0000:00:08.0 =
at offset 4 (was 0, writing fe02a000)
[14315372.520028] PM: Writing back config space on device 0000:00:08.0 =
at offset 1 (was b00000, writing b00007)
[14315372.520243] eth0: no link during initialization.
[14315372.533345] PM: Writing back config space on device 0000:00:09.0 =
at offset f (was 14010100, writing 1401010a)
[14315372.533349] PM: Writing back config space on device 0000:00:09.0 =
at offset 7 (was 0, writing fe025000)
[14315372.533352] PM: Writing back config space on device 0000:00:09.0 =
at offset 6 (was 0, writing fe026000)
[14315372.533354] PM: Writing back config space on device 0000:00:09.0 =
at offset 5 (was 1, writing ac01)
[14315372.533357] PM: Writing back config space on device 0000:00:09.0 =
at offset 4 (was 0, writing fe027000)
[14315372.533360] PM: Writing back config space on device 0000:00:09.0 =
at offset 1 (was b00000, writing b00007)
[14315372.533586] eth1: no link during initialization.
[14315372.533598] PCI: Setting latency timer of device 0000:00:0a.0 to =
64
[14315372.533610] PCI: Setting latency timer of device 0000:00:0b.0 to =
64
[14315372.533622] PCI: Setting latency timer of device 0000:00:0c.0 to =
64
[14315372.533633] PCI: Setting latency timer of device 0000:00:0d.0 to =
64
[14315372.533644] PCI: Setting latency timer of device 0000:00:0e.0 to =
64
[14315372.533656] PCI: Setting latency timer of device 0000:00:0f.0 to =
64
[14315372.546684] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315372.554236] PM: Writing back config space on device 0000:06:00.0 =
at offset 1 (was 100003, writing 100007)
[14315372.554247] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315372.554251] PCI: Setting latency timer of device 0000:06:00.0 to =
64
[14315372.557235] serial 00:08: activated
[14315372.557269] sd 2:0:0:0: [sda] Starting disk
[14315372.690357] ata9.01: ACPI cmd ef/03:44:00:00:00:b0 filtered out
[14315372.690360] ata9.01: ACPI cmd ef/03:0c:00:00:00:b0 filtered out
[14315372.690379] ata9: nv_mode_filter: 0x1f01f&0x1f01f->0x1f01f, BIOS=3D=
0x1f000 (0xc50000) ACPI=3D0x1f01f (600:30:0x1c)
[14315372.703436] ata9.01: configured for UDMA/66
[14315372.826679] ata7: SATA link down (SStatus 0 SControl 300)
[14315372.837200] ata4: SATA link down (SStatus 0 SControl 300)
[14315372.847724] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315372.847780] ata6: SATA link down (SStatus 0 SControl 300)
[14315372.858387] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315372.858420] ata5: SATA link down (SStatus 0 SControl 300)
[14315372.868993] ata1: SATA link down (SStatus 0 SControl 300)
[14315372.869092] ata8.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315372.869157] ata3.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315372.869160] ata3.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[14315372.876679] ata2: SATA link down (SStatus 0 SControl 300)
[14315372.880068] ata8.00: configured for UDMA/100
[14315372.880168] ata3.00: configured for UDMA/133
[14315372.880225] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315372.880238] sd 2:0:0:0: [sda] Write Protect is off
[14315372.880240] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[14315372.880261] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315373.700276] PM: writing image.
[14315373.704044] PM: Free swap pages: 977947
[14315373.711976] PM: Saving image data pages (42260 pages) ...     =08=
=08=08=08  0%=08=08=08=08  1%=08=08=08=08  2%=08=08=08=08  3%=08=08=08=08=
  4%=08=08=08=08  5%=08=08=08=08  6%=08=08=08=08  7%=08=08=08=08  8%=08=
=08=08=08  9%=08=08=08=08 10%=08=08=08=08 11%=08=08=08=08 12%=08=08=08=08=
 13%=08=08=08=08 14%=08=08=08=08 15%=08=08=08=08 16%=08=08=08=08 17%=08=
=08=08=08 18%=08=08=08=08 19%=08=08=08=08 20%=08=08=08=08 21%=08=08=08=08=
 22%=08=08=08=08 23%=08=08=08=08 24%=08=08=08=08 25%=08=08=08=08 26%=08=
=08=08=08 27%=08=08=08=08 28%=08=08=08=08 29%=08=08=08=08 30%=08=08=08=08=
 31%=08=08=08=08 32%=08=08=08=08 33%=08=08=08=08 34%=08=08=08=08 35%=08=
=08=08=08 36%=08=08=08=08 37%=08=08=08=08 38%=08=08=08=08 39%=08=08=08=08=
 40%=08=08=08=08 41%=08=08=08=08 42%=08=08=08=08 43%=08=08=08=08 44%=08=
=08=08=08 45%=08=08=08=08 46%=08=08=08=08 47%=08=08=08=08 48%=08=08=08=08=
 49%=08=08=08=08 50%=08=08=08=08 51%=08=08=08=08 52%=08=08=08=08 53%=08=
=08=08=08 54%=08=08=08=08 55%=08=08=08=08 56%=08=08=08=08 57%=08=08=08=08=
 58%=08=08=08=08 59%=08=08=08=08 60%=08=08=08=08 61%=08=08=08=08 62%=08=
=08=08=08 63%=08=08=08=08 64%=08=08=08=08 65%=08=08=08=08 66%=08=08=08=08=
 67%=08=08=08=08 68%=08=08=08=08 69%=08=08=08=08 70%=08=08=08=08 71%=08=
=08=08=08 72%=08=08=08=08 73%=08=08=08=08 74%=08=08=08=08 75%=08=08=08=08=
 76%=08=08=08=08 77%=08=08=08=08 78%=08=08=08=08 79%=08=08=08=08 80%=08=
=08=08=08 81%=08=08=08=08 82%=08=08=08=08 83%=08=08=08=08 84%=08=08=08=08=
 85%=08=08=08=08 86%=08=08=08=08 87%=08=08=08=08 88%=08=08=08=08 89%=08=
=08=08=08 90%=08=08=08=08 91%=08=08=08=08 92%=08=08=08=08 93%=08=08=08=08=
 94%=08=08=08=08 95%=08=08=08=08 96%=08=08=08=08 97%=08=08=08=08 98%=08=
=08=08=08 99%=08=08=08=08100%=08=08=08=08done
[14315375.750167] PM: Wrote 169040 kbytes in 2.03 seconds (83.27 MB/s)
[14315375.760237] PM: S|
[14315376.023595] Suspending console(s)
[    0.000000] Command line: root=3D/dev/sda5 resume=3D/dev/sda6 vga=3D=
6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3Dnomsi ro
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
[    0.000000]  BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] max_pfn_mapped =3D 1048576
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000F7B80, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT 7FEE30C0, 004C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 7FEEC540, 00F4 (r3 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 7FEE3240, 92AD (r1 NVIDIA AWRDACPI     1000 M=
SFT  3000000)
[    0.000000] ACPI: FACS 7FEE0000, 0040
[    0.000000] ACPI: SSDT 7FEEC740, 0136 (r1 PTLTD  POWERNOW        1  =
LTP        1)
[    0.000000] ACPI: HPET 7FEEC8C0, 0038 (r1 Nvidia ASUSACPI 42302E31 A=
WRD       98)
[    0.000000] ACPI: MCFG 7FEEC940, 003C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: APIC 7FEEC680, 007C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-8eb01f] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-bfff] PGTABLE
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524000
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI=
 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 7ff0=
0000:70100000)
[14315324.233334] Built 1 zonelists in Zone order, mobility grouping on=
=2E  Total pages: 514863
[14315324.233334] Kernel command line: root=3D/dev/sda5 resume=3D/dev/s=
da6 vga=3D6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3D=
nomsi ro
[14315324.233334] Initializing CPU#0
[14315324.233334] PID hash table entries: 4096 (order: 12, 32768 bytes)
[14315324.233334] Extended CMOS year: 2000
[14315324.233334] TSC calibrated against PM_TIMER
[14315324.233334] time.c: Detected 2411.112 MHz processor.
[14315324.233334] Console: colour VGA+ 80x60
[14315324.233334] console [tty0] enabled
[14315324.233334] console [ttyS0] enabled
[14315324.233334] Dentry cache hash table entries: 262144 (order: 9, 20=
97152 bytes)
[14315324.233334] Inode-cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
[14315324.233334] Checking aperture...
[14315324.233334] Node 0: aperture @ 2894000000 size 32 MB
[14315324.233334] Aperture beyond 4GB. Ignoring.
[14315324.233334] No AGP bridge found
[14315324.233334] Memory: 2056088k/2096000k available (4489k kernel cod=
e, 39052k reserved, 1754k data, 256k init)
[14315324.316530] Calibrating delay using timer specific routine.. 4827=
=2E21 BogoMIPS (lpj=3D8041949)
[14315324.323021] Mount-cache hash table entries: 256
[14315324.326661] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64=
 bytes/line)
[14315324.329994] CPU: L2 Cache: 512K (64 bytes/line)
[14315324.333327] CPU: AMD Athlon(tm) 64 Processor 3800+ stepping 01
[14315324.339621] ACPI: Core revision 20080321
[14315324.353326] enabled ExtINT on CPU#0
[14315324.356659] ENABLING IO-APIC IRQs
[14315324.359992] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1
[14315324.396295] Using local APIC timer interrupts.
[14315324.403323] Detected 12.557 MHz APIC timer.
[14315324.406656] net_namespace: 1160 bytes
[14315324.409989] NET: Registered protocol family 16
[14315324.413322] No dock devices found.
[14315324.416655] TOM: 0000000080000000 aka 2048M
[14315324.419988] ACPI: bus type pci registered
[14315324.423321] PCI: Using configuration type 1 for base access
[14315324.438520] ACPI: Interpreter enabled
[14315324.442549] ACPI: (supports S0 S1 S3 S4 S5)
[14315324.447303] ACPI: Using IOAPIC for interrupt routing
[14315324.464040] ACPI: PCI Root Bridge [PCI0] (0000:00)
[14315324.469921] PCI: Transparent bridge - 0000:00:06.0
[14315324.538606] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.546647] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.553313] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.559228] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.566645] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.573312] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.579978] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.585899] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.593310] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.599977] ACPI: PCI Interrupt Link [LUBA] (IRQs *5 7 9 10 11 14=
 15)
[14315324.605890] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.612555] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.616642] ACPI: PCI Interrupt Link [LAZA] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.623308] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.630526] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.637917] ACPI: PCI Interrupt Link [LUB2] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.645304] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.653306] ACPI: PCI Interrupt Link [LSID] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.659235] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.665894] ACPI: PCI Interrupt Link [LSA2] (IRQs *5 7 9 10 11 14=
 15)
[14315324.669972] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disable=
d.
[14315324.675585] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disable=
d.
[14315324.682242] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[14315324.686638] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disable=
d.
[14315324.692239] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disable=
d.
[14315324.698904] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0, disable=
d.
[14315324.705571] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[14315324.711249] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disable=
d.
[14315324.718328] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[14315324.725318] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[14315324.732150] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[14315324.738824] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.746575] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.753221] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[14315324.758816] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[14315324.765456] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.773215] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.779888] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[14315324.785492] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[14315324.789968] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[14315324.793301] Linux Plug and Play Support v0.97 (c) Adam Belay
[14315324.796634] pnp: PnP ACPI init
[14315324.799968] ACPI: bus type pnp registered
[14315324.810364] pnp: PnP ACPI: found 13 devices
[14315324.814913] ACPI: ACPI bus type pnp unregistered
[14315324.820061] SCSI subsystem initialized
[14315324.824281] usbcore: registered new interface driver usbfs
[14315324.829968] usbcore: registered new interface driver hub
[14315324.833301] usbcore: registered new device driver usb
[14315324.836635] PCI: Using ACPI for IRQ routing
[14315324.839968] testing the IO APIC.......................
[14315324.843301]=20
[14315324.845357] .................................... done.
[14315324.860722] Bluetooth: Core ver 2.11
[14315324.864743] NET: Registered protocol family 31
[14315324.869552] Bluetooth: HCI device and connection manager initiali=
zed
[14315324.873301] Bluetooth: HCI socket layer initialized
[14315324.876634] DMAR:parse DMAR table failure.
[14315324.887859] system 00:01: ioport range 0x1000-0x107f has been res=
erved
[14315324.894742] system 00:01: ioport range 0x1080-0x10ff has been res=
erved
[14315324.901629] system 00:01: ioport range 0x1400-0x147f has been res=
erved
[14315324.908515] system 00:01: ioport range 0x1480-0x14ff has been res=
erved
[14315324.915403] system 00:01: ioport range 0x1800-0x187f has been res=
erved
[14315324.922290] system 00:01: ioport range 0x1880-0x18ff has been res=
erved
[14315324.929184] system 00:02: ioport range 0x4d0-0x4d1 has been reser=
ved
[14315324.935901] system 00:02: ioport range 0x800-0x87f has been reser=
ved
[14315324.942615] system 00:02: ioport range 0x290-0x297 has been reser=
ved
[14315324.949339] system 00:0b: iomem range 0xf0000000-0xf3ffffff could=
 not be reserved
[14315324.957269] system 00:0c: iomem range 0xd2800-0xd3fff has been re=
served
[14315324.964247] system 00:0c: iomem range 0xf0000-0xf7fff could not b=
e reserved
[14315324.973201] system 00:0c: iomem range 0xf8000-0xfbfff could not b=
e reserved
[14315324.980607] system 00:0c: iomem range 0xfc000-0xfffff could not b=
e reserved
[14315324.988013] system 00:0c: iomem range 0xfefff000-0xfefff0ff could=
 not be reserved
[14315324.995938] system 00:0c: iomem range 0x7fee0000-0x7fefffff could=
 not be reserved
[14315325.003394] system 00:0c: iomem range 0xffff0000-0xffffffff could=
 not be reserved
[14315325.011319] system 00:0c: iomem range 0x0-0x9ffff could not be re=
served
[14315325.018294] system 00:0c: iomem range 0x100000-0x7fedffff could n=
ot be reserved
[14315325.026258] system 00:0c: iomem range 0xfec00000-0xfec00fff could=
 not be reserved
[14315325.034024] system 00:0c: iomem range 0xfee00000-0xfeefffff could=
 not be reserved
[14315325.041951] system 00:0c: iomem range 0xfefff000-0xfeffffff could=
 not be reserved
[14315325.049901] system 00:0c: iomem range 0xfff80000-0xfff80fff could=
 not be reserved
[14315325.057826] system 00:0c: iomem range 0xfff90000-0xfffbffff could=
 not be reserved
[14315325.065778] system 00:0c: iomem range 0xfffed000-0xfffeffff could=
 not be reserved
[14315325.074055] PCI: Bridge: 0000:00:06.0
[14315325.078091]   IO window: 9000-9fff
[14315325.081862]   MEM window: 0xfde00000-0xfdefffff
[14315325.086758]   PREFETCH window: disabled.
[14315325.091051] PCI: Bridge: 0000:00:0a.0
[14315325.095083]   IO window: 8000-8fff
[14315325.099738]   MEM window: 0xfdd00000-0xfddfffff
[14315325.103515]   PREFETCH window: 0x00000000e8000000-0x00000000effff=
fff
[14315325.110231] PCI: Bridge: 0000:00:0b.0
[14315325.114261]   IO window: disabled.
[14315325.118026]   MEM window: disabled.
[14315325.122954]   PREFETCH window: disabled.
[14315325.126820] PCI: Bridge: 0000:00:0c.0
[14315325.130852]   IO window: disabled.
[14315325.134625]   MEM window: disabled.
[14315325.138484]   PREFETCH window: disabled.
[14315325.142801] PCI: Bridge: 0000:00:0d.0
[14315325.146833]   IO window: disabled.
[14315325.150606]   MEM window: disabled.
[14315325.154464]   PREFETCH window: disabled.
[14315325.158758] PCI: Bridge: 0000:00:0e.0
[14315325.163082]   IO window: 6000-7fff
[14315325.166847]   MEM window: 0xfdc00000-0xfdcfffff
[14315325.170890]   PREFETCH window: disabled.
[14315325.175795] PCI: Bridge: 0000:00:0f.0
[14315325.179825]   IO window: disabled.
[14315325.183589]   MEM window: disabled.
[14315325.187448]   PREFETCH window: disabled.
[14315325.191814] NET: Registered protocol family 2
[14315325.229000] IP route cache hash table entries: 65536 (order: 7, 5=
24288 bytes)
[14315325.237127] TCP established hash table entries: 262144 (order: 10=
, 4194304 bytes)
[14315325.246670] TCP bind hash table entries: 65536 (order: 7, 524288 =
bytes)
[14315325.259891] TCP: Hash tables configured (established 262144 bind =
65536)
[14315325.266866] TCP reno registered
[14315325.278699] NET: Registered protocol family 1
[14315325.284354] Installing knfsd (copyright (C) 1996 okir@monad.swb.d=
e).
[14315325.291285] JFFS2 version 2.2. (NAND) =C3=82=C2=A9 2001-2006 Red =
Hat, Inc.
[14315325.297709] fuse init (API version 7.9)
[14315325.302556] SGI XFS with security attributes, large block/inode n=
umbers, no debug enabled
[14315325.310220] msgmni has been set to 4016 for ipc namespace fffffff=
f807eda90
[14315325.317538] Block layer SCSI generic (bsg) driver version 0.4 loa=
ded (major 254)
[14315325.326187] io scheduler noop registered
[14315325.330478] io scheduler anticipatory registered
[14315325.335460] io scheduler deadline registered
[14315325.340090] io scheduler cfq registered (default)
[14315325.357122] pci 0000:00:05.0: Enabling HT MSI Mapping
[14315325.362552] pci 0000:00:05.1: Enabling HT MSI Mapping
[14315325.367669] pci 0000:00:05.2: Enabling HT MSI Mapping
[14315325.373101] pci 0000:00:06.0: Enabling HT MSI Mapping
[14315325.378539] pci 0000:00:08.0: Enabling HT MSI Mapping
[14315325.383966] pci 0000:00:09.0: Enabling HT MSI Mapping
[14315325.389406] pci 0000:00:0a.0: Enabling HT MSI Mapping
[14315325.394839] pci 0000:00:0b.0: Enabling HT MSI Mapping
[14315325.400264] pci 0000:00:0c.0: Enabling HT MSI Mapping
[14315325.405707] pci 0000:00:0d.0: Enabling HT MSI Mapping
[14315325.411131] pci 0000:00:0e.0: Enabling HT MSI Mapping
[14315325.416574] pci 0000:00:0f.0: Enabling HT MSI Mapping
[14315325.422109] assign_interrupt_mode Found MSI capability
[14315325.427502] assign_interrupt_mode Found MSI capability
[14315325.433124] assign_interrupt_mode Found MSI capability
[14315325.438703] assign_interrupt_mode Found MSI capability
[14315325.444267] assign_interrupt_mode Found MSI capability
[14315325.449850] assign_interrupt_mode Found MSI capability
[14315325.455627] input: Power Button (FF) as /class/input/input0
[14315325.461561] ACPI: Power Button (FF) [PWRF]
[14315325.466090] input: Power Button (CM) as /class/input/input1
[14315325.472028] ACPI: Power Button (CM) [PWRB]
[14315325.476593] ACPI: PNP0C0B:00 is registered as cooling_device0
[14315325.482698] ACPI: Fan [FAN] (on)
[14315325.486407] ACPI: ACPI0007:00 is registered as cooling_device1
[14315325.493401] ACPI: LNXTHERM:01 is registered as thermal_zone0
[14315325.499668] ACPI: Thermal Zone [THRM] (40 C)
[14315325.525086] Real Time Clock Driver v1.12ac
[14315325.529550] Linux agpgart interface v0.103
[14315325.532400] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, =
IRQ sharing disabled
[14315325.542502] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550=
A
[14315325.549175] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.555688] loop: module loaded
[14315325.559205] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[14315325.564189] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[14315325.570684] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[14315325.577136] e100: Copyright(c) 1999-2006 Intel Corporation
[14315325.583034] tun: Universal TUN/TAP device driver, 1.6
[14315325.589212] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com=
>
[14315325.595842] Driver 'sd' needs updating - please use bus_type meth=
ods
[14315325.602577] Driver 'sr' needs updating - please use bus_type meth=
ods
[14315325.609797] ACPI: PCI Interrupt Link [APC7] enabled at IRQ 16
[14315325.615916] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315326.627016] ahci 0000:06:00.0: AHCI 0001.0000 32 slots 2 ports 3 =
Gbps 0x3 impl SATA mode
[14315326.635540] ahci 0000:06:00.0: flags: 64bit ncq pm led clo pmp pi=
o slum part=20
[14315326.643310] scsi0 : ahci
[14315326.646309] scsi1 : ahci
[14315326.649297] ata1: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe100 irq 16
[14315326.658925] ata2: SATA max UDMA/133 abar m8192@0xfdcfe000 port 0x=
fdcfe180 irq 16
[14315326.984915] ata1: SATA link down (SStatus 0 SControl 300)
[14315327.308610] ata2: SATA link down (SStatus 0 SControl 300)
[14315327.313817] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
[14315327.319931] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315327.329946] sata_nv 0000:00:05.0: Using SWNCQ mode
[14315327.335280] scsi2 : sata_nv
[14315327.338509] scsi3 : sata_nv
[14315327.341858] ata3: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd=
c00 irq 23
[14315327.349259] ata4: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd=
c08 irq 23
[14315327.827605] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315327.860001] ata3.00: ATA-8: SAMSUNG HD501LJ, CR100-12, max UDMA7
[14315327.863336] ata3.00: 976773168 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
[14315327.879784] ata3.00: configured for UDMA/133
[14315328.201320] ata4: SATA link down (SStatus 0 SControl 300)
[14315328.229435] isa bounce pool size: 16 pages
[14315328.233401] scsi 2:0:0:0: Direct-Access     ATA      SAMSUNG HD50=
1LJ  CR10 PQ: 0 ANSI: 5
[14315328.241268] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.249780] sd 2:0:0:0: [sda] Write Protect is off
[14315328.254148] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.263670] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315328.271251] sd 2:0:0:0: [sda] Write Protect is off
[14315328.276461] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315328.285946]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[14315328.364934] sd 2:0:0:0: [sda] Attached SCSI disk
[14315328.371268] sd 2:0:0:0: Attached scsi generic sg0 type 0
[14315328.378335] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
[14315328.384458] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315328.393681] sata_nv 0000:00:05.1: Using SWNCQ mode
[14315328.399650] scsi4 : sata_nv
[14315328.402877] scsi5 : sata_nv
[14315328.406229] ata5: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc=
800 irq 22
[14315328.413636] ata6: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc=
808 irq 22
[14315328.739046] ata5: SATA link down (SStatus 0 SControl 300)
[14315329.072240] ata6: SATA link down (SStatus 0 SControl 300)
[14315329.099800] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 21
[14315329.103345] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315329.114072] sata_nv 0000:00:05.2: Using SWNCQ mode
[14315329.119397] scsi6 : sata_nv
[14315329.122626] scsi7 : sata_nv
[14315329.125977] ata7: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0=
xb400 irq 21
[14315329.133550] ata8: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0=
xb408 irq 21
[14315329.458987] ata7: SATA link down (SStatus 0 SControl 300)
[14315329.945324] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315329.959980] ata8.00: ATAPI: TSSTcorp CDDVDW SH-S203B, SB00, max U=
DMA/100
[14315329.979585] ata8.00: configured for UDMA/100
[14315329.995934] scsi 7:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S2=
03B  SB00 PQ: 0 ANSI: 5
[14315330.006668] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa=
/form2 cdda tray
[14315330.014593] Uniform CD-ROM driver Revision: 3.20
[14315330.019739] sr 7:0:0:0: Attached scsi generic sg1 type 5
[14315330.026194] block2mtd: version $Revision: 1.30 $
[14315330.032398] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 20
[14315330.038520] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315330.047753] ehci_hcd 0000:00:02.1: EHCI Host Controller
[14315330.053414] ehci_hcd 0000:00:02.1: new USB bus registered, assign=
ed bus number 1
[14315330.061282] ehci_hcd 0000:00:02.1: debug port 1
[14315330.066441] ehci_hcd 0000:00:02.1: irq 20, io mem 0xfe02e000
[14315330.081716] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, dr=
iver 10 Dec 2004
[14315330.095685] usb usb1: configuration #1 chosen from 1 choice
[14315330.100569] hub 1-0:1.0: USB hub found
[14315330.106610] hub 1-0:1.0: 10 ports detected
[14315330.212212] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[14315330.216670] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315330.227524] ohci_hcd 0000:00:02.0: OHCI Host Controller
[14315330.233169] ohci_hcd 0000:00:02.0: new USB bus registered, assign=
ed bus number 2
[14315330.241011] ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
[14315330.300001] usb usb2: configuration #1 chosen from 1 choice
[14315330.305965] hub 2-0:1.0: USB hub found
[14315330.310084] hub 2-0:1.0: 10 ports detected
[14315330.389881] hub 1-0:1.0: unable to enumerate USB device on port 1
[14315330.419887] USB Universal Host Controller Interface driver v3.0
[14315330.566155] hub 1-0:1.0: unable to enumerate USB device on port 3
[14315330.742876] hub 1-0:1.0: unable to enumerate USB device on port 4
[14315330.746711] usbcore: registered new interface driver usblp
[14315330.753196] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq =
1
[14315330.759730] PNP: PS/2 appears to have AUX port disabled, if this =
is incorrect please boot with i8042.nopnp
[14315330.769902] serio: i8042 KBD port at 0x60,0x64 irq 1
[14315330.775782] mice: PS/2 mouse device common for all mice
[14315330.804591] i2c /dev entries driver
[14315330.808566] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[14315330.814814] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[14315330.820315] it87: Found IT8716F chip at 0x290, revision 0
[14315330.826520] it87: in3 is VCC (+5V)
[14315330.830294] it87: in7 is VCCH (+5V Stand-By)
[14315330.846668] input: AT Translated Set 2 keyboard as /class/input/i=
nput2
[14315330.879234] md: raid1 personality registered for level 1
[14315330.883403] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initi=
alised: dm-devel@redhat.com
[14315330.892669] Bluetooth: HCI USB driver ver 2.9
[14315330.986210] usb 2-1: new low speed USB device using ohci_hcd and =
address 2
[14315331.133334] usb 2-1: configuration #1 chosen from 1 choice
[14315331.392186] usb 2-3: new low speed USB device using ohci_hcd and =
address 3
[14315331.550000] usb 2-3: configuration #1 chosen from 1 choice
[14315331.818549] usb 2-4: new full speed USB device using ohci_hcd and=
 address 4
[14315331.950004] usb 2-4: device descriptor read/64, error -62
[14315332.183338] usb 2-4: device descriptor read/64, error -62
[14315332.412141] usb 2-4: new full speed USB device using ohci_hcd and=
 address 5
[14315332.543337] usb 2-4: device descriptor read/64, error -62
[14315332.776671] usb 2-4: device descriptor read/64, error -62
[14315333.005475] usb 2-4: new full speed USB device using ohci_hcd and=
 address 6
[14315333.417401] usb 2-4: device not accepting address 6, error -62
[14315333.542700] usb 2-4: new full speed USB device using ohci_hcd and=
 address 7
[14315333.954657] usb 2-4: device not accepting address 7, error -62
[14315333.960004] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315333.966491] usbcore: registered new interface driver hci_usb
[14315333.972664] Bluetooth: HCI UART driver ver 2.2
[14315333.978731] Bluetooth: HCI H4 protocol initialized
[14315333.983548] Bluetooth: HCI BCSP protocol initialized
[14315333.988871] cpuidle: using governor ladder
[14315333.993332] cpuidle: using governor menu
[14315334.003334] input: Microsoft Microsoft 3-Button Mouse with Intell=
iEye(TM) as /class/input/input3
[14315334.034620] input: USB HID v1.10 Mouse [Microsoft Microsoft 3-But=
ton Mouse with IntelliEye(TM)] on usb-0000:00:02.0-1
[14315334.055900] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input4
[14315334.086496] input: USB HID v1.11 Keyboard [Microsoft Natural=C2=AE=
 Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.108027] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input5
[14315334.141346] input: USB HID v1.11 Device [Microsoft Natural=C2=AE =
Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315334.151542] usbcore: registered new interface driver usbhid
[14315334.156882] usbhid: v2.6:USB HID core driver
[14315334.162895] Advanced Linux Sound Architecture Driver Version 1.0.=
16.
[14315334.169762] ALSA device list:
[14315334.173099]   No soundcards found.
[14315334.174923] GACT probability on
[14315334.178434] Mirror/redirect action on
[14315334.182643] u32 classifier
[14315334.185796]     Performance counters on
[14315334.189994]     input device check on=20
[14315334.196591]     Actions configured=20
[14315334.200749] IPv4 over IPv4 tunneling driver
[14315334.204809] ip_tables: (C) 2000-2006 Netfilter Core Team
[14315334.210509] TCP bic registered
[14315334.213927] TCP cubic registered
[14315334.217517] TCP westwood registered
[14315334.221366] TCP htcp registered
[14315334.224871] TCP vegas registered
[14315334.229768] TCP yeah registered
[14315334.233272] Initializing XFRM netlink socket
[14315334.236909] NET: Registered protocol family 10
[14315334.243335] IPv6 over IPv4 tunneling driver
[14315334.247680] NET: Registered protocol family 17
[14315334.252488] NET: Registered protocol family 15
[14315334.257338] Bridge firewalling registered
[14315334.262514] Bluetooth: L2CAP ver 2.9
[14315334.266454] Bluetooth: L2CAP socket layer initialized
[14315334.270883] Bluetooth: SCO (Voice Link) ver 0.5
[14315334.276299] Bluetooth: SCO socket layer initialized
[14315334.281213] Bluetooth: RFCOMM socket layer initialized
[14315334.286720] Bluetooth: RFCOMM TTY layer initialized
[14315334.291961] Bluetooth: RFCOMM ver 1.8
[14315334.295984] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[14315334.301651] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[14315334.307017] RPC: Registered udp transport module.
[14315334.313210] RPC: Registered tcp transport module.
[14315334.318383] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelat=
ech.com>
[14315334.325524] All bugs added by David S. Miller <davem@redhat.com>
[14315334.331898] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3800=
+ processors (1 cpu cores) (version 2.20.00)
[14315334.342280] powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
[14315334.348297] powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
[14315334.353416] powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
[14315334.359351] powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
[14315334.365288] powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
[14315334.378066] Freezing user space processes ... (elapsed 0.00 secon=
ds) done.
[14315334.385893] Freezing remaining freezable tasks ... (elapsed 0.00 =
seconds) done.
[14315334.401111] PM: Loading image data pages (42260 pages) ...     =08=
=08=08=08  0%=08=08=08=08  1%=08=08=08=08  2%=08=08=08=08  3%=08=08=08=08=
  4%=08=08=08=08  5%=08=08=08=08  6%=08=08=08=08  7%=08=08=08=08  8%=08=
=08=08=08  9%=08=08=08=08 10%=08=08=08=08 11%=08=08=08=08 12%=08=08=08=08=
 13%=08=08=08=08 14%=08=08=08=08 15%=08=08=08=08 16%=08=08=08=08 17%=08=
=08=08=08 18%=08=08=08=08 19%=08=08=08=08 20%=08=08=08=08 21%=08=08=08=08=
 22%=08=08=08=08 23%=08=08=08=08 24%=08=08=08=08 25%=08=08=08=08 26%=08=
=08=08=08 27%=08=08=08=08 28%=08=08=08=08 29%=08=08=08=08 30%=08=08=08=08=
 31%=08=08=08=08 32%=08=08=08=08 33%=08=08=08=08 34%=08=08=08=08 35%Mar=
king TSC unstable due to cpufreq changes
[14315335.302783] =08=08=08=08 36%=08=08=08=08 37%=08=08=08=08 38%=08=08=
=08=08 39%=08=08=08=08 40%=08=08=08=08 41%=08=08=08=08 42%=08=08=08=08 =
43%=08=08=08=08 44%=08=08=08=08 45%=08=08=08=08 46%=08=08=08=08 47%=08=08=
=08=08 48%=08=08=08=08 49%=08=08=08=08 50%=08=08=08=08 51%=08=08=08=08 =
52%=08=08=08=08 53%=08=08=08=08 54%<4>Clocksource tsc unstable (delta =3D=
 -253700290 ns)
[14315335.743340] =08=08=08=08 55%=08=08=08=08 56%=08=08=08=08 57%=08=08=
=08=08 58%=08=08=08=08 59%=08=08=08=08 60%=08=08=08=08 61%=08=08=08=08 =
62%=08=08=08=08 63%=08=08=08=08 64%=08=08=08=08 65%=08=08=08=08 66%=08=08=
=08=08 67%=08=08=08=08 68%=08=08=08=08 69%=08=08=08=08 70%=08=08=08=08 =
71%=08=08=08=08 72%=08=08=08=08 73%=08=08=08=08 74%=08=08=08=08 75%=08=08=
=08=08 76%=08=08=08=08 77%=08=08=08=08 78%=08=08=08=08 79%=08=08=08=08 =
80%=08=08=08=08 81%=08=08=08=08 82%=08=08=08=08 83%=08=08=08=08 84%=08=08=
=08=08 85%=08=08=08=08 86%=08=08=08=08 87%=08=08=08=08 88%=08=08=08=08 =
89%=08=08=08=08 90%=08=08=08=08 91%=08=08=08=08 92%=08=08=08=08 93%=08=08=
=08=08 94%=08=08=08=08 95%=08=08=08=08 96%=08=08=08=08 97%=08=08=08=08 =
98%=08=08=08=08 99%=08=08=08=08100%=08=08=08=08done
[14315336.766775] PM: Read 169040 kbytes in 2.35 seconds (71.93 MB/s)
[14315336.773008] Suspending console(s)
[14315372.380623] sd 2:0:0:0: [sda] Synchronizing SCSI cache
[14315372.400001] ACPI handle has no context!
[14315372.400001] serial 00:08: disabled
[14315372.426722] ACPI: PCI interrupt for device 0000:06:00.0 disabled
[14315372.433749] ACPI: PCI interrupt for device 0000:01:08.0 disabled
[14315372.433760] ACPI handle has no context!
[14315372.473374] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14315372.473400] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14315372.473426] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14315372.473462] ACPI: PCI interrupt for device 0000:00:02.1 disabled
[14315372.473472] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14315372.473607] ACPI: Preparing to enter system sleep state S4
[14315372.474088] Extended CMOS year: 2000
[14315372.474134] PM: Creating hibernation image:=20
[14315372.476670] PM: Need to copy 42177 pages
[14315372.476670] PM: Normal pages needed: 42177 + 1024 + 38, available=
 pages: 481725
[14315372.476670] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70=
10600070106
[14315372.476670] svm_cpu_init: svm_data is NULL on 0
[14315372.476670] Extended CMOS year: 2000
[14315372.486394] ACPI: Unable to turn cooling device [ffff81007f842890=
] 'off'
[14315372.486444] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315372.486449] PCI: Setting latency timer of device 0000:00:02.0 to =
64
[14315372.537518] usb usb2: root hub lost power or was reset
[14315372.537524] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315372.537528] PCI: Setting latency timer of device 0000:00:02.1 to =
64
[14315372.537537] usb usb1: root hub lost power or was reset
[14315372.537541] ehci_hcd 0000:00:02.1: debug port 1
[14315372.537543] PCI: cache line size of 64 is not supported by device=
 0000:00:02.1
[14315372.537550] PM: Writing back config space on device 0000:00:04.0 =
at offset b (was 82391043, writing 8239f043)
[14315372.537558] PCI: Setting latency timer of device 0000:00:04.0 to =
64
[14315372.537571] PM: Writing back config space on device 0000:00:05.0 =
at offset 1 (was b00003, writing b00007)
[14315372.537578] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315372.537581] PCI: Setting latency timer of device 0000:00:05.0 to =
64
[14315372.537593] PM: Writing back config space on device 0000:00:05.1 =
at offset 1 (was b00003, writing b00007)
[14315372.537599] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315372.537602] PCI: Setting latency timer of device 0000:00:05.1 to =
64
[14315372.537614] PM: Writing back config space on device 0000:00:05.2 =
at offset 1 (was b00003, writing b00007)
[14315372.537620] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315372.537623] PCI: Setting latency timer of device 0000:00:05.2 to =
64
[14315372.537636] PCI: Setting latency timer of device 0000:00:06.0 to =
64
[14315372.540713] ata10: port disabled. ignoring.
[14315372.550227] eth0: no link during initialization.
[14315372.563683] PCI: Setting latency timer of device 0000:00:0a.0 to =
64
[14315372.563696] PCI: Setting latency timer of device 0000:00:0b.0 to =
64
[14315372.563707] PCI: Setting latency timer of device 0000:00:0c.0 to =
64
[14315372.563719] PCI: Setting latency timer of device 0000:00:0d.0 to =
64
[14315372.563730] PCI: Setting latency timer of device 0000:00:0e.0 to =
64
[14315372.563742] PCI: Setting latency timer of device 0000:00:0f.0 to =
64
[14315372.564039] br0: port 2(eth1) entering learning state
[14315372.576716] PM: Writing back config space on device 0000:01:08.0 =
at offset 1 (was 2900005, writing 2900001)
[14315372.576726] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315372.584286] PM: Writing back config space on device 0000:06:00.0 =
at offset 1 (was 100003, writing 100007)
[14315372.584297] ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315372.584301] PCI: Setting latency timer of device 0000:06:00.0 to =
64
[14315372.587247] serial 00:08: activated
[14315372.587278] sd 2:0:0:0: [sda] Starting disk
[14315372.723691] ata9.01: ACPI cmd ef/03:44:00:00:00:b0 filtered out
[14315372.723693] ata9.01: ACPI cmd ef/03:0c:00:00:00:b0 filtered out
[14315372.723713] ata9: nv_mode_filter: 0x1f01f&0x1f01f->0x1f01f, BIOS=3D=
0x1f000 (0xc50000) ACPI=3D0x1f01f (600:30:0x1c)
[14315372.736770] ata9.01: configured for UDMA/66
[14315372.856680] ata5: SATA link down (SStatus 0 SControl 300)
[14315372.867205] ata4: SATA link down (SStatus 0 SControl 300)
[14315372.877729] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315372.877786] ata6: SATA link down (SStatus 0 SControl 300)
[14315372.888391] ata8: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315372.888423] ata7: SATA link down (SStatus 0 SControl 300)
[14315372.898997] ata1: SATA link down (SStatus 0 SControl 300)
[14315372.899097] ata8.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315372.899162] ata3.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315372.899165] ata3.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[14315372.906679] ata2: SATA link down (SStatus 0 SControl 300)
[14315372.910068] ata8.00: configured for UDMA/100
[14315372.910168] ata3.00: configured for UDMA/133
[14315372.910224] sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315372.910238] sd 2:0:0:0: [sda] Write Protect is off
[14315372.910240] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[14315372.910261] sd 2:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315373.563339] br0: topology change detected, propagating
[14315373.563342] br0: port 2(eth1) entering forwarding state
[14315373.650009] usb 2-1: reset low speed USB device using ohci_hcd an=
d address 2
[14315374.220008] usb 2-3: reset low speed USB device using ohci_hcd an=
d address 3
[14315375.075625] PM: Image restored successfully.
[14315375.127302] Restarting tasks ... done.
[14315375.137874] PM: Basic memory bitmaps freed
[14315375.496675] usb 2-4: device descriptor read/64, error -62
[14315375.730007] usb 2-4: device descriptor read/64, error -62
[14315376.083341] usb 2-4: device descriptor read/64, error -62
[14315376.316674] usb 2-4: device descriptor read/64, error -62
[14315376.950007] usb 2-4: device not accepting address 10, error -62
[14315377.480010] usb 2-4: device not accepting address 11, error -62
[14315377.489893] hub 2-0:1.0: unable to enumerate USB device on port 4


--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
