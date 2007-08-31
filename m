From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Sat, 01 Sep 2007 00:32:55 +0200
Message-ID: <1188599575.7585.62.camel@johannes.berg>
References: <1188250006.18004.144.camel@localhost>
	 <20070827.143724.38316150.davem@davemloft.net>
	 <1188335521.6062.56.camel@localhost>
	 <20070828.142216.99461544.davem@davemloft.net>
	 <1188598563.6062.191.camel@localhost>
	 <1188598880.7585.52.camel@johannes.berg>
	 <1188599040.6062.192.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oxbM031weuwEMZ1v6+Lq"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:45953 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbXHaWbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 18:31:33 -0400
In-Reply-To: <1188599040.6062.192.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-oxbM031weuwEMZ1v6+Lq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-08-31 at 15:24 -0700, Joe Perches wrote:
> On Sat, 2007-09-01 at 00:21 +0200, Johannes Berg wrote:
> > On Fri, 2007-08-31 at 15:16 -0700, Joe Perches wrote:
> > > please pull from:
> > > git pull git://repo.or.cz/linux-2.6/trivial-mods.git net-2.6.24-print=
_mac
> > got a gitweb for that somewhere?
>=20
> Does this work for you?
>=20
> http://repo.or.cz/w/linux-2.6/trivial-mods.git

I think you got a bit too trigger-happy:


        p +=3D sprintf(p, "key[%d] alg=3DCCMP key_set=3D%d "
-                    "tx_pn=3D%02x%02x%02x%02x%02x%02x "
-                    "rx_pn=3D%02x%02x%02x%02x%02x%02x "
+                    "tx_pn=3D%s "
+                    "rx_pn=3D%s "
                     "format_errors=3D%d replays=3D%d decrypt_errors=3D%d\n=
",
                     ccmp->key_idx, ccmp->key_set,
-                    MAC_ARG(ccmp->tx_pn), MAC_ARG(ccmp->rx_pn),
+                    print_mac(mac, ccmp->tx_pn), print_mac(mac2, ccmp->rx_=
pn),

the PN is a number, not a MAC address :) The fact that it used MAC_ARG,
was, I guess, just laziness of the original author since the PN is also
6 bytes long. That said, I can live with it being printed this way too,
it's just a bit weird.

Going to be fun to merge with my 70 outstanding patches though :)

johannes

--=-oxbM031weuwEMZ1v6+Lq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG2JcX/ETPhpq3jKURAq6SAJ9+3H4uU4QQpzYuBfnyz4j15/N95ACgp8IW
XbT59wGXDD/X6eR/vm3hqYs=
=mZ3J
-----END PGP SIGNATURE-----

--=-oxbM031weuwEMZ1v6+Lq--

