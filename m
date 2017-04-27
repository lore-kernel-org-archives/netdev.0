From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next] mlx5: work around unused function warning
Date: Thu, 27 Apr 2017 14:55:13 +0300
Message-ID: <20170427115513.GH14088@mtr-leonro.local>
References: <20170427110421.2431598-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="R4RAxL8G0iuuxuj8"
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170427110421.2431598-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--R4RAxL8G0iuuxuj8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Apr 27, 2017 at 01:04:02PM +0200, Arnd Bergmann wrote:
> The previous patch addressed a sparse warning but replaced it with a
> compiler warning when CONFIG_MODULES is disabled:
>
> drivers/net/ethernet/mellanox/mlx5/core/ipoib.c:485:13: error: 'mlx5_rdma_netdev_free' defined but not used [-Werror=unused-function]
> drivers/net/ethernet/mellanox/mlx5/core/ipoib.c:423:27: error: 'mlx5_rdma_netdev_alloc' defined but not used [-Werror=unused-function]
>
> We should never export 'static' functions, so this makes them global
> again but hides them in another #ifdef like the change before.
>
> Fixes: a7082ef066f0 ("mlx5: hide unused functions")
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/ipoib.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
>

Hi Arnd,

Thanks for the patch, but Stephen and Saeed already sent patch similar to it.
http://marc.info/?l=linux-netdev&m=149288674816288&w=2

Thanks

> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
> index 3c84e36af018..eb48f112dff4 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
> @@ -405,7 +405,6 @@ static int mlx5i_xmit(struct net_device *dev, struct sk_buff *skb,
>
>  	return mlx5i_sq_xmit(sq, skb, &mah->av, dqpn, dqkey);
>  }
> -#endif
>
>  static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
>  {
> @@ -420,10 +419,10 @@ static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
>  	return 0;
>  }
>
> -static struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
> -						 struct ib_device *ibdev,
> -						 const char *name,
> -						 void (*setup)(struct net_device *))
> +struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
> +					  struct ib_device *ibdev,
> +					  const char *name,
> +					  void (*setup)(struct net_device *))
>  {
>  	const struct mlx5e_profile *profile = &mlx5i_nic_profile;
>  	int nch = profile->max_nch(mdev);
> @@ -482,7 +481,7 @@ static struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
>  }
>  EXPORT_SYMBOL(mlx5_rdma_netdev_alloc);
>
> -static void mlx5_rdma_netdev_free(struct net_device *netdev)
> +void mlx5_rdma_netdev_free(struct net_device *netdev)
>  {
>  	struct mlx5e_priv          *priv    = mlx5i_epriv(netdev);
>  	const struct mlx5e_profile *profile = priv->profile;
> @@ -495,4 +494,4 @@ static void mlx5_rdma_netdev_free(struct net_device *netdev)
>  	mlx5e_destroy_mdev_resources(priv->mdev);
>  }
>  EXPORT_SYMBOL(mlx5_rdma_netdev_free);
> -
> +#endif
> --
> 2.9.0
>

--R4RAxL8G0iuuxuj8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkB3CEACgkQ5GN7iDZy
WKfGFhAAiQRLMpSOJJp8i4rykwGuI+/a49mQcK6kB+ACBS10YcSW0iKSEIVC79SJ
H8pYQprpi7hhma0pwIZfxjsq38PAlrG6yFPW+qLlys0047EgQ9PNn8dxRC16R5kr
bZygTK6dTei6Ilb8XQgINqXZ/A2aXaIJAtZyZDx9Ag5xsLmuNp6mQQfSc4m6kRVQ
RvjJC2v8BkRmWq5jLugIUdKKYI/zBbezKSnbgj9N75v8BWJrVARmMrgm05zvtEjN
vTto/nFJFW5VFCdUfHKg6Z3r8qngp7erCINbqY4DBwU2aOqWVSEEg6fww2O2Sr7H
mCoYm7xiUvmpe/uMdntPNNAXG0sJzV9R9V9bGABAsTS1eume3i9iDebzj7lhfHVv
MRlbjWsFgGenpSPILWGcJqD/6HwwpgWzd1hPrD86U0qxbW9buhhpnvgXooOib0q4
6fiCqtZYonI8RIHzgHWkhIUz/C0Z7WBc89TuVlKMQXAUoJRVT+XbqWIEt4D60GAn
03unDR0/D34d68xVuRrxd9PctXLcoO0bAclt7v7NnwHY5uiPVh0+on75beTefo9k
k0OvWzNvCvM8Laha1Lbf5DtclutOy7L/WYHMivy5q6am5eVeszMnokfF5DFQ/nhh
LO/ieKvWTUHY4DE/E+maM6xP9TgEsdW7KOIrH+emxdYSu1B1rcY=
=04CU
-----END PGP SIGNATURE-----

--R4RAxL8G0iuuxuj8--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
