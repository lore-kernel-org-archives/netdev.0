From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: zd1211 ported to Devicescape stack
Date: Sat, 2 Dec 2006 09:54:15 -0500
Message-ID: <200612020954.20469.flamingice@sourmilk.net>
References: <200612020316.50965.flamingice@sourmilk.net> <20061202132539.GB18326@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3913223.XNfAAP2vfS";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Luis Rodriguez <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:22167 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1031567AbWLBOyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 09:54:54 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061202132539.GB18326@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3913223.XNfAAP2vfS
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 02 December 2006 08:25, Ulrich Kunitz wrote:
> > 	- The original driver does not seem to check if a frame has been
> > successfully TXed (as in RXed an ACK), so the port does not properly
> > report to the stack whether or not a TX succeeded.
>
> TX is atomic. Do you really want to spin for the received ACK? Layer 2
> doesn't need to make any guarantees for packet transmission, so I have
> trouble to see the point here. The Linux Device Driver book says
> explicitly that packet transmission must not have been completed
> at the point in time the function returns.
>
And it doesn't. Sleeping at that point would be bad. However, the p54 drive=
r=20
looks for special frames from the card that report the success/failure of=20
sent frames, and adm8211 can tell if a frame was TXed successfully on TX ri=
ng=20
cleanup. The notification is then done by calling ieee80211_tx_status, not =
by=20
returning an error code. No sleeping necessary. This is needed for the uppe=
r=20
layer to resend frames and to also do rate control.

> I would suggest to maintain it until d80211 has
> complete regulatory domains support.
>
Why? It's not like any other d80211 drivers have regulatory domains support=
,=20
and they need the exactly the same features that zd1211 needs. Also, the=20
limited support for regulatory domains that d80211 does have restricts it t=
o=20
channels 1-11 (FCC) regardless, so the code would not be effective.

Thanks,
=2DMichael Wu

--nextPart3913223.XNfAAP2vfS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFcZOcT3Oqt9AH4aERApWQAJ9sQn6IbgAvwr13YlNLfph0RZUAtgCgiA03
7V3gS7IT/cJicaIpdx8QcUw=
=JDES
-----END PGP SIGNATURE-----

--nextPart3913223.XNfAAP2vfS--
