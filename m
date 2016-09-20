From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next V2 3/4] net/mlx4_core: Use RCU to perform radix
 tree lookup for SRQ
Date: Tue, 20 Sep 2016 15:47:49 +0300
Message-ID: <33b95e3f-ae37-4635-1810-c8e65d075e4d@cogentembedded.com>
References: <1474371582-998-1-git-send-email-tariqt@mellanox.com>
 <1474371582-998-4-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:34281 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751040AbcITMrw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 08:47:52 -0400
Received: by mail-lf0-f52.google.com with SMTP id y6so12617823lff.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 05:47:52 -0700 (PDT)
In-Reply-To: <1474371582-998-4-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/20/2016 2:39 PM, Tariq Toukan wrote:

> From: Leon Romanovsky <leonro@mellanox.com>
>
> Radix tree lookup can be performed without locking.
>
> Fixes: 225c7b1feef1 ("IB/mlx4: Add a driver Mellanox ConnectX InfiniBand adapters")
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
> Suggested-by: Sagi Grimberg <sagi@grimberg.me>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/srq.c | 14 +++++---------
>  1 file changed, 5 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
> index 67146624eb58..f44d089e2ca6 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/srq.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
> @@ -45,15 +45,12 @@ void mlx4_srq_event(struct mlx4_dev *dev, u32 srqn, int event_type)
>  	struct mlx4_srq_table *srq_table = &mlx4_priv(dev)->srq_table;
>  	struct mlx4_srq *srq;
>
> -	spin_lock(&srq_table->lock);
> -
> +	rcu_read_lock();
>  	srq = radix_tree_lookup(&srq_table->tree, srqn & (dev->caps.num_srqs - 1));
> +	rcu_read_unlock();
>  	if (srq)
>  		atomic_inc(&srq->refcount);
> -
> -	spin_unlock(&srq_table->lock);
> -
> -	if (!srq) {
> +	else {
>  		mlx4_warn(dev, "Async event for bogus SRQ %08x\n", srqn);
>  		return;
>  	}

    CodingStyle: all branches of the *if* statement should have {} if at least 
one has.

[...]

MBR, Sergei
