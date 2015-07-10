From: Josh Cartwright <joshc@ni.com>
Subject: Re: [PATCH v2] nohz: prevent tilegx network driver interrupts
Date: Fri, 10 Jul 2015 17:45:00 -0500
Message-ID: <20150710224500.GA25028@jcartwri.amer.corp.natinst.com>
References: <55A0175E.2010200@ezchip.com>
 <1436557045-5392-1-git-send-email-cmetcalf@ezchip.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="SZSwH5G1FJ2Fz+jP"
Cc: Frederic Weisbecker <fweisbec@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Metcalf <cmetcalf@ezchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:48011 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751918AbbGJWpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 18:45:06 -0400
In-Reply-To: <1436557045-5392-1-git-send-email-cmetcalf@ezchip.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SZSwH5G1FJ2Fz+jP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 10, 2015 at 03:37:25PM -0400, Chris Metcalf wrote:
> Normally the tilegx networking shim sends irqs to all the cores
> to distribute the load of processing incoming-packet interrupts,
> so that you can get to multiple Gb's of traffic inbound.
>=20
> However, in nohz_full mode we don't want to interrupt the
> nohz_full cores by default, so we limit the set of cores we use
> to only the online housekeeping cores.
>=20
> To make client code easier to read, we introduce a new nohz_full
> accessor, housekeeping_cpumask(), which returns a pointer to the
> housekeeping_mask if nohz_full is enabled, and otherwise returns
> the cpu_possible_mask.
>=20
> Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>
> ---
[..]
> +static inline const struct cpumask *housekeeping_cpumask(void)
> +{
> +#ifdef CONFIG_NO_HZ_FULL
> +	if (tick_nohz_full_enabled())
> +		return housekeeping_mask;
> +#endif

Just a small comment:

We can take these checks out from under a #ifdef CONFIG_NO_HZ_FULL
check, given that are stubbed tick_nohz_full_enabled() defined above.

  Josh

--SZSwH5G1FJ2Fz+jP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJVoErpAAoJEKp7ZBKwQFAr2J0IAKZ+LFQe7XEqsIl6SW0xeM2e
QIIIexwOfTYQ7H+OrL7N2/RHvylPC0FuZAdq2+jMX0t5I5LAo2C7QN2h3ubF1fyb
B9OyshJZrnQ+ssacx5z5HkbjOq3bCQvb+d/AIBiWg3ItuPlUBl7QeN3kXQ+/yWvn
4lXxicM2A+p3sf4tziGW+MBG9o2AkAp+ZsuX4/qhaFlqR/Ci7Fi8FpfzVj6PySic
2mVvbSCx3+esKATUbajdScnoTYjEaBPui8Bgd0gQednvkOyGrD9ZGtruyM8Phz2E
fcx/QhaMnBHe/pUPpc24dLOoO6yqnFESUaeA5o/yVUzegAYNP1qymHtqi16572Y=
=2Zbf
-----END PGP SIGNATURE-----

--SZSwH5G1FJ2Fz+jP--
