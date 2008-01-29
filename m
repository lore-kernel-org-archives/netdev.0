From: Erik Mouw <mouw@nl.linux.org>
Subject: Lots of "BUG eth1 code -5 qlen 0" messages in 2.6.24
Date: Tue, 29 Jan 2008 19:47:26 +0100
Message-ID: <20080129184726.GA29300@gateway.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LZvS9be/3tNcYl/X"
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr1.xs4all.nl ([194.109.24.21]:2069 "EHLO
	smtp-vbr1.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbYA2Sz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 13:55:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

I've just started to use 2.6.24 on my home firewall (before it was
running 2.6.24-rc2 for about 65 days) and I noticed a couple of error
messages I've never seen before:

Jan 29 07:50:54 gateway kernel: BUG eth1 code -5 qlen 0
Jan 29 08:28:30 gateway kernel: BUG eth1 code -5 qlen 0
Jan 29 08:57:30 gateway kernel: BUG eth1 code -5 qlen 0
Jan 29 09:44:04 gateway kernel: BUG eth1 code -5 qlen 0
Jan 29 10:01:35 gateway kernel: BUG eth1 code -5 qlen 0
Jan 29 10:01:35 gateway last message repeated 2 times
Jan 29 10:16:48 gateway kernel: BUG eth1 code -5 qlen 0
Jan 29 10:16:48 gateway last message repeated 2 times
Jan 29 10:45:48 gateway kernel: BUG eth1 code -5 qlen 0
Jan 29 10:45:48 gateway last message repeated 2 times
Jan 29 11:10:01 gateway kernel: BUG eth1 code -5 qlen 0
Jan 29 11:10:02 gateway last message repeated 9 times

The message seems to be coming from the qdisc_restart() in
net/sched/sch_generic.c which was changed with commit
5f1a485d5905aa641f33009019b3699076666a4c .

The NIC is an IBM EtherJet cardbus card using the xircom_cb driver:

05:00.0 Ethernet controller: Xircom Cardbus Ethernet 10/100 (rev 03)
        Subsystem: IBM 10/100 EtherJet Cardbus Adapter
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
        ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium
        >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (5000ns min, 10000ns max)
        Interrupt: pin A routed to IRQ 11
        Region 0: I/O ports at 1800 [size=3D128]
        Region 1: Memory at 2c000000 (32-bit, non-prefetchable)
        [size=3D2K]
        Region 2: Memory at 2c000800 (32-bit, non-prefetchable)
        [size=3D2K]
        [virtual] Expansion ROM at 28000000 [disabled] [size=3D16K]
        Capabilities: [dc] Power Management version 1
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2=
+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D2 PME-
00: 5d 11 03 00 07 00 10 02 03 00 00 02 00 40 00 00
10: 01 18 00 00 00 00 00 2c 00 08 00 2c 00 00 00 00
20: 00 00 00 00 00 00 00 00 07 01 00 00 14 10 81 81
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0b 01 14 28

PCI: Enabling device 0000:05:00.0 (0000 -> 0003)
ACPI: PCI Interrupt 0000:05:00.0[A] -> Link [LNKB] -> GSI 11 (level, low) -=
> IRQ 11
PCI: Setting latency timer of device 0000:05:00.0 to 64
eth1: Xircom cardbus revision 3 at irq 11

Question is: do I need to worry about these messages or are they
harmless?


Erik

--=20
They're all fools. Don't worry. Darwin may be slow, but he'll
eventually get them. -- Matthew Lammers in alt.sysadmin.recovery

--LZvS9be/3tNcYl/X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHn3S+/PlVHJtIto0RApT6AJ0Wlf1Lp4F9roXuPAHoBdG5BTsZHgCcC7sz
M730as/mHoQhW1k/UCHJOj8=
=EluA
-----END PGP SIGNATURE-----

--LZvS9be/3tNcYl/X--
