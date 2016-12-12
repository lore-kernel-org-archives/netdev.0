From: Ozgur Karatas <okaratas@member.fsf.org>
Subject: Re: [PATCH 1/1] Fixed to BUG_ON to WARN_ON def
Date: Mon, 12 Dec 2016 22:24:11 +0200
Message-ID: <1085691481574251@web1o.yandex.ru>
References: <811031481540339@web1j.yandex.ru>
         <20161212123937.GA6503@mtr-leonro.local>
         <2090831481547868@web27h.yandex.ru> <20161212181838.GB8204@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "yishaih@mellanox.com" <yishaih@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161212181838.GB8204@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



12.12.2016, 20:18, "Leon Romanovsky" <leon@kernel.org>:
> On Mon, Dec 12, 2016 at 03:04:28PM +0200, Ozgur Karatas wrote:
>>  Dear Romanovsky;
>
> Please avoid top-posting in your replies.
> Thanks

Dear Leon; 
thanks for the information., I will pay attention.

>>  I'm trying to learn english and I apologize for my mistake words and phrases. So, I think the code when call to "sg_set_buf" and next time set memory and buffer. For example, isn't to call "WARN_ON" function, get a error to implicit declaration, right?
>>
>>  Because, you will use to "BUG_ON" get a error implicit declaration of functions.
>
> I'm not sure that I followed you. mem->offset is set by sg_set_buf from
> buf variable returned by dma_alloc_coherent(). HW needs to get very
> precise size of this buf, in multiple of pages and aligned to pages
> boundaries.

I have studied the following your coding and I guess that's the right patchs.
You are the very expert in this matter, thank you for the correct for me.

I learn to your style as an example.

Regards,

Ozgur Karatas

> See the patch inline which removes this BUG_ON in proper and safe way.
>
> From 7babe807affa2b27d51d3610afb75b693929ea1a Mon Sep 17 00:00:00 2001
> From: Leon Romanovsky <leonro@mellanox.com>
> Date: Mon, 12 Dec 2016 20:02:45 +0200
> Subject: [PATCH] net/mlx4: Remove BUG_ON from ICM allocation routine
>
> This patch removes BUG_ON() macro from mlx4_alloc_icm_coherent()
> by checking DMA address aligment in advance and performing proper
> folding in case of error.
>
> Fixes: 5b0bf5e25efe ("mlx4_core: Support ICM tables in coherent memory")
> Reported-by: Ozgur Karatas <okaratas@member.fsf.org>
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/icm.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
> index 2a9dd46..e1f9e7c 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/icm.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
> @@ -118,8 +118,13 @@ static int mlx4_alloc_icm_coherent(struct device *dev, struct scatterlist *mem,
>          if (!buf)
>                  return -ENOMEM;
>
> + if (offset_in_page(buf)) {
> + dma_free_coherent(dev, PAGE_SIZE << order,
> + buf, sg_dma_address(mem));
> + return -ENOMEM;
> + }
> +
>          sg_set_buf(mem, buf, PAGE_SIZE << order);
> - BUG_ON(mem->offset);
>          sg_dma_len(mem) = PAGE_SIZE << order;
>          return 0;
>  }
> --
> 2.10.2
