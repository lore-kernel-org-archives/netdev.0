From: Souptick Joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3] ethernet :mellanox :mlx4: Replace pci_pool_alloc by pci_pool_zalloc
Date: Wed, 30 Nov 2016 01:59:16 +0530
Message-ID: <CAFqt6zY4ct_AS90P-Lm4UBdcrZETwh28xEYG1u-OCvhnNpkNGA@mail.gmail.com>
References: <20161129194611.GA4088@jordon-HP-15-Notebook-PC> <20161129195811.GA4221@yuval-lap.uk.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rameshwar Sahu <sahu.rameshwar73-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161129195811.GA4221-Hxa29pjIrETlQW142y8m19+IiqhCXseY@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Yuval,

> v3:
>   - Fixed alignment issues

You mean remove extra empty line?

Yes, I removed the empty line and also I had fixed one alignment issue
which was mentioned
by Sergei in v2 patch.

On Wed, Nov 30, 2016 at 1:28 AM, Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, Nov 30, 2016 at 01:16:12AM +0530, Souptick Joarder wrote:
>> In mlx4_alloc_cmd_mailbox(), pci_pool_alloc() followed by memset will be
>> replaced by pci_pool_zalloc()
>>
>> Signed-off-by: Souptick joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>> v3:
>>   - Fixed alignment issues
>
> You mean remove extra empty line?
>
> Reviewed-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>
>>
>> v2:
>>   - Address comment from sergei
>>     Alignment was not proper
>>
>>  drivers/net/ethernet/mellanox/mlx4/cmd.c | 6 ++----
>>  1 file changed, 2 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> index e36bebc..a49072b4 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> @@ -2679,15 +2679,13 @@ struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev)
>>       if (!mailbox)
>>               return ERR_PTR(-ENOMEM);
>>
>> -     mailbox->buf = pci_pool_alloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
>> -                                   &mailbox->dma);
>> +     mailbox->buf = pci_pool_zalloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
>> +                                    &mailbox->dma);
>>       if (!mailbox->buf) {
>>               kfree(mailbox);
>>               return ERR_PTR(-ENOMEM);
>>       }
>>
>> -     memset(mailbox->buf, 0, MLX4_MAILBOX_SIZE);
>> -
>>       return mailbox;
>>  }
>>  EXPORT_SYMBOL_GPL(mlx4_alloc_cmd_mailbox);
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
