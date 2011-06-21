From: Carsten Wolff <carsten@wolffcarsten.de>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 21 Jun 2011 13:34:16 +0200
Message-ID: <201106211334.17825.carsten@wolffcarsten.de>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com> <D0D2412D-2D30-4051-B346-32D20858BC92@nets.rwth-aachen.de> <alpine.DEB.2.00.1106211423400.17529@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Zimmermann <zimmermann@nets.rwth-aachen.de>,
	Dominik Kaspar <dokaspar.ietf@gmail.com>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: "Ilpo =?utf-8?q?J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1346787.stratoserver.net ([85.214.49.182]:32981 "EHLO
	h1346787.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab1FULk1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 07:40:27 -0400
In-Reply-To: <alpine.DEB.2.00.1106211423400.17529@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tuesday 21 June 2011, Ilpo J=C3=A4rvinen wrote:
> On Wed, 27 Apr 2011, Alexander Zimmermann wrote:
> > Am 27.04.2011 um 18:22 schrieb Dominik Kaspar:
> > > Hi Carsten,
> > >=20
> > > Thanks for your feedback. I made some new tests with the same set=
up of
> > > packet-based forwarding over two emulated paths (600 KB/s, 10 ms)=
 +
> > > (400 KB/s, 100 ms). In the first experiments, which showed a step=
-wise
> > > adaptation to reordering, SACK, DSACK, and Timestamps were all
> > > enabled. In the experiments, I individually disabled these three
> > > mechanisms and saw the following:
> > >=20
> > > - Disabling timestamps causes TCP to never adjust to reordering a=
t all.
> >=20
> > Reordering detection with DSACK is broken in Linux. We will fix tha=
t in
> > a couple of weeks...
> >=20
> > > - Disabling SACK allows TCP to adapt very rapidly ("perfect"
> > > aggregation!).
> >=20
> > If you disable SACK, you will use the NewReno detection
>=20
> Which probably has some reordering over-estimate bugs on its own...
> (but I've forgotten details of my suspicion long time ago so please d=
on't
> ask for the them).

the NewReno detection is clever, but there's no exact information it co=
uld=20
utilize for a good metric, because it detects the event too late, when =
the=20
information is already gone. In my experiments it always under-estimate=
d the=20
reordering extent, though. I also remmember thinking that the metric of=
 the=20
Eifel-detection has an off-by-one bug.

Carsten
