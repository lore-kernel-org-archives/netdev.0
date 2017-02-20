From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net] mlx4: reduce OOM risk on arches with large pages
Date: Mon, 20 Feb 2017 10:44:19 +0200
Message-ID: <e0d311ac-50a8-362b-a7bd-c00e520bb49c@gmail.com>
References: <1487442858.1311.104.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35927 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbdBTIoW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 03:44:22 -0500
Received: by mail-wr0-f193.google.com with SMTP id z61so10366197wrc.3
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 00:44:21 -0800 (PST)
In-Reply-To: <1487442858.1311.104.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 18/02/2017 8:34 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Since mlx4 NIC are used on PowerPC with 64K pages, we need to adapt
> MLX4_EN_ALLOC_PREFER_ORDER definition.
>
> Otherwise, a fragment sitting in an out of order TCP queue can hold
> 0.5 Mbytes and it is a serious OOM risk.
>
> Fixes: 51151a16a60f ("mlx4: allow order-0 memory allocations in RX path")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index cec59bc264c9ac197048fd7c98bcd5cf25de0efd..0f6d2f3b7d54f51de359d4ccde21f4585e6b7852 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -102,7 +102,8 @@
>  /* Use the maximum between 16384 and a single page */
>  #define MLX4_EN_ALLOC_SIZE	PAGE_ALIGN(16384)
>
> -#define MLX4_EN_ALLOC_PREFER_ORDER	PAGE_ALLOC_COSTLY_ORDER
> +#define MLX4_EN_ALLOC_PREFER_ORDER min_t(int, get_order(32768),		\
> +					 PAGE_ALLOC_COSTLY_ORDER)
>
>  /* Receive fragment sizes; we use at most 3 fragments (for 9600 byte MTU
>   * and 4K allocations) */
>
>

Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
Thanks Eric!
