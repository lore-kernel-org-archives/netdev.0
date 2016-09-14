From: Sebastian Ott <sebott-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] net/mlx4_en: fix off by one in error handling
Date: Wed, 14 Sep 2016 15:53:57 +0200 (CEST)
Message-ID: <alpine.LFD.2.20.1609141548390.11022@schleppi>
References: <alpine.LFD.2.20.1609141305360.1727@schleppi> <df5834ee-00c2-3f18-ae83-8bb06b6c675b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tariq Toukan <ttoukan.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <df5834ee-00c2-3f18-ae83-8bb06b6c675b-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Tariq,

On Wed, 14 Sep 2016, Tariq Toukan wrote:
> On 14/09/2016 2:09 PM, Sebastian Ott wrote:
> > If an error occurs in mlx4_init_eq_table the index used in the
> > err_out_unmap label is one too big which results in a panic in
> > mlx4_free_eq. This patch fixes the index in the error path.
> You are right, but your change below does not cover all cases.
> The full solution looks like this:
> 
> @@ -1260,7 +1260,7 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
>                                              eq);
>                 }
>                 if (err)
> -                       goto err_out_unmap;
> +                       goto err_out_unmap_excluded;

In this case a call to mlx4_create_eq failed. Do you really have to call
mlx4_free_eq for this index again? As far as I understood this code
mlx4_create_eq cleans up when it fails and thus there is no need for an
additional mlx4_free_eq call.

Regards,
Sebastian

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
