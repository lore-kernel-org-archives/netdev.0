From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [RFC v1 for accelerated IPoIB 14/25] net/mlx5: Enable
 flow-steering for IB link
Date: Wed, 15 Mar 2017 20:56:38 +0200
Message-ID: <20170315185638.GG2079@mtr-leonro.local>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-15-git-send-email-erezsh@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="OlucDFihBVSxvK/7"
Cc: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>, <valex@mellanox.com>,
        <saedm@mellanox.com>, <erezsh@dev.mellanox.co.il>
To: Erez Shitrit <erezsh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr30044.outbound.protection.outlook.com ([40.107.3.44]:42491
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750877AbdCOTQA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 15:16:00 -0400
Content-Disposition: inline
In-Reply-To: <1489429896-10781-15-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--OlucDFihBVSxvK/7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 13, 2017 at 08:31:25PM +0200, Erez Shitrit wrote:
>
> Get the relevant capabilities if supports ipoib_enhanced_offloads and
> init the flow steering table accordingly.
>
> Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 10 +++++-----
>  drivers/net/ethernet/mellanox/mlx5/core/fw.c      |  3 ++-
>  2 files changed, 7 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
> index fa4edd88daf1..dd21fc557281 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
> @@ -1991,9 +1991,6 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
>  	struct mlx5_flow_steering *steering;
>  	int err = 0;
>
> -	if (MLX5_CAP_GEN(dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
> -		return 0;
> -
>  	err = mlx5_init_fc_stats(dev);
>  	if (err)
>  		return err;
> @@ -2004,8 +2001,11 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
>  	steering->dev = dev;
>  	dev->priv.steering = steering;
>
> -	if (MLX5_CAP_GEN(dev, nic_flow_table) &&
> -	    MLX5_CAP_FLOWTABLE_NIC_RX(dev, ft_support)) {
> +	if ((((MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_ETH) &&
> +	      (MLX5_CAP_GEN(dev, nic_flow_table))) ||
> +	     ((MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_IB) &&
> +	      MLX5_CAP_GEN(dev, ipoib_enhanced_offloads)))
> +	    && MLX5_CAP_FLOWTABLE_NIC_RX(dev, ft_support)) {

Erez,

Please calculate the result outside of "if.." and do it in steps,
it is pretty hard to count all these brackets.

Thanks

--OlucDFihBVSxvK/7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAljJjmUACgkQ5GN7iDZy
WKdugA//ZL8JRzhNUFUhomYMn0+lA0zq/Bgk3dXEnkBPRvBSAKrfufxM5p5XmfZ9
dzo4d9kbUif/8ZGumLya1oMZMrkpRxMrCU5OJXDBDC2LRR4ltepr2mjNDxcv+khB
ha5Y8TKqYvaCOW0/brNzTkQJr2i2a7OIZnnGGt/eUwsguFedJqgJyugogckiKZ62
OPmNE+e3xWn1F4nR+XzVnYTNsFjQ1DvC7RXfR3qaeQAtPH+Q6ZhRRA5AA3iOaOnC
KnbYffGpU7WV1TRgoscDNWHbC36wGHTMaHOv0q4DWazyM26FwqTMeTGn9FnGgvJj
TD/fuPs03a4CNTd9+m8cZcNf5rh1A4Q1sq1y91kzme/3h1lud5d1NNYCIWe2GVC9
31aS3z696AZTR0j6FZctLbFATa+7iXx9QS81cDDFo45/fDgdnfDyjV6Zymldf4OZ
1OfX1WzLRNmfw6Ob7Gs3HJP3B9dtzEca13TRzrM9/4TpYAIbco2G8nTZSRqsWaZF
LQXZB3f/WKkrxpp9lx2LHZJtfvCW1pdcsirbBFvoWL14d5SydnF4EvUG+63G+F9n
0TJzrwksCJql14D7MDSXd0Z1A54nwFAfql3nHJY/MGr0IzZGHOdyp8pGvd5Baa2P
Nr5xr42UAT/VglYndtzc5n3gxZ4tRfMUQa8YzQ3MIn+v8Hnz/Dk=
=4+zF
-----END PGP SIGNATURE-----

--OlucDFihBVSxvK/7--
