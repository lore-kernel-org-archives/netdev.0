From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211 ethtool
Date: Wed, 22 Nov 2006 18:17:13 +0100
Message-ID: <1164215833.5934.8.camel@johannes.berg>
References: <200611221608.09234.IvDoorn@gmail.com>
	 <200611221759.01579.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-LRCTUd9DhqfxGQg6hQhr"
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:12517 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1755996AbWKVRTK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 12:19:10 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200611221759.01579.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-LRCTUd9DhqfxGQg6hQhr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-11-22 at 17:59 +0100, Ivo van Doorn wrote:

> This patch adds the ethtool_ops reference into the
> ieee80211_ops structure, and makes sure that it will
> be set on all new interfaces that will be created.

I disagree. Most ethtool ops are really tied to actual ethernet (TSO or
UFO for wireless?) and make no sense to have on wireless devices. From
what I can tell, you're using

 (a) get_link
 (b) eeprom dump
 (c) message level
 (d) driver info
 (e) register dump
 (f) get perm addr

(f) will be added to the wiphy stuff in cfg80211/nl80211. (a) has a bit
of a semantic problem, when, for example, does an access point or
monitor device have carrier/lower level ok?

(b) and (e) can be in debugfs, (c) can be a sysfs-modifiable module
parameter.

That leaves just (d) which isn't all that useful anyway.

I just don't see why the ethtool ops should be there at all.

johannes

--=-LRCTUd9DhqfxGQg6hQhr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFZIYZ/ETPhpq3jKURAj7EAJ9Zm6RvKI47GbSwhLJvX/VqHS0QkACgkdND
9SfDg9Mqag+xbzpVYKRAVj0=
=99tn
-----END PGP SIGNATURE-----

--=-LRCTUd9DhqfxGQg6hQhr--

