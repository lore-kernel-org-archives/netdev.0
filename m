From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: fix initialisation if built-in
Date: Tue, 11 Sep 2007 12:24:57 +0200
Message-ID: <1189506297.6161.11.camel@johannes.berg>
References: <1189424685.4506.63.camel@johannes.berg>
	 <aec7e5c30709101804p337084e9o63b5bcb4f007828@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-llFWJ5t1E22s3nkAks1W"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Rob Hussey <robjhussey@gmail.com>, stable@kernel.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35992 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424AbXIKKX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 06:23:28 -0400
In-Reply-To: <aec7e5c30709101804p337084e9o63b5bcb4f007828@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-llFWJ5t1E22s3nkAks1W
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-09-11 at 10:04 +0900, Magnus Damm wrote:
> On 9/10/07, Johannes Berg <johannes@sipsolutions.net> wrote:
> > When cfg80211 is built into the kernel it needs to init earlier
> > so that device registrations are run after it has initialised.
> >
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
>=20
> Yep, I need this fix as well. Without it the ath5k driver built in
> bombs out during module_init(). Something with kref and a struct
> device pointing to an uninitialized ieee80211_class.
>=20
> I need a similar fix for net/mac80211/rc80211_simple.c as well to get
> ath5k working though, not sure why at the moment. There may be some
> bug with request_module() not being called properly.

Nah, it's just all too late and the rate control algorithm is built-in
too iirc. Rob tested a patch that changes those to subsys_initcall() as
well, so I'll be posting that.

johannes

--=-llFWJ5t1E22s3nkAks1W
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG5mz5/ETPhpq3jKURAtnXAKCpAgk9/dQWHMNnYVLDsYKbf6zD9gCfRUYM
wPsLlkqTa7T4y6OlTORB0mg=
=Bqsf
-----END PGP SIGNATURE-----

--=-llFWJ5t1E22s3nkAks1W--

