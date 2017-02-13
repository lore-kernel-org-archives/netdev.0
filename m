From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Mon, 13 Feb 2017 13:09:58 -0800
Message-ID: <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:38767 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752215AbdBMVKK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 16:10:10 -0500
Received: by mail-it0-f47.google.com with SMTP id c7so3581136itd.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 13:10:04 -0800 (PST)
In-Reply-To: <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 12:51 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Mon, Feb 13, 2017 at 11:58 AM, Eric Dumazet <edumazet@google.com> wrote:

>> +                              PAGE_SIZE, priv->dma_dir);
>>                 page = page_alloc->page;
>>                 /* Revert changes done by mlx4_alloc_pages */
>> -               page_ref_sub(page, page_alloc->page_size /
>> +               page_ref_sub(page, PAGE_SIZE /
>>                                    priv->frag_info[i].frag_stride - 1);
>>                 put_page(page);
>>                 page_alloc->page = NULL;
>
> You can probably simplify this by using __page_frag_cache_drain since
> that way you can just doe the sub and test for the whole set instead
> of doing N - 1 and 1.

Well, we remove this anyway in following patch ;)
