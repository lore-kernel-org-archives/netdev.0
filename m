From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 1/1] virtio-vsock: Fix unbound rx buffer
Date: Thu, 4 Aug 2016 14:38:25 +0100
Message-ID: <20160804133825.GB11522@stefanha-x1.localdomain>
References: <20160801171821.32662-1-ggarcia@deic.uab.cat>
 <20160801171821.32662-2-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UHN/qo2QbUvPLonB"
Cc: netdev@vger.kernel.org
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933618AbcHDNkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 09:40:17 -0400
Content-Disposition: inline
In-Reply-To: <20160801171821.32662-2-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UHN/qo2QbUvPLonB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 01, 2016 at 07:18:21PM +0200, ggarcia@abra.uab.cat wrote:

Besides the other locking issue that was already mentioned:

> diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virt=
io_transport_common.c
> index a53b3a1..3c38d43 100644
> --- a/net/vmw_vsock/virtio_transport_common.c
> +++ b/net/vmw_vsock/virtio_transport_common.c
> @@ -773,13 +773,23 @@ virtio_transport_recv_connected(struct sock *sk,
>  		pkt->len =3D le32_to_cpu(pkt->hdr.len);
>  		pkt->off =3D 0;
> =20
> -		spin_lock_bh(&vvs->rx_lock);
> -		virtio_transport_inc_rx_pkt(vvs, pkt);
> -		list_add_tail(&pkt->list, &vvs->rx_queue);
> -		spin_unlock_bh(&vvs->rx_lock);
> +		if (vvs->rx_bytes + pkt->len <=3D vvs->buf_size) {

vvs->rx_bytes must be accessed under vvs->rx_lock.

--UHN/qo2QbUvPLonB
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXo0VRAAoJEJykq7OBq3PI8vcH/jQ+9LygajUjFonljKwjMxDI
mmLpQGQREi7N8kpGKMQhxQytNGoXBa1atflV7xyeosocX9e7MeoeVpRQqKiq9vpy
V3xnyvIhJ0TZzU7jL1wgTLDB8B6iec0CuR39B4cQK4J0XfNNu3u8swLD8HKuHezp
Z1RCEHbagCkCdwXrgosKCy7mB2iJYjBx8Ef/03fqowHoh25CqYZDFKCIcUKheunH
+8W3rquSIXEMh+zxrDaK5BCsSludTWsJcJ48buOexqDMkC2HR4dlFRa1eRXRkVEt
ysBGFaDYjwNNJpozoz9UF0yU4jfExwBbQo5JEbJAzQjfmQs1D8w2WiNkvoTI0O8=
=7cuP
-----END PGP SIGNATURE-----

--UHN/qo2QbUvPLonB--
