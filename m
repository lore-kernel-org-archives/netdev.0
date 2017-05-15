From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net 1/6] net/mlx5e: Use a spinlock to synchronize statistics
Date: Mon, 15 May 2017 15:51:19 -0700
Message-ID: <20170515155119.040047d1@xeon-e3>
References: <20170512115650.11635-1-saeedm@mellanox.com>
        <20170512115650.11635-2-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Gal Pressman <galp@mellanox.com>, kernel-team@fb.com
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33248 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbdEOWvW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 18:51:22 -0400
Received: by mail-pf0-f174.google.com with SMTP id e193so70048215pfh.0
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 15:51:22 -0700 (PDT)
In-Reply-To: <20170512115650.11635-2-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 May 2017 14:56:45 +0300
Saeed Mahameed <saeedm@mellanox.com> wrote:

> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> index 0099a3e397bc..c41cf7e82795 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> @@ -756,6 +756,7 @@ struct mlx5e_priv {
>  	struct mlx5_core_dev      *mdev;
>  	struct net_device         *netdev;
>  	struct mlx5e_stats         stats;
> +	rwlock_t                   stats_lock;

A reader-writer lock is slower than a spin_lock.
The only case where reader/writer lock is preferred is when writer
will hold onto the lock for a significant amount of time.
Also you only need each statistic to be atomic, the network device API
never guarantees transactional update across multiple statistics.
