From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: d80211-drivers pull request (week-48)
Date: Mon, 11 Dec 2006 21:20:53 -0500
Message-ID: <200612112120.58157.flamingice@sourmilk.net>
References: <200612110101.58710.flamingice@sourmilk.net> <457E00D4.7010201@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6704088.cAKzk32vUW";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:9385 "EHLO annwn14.rutgers.edu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750869AbWLLCVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 21:21:20 -0500
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <457E00D4.7010201@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6704088.cAKzk32vUW
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 11 December 2006 20:07, Daniel Drake wrote:
> Michael Wu wrote:
> >       zd1211rw-d80211: Use ieee80211_tx_status
>
> I've thought some more about this and I'm not so sure that this is the
> right approach.
>
> Can't devicescape be taught that the ZD1211 handles retries in hardware
> and the stack doesn't need to worry about it?
>
All 802.11 devices have to be able to handle retries in hardware to do rand=
om=20
backoff properly. Still, the stack wants to know what happened.

> I think I remember reading that devicescape uses failed transmission
> rate in the rate adjustment calculations. Even without this racy ack
> system we can still achieve that - the device tells us every time it
> retries a transmit, and then it sends a special interrupt at the end
> saying that all retries failed.
>
Yes, but it also uses successful transmissions in rate adjustment.

I don't think this race is such a big deal. It will only happen when someon=
e=20
is really trying to mess with the link, and would cause the rate control to=
=20
jump to the highest speed. However, if someone is really trying to mess wit=
h=20
the link this way, the stability of the link is in trouble anyways. Wait fo=
r=20
stations to send frames, and send an ack for every unicast frame - everyone=
=20
will get confused. To actually mess with this code, the attacker would have=
=20
to transmit acks nearly continuously as it can't tell exactly when is a goo=
d=20
time to screw things up, and the driver recovers as soon as the queue is=20
emptied. Someone transmitting all the time is a problem for all wireless=20
cards. :)

=2DMichael Wu

--nextPart6704088.cAKzk32vUW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFfhIKT3Oqt9AH4aERAqB/AJ4yX/rLgwJUkm25cZ2nrgJMOsorrQCfZhAc
EL23fVDNbMgjbgn5REbVJcs=
=FKAr
-----END PGP SIGNATURE-----

--nextPart6704088.cAKzk32vUW--
