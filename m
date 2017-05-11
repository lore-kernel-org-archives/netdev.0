From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v1] net/mlx4_core: Use min_t instead of if for consistency
Date: Thu, 11 May 2017 13:23:29 +0300
Message-ID: <20170511102329.GC3616@mtr-leonro.local>
References: <1494492389-15040-1-git-send-email-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="PuGuTyElPB9bOcsM"
Cc: yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1494492389-15040-1-git-send-email-yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--PuGuTyElPB9bOcsM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 11, 2017 at 11:46:29AM +0300, Yuval Shaia wrote:
> Signed-off-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
> v0 -> v1:
> 	* s/"min_t("/"min_t(int"
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index 7032054..7bb377e 100644
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
> +		nreq = min_t(int, nreq, MAX_MSIX);

You don't need type checking for these variables, they are all int and
you can use directly min3(..).

Thanks

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

--PuGuTyElPB9bOcsM
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkUO6AACgkQ5GN7iDZy
WKcaaBAAzYTO6hTZ+a/exJ6YutbFjccSVW16KRFTuyo8N6yOGxWw8oXuX2IXjEVN
IjBlqiwiiSZzb1wm+9lNyCvQE38on9UnNeIAgpGc/6ZAue8kMt1VItaO2gF57kJC
Lvv/dvNagmyj0CzkqUKqFL31InPnlYpS/P0ZBJgxK62c0LEg+YNkmySkypNjM63w
vvs4Ir1Eo0AH3Lj5a+r+6IXLDYzl1hG6PN+1mwx7XVoPhAFvar9/INfhIOFnoP1S
0UJrkm9zRUcS8h3boFanJCtBzry2kL1iG802sMmT57X6vOV9PBxWvLXB4eWjnCaA
NkiPbT0pddNqF3KtBDz6mD4mpcnMK8BOrF85pkwMQMtC1EdBxAvsVDXQ+O3MJb3X
630g/PdXSKMI38BZNcBQ+ocVYHBR8c7nYjSGX4jMMP0WzSWumY7OM1EQ534Cluq5
IVEWRa5+5Ie8lMboHZDRlqUdWEv59WEcVI8MzxVpaBVyDXuNvVlGX3tsHzwnexwW
Uh6FOf3e5i2OzBSKow/XXERIm+IgJ2mpJBZ3CA1MQ6vk6+mUOr+yoSP32KT8xmoN
5pHb/8AboYdrsvBWSxLGREPBN/2JhMpZvN3vb4Gtisu8Yl8BkOOOADpUynxKztIJ
p9QQHgR2CzzQLIF8M6M37HcQERhF+ORvu9gUereiCdaf1RIsgQM=
=QtcU
-----END PGP SIGNATURE-----

--PuGuTyElPB9bOcsM--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
