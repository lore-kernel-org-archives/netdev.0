From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v2 1/1] VSOCK: remove more space available check filling
 TX vq
Date: Mon, 15 Aug 2016 15:29:21 +0100
Message-ID: <20160815142921.GC3598@stefanha-x1.localdomain>
References: <20160810152434.14346-1-ggarcia@deic.uab.cat>
 <20160815021607-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="R+My9LyyhiUvIEro"
Cc: ggarcia@abra.uab.cat, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752646AbcHOO3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2016 10:29:24 -0400
Content-Disposition: inline
In-Reply-To: <20160815021607-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--R+My9LyyhiUvIEro
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 15, 2016 at 02:16:51AM +0300, Michael S. Tsirkin wrote:
> On Wed, Aug 10, 2016 at 05:24:34PM +0200, ggarcia@abra.uab.cat wrote:
> > From: Gerard Garcia <ggarcia@deic.uab.cat>
> >=20
> > Remove unnecessary use of enable/disable callback notifications
> > and the incorrect more space available check.
> >=20
> > The virtio_transport_tx_work handles when the TX virtqueue
> > has more buffers available.
> >=20
> > Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> > Acked-by: Stefan Hajnoczi <stefanha@redhat.com>
>=20
> Generally enable/disable is a worthwhile optimization,
> but if Stefan wants to keep code simple for now,
> I don't have a problem with that.

Enabling/disabling callbacks is inappropriate in this function because
its job is *submitting* buffers rather than *reclaiming* completed
buffers.  Oops, I'm not sure how this mistake crept in :).

The callback suppression should only be done around the loop that
reclaims buffers.  Doing it in the wrong place leads to hangs if
interrupts are lost.

Stefan

--R+My9LyyhiUvIEro
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXsdHBAAoJEJykq7OBq3PIflwH/R3OgMnhAPwQ2G+Op6y/crlF
1TCtWZDg9IFxxIOUmWxOxR92T0vCTaUhnlGe9MIy1+eh+WLQ1NOdVNQpGnQRMR7B
0e8f10WceceDpJm7PPKahtImoQM0m5BgnKdhrAwyR271SgLKOEiTbGNrXYyCu8sz
IWpcdQQZq333B3w5uv+L0v6CcUEc+dP4dd/Izs/Pjmg4o+v2zHvIxQJe7MtY6zbg
HHtqnkT4KvUdXxs/5fAMDDxsqLeWbqyCTdQXVCilbivcTnPEcNE0zTUpmEgtJcwu
JrhSrE7HHQf8TmPxKKMnlw3dft/3KTaUm57RsoeHSk7x3Z598jEpNPDeS8n5Tzk=
=PIde
-----END PGP SIGNATURE-----

--R+My9LyyhiUvIEro--
