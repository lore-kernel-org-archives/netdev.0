From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/10] d80211: move away from wmaster towards wiphy
Date: Fri, 17 Nov 2006 23:27:19 +0100
Message-ID: <1163802439.3392.47.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-2blsSRmHZ73z6HcdkDlL"
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:20623 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1753335AbWKQW3H
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 17:29:07 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-2blsSRmHZ73z6HcdkDlL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

Since it looks like we'll be able to move the qdisc stuff over to a new
wiphy concept the master device is getting completely useless. Joy :)

Here's a series of patches to migrate d80211 away from the wmaster and
more towards a wiphy concept. This series targets the driver API.

Since I have no hope that netdev will like my patches, the whole series
is available at http://johannes.sipsolutions.net/patches/d80211-wiphy/
(and this time I made sure it's accessible :), also as
http://johannes.sipsolutions.net/patches/d80211-wiphy.tar.bz2)

d80211: clean up some stupid list and loop code
d80211: reduce mdev usage
d80211: reduce mdev usage
d80211: reduce mdev usage, fix ieee80211_rx_mgmt
d80211: reduce master ieee80211_ptr deref in scan routines
d80211: change the cookie to be opaque

These have been submitted previously and I've used them as stepping
stones. I removed the while (1) from the first one again in favour of
for (;;).

d80211: move hw descriptor into wiphy structure

Another stepping stone in a way, moves the ieee80211_hw *hw into wiphy
to drop some exported symbols.

d80211: add a perm_addr hardware property

another patch from my original series... puts the perm_addr property in
that will be moved around in the next patch

d80211: split ieee80211_hw

Most interesting one :) This one splits up ieee80211_hw into
ieee80211_ops and moves everything that could possibly be card-dependent
(as opposed to driver dependent) into ieee80211_wiphy.

d80211: introduce IEEE80211_HW_FRAG flag

just a fix for the previous one.

No driver updates for now, sorry.

johannes

--=-2blsSRmHZ73z6HcdkDlL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFXjdH/ETPhpq3jKURAl/hAJ9Beug4WoMKc1YgLwIFG76PKzhaKgCfXEbr
n15suksXqpC6EO2oB35LiBI=
=i/of
-----END PGP SIGNATURE-----

--=-2blsSRmHZ73z6HcdkDlL--

