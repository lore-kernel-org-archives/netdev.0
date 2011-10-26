From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>
Subject: Re: tg3: BMC stops responding in 3.0
Date: Wed, 26 Oct 2011 17:49:28 +0200
Message-ID: <201110261749.28799.a.miskiewicz@gmail.com>
References: <201109232145.50449.a.miskiewicz@gmail.com> <20110930235353.GB16743@mcarlson.broadcom.com> <201110010737.59434.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38372 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933052Ab1JZPte convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 11:49:34 -0400
Received: by faan17 with SMTP id n17so1677207faa.19
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2011 08:49:32 -0700 (PDT)
In-Reply-To: <201110010737.59434.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 01 of October 2011, Arkadiusz Mi=C5=9Bkiewicz wrote:
> On Saturday 01 of October 2011, Matt Carlson wrote:
> > On Fri, Sep 30, 2011 at 01:06:25AM -0700, Arkadiusz Mi??kiewicz wro=
te:
> > > On Friday 30 of September 2011, Matt Carlson wrote:
> > > > On Mon, Sep 26, 2011 at 11:31:33AM -0700, Arkadiusz Mi??kiewicz=
 wrote:
> > > > > On Monday 26 of September 2011, Matt Carlson wrote:
> > > > > > On Fri, Sep 23, 2011 at 12:45:50PM -0700, Arkadiusz Mi??kie=
wicz
>=20
> wrote:
> > > > > > > Hi,
> > > > > > >=20
> > > > > > > I was using 2.6.38.8 and recently tried to switch to 3.0.=
4 on
> > > > > > > Tyan S2891 platform.
> > > > > > >=20
> > > > > > > This platform uses tg3:
> > > > > > > tg3 0000:0a:09.1: eth1: Tigon3 [partno(BCM95704) rev 2003=
]
> > > > > > > (PCIX:133MHz:64- bit) MAC address 00:e0:81:33:5e:af
> > > > > > > tg3 0000:0a:09.1: eth1: attached PHY is 5704 (10/100/1000=
Base-T
> > > > > > > Ethernet) (WireSpeed[1], EEE[0])
> > > > > > > tg3 0000:0a:09.1: eth1: RXcsums[1] LinkChgREG[0] MIirq[0]
> > > > > > > ASF[0] TSOcap[1] tg3 0000:0a:09.1: eth1: dma_rwctrl[769f4=
000]
> > > > > > > dma_mask[64-bit]
> > > > > > >=20
> > > > > > > With 2.6.38.8 everything was working fine. With 3.0.4 the=
re is
> > > > > > > a problem. As soon as tg3 module is loaded or eth0 config=
ured
> > > > > > > (can't tell which one since the machine is 400km away fro=
m me
> > > > > > > and I have no way to play with it other than ipmi or ssh)=
 BMC
> > > > > > > stops responding (so all ipmitool commands over LAN stop
> > > > > > > working). Normal tg3 activity is not affected - I can ssh=
-in
> > > > > > > without a problem etc but ipmi over lan doesn't work.
> > > > > > >=20
> > > > > > > From ssh console "ipmitool lan print" works, shows data b=
ut for
> > > > > > > example after "ipmitool mc reset cold" it doesn't recover=
 -
> > > > > > > ipmitool returns "Invalid channel: 255". I have to reboot=
 to
> > > > > > > 2.6.38.8 and then issue "ipmitool mc reset cold" to recov=
er.
> > > > > > >=20
> > > > > > > Any idea which tg3 change could break this? Can't bisect =
this
> > > > > > > due remote access only.
> > > > > > >=20
> > > > > > > I was hoping that maybe
> > > > > > > 9e975cc291d80d5e4562d6bed15ec171e896d69b "tg3: Fix io fai=
lures
> > > > > > > after chip reset" will fix things for me but no - this do=
esn't
> > > > > > > help.
> > > > > >=20
> > > > > > What version of the tg3 driver are you working with?
> > > > >=20
> > > > > The one in 3.0.4 kernel. I think it's 3.119 (at least modinfo=
 says
> > > > > so).
> > > >=20
> > > > Unfortunately there were a lot of changes between 3.117 and 3.1=
19(+).
> > > > Is there any way you can narrow down the gap?
> > >=20
> > > The machines are 400km away from me and it's hard to debug that w=
ay
> > > then ipmi/network conectivity is in stake :-/ I could try some fo=
rm of
> > > bisecting but need to know if all git versions between 3.117 and =
3.119
> > > were known to be safe and working? I don't want to loose any
> > > conectivity to this machine.
> > >=20
> > > I was going to try 2.6.39 but it looks like it also uses 3.117 dr=
iver.
> >=20
> > O.K.  Can you give me the details of your machine?  Maybe we have t=
he
> > exact machine or a machine similar enough to reproduce the problem =
with.

