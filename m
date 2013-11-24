From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH 3/3] xfrm: Fix null pointer dereference when decoding
 sessions
Date: Sun, 24 Nov 2013 15:27:58 +0100
Message-ID: <52920CEE.2040407@universe-factory.net>
References: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com> <1383294107-7509-4-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="ba8K8tfi4v3qlL90S2rAbN8td2bhp9Ie2"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([37.72.148.22]:48439 "EHLO
	chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752380Ab3KXOgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 09:36:06 -0500
In-Reply-To: <1383294107-7509-4-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ba8K8tfi4v3qlL90S2rAbN8td2bhp9Ie2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/01/2013 09:21 AM, Steffen Klassert wrote:
> On some codepaths the skb does not have a dst entry
> when xfrm_decode_session() is called. So check for
> a valid skb_dst() before dereferencing the device
> interface index. We use 0 as the device index if
> there is no valid skb_dst(), or at reverse decoding
> we use skb_iif as device interface index.
>=20
> Bug was introduced with git commit bafd4bd4dc
> ("xfrm: Decode sessions with output interface.").
>=20
> Reported-by: Meelis Roos <mroos@linux.ee>
> Tested-by: Meelis Roos <mroos@linux.ee>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Please queue this for 3.12-stable, I've seen this bug trigger a panic
when heavily using Bittorrent (screenshot:
http://i.imgur.com/OIKVccM.jpg )

Thanks,
Matthias


--ba8K8tfi4v3qlL90S2rAbN8td2bhp9Ie2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlKSDO4ACgkQq3qIxbiQM9hMsACfdkhdtKL1rgMTyu7e84fiPNEm
QlwAnifDJlacNK0w3JWRn2SrIA/ENF0e
=fa2M
-----END PGP SIGNATURE-----

--ba8K8tfi4v3qlL90S2rAbN8td2bhp9Ie2--
