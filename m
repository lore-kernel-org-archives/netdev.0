From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Mon, 06 Nov 2006 22:09:54 +0100
Message-ID: <1162847394.1412.17.camel@johannes.berg>
References: <1162741174.24574.22.camel@johannes.berg>
	 <20061106210145.6824bec6@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zz+FvG23KL+vD+5ZxCP5"
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:27087 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1753807AbWKFVLe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 16:11:34 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061106210145.6824bec6@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-zz+FvG23KL+vD+5ZxCP5
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

[reordering a bit]

> >    This changes the 'cookie' that d80211 returns from alloc_hw
> >    to be an opaque value to the driver. Turned out that it wasn't
> >    such a great idea but since it was generally a clean up I kept
> >    this patch to base my other patches on.
>=20
> ACK.

> What did happen with
> d80211: add a function to get the wiphy index
> d80211: add a perm_addr hardware property
> d80211: add a struct device* hardware property
> d80211: add a ethtool_ops hardware property
> patches?

Well after some chat with a few people I decided that it was stupid and
not very maintainable to copy all the fields in net_device to a new
structure.

> > 009-d80211-convert-spaces.patch
> >    d80211: convert leading spaces to tabs
> >=20
> >    I hated working on the code, so I did this. The next patch
> >    breaks everything anyway.
>=20
> NAK. There are too many patches pending. Let's do this just before
> merging.

Oh come off it! It's really stupid to have to check all the tabs/spaces
all the time. The patch changes 451 lines. And wiggle can handle that
just fine. Besides, if you do
s/^\+       /+\t/
s/^-       /-\t/
s/        /\t/
on your patches, they'll be fine too.

> This is too big patch for a review,=20

Yeah. It's pretty bad actually, but I couldn't really find a good way to
split it into logical chunks.

> > * The mdev no longer has a sub_if_data attached (why ever did it??)
> >   It's private area is for the driver since we don't create it but
> >   the driver does. I did keep the notation of mdev/master all through,
> >   but it's no longer the stacks device. Keep that in mind.
>=20
> This definitely breaks AP mode. In the code, there is heavily (ab)used
> the fact that the master device is in fact an AP device. I tried to fix
> that but it was so difficult I gave up. It is needed to rewrite the
> whole RX path (and even that is probably not enough).

Bugger. I didn't notice that. I'll have a look. That is indeed a
showstopper.

> As this will
> be fixed for free when we have native 802.11 devices, I don't think we
> need to do anything about it now.

I don't think I understand this. I mean, my patch actually gives us
native 802.11 devices by making the drivers register those and then
handling them virtually similar to how 8021q handles ethernet devices. I
honestly thought that this was the plan for said "native 802.11
devices".

> > * sysfs layout changed. There is no wiphy or an ieee80211 class any mor=
e,
> >   the attributes that used to be there are now in the net_device that
> >   the driver registered, and our attributes are below the devices we cr=
eated.
>=20
> You want an ieee80211 class. Once you get rid of a master interface you
> need something with per-hardware information, statistics etc.

Yeah, I gave up trying to get rid of the master interface in favour of
having a native 802.11 device which is registered by the phy driver
instead.

> > * sysfs layout changed. There is no wiphy or an ieee80211 class any mor=
e,
> >   the attributes that used to be there are now in the net_device that
> >   the driver registered, and our attributes are below the devices we cr=
eated.
>=20
> Doesn't belong to this patch.

Had to be here initially due to the way I did things, but ok, probably
changeable.

johannes

--=-zz+FvG23KL+vD+5ZxCP5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARU+koKVg1VMiehFYAQJwChAAoHYPoXD/d4tKGSFRW1Vlw28sEjBoc1Yi
EhqlUsiUhWfw0Z92hTcNV8630bmPwy8VzMj9Exfn8d3aKrIkiB7ZRyo2385Z1qC6
v9JeeHbjRVuTO2uiDgClGpFPoBsr3nMD0ss7ksuyz/XXxJxg6mG64JwAka1dPKwl
Xds/zTPjhkMJybxhh+TxcrQGG2uvaM3qpkTiieKAegCL8Ftd63JmiQdqloJLpQqj
B5YvAxFp5Ak+4ATy1/cHb2wBFWNwvJM6WMmGxUGUDrFwH2vi8WFZSfRX3Xkj4ed8
YQRp60SXJXinOI2Z0k2R9EpTmCYP522rx6VvCP5qwdVyUraRllgPSfqsZqOAwjh6
tOXIinBalsJu1CIawcIT6c4IIA+j9esY6OLW8+/sueqP+yGJ69kMJDAYH1bW3dek
F1A2Wnz38WEvHe01Zx0fGRouikPpKsckFetgnGjL+J6LcPZU9WAOwK8goWQhTgnV
JMqCxSCpqrI/hQ+vghP+cKTCMgbnMcLkC5WVLS0IfoNMlOGp4nEjCLruzfIStKvG
8FuC+mSbra957WaoZHFtEIvZVRqS/DkIh7NhY52+AxAnTB4rJFQPJQKTVWqihaxU
r42Hh9Tsk3TNW1EOJH8+8H9Xk+R+kM62zpJBvN1FjV5R1Ohak9DUJYMaXhbPJ3mN
Xqez7MWXaIE=
=ZQeh
-----END PGP SIGNATURE-----

--=-zz+FvG23KL+vD+5ZxCP5--

