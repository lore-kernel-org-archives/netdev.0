From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the akpm tree
Date: Mon, 3 Jul 2017 18:14:55 +1000
Message-ID: <20170703181455.2d5a7600@canb.auug.org.au>
References: <20170630163241.0ac5c0e5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Daniel Micay <danielmicay@gmail.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Andrew Morton <akpm@linux-foundation.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170630163241.0ac5c0e5@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

On Fri, 30 Jun 2017 16:32:41 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> After merging the akpm tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
> 
> In file included from include/linux/bitmap.h:8:0,
>                  from include/linux/cpumask.h:11,
>                  from include/linux/mm_types_task.h:13,
>                  from include/linux/mm_types.h:4,
>                  from include/linux/kmemcheck.h:4,
>                  from include/linux/skbuff.h:18,
>                  from include/linux/if_ether.h:23,
>                  from include/linux/etherdevice.h:25,
>                  from drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c:33:
> In function 'memcpy',
>     inlined from 'mlx5_fpga_query_qp' at drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c:194:2:
> include/linux/string.h:315:4: error: call to '__read_overflow2' declared with attribute error: detected read beyond size of object passed as 2nd parameter
>     __read_overflow2();
>     ^
> 
> Caused by commit
> 
>   c151149cc4db ("include/linux/string.h: add the option of fortified string.h functions")
> 
> interacting with commit
> 
>   6062118d5cd2 ("net/mlx5: FPGA, Add FW commands for FPGA QPs")
> 
> from the net-next tree.
> 
> I took a guess and tried the following patch which seemed to work.
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 30 Jun 2017 16:24:35 +1000
> Subject: [PATCH] net/mlx5: fix memcpy limit?
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c
> index 5cb855fd618f..e37453d838db 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c
> @@ -191,7 +191,7 @@ int mlx5_fpga_query_qp(struct mlx5_core_dev *dev,
>  	if (ret)
>  		return ret;
>  
> -	memcpy(fpga_qpc, MLX5_ADDR_OF(fpga_query_qp_out, in, fpga_qpc),
> +	memcpy(fpga_qpc, MLX5_ADDR_OF(fpga_query_qp_out, out, fpga_qpc),
>  	       MLX5_FLD_SZ_BYTES(fpga_query_qp_out, fpga_qpc));
>  	return ret;
>  }
> -- 
> 2.11.0

Again today ... so is the fix correct?  if so, Dave should apply it, if
not someone should supply a correct fix for Dave.

-- 
Cheers,
Stephen Rothwell
