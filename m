From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ethtool: fix a kernel infoleak in ethtool_get_pauseparam
Date: Wed, 01 Jun 2016 18:14:24 +0100
Message-ID: <1464801264.2847.76.camel@decadent.org.uk>
References: <1464791961-8169-1-git-send-email-kjlu@gatech.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7QVLh1N5KrF4mRdnMuWl"
Cc: kan.liang@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	csong84@gatech.edu, Kangjie Lu <kjlu@gatech.edu>
To: Kangjie Lu <kangjielu@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38507 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751385AbcFAROm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 13:14:42 -0400
In-Reply-To: <1464791961-8169-1-git-send-email-kjlu@gatech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7QVLh1N5KrF4mRdnMuWl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-06-01 at 16:39 +0200, Kangjie Lu wrote:
> The field autoneg of pauseparam is not initialized in some
> implementations of get_pauseparam(),

Nonsense. =C2=A0The current implementation initialises all fields. =C2=A0(I=
f
there was padding in the structure, this change would be needed to
guarantee that the padding was initialised. =C2=A0But there isn't.)

Ben.

>  but the whole object is
> copied to userland.
>=20
> Signed-off-by: Kangjie Lu <kjlu@gatech.edu>
> ---
> =C2=A0net/core/ethtool.c | 5 ++++-
> =C2=A01 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index f426c5a..84544bd 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1723,7 +1723,10 @@ static noinline_for_stack int
> ethtool_set_channels(struct net_device *dev,
> =C2=A0
> =C2=A0static int ethtool_get_pauseparam(struct net_device *dev, void
> __user *useraddr)
> =C2=A0{
> -	struct ethtool_pauseparam pauseparam =3D { ETHTOOL_GPAUSEPARAM
> };
> +	struct ethtool_pauseparam pauseparam;
> +
> +	memset(&pauseparam, 0, sizeof(pauseparam));
> +	pauseparam.cmd =3D ETHTOOL_GPAUSEPARAM;
> =C2=A0
> =C2=A0	if (!dev->ethtool_ops->get_pauseparam)
> =C2=A0		return -EOPNOTSUPP;
--=20
Ben Hutchings
To err is human; to really foul things up requires a computer.

--=-7QVLh1N5KrF4mRdnMuWl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXTxfwAAoJEOe/yOyVhhEJyQ8QAIqGyMMglLVIOmRuWje3nGLU
PZsrThcPQNEzSqDCFlSuCxCMaLUV+46tuU2QgbIwW7UzO/f6Je06CtSalbT9xsrZ
pQG78+Z4CHNdKcmzXTr/z9eyIyqpaMmAALtgQ7rPSbv92K1VdVK6Y31liJ+Yw0Ch
oULwAQLZKDusvYedwG4fqVVNeKdY6EY14LB1W/xhGpY8NX0WlWERJJulDNXauaZN
RNn2otpByXnEtbyNGnpZQ6sYuylFnnNGIdtF3uux6ibDw+KZwr32OobLv/h6WuMa
P99PzEDHXK3txT8Ajv10M+HMTVcavrRK7kh7vv4aIuHqGLL47IXCs4Q8aduvlFRQ
GjkpPDeGMuNVm6dZuEoy2NURjpZXY9BKtaLBjhGGtjFVF7C8QjtYstRb8crxcmXj
2FU5dSnEWFdV0yaXlS4rNbtFPM9IzLuACGS3vtVvs9VslbElIdSaxKX8oGkguyUK
p3Dhco6YxsVuWXtLgf8jJZLayFR8CnmivjquhqRMKw5Lyzj2+f+YdUIyAcOUn9KY
YOECt3luoX/980uR9i7YodQIuIU2QiYjPwpPbBLi3GZ9pYDlEggHwqkWWIkdhXos
MbXSviLkUa+TbeATLiZ/YafQFtu0Rrwe4AUtzLrtn2CrlqUw8sJszL8IYsikJMvC
tmMzNa0DFpTjt29cS1ln
=QGFy
-----END PGP SIGNATURE-----

--=-7QVLh1N5KrF4mRdnMuWl--
