From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 2/3] vsockmon: Add vsockmon device.
Date: Wed, 10 Aug 2016 12:51:58 +0100
Message-ID: <20160810115158.GB10461@stefanha-x1.localdomain>
References: <20160808161442.16038-1-ggarcia@deic.uab.cat>
 <20160808161442.16038-3-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="8P1HSweYDcXXzwPJ"
Cc: netdev@vger.kernel.org, jhansen@vmware.com, mst@redhat.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48384 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935790AbcHJTBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 15:01:23 -0400
Content-Disposition: inline
In-Reply-To: <20160808161442.16038-3-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--8P1HSweYDcXXzwPJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 08, 2016 at 06:14:41PM +0200, ggarcia@abra.uab.cat wrote:
> diff --git a/include/uapi/linux/vsockmon.h b/include/uapi/linux/vsockmon.h
> new file mode 100644
> index 0000000..739b4bf
> --- /dev/null
> +++ b/include/uapi/linux/vsockmon.h
> @@ -0,0 +1,35 @@
> +#ifndef _UAPI_VSOCKMON_H
> +#define _UAPI_VSOCKMON_H
> +
> +#include <linux/virtio_vsock.h>
> +
> +/* Structure of packets received trought the vsockmon device. */
> +
> +struct af_vsockmon_hdr {
> +	__le64 src_cid;
> +	__le64 dst_cid;
> +	__le32 src_port;
> +	__le32 dst_port;
> +	__le16 op;			/* enum af_vsockmon_op */
> +	__le16 t;			/* enum af_vosckmon_t */
> +	__le16 len;			/* sizeof(t_hdr) */
> +	union {
> +		struct virtio_vsock_hdr virtio_hdr;
> +	} t_hdr;
> +} __attribute__((packed));

This struct will change in size if/when VMCI transport support is added.
Existing binaries that were complied against the old header file would
use an incorrect size.

It would be cleaner to drop t_hdr from the struct and force users to
explicitly use af_vsockmon_hdr.len to handle the size of the headers.

--8P1HSweYDcXXzwPJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXqxVeAAoJEJykq7OBq3PIwEwH/i2V+kDhmnJLkz4vpZm/cZ++
bPr9+z0FiCkrycPhNMYYxfILEt0Jp2QUlkOxvbob1oY7ufiFPWSeyIhuzkdjZ5tD
9chKQbCTRxumiwKkzD84v6fXyRm+UXX68vmaSJKe+xeMWWyuiUEGh9hYcc6kS7nX
o8NpQt5lxYQQWxGgcnQMsINP9DgdHUFpSM5FMa4M1IOUmUM2s3sG6hzR/iBc75Xe
57lQ2ZndNmpWpKZfQ+oKoGBmuryxRfiyvVbB5/3dYkNRgvglA4/ktyoBZXphRiSu
zzzO5jjAab7069GVI1wE7YI7sz3LcTLr6B/Mv3oElIiYqKI8T+ToMZauJD/0iuI=
=QR3a
-----END PGP SIGNATURE-----

--8P1HSweYDcXXzwPJ--
