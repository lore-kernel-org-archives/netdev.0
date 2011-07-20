From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: 3.0.0rc6: ethtool not working without a cable
Date: Wed, 20 Jul 2011 19:57:39 +0200
Message-ID: <201107201957.39237.a.miskiewicz@gmail.com>
References: <201107061338.08573.a.miskiewicz@gmail.com> <201107061653.04689.a.miskiewicz@gmail.com> <alpine.WNT.2.00.1107201050450.1084@JBRANDEB-DESK2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:35832 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab1GTR5o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 13:57:44 -0400
Received: by fxd18 with SMTP id 18so2098495fxd.11
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 10:57:43 -0700 (PDT)
In-Reply-To: <alpine.WNT.2.00.1107201050450.1084@JBRANDEB-DESK2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 20 of July 2011, Brandeburg, Jesse wrote:
> On Wed, 6 Jul 2011, Arkadiusz Miskiewicz wrote:
> > On Wednesday 06 of July 2011, Ben Hutchings wrote:
> > > > If there is no cable then ethtool reports no device. It wasn't =
that
> > > > before AFAIK.
> > > >=20
> > > > ethtool version 2.6.36
> > > >=20
> > > >=20
> > > > cable disconnected:
> > > >=20
> > > > [root@t400 ~]# ethtool eth0
> > > > Settings for eth0:
> > > > Cannot get device settings: No such device
> > > > Cannot get wake-on-lan settings: No such device
> > > > Cannot get message level: No such device
> > > > Cannot get link status: No such device
> > > > No data available
> > > > zsh: exit 75    ethtool eth0
> > > > [root@t400 ~]# ethtool -i eth0
> > > > Cannot get driver information: No such device
> > > > zsh: exit 71    ethtool -i eth0
>=20
> please check lspci -vvv on your device when cable is unplugged.  I'm
> wondering if OSPM (os power management) is kicking in (if enabled in =
your
> kernel) and somehow interacting badly with ethtool.
>=20
> if the device is in D3, then most ethtool stuff won't work, since all=
 the
> registers in the device (except in config space) don't work when in D=
3.

00:19.0 Ethernet controller: Intel Corporation 82567LM Gigabit Network=20
Connection (rev 03)
        Subsystem: Lenovo Device 20ee
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err-=20
Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Interrupt: pin A routed to IRQ 20
        Region 0: Memory at fc000000 (32-bit, non-prefetchable) [disabl=
ed]=20
[size=3D128K]
        Region 1: Memory at fc025000 (32-bit, non-prefetchable) [disabl=
ed]=20
[size=3D4K]
        Region 2: I/O ports at 1840 [disabled] [size=3D32]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D3 NoSoftRst- PME-Enable+ DSel=3D0 DScale=3D1 P=
ME-
        Capabilities: [d0] MSI: Enable- Count=3D1/1 Maskable- 64bit+
                Address: 00000000fee0300c  Data: 41c5
        Capabilities: [e0] PCI Advanced Features
                AFCap: TP+ FLR+
                AFCtrl: FLR-
                AFStatus: TP-
        Kernel driver in use: e1000e
        Kernel modules: e1000e


--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
