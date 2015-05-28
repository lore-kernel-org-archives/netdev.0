From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/4] net/mlx4_core: Make sure there are no pending
 async events when freeing CQ
Date: Thu, 28 May 2015 22:41:37 +0300
Message-ID: <55676F71.7070104@cogentembedded.com>
References: <1432827676-5599-1-git-send-email-ogerlitz@mellanox.com> <1432827676-5599-5-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:34454 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826AbbE1Tll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 15:41:41 -0400
Received: by lbcmx3 with SMTP id mx3so35314854lbc.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 12:41:39 -0700 (PDT)
In-Reply-To: <1432827676-5599-5-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/28/2015 06:41 PM, Or Gerlitz wrote:

> From: Matan Barak <matanb@mellanox.com>

> When freeing a CQ, we need to make sure there are no
> asynchronous events (on the ASYNC EQ) that could
> relate to this CQ before freeing it.

> This is done by introducing synchronize_irq.

> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/cq.c |    4 ++++
>   1 files changed, 4 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
> index 7431cd4..1fc1dc5 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cq.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
> @@ -369,6 +369,10 @@ void mlx4_cq_free(struct mlx4_dev *dev, struct mlx4_cq *cq)
>   		mlx4_warn(dev, "HW2SW_CQ failed (%d) for CQN %06x\n", err, cq->cqn);
>
>   	synchronize_irq(priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(cq->vector)].irq);
> +	if (priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(cq->vector)].irq !=
> +	    priv->eq_table.eq[MLX4_EQ_ASYNC].irq)
> +		synchronize_irq(priv->eq_table.eq[MLX4_EQ_ASYNC].irq);
> +
>

    I think one empty line was enough.

>   	spin_lock_irq(&cq_table->lock);
>   	radix_tree_delete(&cq_table->tree, cq->cqn);

WBR, Sergei
