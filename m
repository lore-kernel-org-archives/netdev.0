From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] net/mlx4_core: Use min_t instead of if for consistency
Date: Thu, 11 May 2017 11:28:18 +0300
Message-ID: <20170511082818.GB3616@mtr-leonro.local>
References: <1494490852-5567-1-git-send-email-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="3uo+9/B/ebqu+fSQ"
Cc: yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1494490852-5567-1-git-send-email-yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--3uo+9/B/ebqu+fSQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 11, 2017 at 11:20:52AM +0300, Yuval Shaia wrote:
> Signed-off-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index 7032054..a58b15a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2862,12 +2862,11 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
>  	int port = 0;
>
>  	if (msi_x) {
> -		int nreq = dev->caps.num_ports * num_online_cpus() + 1;
> +		int nreq = min_t(int,
> +				 dev->caps.num_ports * num_online_cpus() + 1,
> +				 dev->caps.num_eqs - dev->caps.reserved_eqs);
>
> -		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
> -			     nreq);
> -		if (nreq > MAX_MSIX)
> -			nreq = MAX_MSIX;
> +		nreq = min_t(nreq, MAX_MSIX);

I don't see min_t (int, ..) here.

>
>  		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
>  		if (!entries)
> --
> 2.7.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--3uo+9/B/ebqu+fSQ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkUIKIACgkQ5GN7iDZy
WKej3g//Zj0VwQ7h+1oL8h+p0PgvaKr4BNklUdg+hwMAbCkVp+OJ+TjfZQ5orLgo
rlSZvJYkpDpTTIZovVijYuJxFCPWuwzIZKTQXy58vC5I69wMPjB77XICbErHf+XM
9EcBizY7/XyGyxNr9eznmu6Qn7rpzLK+0JomPvNavHXa/DeopcGwNKxqOVeKv3rB
9g1SHRaB6prhCCKFTATX2fi/xvph+wFLIwNv5BcUzN4kpf4CIeRp22HHrOyEip/t
RjjzgmGpruv7vdByEUiqfv3q7SONAJWwHKAYOSPxnBP/hFtjEjuZ8LswtkiTSdl1
nSDtz3QMk3FmDWnwHjZG1ri/j7e6/vGXrO34xUQWrL/QUvSR/BLYCnc4s7y5ogSC
mR7T7uzfUe0+8xpEc90qhNkuxIBwR+B4xDPZEIB0GT/J2N2AuJdSRok0uld3GeiF
mLDA43x2jYCR6Zd7NXFgPmloK1eEw3dn+4B3HajaFlKKagdtRKI+NnkH9+YNOIxP
zIgBUFONHcFitc1Topc1MdmIrNszlCuW7FiMXE/HgndB5nOAKABrW76FJxa7v+QC
DmJQFNYcyFTr9vg9WeA4eV2KKdvuNS3zQCFpR7/E838fx8Ifw2I2cGFTFa+lhTrt
0KT1Je64ZLeXfirFn03x4sIMMbdNAK7rcX4NFWoVy15D8k+1wp4=
=jh70
-----END PGP SIGNATURE-----

--3uo+9/B/ebqu+fSQ--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
