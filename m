From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next-2.6 0/2] 3c59x: Locking fixes
Date: Thu, 24 Jun 2010 00:52:41 +0100
Message-ID: <1277337161.26161.14.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-L/kA1eHnQvlAwGaenWgr"
Cc: netdev@vger.kernel.org,
	Chase Douglas <chase.douglas@canonical.com>,
	Arne Nordmark <nordmark@mech.kth.se>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38897 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753727Ab0FWXwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 19:52:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-L/kA1eHnQvlAwGaenWgr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

disable_irq() is no longer safe to use in atomic context.  This should
remove the need to use disable_irq() or to hold locks for long periods
in 3c59x.

Ben.

Ben Hutchings (2):
  3c59x: Specify window explicitly for access to windowed registers
  3c59x: Use fine-grained locks for MII and windowed register access

 drivers/net/3c59x.c |  350 ++++++++++++++++++++++++++---------------------=
----
 1 files changed, 177 insertions(+), 173 deletions(-)



--=-L/kA1eHnQvlAwGaenWgr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATCKeNue/yOyVhhEJAQJRfRAA1aENcuzCC0TmcC9RtN74qwx7C5ZAnIbp
yeCU+oBzOcbTPxEA8AzNbhsJ/XyCSv8gfkvylF1l5Dfd13IdNpQFlLRYQnkKxvih
UvoCFKtiNER6BbTcYwp2ptEgt43PS+zKa2PCcBQgzoVvccFE9FIlBgmR3L/UPN3Z
DizQfy7VJuEe1Jx3r259jEgsvApt3ief4I/+UOJl/e3vhLZOGyjfQO2S8n3sDYH8
AjpHuZoEwhB6Lf7Soz9MyuhEyRdigCd1D+EtWlHkyEtiPBzDRviR99OaQam8Qd5o
uUUa/G6OTFoBZEKdpvI34ht9cqEEE/5wfntCP6ZiYP0jWtmSOYrCdAd6YXNvARqi
7VwYRUXqbxSvOIS+7QvZa5Cjl1NmVkGqNcnmb6fl1u2urDuFbkLuStjQA+cdW3eJ
oNApgZUQYxpWfnu7jMusBhjT7IFVUv5w4dZDxx2sG+5TDfiy/XovevQrRwyKgOE8
xtQ9thLzcRDXpRwNd7GRPc2iTLCdNxRcDvP45dpL/UjBh+r0aep6TTk8Z9JTieLg
yAAoQBundHYpeXZn0T3yxS13Mu/boHILl5Ov5YVrNL8Ys4pCU0tTBg6OS5yZORBj
Uw2zBTnbgH/Oid2DVr4u3qWQVaEh4Yh2XTRQ68BkTZr1V5ag0chntxDtcrzRSBA2
HDMvUVfcKZs=
=F7rk
-----END PGP SIGNATURE-----

--=-L/kA1eHnQvlAwGaenWgr--
