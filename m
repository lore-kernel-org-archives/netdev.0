From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH 08/11] ssb: driver_chip_comon_pmu: Fix probable mask
 then right shift defect
Date: Mon, 27 Oct 2014 18:32:31 +0100
Message-ID: <20141027183231.2a9abbb4@wiggum>
References: <cover.1414387334.git.joe@perches.com>
	<e68a49a228d8d2495630b4ef03a1f32b33fce7fe.1414387334.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/CAj/qyhiMumS69DuPDRPde2"; protocol="application/pgp-signature"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e68a49a228d8d2495630b4ef03a1f32b33fce7fe.1414387334.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/CAj/qyhiMumS69DuPDRPde2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Sun, 26 Oct 2014 22:25:04 -0700
Joe Perches <joe@perches.com> wrote:

> Precedence of & and >> is not the same and is not left to right.
> shift has higher precedence and should be done after the mask.
>=20
> Add parentheses around the mask.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>

Good catch.

Reviewed-by: Michael B=C3=BCsch <m@bues.ch>

> ---
>  drivers/ssb/driver_chipcommon_pmu.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/ssb/driver_chipcommon_pmu.c b/drivers/ssb/driver_chi=
pcommon_pmu.c
> index 1173a09..bc71583 100644
> --- a/drivers/ssb/driver_chipcommon_pmu.c
> +++ b/drivers/ssb/driver_chipcommon_pmu.c
> @@ -621,8 +621,8 @@ static u32 ssb_pmu_get_alp_clock_clk0(struct ssb_chip=
common *cc)
>  	u32 crystalfreq;
>  	const struct pmu0_plltab_entry *e =3D NULL;
> =20
> -	crystalfreq =3D chipco_read32(cc, SSB_CHIPCO_PMU_CTL) &
> -		      SSB_CHIPCO_PMU_CTL_XTALFREQ >> SSB_CHIPCO_PMU_CTL_XTALFREQ_SHIFT;
> +	crystalfreq =3D (chipco_read32(cc, SSB_CHIPCO_PMU_CTL) &
> +		       SSB_CHIPCO_PMU_CTL_XTALFREQ) >> SSB_CHIPCO_PMU_CTL_XTALFREQ_SHI=
FT;
>  	e =3D pmu0_plltab_find_entry(crystalfreq);
>  	BUG_ON(!e);
>  	return e->freq * 1000;




--=20
Michael

--Sig_/CAj/qyhiMumS69DuPDRPde2
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUToGxAAoJEPUyvh2QjYsOMegP/RvSLPksqP6l7dXDkcVr9jpK
s7ns/qqO0CVYWFoEFKmkPe5B5IIKaX8YHhJSL8A+SZhT/GDd0KEKjhNjJJUXZt6j
ZNSVsrW4jQyxQO+Z6a3TML5UQMg3NZeaeooeLrLQwuja4ViZmc0NjhZiZp3y6Hda
NxaaUE5lh7O6BUJfJf16oizheFz7koTqJigyrflJ4Al5XhxALgIt7w8dzq5rnlog
1jsr5r/Pp5BytUOorL3+6f8iDPHOfg9sJyDsGwHl1/pXL+KTdEkvmSzC3VaKDNot
JbpJFR0wvroQzj56dFcULIa2fa2bcF9+oUHKw2mGITYZqDY8umwkPSNi0oC7+mZl
/HJGk+SGrfFdkUjweAXymjkSfjHfKGeJNvfF5ndr5ijY+rHJG4uRte6W1JlDvZtF
HDzpAv3N4PPsPmQzFrVxdDhbPEjGUDIDGum3QkpiK5w2rnOqncaXq3caH6LDRFYS
gsV6j1pv1kXaQFKlQea5K1DxQcA9phXwHq3XVfhQ4uVAyUqP9JuAT+z2VlF4jEPH
9dfOURbBJDj2brp7PDm+548R3TGnvcL4zOWlgYdcGZLfwoy9sScynZbFxf8ll5/C
IFLxuza9YOTHaIUlr1l14+1850we5KKkZuS6iYELaJMXwlCj3G1ciFKqXB4g0dJO
0p/2mx3T8kxxkg6Yd7Pg
=qznj
-----END PGP SIGNATURE-----

--Sig_/CAj/qyhiMumS69DuPDRPde2--
