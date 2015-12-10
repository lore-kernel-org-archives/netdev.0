From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [patch -next] VSOCK: signedness bug in
 virtio_transport_dgram_enqueue()
Date: Thu, 10 Dec 2015 10:21:12 +0800
Message-ID: <20151210022112.GB9577@stefanha-x1.localdomain>
References: <20151209102713.GG3173@mwanda>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eAbsdosE1cNLO4uF"
Cc: "David S. Miller" <davem@davemloft.net>,
	Asias He <asias@redhat.com>, Ray Jui <rjui@broadcom.com>,
	Scott Branden <sbranden@broadcom.com>,
	Jon Mason <jonmason@broadcom.com>, netdev@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875AbbLJCVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 21:21:18 -0500
Content-Disposition: inline
In-Reply-To: <20151209102713.GG3173@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--eAbsdosE1cNLO4uF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 09, 2015 at 01:27:13PM +0300, Dan Carpenter wrote:
> "written" has to be signed for the error handling to work.
> trans->ops->send_pkt() returns an int so that's fine.
>=20
> Fixes: 80a19e338d45 ('VSOCK: Introduce virtio-vsock-common.ko')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>=20
> diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virt=
io_transport_common.c
> index 28f790d..d9a2325 100644
> --- a/net/vmw_vsock/virtio_transport_common.c
> +++ b/net/vmw_vsock/virtio_transport_common.c
> @@ -815,7 +815,8 @@ virtio_transport_dgram_enqueue(struct vsock_sock *vsk,
>  		.type =3D VIRTIO_VSOCK_TYPE_DGRAM,
>  		.msg =3D msg,
>  	};
> -	size_t total_written =3D 0, pkt_off =3D 0, written;
> +	size_t total_written =3D 0, pkt_off =3D 0;
> +	int written;
>  	u16 dgram_id;
> =20
>  	/* The max size of a single dgram we support is 64KB */
> @@ -845,7 +846,7 @@ virtio_transport_dgram_enqueue(struct vsock_sock *vsk,
>  		}
>  		total_written +=3D written;
>  		pkt_off +=3D written;
> -		pr_debug("%s:id=3D%d, dgram_len=3D%zu, off=3D%zu, total_written=3D%zu,=
 written=3D%zu\n",
> +		pr_debug("%s:id=3D%d, dgram_len=3D%zu, off=3D%zu, total_written=3D%zu,=
 written=3D%d\n",
>  			  __func__, dgram_id, dgram_len, pkt_off, total_written, written);
>  	}
> =20

Thanks!

The dgram functionality has been dropped in the latest patch revision
but I'll keep your fix in mind if it's brought back.

Stefan

--eAbsdosE1cNLO4uF
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJWaOGYAAoJEJykq7OBq3PIrnEH/3TZVkB37oyI4pHJk/dfUNYt
7bFi/LZMFNcBmeghQjSY92GPMBCQnVu2mLSHIbRC3ZCm2GolQMXmQj6z6pZ59ukk
EHJrRaINCdNdXwCvuME6CPEGxbgU19WNlCxi88YgzYwViaa9P8UFocfwZYXvN1F4
iTGkxMFdUAc1XQqitXTiI4ty+2lu7WM303VIZ1NuPKE+CMSu4YH1zdDH21RO9jry
jM/UM1a8geJZctgBNnh0utQgbKjxy8G5fD7Xvv3dogV+tRGRt9KfdZGsLEavP4UB
Bfm4Y+TWE20JIJ2FAm274xoaSwXbm/p4OvErWXyGhUIg41eMCTll+UnEyAfb9uE=
=3zeQ
-----END PGP SIGNATURE-----

--eAbsdosE1cNLO4uF--
