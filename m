From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Sun, 26 Nov 2006 11:03:28 +0100
Message-ID: <1164535408.21459.3.camel@johannes.berg>
References: <4568DCEB.mailLLK1Z24PM@lwfinger.net>
	 <45691273.9090803@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+TrUiJnzjYoNtm1JjMBM"
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:15562 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S935309AbWKZKFl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 05:05:41 -0500
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <45691273.9090803@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+TrUiJnzjYoNtm1JjMBM
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2006-11-25 at 23:05 -0500, Daniel Drake wrote:

> Surely disabling the queue actually makes sense, in order to avoid=20
> frames designated for the "current session" being transmitted on=20
> different channels during scanning?

The problem is that queue disabling isn't refcounted so that a scan that
collides with bcm43xx having disabled the queue for calibration might
re-enable the queue while bcm43xx is still calibrating.

Clearly, this doesn't fully fix the problem because softmac will try to
transmit frames during the calibration. Hence, a proper fix would be to
not remove the calls to netif_tx_disable but make them go through
softmac (ieee80211_tx_disable) to make sure that softmac doesn't try to
scan while the queues are disabled, which would fix the aforementioned
problem of softmac enabling the queue while the driver needs it disabled
for free.

johannes

--=-+TrUiJnzjYoNtm1JjMBM
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFaWZw/ETPhpq3jKURArDIAJ0VC2vouzVo+nGJaSK8v2UthTbtNACfRsog
T8t/U/cZ6uJwvHccyXZA+RY=
=p772
-----END PGP SIGNATURE-----

--=-+TrUiJnzjYoNtm1JjMBM--

