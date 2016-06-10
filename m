From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [RFC 2/3] vsockmon: Add vsockmon device
Date: Fri, 10 Jun 2016 16:37:09 +0100
Message-ID: <20160610153709.GD3855@stefanha-x1.localdomain>
References: <20160528162907.14809-1-ggarcia@deic.uab.cat>
 <20160528162907.14809-3-ggarcia@deic.uab.cat>
 <20160601211554.GG15594@stefanha-x1.localdomain>
 <d5141c2f-0558-2b1b-9089-4901d54e5beb@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DiL7RhKs8rK9YGuF"
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: Gerard Garcia <ggarcia@abra.uab.cat>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57185 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932099AbcFJPhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 11:37:13 -0400
Content-Disposition: inline
In-Reply-To: <d5141c2f-0558-2b1b-9089-4901d54e5beb@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DiL7RhKs8rK9YGuF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 09, 2016 at 05:21:26PM +0200, Gerard Garcia wrote:
> > > diff --git a/include/uapi/linux/vsockmon.h b/include/uapi/linux/vsockmon.h
> > > new file mode 100644
> > > index 0000000..c73166f
> > > --- /dev/null
> > > +++ b/include/uapi/linux/vsockmon.h
> > > @@ -0,0 +1,37 @@
> > > +#ifndef _UAPI_VSOCKMON_H
> > > +#define _UAPI_VSOCKMON_H
> > > +
> > > +#include <linux/virtio_vsock.h>
> > > +
> > > +/* Packet structure of packets received from the vsockmon device. */
> > > +
> > > +struct af_vsockmon_g {
> > > +	unsigned short op; /* enum af_vsock_g_ops */
> > > +	unsigned int src_cid;
> > > +	unsigned int src_port;
> > > +	unsigned int dst_cid;
> > > +	unsigned int dst_port;
> > > +};
> > > +
> > > +struct af_vsockmon_hdr {
> > > +	unsigned short type;  /* enum af_vosck_type */
> > > +	struct af_vsockmon_g g_hdr;
> > > +	union {
> > > +		struct virtio_vsock_hdr virtio_hdr;
> > > +	} t_hdr;
> > > +};
> > How does endianness work?  virtio_hdr uses little-endian fields on the
> > wire.  I guess that af_vsockmon_g is always CPU-endian.
> Yes, af_vsockmon_g is CPU-endian. I don't know what criteria is normally
> used regarding the endianness of structs facing user space but I think it is
> better to not modify the vsock transport structs.

Endianness must to be documented in this uapi header file.

--DiL7RhKs8rK9YGuF
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXWt6lAAoJEJykq7OBq3PILDEH/3z24qmgG8htPZNhN/PSPs1r
52u67nSjmBAkWAbo3TGTIg7wT1GSy8yms8v/XaMlN0sW9kpJR5jjkGLA8whvsvqt
UWS/kSo3K7Vu43Pc290jU8tijRU1eMSEFzHoWjIH41K0ZdnoMUg2Q/AmRgDCO8E1
fZ1DA0HqIY1tGISuejxaa9UQd/jTABqHgbH0xSH/kiKzgQ+DpF0Oahum/JMvPm6M
TtpI15zDJEOGfpAB0a4Qhmgmfh721ht5DYwn5yOCnUavZjtFyvgXtzdoFtvkv8kH
LT6uMRdZbFrSgih4V84avb9HkiQCQngrbcaj1uYqF/ljrklJVZ8WL8UJAip4sN8=
=/T4e
-----END PGP SIGNATURE-----

--DiL7RhKs8rK9YGuF--
