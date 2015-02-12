From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH] iwl4965: Enable checking of format strings
Date: Thu, 12 Feb 2015 00:41:39 +0000
Message-ID: <60178C37-F104-430E-92EB-B6DDFAEB2F99@intel.com>
References: <1423695069-23436-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_39763AEA-1C12-4996-997C-C584EEB22D7C";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423695069-23436-1-git-send-email-linux@rasmusvillemoes.dk>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_39763AEA-1C12-4996-997C-C584EEB22D7C
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Feb 11, 2015, at 2:51 PM, Rasmus Villemoes <linux@rasmusvillemoes.dk> =
wrote:

> Since these fmt_* variables are just const char*, and not const
> char[], gcc (and smatch) doesn't to type checking of the arguments to
> the printf functions. Since the linker knows perfectly well to merge
> identical string constants, there's no point in having three static
> pointers waste memory and give an extra level of indirection.
>=20
> This removes over 100 "non-constant format argument" warnings from
> smatch, accounting for about 20% of all such warnings in an
> allmodconfig.
>=20
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
> drivers/net/wireless/iwlegacy/4965-debug.c | 7 +++----
> 1 file changed, 3 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/wireless/iwlegacy/4965-debug.c =
b/drivers/net/wireless/iwlegacy/4965-debug.c
> index e0597bfdddb8..18855325cc1c 100644
> --- a/drivers/net/wireless/iwlegacy/4965-debug.c
> +++ b/drivers/net/wireless/iwlegacy/4965-debug.c
> @@ -28,10 +28,9 @@
> #include "common.h"
> #include "4965.h"
>=20
> -static const char *fmt_value =3D "  %-30s %10u\n";
> -static const char *fmt_table =3D "  %-30s %10u  %10u  %10u  %10u\n";
> -static const char *fmt_header =3D
> -    "%-32s    current  cumulative       delta         max\n";

Why not change these to:
static const char fmt_value[] =3D "  %-30s %10u\n";
static const char fmt_table[] =3D "  %-30s %10u  %10u  %10u  %10u\n";
static const char fmt_header[] =3D
    "%-32s    current  cumulative       delta         max\n";

I think that is better than the macros and avoids the extra pointers =
that I agree are useless.

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_39763AEA-1C12-4996-997C-C584EEB22D7C
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJU2/bCAAoJEDwO/+eO4+5uAFkP/A0FhqR0STl6uCwwaKu/Ro0P
4qx6gcM7995VyuBcXNMgqTGpRcQIachnS+7xULon8/bCPy5xYAoqVGm1XTwDLDvp
1ENK2Lpn87FPltBOVW/tA4HQFSdWP+OAplLkaaqAUwd676eKCe3YD5QPtjfYJrx3
d8jIipNUrxdW5zpqkDjCe1yUFgKzfivQRV4Spc37CLfkxf2opM5YVLerQdJn86dq
6n9IuogcNCUXuQzEZPKt7Abv760GpqpNQfNoF2YnChEvfjzdOVSXlX2VW/GQ6Iwo
9S6pLaLPrem04lOFpg1b+qNq58JCEuCcTi0KZr81RLqn8hHt2hyBpqffjSPwL3On
wCk7pXkpz1B60IY2XANGYFhQaNZBAMcgItUgnBXFYcaZJsgzVmS/QQ97H0NL9cVJ
fPeSZ7b7TzAv/XeJCnsBlcDORghDMQLsqbfq6meZfy25Lv7f4O11l4bvIoS07SQu
nXnL+5M9u2J9jEqbmRdgX67I3XI0ROsq6sP6eBx9OZ1Z8tHu9idqsIXs6x8WtF/k
v5CyoSSDjvZjOhMlZWuoJNuZxZLdcePangUBX5/sFnb+oRdyklFAR2cQJjJC21vH
W3W0bNGAVIVe6F7S76aACxDYn4VphqOm4+KaOkvppVOHhuEwLMRdSYqh2V90szWT
LZw+4Y9gE0/UNtiaujvT
=GQJq
-----END PGP SIGNATURE-----

--Apple-Mail=_39763AEA-1C12-4996-997C-C584EEB22D7C--
