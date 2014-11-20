From: Amir Vadai <amirv@mellanox.com>
Subject: Re: mlx4: don't duplicate kvfree()
Date: Thu, 20 Nov 2014 10:38:10 +0200
Message-ID: <CAPcc5Pjb7Nd3OFBdf4nCPTKPYZBU8gJp8WJB9VdPxJtPV+NE_Q@mail.gmail.com>
References: <20141120081538.GJ7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141120081538.GJ7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 20, 2014 at 10:15 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
> index 193a6ad..d6f5496 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mr.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
> @@ -130,10 +130,7 @@ static int mlx4_buddy_init(struct mlx4_buddy *buddy, int max_order)
>
>  err_out_free:
>         for (i = 0; i <= buddy->max_order; ++i)
> -               if (buddy->bits[i] && is_vmalloc_addr(buddy->bits[i]))
> -                       vfree(buddy->bits[i]);
> -               else
> -                       kfree(buddy->bits[i]);
> +               kvfree(buddy->bits[i]);
>
>  err_out:
>         kfree(buddy->bits);
> @@ -147,10 +144,7 @@ static void mlx4_buddy_cleanup(struct mlx4_buddy *buddy)
>         int i;
>
>         for (i = 0; i <= buddy->max_order; ++i)
> -               if (is_vmalloc_addr(buddy->bits[i]))
> -                       vfree(buddy->bits[i]);
> -               else
> -                       kfree(buddy->bits[i]);
> +               kvfree(buddy->bits[i]);
>
>         kfree(buddy->bits);
>         kfree(buddy->num_free);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

Thanks Al

Acked-by: Amir Vadai <amirv@mellanox.com>
