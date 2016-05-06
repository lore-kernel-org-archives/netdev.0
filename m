From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/3] net/mlx5e: make VXLAN support conditional
Date: Fri, 6 May 2016 13:12:49 -0700
Message-ID: <CAKgT0UcHtsnCb48SM6afYcuigd-7L0zSbNMeGJao9YLra4FDmw@mail.gmail.com>
References: <1462364774-3792510-1-git-send-email-arnd@arndb.de>
	<1462365116-3856622-1-git-send-email-arnd@arndb.de>
	<CALzJLG885q-Nm4xD3FobvY4A9RhLAV3jLwfAWdJwyDOid+tJ6g@mail.gmail.com>
	<4306900.EI0LQtX7kx@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Matthew Finlay <matt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Abramonvsky <hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Achiad Shochat <achiad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Gal Pressman <galp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4306900.EI0LQtX7kx@wuerfel>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 5, 2016 at 11:09 AM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Thursday 05 May 2016 19:44:36 Saeed Mahameed wrote:
>> On Wed, May 4, 2016 at 3:31 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
>> > VXLAN can be disabled at compile-time or it can be a loadable
>> > module while mlx5 is built-in, which leads to a link error:
>> >
>> > drivers/net/built-in.o: In function `mlx5e_create_netdev':
>> > ntb_netdev.c:(.text+0x106de4): undefined reference to `vxlan_get_rx_port'
>> >
>> > This avoids the link error and makes the vxlan code optional,
>> > like the other ethernet drivers do as well.
>> >
>> > Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
>> > Link: https://patchwork.ozlabs.org/patch/589296/
>> > Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
>> > ---
>> > I sent it originally on Feb 26 2016, but misread Saeed Mahameed's
>> > reply as saying that he'd fix it up himself. The new version
>> > should address the original comment.
>> > ---
>>
>> Hi Arnd,
>>
>> I didn't post a fix up since it is not needed anymore, see
>> b7aade15485a ('vxlan: break dependency with netdev drivers') in
>> net-next.
>>
>> The new issue is introduced due to : "net/mlx5: Kconfig: Fix
>> MLX5_EN/VXLAN build issue" which was merged from net tree.
>>
>> Dave shouldn't have merged it into net-next, I explicitly asked him
>> that in the cover letter.  Maybe he missed it.
>>
>> I just checked and It is sufficient to only take the revert patch:
>> [PATCH 1/3] Revert "net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue"
>> to net-next.
>>
>> Can you please confirm that with only the revert patch, you don't see
>> the issue ?
>
> Yes, it works, but not it is different from all the other drivers
> (MLX4, BENET, IXGBE, I40E, FM10K, QLCNIC, and QEDE). If the 'select
> VXLAN' is not the preferred way to handle this, we should change
> the other ones the same way, right?
>
> For reference, I've tried it out on the MLX4 driver, and it does
> seem nicer that way, see below.
>
>         Arnd
> ---
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> in case someone wants to pick up that patch and do the other
> ones as well.
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
> index 9ca3734ebb6b..88fff4484200 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
> +++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
> @@ -6,6 +6,7 @@ config MLX4_EN
>         tristate "Mellanox Technologies 1/10/40Gbit Ethernet support"
>         depends on MAY_USE_DEVLINK
>         depends on PCI
> +       select VXLAN
>         select MLX4_CORE
>         select PTP_1588_CLOCK
>         ---help---

This piece is unnecessary and unwanted.  We just recently added the
ability to load the modules without the need for VXLAN.  Lets not take
that in the wrong direction by having the drivers select a module they
don't have to have.

