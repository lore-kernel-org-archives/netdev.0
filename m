From: Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Wed, 20 Apr 2016 09:38:43 -0400
Message-ID: <57178663.4050503@codeaurora.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160419182212.GA8441@infradead.org> <571785A5.5040306@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eranlinuxmellanox-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <571785A5.5040306-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Apologies,

Replied to an older post by mistake. I was trying to reply to Eran.

>Hi Sinan,
>
>We are working in Mellanox for a solution which
>removes the vmap call and allocate contiguous memory (using dma_alloc_coherent).
>
>Thanks,
>Eran
>
>
>On 4/20/2016 9:35 AM, Sinan Kaya wrote:
> On 4/19/2016 2:22 PM, Christoph Hellwig wrote:
>> What I think we need is something like the patch below.  In the long
>> ru nwe should also kill the mlx4_buf structure which now is pretty
>> pointless.
>>
> 

It is been 1.5 years since I reported the problem. We came up with three
different solutions this week. I'd like to see a version of the solution
to get merged until Mellanox comes up with a better solution with another
patch. My proposal is to use this one.

> 
> -- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
> @@ -588,7 +588,7 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
>  {
>         dma_addr_t t;
> 
> -       if (size <= max_direct) {
> +       if ((size <= max_direct) || (BITS_PER_LONG == 64)){
>                 buf->nbufs        = 1;
>                 buf->npages       = 1;
>                 buf->page_shift   = get_order(size) + PAGE_SHIFT;
> 
> Of course, this is assuming that you are not ready to submit your patch yet. If you 
> are, feel free to post.
> 


-- 
Sinan Kaya
Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
