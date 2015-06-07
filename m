From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] ssb: fix handling of ssb_pmu_get_alp_clock()
Date: Sun, 7 Jun 2015 09:02:23 +0200
Message-ID: <20150607090223.13463c73@wiggum>
References: <1433634771-23438-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/glfxgCzexqhwEL5L.MzVfw9"; protocol="application/pgp-signature"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-mips@linux-mips.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1433634771-23438-1-git-send-email-hauke@hauke-m.de>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

--Sig_/glfxgCzexqhwEL5L.MzVfw9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun,  7 Jun 2015 01:52:51 +0200
Hauke Mehrtens <hauke@hauke-m.de> wrote:

> Dan Carpenter reported missing brackets which resulted in reading a
> wrong crystalfreq value. I also noticed that the result of this
> function is ignored.
>=20
> Reported-By: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
>  drivers/ssb/driver_chipcommon_pmu.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/ssb/driver_chipcommon_pmu.c b/drivers/ssb/driver_chi=
pcommon_pmu.c
> index 0942841..c5352ea 100644
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
> +		       SSB_CHIPCO_PMU_CTL_XTALFREQ)  >> SSB_CHIPCO_PMU_CTL_XTALFREQ_SH=
IFT;
>  	e =3D pmu0_plltab_find_entry(crystalfreq);
>  	BUG_ON(!e);
>  	return e->freq * 1000;
> @@ -634,7 +634,7 @@ u32 ssb_pmu_get_alp_clock(struct ssb_chipcommon *cc)
> =20
>  	switch (bus->chip_id) {
>  	case 0x5354:
> -		ssb_pmu_get_alp_clock_clk0(cc);
> +		return ssb_pmu_get_alp_clock_clk0(cc);
>  	default:
>  		ssb_err("ERROR: PMU alp clock unknown for device %04X\n",
>  			bus->chip_id);

Looks good.
Signed-off-by: Michael Buesch <m@bues.ch>

Can some MIPS people take this, please?

--=20
Michael

--Sig_/glfxgCzexqhwEL5L.MzVfw9
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVc+yCAAoJEPUyvh2QjYsOKrIQALY/QqdiiTFsFGjhIF7ALwRD
9rH2+Nh7FemGIDylyInaDwfAadXJYfDK9HkrAM+EXAszOYlmpp8JGFYoIkVsN2mO
UPg5KgZFOzz8jhPIHmGorSf/naw1rrqZTMslSrxzW9bHcbrKHa1ZXghGGWfKFToD
4zykoFD1h3OoE1I0bLOaR+t9vb1pCbFEY5Z4jFwEWajQmxqI9DREd6cyUFUMjGIQ
5emPmc7mcz3JxpAD8Tkef8YSpvCH/1B5roVf4Fu0UgRcAh89wxGEu0p9uj+ZO/TC
HmSdL8YTROVxH+WCN/IteUSh55zD9DA7mKaCOSgQDS/prHg29XNfDagIz7E+D/Pt
yFQslDQBkR6Ww5xadwMp+hw+GLchRA8WCsaqMR6SK+e+ctd2zirhIxVqA5IvNx99
idCMNlvDfrIvMAlF0Xs14RlIyE+p4uebzBIMGi5P3h34tsVkoDpDdzS1j0JWP+ME
rLJ1VxCo4KbaJdXUp0MS1jXT4bOMJP0I9Qoanit/yTqO2cNFakr5bPy+Cac6V+dJ
K4HIQflzpCzCrbXXaN2z7uDFliaHn6sYatDTwgJvXfKWHL9lf0HaAYmtIWrd8aCH
njyKR2SiG805eSWl1ee357W6GcO0eZwf247vsWDvujESGUllYEXL0wCjxwqjGN2v
gDVzaKJgO+sbs5vRSUCB
=WgCq
-----END PGP SIGNATURE-----

--Sig_/glfxgCzexqhwEL5L.MzVfw9--
