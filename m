From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 12/14] mlx4: use netdev_rss_key_fill() helper
Date: Sat, 22 Nov 2014 21:49:21 +0000
Message-ID: <1416692961.7215.31.camel@decadent.org.uk>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
	 <1416147798-16561-13-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OGX52J2p4baRDjIXYFKj"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44199 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752929AbaKVVtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 16:49:51 -0500
In-Reply-To: <1416147798-16561-13-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OGX52J2p4baRDjIXYFKj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-11-16 at 06:23 -0800, Eric Dumazet wrote:
> Use of well known RSS key increases attack surface.
> Switch to a random one, using generic helper so that all
> ports share a common key.
>=20
> Also provide ethtool -x support to fetch RSS key
[...]
> @@ -1799,6 +1805,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops =3D {
>  	.get_rxnfc =3D mlx4_en_get_rxnfc,
>  	.set_rxnfc =3D mlx4_en_set_rxnfc,
>  	.get_rxfh_indir_size =3D mlx4_en_get_rxfh_indir_size,
> +	.get_rxfh_key_size =3D mlx4_en_get_rxfh_key_size,
>  	.get_rxfh =3D mlx4_en_get_rxfh,
>  	.set_rxfh =3D mlx4_en_set_rxfh,
[...]

A driver that implements get_rxfh_key_size() and set_rxfh() is assumed
to support setting the RSS key (and only the key).  However,
mlx4_en_set_rxfh() will currently crash if a new indirection table is
not provided.

Ben.

--=20
Ben Hutchings
Logic doesn't apply to the real world. - Marvin Minsky

--=-OGX52J2p4baRDjIXYFKj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHEE8Oe/yOyVhhEJAQrQAhAApz77db/zwFfV+N/g+eVt2iNEyUn1Atv8
RrLrHHDni6Pe9gvULgBqk7j2Eu0VVmJGsNMd3w1hXn5Jy2EDxwwolcZ6PbUWbibk
GaxURLErdA+NOiPPekUzAeSVmqvZhkBDNYdqHhILipLRXNLOP/5j162pEHt5m1t0
AMmURk3fDIxZrHSvlkSMrkoNWeyIRmAoCEVmDbyWOpQ9TU4SeAMdBFCCnoCBQRtr
0xF13wSXVUSm/wovjOg09CdECn8pnuup7qCx+PcB7uc7WoHSzDrbpimBNKoZINdT
ChUvQrjyS3HlQnVzM7J9paGTJs2fugOIlpEQx3aWitYF085v+OFZFFOoq7js0Q2w
h4wkQbnkq/tTYM54EyNV1f2bQ+79g8mwYJRG+do91adrC2LMi5eh8N8cmlYV/WMP
kthRZwUHccjW/w1rvBbTPgXLgFVjrGVf/4RZoHP9Oo8Ew8eSKvCmUPLsfXpJH/cj
FYVWgj1sMa7/CYMmZLtP27HLVI7ZHopdIggxeI/Af9xyl2eu/Wo3pPGMptjprEqP
r1iVt1hNVGCGjMEB9+zHLk0EPhxTnLnW5S35HZMPvY/iYLjvr8abJ8vy4La+huXY
vqWP+rq25WyabGZUEEdag549oMtOyYFCoozlIslQsIOYestaG3Xa53oUEHkZb7xC
vzZCwDmdDis=
=U9dh
-----END PGP SIGNATURE-----

--=-OGX52J2p4baRDjIXYFKj--
