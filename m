From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: fix unused igb_deliver_wake_packet() warning when
 CONFIG_PM=n
Date: Thu, 13 Jul 2017 15:33:20 -0700
Message-ID: <1499985200.4698.31.camel@intel.com>
References: <20170712210925.4F647FAA@viggo.jf.intel.com>
         <CAOMZO5B1bFRJh3wjbR77HL4ZQ7LqmmSJdeVzRkbyJXUjFFCsrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-RbX9J3YVO9Ie3qcTWJFS"
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        intel-wired-lan@lists.osuosl.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>,
        Dave Hansen <dave.hansen@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOMZO5B1bFRJh3wjbR77HL4ZQ7LqmmSJdeVzRkbyJXUjFFCsrQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-RbX9J3YVO9Ie3qcTWJFS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-07-12 at 18:23 -0300, Fabio Estevam wrote:
> On Wed, Jul 12, 2017 at 6:09 PM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
> >=20
> > From: Dave Hansen <dave.hansen@linux.intel.com>
> >=20
> > I'm seeing warnings on kernel configurations where CONFIG_PM is
> > disabled.  It happens in 4.12, at least:
> >=20
> > drivers/ethernet/intel/igb/igb_main.c:7988:13: warning:
> > 'igb_deliver_wake_packet' defined but not used [-Wunused-function]
> >=20
> > This is because igb_deliver_wake_packet() is defined outside of
> > the #ifdef", but is used only a single time within the #ifdef in
> > igb_resume().  Fix it by moving igb_deliver_wake_packet() next to
> > igb_resume() inside the #ifdef.
> >=20
> > The diff ends up looking a bit funky here.  It *looks* like
> > igb_suspend() is getting moved, but that's an artifact of how
> > 'diff' sees the changes.
> >=20
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Cc: intel-wired-lan@lists.osuosl.org
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>=20
> Seems to be fixed by the following commit in linux-next:
>=20
> commit 000ba1f2ebf0d6f93b9ae6cfbe5417e66f1b8e8c
> Author: Arnd Bergmann <arnd@arndb.de>
> Date:   Thu Apr 27 21:09:52 2017 +0200
>=20
>     igb: mark PM functions as __maybe_unused
>=20
>     The new wake function is only used by the suspend/resume handlers
> that
>     are defined in inside of an #ifdef, which can cause this harmless
>     warning:
>=20
>     drivers/net/ethernet/intel/igb/igb_main.c:7988:13: warning:
> 'igb_deliver_wake_packet' defined but not used [-Wunused-function]
>=20
>     Removing the #ifdef, instead using a __maybe_unused annotation
>     simplifies the code and avoids the warning.
>=20
>     Fixes: b90fa8763560 ("igb: Enable reading of wake up packet")
>     Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>     Tested-by: Aaron Brown <aaron.f.brown@intel.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Yeah, this is already fixed in my tree.  Dropping this patch.
--=-RbX9J3YVO9Ie3qcTWJFS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlln9TAACgkQ5W/vlVpL
7c6vXRAAoeLfz9UUUEupSus+VrRshX5kSJt67Ig58CCb+5hqVcn5ZRRs/2DXI4ot
9FweXqmj7tdSoNadVw/QcryLpr0UN92Qgo0NwMpA4Hp19hNHNSzhe5ZyBQZFt1Uz
h7xYL6gJCu0FVUXTer/Xuxu96hexhlM14pDqK1vu+rUyRpjQm1/bJVfq5vco/Dlq
sHpAYeZD6PXg3/AQoT830wlxuY3QeKFG3XQR24J42tRZ42m8OnTNKEGKY0Ep1F+I
IZyBF2kPjAQmM0gw+KwzlMaV0rg2y7VpJAj8n1fgqTmjrToCPHypKh3uwsET6iTk
Ak3WGYTkbgwbZjeMh3Or3xw8cM6zDGSCw/FMN7X0f4BlzKTBNMroyaD3plcfRTEd
SDAtukw0uwslQzcd6f/fZGxEo5VSZNtz8lR4+fpzb+N1nJBjMjVNudTIXPdhVC+G
krzx8Zx7RgNPrbiiIA5+ZgQ00Tv+aN6bZKP9FB6YnsD2ra/BAEjOOPibnk6jQz3G
NY+ss3tjc72kEOefhYuD54IO8jCpbiMLeXLao5AB7apaELcRsERWyyN+ZC/T+thN
C5RupLnfyEv736jAVV8QoQaC2l/g3UBEadeeLXp3Pw9dtqI3h0ALswJ6drBEIX9M
fQXcRRM5uefD17yUIEslHxl8K1P8Q9LnGjIafVVQKq2SOqX8gl0=
=toCL
-----END PGP SIGNATURE-----

--=-RbX9J3YVO9Ie3qcTWJFS--
