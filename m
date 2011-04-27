From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Wed, 27 Apr 2011 13:46:30 +0200
Message-ID: <201104271346.34431.maxi@daemonizer.de>
References: <201104250033.03401.maxi@daemonizer.de> <EDC0E76513226749BFBC9C3FB031318F016B4125A4@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart10057156.ZqjvRVH0SN";
  protocol="application/pgp-signature";
  micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <EDC0E76513226749BFBC9C3FB031318F016B4125A4@orsmsx508.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart10057156.ZqjvRVH0SN
Content-Type: multipart/mixed;
  boundary="Boundary-01=_XIAuNVSBAfEn01s"
Content-Transfer-Encoding: 7bit


--Boundary-01=_XIAuNVSBAfEn01s
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 27 April 2011 01:34:09 Wyborny, Carolyn wrote:
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> >On Behalf Of Maximilian Engelhardt
> >Sent: Sunday, April 24, 2011 3:33 PM
> >To: linux-kernel@vger.kernel.org
> >Cc: netdev@vger.kernel.org; StuStaNet Vorstand
> >Subject: Kernel crash after using new Intel NIC (igb)
> >
> >Hello,
> >
> >some time ago we switched some of our servers to a new networking card
> >that
> >uses the Intel igb driver. Since that time we see regular kernel
> >crashes.
> >The crashes happen at very irregular intervals, sometimes after a week
> >uptime,
> >sometimes after a month or even more. They seem to be independent of the
> >server load as they also happen in the night when there is low traffic.
> >
> >The affected server is used as a NAT device with some iptables rules and
> >serves
> >about 2000 people.
> >
> >Attached are two logs of the crashes as well as the output of dmesg,
> >lspci,
> >and /proc/interrupts as well as the used kernel config.
> >
> >I have no idea what might be wrong but I think it is a kernel bug.
> >Perhaps
> >someone with more knowledge has a clue.
> >
> >If needed I can provide additional information or build different
> >kernels.
> >
> >Greetings,
> >Maxi
>=20
> Hello,
>=20
> I'm sorry you're having crashes since installing our NIC.  Thank you for
> the data.  I haven't had a chance to review it carefully yet, but it looks
> to me like the crashes have us in the stack sometimes and sometimes not.=
=20
> I need to do a bit more research and will need some more information.  Can
> I get an ethtool -i eth# for the device and also lspci -vvv for the
> platform its installed on.
>=20
> If you open an issue at SourceForge we will have a place to keep the logs.
>=20
> I will research this a bit more and get back to you tomorrow my time.
>=20
> Thanks,
>=20
> Carolyn
> Carolyn Wyborny
> Linux Development
> LAN Access Division
> Intel Corporation


Hello Carolyn,

Thanks for your response.

I have opened a issue at
https://sourceforge.net/tracker/?func=3Ddetail&aid=3D3293703&group_id=3D423=
02&atid=3D447449
and also posted all information there.


Please not that yesterday I updated the kernel, so I'm now running 2.6.38.4.
Eric Dumazet mentioned on the LKML that this might be a memory corruption t=
hat=20
my be solved with kernel 2.6.38.

I'll report if the crash happens again, but it might take some times as in =
the=20
past it happened within the interval of weeks to month.


Here is the output of ethtool (with the new 2.6.38.4 kernel):
$ /sbin/ethtool -i eth0
driver: igb
version: 2.1.0-k2
firmware-version: 1.2-1
bus-info: 0000:05:00.0
$ /sbin/ethtool -i eth1
driver: igb
version: 2.1.0-k2
firmware-version: 1.2-1
bus-info: 0000:05:00.1

