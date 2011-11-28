From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH V2 6/7] net/mlx4_en: adding loopback support
Date: Mon, 28 Nov 2011 14:17:09 -0800
Message-ID: <CAF2d9jj3jQPKhifOy5+QQg_wjgokMCE0CmZcvLiOf7HDVBd3PA@mail.gmail.com>
References: <4ED1D0C7.2040906@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	oren@mellanox.co.il, amirv@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35894 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876Ab1K1WRc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 17:17:32 -0500
Received: by faas1 with SMTP id s1so3058920faa.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 14:17:30 -0800 (PST)
In-Reply-To: <4ED1D0C7.2040906@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2011 at 9:55 PM, Yevgeny Petrilin
<yevgenyp@mellanox.co.il> wrote:
> From: Amir Vadai <amirv@mellanox.co.il>
>
> Device must be in promiscuous mode or DMAC must be same as the host M=
AC, or
> else packet will be dropped by the HW rx filtering.
>
> Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
Acked-by: Mahesh Bandewar <maheshb@google.com>

Thanks,
--mahesh..
> ---
> =A0drivers/net/ethernet/mellanox/mlx4/en_netdev.c | =A0 19 ++++++++++=
+++++++++
> =A0drivers/net/ethernet/mellanox/mlx4/en_tx.c =A0 =A0 | =A0 =A03 +--
> =A0drivers/net/ethernet/mellanox/mlx4/mlx4_en.h =A0 | =A0 =A01 +
> =A0include/linux/mlx4/qp.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 =A01 +
> =A04 files changed, 22 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers=
/net/ethernet/mellanox/mlx4/en_netdev.c
> index 78d776b..4c5bbb3 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -974,6 +974,21 @@ static int mlx4_en_change_mtu(struct net_device =
*dev, int new_mtu)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static int mlx4_en_set_features(struct net_device *netdev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_features_t features)
> +{
> + =A0 =A0 =A0 struct mlx4_en_priv *priv =3D netdev_priv(netdev);
> +
> + =A0 =A0 =A0 if (features & NETIF_F_LOOPBACK)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->ctrl_flags |=3D cpu_to_be32(MLX4_=
WQE_CTRL_FORCE_LOOPBACK);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->ctrl_flags &=3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_to_be32(~MLX4_WQE_C=
TRL_FORCE_LOOPBACK);
> +
> + =A0 =A0 =A0 return 0;
> +
> +}
> +
> =A0static const struct net_device_ops mlx4_netdev_ops =3D {
> =A0 =A0 =A0 =A0.ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D mlx4_en_open=
,
> =A0 =A0 =A0 =A0.ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D mlx4_en_clos=
e,
> @@ -990,6 +1005,7 @@ static const struct net_device_ops mlx4_netdev_o=
ps =3D {
> =A0#ifdef CONFIG_NET_POLL_CONTROLLER
> =A0 =A0 =A0 =A0.ndo_poll_controller =A0 =A0=3D mlx4_en_netpoll,
> =A0#endif
> + =A0 =A0 =A0 .ndo_set_features =A0 =A0 =A0 =3D mlx4_en_set_features,
> =A0};
>
> =A0int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
> @@ -1022,6 +1038,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mde=
v, int port,
> =A0 =A0 =A0 =A0priv->port =3D port;
> =A0 =A0 =A0 =A0priv->port_up =3D false;
> =A0 =A0 =A0 =A0priv->flags =3D prof->flags;
> + =A0 =A0 =A0 priv->ctrl_flags =3D cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDAT=
E |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MLX4_WQE_CTRL_SOLICITED=
);
> =A0 =A0 =A0 =A0priv->tx_ring_num =3D prof->tx_ring_num;
> =A0 =A0 =A0 =A0priv->rx_ring_num =3D prof->rx_ring_num;
> =A0 =A0 =A0 =A0priv->mac_index =3D -1;
> @@ -1088,6 +1106,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mde=
v, int port,
> =A0 =A0 =A0 =A0dev->features =3D dev->hw_features | NETIF_F_HIGHDMA |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NETIF_F_HW_VLAN_TX | N=
ETIF_F_HW_VLAN_RX |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NETIF_F_HW_VLAN_FILTER=
;
> + =A0 =A0 =A0 dev->hw_features |=3D NETIF_F_LOOPBACK;
>
> =A0 =A0 =A0 =A0mdev->pndev[port] =3D dev;
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net=
/ethernet/mellanox/mlx4/en_tx.c
> index 3094f94..807c218 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -679,8 +679,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, str=
uct net_device *dev)
> =A0 =A0 =A0 =A0tx_desc->ctrl.vlan_tag =3D cpu_to_be16(vlan_tag);
> =A0 =A0 =A0 =A0tx_desc->ctrl.ins_vlan =3D MLX4_WQE_CTRL_INS_VLAN * !!=
vlan_tag;
> =A0 =A0 =A0 =A0tx_desc->ctrl.fence_size =3D (real_size / 16) & 0x3f;
> - =A0 =A0 =A0 tx_desc->ctrl.srcrb_flags =3D cpu_to_be32(MLX4_WQE_CTRL=
_CQ_UPDATE |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 MLX4_WQE_CTRL_SOLICITED);
> + =A0 =A0 =A0 tx_desc->ctrl.srcrb_flags =3D priv->ctrl_flags;
> =A0 =A0 =A0 =A0if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tx_desc->ctrl.srcrb_flags |=3D cpu_to_=
be32(MLX4_WQE_CTRL_IP_CSUM |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MLX4_WQE_CTRL_TCP_UDP_CSUM);
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/n=
et/ethernet/mellanox/mlx4/mlx4_en.h
> index c367832..7d26b7a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -452,6 +452,7 @@ struct mlx4_en_priv {
> =A0 =A0 =A0 =A0int base_qpn;
>
> =A0 =A0 =A0 =A0struct mlx4_en_rss_map rss_map;
> + =A0 =A0 =A0 u32 ctrl_flags;
> =A0 =A0 =A0 =A0u32 flags;
> =A0#define MLX4_EN_FLAG_PROMISC =A0 0x1
> =A0#define MLX4_EN_FLAG_MC_PROMISC =A0 =A0 =A0 =A00x2
> diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
> index 6562ff6..bee8fa2 100644
> --- a/include/linux/mlx4/qp.h
> +++ b/include/linux/mlx4/qp.h
> @@ -210,6 +210,7 @@ struct mlx4_wqe_ctrl_seg {
> =A0 =A0 =A0 =A0 * [4] =A0 IP checksum
> =A0 =A0 =A0 =A0 * [3:2] C (generate completion queue entry)
> =A0 =A0 =A0 =A0 * [1] =A0 SE (solicited event)
> + =A0 =A0 =A0 =A0* [0] =A0 FL (force loopback)
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0__be32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0srcrb_flags;
> =A0 =A0 =A0 =A0/*
> --
> 1.7.7
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
