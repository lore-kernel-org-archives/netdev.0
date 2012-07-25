From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 08/17] Tools: hv: Gather subnet information
Date: Wed, 25 Jul 2012 02:14:10 +0100
Message-ID: <1343178850.5132.104.camel@deadeye.wl.decadent.org.uk>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
	 <1343145701-3691-1-git-send-email-kys@microsoft.com>
	 <1343145701-3691-8-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-CztLO7lyHO6O/+a0jcPJ"
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, virtualization@lists.osdl.org,
	olaf@aepfle.de, apw@canonical.com, netdev@vger.kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343145701-3691-8-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-CztLO7lyHO6O/+a0jcPJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-07-24 at 09:01 -0700, K. Y. Srinivasan wrote:
> Now gather sub-net information for the specified interface.
>=20
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> ---
>  tools/hv/hv_kvp_daemon.c |   31 +++++++++++++++++++++++++++++--
>  1 files changed, 29 insertions(+), 2 deletions(-)
>=20
> diff --git a/tools/hv/hv_kvp_daemon.c b/tools/hv/hv_kvp_daemon.c
> index 79eb130..2c24ebf 100644
> --- a/tools/hv/hv_kvp_daemon.c
> +++ b/tools/hv/hv_kvp_daemon.c
> @@ -534,6 +534,7 @@ kvp_get_ip_address(int family, char *if_name, int op,
>  	struct ifaddrs *ifap;
>  	struct ifaddrs *curp;
>  	int offset =3D 0;
> +	int sn_offset =3D 0;
>  	const char *str;
>  	int error =3D 0;
>  	char *buffer;
> @@ -594,12 +595,38 @@ kvp_get_ip_address(int family, char *if_name, int o=
p,
>  			 * Gather info other than the IP address.
>  			 * IP address info will be gathered later.
>  			 */
> -			if (curp->ifa_addr->sa_family =3D=3D AF_INET)
> +			if (curp->ifa_addr->sa_family =3D=3D AF_INET) {
>  				ip_buffer->addr_family |=3D ADDR_FAMILY_IPV4;
> -			else
> +				/*
> +				 * Get subnet info.
> +				 */
> +				error =3D kvp_process_ip_address(
> +							curp->ifa_netmask,
> +							AF_INET,
> +							(char *)
> +							ip_buffer->sub_net,
> +							length,
> +							&sn_offset);
[...]

This is barely readable; why don't you indent the arguments by just one
extra tab?

Ben.

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-CztLO7lyHO6O/+a0jcPJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUA9IYue/yOyVhhEJAQrpZA/9EvExDzDkOOJJlaBh4QQLIe1dPtFKgHXD
nI8T2davGVcX0l1N5WEb2X1j1jRp5xDKCT2zy2YnT5y2ESNHL9oWDPzh5wNN0iEU
WcZDhFDTiODi1y1N0nPFkv4rAUUF79i5z31e1LJKCwajcy9LYMOxwvHE9yRJUMyM
wyAglCyHgkMqZX/pp4/nkJ9H7kPRkvzSs852cQ4hPPOQLx+B4or76xWarCLoeQrN
1LZ+rO1NDKFIDrvZH1onfo8y2imQLKUyp2gU/XuxlwniRnUyr+rnYY2Ac9BpyRUv
VMHlW3sd9TAm+4FKkqFd5xxppq7AICO30F4eoFQs1iITZHzMxuYJscvAlWXRtr8F
ij4ZaUIEW3eoOS2FOas/j5Adn9+wq8uWzf2gZibQl39m3x2wsR41lDF/5QGlgPJw
9smam9bA91xzNeUcDEavYoczdBdq9q3U1nmdl/yNgk7zG0zMjH+l6oJUOWj1mg4L
EgccKeYO29DxjFf4QlsuIm9XIaMKIxTlkEy3O532xkIArqd2p9V6rQirU/6uhkSh
T3vQ8+sDEz1dnJD0ux1Bkex33DTeyNLZXbDmf5erXMeD+60hST4h5ual2QqbdSlL
KqGewOIcPkjPBnsxj3HvHz45R+kKJn1WcyVTfJ53IotWG03M9XVcZJ7SZxiz3/Vk
fPaFLojeTxQ=
=XCv7
-----END PGP SIGNATURE-----

--=-CztLO7lyHO6O/+a0jcPJ--
