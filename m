From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] uapi: fix rdma/mlx5-abi.h userspace compilation errors
Date: Fri, 24 Mar 2017 22:02:25 -0400
Message-ID: <1490407345.2404.36.camel@redhat.com>
References: <20170224002813.GB31010@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Dmitry V. Levin" <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170224002813.GB31010-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-02-24 at 03:28 +0300, Dmitry V. Levin wrote:
> Consistently use types from linux/types.h to fix the following
> rdma/mlx5-abi.h userspace compilation errors:
> 
> /usr/include/rdma/mlx5-abi.h:69:25: error: 'u64' undeclared here (not
> in a function)
>   MLX5_LIB_CAP_4K_UAR = (u64)1 << 0,
> /usr/include/rdma/mlx5-abi.h:69:29: error: expected ',' or '}' before
> numeric constant
>   MLX5_LIB_CAP_4K_UAR = (u64)1 << 0,
> 
> Include <linux/if_ether.h> to fix the following rdma/mlx5-abi.h
> userspace compilation error:
> 
> /usr/include/rdma/mlx5-abi.h:286:12: error: 'ETH_ALEN' undeclared
> here (not in a function)
>   __u8 dmac[ETH_ALEN];
> 
> Signed-off-by: Dmitry V. Levin <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>

Thanks, applied.

> ---
>  include/uapi/rdma/mlx5-abi.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/rdma/mlx5-abi.h b/include/uapi/rdma/mlx5-
> abi.h
> index da7cd62..0b3d308 100644
> --- a/include/uapi/rdma/mlx5-abi.h
> +++ b/include/uapi/rdma/mlx5-abi.h
> @@ -34,6 +34,7 @@
>  #define MLX5_ABI_USER_H
>  
>  #include <linux/types.h>
> +#include <linux/if_ether.h>	/* For ETH_ALEN. */
>  
>  enum {
>  	MLX5_QP_FLAG_SIGNATURE		= 1 << 0,
> @@ -66,7 +67,7 @@ struct mlx5_ib_alloc_ucontext_req {
>  };
>  
>  enum mlx5_lib_caps {
> -	MLX5_LIB_CAP_4K_UAR	= (u64)1 << 0,
> +	MLX5_LIB_CAP_4K_UAR	= (__u64)1 << 0,
>  };
>  
>  struct mlx5_ib_alloc_ucontext_req_v2 {
-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
