From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 28 May 2007 22:55:46 +0200
Message-ID: <200705282255.56490.maxi@daemonizer.de>
References: <20070525172431.60affaca@freepuppy> <200705281944.05030.maxi@daemonizer.de> <1180380230.3657.3.camel@chaos>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1755595.g61BcoufYt";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.16.230]:39808 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490AbXE1U4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 16:56:44 -0400
In-Reply-To: <1180380230.3657.3.camel@chaos>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1755595.g61BcoufYt
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 28 May 2007, Thomas Gleixner wrote:
> On Mon, 2007-05-28 at 19:44 +0200, Maximilian Engelhardt wrote:
> > > Can you please keep CONFIG_HIGH_RES_TIMERS and CONFIG_NOHZ and try the
> > > following combinations on the kernel command line:
> > >
> > > 1) highres=3Doff nohz=3Doff (should be the same as your working confi=
g)
> > > 2) highres=3Doff
> > > 3) nohz=3Doff
> >
> > I tested this with my 2.6.22-rc3 kernel, here are the results:
> >
> > without any special boot parameters: problem does appear
> > highres=3Doff nohz=3Doff: problem does not appear
> > highres=3Doff: problem does not appear
> > nohz=3Doff: problem does appear
>
> Is there any other strange behavior of the high res enabled kernel than
> the b44 problem ?

I didn't notice anything.

>
> > I additionally built my 2.6.22-rc2-mm1 kernel without High Resolution
> > Timer, but the high ping problem is still there.
>
> Hmm, that's mysterious. Wild guess is that highres exposes the hidden
> "feature" in a different way than rc2-mm1 does.

I think the bug in 2.6.21/22-rc3 is a different one that the one in=20
2.6.22-rc2-mm1, but that's also only a wild guess :)

I'll explain this a bit:
In 2.6.21/22-rc3 is the same b44 driver that has been in the stock kernels =
for=20
some time. With this driver and High Resolution Timer turned on I get=20
problems using iperf. The problems are that the systems becomes really slow=
=20
and unresponsive.  Michael Buesch thought this could be an IRQ storm which=
=20
sounds logical to me. This bug did never happen to me before I startet the=
=20
iperf test.

The other issue happens only with 2.6.22-rc2-mm1 which includes the b44 ssb=
=20
spilt. It's independed wether High Resolution Timer is turned on or off I=20
always get very varying and high ping times. The iperf-test doesn't show th=
e=20
problems from 2.6.21/22-rc3.

Maxi

--nextPart1755595.g61BcoufYt
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGW0HcOimwv528XGERAjPfAJ9EUNLUXjxAFnid3vcXhWQj8dTVnQCeJIQ9
uISFyuLmxhfgJnmcR71RtAI=
=exhi
-----END PGP SIGNATURE-----

--nextPart1755595.g61BcoufYt--
