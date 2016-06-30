From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [RFC v2 3/3] vsockmon: Add vsock hooks
Date: Thu, 30 Jun 2016 11:55:27 +0100
Message-ID: <20160630105527.GC31866@stefanha-x1.localdomain>
References: <20160622161102.8250-1-ggarcia@deic.uab.cat>
 <20160622161102.8250-4-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/e2eDi0V/xtL+Mc8"
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38752 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932065AbcF3Kz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 06:55:29 -0400
Content-Disposition: inline
In-Reply-To: <20160622161102.8250-4-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/e2eDi0V/xtL+Mc8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 22, 2016 at 06:11:02PM +0200, ggarcia@abra.uab.cat wrote:
> +	hdr = (struct af_vsockmon_hdr *) skb_push(skb, sizeof(*hdr));
> +
> +	hdr->src_cid = pkt->hdr.src_cid;
> +	hdr->src_port = pkt->hdr.src_port;
> +	hdr->dst_cid = pkt->hdr.dst_cid;
> +	hdr->dst_port = pkt->hdr.dst_port;
> +	hdr->t = AF_VSOCK_T_VIRTIO;
> +
> +	switch(pkt->hdr.op) {
> +		case VIRTIO_VSOCK_OP_REQUEST:
> +		case VIRTIO_VSOCK_OP_RESPONSE:
> +			hdr->op = AF_VSOCK_OP_CONNECT;
> +			break;
> +		case VIRTIO_VSOCK_OP_RST:
> +		case VIRTIO_VSOCK_OP_SHUTDOWN:
> +			hdr->op = AF_VSOCK_OP_DISCONNECT;
> +			break;
> +		case VIRTIO_VSOCK_OP_RW:
> +			hdr->op = AF_VSOCK_OP_PAYLOAD;
> +			break;
> +		case VIRTIO_VSOCK_OP_CREDIT_UPDATE:
> +		case VIRTIO_VSOCK_OP_CREDIT_REQUEST:
> +			hdr->op = AF_VSOCK_OP_CONTROL;
> +			break;
> +		default:
> +			hdr->op = AF_VSOCK_OP_UNKNOWN;
> +			break;
> +	}

hdr->t and hdr->op need cpu_to_le*() to ensure little-endianness.

--/e2eDi0V/xtL+Mc8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXdPqfAAoJEJykq7OBq3PI+U8IAKgJanbxNRr+3z7WCpSOUpso
g7r0p8jdQJt4JxW4dU6X818lI4x/1VuQzIPjJeMzBXyf0JCSsol8IHYnIpw9NaK/
4dHDiFrVRyP0LvqtfzZWFVRKflph1hnA5gr6wPkcEnuUQILpnTs4kf+udIXR4jYA
p2/vj4WbxeXxWg3hVXCafy9Nm5ceo4Us1kzXZ7CaFMiMcsC76wdFRxQRkzfxy6Dn
ud6lDES5qhIPdxq+/FePq7elKVLHZ+XbTUVGZ12Zh73YARPefA/cGRkBdx1spOPh
qNaBKikqrCIpajJFZLMn+/oRdwMS4drMW/mhP3M52k4hcugmWFD1vTw1sboV8FQ=
=KrBy
-----END PGP SIGNATURE-----

--/e2eDi0V/xtL+Mc8--
