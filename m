From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next 11/11] net/mlx5: Ethernet driver
Date: Wed, 08 Apr 2015 19:07:39 -0700
Message-ID: <5525DEEB.7020102@redhat.com>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com> <1428504685-8945-12-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54201 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000AbbDICHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 22:07:41 -0400
In-Reply-To: <1428504685-8945-12-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 07:51 AM, Amir Vadai wrote:
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

> --- /dev/null
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> @@ -0,0 +1,518 @@

<snip>

> +			     struct mlx5e_params *new_params);
> +
> +static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
> +				      struct mlx5e_tx_wqe *wqe)
> +{
> +	/* ensure wqe is visible to device before updating doorbell record */
> +	wmb();
> +

Could this be replaced with a dma_wmb() since it seems like you are just 
doing two memory writes here between the wqe and *sq->wq.db.

> +	*sq->wq.db = cpu_to_be32(sq->pc);
> +
> +	/* ensure doorbell record is visible to device before ringing the
> +	 * doorbell */
> +	wmb();
> +
> +	mlx5_write64((__be32 *)&wqe->ctrl,
> +		     sq->uar_map + MLX5_BF_OFFSET + sq->bf_offset,
> +		     NULL);
> +
> +	sq->bf_offset ^= sq->bf_buf_size;
> +}
> +
> +static inline void mlx5e_cq_arm(struct mlx5e_cq *cq)
> +{
> +	struct mlx5_core_cq *mcq;
> +
> +	mcq = &cq->mcq;
> +	mlx5_cq_arm(mcq, MLX5_CQ_DB_REQ_NOT, mcq->uar->map, NULL, cq->wq.cc);
> +}
> +
> +extern const struct ethtool_ops mlx5e_ethtool_ops;
