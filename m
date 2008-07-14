From: Mario Limonciello <mario_limonciello@dell.com>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
 Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
 Problem)
Date: Mon, 14 Jul 2008 16:00:39 -0500
Message-ID: <487BBE77.7050702@dell.com>
References: <4861800B.90703@nscus.com> <48777BC3.6090108@dell.com>	 <1216052460.23392.14.camel@localhost>	 <200807142152.26163.eike-kernel@sf-tec.de>  <487BB065.3020709@dell.com> <1216068344.23392.19.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6F47E8A78D3EE8353B3980CB"
Cc: Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Michael Grollman <mgrollman@nscus.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Kasper Sandberg <lkml@metanurb.dk>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1216068344.23392.19.camel@localhost>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6F47E8A78D3EE8353B3980CB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Kasper:

If I was to guess (I didn't actually work out which one yours identifies
as), most likely your NIC isn't caught in my check for MAC_VER_13 or
MAC_VER_16, but Francois's patch has:


-	dprintk("Set MAC Reg C+CR Offset 0x82h =3D 0x01h\n");
-	RTL_W8(0x82, 0x01);
+	if (tp->mac_version <=3D RTL_GIGA_MAC_VER_06) {
+		dprintk("Set MAC Reg C+CR Offset 0x82h =3D 0x01h\n");
+		RTL_W8(0x82, 0x01);
+	}

Which I've got indirectly but checking for 13 & 16.

Regards

Kasper Sandberg wrote:
> On Mon, 2008-07-14 at 15:00 -0500, Mario Limonciello wrote:
>  =20
>> Kasper:
>>
>> Interesting that it failed for you though.  I was able to run through =
a
>> script of 200x rmmod/modprobe without any trouble when that patch was
>> applied.
>>    =20
>
> Well are you sure it actually catches my nics?
>
> i have 8111c:
>
> 05:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd.
> RTL8111/8168B PCI Express Gigabit Ethernet controller [10ec:8168] (rev
> 02)
>         Subsystem: Giga-byte Technology Unknown device [1458:e000]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 376
>         Region 0: I/O ports at c000 [size=3D256]
>         Region 2: Memory at e9010000 (64-bit, prefetchable) [size=3D4K]=

>         Region 4: Memory at e9000000 (64-bit, prefetchable) [size=3D64K=
]
>         [virtual] Expansion ROM at e9020000 [disabled] [size=3D64K]
>         Capabilities: [40] Power Management version 3
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0+,=
D1
> +,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>         Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
> Queue=3D0/1 Enable+
>                 Address: 00000000fee0f00c  Data: 416e
>         Capabilities: [70] Express (v1) Endpoint, MSI 01
>                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
> <512ns, L1 <8us
>                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-=

>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 4096 bytes
>                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr=
+
> TransPend-
>                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
> Latency L0 <512ns, L1 <64us
>                         ClockPM+ Suprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+=

> DLActive- BWMgmt- ABWMgmt-
>         Capabilities: [b0] MSI-X: Enable- Mask- TabSize=3D2
>                 Vector table: BAR=3D4 offset=3D00000000
>                 PBA: BAR=3D4 offset=3D00000800
>         Capabilities: [d0] Vital Product Data <?>
>         Capabilities: [100] Advanced Error Reporting <?>
>         Capabilities: [140] Virtual Channel <?>
>         Capabilities: [160] Device Serial Number 00-00-00-00-00-00-00-0=
0
>         Kernel driver in use: r8169
>         Kernel modules: r8169
> 00: ec 10 68 81 07 04 10 00 02 00 00 02 08 00 00 00
> 10: 01 c0 00 00 00 00 00 00 0c 00 01 e9 00 00 00 00
> 20: 0c 00 00 e9 00 00 00 00 00 00 00 00 58 14 00 e0
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 0a 01 00 00
>
> 06:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd.
> RTL8111/8168B PCI Express Gigabit Ethernet controller [10ec:8168] (rev
> 02)
>         Subsystem: Giga-byte Technology Unknown device [1458:e000]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 375
>         Region 0: I/O ports at d000 [size=3D256]
>         Region 2: Memory at e9110000 (64-bit, prefetchable) [size=3D4K]=

>         Region 4: Memory at e9100000 (64-bit, prefetchable) [size=3D64K=
]
>         [virtual] Expansion ROM at e9120000 [disabled] [size=3D64K]
>         Capabilities: [40] Power Management version 3
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0+,=
D1
> +,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>         Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
> Queue=3D0/1 Enable+
>                 Address: 00000000fee0f00c  Data: 4176
>         Capabilities: [70] Express (v1) Endpoint, MSI 01
>                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
> <512ns, L1 <8us
>                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-=

>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr=
+
> TransPend-
>                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
> Latency L0 <512ns, L1 <64us
>                         ClockPM+ Suprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+=

> DLActive- BWMgmt- ABWMgmt-
>         Capabilities: [b0] MSI-X: Enable- Mask- TabSize=3D2
>                 Vector table: BAR=3D4 offset=3D00000000
>                 PBA: BAR=3D4 offset=3D00000800
>         Capabilities: [d0] Vital Product Data <?>
>         Capabilities: [100] Advanced Error Reporting <?>
>         Capabilities: [140] Virtual Channel <?>
>         Capabilities: [160] Device Serial Number 00-00-00-00-00-00-00-0=
0
>         Kernel driver in use: r8169
>         Kernel modules: r8169
> 00: ec 10 68 81 07 04 10 00 02 00 00 02 08 00 00 00
> 10: 01 d0 00 00 00 00 00 00 0c 00 11 e9 00 00 00 00
> 20: 0c 00 10 e9 00 00 00 00 00 00 00 00 58 14 00 e0
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00
>
>
> Either way, the patchset from Francois seems to fix it, With this in
> mind, do we actually know exactly what causes it?
>
>  =20
>> Regards
>>
>> Rolf Eike Beer wrote:
>>    =20
>>> Kasper Sandberg wrote:
>>>  =20
>>>
>>> Is there any chance this helps with the famous 8101 problems, e.g.=20
>>> http://bugzilla.kernel.org/show_bug.cgi?id=3D6807 ?
>>>
>>>  =20
>>>
>>> There is a typo in the description of 91ba1a976c214766b5ee8c6d1708690=
3c10f6405=20
>>> (serie should be series I think).
>>>
>>> Greetings,
>>>
>>> Eike
>>>  =20
>>>      =20
>
>  =20

--=20
Mario Limonciello
*Dell | Linux Engineering*
mario_limonciello@dell.com


--------------enig6F47E8A78D3EE8353B3980CB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFIe7532CrZjkA73YsRAraMAJ4i/ObSrImGQLeocK3RvHjTdNUcmQCfV3mA
swvyUokfvf12f8yNrKLinz0=
=OKhW
-----END PGP SIGNATURE-----

--------------enig6F47E8A78D3EE8353B3980CB--
