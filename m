From: Ozgur Karatas <okaratas@member.fsf.org>
Subject: Re: [PATCH 1/1] Fixed to BUG_ON to WARN_ON def
Date: Mon, 12 Dec 2016 15:04:28 +0200
Message-ID: <2090831481547868@web27h.yandex.ru>
References: <811031481540339@web1j.yandex.ru> <20161212123937.GA6503@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "yishaih@mellanox.com" <yishaih@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161212123937.GA6503@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Romanovsky;

I'm trying to learn english and I apologize for my mistake words and phrases. So, I think the code when call to "sg_set_buf" and next time set memory and buffer. For example, isn't to call "WARN_ON" function, get a error to implicit declaration, right?

Because, you will use to "BUG_ON" get a error implicit declaration of functions.

        sg_set_buf(mem, buf, PAGE_SIZE << order);
        WARN_ON(mem->offset);

Thanks for information and learn to me.

Regards,

Ozgur Karatas

12.12.2016, 14:39, "Leon Romanovsky" <leon@kernel.org>:
> On Mon, Dec 12, 2016 at 12:58:59PM +0200, Ozgur Karatas wrote:
>>  Hello all,
>>  I think should be use to "WARN_ON" and checkpatch script give to error, I fixed and I think should don't use "BUG_ON".
>>  Regards,
>>
>>  Signed-off-by: Ozgur Karatas <okaratas@member.fsf.org>
>
> NAK, Leon Romanovsky <leonro@mellanox.com>
>
> If we put aside commit message issue, which was pointed to you by Stefan, your
> proposed change is incorrect. By chnaging BUG_ONs to be WARN_ONs, you
> will left the driver in improper state.
>
> Thanks
>
>>  ---
>>  drivers/net/ethernet/mellanox/mlx4/icm.c | 4 ++--
>>
>>  diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
>>  index 2a9dd46..3fde535 100644
>>  --- a/drivers/net/ethernet/mellanox/mlx4/icm.c
>>  +++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
>>  @@ -119,7 +119,7 @@ static int mlx4_alloc_icm_coherent(struct device *dev, struct scatterlist *mem,
>>                   return -ENOMEM;
>>
>>           sg_set_buf(mem, buf, PAGE_SIZE << order);
>>  - BUG_ON(mem->offset);
>>  + WARN_ON(mem->offset);
>>           sg_dma_len(mem) = PAGE_SIZE << order;
>>           return 0;
>>   }
>>  @@ -133,7 +133,7 @@ struct mlx4_icm *mlx4_alloc_icm(struct mlx4_dev *dev, int npages,
>>           int ret;
>>
>>           /* We use sg_set_buf for coherent allocs, which assumes low memory */
>>  - BUG_ON(coherent && (gfp_mask & __GFP_HIGHMEM));
>>  + WARN_ON(coherent && (gfp_mask & __GFP_HIGHMEM));
>>
>>           icm = kmalloc_node(sizeof(*icm),
>>                              gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN),
>>  --
>>  2.1.4
