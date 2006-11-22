From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 0/3] more power to cfg80211
Date: Wed, 22 Nov 2006 20:18:53 +0100
Message-ID: <1164223133.5934.19.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
	 <1163979143.9216.14.camel@johannes.berg>
	 <20061120201402.76e69e46@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wnCZTWd5YFuLOV6edBPi"
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:52439 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1756713AbWKVTUz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 14:20:55 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061120201402.76e69e46@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-wnCZTWd5YFuLOV6edBPi
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

The following patches are mostly proof-of-concept code for moving over
stuff to cfg80211 (like the wiphy thing).

I've changed net_dev->ieee80211_ptr to be of struct wiphy because it
allows accessing the wiphy by netdev easily then, and since wireless
drivers are (after these patches) expected to register with cfg80211
anyway it doesn't really change much. They need wiphy_priv() then but
it's tiny.

There's lots left, cfg80211 could put some default things into sysfs, we
could notify it of added/removed netdevs (it knows when userspace does
this, but not when the driver does by default) and put links from=20
  class/ieee80211/<wiphy>/dev:eth1 -> ../../net/eth1
and things like that.

I'm not really sure this is the best thing we can do so I'm posting this
for some review before I actually dive in and do those modifications.
Also, I need to put back a symlink from class/ieee80211/<wiphy>/device
to the hardware device. Just discovered that I apparently forgot :)

The patches are tested and work fine but we lose functionality, I
removed the possibility to create and remove virtual interfaces in
d80211 because I wanted to put it into cfg80211 already (well, just
needs the d80211 cfg handler...) but then didn't put it in so far.

If you feel this is something worth pursuing please shout and I'll fix
these issues and submit the patches for actual inclusion.

johannes

--=-wnCZTWd5YFuLOV6edBPi
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFZKKd/ETPhpq3jKURAl5JAJ0dKWhbVU8PGTC5iJzdZil7bkSq5QCeKdSB
pbdBYtEJ8FkV22EUjWySc2g=
=OmBP
-----END PGP SIGNATURE-----

--=-wnCZTWd5YFuLOV6edBPi--