Did you have any chance to find and test on a similar system?

>=20
> It's 1U server, with Tyan S2891 mainboard and some chenbro chassis. i=
pmi
> and eth0 share physical rj45 port in the server.
>=20
> lspci & dmidecode below:
>=20
> 00:00.0 Memory controller: nVidia Corporation CK804 Memory Controller=
 (rev
> a3) Subsystem: Tyan Computer Thunder K8SRE Mainboard
> 	Flags: bus master, 66MHz, fast devsel, latency 0
> 	Capabilities: [44] HyperTransport: Slave or Primary Interface
> 	Capabilities: [e0] HyperTransport: MSI Mapping Enable+ Fixed-
>=20
> 00:01.0 ISA bridge: nVidia Corporation CK804 ISA Bridge (rev a3)
> 	Subsystem: Tyan Computer Device 2891
> 	Flags: bus master, 66MHz, fast devsel, latency 0
> 	I/O ports at 8c00 [size=3D1K]
>=20
> 00:01.1 SMBus: nVidia Corporation CK804 SMBus (rev a2)
> 	Subsystem: Tyan Computer Device 2891
> 	Flags: 66MHz, fast devsel
> 	I/O ports at 1000 [size=3D32]
> 	I/O ports at 5000 [size=3D64]
> 	I/O ports at 5040 [size=3D64]
> 	Capabilities: [44] Power Management version 2
>=20
> 00:02.0 USB Controller: nVidia Corporation CK804 USB Controller (rev =
a2)
> (prog-if 10 [OHCI])
> 	Subsystem: Tyan Computer Device 2891
> 	Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 10
> 	Memory at dd000000 (32-bit, non-prefetchable) [size=3D4K]
> 	Capabilities: [44] Power Management version 2
>=20
> 00:02.1 USB Controller: nVidia Corporation CK804 USB Controller (rev =
a3)
> (prog-if 20 [EHCI])
> 	Subsystem: Tyan Computer Device 2891
> 	Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 7
> 	Memory at dd001000 (32-bit, non-prefetchable) [size=3D256]
> 	Capabilities: [44] Debug port: BAR=3D1 offset=3D0098
> 	Capabilities: [80] Power Management version 2
>=20
> 00:06.0 IDE interface: nVidia Corporation CK804 IDE (rev f2) (prog-if=
 8a
> [Master SecP PriP])
> 	Subsystem: Tyan Computer Device 2891
> 	Flags: bus master, 66MHz, fast devsel, latency 0
> 	[virtual] Memory at 000001f0 (32-bit, non-prefetchable) [size=3D8]
> 	[virtual] Memory at 000003f0 (type 3, non-prefetchable) [size=3D1]
> 	[virtual] Memory at 00000170 (32-bit, non-prefetchable) [size=3D8]
> 	[virtual] Memory at 00000370 (type 3, non-prefetchable) [size=3D1]
> 	I/O ports at 1400 [size=3D16]
> 	Capabilities: [44] Power Management version 2
>=20
> 00:07.0 IDE interface: nVidia Corporation CK804 Serial ATA Controller=
 (rev
> f3) (prog-if 85 [Master SecO PriO])
> 	Subsystem: Tyan Computer Device 2891
> 	Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 11
> 	I/O ports at 1440 [size=3D8]
> 	I/O ports at 1434 [size=3D4]
> 	I/O ports at 1438 [size=3D8]
> 	I/O ports at 1430 [size=3D4]
> 	I/O ports at 1410 [size=3D16]
> 	Memory at dd002000 (32-bit, non-prefetchable) [size=3D4K]
> 	Capabilities: [44] Power Management version 2
>=20
> 00:08.0 IDE interface: nVidia Corporation CK804 Serial ATA Controller=
 (rev
> f3) (prog-if 85 [Master SecO PriO])
> 	Subsystem: Tyan Computer Device 2891
> 	Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 10
> 	I/O ports at 1458 [size=3D8]
> 	I/O ports at 144c [size=3D4]
> 	I/O ports at 1450 [size=3D8]
> 	I/O ports at 1448 [size=3D4]
> 	I/O ports at 1420 [size=3D16]
> 	Memory at dd003000 (32-bit, non-prefetchable) [size=3D4K]
> 	Capabilities: [44] Power Management version 2
>=20
> 00:09.0 PCI bridge: nVidia Corporation CK804 PCI Bridge (rev a2) (pro=
g-if
> 00 [Normal decode])
> 	Flags: bus master, 66MHz, fast devsel, latency 0
> 	Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=3D6=
4
> 	I/O behind bridge: 00002000-00002fff
> 	Memory behind bridge: dd100000-deffffff
> 	Prefetchable memory behind bridge: d0000000-d00fffff
>=20
> 00:0e.0 PCI bridge: nVidia Corporation CK804 PCIE Bridge (rev a3) (pr=
og-if
> 00 [Normal decode])
> 	Flags: bus master, fast devsel, latency 0
> 	Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latency=3D0
> 	Capabilities: [40] Power Management version 2
> 	Capabilities: [48] MSI: Enable- Count=3D1/2 Maskable- 64bit+
> 	Capabilities: [58] HyperTransport: MSI Mapping Enable- Fixed-
> 	Capabilities: [80] Express Root Port (Slot+), MSI 00
> 	Kernel driver in use: pcieport
>=20
> 00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Optero=
n]
> HyperTransport Technology Configuration
> 	Flags: fast devsel
> 	Capabilities: [80] HyperTransport: Host or Secondary Interface
> 	Capabilities: [a0] HyperTransport: Host or Secondary Interface
> 	Capabilities: [c0] HyperTransport: Host or Secondary Interface
>=20
> 00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Optero=
n]
> Address Map
> 	Flags: fast devsel
>=20
> 00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Optero=
n]
> DRAM Controller
> 	Flags: fast devsel
>=20
> 00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Optero=
n]
> Miscellaneous Control
> 	Flags: fast devsel
>=20
> 00:19.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Optero=
n]
> HyperTransport Technology Configuration
> 	Flags: fast devsel
> 	Capabilities: [80] HyperTransport: Host or Secondary Interface
> 	Capabilities: [a0] HyperTransport: Host or Secondary Interface
> 	Capabilities: [c0] HyperTransport: Host or Secondary Interface
>=20
> 00:19.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Optero=
n]
> Address Map
> 	Flags: fast devsel
>=20
> 00:19.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Optero=
n]
> DRAM Controller
> 	Flags: fast devsel
>=20
> 00:19.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Optero=
n]
> Miscellaneous Control
> 	Flags: fast devsel
>=20
> 01:07.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev =
27)
> (prog-if 00 [VGA controller])
> 	Subsystem: ATI Technologies Inc Rage XL
> 	Flags: bus master, stepping, medium devsel, latency 66, IRQ 11
> 	Memory at de000000 (32-bit, non-prefetchable) [size=3D16M]
> 	I/O ports at 2000 [size=3D256]
> 	Memory at dd100000 (32-bit, non-prefetchable) [size=3D4K]
> 	[virtual] Expansion ROM at d0000000 [disabled] [size=3D128K]
> 	Capabilities: [5c] Power Management version 2
>=20
> 08:0a.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8131 PCI-X Bridg=
e (rev
> 12) (prog-if 00 [Normal decode])
> 	Flags: bus master, 66MHz, medium devsel, latency 64
> 	Bus: primary=3D08, secondary=3D09, subordinate=3D09, sec-latency=3D6=
4
> 	I/O behind bridge: 00003000-00003fff
> 	Memory behind bridge: df300000-df3fffff
> 	Prefetchable memory behind bridge: 00000000df500000-00000000df5fffff
> 	Capabilities: [a0] PCI-X bridge device
> 	Capabilities: [b8] HyperTransport: Interrupt Discovery and Configura=
tion
> 	Capabilities: [c0] HyperTransport: Slave or Primary Interface
>=20
> 08:0a.1 PIC: Advanced Micro Devices [AMD] AMD-8131 PCI-X IOAPIC (rev =
01)
> (prog-if 10 [IO-APIC])
> 	Subsystem: Tyan Computer Device 2891
> 	Flags: bus master, medium devsel, latency 0
> 	Memory at df200000 (64-bit, non-prefetchable) [size=3D4K]
>=20
> 08:0b.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8131 PCI-X Bridg=
e (rev
> 12) (prog-if 00 [Normal decode])
> 	Flags: bus master, 66MHz, medium devsel, latency 64
> 	Bus: primary=3D08, secondary=3D0a, subordinate=3D0a, sec-latency=3D6=
4
> 	Memory behind bridge: df400000-df4fffff
> 	Capabilities: [a0] PCI-X bridge device
> 	Capabilities: [b8] HyperTransport: Interrupt Discovery and Configura=
tion
>=20
> 08:0b.1 PIC: Advanced Micro Devices [AMD] AMD-8131 PCI-X IOAPIC (rev =
01)
> (prog-if 10 [IO-APIC])
> 	Subsystem: Tyan Computer Device 2891
> 	Flags: bus master, medium devsel, latency 0
> 	Memory at df201000 (64-bit, non-prefetchable) [size=3D4K]
>=20
> 09:08.0 Fibre Channel: QLogic Corp. ISP2312-based 2Gb Fibre Channel t=
o
> PCI-X HBA (rev 02)
> 	Subsystem: Compaq Computer Corporation Device 0100
> 	Flags: bus master, 66MHz, medium devsel, latency 128, IRQ 24
> 	I/O ports at 3000 [size=3D256]
> 	Memory at df300000 (64-bit, non-prefetchable) [size=3D4K]
> 	[virtual] Expansion ROM at df500000 [disabled] [size=3D128K]
> 	Capabilities: [44] Power Management version 2
> 	Capabilities: [4c] PCI-X non-bridge device
> 	Capabilities: [54] MSI: Enable- Count=3D1/8 Maskable- 64bit+
> 	Capabilities: [64] CompactPCI hot-swap <?>
> 	Kernel driver in use: qla2xxx
>=20
> 0a:09.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 G=
igabit
> Ethernet (rev 03)
> 	Subsystem: Broadcom Corporation NetXtreme BCM5704 Gigabit Ethernet
> 	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 28
> 	Memory at df410000 (64-bit, non-prefetchable) [size=3D64K]
> 	Memory at df400000 (64-bit, non-prefetchable) [size=3D64K]
> 	Capabilities: [40] PCI-X non-bridge device
> 	Capabilities: [48] Power Management version 2
> 	Capabilities: [50] Vital Product Data
> 	Capabilities: [58] MSI: Enable- Count=3D1/8 Maskable- 64bit+
> 	Kernel driver in use: tg3
>=20
> 0a:09.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 G=
igabit
> Ethernet (rev 03)
> 	Subsystem: Broadcom Corporation NetXtreme BCM5704 Gigabit Ethernet
> 	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 29
> 	Memory at df430000 (64-bit, non-prefetchable) [size=3D64K]
> 	Memory at df420000 (64-bit, non-prefetchable) [size=3D64K]
> 	Capabilities: [40] PCI-X non-bridge device
> 	Capabilities: [48] Power Management version 2
> 	Capabilities: [50] Vital Product Data
> 	Capabilities: [58] MSI: Enable- Count=3D1/8 Maskable- 64bit+
> 	Kernel driver in use: tg3
>=20
>=20
>=20
> # dmidecode 2.11
> SMBIOS version fixup (2.33 -> 2.3).
> SMBIOS 2.3 present.
> 34 structures occupying 1202 bytes.
> Table at 0x7FFEF000.
>=20
> Handle 0x0000, DMI type 0, 20 bytes
> BIOS Information
> 	Vendor: Phoenix Technologies Ltd.
> 	Version: 2003Q2
> 	Release Date: 03/27/2006
> 	Address: 0xE65B0
> 	Runtime Size: 105040 bytes
> 	ROM Size: 1024 kB
> 	Characteristics:
> 		PCI is supported
> 		PNP is supported
> 		BIOS is upgradeable
> 		BIOS shadowing is allowed
> 		ESCD support is available
> 		Boot from CD is supported
> 		Selectable boot is supported
> 		EDD is supported
> 		5.25"/360 kB floppy services are supported (int 13h)
> 		5.25"/1.2 MB floppy services are supported (int 13h)
> 		3.5"/720 kB floppy services are supported (int 13h)
> 		3.5"/2.88 MB floppy services are supported (int 13h)
> 		Print screen service is supported (int 5h)
> 		8042 keyboard services are supported (int 9h)
> 		Serial services are supported (int 14h)
> 		Printer services are supported (int 17h)
> 		CGA/mono video services are supported (int 10h)
> 		ACPI is supported
> 		USB legacy is supported
>=20
> Handle 0x0001, DMI type 1, 25 bytes
> System Information
> 	Manufacturer: TYAN Computer Corp
> 	Product Name: S2891
> 	Version: REFERENCE
> 	Serial Number: 0123456789
> 	UUID: Not Settable
> 	Wake-up Type: Power Switch
>=20
> Handle 0x0002, DMI type 2, 8 bytes
> Base Board Information
> 	Manufacturer: TYAN Computer Corp
> 	Product Name: GT24-B2891
> 	Version: REFERENCE
> 	Serial Number: 0123456789
>=20
> Handle 0x0003, DMI type 3, 17 bytes
> Chassis Information
> 	Manufacturer: TYAN Computer Corp
> 	Type: Main Server Chassis
> 	Lock: Not Present
> 	Version: Not Specified
> 	Serial Number: Not Specified
> 	Asset Tag: Not Specified
> 	Boot-up State: Unknown
> 	Power Supply State: Unknown
> 	Thermal State: Unknown
> 	Security Status: Unknown
> 	OEM Information: 0x00000000
>=20
> Handle 0x0004, DMI type 4, 35 bytes
> Processor Information
> 	Socket Designation: CPU0-Socket 940
> 	Type: Central Processor
> 	Family: Opteron
> 	Manufacturer: AMD
> 	ID: 12 0F 02 00 FF FB 8B 17
> 	Signature: Family 15, Model 33, Stepping 2
> 	Flags:
> 		FPU (Floating-point unit on-chip)
> 		VME (Virtual mode extension)
> 		DE (Debugging extension)
> 		PSE (Page size extension)
> 		TSC (Time stamp counter)
> 		MSR (Model specific registers)
> 		PAE (Physical address extension)
> 		MCE (Machine check exception)
> 		CX8 (CMPXCHG8 instruction supported)
> 		APIC (On-chip APIC hardware supported)
> 		SEP (Fast system call)
> 		MTRR (Memory type range registers)
> 		PGE (Page global enable)
> 		MCA (Machine check architecture)
> 		CMOV (Conditional move instruction supported)
> 		PAT (Page attribute table)
> 		PSE-36 (36-bit page size extension)
> 		CLFSH (CLFLUSH instruction supported)
> 		MMX (MMX technology supported)
> 		FXSR (FXSAVE and FXSTOR instructions supported)
> 		SSE (Streaming SIMD extensions)
> 		SSE2 (Streaming SIMD extensions 2)
> 		HTT (Multi-threading)
> 	Version: AMD
> 	Voltage: 1.2 V
> 	External Clock: 200 MHz
> 	Max Speed: 3000 MHz
> 	Current Speed: 2000 MHz
> 	Status: Populated, Enabled
> 	Upgrade: None
> 	L1 Cache Handle: 0x0006
> 	L2 Cache Handle: 0x0007
> 	L3 Cache Handle: Not Provided
> 	Serial Number: Not Specified
> 	Asset Tag: Not Specified
> 	Part Number: Not Specified
>=20
> Handle 0x0005, DMI type 4, 35 bytes
> Processor Information
> 	Socket Designation: CPU1-Socket 940
> 	Type: Central Processor
> 	Family: Opteron
> 	Manufacturer: AMD
> 	ID: 12 0F 02 00 FF FB 8B 17
> 	Signature: Family 15, Model 33, Stepping 2
> 	Flags:
> 		FPU (Floating-point unit on-chip)
> 		VME (Virtual mode extension)
> 		DE (Debugging extension)
> 		PSE (Page size extension)
> 		TSC (Time stamp counter)
> 		MSR (Model specific registers)
> 		PAE (Physical address extension)
> 		MCE (Machine check exception)
> 		CX8 (CMPXCHG8 instruction supported)
> 		APIC (On-chip APIC hardware supported)
> 		SEP (Fast system call)
> 		MTRR (Memory type range registers)
> 		PGE (Page global enable)
> 		MCA (Machine check architecture)
> 		CMOV (Conditional move instruction supported)
> 		PAT (Page attribute table)
> 		PSE-36 (36-bit page size extension)
> 		CLFSH (CLFLUSH instruction supported)
> 		MMX (MMX technology supported)
> 		FXSR (FXSAVE and FXSTOR instructions supported)
> 		SSE (Streaming SIMD extensions)
> 		SSE2 (Streaming SIMD extensions 2)
> 		HTT (Multi-threading)
> 	Version: AMD
> 	Voltage: 1.2 V
> 	External Clock: 200 MHz
> 	Max Speed: 3000 MHz
> 	Current Speed: 2000 MHz
> 	Status: Populated, Enabled
> 	Upgrade: None
> 	L1 Cache Handle: 0x0008
> 	L2 Cache Handle: 0x0009
> 	L3 Cache Handle: Not Provided
> 	Serial Number: Not Specified
> 	Asset Tag: Not Specified
> 	Part Number: Not Specified
>=20
> Handle 0x0006, DMI type 7, 19 bytes
> Cache Information
> 	Socket Designation: H0 L1 Cache
> 	Configuration: Enabled, Not Socketed, Level 1
> 	Operational Mode: Write Back
> 	Location: Internal
> 	Installed Size: 64 kB
> 	Maximum Size: 64 kB
> 	Supported SRAM Types:
> 		Burst
> 		Pipeline Burst
> 		Asynchronous
> 	Installed SRAM Type: Asynchronous
> 	Speed: Unknown
> 	Error Correction Type: Unknown
> 	System Type: Unknown
> 	Associativity: Unknown
>=20
> Handle 0x0007, DMI type 7, 19 bytes
> Cache Information
> 	Socket Designation: H0 L2 Cache
> 	Configuration: Enabled, Not Socketed, Level 2
> 	Operational Mode: Write Through
> 	Location: Internal
> 	Installed Size: 2048 kB
> 	Maximum Size: 1024 kB
> 	Supported SRAM Types:
> 		Burst
> 		Pipeline Burst
> 		Synchronous
> 	Installed SRAM Type: Synchronous
> 	Speed: Unknown
> 	Error Correction Type: Unknown
> 	System Type: Unified
> 	Associativity: Unknown
>=20
> Handle 0x0008, DMI type 7, 19 bytes
> Cache Information
> 	Socket Designation: H1 L1 Cache
> 	Configuration: Enabled, Not Socketed, Level 1
> 	Operational Mode: Write Back
> 	Location: Internal
> 	Installed Size: 64 kB
> 	Maximum Size: 64 kB
> 	Supported SRAM Types:
> 		Burst
> 		Pipeline Burst
> 		Asynchronous
> 	Installed SRAM Type: Asynchronous
> 	Speed: Unknown
> 	Error Correction Type: Unknown
> 	System Type: Unknown
> 	Associativity: Unknown
>=20
> Handle 0x0009, DMI type 7, 19 bytes
> Cache Information
> 	Socket Designation: H1 L2 Cache
> 	Configuration: Enabled, Not Socketed, Level 2
> 	Operational Mode: Write Through
> 	Location: Internal
> 	Installed Size: 2048 kB
> 	Maximum Size: 1024 kB
> 	Supported SRAM Types:
> 		Burst
> 		Pipeline Burst
> 		Synchronous
> 	Installed SRAM Type: Synchronous
> 	Speed: Unknown
> 	Error Correction Type: Unknown
> 	System Type: Unified
> 	Associativity: Unknown
>=20
> Handle 0x000A, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J2
> 	Internal Connector Type: PS/2
> 	External Reference Designator: PS/2 Mouse
> 	External Connector Type: PS/2
> 	Port Type: Mouse Port
>=20
> Handle 0x000B, DMI type 9, 13 bytes
> System Slot Information
> 	Designation: PCI Slot 1
> 	Type: 32-bit PCI
> 	Current Usage: Unknown
> 	Length: Long
> 	ID: 0
> 	Characteristics:
> 		3.3 V is provided
> 		PME signal is supported
>=20
> Handle 0x000C, DMI type 11, 5 bytes
> OEM Strings
> 	String 1: 0
> 	String 2: 0
> 	String 3: .........................
>=20
> Handle 0x000D, DMI type 16, 15 bytes
> Physical Memory Array
> 	Location: System Board Or Motherboard
> 	Use: System Memory
> 	Error Correction Type: Single-bit ECC
> 	Maximum Capacity: 32 GB
> 	Error Information Handle: Not Provided
> 	Number Of Devices: 8
>=20
> Handle 0x000E, DMI type 17, 27 bytes
> Memory Device
> 	Array Handle: 0x000D
> 	Error Information Handle: No Error
> 	Total Width: 128 bits
> 	Data Width: 64 bits
> 	Size: 8192 MB
> 	Form Factor: DIMM
> 	Set: 1
> 	Locator: C0_DIMM0
> 	Bank Locator: Bank 0
> 	Type: DRAM
> 	Type Detail: Synchronous
> 	Speed: Unknown
> 	Manufacturer: Not Specified
> 	Serial Number: Not Specified
> 	Asset Tag: Not Specified
> 	Part Number: Not Specified
>=20
> Handle 0x000F, DMI type 17, 27 bytes
> Memory Device
> 	Array Handle: 0x000D
> 	Error Information Handle: No Error
> 	Total Width: 128 bits
> 	Data Width: 64 bits
> 	Size: 8192 MB
> 	Form Factor: DIMM
> 	Set: 2
> 	Locator: C0_DIMM1
> 	Bank Locator: Bank 1
> 	Type: DRAM
> 	Type Detail: Synchronous
> 	Speed: Unknown
> 	Manufacturer: Not Specified
> 	Serial Number: Not Specified
> 	Asset Tag: Not Specified
> 	Part Number: Not Specified
>=20
> Handle 0x0010, DMI type 17, 27 bytes
> Memory Device
> 	Array Handle: 0x000D
> 	Error Information Handle: No Error
> 	Total Width: 128 bits
> 	Data Width: 64 bits
> 	Size: 8192 MB
> 	Form Factor: DIMM
> 	Set: 3
> 	Locator: C0_DIMM2
> 	Bank Locator: Bank 2
> 	Type: DRAM
> 	Type Detail: Synchronous
> 	Speed: Unknown
> 	Manufacturer: Not Specified
> 	Serial Number: Not Specified
> 	Asset Tag: Not Specified
> 	Part Number: Not Specified
>=20
> Handle 0x0011, DMI type 17, 27 bytes
> Memory Device
> 	Array Handle: 0x000D
> 	Error Information Handle: No Error
> 	Total Width: 128 bits
> 	Data Width: 64 bits
> 	Size: 8192 MB
> 	Form Factor: DIMM
> 	Set: 3
> 	Locator: C0_DIMM3
> 	Bank Locator: Bank 3
> 	Type: DRAM
> 	Type Detail: Synchronous
> 	Speed: Unknown
> 	Manufacturer: Not Specified
> 	Serial Number: Not Specified
> 	Asset Tag: Not Specified
> 	Part Number: Not Specified
>=20
> Handle 0x0012, DMI type 17, 27 bytes
> Memory Device
> 	Array Handle: 0x000D
> 	Error Information Handle: No Error
> 	Total Width: 128 bits
> 	Data Width: 64 bits
> 	Size: 8192 MB
> 	Form Factor: DIMM
> 	Set: 3
> 	Locator: C0_DIMM0
> 	Bank Locator: Bank 0
> 	Type: DRAM
> 	Type Detail: Synchronous
> 	Speed: Unknown
> 	Manufacturer: Not Specified
> 	Serial Number: Not Specified
> 	Asset Tag: Not Specified
> 	Part Number: Not Specified
>=20
> Handle 0x0013, DMI type 17, 27 bytes
> Memory Device
> 	Array Handle: 0x000D
> 	Error Information Handle: No Error
> 	Total Width: 128 bits
> 	Data Width: 64 bits
> 	Size: 8192 MB
> 	Form Factor: DIMM
> 	Set: 3
> 	Locator: C1_DIMM1
> 	Bank Locator: Bank 1
> 	Type: DRAM
> 	Type Detail: Synchronous
> 	Speed: Unknown
> 	Manufacturer: Not Specified
> 	Serial Number: Not Specified
> 	Asset Tag: Not Specified
> 	Part Number: Not Specified
>=20
> Handle 0x0014, DMI type 17, 27 bytes
> Memory Device
> 	Array Handle: 0x000D
> 	Error Information Handle: No Error
> 	Total Width: Unknown
> 	Data Width: Unknown
> 	Size: No Module Installed
> 	Form Factor: DIMM
> 	Set: 3
> 	Locator: C1_DIMM2
> 	Bank Locator: Bank 2
> 	Type: DRAM
> 	Type Detail: Synchronous
> 	Speed: Unknown
> 	Manufacturer: Not Specified
> 	Serial Number: Not Specified
> 	Asset Tag: Not Specified
> 	Part Number: Not Specified
>=20
> Handle 0x0015, DMI type 17, 27 bytes
> Memory Device
> 	Array Handle: 0x000D
> 	Error Information Handle: No Error
> 	Total Width: Unknown
> 	Data Width: Unknown
> 	Size: No Module Installed
> 	Form Factor: DIMM
> 	Set: 3
> 	Locator: C1_DIMM3
> 	Bank Locator: Bank 3
> 	Type: DRAM
> 	Type Detail: Synchronous
> 	Speed: Unknown
> 	Manufacturer: Not Specified
> 	Serial Number: Not Specified
> 	Asset Tag: Not Specified
> 	Part Number: Not Specified
>=20
> Handle 0x0016, DMI type 19, 15 bytes
> Memory Array Mapped Address
> 	Starting Address: 0x00000000000
> 	Ending Address: 0x00BFFFFFFFF
> 	Range Size: 48 GB
> 	Physical Array Handle: 0x000D
> 	Partition Width: 2
>=20
> Handle 0x0017, DMI type 20, 19 bytes
> Memory Device Mapped Address
> 	Starting Address: 0x00000000000
> 	Ending Address: 0x001FFFFFFFF
> 	Range Size: 8 GB
> 	Physical Device Handle: 0x000E
> 	Memory Array Mapped Address Handle: 0x0016
> 	Partition Row Position: 1
> 	Interleaved Data Depth: 1
>=20
> Handle 0x0018, DMI type 20, 19 bytes
> Memory Device Mapped Address
> 	Starting Address: 0x00200000000
> 	Ending Address: 0x003FFFFFFFF
> 	Range Size: 8 GB
> 	Physical Device Handle: 0x000F
> 	Memory Array Mapped Address Handle: 0x0016
> 	Partition Row Position: 1
> 	Interleaved Data Depth: 1
>=20
> Handle 0x0019, DMI type 20, 19 bytes
> Memory Device Mapped Address
> 	Starting Address: 0x00400000000
> 	Ending Address: 0x005FFFFFFFF
> 	Range Size: 8 GB
> 	Physical Device Handle: 0x0010
> 	Memory Array Mapped Address Handle: 0x0016
> 	Partition Row Position: 1
> 	Interleaved Data Depth: 1
>=20
> Handle 0x001A, DMI type 20, 19 bytes
> Memory Device Mapped Address
> 	Starting Address: 0x00600000000
> 	Ending Address: 0x007FFFFFFFF
> 	Range Size: 8 GB
> 	Physical Device Handle: 0x0011
> 	Memory Array Mapped Address Handle: 0x0016
> 	Partition Row Position: 1
> 	Interleaved Data Depth: 1
>=20
> Handle 0x001B, DMI type 20, 19 bytes
> Memory Device Mapped Address
> 	Starting Address: 0x00800000000
> 	Ending Address: 0x009FFFFFFFF
> 	Range Size: 8 GB
> 	Physical Device Handle: 0x0012
> 	Memory Array Mapped Address Handle: 0x0016
> 	Partition Row Position: 1
> 	Interleaved Data Depth: 1
>=20
> Handle 0x001C, DMI type 20, 19 bytes
> Memory Device Mapped Address
> 	Starting Address: 0x00A00000000
> 	Ending Address: 0x00BFFFFFFFF
> 	Range Size: 8 GB
> 	Physical Device Handle: 0x0013
> 	Memory Array Mapped Address Handle: 0x0016
> 	Partition Row Position: 1
> 	Interleaved Data Depth: 1
>=20
> Handle 0x001D, DMI type 20, 19 bytes
> Memory Device Mapped Address
> 	Starting Address: 0x00BFFFFFC00
> 	Ending Address: 0x00BFFFFFFFF
> 	Range Size: 1 kB
> 	Physical Device Handle: 0x0014
> 	Memory Array Mapped Address Handle: 0x0016
> 	Partition Row Position: 1
> 	Interleaved Data Depth: 1
>=20
> Handle 0x001E, DMI type 20, 19 bytes
> Memory Device Mapped Address
> 	Starting Address: 0x00BFFFFFC00
> 	Ending Address: 0x00BFFFFFFFF
> 	Range Size: 1 kB
> 	Physical Device Handle: 0x0015
> 	Memory Array Mapped Address Handle: 0x0016
> 	Partition Row Position: 1
> 	Interleaved Data Depth: 1
>=20
> Handle 0x001F, DMI type 32, 20 bytes
> System Boot Information
> 	Status: <OUT OF SPEC>
>=20
> Handle 0x0020, DMI type 38, 18 bytes
> IPMI Device Information
> 	Interface Type: KCS (Keyboard Control Style)
> 	Specification Version: 2.0
> 	I2C Slave Address: 0x10
> 	NV Storage Device: Not Present
> 	Base Address: 0x0000000000000CA8 (I/O)
> 	Register Spacing: 32-bit Boundaries
> 	Interrupt Polarity: Active Low
> 	Interrupt Trigger Mode: Edge
>=20
> Handle 0x0021, DMI type 127, 4 bytes
> End Of Table


--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
