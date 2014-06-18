From: Felipe Balbi <balbi@ti.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: fix dual EMAC stall when
 connected to same switch
Date: Wed, 18 Jun 2014 09:52:22 -0500
Message-ID: <20140618145222.GB31420@saruman.home>
References: <1403092308-31380-1-git-send-email-mugunthanvnm@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZoaI/ZTpAVc4A5k6"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Yegor Yefremov <yegorslists@googlemail.com>,
	Felipe Balbi <balbi@ti.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:55678 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbaFROws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 10:52:48 -0400
Content-Disposition: inline
In-Reply-To: <1403092308-31380-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--ZoaI/ZTpAVc4A5k6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 18, 2014 at 05:21:48PM +0530, Mugunthan V N wrote:
> In commit 629c9a8fd0bbdfc6d702526b327470166ec39c6b (drivers: net: cpsw: A=
dd
> default vlan for dual emac case also), api cpsw_add_default_vlan() also
> changes the port vlan which is required to seperate the ports which resul=
ts
> in the following behavior
>=20
> In Dual EMAC mode, when both the Etnernet connected is connected to same
> switch, it creates a loop in the switch and when a broadcast packet is
> received it is forwarded to the other port which stalls the whole switch
> and needs a reset/power cycle to the switch to recover. So intead of using
> the api, add only the default VLAN entry in dual EMAC case.
>=20
> Cc: Yegor Yefremov <yegorslists@googlemail.com>
> Cc: Felipe Balbi <balbi@ti.com>

Tested yesterday on top of next-20140617

Tested-by: Felipe Balbi <balbi@ti.com>

> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cps=
w.c
> index ff380da..b988d16 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1212,7 +1212,12 @@ static int cpsw_ndo_open(struct net_device *ndev)
>  	for_each_slave(priv, cpsw_slave_open, priv);
> =20
>  	/* Add default VLAN */
> -	cpsw_add_default_vlan(priv);
> +	if (!priv->data.dual_emac)
> +		cpsw_add_default_vlan(priv);
> +	else
> +		cpsw_ale_add_vlan(priv->ale, priv->data.default_vlan,
> +				  ALE_ALL_PORTS << priv->host_port,
> +				  ALE_ALL_PORTS << priv->host_port, 0, 0);
> =20
>  	if (!cpsw_common_res_usage_state(priv)) {
>  		/* setup tx dma to fixed prio and zero offset */
> --=20
> 1.9.2.459.g68773ac
>=20

--=20
balbi

--ZoaI/ZTpAVc4A5k6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJToaemAAoJEIaOsuA1yqREVRIP/08sxsr+7ecEhC2rfu7zQxeb
8i3LJo7L7gSy1zKwyCdnbDVn/S/Gz2+Lz7++1wdHvpaFVHnCi++zXyn6fZWzRXSq
c/JidLFQvOuh0RUf9lePzeI2orzMvma+WuO1UWDSusET6e9sXZi8iz3ov7buhf1D
YDZqq7+JoWOSELMF7yKvOkzPIYXA5Y0Nqvplz5fCM49H6Kb5dvp77/GZH3Dl/Cdi
yxHIvrVT2yu7C2meJ6K+8jfonO7Q378yu5JlGsQuSJsR5cF03Wpkel2vOKeOJzoq
dbKEv0Y/AeQQpvcpAma6FNqctGLlJ+5bYwF9O/blos4SzSTnH8eLi5yrrQxEC5ts
RkoH+olXDL/UTAPETleziwo9WvcsgEiHMDlU1cDyHrrttNIHbCdkXO7sTfUxGqMe
J+zIyBsZKB555RwAYe1DYiKM5fXxQvcxYKatyg/giRTdZPzcn++75/lxrQqUe2S+
g387NR9qdXmQcWcXPbgt8XwF1+MxJbc4b4JkiffwMy46lZKF4BjZT0fSx27UdBS/
qEvGSw6T8GYfPhV17/qf+vmiqC5UFAwOfPoZ0zw+RFQFeR6+gHlLeGWZCwoJ3+mz
dndg1yymmx4IFWO3bG3vJTRwwNGOV5XZBvdivVbwPARFuJgAmSZK6Nsy35jP4pux
tlaPPmgPMXiu4gQspHUJ
=jO4V
-----END PGP SIGNATURE-----

--ZoaI/ZTpAVc4A5k6--
