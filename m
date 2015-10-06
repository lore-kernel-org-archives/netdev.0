From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH net-next v3 1/2] regmap: Allow installing custom
 reg_update_bits function
Date: Tue, 6 Oct 2015 17:30:11 +0100
Message-ID: <20151006163011.GU12635@sirena.org.uk>
References: <1443717488-16533-1-git-send-email-jon@ringle.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="FmzkFdx4KZToyoR7"
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jon Ringle <jringle@gridpoint.com>
To: jon@ringle.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443717488-16533-1-git-send-email-jon@ringle.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--FmzkFdx4KZToyoR7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 01, 2015 at 12:38:07PM -0400, jon@ringle.org wrote:
> From: Jon Ringle <jringle@gridpoint.com>
>=20
> This commit allows installing a custom reg_update_bits function for cases=
 where
> the hardware provides a mechanism to set or clear register bits without a
> read/modify/write cycle. Such is the case with the Microchip ENCX24J600.

Thanks, I've applied this.  I'll extend it so that individual devices
can do this as well - I've not looked at your driver but it might be
that this is a better option than regmap_bus for your driver (but both
are supported so meh).  Dave, I've tagged the commit and there's a pull
request for this below:

The following changes since commit 6ff33f3902c3b1c5d0db6b1e2c70b6d76fba357f:

  Linux 4.3-rc1 (2015-09-12 16:35:56 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/broonie/regmap.git tags/reg=
map-offload-update-bits

for you to fetch changes up to 77792b11409c9270d98e604b4314b85ce886ac7d:

  regmap: Allow installing custom reg_update_bits function (2015-10-06 16:1=
2:34 +0100)

----------------------------------------------------------------
regmap: Allow buses to provide a custom update_bits() operation

Some buses provide a native _update_bits() operation which for uncached
registers is faster than doing a read/modify/write cycle as it is a
single bus transaction.  Add support for implementing this to regmap.

----------------------------------------------------------------
Jon Ringle (1):
      regmap: Allow installing custom reg_update_bits function

 drivers/base/regmap/internal.h |  2 ++
 drivers/base/regmap/regmap.c   | 29 ++++++++++++++++++-----------
 include/linux/regmap.h         |  3 +++
 3 files changed, 23 insertions(+), 11 deletions(-)

--FmzkFdx4KZToyoR7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWE/cSAAoJECTWi3JdVIfQ2V4H/3C+XvYGyYPe/tre64UUajx3
gmt+xZHovb6E1FgBS763x6qSLZvCUxaelAdIJfB9+5F/XH/IFHaWSySx08L9nP6+
dNwPrxjpNzXL/oa20PEgO3gh/IGycMayMVsGTbkgtvqz80KGmFZRYmBw3lP2oEdm
tbcLVn5hje2LDS+pRIP7lKuRWRZ71BuVgklU624CvS3HyiTnIE64bIWewrkDCXNV
uIzFq53XvTe37IMXyEf/nz/U3rzDUR43CrMBlwRg72dOrpQ1d4P1dCR/Kug2BF60
mFackJKw4Ieh05y31k62Mkg2wiZPQ4EbJsyS8vyIahkLoAGnquAApjFoklYZhT8=
=uaMd
-----END PGP SIGNATURE-----

--FmzkFdx4KZToyoR7--
