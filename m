From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [2.6 patch] hostap_{pci,plx}.c: fix memory leaks
Date: Tue, 14 Mar 2006 15:30:20 +0100
Message-ID: <200603141530.20901.mb@bu3sch.de>
References: <20060313222841.GQ13973@stusta.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart42314815.A9ZDOVLyYl";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: jkmaline@cc.hut.fi, hostap@shmoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751002AbWCNOad@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060313222841.GQ13973@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart42314815.A9ZDOVLyYl
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 13 March 2006 23:28, you wrote:
> This patch fixes two memotry leaks spotted by the Coverity checker.
>=20
>=20
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
>=20
> ---
>=20
>  drivers/net/wireless/hostap/hostap_pci.c |    6 +++---
>  drivers/net/wireless/hostap/hostap_plx.c |    6 +++---
>  2 files changed, 6 insertions(+), 6 deletions(-)
>=20
> --- linux-2.6.16-rc6-mm1-full/drivers/net/wireless/hostap/hostap_pci.c.ol=
d	2006-03-13 22:34:30.000000000 +0100
> +++ linux-2.6.16-rc6-mm1-full/drivers/net/wireless/hostap/hostap_pci.c	20=
06-03-13 22:37:57.000000000 +0100
> @@ -301,14 +301,14 @@ static int prism2_pci_probe(struct pci_d
>  	struct hostap_interface *iface;
>  	struct hostap_pci_priv *hw_priv;
> =20
> +	if (pci_enable_device(pdev))
> +		return -EIO;
> +
>  	hw_priv =3D kmalloc(sizeof(*hw_priv), GFP_KERNEL);
>  	if (hw_priv =3D=3D NULL)

+               pci_disable_device(pdev);

>  		return -ENOMEM;
>  	memset(hw_priv, 0, sizeof(*hw_priv));
> =20
> -	if (pci_enable_device(pdev))
> -		return -EIO;
> -
>  	phymem =3D pci_resource_start(pdev, 0);
> =20
>  	if (!request_mem_region(phymem, pci_resource_len(pdev, 0), "Prism2")) {
> --- linux-2.6.16-rc6-mm1-full/drivers/net/wireless/hostap/hostap_plx.c.ol=
d	2006-03-13 22:39:40.000000000 +0100
> +++ linux-2.6.16-rc6-mm1-full/drivers/net/wireless/hostap/hostap_plx.c	20=
06-03-13 22:40:09.000000000 +0100
> @@ -446,14 +446,14 @@ static int prism2_plx_probe(struct pci_d
>  	int tmd7160;
>  	struct hostap_plx_priv *hw_priv;
> =20
> +	if (pci_enable_device(pdev))
> +		return -EIO;
> +
>  	hw_priv =3D kmalloc(sizeof(*hw_priv), GFP_KERNEL);
>  	if (hw_priv =3D=3D NULL)

Seems like pci_disable_device should be done here, too.

>  		return -ENOMEM;
>  	memset(hw_priv, 0, sizeof(*hw_priv));
> =20
> -	if (pci_enable_device(pdev))
> -		return -EIO;
> -
>  	/* National Datacomm NCP130 based on TMD7160, not PLX9052. */
>  	tmd7160 =3D (pdev->vendor =3D=3D 0x15e8) && (pdev->device =3D=3D 0x0131=
);

=2D-=20
Greetings Michael.

--nextPart42314815.A9ZDOVLyYl
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.1 (GNU/Linux)

iD8DBQBEFtN8lb09HEdWDKgRAlyNAJsGh7BkxnBz5QlC9pBiTk7YWvKKvwCgjdks
qZqO0eX+QIJ6iA5myl3ZHGQ=
=Qlfa
-----END PGP SIGNATURE-----

--nextPart42314815.A9ZDOVLyYl--
