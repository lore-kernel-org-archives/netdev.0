From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net 1/6] net/mlx4_en: Do not count dropped packets twice
Date: Tue, 16 Feb 2016 10:31:57 -0800
Message-ID: <56C36B1D.3050007@hpe.com>
References: <1455634911-31206-1-git-send-email-ogerlitz@mellanox.com>
 <1455634911-31206-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Amir Vadai <amir@vadai.me>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:56592 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964838AbcBPScA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 13:32:00 -0500
In-Reply-To: <1455634911-31206-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/16/2016 07:01 AM, Or Gerlitz wrote:
> From: Amir Vadai <amir@vadai.me>
>
> RdropOvflw counter was mistakenly copied into rx_missed_errors. Because
> of that it was counted twice for the device dropped packets accounting.
>
> Fixes: c27a02cd94d6 ('mlx4_en: Add driver for Mellanox ConnectX 10GbE NIC')
> Signed-off-by: Amir Vadai <amir@vadai.me>
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_port.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
> index ee99e67..7b511a5 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
> @@ -242,7 +242,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
>   	stats->rx_crc_errors = be32_to_cpu(mlx4_en_stats->RCRC);
>   	stats->rx_frame_errors = 0;
>   	stats->rx_fifo_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
> -	stats->rx_missed_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
> +	stats->rx_missed_errors = 0;
>   	stats->tx_aborted_errors = 0;
>   	stats->tx_carrier_errors = 0;
>   	stats->tx_fifo_errors = 0;
>

I'm still not clear on when an Acked-by is appropriate, but given that 
this has been a non-trivial frustration for a long time, a hearty 
endorsement from me.  Perhaps not important enough but it would be nice 
to have it flow back a release or two.

That said, should mlx4_en_stats->RdropOvflw still be going into both 
rx_fifo_errors and rx_over_errors?

         stats->rx_over_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
         stats->rx_crc_errors = be32_to_cpu(mlx4_en_stats->RCRC);
         stats->rx_frame_errors = 0;
         stats->rx_fifo_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);

happy benchmarking,

rick jones
