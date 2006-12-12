From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: d80211-drivers pull request (week-48)
Date: Mon, 11 Dec 2006 23:28:09 -0500
Message-ID: <200612112328.14286.flamingice@sourmilk.net>
References: <200612110101.58710.flamingice@sourmilk.net> <200612112120.58157.flamingice@sourmilk.net> <457E2734.6010700@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3752438.X25DR5Tkz6";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:39960 "EHLO
	annwn14.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751070AbWLLE2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 23:28:34 -0500
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <457E2734.6010700@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3752438.X25DR5Tkz6
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 11 December 2006 22:51, Daniel Drake wrote:
> It's ugly, in my mind not necessary, and it will kill performance. We
> haven't had to make such compromises in a long time. We got a large TX
> speed boost when the driver was modified to queue up multiple transmit
> URBs (i.e. don't wait for URB completion of the first) at the same time
> early during driver development. And even with that we're still a fair
> distance from the performance of the vendor driver.
>
Yes, synchronous anything tends to kill performance. I do not see what abou=
t=20
this patch kills performance, however. It merely frees skbs at a later poin=
t.=20
The additional code in the RX path should be negligible. Also, every other=
=20
d80211 driver has some sort of similar mechanism, the only difference being=
=20
that  the one for zd1211rw-d80211 isn't as reliable. I do not think it is=20
that ugly.

> While the stack isn't so well suited for this device I'd much prefer to
> see a more simplistic workaround. For example, assume all packets were
> successful but then report a failure when an interrupt comes in. Or, if
> the stack won't accept out-of-the-blue notifications like that, then
> maintain a counter which is incremented when a failure is reported, and
> when transmitting the next few frames report them as failed and
> decrement the counter (while counter > 0).
I don't think these solutions are much prettier than a tx_queue.

> Maybe disable rate control=20
> until we can come up with a nicer solution.
>
I don't think that's gonna happen unless changes are made in the firmware, =
or=20
there's some bit somewhere to flip that does exactly what we need. And=20
surely, having some working rate control is better than requiring manual tx=
=20
rate tuning, right? (which isn't an option in d80211 anyway)

=2DMichael Wu

--nextPart3752438.X25DR5Tkz6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFfi/eT3Oqt9AH4aERAh+XAJ9m8HodeKartIW4p92Qlg/uyPNSPQCfRjRh
sPLMkbPdyVLg5mljIP3Odnk=
=T/L2
-----END PGP SIGNATURE-----

--nextPart3752438.X25DR5Tkz6--
