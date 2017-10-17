From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH, net-next] i40e: avoid 64-bit division where possible
Date: Tue, 17 Oct 2017 08:14:54 -0700
Message-ID: <1508253294.2928.2.camel@intel.com>
References: <20171017102351.492492-1-arnd@arndb.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-yc9+UOS5SKXGgECMHP/0"
Cc: Jacob Keller <jacob.e.keller@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Amritha Nambiar <amritha.nambiar@intel.com>,
        Filip Sadowski <filip.sadowski@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        =?ISO-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171017102351.492492-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-yc9+UOS5SKXGgECMHP/0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-10-17 at 12:23 +0200, Arnd Bergmann wrote:
> The new bandwidth calculation causes a link error on 32-bit
> architectures, like
>=20
> ERROR: "__aeabi_uldivmod" [drivers/net/ethernet/intel/i40e/i40e.ko]
> undefined!
>=20
> The problem is the max_tx_rate calculation that uses 64-bit integers.
> This is not really necessary since the numbers are in MBit/s so
> they won't be higher than 40000 for the highest support rate, and
> are guaranteed to not exceed 2^32 in future generations either.
>=20
> This changes the representation to 'u32' when dealing with MBit/s
> and uses div_u64() to convert from u64 numbers in byte/s.
>=20
> Fixes: 2027d4deacb1 ("i40e: Add support setting TC max bandwidth
> rates")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/ethernet/intel/i40e/i40e.h      |  4 ++--
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 27 ++++++++++++++-----
> --------
>  2 files changed, 16 insertions(+), 15 deletions(-)

Unfortunately your patch does not apply cleanly to my tree.  Arnd,
could you please rebase your patch based my next-queue tree (dev-queue
branch)?  I already have several i40e patches queued up and applied to
that branch.
--=-yc9+UOS5SKXGgECMHP/0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlnmHm4ACgkQ5W/vlVpL
7c7BexAApSPPwAN7kujDo2/UZGuO4Vw9BDDO65VT3te+HrwBihZFLwWSqYAoVZMA
wbwfT43UmNsAcjZ0aS80QYW4XGpV30y3Z+RhtjITdfCyyUZMOKB85YBMiWge8JCS
y1s6M/CVunL2SamLP4wA0UxCVCey2Us8ID86DFp4Plf7ntC4zSL6TR9/R+9UgH52
4S452RVHBPfrEYPDad2jZQse3EtqTmYQv5qv1GyRJ4d9mj1DZ4W96+I7bJjUI/PP
3G5LSl80AkcHHj5UXnUlzj6Aa04/Eq6LKgDrPhU3To6eoPMiktUveyBCItXjFDA7
kn7reZ1RPcHdAEelHQ1ksSqHkBdXCidyYRd7DiewN2FErNYsT4mVsF726Syve0Tc
/+pKHbYLL74msj6cH1v43nxQ0KRKjXUKJr2AS2rX70jbpu+5eP44ZuPT0UlomOZv
ONbxEgrAW4o69cV4ouTxPZNC7UboUaRYlLrSwdL5HQEnv6VIQwWGD/FX8AJuN60o
fPcrfi6U7KTzdGkCrLyyC7IIZ81xTQRWzoyKcz8n0Nrscc/zTLT8Jdhsk+cEBI8A
DYNni+VZbhsUmNx3UTRdAAB8lvCquc7M5kJYh6bPF+cTDkvjEw2Q8YccB5UmD4pc
CtgJ76fNP9FxHs5UpOguBsCv6uag0EWbdNzfaNJd2QlHCq8DJVk=
=Z/69
-----END PGP SIGNATURE-----

--=-yc9+UOS5SKXGgECMHP/0--
