From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet Corruption with Atheros Communications Inc.
 AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) Interface
Date: Wed, 21 Nov 2012 09:14:09 -0800
Message-ID: <1353518049.2590.41.camel@edumazet-glaptop>
References: <50ACEB1D.2020303@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Martin Tessun <martin.tessun@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64829 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087Ab2KURON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 12:14:13 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so5221010pbc.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 09:14:13 -0800 (PST)
In-Reply-To: <50ACEB1D.2020303@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 15:54 +0100, Martin Tessun wrote:
> Hi @all,
>=20
> unfortunately I don't have the old postings any more, so I start a ne=
w=20
> thread.
>=20
> Following situation:
>=20
> I have a Server (NFS) and a Client with the Atheros network card. If =
I=20
> transfer big files, the md5sum of these files differ.
> If I try to scp the file I get "MAC corrupted on inpu".
>=20
> Everything works fine, if running on any other OS (or with other NICs=
=20
> than the Atheros one).
>=20
> So here is the data:
>=20
> lspci:
> 02:00.0 Ethernet controller: Atheros Communications Inc.=20
> AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0)
>          Subsystem: ASUSTeK Computer Inc. Device 831c
>          Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR+ FastB2B- DisINTx+
>          Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAb=
ort-=20
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>          Latency: 0, Cache Line Size: 64 bytes
>          Interrupt: pin A routed to IRQ 44
>          Region 0: Memory at fbec0000 (64-bit, non-prefetchable) [siz=
e=3D256K]
>          Region 2: I/O ports at dc00 [size=3D128]
>          Capabilities: [40] Power Management version 2
>                  Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
> PME(D0-,D1-,D2-,D3hot+,D3cold+)
>                  Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D=
0 PME-
>          Capabilities: [48] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
>                  Address: 00000000fee0f00c  Data: 4181
>          Capabilities: [58] Express (v1) Endpoint, MSI 00
>                  DevCap: MaxPayload 4096 bytes, PhantFunc 0, Latency =
L0s=20
> <4us, L1 unlimited
>                          ExtTag- AttnBtn+ AttnInd+ PwrInd+ RBE- FLRes=
et-
>                  DevCtl: Report errors: Correctable- Non-Fatal- Fatal=
-=20
> Unsupported-
>                          RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                          MaxPayload 128 bytes, MaxReadReq 512 bytes
>                  DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+=20
> AuxPwr+ TransPend-
>                  LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s,=20
> Latency L0 unlimited, L1 unlimited
>                          ClockPM- Surprise- LLActRep- BwNot-
>                  LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrai=
n-=20
> CommClk+
>                          ExtSynch- ClockPM- AutWidDis- BWInt- AutBWIn=
t-
>                  LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotC=
lk+=20
> DLActive- BWMgmt- ABWMgmt-
>          Capabilities: [100 v1] Advanced Error Reporting
>                  UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt+=20
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
>                  UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-=20
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                  UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt-=20
> UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>                  CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-=20
> NonFatalErr-
>                  CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-=20
> NonFatalErr-
>                  AERCap: First Error Pointer: 14, GenCap+ CGenEn-=20
> ChkCap+ ChkEn-
>          Capabilities: [180 v1] Device Serial Number ff-76-f8-79-00-2=
6-18-ff
>          Kernel driver in use: ATL1E
>=20
>=20
> $ ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: off
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off
> rx-vlan-offload: on
> tx-vlan-offload: on
> ntuple-filters: off
> receive-hashing: off
>=20
>=20
> SCP initiated on client:
> $ scp server:/export/no_backup/burn/openSUSE-12.2-DVD-x86_64.iso .
> openSUSE-12.2-DVD-x86_64.iso=20
> =20
>                                                                1%   8=
8MB=20
>    9.8MB/s   07:26 ETA
> Corrupted MAC on input.
> Disconnecting: Packet corrupt
> lost connection
>=20
> SCP initiated on server:
> $ scp /export/no_backup/burn/openSUSE-12.2-DVD-x86_64.iso client:/tmp
> Enter passphrase for key '/home/chewie/tessun/.ssh/id_rsa':
> openSUSE-12.2-DVD-x86_64.iso=20
> =20
>                                                                5%  22=
9MB=20
>    7.0MB/s   10:00 ETA
> Received disconnect from 2a01:198:366:100::fba5: 2: Packet corrupt
> lost connection
>=20
>=20
> ifconfig-output (Client):
>            RX packets:773481 errors:0 dropped:7620 overruns:0 frame:0
>            TX packets:589594 errors:0 dropped:0 overruns:0 carrier:1
>            collisions:0 Sendewarteschlangenl=C3=A4nge:1000
>            RX bytes:596932088 (569.2 Mb)  TX bytes:90583584 (86.3 Mb)
>            Interrupt:44
>=20
> ifconfig-Output (Server):
>            RX packets:11579837 errors:0 dropped:0 overruns:0 frame:0
>            TX packets:19734057 errors:0 dropped:0 overruns:0 carrier:=
0
>            collisions:0 txqueuelen:1000
>            RX bytes:2717120721 (2591.2 Mb)  TX bytes:22047372376=20
> (21026.0 Mb)
>            Interrupt:42 Base address:0xc000
>=20
>=20
> As said: Other NICs than the Atheros work fine.
>=20
> If you need additional Infos (tcpdumps, etc.) please let me know.
>=20
> Regards,
> Martin

Is it only happening for IPv6 traffic, or is it also buggy for IPv4 ?

If you disable tso , does the bug disappear ?
