From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 6/13] d80211: change the identifier netdev to
	ieee80211_hw
Date: Mon, 20 Nov 2006 19:04:04 +0100
Message-ID: <1164045844.9216.24.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
	 <1163964522.15473.52.camel@johannes.berg>
	 <20061120185752.684b1b09@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rmhopnW6kknYUVPz/oJq"
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
Received: from crystal.sipsolutions.net ([195.210.38.204]:11473 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S966306AbWKTSFx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 13:05:53 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061120185752.684b1b09@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rmhopnW6kknYUVPz/oJq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-11-20 at 18:57 +0100, Jiri Benc wrote:

> If you are at it, why not to rename ieee80211_hw to some better name?
> We need to rename ieee80211_local and I think ieee80211_hw would be
> very good name for it. What about renaming of ieee80211_hw to
> ieee80211_dev?

Heh. I called it ieee80211_wiphy in the first series (don't look) but
then David said he'd prefer keeping the name to reduce diff size. It did
reduce the diff size a bit so I kept it for now.

> Setting set_frag_threshold when the card doesn't do fragmentation makes
> no sense. Not setting set_frag_threshold when the card needs to do
> fragmentation in hardware makes no sense as well. Therefore
> assigning/not assigning of set_frag_threshold gives the same
> information as the flag.

Well, I guessed that some optimisations with the p54 memory allocator
might be possible if it knows what the maximum frame size is (due to
fragmentation smaller than max MPDU size). But yeah, that's basically
handwaving.

The point was to make the 33 function pointers independent of the actual
hardware and only dependent on the driver so that ieee80211_ops can be
static to reduce size of the hw description struct.

> > -/* Configuration block used by the low-level driver to tell the 802.11=
 code
> > - * about supported hardware features and to pass function pointers to =
callback
> > - * functions. */
> > +/* this is driver-visible part of the per-hw state the stack keeps.
> > + * if you change something in here, call */
>=20
> Call what?

Heh. Call this function (update_hw) to notify the stack.

> > -	/* ieee80211 drivers must assign this instead of the callback in
> > +	/* This replaces the callback that would usually be in
> >  	 * &struct net_device. dev->flags, dev->mc_count and dev->mc_list mus=
t
>=20
> You probably want to delete the last "must".

Actually, the comment should be rewritting since dev-> makes no sense
any more.

johannes

--=-rmhopnW6kknYUVPz/oJq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYe4U/ETPhpq3jKURAj0lAJ0TMaZsUh6UKgv2T090Zdk3KYJXEACgs+LX
dlMS8x/DHjzeO5lSJmR7kXk=
=FVeI
-----END PGP SIGNATURE-----

--=-rmhopnW6kknYUVPz/oJq--

