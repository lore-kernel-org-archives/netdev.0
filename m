From: Yishai Hadas <yishaih@dev.mellanox.co.il>
Subject: Re: [PATCH] IB/mlx4: avoid a -Wmaybe-uninitialize warning
Date: Wed, 26 Oct 2016 09:51:04 +0300
Message-ID: <3a7b4d28-1700-7545-c1b7-7d2d463a17d7@dev.mellanox.co.il>
References: <20161025161632.411899-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Yishai Hadas <yishaih@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Moshe Shemesh <moshe@mellanox.com>,
        Christophe Jaillet <christophe.jaillet@wanadoo.fr>,
        Moni Shoua <monis@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161025161632.411899-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/2016 7:16 PM, Arnd Bergmann wrote:
> There is an old warning about mlx4_SW2HW_EQ_wrapper on x86:
>
> ethernet/mellanox/mlx4/resource_tracker.c: In function ‘mlx4_SW2HW_EQ_wrapper’:
> ethernet/mellanox/mlx4/resource_tracker.c:3071:10: error: ‘eq’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
>
> The problem here is that gcc won't track the state of the variable
> across a spin_unlock. Moving the assignment out of the lock is
> safe here and avoids the warning.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Yishai Hadas <yishaih@mellanox.com>

> ---
>  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> index 84d7857ccc27..c548beaaf910 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> @@ -1605,13 +1605,14 @@ static int eq_res_start_move_to(struct mlx4_dev *dev, int slave, int index,
>  			r->com.from_state = r->com.state;
>  			r->com.to_state = state;
>  			r->com.state = RES_EQ_BUSY;
> -			if (eq)
> -				*eq = r;
>  		}
>  	}
>
>  	spin_unlock_irq(mlx4_tlock(dev));
>
> +	if (!err && eq)
> +		*eq = r;
> +
>  	return err;
>  }
>
>
