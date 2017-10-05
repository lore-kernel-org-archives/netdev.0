From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] net/mlx4_core: Convert timers to use timer_setup()
Date: Thu, 5 Oct 2017 12:38:02 +0300
Message-ID: <20171005093802.GK25829@mtr-leonro.local>
References: <20171005005154.GA23500@beast>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="/rDaUNvWv5XYRSKj"
Cc: linux-kernel@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171005005154.GA23500@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--/rDaUNvWv5XYRSKj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Oct 04, 2017 at 05:51:54PM -0700, Kees Cook wrote:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-rdma@vger.kernel.org
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> This requires commit 686fef928bba ("timer: Prepare to change timer
> callback argument type") in v4.14-rc3, but should be otherwise
> stand-alone.
> ---
>  drivers/net/ethernet/mellanox/mlx4/catas.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
>

Hi Kees,

In RDMA, we had very similar patch [1] to your patch series, but it converts to
setup_timer, while you are converting to timer_setup.

Which conversion is the right one?

[1] https://patchwork.kernel.org/patch/9980701/

Thanks

> diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
> index 53daa6ca5d83..e2b6b0cac1ac 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/catas.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
> @@ -231,10 +231,10 @@ static void dump_err_buf(struct mlx4_dev *dev)
>  			 i, swab32(readl(priv->catas_err.map + i)));
>  }
>
> -static void poll_catas(unsigned long dev_ptr)
> +static void poll_catas(struct timer_list *t)
>  {
> -	struct mlx4_dev *dev = (struct mlx4_dev *) dev_ptr;
> -	struct mlx4_priv *priv = mlx4_priv(dev);
> +	struct mlx4_priv *priv = from_timer(priv, t, catas_err.timer);
> +	struct mlx4_dev *dev = &priv->dev;
>  	u32 slave_read;
>
>  	if (mlx4_is_slave(dev)) {
> @@ -277,7 +277,7 @@ void mlx4_start_catas_poll(struct mlx4_dev *dev)
>  	phys_addr_t addr;
>
>  	INIT_LIST_HEAD(&priv->catas_err.list);
> -	init_timer(&priv->catas_err.timer);
> +	timer_setup(&priv->catas_err.timer, poll_catas, 0);
>  	priv->catas_err.map = NULL;
>
>  	if (!mlx4_is_slave(dev)) {
> @@ -293,8 +293,6 @@ void mlx4_start_catas_poll(struct mlx4_dev *dev)
>  		}
>  	}
>
> -	priv->catas_err.timer.data     = (unsigned long) dev;
> -	priv->catas_err.timer.function = poll_catas;
>  	priv->catas_err.timer.expires  =
>  		round_jiffies(jiffies + MLX4_CATAS_POLL_INTERVAL);
>  	add_timer(&priv->catas_err.timer);
> --
> 2.7.4
>
>
> --
> Kees Cook
> Pixel Security
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--/rDaUNvWv5XYRSKj
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnV/XoACgkQ5GN7iDZy
WKfQaxAAz9yeFZA1Jq8DZBGOT1fzeG6kscJUPFym/HYknwiTY/WCoHOD1Smka+/u
DRe1jlLkoaJt8GSsPmZgmyZxK0GX3xQAK3yf0rRvMU/SYrPp9jIBzI+UZXITtLBS
n2ZAX2Ur8ffPQsliyYbidUML6GX6XWvwe4cR5Mursl6MZ6uNKl1Uk8yiPsecYRHo
LWqGgy99Ga/Da3Ly/iA3jUOAX48g6pJgf54Ms0uHRCiY5jhdQEmluw5QQs+L5YtA
bPk217vQaHCvd09OWL836GZlM60+1dCqgNG21KWGYk1rkvwvp7pzY4p8k4UGH1KS
r2YcONMYU8jUw5YlCrG/jHcHogSwYo4lYRH8NP4ImPQN6BFXSe6C/qvVpOkW1Am9
3CRs5eNt6eUs1tTjR6fidV7GzVSf2pNow9Fbd9IWIE9NSop62Fk9AHeSZeP1U9IB
B6SPVeJNWMlsbQnNEVyiEeBuW9qVyyTFODrggJ4VKAkEmDjmHr5e5CobBvSK0XXl
LdJCexsRzpsFH2zobLHuYCZ94NymCXSD9GkjPBxeblYomESwvawI+bAdi8FeSGgh
LJfIwJyQOPh8umfEgdAJLUuzuwtEtCBbkKIExp5zrmS9oWBez3EUQAlt1ZK5kh6q
ULNMRk5Atpy39qZy99M7hZEu+Ffba7ff3rsGEchHJ1zrvWE6JJQ=
=KU2C
-----END PGP SIGNATURE-----

--/rDaUNvWv5XYRSKj--
