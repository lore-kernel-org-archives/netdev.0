From: =?ISO-8859-15?Q?Andreas_F=E4rber?= <afaerber@suse.de>
Subject: Re: [PATCH v1 2/2] net: stmmac: add fixed_phy support via fixed-link
 DT binding
Date: Mon, 26 Jan 2015 04:01:59 +0100
Message-ID: <54C5AE27.4080206@suse.de>
References: <1422239858-3452-1-git-send-email-ming.lei@canonical.com> <1422239858-3452-3-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="UoAUwrn7CUxkeqV6baeqQrvRaw4F63wkv"
Cc: linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene@kernel.org>,
	netdev@vger.kernel.org, Byungho An <bh74.an@samsung.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Ming Lei <ming.lei@canonical.com>,
	linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <1422239858-3452-3-git-send-email-ming.lei@canonical.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--UoAUwrn7CUxkeqV6baeqQrvRaw4F63wkv
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

Am 26.01.2015 um 03:37 schrieb Ming Lei:
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 8c6b7c16..ddb4351 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -847,8 +847,11 @@ static int stmmac_init_phy(struct net_device *dev)=

>  	 * 0 rather than 0xffff. Catch this here and treat 0 as a non-existen=
t
>  	 * device as well.
>  	 * Note: phydev->phy_id is the result of reading the UID PHY register=
s.
> +	 * But phy_id returned from fixed phy is always zero, so bypass the
> +	 * check for fixed phy.
>  	 */
> -	if (phydev->phy_id =3D=3D 0) {
> +	if (phydev->phy_id =3D=3D 0 && (!priv->plat->phy_bus_name ||
> +			strcmp(priv->plat->phy_bus_name,"fixed"))) {

Small nit here: There's a space missing between the arguments.

Cheers,
Andreas

>  		phy_disconnect(phydev);
>  		return -ENODEV;
>  	}
[snip]

--=20
SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=FCrnberg, Germany
GF: Felix Imend=F6rffer, Jane Smithard, Jennifer Guild, Dilip Upmanyu,
Graham Norton; HRB 21284 (AG N=FCrnberg)


--UoAUwrn7CUxkeqV6baeqQrvRaw4F63wkv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUxa4rAAoJEPou0S0+fgE/ZKoQAJBv1p2oQL2UR+uyUKXQ1NgL
m/GBLBncN9U0YHuehPqX0QaXAEz1LYZAnuAGmVpxWaDRg7x5BguBbiMOz9I5/Olp
bHgi+YZGb2mZKrEGnXvDjsXQSlbur2lNtTI/bqohyvj3++/85ftzFnlJk4lzUFOZ
4WcY9p9hITvzjeRfH1EW0jr+TX8AxPvikz5krtFYQYPwkpHbqqddpvJohI6jwQ5X
Ad5VHqIGoLCUvUoFdWnTP5TnLe6HN7zE1NhlE4DBbzKu+UEVuBBb3NP+BNsZtaeu
j2ZOqeMfdapoWtRyhRBO38lrkZ9eO0J9HvJE+l0SDC41+A0utHuSp8LtxJnN7voS
sEya9wolPqvc6QGfH/GhqTmV0QfTMoF5Ct2TMkYVRUtHJpJP+x09x+KxACeZJNg6
tkfZb3s4V/qlOmmyGbGjYT1usqaMECxpemuEPbYDwEn4MVsCIb+BLuJP9/IO2Pzf
vFOHiTTgH87t/fCrAsz5UwPrkZWOgr52WyquOM6n9P732ByFsbKNgcQwR1OGt/ib
Y6ZVvTExwlkwKznWuTXGXeI+GjRuKpa1VUVE3qd0RWhVV5dayZ+wpO5+Owo0d4yL
xvfIzIwHbAUFIknLtk+eC8G2zF9dxGImQ6PH9lCG0SD1sor2md1fdtrEoBw6pf/t
kQu7jHglvdUyc+bDllkM
=NGlL
-----END PGP SIGNATURE-----

--UoAUwrn7CUxkeqV6baeqQrvRaw4F63wkv--
