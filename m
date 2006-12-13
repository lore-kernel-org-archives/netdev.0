From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: d80211-drivers pull request (week-48)
Date: Tue, 12 Dec 2006 21:35:08 -0500
Message-ID: <200612122135.13466.flamingice@sourmilk.net>
References: <200612110101.58710.flamingice@sourmilk.net> <200612112120.58157.flamingice@sourmilk.net> <20061212233955.GB8487@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4420151.DJFkgp8Sor";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>,
	John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:43452 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964899AbWLMCfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 21:35:34 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061212233955.GB8487@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4420151.DJFkgp8Sor
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 12 December 2006 18:39, Ulrich Kunitz wrote:
> Just two observations:
>
> 1) The retry-failed-interrupt message contains the destination
>    MAC address of the transmitted message.
Hm, that might be useful to check in master or adhoc mode to make sure the =
tx=20
queue isn't messed up.

> 2) We could get easily two acks for the same transmission.
How would this occur?

> 3) We could get ACKs or retry-failed-interrupts for packets, for
>    which no status has been requested by the upper layers.
>
We report status for every frame which will get an ACK, which is every unic=
ast=20
frame. Coincidentally, d80211 uses the same logic to determine when it want=
s=20
the status to be reported (IIRC).

> I suggest that the skbs as buffer for the URB transmissions.
Yes, copying the entire frame to another buffer isn't very performance=20
friendly. This was one of the things that bothered me when I ported zd1211r=
w.

> We could add a timeout value to each=20
> packet to make sure, that we don't ACK or NAK packets, which have
> been overdue.
Some sort of watchdog to kick things when things stall could be useful, tho=
ugh=20
I'm not sure how to go about it.

=2DMichael Wu

--nextPart4420151.DJFkgp8Sor
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFf2bhT3Oqt9AH4aERAl3GAJ9PCWZEasvsyKVc4T0zklcF5WSCvACgrjs1
huAxutQaauYDATlhHkVJkgA=
=0bG3
-----END PGP SIGNATURE-----

--nextPart4420151.DJFkgp8Sor--
