From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Fri, 20 Mar 2009 09:32:47 +0100
Message-ID: <1237537967.5100.135.camel@johannes.local>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <1237140665.24621.2.camel@johannes.local>
	 <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain>
	 <1237143683.24621.7.camel@johannes.local> <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <1237317742.31814.28.camel@johannes.local>
	 <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com>
	 <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com>
	 <1237455534.5100.56.camel@johannes.local>
	 <b6a2187b0903192155q33510b57l9d5927538a0f4f99@mail.gmail.com>
	 (sfid-20090320_055547_445634_00B01F23)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-X8kIeZ0Q9dD6TiLoV7mh"
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Jeff Chua <jeff.chua.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:41166 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755721AbZCTIeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:34:02 -0400
In-Reply-To: <b6a2187b0903192155q33510b57l9d5927538a0f4f99@mail.gmail.com> (sfid-20090320_055547_445634_00B01F23)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-X8kIeZ0Q9dD6TiLoV7mh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-03-20 at 12:55 +0800, Jeff Chua wrote:

> >> # this needs patch to work ...
> >> iwconfig wlan0 mode Managed
> >> ifconfig wlan0 up
> >> iwconfig wlan0 essid xxx
> >> iwconfig wlan0 key restricted xxx
> >> iwconfig wlan0 ap auto channel auto
> >
> > If you swap the key and essid lines, it will probably always work. But
> > I've yet to analyse your data to see why it doesn't in the other case.
>=20
> Doesn't. Taking away "hiwconfig wlan0 ap auto channel auto" makes it work=
s.

That's a little weird, but not entirely, you probably manage to cut it
short in the middle of the assoc process when issuing the auto command.

> It seems position of "ifconfig wlan0 up" matters
>=20
> 1) It can't be before iwconfig which will result in "SET failed on
> device wlan0 ; Device or resource busy".
>=20
> 2) _Before_ "essid" and "key" settings. "ap auto channel auto" MUST
> NOT BE SET.
>=20
> 3) _After_ "essid" and "key". Ensure all iwconfig settings comes
> before "ifconfig".
>=20
>=20
> So, it seems "ifconfig" must be done as the last stage.

This, however, is completely strange. You should always set the
interface up before doing anything with it. wext allows you to do it the
other way around, but that's not quite natural since without it being up
you cannot even scan.

However, -EBUSY isn't returned anywhere in mac80211, and I don't see the
driver passing it out either. So your point 1) confuses me. Can you
explain that a little more?

As for 2), that is very very strange since ap auto channel auto is the
default, so saying that before you do anything else should do anything
at all.

I suspect something is going on in the driver because the ifconfig order
matters and for mac80211, it shouldn't make a difference when the state
machine is really started. I'll probably need to try to reproduce this,
but to be honest between the varying failure modes, undefined wireless
extensions semantics, etc. I'm not very confident I can.

johannes

--=-X8kIeZ0Q9dD6TiLoV7mh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJw1StAAoJEKVg1VMiehFYc9oP/jcc0X9IcGTCrWDV5FNEbuPr
EjE0MYr9reTRJTuAP6GxwOXO4cY/DVrcaPaRGIUzath0ZkS5TMuxD3aHR353on6E
+v8ple+MpESUQSc5Uq8ugl+/RzrHT/uYdv3QqITvJp4w7FFtlocJCnjynjgG1zWl
Sp7nClB9oXe+v6cTxCqvIwPuNee7VPCIN3sUai5bxMxIqMVUQE/bV/L6OFSF6wZR
fxtFH2t04l6eakzECOdnLQSSj0arQywLywRAUoTp6FR0gksg20/CEcWbe47fXL8h
EHpUw2vVPLqM62F4VdHxH81LZdQJbVFCXfZuMDEwnYuivrKICMvXhRWYmVPCDg0X
BcGyxe3LiH4JzGBixAT9KVKHsLcG/410Djrx6uMc1CGk9ZIZLueWTO3rTC0W5tAq
iV6msuqTksB9uGSLoty8Fh1ZzGwUcW/+3AtTkNxAkXtl3QeeOnHg2/pWtzBHr/Py
EqmeIUcBaphnLDlSh2AUImPpaOwx7co2x/bqWQd6vQAQxO3w689ddTI2AhIAfo4h
p+2Z8XmCji7/88cOCMf21TS0bldnGjojOocYivj855PAEDH5UClZeGLHde7x+JCE
42sKNI1jmVH0QugyMX76QrtRww0qk93/4jq24LptBnlH5JCBnoi6aJNp8zwjxBhb
2vKHg2GcoVgY1tAJGgAJ
=Mcbp
-----END PGP SIGNATURE-----

--=-X8kIeZ0Q9dD6TiLoV7mh--

