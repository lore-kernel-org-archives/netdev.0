From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] SSB / B44: fix WOL for BCM4401
Date: Tue, 2 Dec 2014 21:12:11 +0100
Message-ID: <20141202211211.7e08b935@wiggum>
References: <20141201111125.GA11974@localhost.localdomain>
	<1417466798-15735-1-git-send-email-Andrej.Skvortzov@gmail.com>
	<20141201221023.79ffb40d@wiggum>
	<20141202200129.GA4580@crion89>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/KgW+yCt0KOyVeLsvDfBVbb3"; protocol="application/pgp-signature"
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Gary.Zambrano@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	b43-dev <b43-dev@lists.infradead.org>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Andrey Skvortsov <andrej.skvortzov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141202200129.GA4580@crion89>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/KgW+yCt0KOyVeLsvDfBVbb3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, 2 Dec 2014 23:01:29 +0300
Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:

> On Mon, Dec 01, 2014 at 10:10:23PM +0100, Michael B=C3=BCsch wrote:
> > On Mon,  1 Dec 2014 23:46:38 +0300
> > Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:
> >=20
> > > Wake On Lan was not working on laptop DELL Vostro 1500.
> > > If WOL was turned on, BCM4401 was powered up in suspend mode. LEDs bl=
inked.
> > > But the laptop could not be woken up with the Magic Packet. The reaso=
n for
> > > that was that PCIE was not enabled as a system wakeup source and
> > > therefore the host PCI bridge was not powered up in suspend mode.
> > > PCIE was not enabled in suspend by PM because no child devices were
> > > registered as wakeup source during suspend process.
> > > On laptop BCM4401 is connected through the SSB bus, that is connected=
 to the
> > > PCI-Express bus. SSB and B44 did not use standard PM wakeup functions
> > > and did not forward wakeup settings to their parents.
> > > To fix that B44 driver enables PM wakeup and registers new wakeup sou=
rce
> > > using device_set_wakeup_enable(). Wakeup is automatically reported to=
 the parent SSB
> > > bus via power.wakeup_path. SSB bus enables wakeup for the parent PCI =
bridge, if there is any
> > > child devices with enabled wakeup functionality. All other steps are
> > > done by PM core code.
> >=20
> > Thanks, this looks good.
> > I assume you tested this (I currently don't have a device to test this).
>=20
> Sure, I've tested it. WOL from suspend is working and after resume from h=
ibernate Ethernet is working too.

That sounds good, indeed.
I'd still prefer, if someone with b43 (wireless) would test it, too.

--=20
Michael

--Sig_/KgW+yCt0KOyVeLsvDfBVbb3
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUfh0hAAoJEPUyvh2QjYsOcnUP/3n1QQK1TWvMvKKpTZgU18hR
eEyxRP+/jtSWnInzRwkXUM39rdNCTWkBdinpNlS67lAxoC3OoLJ+vYn+O38Owmva
Kj49MAFj8MQ3Zfl8OO82/O54FZzW+Umv7yne6twRHm8M57I5F/oolrgWiHlSbQj6
a38s1SQESH7JJhVMwzBwDXm/H6Z5upURfJ155XhGo1GsEV4hr00okPSt6EWLLQNX
xPmU1C9Ev4UmwhwABsxmRb7wdZhkpb5JUCi5zAh2YAypEng95VDTwC/aRaSQRsNJ
AcBMhP+PFJsZXJL9WcnhfcltOwx2u5bVXGyAm0E+Ca3ALNlR65TNeAeCz5k/vQex
xiNOSZb7K/SjOB6YISyj6ngKY0aLS1oUEay9uX9P6F4A7sscdgg91ZVWxc3nZpJa
HSUCkWtTGx5u1Ck4zSCgmrFAYZuzW6K9ES4CFknWuHYg/5WC0JVD41HhwK7D1Vy8
iH18M5nk9YINAle8NxX0FkACLTP+fPnzHhZ2C02n5S6lbzFV3Y0c9U5gav4Uy9jp
o1YbQonpX5WEnzWfdWD+uW+3YNatf3sP5Yl057InSMDnIaKAA5YxUgLHhvXNG0vc
19sL7Bt4TJILb1RxjYoPelfuauWQCsRmuqLqB3n/fwaUdpP/TVaA/3rH0T3abPwR
dEPyqbxyLcmgcRgGeQPv
=DYTK
-----END PGP SIGNATURE-----

--Sig_/KgW+yCt0KOyVeLsvDfBVbb3--