The output of lspci -vvv is attached (also with kernel 2.6.38.4 but I guess=
 it=20
doesn't make any difference)


Greetings,
Maxi

--Boundary-01=_XIAuNVSBAfEn01s
Content-Type: text/plain;
  charset="UTF-8";
  name="lspci_vvv"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="lspci_vvv"

00:00.0 Host bridge: Intel Corporation 3200/3210 Chipset DRAM Controller (rev 01)
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: <access denied>
	Kernel driver in use: i3200_edac

00:01.0 PCI bridge: Intel Corporation 3200/3210 Chipset Host-Primary PCI Express Bridge (rev 01) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=01, subordinate=03, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: d0100000-d01fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #4 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 4: I/O ports at 1820 [size=32]
	Capabilities: <access denied>
	Kernel driver in use: uhci_hcd

00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #5 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 17
	Region 4: I/O ports at 1840 [size=32]
	Capabilities: <access denied>
	Kernel driver in use: uhci_hcd

00:1a.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #6 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 1860 [size=32]
	Capabilities: <access denied>
	Kernel driver in use: uhci_hcd

00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #2 (rev 02) (prog-if 20 [EHCI])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 0: Memory at d0000000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: <access denied>
	Kernel driver in use: ehci_hcd

00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 1 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: d0200000-d0bfffff
	Prefetchable memory behind bridge: 00000000d1000000-00000000d17fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1c.4 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 5 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=0d, subordinate=0d, sec-latency=0
	I/O behind bridge: 00003000-00003fff
	Memory behind bridge: d0c00000-d0cfffff
	Prefetchable memory behind bridge: 00000000d1800000-00000000d19fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1c.5 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 6 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=0f, subordinate=0f, sec-latency=0
	I/O behind bridge: 00004000-00004fff
	Memory behind bridge: d0d00000-d0dfffff
	Prefetchable memory behind bridge: 00000000d1a00000-00000000d1bfffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #1 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at 1880 [size=32]
	Capabilities: <access denied>
	Kernel driver in use: uhci_hcd

00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #2 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 22
	Region 4: I/O ports at 18a0 [size=32]
	Capabilities: <access denied>
	Kernel driver in use: uhci_hcd

00:1d.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #3 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 18c0 [size=32]
	Capabilities: <access denied>
	Kernel driver in use: uhci_hcd

00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #1 (rev 02) (prog-if 20 [EHCI])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at d0000400 (32-bit, non-prefetchable) [size=1K]
	Capabilities: <access denied>
	Kernel driver in use: ehci_hcd

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=11, subordinate=11, sec-latency=32
	I/O behind bridge: 00005000-00005fff
	Memory behind bridge: d0e00000-d0efffff
	Prefetchable memory behind bridge: 00000000d8000000-00000000dfffffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>

00:1f.0 ISA bridge: Intel Corporation 82801IR (ICH9R) LPC Interface Controller (rev 02)
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: <access denied>

00:1f.2 SATA controller: Intel Corporation 82801IR/IO/IH (ICH9R/DO/DH) 6 port SATA AHCI Controller (rev 02) (prog-if 01 [AHCI 1.0])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 92
	Region 0: I/O ports at 1c50 [size=8]
	Region 1: I/O ports at 1c44 [size=4]
	Region 2: I/O ports at 1c48 [size=8]
	Region 3: I/O ports at 1c40 [size=4]
	Region 4: I/O ports at 18e0 [size=32]
	Region 5: Memory at d0000800 (32-bit, non-prefetchable) [size=2K]
	Capabilities: <access denied>
	Kernel driver in use: ahci

00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller (rev 02)
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 17
	Region 0: Memory at d0001000 (64-bit, non-prefetchable) [size=256]
	Region 4: I/O ports at 1100 [size=32]
	Kernel driver in use: i801_smbus

00:1f.6 Signal processing controller: Intel Corporation 82801I (ICH9 Family) Thermal Subsystem (rev 02)
	Subsystem: Super Micro Computer Inc Device 0000
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 5
	Region 0: Memory at d0002000 (64-bit, non-prefetchable) [size=4K]
	Capabilities: <access denied>

01:00.0 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge A (rev 09) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=01, secondary=02, subordinate=02, sec-latency=64
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>

01:00.1 PIC: Intel Corporation 6700/6702PXH I/OxAPIC Interrupt Controller A (rev 09) (prog-if 20 [IO(X)-APIC])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Region 0: Memory at d0100000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: <access denied>

01:00.2 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge B (rev 09) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=01, secondary=03, subordinate=03, sec-latency=64
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>

01:00.3 PIC: Intel Corporation 6700PXH I/OxAPIC Interrupt Controller B (rev 09) (prog-if 20 [IO(X)-APIC])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Region 0: Memory at d0101000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: <access denied>

05:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
	Subsystem: Intel Corporation Gigabit ET Dual Port Server Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at d0220000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at d0400000 (32-bit, non-prefetchable) [size=4M]
	Region 2: I/O ports at 2000 [size=32]
	Region 3: Memory at d0200000 (32-bit, non-prefetchable) [size=16K]
	[virtual] Expansion ROM at d1000000 [disabled] [size=4M]
	Capabilities: <access denied>
	Kernel driver in use: igb

05:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
	Subsystem: Intel Corporation Gigabit ET Dual Port Server Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 17
	Region 0: Memory at d0240000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at d0800000 (32-bit, non-prefetchable) [size=4M]
	Region 2: I/O ports at 2020 [size=32]
	Region 3: Memory at d0204000 (32-bit, non-prefetchable) [size=16K]
	[virtual] Expansion ROM at d1400000 [disabled] [size=4M]
	Capabilities: <access denied>
	Kernel driver in use: igb

0d:00.0 Ethernet controller: Intel Corporation 82573E Gigabit Ethernet Controller (Copper) (rev 03)
	Subsystem: Super Micro Computer Inc Device 108c
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 93
	Region 0: Memory at d0c00000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at 3000 [size=32]
	Capabilities: <access denied>
	Kernel driver in use: e1000e

0f:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
	Subsystem: Super Micro Computer Inc Device 109a
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 94
	Region 0: Memory at d0d00000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at 4000 [size=32]
	Capabilities: <access denied>
	Kernel driver in use: e1000e

11:04.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02) (prog-if 00 [VGA controller])
	Subsystem: Super Micro Computer Inc Device d280
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR+ FastB2B+ DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 66 (2000ns min), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at d8000000 (32-bit, prefetchable) [size=128M]
	Region 1: I/O ports at 5000 [size=256]
	Region 2: Memory at d0e00000 (32-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at d0e20000 [disabled] [size=128K]
	Capabilities: <access denied>


--Boundary-01=_XIAuNVSBAfEn01s--

--nextPart10057156.ZqjvRVH0SN
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJNuAIXAAoJEIHqZH0kK9IVfgAP/3aA9DyXer6t9+RJ0lLCfsbP
6/q+mCK5BG5DVDFXHt/ZwvMCk7jwLJEe/F+mlq8B/At0urPZtLIckAUqdM/WBC0a
WMjgDsPHzbjsXcxOz+dO2cHXBk6bdIFpwGKXKAzQYIoZydNUC132k8tf1709MK1Z
SXWIqmk5M/xAVZRvN/9R5K9JWVjJDwKbQHLKu4AAKgUEwD7BXN0befm8MmNK6FuI
uwAYB2gaOF+mcY2sauKKtXfERkN6jSvXT8jauB9yylOBF+IY4vFAGWxk23HSleM5
vJw9/LG3CSHZpVVm1f6yB0hf08tJr+c+qPsBw1H6E5s9fX658UY4x7ht6Dcsrziz
B3sM+Y86kMJErD/1e+qoG81g+4QPUOcTnuJQSKfL2e600ClAEHs7NjAVsJtarHiC
NMEh3Sd1KkwxKbnFd2IGmOuGcCX0eDwMXsJnY5MmTNofhiJseIkLvEcRih9QEe6T
OGrhcsVOSG2A8fn7SBxvpAvsP/9snuh4VGp+WfvghWpNSEBWqs5NhG+8ZCTPd0dC
DC+WI7qKUMeWX0+3GzGuDVlNt/JF1ANzFYGJxPvweQHP/WpQEUP3aBXyWrI6Wzy7
UJQ6/BesuON53YDl9r9dmscXhVxka0B7TwYw/Re86nsARQfK4GOpL2AdpGq6bmtM
9qsOTkwQJrrrRYkzPXn8
=z/sp
-----END PGP SIGNATURE-----

--nextPart10057156.ZqjvRVH0SN--
