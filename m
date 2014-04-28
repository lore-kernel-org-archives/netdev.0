From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 1/6] drivers: net: cpts: Remove hardcoded clock name for
 CPTS
Date: Mon, 28 Apr 2014 09:31:15 -0500
Message-ID: <20140428143115.GC30292@saruman.home>
References: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
 <1398658225-25873-2-git-send-email-george.cherian@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="B4IIlcmfBL/1gGOG"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<davem@davemloft.net>, <richardcochran@gmail.com>,
	<jeffrey.t.kirsher@intel.com>, <dborkman@redhat.com>,
	<ast@plumgrid.com>, <tklauser@distanz.ch>, <mpa@pengutronix.de>,
	<bhutchings@solarflare.com>, <zonque@gmail.com>, <balbi@ti.com>,
	<mugunthanvnm@ti.com>, <t-kristo@ti.com>, <mturquette@linaro.org>,
	<linux@arm.linux.org.uk>, <galak@codeaurora.org>,
	<ijc+devicetree@hellion.org.uk>, <mark.rutland@arm.com>,
	<pawel.moll@arm.com>, <robh+dt@kernel.org>, <tony@atomide.com>,
	<bcousson@baylibre.com>
To: George Cherian <george.cherian@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1398658225-25873-2-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--B4IIlcmfBL/1gGOG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 28, 2014 at 09:40:20AM +0530, George Cherian wrote:
> CPTS refclk name is hardcoded, which makes it fail in case of DRA7x
> Remove the hardcoded clock name for CPTS refclk and get the same from DT.
>=20
> Signed-off-by: George Cherian <george.cherian@ti.com>
> ---
>  drivers/net/ethernet/ti/cpts.c | 11 ++++-------
>  1 file changed, 4 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpt=
s.c
> index 2435139..0b6f6f7 100644
> --- a/drivers/net/ethernet/ti/cpts.c
> +++ b/drivers/net/ethernet/ti/cpts.c
> @@ -236,13 +236,11 @@ static void cpts_overflow_check(struct work_struct =
*work)
>  	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
>  }
> =20
> -#define CPTS_REF_CLOCK_NAME "cpsw_cpts_rft_clk"
> -
> -static void cpts_clk_init(struct cpts *cpts)
> +static void cpts_clk_init(struct device *dev, struct cpts *cpts)
>  {
> -	cpts->refclk =3D clk_get(NULL, CPTS_REF_CLOCK_NAME);
> +	cpts->refclk =3D devm_clk_get(dev, "cpts");
>  	if (IS_ERR(cpts->refclk)) {
> -		pr_err("Failed to clk_get %s\n", CPTS_REF_CLOCK_NAME);
> +		pr_err("Failed to get cpts refclk\n");

now you have a dev pointer as argument, how about converting this to
dev_err() ?

--=20
balbi

--B4IIlcmfBL/1gGOG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTXmYzAAoJEIaOsuA1yqREXIMP/1Bc/quLxm2iQcjkrvVGV0bG
8ysMIL84mDbhgbPzyDSj8KUK/wd714H0Lzc3hUbVemWRt3TlqYv/fjrwT6iEct9+
gKXY+FSHHQ71aMCGAeJq8lazpfgasexWVg6CVaAMHSIAdujQd3HwmXfswskV6aXz
47BGrfcUBfrmu25Ex2+HPLF6snIqi5lQg9TiejkQdtJKcE2LcVNMuinwExJ19B7b
8OrXwXhN6Y8zm7aOaP6dNd/yAsn2XTEWUy9nioUV0/t/bpcX7sIMdhkeoCoM/C75
hxTiMnfCHjhxdCznqsCQRsd3CwzGjX6vHg3tV5aFwHkp7vxbRUJnRIIUp7Q4wYWQ
So1WfQcsOjkiZcctjG7PdjnUDP15EXWDcSzgWJJLTLLKW63fWVzF5bZUGtlTQGyy
ERc6jBnfIDF0rD8pa1EEXXzKdJsimb9MhTWRYhieHWz+nNRIiOhhkRowURyl+D+r
8sm74qhtxxlzURtOHDfYRQX+/TMinKUDT+XEaItJ7sr6wBIYRSnnwzBDd5KEpBhc
O0QKckywGfxlCArB357BNPxuOuuOFZ5IVfJ4at6mDtJ4GbVB/pd93EVHPPA/Ceur
GiJUQDY7Cl83cQQZI9sSi/m9jVlYvNsmA4HlQZVI9/6IdFaC2N//py3fgMidqiIT
IaiVJR78G14uCHOOBCeO
=3dw5
-----END PGP SIGNATURE-----

--B4IIlcmfBL/1gGOG--
