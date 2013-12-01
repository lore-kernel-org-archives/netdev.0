From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH 3/3] xfrm: Fix null pointer dereference when decoding
 sessions
Date: Sun, 01 Dec 2013 05:19:53 +0100
Message-ID: <529AB8E9.30004@universe-factory.net>
References: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com> <1383294107-7509-4-git-send-email-steffen.klassert@secunet.com> <52920CEE.2040407@universe-factory.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="bc85cvIXFSm8HBLhI8uOLEfL2tb1rUS6h"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([37.72.148.22]:42807 "EHLO
	chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751529Ab3LAETz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 23:19:55 -0500
In-Reply-To: <52920CEE.2040407@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bc85cvIXFSm8HBLhI8uOLEfL2tb1rUS6h
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/24/2013 03:27 PM, Matthias Schiffer wrote:
> On 11/01/2013 09:21 AM, Steffen Klassert wrote:
>> On some codepaths the skb does not have a dst entry
>> when xfrm_decode_session() is called. So check for
>> a valid skb_dst() before dereferencing the device
>> interface index. We use 0 as the device index if
>> there is no valid skb_dst(), or at reverse decoding
>> we use skb_iif as device interface index.
>>
>> Bug was introduced with git commit bafd4bd4dc
>> ("xfrm: Decode sessions with output interface.").
>>
>> Reported-by: Meelis Roos <mroos@linux.ee>
>> Tested-by: Meelis Roos <mroos@linux.ee>
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>=20
> Please queue this for 3.12-stable, I've seen this bug trigger a panic
> when heavily using Bittorrent (screenshot:
> http://i.imgur.com/OIKVccM.jpg )
>=20
> Thanks,
> Matthias
>=20

Ping? Several people I know have hit this panic with 3.12.x at least
once or twice by now during heavy IPv6 usage.


--bc85cvIXFSm8HBLhI8uOLEfL2tb1rUS6h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlKauOkACgkQq3qIxbiQM9hnvACgmTb/SLCJzVfNGR1s6q5qLGB7
D1kAnixQ1KY0YLsg7S0n0bVvCre/XxZo
=MZHf
-----END PGP SIGNATURE-----

--bc85cvIXFSm8HBLhI8uOLEfL2tb1rUS6h--
