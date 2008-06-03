From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [linux-pm] [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan
	problems
Date: Tue, 3 Jun 2008 19:30:13 +0200
Message-ID: <20080603173013.GA9490@yamamaya.is-a-geek.org>
References: <20080603061618.GB9301@yamamaya.is-a-geek.org> <Pine.LNX.4.44L0.0806031002510.2363-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Brownell <david-b@pacbell.net>,
	linux-acpi@vger.kernel.org, linux-pm@lists.linux-foundation.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:34801 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758216AbYFCRao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 13:30:44 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.0806031002510.2363-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Stern wrote:
> > > Also, you should run "lspci -vv" as root to see what wakeup signa=
ls the=20
> > > USB controllers are issuing.
[...]
> > 00:02.1 USB Controller: nVidia Corporation MCP55 USB Controller (re=
v a2) (prog-if 20 [EHCI])
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
> > 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
- Stepping- SERR- FastB2B- DisINTx-
> > 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <=
TAbort- <MAbort- >SERR- <PERR- INTx-
> > 	Latency: 0 (750ns min, 250ns max)
> > 	Interrupt: pin B routed to IRQ 20
> > 	Region 0: Memory at fe02e000 (32-bit, non-prefetchable) [size=3D25=
6]
> > 	Capabilities: [44] Debug port: BAR=3D1 offset=3D0098
> > 	Capabilities: [80] Power Management version 2
> > 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3ho=
t+,D3cold+)
> > 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME+
> > 	Kernel driver in use: ehci_hcd
>=20
> The EHCI controller settings, however, are strange.  The relevant par=
t=20
> is the Power Management Status line near the end:
>=20
> > 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME+
>=20
> This means the controller is in the D0 state (as expected) and=20
> PME-Enable is currently turned off ("PME" stands for "Power Managemen=
t=20
> Event").  But the PME+ at the end means that as soon as PME does get=20
> enabled -- like when the controller is suspended at the start of a=20
> system sleep -- it _will_ send a PME signal.
>=20
> So for some reason your EHCI controller thinks a wakeup event is=20
> pending.  This means you should examine the contents of the "register=
s"=20
> file in the debugfs directory for the EHCI controller, not OHCI.

melchior:/mnt/ehci/0000:00:02.1# cat registers
bus pci, device 0000:00:02.1 (driver 10 Dec 2004)
EHCI Host Controller
EHCI 1.00, hcd state 1
ownership 00000001
SMI sts/enable 0xc0080000
structural params 0x00101a8a
capability params 0x0000a086
status 0008 FLR
command 010009 (park)=3D0 ithresh=3D1 period=3D256 RUN
intrenable 37 IAA FATAL PCD ERR INT
uframe 3f3a
port 1 status 003400 POWER OWNER sig=3Dk
port 2 status 001000 POWER sig=3Dse0
port 3 status 003400 POWER OWNER sig=3Dk
port 4 status 003400 POWER OWNER sig=3Dk
port 5 status 001000 POWER sig=3Dse0
port 6 status 001000 POWER sig=3Dse0
port 7 status 001000 POWER sig=3Dse0
port 8 status 001000 POWER sig=3Dse0
port 9 status 001000 POWER sig=3Dse0
port 10 status 001000 POWER sig=3Dse0
irq normal 0 err 0 reclaim 0 (lost 0)
complete 0 unlink 0

HTH,

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
