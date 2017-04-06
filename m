From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx5e: fix build error without
 CONFIG_SYSFS
Date: Thu, 06 Apr 2017 12:55:55 -0700 (PDT)
Message-ID: <20170406.125555.1576050282465956628.davem@davemloft.net>
References: <20170405091110.711-1-tobias.regnery@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tobias.regnery@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170405091110.711-1-tobias.regnery@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tobias Regnery <tobias.regnery@gmail.com>
Date: Wed,  5 Apr 2017 11:11:10 +0200

> Commit 9008ae074885 ("net/mlx5e: Minimize mlx5e_{open/close}_locked")
> copied the calls to netif_set_real_num_{tx,rx}_queues from
> mlx5e_open_locked to mlx5e_activate_priv_channels and wraps them in an
> if condition to test for netdev->real_num_{tx,rx}_queues.
> 
> But netdev->real_num_rx_queues is conditionally compiled in if CONFIG_SYSFS
> is set. Without CONFIG_SYSFS the build fails:
> 
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c: In function 'mlx5e_activate_priv_channels':
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2515:12: error: 'struct net_device' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_queues'?
> 
> Fix this by unconditionally call netif_set_real_num{tx,rx}_queues like before
> commit 9008ae074885.
> 
> Fixes: 9008ae074885 ("net/mlx5e: Minimize mlx5e_{open/close}_locked")
> Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>

Applied, thanks.
