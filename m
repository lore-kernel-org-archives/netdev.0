From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [BUG]ethtool: NIC blink
Date: Tue, 20 May 2014 15:39:00 +0100
Message-ID: <1400596740.17377.50.camel@deadeye.wl.decadent.org.uk>
References: <CFA0BA5E.2E2E6%shawn.warren@rackspace.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7ESEvhr8J6eqxxgrrnMd"
Cc: netdev <netdev@vger.kernel.org>
To: Shawn Warren <shawn.warren@rackspace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35510 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752085AbaETOjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 10:39:06 -0400
In-Reply-To: <CFA0BA5E.2E2E6%shawn.warren@rackspace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7ESEvhr8J6eqxxgrrnMd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[Re-sending with cc to netdev]

On Tue, 2014-05-20 at 12:53 +0000, Shawn Warren wrote:
> Hello Ben and NetDev,
>=20
>=20
> I am curious how exactly the ethtool =E2=80=93p flag works when blinking
> interface lights. I ran into an issue on a DELL R820 with an Intel
> proc that when I blinked an interface and put ethtool in the
> background, the load on the server began steadily increasing. I ran
> the following command to reproduce the issue:
>=20
>=20
> # ethtool =E2=80=93p eth2 3600 &
>=20
>=20
> The load increased until the ethtool process was halted. Is this a
> known bug/issue?

It's not a bug in the ethtool utility.

Perhaps you have run into the problem explained in
<https://git.kernel.org/linus/68f512f21a64c9b264df6c61a9333e7890faf74b>.
The load will increase as processes wait (uninterruptibly) to obtain the
RTNL lock.  They will appear as being in D state.

This was fixed in Linux 3.0, but older versions can't practically be
fixed as it required an incompatible change to the driver API.

Ben.

--=20
Ben Hutchings
Life would be so much easier if we could look at the source code.

--=-7ESEvhr8J6eqxxgrrnMd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU3tpBee/yOyVhhEJAQr9qhAAu+grPsXaQ7IgIQxE+l0ZtHjfWh4McHp2
4e9lLhiX/fWHPsC6pBdQzpIwz1LE3uGKn5wLbkFl8Pm669uGg9ej82hUSCtKdETU
BsZMEfeBKJDfFCZY9FWtHPATC7ZjxNnmSiTOZTe66Qaf0Y5ufTljobF0vT7Lw8bn
dBhqJLp6RD/zF125O2uC3GKsBc1f+45NnKPsc2M8VZKwawoaa1i+ETBq0M2GfTay
XkD1Ui5GGeCJajLnKgFDAtFP5PRTM+eyS221uanu2MowZgeR7Txn1ekqD1YvBJND
BCtHH+KU9DVgYnpm24KPSu/V/mdm4TFc53E+dA46gwoH8IWi6wwk0jXqJotPM12B
pMYdDfN7JAkHcQ6Algm74HUFMQfscOzyUrHLkaS07fUIfEVgKIKKusdEzgmNAWd6
Fq0A+AleysWZ+STJaiMo35P5EnqjCTFtrOzcUvFoGIqt/5zT+kjmYhiI7iskBDNj
u/AGjjGUUM6hVovDcccPdel+tdMuY0pNUtr1qoMbUn1qQS7hdXrAldC4C2Xxx34p
kJNoMJI07yu9VG7h4sKqz3kc8RWgdsc4IiIpYvklwILgM9OUJan/svLKEqpNlH1Q
8dmMl2TuNd7w31vkewxgWvR0a79BbNE256bNiPhbQ5FCUOe7jI8g2yNhsHCCF/9x
10rXLI5YNK8=
=t1T8
-----END PGP SIGNATURE-----

--=-7ESEvhr8J6eqxxgrrnMd--