The rest of this code is probably fine.  After the dependency was
broken via b7aade15485a ('vxlan: break dependency with netdev
drivers') you could probably go through and just pull all the VXLAN
ifdefs from all the drivers since I don't think there is anything that
explicitly relies on that module anymore as the only export still
hanging around is vxlan_dev_create and I don't think any Ethernet
drivers are directly spawning VXLAN interfaces.

> @@ -24,13 +25,6 @@ config MLX4_EN_DCB
>
>           If unsure, set to Y
>
> -config MLX4_EN_VXLAN
> -       bool "VXLAN offloads Support"
> -       default y
> -       depends on MLX4_EN && VXLAN && !(MLX4_EN=y && VXLAN=m)
> -       ---help---
> -         Say Y here if you want to use VXLAN offloads in the driver.
> -
>  config MLX4_CORE
>         tristate
>         depends on PCI
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 6f28ac58251c..ad887c425f2d 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1691,10 +1691,8 @@ int mlx4_en_start_port(struct net_device *dev)
>         /* Schedule multicast task to populate multicast list */
>         queue_work(mdev->workqueue, &priv->rx_mode_task);
>
> -#ifdef CONFIG_MLX4_EN_VXLAN
>         if (priv->mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
>                 vxlan_get_rx_port(dev);
> -#endif
>         priv->port_up = true;
>         netif_tx_start_all_queues(dev);
>         netif_device_attach(dev);
> @@ -2337,7 +2335,6 @@ static int mlx4_en_get_phys_port_id(struct net_device *dev,
>         return 0;
>  }
>
> -#ifdef CONFIG_MLX4_EN_VXLAN
>  static void mlx4_en_add_vxlan_offloads(struct work_struct *work)
>  {
>         int ret;
> @@ -2448,7 +2445,6 @@ static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
>
>         return features;
>  }
> -#endif
>
>  static int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 maxrate)
>  {
> @@ -2501,11 +2497,9 @@ static const struct net_device_ops mlx4_netdev_ops = {
>         .ndo_rx_flow_steer      = mlx4_en_filter_rfs,
>  #endif
>         .ndo_get_phys_port_id   = mlx4_en_get_phys_port_id,
> -#ifdef CONFIG_MLX4_EN_VXLAN
>         .ndo_add_vxlan_port     = mlx4_en_add_vxlan_port,
>         .ndo_del_vxlan_port     = mlx4_en_del_vxlan_port,
>         .ndo_features_check     = mlx4_en_features_check,
> -#endif
>         .ndo_set_tx_maxrate     = mlx4_en_set_tx_maxrate,
>  };
>
> @@ -2539,11 +2533,9 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
>         .ndo_rx_flow_steer      = mlx4_en_filter_rfs,
>  #endif
>         .ndo_get_phys_port_id   = mlx4_en_get_phys_port_id,
> -#ifdef CONFIG_MLX4_EN_VXLAN
>         .ndo_add_vxlan_port     = mlx4_en_add_vxlan_port,
>         .ndo_del_vxlan_port     = mlx4_en_del_vxlan_port,
>         .ndo_features_check     = mlx4_en_features_check,
> -#endif
>         .ndo_set_tx_maxrate     = mlx4_en_set_tx_maxrate,
>  };
>
> @@ -2834,10 +2826,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
>         INIT_WORK(&priv->linkstate_task, mlx4_en_linkstate);
>         INIT_DELAYED_WORK(&priv->stats_task, mlx4_en_do_get_stats);
>         INIT_DELAYED_WORK(&priv->service_task, mlx4_en_service_task);
> -#ifdef CONFIG_MLX4_EN_VXLAN
>         INIT_WORK(&priv->vxlan_add_task, mlx4_en_add_vxlan_offloads);
>         INIT_WORK(&priv->vxlan_del_task, mlx4_en_del_vxlan_offloads);
> -#endif
>  #ifdef CONFIG_RFS_ACCEL
>         INIT_LIST_HEAD(&priv->filters);
>         spin_lock_init(&priv->filters_lock);
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 63b1aeae2c03..cbab8741d60f 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -546,10 +546,8 @@ struct mlx4_en_priv {
>         struct work_struct linkstate_task;
>         struct delayed_work stats_task;
>         struct delayed_work service_task;
> -#ifdef CONFIG_MLX4_EN_VXLAN
>         struct work_struct vxlan_add_task;
>         struct work_struct vxlan_del_task;
> -#endif
>         struct mlx4_en_perf_stats pstats;
>         struct mlx4_en_pkt_stats pkstats;
>         struct mlx4_en_counter_stats pf_stats;
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
