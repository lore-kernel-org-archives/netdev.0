From: Libor =?utf-8?q?Klep=C3=A1=C4=8D?= <libor.klepac@bcom.cz>
Subject: r8169 and region #2 not an MMIO resource
Date: Wed, 1 Nov 2006 22:21:42 +0100
Message-ID: <200611012221.46981.libor.klepac@bcom.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1803977.pI402ZxuCN";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.webx.cz ([82.208.12.1]:25768 "EHLO mail.webx.cz")
	by vger.kernel.org with ESMTP id S1752446AbWKAVVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 16:21:55 -0500
Received: from localhost (ns.webx.cz [127.0.0.1])
	by mail.webx.cz (Postfix) with ESMTP id 44E8F41C1C3
	for <netdev@vger.kernel.org>; Wed,  1 Nov 2006 22:21:54 +0100 (CET)
Received: from mail.webx.cz ([127.0.0.1])
	by localhost (ns.webx.cz [127.0.0.1]) (amavisd-new, port 10042)
	with ESMTP id 9cnbq+KYjaNC for <netdev@vger.kernel.org>;
	Wed,  1 Nov 2006 22:21:54 +0100 (CET)
Received: from leviathan.mugn.local (76-82-244-84.zapcechy.adsl-llu.static.bluetone.cz [84.244.82.76])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.webx.cz (Postfix) with ESMTP id 00EA441C1AB
	for <netdev@vger.kernel.org>; Wed,  1 Nov 2006 22:21:54 +0100 (CET)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1803977.pI402ZxuCN
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Good day,

i have build computer with msi MS-7235 motherboard, it has r8169 chip onboa=
rd
i'm using kernel version 2.6.18 from debian (and i also rebuild kernel with=
out=20
NAPI).
When i modprobe module , dmesg says

r8169 Gigabit Ethernet driver 2.2LK loaded
PCI: Enabling device 0000:03:06.0 (0000 -> 0003)
ACPI: PCI Interrupt 0000:03:06.0[A] -> GSI 21 (level, low) -> IRQ 201
r8169 0000:03:06.0: region #2 not an MMIO resource, aborting

lspci says (there is no region 2? )

0000:03:06.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169S=
C=20
Gigabit Ethernet (rev 10)
        Subsystem: Micro-Star International Co., Ltd.: Unknown device 235c
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=
=20
<TAbort- <MAbort- >SERR- <PERR-
        Interrupt: pin A routed to IRQ 201
        Region 0: I/O ports at cc00 [disabled] [size=3D256]
        Region 1: Memory at fd7fd000 (32-bit, non-prefetchable) [disabled]=
=20
[size=3D256]
        Expansion ROM at fde20000 [disabled] [size=3D128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA=20
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

when i build r1000 driver, dmesg says
PCI: Enabling device 0000:03:06.0 (0000 -> 0003)
ACPI: PCI Interrupt 0000:03:06.0[A] -> GSI 21 (level, low) -> IRQ 201
eth1: Identified chip type is 'RTL8169SC/8110SC'.
eth1: r10001.04, the Linux device driver for Realtek Ethernet Controllers a=
t=20
0xcc00, 00:16:17:b1:54:56, IRQ 201
Realtek RTL8169/8110 Family Gigabit Ethernet Network Adapter
Driver version:1.04
Released date:2006/07/07
Link Status:Not Linked
I/O Base:0xCC00(I/O port)
IRQ:201

and lspci output changes
0000:03:06.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169S=
C=20
Gigabit Ethernet (rev 10)
        Subsystem: Micro-Star International Co., Ltd.: Unknown device 235c
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=
=20
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (8000ns min, 16000ns max), Cache Line Size: 0x10 (64=20
bytes)
        Interrupt: pin A routed to IRQ 201
        Region 0: I/O ports at cc00 [size=3D256]
        Region 1: Memory at fd7fd000 (32-bit, non-prefetchable) [size=3D256]
        Expansion ROM at fde20000 [disabled] [size=3D128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA=20
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-


I also tried to boot with acpi=3Dnoirq and/or pci=3Dnoacpi, it doesn't help.
I tried to fetch, apply and use some patches ,which i found on=20
http://www.fr.zoreil.com/linux/kernel/ , but it doesn't help

I can play with this machine for next few days, before it's placed in housi=
ng=20
center, so if you need some more feedback, i'll try to respond

cu

libor

--nextPart1803977.pI402ZxuCN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBFSQ/qhMrxGRe1HmERAl22AJwMuGH6xQvpzXBRCqYT/H6+pR4sGQCdH+Hy
9njYiIBHV/AHks2x3GIx+iQ=
=Swhe
-----END PGP SIGNATURE-----

--nextPart1803977.pI402ZxuCN--
