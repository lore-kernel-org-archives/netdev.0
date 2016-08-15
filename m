From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v2 0/3] VSOCK: vsockmon virtual device to monitor
 AF_VSOCK sockets.
Date: Mon, 15 Aug 2016 16:13:26 +0100
Message-ID: <20160815151326.GE3598@stefanha-x1.localdomain>
References: <20160813102154.14338-1-ggarcia@deic.uab.cat>
 <20160814231538.jihsj54ft7aftvdf@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gMR3gsNFwZpnI/Ts"
Cc: ggarcia@abra.uab.cat, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932449AbcHOPN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2016 11:13:28 -0400
Content-Disposition: inline
In-Reply-To: <20160814231538.jihsj54ft7aftvdf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gMR3gsNFwZpnI/Ts
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 15, 2016 at 02:15:38AM +0300, Michael S. Tsirkin wrote:
> On Sat, Aug 13, 2016 at 12:21:51PM +0200, ggarcia@abra.uab.cat wrote:
> > From: Gerard Garcia <ggarcia@deic.uab.cat>
> >=20
> > This patch applies over the mst vhost git repository:
> > http://git.kernel.org/cgit/linux/kernel/git/mst/vhost.git
>=20
> So I do like where this is going, but it gives me pause
> that there's a global list of taps, where all sockets
> seem to multicast to them all.
>=20
> In particular, this won't play well with things
> like containers.

vsock currently has no network namespace support.  I agree that the tap
instances should be per-namespace when we add namespace support.

> As each socket is bound to a physical device, how about binding
> the monitor there as well?

Sockets aren't bound to physical devices, they are bound globally in the
af_vsock.ko module.  The module currently doesn't allow multiple
instances (you cannot have multiple VMCI or virtio transports).

> Only sockets from this device
> would do the forwarding, and only one monitor per
> device would be supported.
>=20
> In a sense this will make it more like macvtap than tap.

Restricting the number of monitors could make userspace cumbersome.
Imagine two scripts that want to capture packets.  The two scripts have
no knowledge of each other and create their own vsockmon interfaces.  If
we restrict vsockmon to just 1 interface then users need to agree on
sharing just 1 vsockmon interface.  I don't think this is beneficial.

So I think this global list is acceptable until we introduce network
namespace support.  At that point it will become per-namespace.

Stefan

--gMR3gsNFwZpnI/Ts
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXsdwWAAoJEJykq7OBq3PIOYgIAKY5i95WiWS+f15q4OFrla7e
daxO4ezmEGb3wKgUpwpiPmlfuxwcn6XoQWxN/xI73USYWfnAGVOF4QwTYSahE1wl
LySamVxBgc9b2s9JtmNRyqJmPFzR7e/33CGHNWiXr04ZDHvvquPYygro8yRPjYGF
+SflRFIQY9yIkaguL6/xQv2Uk+PbOI7ESxiqMeIOxoogeBPTR5fW14Pf08RDcA6G
bFc2WzjXj+3B3OuRYf9t7YA9LGCAZZnd//uKyP4pR6BJ/JElkocajLp21LKslQM+
8KGi/UI5AlJOZ82HtjRpwoL1c5FdQXfpc4akr7Oe61CgN1qAGL92Sq07VpqSAPQ=
=GMnP
-----END PGP SIGNATURE-----

--gMR3gsNFwZpnI/Ts--
