From: Alejandro Riveira =?UTF-8?B?RmVybsOhbmRleg==?=
	<ariveira@gmail.com>
Subject: Re: atl1e: TSO is broken
Date: Fri, 15 Jan 2010 16:54:47 +0100
Message-ID: <20100115165447.2eb7d547@varda>
References: <20100115.135613.1130385479658158300.anders@netinsight.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiong.huang@atheros.com, jie.yang@atheros.com,
	linux-kernel@vger.kernel.org, ben@decadent.org.uk,
	netdev@vger.kernel.org
To: Anders =?UTF-8?B?Qm9zdHLDtm0=?= <anders@netinsight.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756884Ab0AOPzD@vger.kernel.org>
In-Reply-To: <20100115.135613.1130385479658158300.anders@netinsight.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

El Fri, 15 Jan 2010 13:56:13 +0100 (CET)
Anders Bostr=C3=B6m <anders@netinsight.net> escribi=C3=B3:

CCing netdev

> Short desription
> ----------------
>=20
> TCP Segmentation Offload (TSO) result in broken IPv4-packets sent out
> from Atheros AR8121/AR8113/AR8114 with the atl1e driver.
>=20
>=20
> Work around
> -----------
>=20
> Turn off TSO. Requires 2.6.33-rc1 or later.
>=20
>=20
> Long desription
> ----------------
>=20
> When I run NFS over TCP (default options) and read large files from a
> server with Atheros AR8121/AR8113/AR8114 Ethernet chip, I only get
> ~25Mbyte/s performance. I get ~5000 retransmitted packets per GByte
> data, according to RetransSegs in /proc/net/snmp . wireshark in the
> client show that the server send out a sequence of frames. All but th=
e
> last one are 1500 bytes IP-packets. The last one is shorter, but the
> IP-header still say 1500 byte. The client then requests retransmit,
> and the retransmitted frame arrives with correct IP-header.
>=20
> If I mount NFS using UDP instead, performance is ~110Mbyte/s.
>=20
> TCP Segmentation Offload (TSO) is default enabled in the atl1e
> Ethernet-driver. When I run a patched 2.6.30.10, enabling ethtool to
> turn off TSO (using ac936929092dc6a5409b627c4c67305ab9b626b3 by Ben
> Hutchings), and turn off TSO, the problem disappears. Performance is
> ~110Mbyte/s and no broken IP-packets arrive.
>=20
>=20
> Capture of 146-byte Ethernet frame with bad IP-header:
>=20
> No.     Time        Source                Destination           Proto=
col Info
>   98329 11.034129   flash.netinsight.se   sid.netinsight.se     RPC  =
    Continuation
>=20
> Frame 98329 (146 bytes on wire, 146 bytes captured)
>     Arrival Time: Jan 15, 2010 13:35:16.224491000
>     [Time delta from previous captured frame: 0.000009000 seconds]
>     [Time delta from previous displayed frame: 0.000009000 seconds]
>     [Time since reference or first frame: 11.034129000 seconds]
>     Frame Number: 98329
>     Frame Length: 146 bytes
>     Capture Length: 146 bytes
>     [Frame is marked: False]
>     [Protocols in frame: eth:ip:tcp:rpc]
>     [Coloring Rule Name: TCP]
>     [Coloring Rule String: tcp]
> Ethernet II, Src: AsustekC_ae:69:6d (00:26:18:ae:69:6d), Dst: sid.net=
insight.se (00:18:f3:52:22:3f)
> Internet Protocol, Src: flash.netinsight.se (10.100.0.88), Dst: sid.n=
etinsight.se (10.100.1.25)
>     Version: 4
>     Header length: 20 bytes
>     Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x0=
0)
>     Total Length: 1500
>     Identification: 0x331e (13086)
>     Flags: 0x02 (Don't Fragment)
>     Fragment offset: 0
>     Time to live: 64
>     Protocol: TCP (0x06)
>     Header checksum: 0xebc5 [correct]
>     Source: flash.netinsight.se (10.100.0.88)
>     Destination: sid.netinsight.se (10.100.1.25)
> Transmission Control Protocol, Src Port: nfs (2049), Dst Port: access=
builder (888), Seq: 93989617, Ack: 516997, Len: 80
> Remote Procedure Call
>=20
> 0000  00 18 f3 52 22 3f 00 26 18 ae 69 6d 08 00 45 00   ...R"?.&..im.=
=2EE.
> 0010  05 dc 33 1e 40 00 40 06 eb c5 0a 64 00 58 0a 64   ..3.@.@....d.=
X.d
> 0020  01 19 08 01 03 78 a4 07 57 23 e6 50 1f 1b 80 10   .....x..W#.P.=
=2E..
> 0030  01 f5 dd 8d 00 00 01 01 08 0a 05 28 ca 7e 38 93   ...........(.=
~8.
> 0040  67 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00   g............=
=2E..
> 0050  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0060  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0070  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0080  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0090  00 00                                             ..
>=20
>=20
>=20
> Software info:
>=20
> I've tested with Debian 2.6.26 (stable) and 2.6.30 (testing), as well
> as 2.6.30.10 from kernel.org. Same result.
>=20
> Hardware info:
>=20
> lspci -vvv:
>=20
> 03:00.0 Ethernet controller: Attansic Technology Corp. Atheros AR8121=
/AR8113/AR8114 PCI-E Ethernet Controller (rev b0)
>         Subsystem: ASUSTeK Computer Inc. Device 831c
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- P=
arErr- Stepping- SERR+ FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbo=
rt- <TAbort- <MAbort- >SERR+ <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 27
>         Region 0: Memory at fbfc0000 (64-bit, non-prefetchable) [size=
=3D256K]
>         Region 2: I/O ports at ec00 [size=3D128]
>         Capabilities: [40] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,=
D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>         Capabilities: [48] Message Signalled Interrupts: Mask- 64bit+=
 Queue=3D0/0 Enable+
>                 Address: 00000000fee0f00c  Data: 4189
>         Capabilities: [58] Express (v1) Endpoint, MSI 00
>                 DevCap: MaxPayload 4096 bytes, PhantFunc 0, Latency L=
0s <4us, L1 unlimited
>                         ExtTag- AttnBtn+ AttnInd+ PwrInd+ RBE- FLRese=
t-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-=
 Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxP=
wr+ TransPend-
>                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, L=
atency L0 unlimited, L1 unlimited
>                         ClockPM- Suprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain=
- CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt=
-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotCl=
k+ DLActive- BWMgmt- ABWMgmt-
>         Capabilities: [100] Advanced Error Reporting <?>
>         Capabilities: [180] Device Serial Number ff-18-26-00-6d-69-ae=
-ff
>         Kernel driver in use: ATL1E
>         Kernel modules: atl1e
>=20
> ethtool -i eth0:
>=20
> driver: ATL1E
> version: 1.0.0.7-NAPI
> firmware-version: L1e
> bus-info: 0000:03:00.0
>=20
>=20
> / Anders
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
