From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next] liquidio: fix bug in soft reset failure
 detection
Date: Sun, 25 Jun 2017 09:11:37 +0300
Message-ID: <20170625061137.GP1248@mtr-leonro.local>
References: <20170624110020.GA1247@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="1WN/MJ7JJGqVzwIW"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:40030 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751185AbdFYGLl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Jun 2017 02:11:41 -0400
Content-Disposition: inline
In-Reply-To: <20170624110020.GA1247@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--1WN/MJ7JJGqVzwIW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jun 24, 2017 at 04:00:21AM -0700, Felix Manlunas wrote:
> From: Derek Chickles <derek.chickles@cavium.com>
>
> The code that detects a failed soft reset of Octeon is comparing the wrong
> value against the reset value of the Octeon SLI_SCRATCH_1 register,
> resulting in an inability to detect a soft reset failure.  Fix it by using
> the correct value in the comparison.
>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> ---
>  drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c | 2 +-
>  drivers/net/ethernet/cavium/liquidio/cn66xx_device.c    | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
> index 6081c31..3ab311f 100644
> --- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
> +++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
> @@ -221,7 +221,7 @@ static int cn23xx_pf_soft_reset(struct octeon_device *oct)
>  	/* Wait for 100ms as Octeon resets. */
>  	mdelay(100);
>
> -	if (octeon_read_csr64(oct, CN23XX_SLI_SCRATCH1) == 0x1234ULL) {
> +	if (octeon_read_csr64(oct, CN23XX_SLI_SCRATCH1) != 0x0ULL) {

Zero is always zero, please drop this 0x0ULL and add fixes line to the commit message.

>  		dev_err(&oct->pci_dev->dev, "OCTEON[%d]: Soft reset failed\n",
>  			oct->octeon_id);
>  		return 1;
> diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
> index b28253c..effd7ac 100644
> --- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
> +++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
> @@ -44,7 +44,7 @@ int lio_cn6xxx_soft_reset(struct octeon_device *oct)
>  	/* Wait for 10ms as Octeon resets. */
>  	mdelay(100);
>
> -	if (octeon_read_csr64(oct, CN6XXX_SLI_SCRATCH1) == 0x1234ULL) {
> +	if (octeon_read_csr64(oct, CN6XXX_SLI_SCRATCH1) != 0x0ULL) {
>  		dev_err(&oct->pci_dev->dev, "Soft reset failed\n");
>  		return 1;
>  	}

--1WN/MJ7JJGqVzwIW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllPVBkACgkQ5GN7iDZy
WKfF2xAA02Mxq5f5SDXsuFQwyreWB52DmZ96/7yFzcaAHhttSybdDgqkeJnTYPYB
c8Vjv8XRcfCBYX5828FrwYKYYmeQsO02pNzkfiM0DeM8w6MfYzwc577nC9YZ8MsZ
CFfp6IUnWfeKCgY8itdLvrQBYZIfnYXwO/y2WtUw1jKN/AnzCtoM1CU98qkvbjnv
oAJDwxHWldIovYegyWAiQDAG8dB30HAYmFMqFCYs5ssXvONRGeBIxeeJucRv8KaI
DQdgGXlSlzffk5FzQMlkdQkFd/+bipOlqjW9+qYa2s4Sfzek1BzmrFCo60kdIJvR
p5zIToUP7DeMPotin0Y68b4Z2Hl26OwEZcuF5ByP4EUwDofRG+FOCMBqgELNP4SK
xasNP1jANuEGkJJmESkbokz5HvT2xHdqrpK8QbAxdm+HYPkYpCTgBFupl7256L4l
WWom9ch3ECf5eKKr/9rsX50UhOXs4aQWhmWRzda2EcguRxUIcGX3gT20r+8JuIhG
Hh73H+T7Agg6F0L/5mPKFMuPsLj1wMFVK9hJRI7wiEvJTkigtRjBcvhT7k2dTplM
8QuJV1LEl2YR7XQoMA2jW5Q7QgbsVbLXzBlpCrNSep46XSuyHBG8bAour6hvFd0Z
dewy9tJgSfz/xzawtaDyJb2gjmE+JTIOF5EvyEMTkKmw/orOUII=
=pvyf
-----END PGP SIGNATURE-----

--1WN/MJ7JJGqVzwIW--
