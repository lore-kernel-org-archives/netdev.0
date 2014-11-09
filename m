From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH V2 net-next 2/2] net/mlx4_en: Extend checksum offloading
 by CHECKSUM COMPLETE
Date: Sun, 9 Nov 2014 10:14:32 +0200
Message-ID: <545F2268.9010108@mellanox.com>
References: <1415291324-22069-1-git-send-email-ogerlitz@mellanox.com> <1415291324-22069-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, Matan Barak <matanb@mellanox.com>,
	"Saeed Mahameed" <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	"Ido Shamay" <idos@mellanox.com>, Jerry Chu <hkchu@google.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:51402 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750769AbaKIIOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 03:14:39 -0500
In-Reply-To: <1415291324-22069-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/6/2014 6:28 PM, Or Gerlitz wrote:
> From: Shani Michaeli <shanim@mellanox.com>
> 
> When processing received traffic, pass CHECKSUM_COMPLETE status to the
> stack, with calculated checksum for non TCP/UDP packets (such
> as GRE or ICMP).
> 
> Although the stack expects checksum which doesn't include the pseudo
> header, the HW adds it. To address that, we are subtracting the pseudo
> header checksum from the checksum value provided by the HW.
> 
> In the IPv6 case, we also compute/add the IP header checksum which
> is not added by the HW for such packets.
> 
> Cc: Jerry Chu <hkchu@google.com>
> Signed-off-by: Shani Michaeli <shanim@mellanox.com>
> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    5 +
>  drivers/net/ethernet/mellanox/mlx4/en_port.c    |    2 +
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  127 +++++++++++++++++++++--
>  drivers/net/ethernet/mellanox/mlx4/main.c       |    9 ++
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    5 +-
>  include/linux/mlx4/device.h                     |    1 +
>  7 files changed, 142 insertions(+), 9 deletions(-)
> 

[...]

> @@ -702,8 +787,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  		 * and not performing the selftest or flb disabled
>  		 */
>  		if (priv->flags & MLX4_EN_FLAG_RX_FILTER_NEEDED) {
> -			struct ethhdr *ethh;
>  			dma_addr_t dma;
> +			struct ethhdr *ethh;
>  			/* Get pointer to first fragment since we haven't
>  			 * skb yet and cast it to ethhdr struct
>  			 */
This  hunk is not needed


> @@ -744,13 +829,26 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));

[...]

Amir
