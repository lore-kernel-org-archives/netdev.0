From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH 1/2] regmap: Allow installing custom reg_update_bits
 function
Date: Fri, 2 Oct 2015 18:19:08 +0100
Message-ID: <20151002171908.GY12635@sirena.org.uk>
References: <1443681187-29505-1-git-send-email-jon@ringle.org>
 <20151001094424.GG15635@sirena.org.uk>
 <alpine.DEB.2.10.1510010826450.21737@jring-w510-7m3g.gridpoint.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="sKosZo66cxuwvnFI"
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jon Ringle <jon@ringle.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:35975 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534AbbJBRTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 13:19:16 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1510010826450.21737@jring-w510-7m3g.gridpoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sKosZo66cxuwvnFI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 01, 2015 at 08:29:19AM -0400, Jon Ringle wrote:
> On Thu, 1 Oct 2015, Mark Brown wrote:

> > This completely bypasses and therefore breaks the cache infrastructure.

> Right after sending the v2 patch, I realized that calling the=20
> custom reg_update_bits would only be applicable for registers that are=20
> marked as volatile. Would the following solution be acceptable (it would=
=20

Well, it should still *work* with a cache, though it's certainly true
that it's unlikely to have any performance benefit with cached register
since the read part of the read/modify/write cycle is essentially free=20
with the cache.

> also simplify the regmap_update_bits in the encx24j600 driver):

> 	if (regmap_volatile(map, reg) && map->reg_update_bits) {
> 		return map->reg_update_bits(map->bus_context, reg, mask,=20
> 		                            val, change, force_write);

> The cache state should not matter for volatile registers, right?

Right.  I see you've sent a new patch already, I'll reply to that after
I've thought about it a little.

--sKosZo66cxuwvnFI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWDryLAAoJECTWi3JdVIfQ85AH/1N0hojqldZspZOSkngT4+85
+03SYBQHzEpnjlOFk9VrdTppKIKroZKwQQ6S+1PdEG1bdjVioc4Hken0eaHkEFB+
nG+V2Z7yH7+SFydtDR/vLK786RWQVvTvr+k9GJAPer/rHNwknxXy2RPhB4XN+Gvz
RZrbps0a+h9qJyHbWROiduRRwtphi4L46H+gR27ZmYvhJ2LzHnuM07piTtMU0u1h
hM1ow316B6dZZnc4SqNgX+NstmXT7MB6IECSBHmKrD0xvmTU9I9RnvooQrgFOprN
cIYvQe1MHQqvFFMjjIZ/n9WWdhqiV/0JcK6oIc+L8qIXa0OUaZxiM+7Et8O8tgk=
=Ox6S
-----END PGP SIGNATURE-----

--sKosZo66cxuwvnFI--
