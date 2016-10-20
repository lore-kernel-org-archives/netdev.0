From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] tipc: Guard against tiny MTU in tipc_msg_build()
Date: Thu, 20 Oct 2016 17:40:09 +0100
Message-ID: <1476981609.2709.56.camel@decadent.org.uk>
References: <20161019021654.GD2773@decadent.org.uk>
         <6a69780d-0797-b5af-fc90-04960bbb21c6@gmail.com>
         <1476967585.2709.52.camel@decadent.org.uk>
         <A2BAEFC30C8FD34388F02C9B3121859D22587ADA@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-Qq4ijjk2xfmcnZgw9wmy"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Qian Zhang <zhangqian-c@360.cn>,
        Eric Dumazet <edumazet@google.com>
To: Jon Maloy <jon.maloy@ericsson.com>, Ying Xue <ying.xue0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42777 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753428AbcJTQkU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 12:40:20 -0400
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D22587ADA@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Qq4ijjk2xfmcnZgw9wmy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-10-20 at 14:51 +0000, Jon Maloy wrote:
[...]
> > At this point we're about to copy INT_H_SIZE + mhsz bytes into the
> > first fragment. =C2=A0If that's already limited to be less than or equa=
l to
> > MAX_H_SIZE, comparing with MAX_H_SIZE would be fine. =C2=A0But if MAX_H=
_SIZE
> > is the maximum value of mhsz, that won't be good enough.
>=20
>=20
> MAX_H_SIZE is 60 bytes, but in practice you will never see an mhsz larger=
 than the biggest header we are actually using, which is MCAST_H_SIZE (=3D=
=3D44 bytes).
> INT_H_SIZE is 40 bytes, so you are in reality testing for whether we have=
 an mtu < 84 bytes.
> You won't find any interfaces or protocols that come even close to this l=
imitation, so to me this test is redundant.

But I can easily create such an interface:

$ unshare -n -U -r
# ip l set lo mtu 1

Ben.

--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.


--=-Qq4ijjk2xfmcnZgw9wmy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYCPNpAAoJEOe/yOyVhhEJVLEP/2PzxACmmXmoHPj/8kQaL0Sr
0So4Pj0iC8KlgL7+Dhka54t7vnYYoV2vKuPH5R4neRtoIaW9MU/k4qkVs7IJYz1C
tAPWKp0/RlXnnDOLuYPEQkDEO6AbPl9gc3BDz0Qpo8ABYtwFDWw2UqE1JE3Op3il
+IITcIAeg9GLc7GCNrFJmhg794AE4ogOeJjf46xFS5kitS9yXCZTJQ8tmku4UtTT
aKkvZmyyFVVqmCL5R4Y41kstz44YoTQKTLilNPCf/m8QnLm+gS5HCaK1zzNE47xv
jrypNeBP/jFaSaBTgwS/u/U2dwlcwSEeAxF6TNNJuCQ6E58avkHSrU9i0GpqZjSr
QbbtWw7SS0bIpkzy92clbaT+D7qsTas4jphIPYs7CMAyqDXsbMmbHbMviMtBNSwq
WoMHe9/a51xot4+wx4eA3W3n86BWEP0Atc00iiv0q+kigeui9UKK1jUb8WsWuwbW
RVxZeDE5e5BWNCm3+zusMRaVnl875dGkW2R0X7Z0NQoKJAc0y9Fqw4Dz8J/P2xlo
Cha2oweIGUGgh3UHvtQN0s9NHcxCPaoI6ncDoA2jb8k7uIlEZeoYqbq16TuO7Oml
WyWPiqW9M2SDUmekFZvStR8j4A5Ym1y43iEPnV4yUrFM95pF330VTo29B9DJrlmk
YFVV3+RYVF29QO2M6xVq
=hN/U
-----END PGP SIGNATURE-----

--=-Qq4ijjk2xfmcnZgw9wmy--
