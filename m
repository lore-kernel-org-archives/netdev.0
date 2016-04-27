From: Haggai Abramovsky <haggaia.linux@gmail.com>
Subject: Re: [PATCH net] net/mlx4: Avoid wrong virtual mappings
Date: Wed, 27 Apr 2016 10:06:18 +0300
Message-ID: <CANO=VFGp16PAD15k4JUZrnpGRdARcaJFUe=mLQTJrGdXZh8_8g@mail.gmail.com>
References: <1461591287-11595-1-git-send-email-hagaya@mellanox.com>
	<20160427063254.GM7974@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Haggai Abramovsky <hagaya@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Sinan Kaya <okaya@codeaurora.org>,
	Timur Tabi <timur@codeaurora.org>,
	Eli Cohen <eli@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: leon@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36324 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753024AbcD0HGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 03:06:20 -0400
In-Reply-To: <20160427063254.GM7974@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2016 at 9:32 AM, Leon Romanovsky <leon@kernel.org> wrote:
> On Mon, Apr 25, 2016 at 04:34:47PM +0300, Haggai Abramovsky wrote:
>> -int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
>> -                struct mlx4_buf *buf, gfp_t gfp)
>> +static int mlx4_buf_direct_alloc(struct mlx4_dev *dev, int size,
>> +                              struct mlx4_buf *buf, gfp_t gfp)
>>  {
>> -     dma_addr_t t;
>> +             dma_addr_t t;
>>
>
> You have wrong indentation in whole this function.

Thanks, I will fix this and send v1.

>
>> -     if (size <= max_direct) {
>>               buf->nbufs        = 1;
>>               buf->npages       = 1;
>>               buf->page_shift   = get_order(size) + PAGE_SHIFT;
>> -             buf->direct.buf   = dma_alloc_coherent(&dev->persist->pdev->dev,
>> -                                                    size, &t, gfp);
>> +             buf->direct.buf   =
>> +                     dma_zalloc_coherent(&dev->persist->pdev->dev,
>> +                                         size, &t, gfp);
>>               if (!buf->direct.buf)
>>                       return -ENOMEM;
