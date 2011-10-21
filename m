From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#645308: tg3 broken for NetXtreme 5714S in squeeze 6.0.3
 installer
Date: Fri, 21 Oct 2011 13:19:39 +0100
Message-ID: <1319199579.2918.42.camel@deadeye>
References: <20111017134430.GJ22096@torres.zugschlus.de>
	 <20111017135137.GB4647@elie.hsd1.il.comcast.net>
	 <20111017135457.GL22096@torres.zugschlus.de>
	 <1318861800.3340.21.camel@deadeye>
	 <20111017144825.GM22096@torres.zugschlus.de>
	 <20111017160812.GL3366@decadent.org.uk> <1318901100.3340.36.camel@deadeye>
	 <20111018142056.GF29261@torres.zugschlus.de>
	 <1319084914.23980.96.camel@deadeye>
	 <20111021090046.GA13930@torres.zugschlus.de>
	 <20111021090811.GA5993@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-q78tLLgbfx7xkm6p+b3n"
Cc: 645308@bugs.debian.org, Marc Haber <mh+debian-bugs@zugschlus.de>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56632 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754105Ab1JUMUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 08:20:05 -0400
In-Reply-To: <20111021090811.GA5993@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-q78tLLgbfx7xkm6p+b3n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-10-21 at 11:08 +0200, Marc Haber wrote:
> On Fri, Oct 21, 2011 at 11:00:46AM +0200, Marc Haber wrote:
> > On Thu, Oct 20, 2011 at 05:28:34AM +0100, Ben Hutchings wrote:
> > > I don't see any changes that would obviously change the way this devi=
ce
> > > is reconfigured during a down/up cycle.  There were some changes to
> > > power management that should just let the PCI core do some work that =
the
> > > driver used to, but it's possible that the result isn't quite the sam=
e.
> > > I built a module with those reverted; source and binary attached.  Co=
uld
> > > you test that?  I checked that d-i does include an insmod command.
> >=20
> > The squeeze 6.0.3 installer with the shipped tg3.ko replaced with
> > yours boots and networks just fine without any workaround and without
> > manual interaction.
>=20
> I was a bit fast on that. The interface now fails right in the middle
> of installation and needs the modprobe -r, modprobe stunt to network
> again.

Matt, Michael,

The tg3 driver has regressed for the 5714S since Linux 2.6.32.  Marc
Haber found this in the backported version included in our stable
update, but also confirmed it in Linux 3.0.

Bringing the interface down and then up again (which the installer does
for some reason) can leave it unable to pass traffic (possibly after
working for a few packets) until the module is reloaded.

I asked Marc to check whether reverting the power management changes
(071697e2bcd8dff2af4d6fdd6525c2324f89553b,
d237d9ecf06a00f0ebca657958cf2a1e92940796) made a difference, but it
doesn't seem to.

There is more information in the bug log at
<http://bugs.debian.org/645308>.

Ben.

--=20
Ben Hutchings
Unix is many things to many people,
but it's never been everything to anybody.

--=-q78tLLgbfx7xkm6p+b3n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATqFjW+e/yOyVhhEJAQoooRAAg/kMS4iKSNN435CBpzIPGhvedgvig82Y
4PoET7QKXAbD86S6DElGt+E2x8pfk4CY32rpFKg/LItf+s9rDwfkq/LMdmQaY3u5
a2tovwlH9s/PwG9oQOUeZgMmOnD/O+qeHFlroKnT0luB3Vgof1tvTcpL3MnAFBh/
8yD/TUUm5VSDumP8KRQhYtEruZJI100d5sZfGeXajnWPeh+eB03M11BJ3Uft3R6z
FdtMP2LT8kgHytxvU4JGbf8Y1DLuK/39xwC7Ms4PMjxlbOORB6p058/nKoe3scmw
ksYHSBpWyy3ghxSwR9AqyaPHTbEEVkZL1dzRyx25fsb2kZ25oLPC9hKfV5+MQDdJ
gwa5sWU1vAQBVeLsuE/Vu6rP2eZFbjYbo+vpWMUvg8scqSwi8ypzjYCZGbqpwimk
PcjrGxuRXFD+vDTBfakYJAnTHM6jUJyU0Ptb8h+W8Wm7wxEmRKX76VvTelnB+AsO
le29mCTOU/kBHZZd6Fu2FI0waAfUw4w5ff2GEdG/jXkH5wjR7xEaMCPQ+TPy9c27
AolY1cn7tIwgsZqLHyuEEO0OzHld7i6BSXWaUEizWO6IrwUFarcF34s+YnVftr0N
6HenqZ3fCiHcIpeScHdjVYqbjj4/kv8KY0KuZ3BvONxoiPS4u3hw5FHwWTJTIrSN
tGSJuOAs+Oo=
=boxm
-----END PGP SIGNATURE-----

--=-q78tLLgbfx7xkm6p+b3n--
