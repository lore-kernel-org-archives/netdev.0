From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 05/10] bnxt_en: Add get_eee() and set_eee()
 ethtool support.
Date: Tue, 05 Apr 2016 11:07:38 +0100
Message-ID: <1459850858.23351.45.camel@decadent.org.uk>
References: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
	 <1459844562-24576-6-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GTWK16QL28OsEEwtVAGy"
Cc: netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45765 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757201AbcDEKHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 06:07:52 -0400
In-Reply-To: <1459844562-24576-6-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GTWK16QL28OsEEwtVAGy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-04-05 at 04:22 -0400, Michael Chan wrote:

> Allow users to get|set EEE parameters.
>=20
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>
> ---
> =C2=A0drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 73 ++++++++++++=
+++++++++++
> =C2=A01 file changed, 73 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/=
net/ethernet/broadcom/bnxt/bnxt_ethtool.c
> index 14f0520..3d5c64f 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
> @@ -1379,6 +1379,77 @@ static int bnxt_set_eeprom(struct net_device *dev,
> =C2=A0				eeprom->len);
> =C2=A0}
> =C2=A0
> +static int bnxt_set_eee(struct net_device *dev, struct ethtool_eee *edat=
a)
> +{
> +	struct bnxt *bp =3D netdev_priv(dev);
> +	struct ethtool_eee *eee =3D &bp->eee;
> +	struct bnxt_link_info *link_info =3D &bp->link_info;
> +	u32 advertising =3D
> +		=C2=A0_bnxt_fw_to_ethtool_adv_spds(link_info->advertising, 0);
> +	int rc =3D 0;
> +
> +	if (BNXT_VF(bp))
> +		return 0;
> +
> +	if (!(bp->flags & BNXT_FLAG_EEE_CAP))
> +		return -EOPNOTSUPP;
> +
> +	if (!edata->eee_enabled)
> +		goto eee_ok;
[...]
> +	eee->advertised =3D edata->advertised;
> +	eee->tx_lpi_enabled =3D edata->tx_lpi_enabled;
> +	eee->tx_lpi_timer =3D edata->tx_lpi_timer;
> +eee_ok:
> +	eee->eee_enabled =3D edata->eee_enabled;
> +
> +	if (netif_running(dev))
> +		rc =3D bnxt_hwrm_set_link_setting(bp, false, true);
> +
> +	return rc;
> +}
> +
> +static int bnxt_get_eee(struct net_device *dev, struct ethtool_eee *edat=
a)
> +{
> +	struct bnxt *bp =3D netdev_priv(dev);
> +
> +	if (!(bp->flags & BNXT_FLAG_EEE_CAP))
> +		return -EOPNOTSUPP;
> +
> +	*edata =3D bp->eee;
> +	if (!bp->eee.eee_enabled) {
> +		edata->advertised =3D 0;
> +		edata->tx_lpi_enabled =3D 0;

What about tx_lpi_timer?

And, wouldn't it make more sense to do these fixups to the internal
state in bnxt_set_eee()?

Ben.

> +	}
> +
> +	if (!bp->eee.eee_active)
> +		edata->lp_advertised =3D 0;
> +
> +	return 0;
> +}
[...]

--=20
Ben Hutchings
No political challenge can be met by shopping. - George Monbiot
--=-GTWK16QL28OsEEwtVAGy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXA45qAAoJEOe/yOyVhhEJ3rAP/j/w6w9lSpIZy3PBvwVRXTGD
7YWE6J8zLsZcxZ/8II35zTmqPPnFI2YJ/sl/nIj4G2ZUwMVI2ozNUo7AgCpN0nD2
M0KKXmBZgZXgaRL6RnazP/xlnX8rzMhu1VdNh7ofwTs9/xpdZ8NEtmbOuKrZV/qr
340Kh+rcQ0cl/gEiJQtONxJqi4AOWiCBfi3wYI3hrHKGHKZutUjRJeMefB5oOPZ0
S7vxYsneIitdguglIKrpWn7Q9WJrdE7Skcmh08edvy0froTR7q4cQJ//k7O2mg1K
xZed/VzQ9ddDaF4N7LYk8t/fBi+kvsWvbgJaieKu3lCl5NMcJYeFXb+NiGMrxKxF
Quta2d+pwOSfLu3hvXqyXUUNRCPnlIVlkkQ4istsklvr52XFuTgQYUnqQ8LsU1tc
AkfgXUZNDDzXvoilsBjUmh+MMnnr4nauOyRJhvp8W+0TcRLBpVE2q3LlZjWsVpAs
/du4f8MsNIHp69QmbqWoHTOuop1YhRBUD+oMbtO/dQ/PFJsvttvezre7BoospHOi
m0XLM/AmALdg5wof9NdkG5zzcB2jcKqB0Ht3ERFuxbQyutYRvVhtQtkgSFnm4l0L
UIFEsIEgYJThfwsLGmbu+uWnVDzCdymgaLdv/VNPsqxztHwdZ92ksIuRDPiWI1Xe
AsZOfRBLrgaAbt4FaM0F
=cZ7w
-----END PGP SIGNATURE-----

--=-GTWK16QL28OsEEwtVAGy--
