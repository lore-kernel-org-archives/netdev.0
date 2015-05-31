From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] net/mlx4_core: Make sure there are no
 pending async events when freeing CQ
Date: Sat, 30 May 2015 23:23:45 -0700 (PDT)
Message-ID: <20150530.232345.188813752279467836.davem@davemloft.net>
References: <1432827676-5599-1-git-send-email-ogerlitz@mellanox.com>
	<1432827676-5599-5-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	talal@mellanox.com, idos@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbbEaGXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 02:23:48 -0400
In-Reply-To: <1432827676-5599-5-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 28 May 2015 18:41:16 +0300

> @@ -369,6 +369,10 @@ void mlx4_cq_free(struct mlx4_dev *dev, struct mlx4_cq *cq)
>  		mlx4_warn(dev, "HW2SW_CQ failed (%d) for CQN %06x\n", err, cq->cqn);
>  
>  	synchronize_irq(priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(cq->vector)].irq);
> +	if (priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(cq->vector)].irq !=
> +	    priv->eq_table.eq[MLX4_EQ_ASYNC].irq)
> +		synchronize_irq(priv->eq_table.eq[MLX4_EQ_ASYNC].irq);
> +
>  
>  	spin_lock_irq(&cq_table->lock);
>  	radix_tree_delete(&cq_table->tree, cq->cqn);

I agree with Sergei that one empty line is sufficient here, don't make
it into two.

Please respin with this fixed.
