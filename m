From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v4 3/3] VSOCK: Add virtio vsock vsockmon hooks
Date: Thu, 20 Apr 2017 15:24:11 +0100
Message-ID: <20170420142411.GA28450@stefanha-x1.localdomain>
References: <20170413161811.8953-1-stefanha@redhat.com>
 <20170413161811.8953-4-stefanha@redhat.com>
 <5E1B910C-0113-494A-A46D-41F9686BD525@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="azLHFNyN32YCQGCU"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Zhu Yanjun <zyjzyj2000@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>
To: "Jorgen S. Hansen" <jhansen@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33980 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032421AbdDTOYP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 10:24:15 -0400
Content-Disposition: inline
In-Reply-To: <5E1B910C-0113-494A-A46D-41F9686BD525@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 20, 2017 at 12:35:40PM +0000, Jorgen S. Hansen wrote:
> >=20
> > +/* Packet capture */
> > +void virtio_transport_deliver_tap_pkt(struct virtio_vsock_pkt *pkt)
> > +{
> > +	struct sk_buff *skb;
> > +	struct af_vsockmon_hdr *hdr;
> > +	unsigned char *t_hdr, *payload;
> > +
> > +	skb =3D alloc_skb(sizeof(*hdr) + sizeof(pkt->hdr) + pkt->len,
> > +			GFP_ATOMIC);
>=20
> So with the current API, an skb will always be allocated, even if there a=
re no listeners? And we=E2=80=99ll copy the payload into the skb as well, i=
f there is any. Would it make sense to introduce a check here (exposed as p=
art of the vsock tap API), that skips all that in the case of no listeners?=
 In the common case, there won=E2=80=99t be any listeners, so it would save=
 some cycles.

Good point, will fix.

--azLHFNyN32YCQGCU
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJY+MSKAAoJEJykq7OBq3PIu0AH/j+rL9kmlQCjfWmE4SS4hFLs
bvjY6VqrxUg+GcVk6S51VTe/uB2/TX1ZMwbWpiAEfMYoj0+DQ5PyEQCoo9VJ73H7
t8su3wxwnuESPrrI5vEm31KE0tbKmcpyY+hI3PazCRFt1XkM3G/54fiKzCXjo0+F
BmGBNuHJCabkjO82R4VBa2lvVs29FN2clwgbO4+uDQc1dA3ULzz5unBdbMtagfm7
Ns8GfcdUax5+ncci9TrYWIvqX05YsvycR5aBD4Z2zJrYkZAddgL0U5Le6xZNFY4T
j4uNmS1MIytgZ7RSPcAK22MoexVnH8O3vWFKrxuuP9SiKWjoU4KFWNlMx2U2PgY=
=5tGO
-----END PGP SIGNATURE-----

--azLHFNyN32YCQGCU--
