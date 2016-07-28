From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] net/mlx5_core/pagealloc: Remove deprecated create_singlethread_workqueue
Date: Fri, 29 Jul 2016 01:44:41 +0300
Message-ID: <CALzJLG-ZTnD29hyGpt2jFN=UJ4-CVBwx-f9n8XSnBaZpNR+aeA@mail.gmail.com>
References: <20160728081949.GA5561@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160728081949.GA5561@Karyakshetra>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 28, 2016 at 11:19 AM, Bhaktipriya Shridhar
<bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> A dedicated workqueue has been used since the work items are being used
> on a memory reclaim path. WQ_MEM_RECLAIM has been set to guarantee forward
> progress under memory pressure.
>
> The workqueue has a single work item. Hence, alloc_workqueue() is used
> instead of alloc_ordered_workqueue() since ordering is unnecessary when
> there's only one work item.

let's keep the current behavior (ST WQ) because at the moment we don't
know how this WQ will evolve in the future, the original author had
something in mind .. let's keep.

>
> Explicit concurrency limit is unnecessary here since there are only a
> fixed number of work items.
>
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> index 9eeee05..7c85262 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> @@ -552,7 +552,8 @@ void mlx5_pagealloc_cleanup(struct mlx5_core_dev *dev)
>
>  int mlx5_pagealloc_start(struct mlx5_core_dev *dev)
>  {
> -       dev->priv.pg_wq = create_singlethread_workqueue("mlx5_page_allocator");
> +       dev->priv.pg_wq = alloc_workqueue("mlx5_page_allocator",
> +                                         WQ_MEM_RECLAIM, 0);
>         if (!dev->priv.pg_wq)
>                 return -ENOMEM;
>
> --
> 2.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
