From: Amir Vadai <amirv@mellanox.com>
Subject: RE: [PATCH 7/8] net/mlx4_en: adding loopback support
Date: Wed, 23 Nov 2011 07:27:20 +0000
Message-ID: <EB097B4067A7C64DA511817018705AE523B0CF2D@MTLDAG01.mtl.com>
References: <4ECA0F4A.30308@mellanox.co.il>
 <CAF2d9jhesfOW8c4pXOAmMGonGv+1ryFsZ_PoCknX+ahy-fGdaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Oren Duer <oren@mellanox.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:38240 "HELO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752921Ab1KWIVA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 03:21:00 -0500
In-Reply-To: <CAF2d9jhesfOW8c4pXOAmMGonGv+1ryFsZ_PoCknX+ahy-fGdaw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, this is a good idea. I will fix it.

- Amir

-----Original Message-----
=46rom: Mahesh Bandewar [mailto:maheshb@google.com]=20
Sent: Wednesday, November 23, 2011 3:35 AM
To: Yevgeny Petrilin
Cc: davem@davemloft.net; netdev@vger.kernel.org; Or Gerlitz; Oren Duer;=
 Amir Vadai
Subject: Re: [PATCH 7/8] net/mlx4_en: adding loopback support

On Mon, Nov 21, 2011 at 12:43 AM, Yevgeny Petrilin
<yevgenyp@mellanox.co.il> wrote:
>
> From: Amir Vadai <amirv@mellanox.co.il>
>
> Device must be in promiscious mode or DMAC must be same as the host M=
AC, or
> else packet will be dropped by the HW rx filtering.
>
> Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
> ---
> =A0drivers/net/ethernet/mellanox/mlx4/en_netdev.c | =A0 =A01 +
> =A0drivers/net/ethernet/mellanox/mlx4/en_tx.c =A0 =A0 | =A0 =A03 +++
> =A0include/linux/mlx4/qp.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 =A01 +
> =A03 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers=
/net/ethernet/mellanox/mlx4/en_netdev.c
> index 78d776b..55fdbce 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1088,6 +1088,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mde=
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
> index 3094f94..f9093b5 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -681,6 +681,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, str=
uct net_device *dev)
> =A0 =A0 =A0 =A0tx_desc->ctrl.fence_size =3D (real_size / 16) & 0x3f;
> =A0 =A0 =A0 =A0tx_desc->ctrl.srcrb_flags =3D cpu_to_be32(MLX4_WQE_CTR=
L_CQ_UPDATE |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0MLX4_WQE_CTRL_SOLICITED);
> + =A0 =A0 =A0 if (dev->features & NETIF_F_LOOPBACK)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_desc->ctrl.srcrb_flags |=3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_to_be32(MLX4_WQE_CT=
RL_FORCE_LOOPBACK);

This is re-calculated for every xmit. Is it required to be that way?
May be you can pre-calculate it and just assign / add it to the
control-flags here.

> =A0 =A0 =A0 =A0if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tx_desc->ctrl.srcrb_flags |=3D cpu_to_=
be32(MLX4_WQE_CTRL_IP_CSUM |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MLX4_WQE_CTRL_TCP_UDP_CSUM);
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
