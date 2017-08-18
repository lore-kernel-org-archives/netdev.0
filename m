From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH] mlx5: ensure 0 is returned when vport is zero
Date: Fri, 18 Aug 2017 19:02:02 +0300
Message-ID: <20170818160202.GA18138@mtr-leonro.local>
References: <20170818134925.16604-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="y0ulUmNC+osPPQO6"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170818134925.16604-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Aug 18, 2017 at 02:49:25PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> Currently, if vport is zero then then an uninialized return status
> in err is returned.  Since the only return status at the end of the
> function esw_add_uc_addr is zero for the current set of return paths
> we may as well just return 0 rather than err to fix this issue.
>
> Detected by CoverityScan, CID#1452698 ("Uninitialized scalar variable")
>
> Fixes: eeb66cdb6826 ("net/mlx5: Separate between E-Switch and MPFS")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
> index 6d9fb6ac6e9b..c77f4c0c7769 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
> @@ -401,7 +401,7 @@ static int esw_add_uc_addr(struct mlx5_eswitch *esw, struct vport_addr *vaddr)
>  	esw_debug(esw->dev, "\tADDED UC MAC: vport[%d] %pM fr(%p)\n",
>  		  vport, mac, vaddr->flow_rule);
>
> -	return err;
> +	return 0;
>  }
>

I personally prefer initialization of "err" to zero, but this solution
is fine enough too.

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--y0ulUmNC+osPPQO6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmXD3kACgkQ5GN7iDZy
WKdWmA//e9TDx4qVnGhvtQKD7/eiMbFxr1Dq7g+2NgUZi68JxVNtAEfoErH7Yls2
RxzkZ3i7+q9G7dgWvPkuL6xBy5e8/ycXWGDhqQpzgV5vI/dsFlSsaX7UR9iXSfmt
3bo1wJCrrZ9DNJ/fGzpDHAccv59zXj4fIwHFva9/mbJZnJxERb6IFVNEGkq2ncG7
/iE4TecM4nLm0hSh+rjVPu5LGv5hAvrgw5WWRo0Yi2Wxr79B23D2OmrJywxy4fN5
5bcZ6VddRKneupESMGgaRxJMt+tcAD6YrwC/m+wV4N9lbb1tLq4Ubnl6aFDOkSvB
W+kZZdwBGg5NP+9sxQPcgXI5CXt9qDILcGfRGH4Dl//v4KjGk+nOHBrv/a9BsgmE
ASM0lmPIfRdKN7X8t3hs+FEO8VqW8jsyHr+IHWiE3ugwok2y0T2UzaitDVF67PKM
yeoFrrLaWybSDuuviRXfYHsm0pLnudhlnAo+UHCPjN7TywyBG/CJNGdbRRveFD4n
YBSNp8O266tbOsxwmZQkHszp0MKzwVF5zXP8VJFI+7YSi02KJaF9aZ9FeJsC+wxZ
oL2iCwTBDwHNiOIP70uW1DPrlEziaNlTCgCCu3Ps2KbDYqjSWUk+z/TuLO5FpF3t
YM2Jd6Rd6+IOa9W8d6NFwWaMshm3/F6i4fGKKCCspTtsmo3gIRM=
=D2UC
-----END PGP SIGNATURE-----

--y0ulUmNC+osPPQO6--
