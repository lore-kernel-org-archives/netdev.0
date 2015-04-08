From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 03/11] net/mlx5_core: Virtually extend
 work/completion queue buffers by one page
Date: Wed, 8 Apr 2015 20:44:10 +0300
Message-ID: <CAPcc5PgqS18h4zG+KrkXy3o3DSsppJKDkprUU4zCALXzEvimoA@mail.gmail.com>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com>
	<1428504685-8945-4-git-send-email-amirv@mellanox.com>
	<20150408.122520.1452310225826617365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, achiad@mellanox.com,
	Ido Shamay <idos@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:35493 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994AbbDHRoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 13:44:12 -0400
Received: by lbbuc2 with SMTP id uc2so69327106lbb.2
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 10:44:10 -0700 (PDT)
In-Reply-To: <20150408.122520.1452310225826617365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 8, 2015 at 7:25 PM, David Miller <davem@davemloft.net> wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Wed,  8 Apr 2015 17:51:17 +0300
>
>> +     for (i = 0; i < buf->nbufs; i++) {
>> +             buf->page_list[i].buf =
>> +                     dma_zalloc_coherent(&dev->pdev->dev, PAGE_SIZE,
>> +                                         &t, GFP_KERNEL);
>> +             if (!buf->page_list[i].buf)
>> +                     goto err_free;
>> +
>> +             buf->page_list[i].map = t;
>> +     }
>> +
>> +     if (BITS_PER_LONG == 64) {
>> +             struct page **pages;
>> +             int npages = buf->nbufs + (virtual_extension ? 1 : 0);
>> +
>> +             pages = kcalloc(npages, sizeof(*pages), GFP_KERNEL);
>> +             if (!pages)
>> +                     goto err_free;
>> +
>> +             for (i = 0; i < buf->nbufs; i++)
>> +                     pages[i] = virt_to_page(buf->page_list[i].buf);
>> +
>> +             if (virtual_extension)
>> +                     pages[buf->nbufs] = pages[0];
>> +
>> +             buf->direct.buf = vmap(pages, npages, VM_MAP, PAGE_KERNEL);
>
> I'm sorry but I'm going to require that you fix this mis-use of the DMA
> API first.
>
> You absolutely cannot vmap() pages backing coherent DMA memory, the
> memory is mapped in a particular way by dma_*_coherent() and you must
> therefore only use the virtual address provided to you by that
> function to access the memory.

Right - will be fixed in V1

Thanks,
Amir

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
