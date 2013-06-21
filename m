From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 6/6] alx: fix ethtool support code
Date: Fri, 21 Jun 2013 13:39:45 +0100
Message-ID: <1371818385.8771.21.camel@deadeye.wl.decadent.org.uk>
References: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
	 <1371766494-18979-7-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5IyudmzP58fMIP5WOXxu"
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36290 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161196Ab3FUMjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 08:39:46 -0400
In-Reply-To: <1371766494-18979-7-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5IyudmzP58fMIP5WOXxu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-06-21 at 00:14 +0200, Johannes Berg wrote:
> A number of places treated features wrongly, listing not-supported
> features instead of supported ones. Also, the get_drvinfo ethtool
> callback isn't needed, and alx_get_pauseparam can be simplified.
>=20
> Reported-by: Ben Hutchings <ben@decadent.org.uk>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  drivers/net/ethernet/atheros/alx/ethtool.c | 62 +++++++++++++-----------=
------
>  1 file changed, 26 insertions(+), 36 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/atheros/alx/ethtool.c b/drivers/net/eth=
ernet/atheros/alx/ethtool.c
> index 2170b61..0f4c79e 100644
> --- a/drivers/net/ethernet/atheros/alx/ethtool.c
> +++ b/drivers/net/ethernet/atheros/alx/ethtool.c
> @@ -46,22 +46,35 @@
>  #include "reg.h"
>  #include "hw.h"
> =20
> +static u32 alx_get_supported_speeds(struct alx_hw *hw)
> +{
> +	u32 supported =3D SUPPORTED_10baseT_Half |
> +			SUPPORTED_10baseT_Full |
> +			SUPPORTED_100baseT_Half |
> +			SUPPORTED_100baseT_Full;
> +
> +	if (alx_hw_giga(hw))
> +		supported |=3D SUPPORTED_1000baseT_Full;
> +
> +	BUILD_BUG_ON(SUPPORTED_10baseT_Half !=3D ADVERTISED_10baseT_Half);
> +	BUILD_BUG_ON(SUPPORTED_10baseT_Full !=3D ADVERTISED_10baseT_Full);
> +	BUILD_BUG_ON(SUPPORTED_100baseT_Half !=3D ADVERTISED_100baseT_Half);
> +	BUILD_BUG_ON(SUPPORTED_100baseT_Full !=3D ADVERTISED_100baseT_Full);
> +	BUILD_BUG_ON(SUPPORTED_1000baseT_Full !=3D ADVERTISED_1000baseT_Full);
> +
> +	return supported;
> +}
[...]
> @@ -102,7 +115,7 @@ static int alx_set_settings(struct net_device *netdev=
, struct ethtool_cmd *ecmd)
>  	ASSERT_RTNL();
> =20
>  	if (ecmd->autoneg =3D=3D AUTONEG_ENABLE) {
> -		if (ecmd->advertising & ADVERTISED_1000baseT_Half)
> +		if (ecmd->advertising & ~alx_get_supported_speeds(hw))
[...]

This means that Pause/Asym_Pause advertising can't be directly
controlled.  It's a pain to implement that properly, though, so I
suppose this can be deferred.

Ben.

--=20
Ben Hutchings
Klipstein's 4th Law of Prototyping and Production:
                                    A fail-safe circuit will destroy others=
.

--=-5IyudmzP58fMIP5WOXxu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUcRJkee/yOyVhhEJAQrmaw//TUBE/vtni7+89yYkILjZMyzVqGcaED+p
hjNaLNf3BC4IvONf5nCUs/IdYn7II2iJh2XslSpFLGVxntOjPsnxhWQPGS8+r2Fz
IfJYex6Cf/qccN1AGA1S3jxjtv/O2u2S+eAONsjH4Acbbsse/CzJDNIN9/7nx52k
iKJS31dUzTEri63k+B8dZujhdFaf1QQkl9pKoxG8nyquU1mgHjSov71MD/5mRdKn
YQlAAtdXBCEHwlVacXIpuhEpA0SieBGwjHSGV7PT4/WmDk3oNjjWahnNe6XVQq/L
kr8tQ3ewsBg752O0TJM3PYzjQkJwieJbqUunVyTn49Z09KekIJdeb613QyOuo+V7
vC4Pblci7Mo8m7Ss2Wu3QB2eIlt5O1lttX9PM15GYN3V3sppmwhvJWhxC3TNPb6f
Wu26Lvw8FT/QZYlmWzxm56QdygM7KCBFJWrosuuO7JUcR9uOEKjxejHO38QLP5Of
z822VcfFjZsPaZCtdRkcf+pl+BrfmpxyWj5SeJMuPqCDApgGh0mcfJbzctqPBFGJ
TYtwtW8hUa9711vP+crOqJ1DN0kyAYGhDVT2ZIC+mOn4v2a/JcuiQG9R8/WIpomG
4M5PUb1hDdZ2p7movOqGHo8uKylCGnKJ/Ured4ZAMMAGlLKyyfgjey5ed0rF2XtG
U/EMIb+SKTE=
=zxPu
-----END PGP SIGNATURE-----

--=-5IyudmzP58fMIP5WOXxu--
