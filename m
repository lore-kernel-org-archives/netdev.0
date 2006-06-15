From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: Suspending 802.11 drivers
Date: Thu, 15 Jun 2006 22:14:52 +0200
Message-ID: <200606152214.55745.IvDoorn@gmail.com>
References: <200606152158.10079.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1177348.8oStRglk0D";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:60724 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1031252AbWFOULO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 16:11:14 -0400
Received: by nf-out-0910.google.com with SMTP id y25so304577nfb
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 13:11:12 -0700 (PDT)
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606152158.10079.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1177348.8oStRglk0D
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

> I am currently thinking about the best way to correctly
> implement PM suspending for wireless drivers.
> Currently, the 802.11 stack is not suspend aware (if I talk
> about "stack" here, I mostly mean devicescape).
> For example, if we suspend the bcm43xx driver, we don't
> notify the stack before doing so. That's a bug.

Similar in rt2x00. The basic approach in there is calling
netdev->open() and netdev->stop() which is not the most clean
or correct thing to do.

> I would say, we should have two functions, which are called
> from the driver suspend and resume callbacks.
> Let's call them
> ieee80211_suspend() and ieee80211_resume() for now.
> The suspend would save all status information, for example
> to which AP we are associated and so on. After that it would
> cleanly disassociate from the AP and do other cleanups which
> are needed.
> The resume function would try to re-esablish the connection.
> Of course, that will not always be possible (the notebook
> owner traveled around half the world between suspend and
> resume ;) ). But that does not matter. We simply return silently
> without a new association (Do a new scan, or whatever).
>=20
> Are such functions generally desireable?

Absolutely, I have been looking into this some time ago as well,
but due to lack of time haven't managed to get anything done.

Ivo

--nextPart1177348.8oStRglk0D
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEkb+/aqndE37Em0gRAqO9AKCTaYZrqW2PHTzmQLa916ygLnIvVgCfW0a0
x8zXnb5hPvz5nc4C5HSY/Cs=
=o6tB
-----END PGP SIGNATURE-----

--nextPart1177348.8oStRglk0D--
