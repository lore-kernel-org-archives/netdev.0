From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH] rio: warn_unused_result warnings fix
Date: Tue, 28 Apr 2009 20:51:22 +1000
Message-ID: <1240915882.15414.3.camel@localhost>
References: <2a27d3730904280316l7049bddbie914907b16ccfff6@mail.gmail.com>
	 <1240913737-23773-1-git-send-email-leoli@freescale.com>
	 <1240913737-23773-2-git-send-email-leoli@freescale.com>
	 <1240913737-23773-3-git-send-email-leoli@freescale.com>
	 <1240913737-23773-4-git-send-email-leoli@freescale.com>
	 <1240913737-23773-5-git-send-email-leoli@freescale.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-OdvJ9k/N8AGJspQ0lAI/"
Cc: akpm@linux-foundation.org, galak@kernel.crashing.org,
	davem@davemloft.net, mporter@kernel.crashing.org,
	linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bilbo.ozlabs.org ([203.10.76.25]:38001 "EHLO bilbo.ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbZD1KvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 06:51:24 -0400
In-Reply-To: <1240913737-23773-5-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OdvJ9k/N8AGJspQ0lAI/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-04-28 at 18:15 +0800, Li Yang wrote:
> warning: ignoring return value of 'device_add', declared with attribute w=
arn_unused_result
> warning: ignoring return value of 'sysfs_create_bin_file', declared with =
attribute warn_unused_result
>=20
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
>  drivers/rapidio/rio-scan.c  |    5 ++++-
>  drivers/rapidio/rio-sysfs.c |    6 ++++--
>  2 files changed, 8 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/rapidio/rio-scan.c b/drivers/rapidio/rio-scan.c
> index 74d0bfa..9309e24 100644
> --- a/drivers/rapidio/rio-scan.c
> +++ b/drivers/rapidio/rio-scan.c
> @@ -265,7 +265,10 @@ static void rio_route_set_ops(struct rio_dev *rdev)
>   */
>  static void __devinit rio_add_device(struct rio_dev *rdev)
>  {
> -	device_add(&rdev->dev);
> +	int err;
> +
> +	err =3D device_add(&rdev->dev);
> +	WARN_ON(err);
> =20
>  	spin_lock(&rio_global_list_lock);
>  	list_add_tail(&rdev->global_list, &rio_devices);

Is that really useful? Why not return the error to rio_setup_device()
which can tell it's caller.

cheers

--=-OdvJ9k/N8AGJspQ0lAI/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkn236oACgkQdSjSd0sB4dLRVQCfZBsUfUFtOG4FjDmc8WfwpUYn
LG8AoLdA+sjSxdDmbFUMcgPQ0Bp3mtMU
=UsnV
-----END PGP SIGNATURE-----

--=-OdvJ9k/N8AGJspQ0lAI/--

