From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] net/mlx5e: make VXLAN support conditional
Date: Mon, 29 Feb 2016 13:51:51 +0100
Message-ID: <2455934.lWxXaHB90g@wuerfel>
References: <1456521217-2174580-1-git-send-email-arnd@arndb.de> <CALzJLG8MG9y8yr7zi4UTED0FwgBTJ+_5vSSWHB5SHFs-e8WTbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG8MG9y8yr7zi4UTED0FwgBTJ+_5vSSWHB5SHFs-e8WTbg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 28 February 2016 15:26:53 Saeed Mahameed wrote:
> > diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> > index 0d45f35aee72..44fc4bc35ffd 100644
> > --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> > +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> > @@ -2116,6 +2116,9 @@ static netdev_features_t mlx5e_vxlan_features_check(struct mlx5e_priv *priv,
> >         u16 proto;
> >         u16 port = 0;
> >
> > +       if (!IS_ENABLED(CONFIG_MLX5_CORE_EN_VXLAN))
> > +               goto out;
> > +
> 
> I would rather wrap the whole mlx5e_features_check with the suggested
> config flag and disable it in case CONFIG_MLX5_CORE_EN_VXLAN is OFF,
> since this function is only needed for when vxlan is supported.

Sounds good.

I think moving the IS_ENABLED() check into the caller(s) will still
result in the same object code, but it makes sense to structure
the code for best readability.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
