From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Thu, 19 Mar 2009 17:59:21 +0100
Message-ID: <1237481961.5100.98.camel@johannes.local>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com>
	 <1237140665.24621.2.camel@johannes.local>
	 <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain>
	 <1237143683.24621.7.camel@johannes.local> <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <1237317742.31814.28.camel@johannes.local>
	 <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com>
	 <b6a2187b0903182025y5552900cu6213a4f4eafeb6e6@mail.gmail.com>
	 <b6a2187b0903182123s4371c67ep7a98f081d12b8e02@mail.gmail.com>
	 (sfid-20090319_052309_885717_7A3A63CE)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-pxGy+Al2gKv6l5487tUN"
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
Received: from xc.sipsolutions.net ([83.246.72.84]:58458 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757603AbZCSSAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 14:00:35 -0400
In-Reply-To: <b6a2187b0903182123s4371c67ep7a98f081d12b8e02@mail.gmail.com> (sfid-20090319_052309_885717_7A3A63CE)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pxGy+Al2gKv6l5487tUN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-03-19 at 12:23 +0800, Jeff Chua wrote:

> *** this is in nopatch.fail ***
>=20
> 2009-03-19T12:07:22.437578+08:00 boston kernel: ieee80211 phy0: U
> iwl_bg_request_scan Start direct scan for 'sdg2088a88'
>=20
> 2009-03-19T12:07:24.337644+08:00 boston kernel: ieee80211 phy0: U
> iwl_bg_request_scan Start indirect scan.
>=20
>=20
> For the passing run, it's always "direct scan".

That's because of your 'iwlist wlan0 scan' command, it triggers an
indirect scan, if you did 'iwlist wlan0 scan essid sdg2088a88' you would
get a direct scan there. It's always 'direct' for when it passes because
then you don't get to the point where you scan again, I think.

All in all, I don't see much in the logs, it seems to be behaving
properly and asking for a direct scan when you set the essid. The kernel
will not try to connect to an encrypted network before you give it a
key, but "iwconfig wlan0 ap any" should trigger the association
process...

Can you do something else for me?

Get iw (some distros ship it, or see wireless.kernel.org) and enter this
command:
	iw dev wlan0 interface add moni0 type monitor flags none

Then,
	ip link set moni0 up

Start a capture:
	iwevent > /tmp/event.txt

Now do, in a separate shell:
	iwconfig wlan0 essid ...
	iwconfig wlan0 key ...

_Now_ start tcpdump:
	tcpdump -i moni0 -s 10000 -w /tmp/dump.pkt

and in a separate shell do:
	iwlist wlan0 scan last > /tmp/scan.txt ; iwconfig wlan0 ap any

(this is important in one command so it's timed closed together)

Send me the contents of all the files from a failed run please.

johannes

--=-pxGy+Al2gKv6l5487tUN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJwnnmAAoJEKVg1VMiehFY7j8P/0DtN335lFRGrXmdLP4DY8Ih
fgoYY0hKxLgT1AnQxpUNsdn0TX6BRovRD+fwsP9Y1ThO3XYLPBe9fjT0Vt23l24+
YwawUaqdFXLLtKbLjO7fS6CJvIaijqgra5TMNVfya7WLgWHiNVigPjXEJ+7x+/c7
DBaJWoDLwGpK4HT3WTfBb208+unMtOZejBnvboZ5aQWJ2YGIN9/pYT60Xo2c3pSS
J0WwojwxPvgW0Xm1qvPC7S4heI310rXfbJct91Ehz44LwpmvhY7665Jn3VCf76mk
H4A9EaVYF5ylWbZ+ZySxCUaLKE0z+NmfAb4JCcK64rF8p+KhLbPoAoXxRqQfXbkn
KOR/fnuhdsG4QVTjpYbiPjMTv7yWk8sXP0HQ1FtnJ/hhxkFUnlNZsOwQH8w+qtEU
ap6jaHewQB/LU6Huzhgb/S3I0BHo5X56GomWn87kiCHFPBaCqwvUlGh0Spr12+fE
K3RZLOPq9P2ld6kAM4i8QYX2ZXyc34ApL9/OCC9slhI38GgjyEjOQlBOG2H2pskJ
vzPrxtkjUjohqPhCTq6cKC+bQoinlR5YoznC5p6YVZ24qIf+jY1HhmMoFEVpb4pa
fylEY67dFmZBxyeGXeIbBcTx0fEe/9/UkOps721NqgtA6ztNBxzV7TY/jFvZmuP0
mkAd3sIhO23uu7lzXUhj
=fiih
-----END PGP SIGNATURE-----

--=-pxGy+Al2gKv6l5487tUN--

