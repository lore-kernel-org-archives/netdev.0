From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH net-next] vxlan: correctly set vxlan->net when creating
 the device in a netns
Date: Mon, 3 Jul 2017 10:13:23 +0200
Message-ID: <1ef83529-2ab5-5380-40c0-a68b78ca860a@universe-factory.net>
References: <a21c497947fa98741df864ec4a855d121f8054cc.1498830270.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="PaQWEDxOPPqC2VQ3Tl8dq7Lq69pwdp6K0"
To: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([31.24.148.19]:40536 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752364AbdGCINZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 04:13:25 -0400
In-Reply-To: <a21c497947fa98741df864ec4a855d121f8054cc.1498830270.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--PaQWEDxOPPqC2VQ3Tl8dq7Lq69pwdp6K0
Content-Type: multipart/mixed; boundary="V11r4VowWNkuu9S1hQAVwoVXDADo7xhnP";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer@universe-factory.net>
To: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
Message-ID: <1ef83529-2ab5-5380-40c0-a68b78ca860a@universe-factory.net>
Subject: Re: [PATCH net-next] vxlan: correctly set vxlan->net when creating
 the device in a netns
References: <a21c497947fa98741df864ec4a855d121f8054cc.1498830270.git.sd@queasysnail.net>
In-Reply-To: <a21c497947fa98741df864ec4a855d121f8054cc.1498830270.git.sd@queasysnail.net>

--V11r4VowWNkuu9S1hQAVwoVXDADo7xhnP
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 06/30/2017 03:50 PM, Sabrina Dubroca wrote:
> Commit a985343ba906 ("vxlan: refactor verification and application of
> configuration") modified vxlan device creation, and replaced the
> assignment of vxlan->net to src_net with dev_net(netdev) in ->setup().
>=20
> But dev_net(netdev) is not the same as src_net. At the time ->setup()
> is called, dev_net hasn't been set yet, so we end up creating the
> socket for the vxlan device in init_net.
>=20
> Fix this by bringing back the assignment of vxlan->net during device
> creation.
>=20
> Fixes: a985343ba906 ("vxlan: refactor verification and application of c=
onfiguration")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Thanks for fixing this up, I really didn't expect dev_net() not to return=

the correct net in setup().

Reviewed-by: Matthias Schiffer <mschiffer@universe-factory.net>


> ---
>  drivers/net/vxlan.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index fd0ff97e3d81..47d6e65851aa 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2656,7 +2656,6 @@ static void vxlan_setup(struct net_device *dev)
>  	vxlan->age_timer.data =3D (unsigned long) vxlan;
> =20
>  	vxlan->dev =3D dev;
> -	vxlan->net =3D dev_net(dev);
> =20
>  	gro_cells_init(&vxlan->gro_cells, dev);
> =20
> @@ -3028,7 +3027,9 @@ static int vxlan_config_validate(struct net *src_=
net, struct vxlan_config *conf,
> =20
>  static void vxlan_config_apply(struct net_device *dev,
>  			       struct vxlan_config *conf,
> -			       struct net_device *lowerdev, bool changelink)
> +			       struct net_device *lowerdev,
> +			       struct net *src_net,
> +			       bool changelink)
>  {
>  	struct vxlan_dev *vxlan =3D netdev_priv(dev);
>  	struct vxlan_rdst *dst =3D &vxlan->default_dst;
> @@ -3044,6 +3045,8 @@ static void vxlan_config_apply(struct net_device =
*dev,
> =20
>  		if (conf->mtu)
>  			dev->mtu =3D conf->mtu;
> +
> +		vxlan->net =3D src_net;
>  	}
> =20
>  	dst->remote_vni =3D conf->vni;
> @@ -3086,7 +3089,7 @@ static int vxlan_dev_configure(struct net *src_ne=
t, struct net_device *dev,
>  	if (ret)
>  		return ret;
> =20
> -	vxlan_config_apply(dev, conf, lowerdev, changelink);
> +	vxlan_config_apply(dev, conf, lowerdev, src_net, changelink);
> =20
>  	return 0;
>  }
>=20



--V11r4VowWNkuu9S1hQAVwoVXDADo7xhnP--

--PaQWEDxOPPqC2VQ3Tl8dq7Lq69pwdp6K0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEZmTnvaa2aYgexS51Fu8/ZMsgHZwFAllZ/KMACgkQFu8/ZMsg
HZznMQ//fzFEG0gOumdrJm3S/3kFLvR9zvYQVBK4NRUHmm8coP9BHVI5j1Lps27J
qdhTRlBljYZ/9LJvNHAjB1ZWjOUvi/0Rfo157l3DrTVU5T+R4zJCqfAhkD+/gVC2
XjXtxtlmI+oh6pwEYUAycZhK7XyJdXm62cRzhoGpaGJCe2Op+EqjIVJUYuAzqAvd
b7zKTaKADqs/tYooNEswJD+UEpZbo5lrYNTtA3IhB6L0BMUJ39OTmSQvCUP6/jpq
My+UWIAgDrzwR3hWUNHAWw7NyZFP0VGTO8HKgIEIaD48EwcP1AarWARv6n0Y03Dq
PuWLU0YOkAOcFfsxcxrWWjLSIZpOL8wg7zjPyMW2YR2KAgkAn/VrnqaEK2a9UH5i
/fV9KfqDpv7aC79ZZmdYFNebKTcHVW1VfBGUgb3Vko7DkC4ixhyamiuWJlPRf6vl
Edm9ohRU/p5F08NaZ8OWiCuzTVWxCimTHbDMrhzs4juHs4mQjuJJDTEAa0w5q1qB
7mQIbk2eDhEaj3gjzi3tAi552F1yFvhXCvaVmBWtA22qMK7znRUd1qttRXS25zEF
4tGVX1kWIWCsFJB2MhgORt0azWp3VR7sdVaZjStn2bSPUPQAqzHHorJQE5tSd9Iz
9MebuLv01QVCh8LqlCZe+WKBOwH8slANnfbB8PuJSPKbBK45O3Q=
=U+QH
-----END PGP SIGNATURE-----

--PaQWEDxOPPqC2VQ3Tl8dq7Lq69pwdp6K0--
