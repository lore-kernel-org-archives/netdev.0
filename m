From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Wed, 2 Dec 2009 16:44:03 +0100
Message-ID: <20091202154403.GB30730@sd-11162.dedibox.fr>
References: <20091128010156.1219012a@houba> <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi> <20091130195004.38dbc319@houba> <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi> <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba> <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:54329 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644AbZLBPuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 10:50:23 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 02, 2009 at 02:59:20PM +0200, Ilpo J=E4rvinen wrote:
> On Wed, 2 Dec 2009, Frederic Leroy wrote:
>=20
> > Le Tue, 1 Dec 2009 22:27:01 +0200 (EET),
> > "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> a =E9crit :
> What is directly inferrable from the logs: Losses happen. RTO is trig=
gered=20
> for the first time (for some reason also fast retransmit is missing a=
nd it=20
> most likely it should have preceeded RTO), however, the retransmissio=
n=20
> that RTO should make is never captured into the tcpdump. Then when RT=
O=20
> triggers for the second time, the connection silently dies immediatel=
y and=20
> consistently for some reason. ...From that point on resets are sent i=
f the=20
> peer keeps trying.

If you want, I can add printk when a rto is made, in order to compare w=
ith tcpdump.

> > > I wonder if you have had some working (past) kernel version?
> > I tried a 2.6.31, and it seems to work. If it really work (connecti=
on
> > don't stall everytime at the moment), I'll try to make a "git bisec=
t"
> > asap.

I can confirm now that 2.6.31 works well.

I made a little change during the test :=20
Instead of launching scp on sg, I launched it from houba.
The scp command return then  to bash with an error, without stalling.
Which appears to me logical because the connection is killed from houba=
 point of view.
=20
> In one of the cases, also the sg end dies (the 4th case). I suppose t=
hat=20
> was running earlier kernel already?

This case was the one with tcp_frto=3D2 and tcp_timestamps=3D0 on houba=
=2E

I only rebooted sg two days ago. It still 2.6.32-rc5. Nothing had been =
changed on this host during all tests.
tcp_frto=3D2
tcp_timestamps=3D1

--=20
=46r=E9d=E9ric Leroy
