From: P@draigBrady.com
Subject: strange e1000 interface freeze
Date: Mon, 09 Aug 2004 11:54:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411757CA.4010401@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: e1000-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've been able to reproduce an situation here
where the interface freezes on a platform
where a continuous stream of about 8000 packets
per second are being received. It usually takes
about 2 days to reproduce, but I've a system
in this state now if you have anything you want
me to look at.

I've reproduced the problem in both 100 and 1000 Mb/s mode,
but it seems easier to reproduce in 100 mode?
Also usually one but sometimes both interfaces lock up.
By lock up I mean that the interface records all packets
as fifo errors, and it receives only 1 interrupt every 2 seconds.
Note the other NAPI interface works fine (at about 7.5K interrupts/s).

The system is E7501 based with an 82546EB running kernel 2.4.20
with the 5.2.52 e1000 driver in NAPI mode.
Here are the ethernet settings from one of the dual ports
(the other is identical):

Intel(R) PRO/1000 Network Driver - version 5.2.52
Copyright (c) 1999-2004 Intel Corporation.
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
e1000: eth1: e1000_validate_option: Transmit Descriptors set to 4096
e1000: eth1: e1000_validate_option: Receive Descriptors set to 4096
e1000: eth1: e1000_validate_option: Checksum Offload Enabled
e1000: eth1: e1000_validate_option: Flow Control Disabled
e1000: eth1: e1000_validate_option: Transmit Interrupt Delay set to 0
e1000: eth1: e1000_validate_option: Transmit Absolute Interrupt Delay=20
set to 0
e1000: eth1: e1000_validate_option: Receive Interrupt Delay set to 0
e1000: eth1: e1000_validate_option: Receive Absolute Interrupt Delay=20
set to 0

Here is the lspci output for the locked interface.
NOTE the pci master abort is set!

05:0c.1 Class 0200: 8086:1010 (rev 01)
	Subsystem: 8086:1011
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-=20
Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 52 (63750ns min), cache line size 08
	Interrupt: pin B routed to IRQ 49
	Region 0: Memory at fc220000 (64-bit, non-prefetchable) [size=3D128K]
	Region 4: I/O ports at 2040 [size=3D64]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D1 PME-
	Capabilities: [e4] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=3D2 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-, DC=3Dsimple,=
=20
DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-	Capabilities: [f0] Message=20
Signalled Interrupts: 64bit+ Queue=3D0/0 Enable-
		Address: 0000000000000000  Data: 0000

There are no e1000 messages in the logs.

cheers,
P=C3=A1draig.
