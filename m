From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 3/3] fm10k/igb/ixgbe: Use load_acquire on Rx descriptor
Date: Fri, 14 Nov 2014 09:25:19 -0800
Message-ID: <1415985919.2454.50.camel@jtkirshe-mobl>
References: <20141113191250.12579.19694.stgit@ahduyck-server>
	 <20141113192746.12579.91054.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tkmFPNkhUJCew2m+hnBt"
Cc: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mikey@neuling.org,
	tony.luck@intel.com, mathieu.desnoyers@polymtl.ca,
	donald.c.skidmore@intel.com, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	oleg@redhat.com, will.deacon@arm.com, davem@davemloft.net,
	michael@ellerman.id.au, matthew.vick@intel.com,
	nic_swsd@realtek.com, geert@linux-m68k.org, fweisbec@gmail.com,
	schwidefsky@de.ibm.com, linux@arm.linux.org.uk,
	paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org,
	mingo@kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20141113192746.12579.91054.stgit@ahduyck-server>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-tkmFPNkhUJCew2m+hnBt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-13 at 11:27 -0800, Alexander Duyck wrote:
> This change makes it so that load_acquire is used when reading the Rx
> descriptor.  The advantage of load_acquire is that it allows for a
> much
> lower cost barrier on x86, ia64, powerpc, arm64, and s390
> architectures
> than a traditional memory barrier when dealing with reads that only
> have
> to synchronize to system memory.
>=20
> In addition I have updated the code so that it just checks to see if
> any
> bits have been set instead of just the DD bit since the DD bit will
> always
> be set as a part of a descriptor write-back so we just need to check
> for a
> non-zero value being present at that memory location rather than just
> checking for any specific bit.  This allows the code itself to appear
> much
> cleaner and allows the compiler more room to optimize.
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Matthew Vick <matthew.vick@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |    8 +++-----
>  drivers/net/ethernet/intel/igb/igb_main.c     |    8 +++-----
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   11 ++++-------
>  3 files changed, 10 insertions(+), 17 deletions(-)

Based on the discussion on patch 01 of the series, it appears changes
are coming to the series, so I won't be picking up this patch.  I will
wait for Alex to re-spin the series with the suggested changes.

--=-tkmFPNkhUJCew2m+hnBt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUZjr/AAoJEOVv75VaS+3O7EoP/jPOeNPsC6iYfhdffYVIuRSd
02LHiX6nVaiQ5b7MRq39BhaFyeqUne5Kdmj44xpKr9SBjFLcl93XE2llV3DzwvZ2
W9iQgSEliV+ZpCTuhPTGP34nx2chUH9UMLc5vxUlNjEaoInq8CCg0HYyHtV8I1tV
pxbx3sQbH/kAsiXZ2gn4cN0VwAWAmjzViaE20mBLXK73ulzUbyZ2LLFiSgo7Op3m
N/B9PmdfZnhafJRy3xOAz/GPPVhJKkgzxfme6QQbtTI2lGFYZFUcg3R5WPJ8T43/
IDxnyw27IgKRR/EbZNbRr76hl8FzuhgAHZkkMy4EkTfAwMlrYrQ/LsXsMMwirR3/
ZHeQ11DB/JMZIB78G9GlNXmbT1s6daKExcuaTigJcWxeVNkQDEPHbA/0x+J8TSgs
WWH3qgSGJ2MolizljOWywF/phP2Mg9PFAmwpHBZO1mML9hxuleral4h9r/jou4kv
kn27OYUK7YwI/D6yo8PhaboMlkPwx/fISzdjFfMn5hs4EtOVP2c/5qgH8iFwJFOi
H2JPu1b3OBoiLcUXMPV7g4DV2w1ePzFsLjMNgQwLybehZow9mgJR2Rnroc2HPXQO
lcYz9fATkKlJ95f2z9Nsgm7k2Nb73PgZkINxkG05Gcb43HMLRz6OdYyHJP+SLEvp
kwLli3RkROPoYBay0zM1
=QB5M
-----END PGP SIGNATURE-----

--=-tkmFPNkhUJCew2m+hnBt--
