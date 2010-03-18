From: =?utf-8?Q?J=F6rn?= Engel <joern@dublin.logfs.org>
Subject: Re: [Regression] r8169: enable 64-bit DMA by default for PCI
	Express devices (v2)
Date: Thu, 18 Mar 2010 10:03:08 +0100
Message-ID: <20100318090308.GA3697__25844.9814202779$1268903023$gmane$org@Dublin.logfs.org>
References: <20100315150806.GA15354@Dublin.logfs.org> <20100315151041.GA15667@Dublin.logfs.org> <20100315.115748.13754030.davem@davemloft.net> <51f3faa71003151628g5edc4d7av8916ac76cb337bfe@mail.gmail.com> <20100316083501.GA3489@Dublin.logfs.org> <20100317205206.GA2699@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Francois Romieu <romieu@fr.zoreil.com>,
	Robert Hancock <hancockrwd@gmail.com>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.183.11.32] ([85.183.11.32]:54150 "EHLO Dublin.logfs.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751171Ab0CRJDV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 05:03:21 -0400
Content-Disposition: inline
In-Reply-To: <20100317205206.GA2699@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 March 2010 21:52:06 +0100, Francois Romieu wrote:
> On Tue, Mar 16, 2010 at 09:35:01AM +0100, J=EF=BF=BDrn Engel wrote:
> [...]
> > I just noticed lspci is also unhappy.
> >=20
> > With patch in:
> > Bikini:~# lspci -vv > lspci
> > pcilib: sysfs_read_vpd: read failed: Connection timed out.
> >
> > With patch reverted:
> > Bikini:~# lspci -vv > lspci2
> > Bikini:~# diff -u lspci*
> > --- lspci       2010-03-16 09:03:02.000000000 +0100
> > +++ lspci2      2010-03-16 09:09:36.000000000 +0100
> > @@ -246,7 +246,7 @@
> >                 Vector table: BAR=3D4 offset=3D00000000
> >                 PBA: BAR=3D4 offset=3D00000800
> >         Capabilities: [cc] Vital Product Data
> > -               Not readable
> > +               Unknown small resource type 00, will not decode mor=
e.
>=20
> Neither looks good.

Agreed.

> Did lspci output look different with an older kernel ?

Yes.  The relevant hunk is this one.  Different obviously doesn't
mean better. :)

@@ -223,7 +221,7 @@
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0+,=
D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst+ PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
        Capabilities: [50] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
-               Address: 00000000fee0300c  Data: 4169
+               Address: 00000000fee0300c  Data: 4179
        Capabilities: [70] Express (v2) Endpoint, MSI 01
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s =
<512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-

And for completeness he is the full diff.  The machine was bought on
16 Jun 2009, so this is the oldest kernel I have.  If you want any
specific kernels tested, please tell me which ones.

Bikini:~# uname -a
Linux Bikini 2.6.31-rc2 #193 SMP Sun Mar 14 17:00:08 CET 2010 x86_64 GN=
U/Linux
Bikini:~# lspci -vv > lspci3
Bikini:~# diff -u lspci[23]
--- lspci2      2010-03-16 09:09:46.000000000 +0100
+++ lspci3      2010-03-18 09:49:21.000000000 +0100
@@ -24,14 +24,12 @@
                Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
=20
 00:1c.0 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express=
 Port 1 (rev 01) (prog-if 00 [Normal decode])
-       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
+       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latenc=
y=3D0
-       I/O behind bridge: 00001000-00001fff
-       Memory behind bridge: bf700000-bfafffff
        Prefetchable memory behind bridge: 00000000fdf00000-00000000fdf=
fffff
-       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
+       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
@@ -56,14 +54,14 @@
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
        Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
-               Address: fee0300c  Data: 4149
+               Address: fee0300c  Data: 4159
        Capabilities: [90] Subsystem: ASRock Incorporation Device 27d0
        Capabilities: [a0] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1=
-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
        Capabilities: [100] Virtual Channel <?>
        Capabilities: [180] Root Complex Link <?>
-       Kernel driver in use: pcieport
+       Kernel driver in use: pcieport-driver
=20
 00:1c.1 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express=
 Port 2 (rev 01) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR+ FastB2B- DisINTx+
@@ -98,14 +96,14 @@
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
        Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
-               Address: fee0300c  Data: 4151
+               Address: fee0300c  Data: 4161
        Capabilities: [90] Subsystem: ASRock Incorporation Device 27d2
        Capabilities: [a0] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1=
-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
        Capabilities: [100] Virtual Channel <?>
        Capabilities: [180] Root Complex Link <?>
-       Kernel driver in use: pcieport
+       Kernel driver in use: pcieport-driver
=20
 00:1d.0 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHC=
I Controller #1 (rev 01) (prog-if 00 [UHCI])
        Subsystem: ASRock Incorporation Device 27c8
@@ -223,7 +221,7 @@
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0+,=
D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst+ PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
        Capabilities: [50] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
-               Address: 00000000fee0300c  Data: 4169
+               Address: 00000000fee0300c  Data: 4179
        Capabilities: [70] Express (v2) Endpoint, MSI 01
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s =
<512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
