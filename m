From: Vitaly Bordug <vbordug@ru.mvista.com>
Subject: Re: [PATCH 4/6] drivers/net/fs_enet: remove null pointer
 dereference
Date: Mon, 12 May 2008 19:37:54 +0400
Message-ID: <20080512193754.70c65c5d@vitb-lp>
References: <Pine.LNX.4.64.0805121537590.3694@ask.diku.dk>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/hmiGCmnL3XGsfEJx71+1DdR";
 protocol="application/pgp-signature"; micalg=PGP-SHA1
Cc: pantelis.antoniou@gmail.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:24899 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751345AbYELPiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 11:38:06 -0400
In-Reply-To: <Pine.LNX.4.64.0805121537590.3694@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/hmiGCmnL3XGsfEJx71+1DdR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 12 May 2008 15:38:26 +0200 (CEST)
Julia Lawall wrote:

> From: Julia Lawall <julia@diku.dk>
Acked-by: Vitaly Bordug <vitb@kernel.crashing.org>

>=20
> The following code appears in the function fs_init_instance in the
> file drivers/net/fs_enet/fs_enet-main.c.
>=20
> 	if (fep->ops =3D=3D NULL) {
> 		printk(KERN_ERR DRV_MODULE_NAME
> 		       ": %s No matching ops found (%d).\n",
> 		       ndev->name, fpi->fs_no);
> 		err =3D -EINVAL;
> 		goto err;
> 	}
>=20
> This code implies that at the point of err, fep->ops can be NULL, so
> an extra test is needed before dereferencing this value.
>=20

>=20
> This problem was found using the following semantic match
> (http://www.emn.fr/x-info/coccinelle/)
>=20
> // <smpl>
> @@
> expression E, E1;
> identifier f;
> statement S1,S2,S3;
> @@
>=20
> * if (E =3D=3D NULL)
> {
>   ... when !=3D if (E =3D=3D NULL) S1 else S2
>       when !=3D E =3D E1
> * E->f
>   ... when any
>   return ...;
> }
> else S3
> // </smpl>
>=20
> Signed-off-by: Julia Lawall <julia@diku.dk>
>=20
> ---
>=20
> diff -u -p a/drivers/net/fs_enet/fs_enet-main.c
> b/drivers/net/fs_enet/fs_enet-main.c ---
> a/drivers/net/fs_enet/fs_enet-main.c	2008-04-27
> 11:41:11.000000000 +0200 +++
> b/drivers/net/fs_enet/fs_enet-main.c	2008-05-12
> 09:41:52.000000000 +0200 @@ -1093,7 +1093,7 @@ err: if (registered)
> unregister_netdev(ndev);=20
> -		if (fep !=3D NULL) {
> +		if (fep && fep->ops) {
>  			(*fep->ops->free_bd)(ndev);
>  			(*fep->ops->cleanup_data)(ndev);
>  		}

--Sig_/hmiGCmnL3XGsfEJx71+1DdR
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEYEARECAAYFAkgoZFoACgkQe8XNc4YXvvj24ACg2SAPJFHf8Clq0jMQJ4ks/qQp
RH0AniPgTxfpG+GBzSI2xN+xgIT5CMuR
=QP9p
-----END PGP SIGNATURE-----

--Sig_/hmiGCmnL3XGsfEJx71+1DdR--
