From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Mon, 13 Feb 2017 15:16:35 -0800
Message-ID: <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com> <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
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
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35575 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750975AbdBMXQh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 18:16:37 -0500
Received: by mail-it0-f65.google.com with SMTP id 203so1141995ith.2
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 15:16:36 -0800 (PST)
In-Reply-To: <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 1:09 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Mon, Feb 13, 2017 at 12:51 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Mon, Feb 13, 2017 at 11:58 AM, Eric Dumazet <edumazet@google.com> wrote:
>
>>> +                              PAGE_SIZE, priv->dma_dir);
>>>                 page = page_alloc->page;
>>>                 /* Revert changes done by mlx4_alloc_pages */
>>> -               page_ref_sub(page, page_alloc->page_size /
>>> +               page_ref_sub(page, PAGE_SIZE /
>>>                                    priv->frag_info[i].frag_stride - 1);
>>>                 put_page(page);
>>>                 page_alloc->page = NULL;
>>
>> You can probably simplify this by using __page_frag_cache_drain since
>> that way you can just doe the sub and test for the whole set instead
>> of doing N - 1 and 1.
>
> Well, we remove this anyway in following patch ;)

Any plans to add the bulk page count updates back at some point?  I
just got around to adding it for igb in commit bd4171a5d4c2 ("igb:
update code to better handle incrementing page count").  I should have
patches for ixgbe, i40e, and i40evf here pretty soon.  That was one of
the reasons why I implemented __page_frag_cache_drain in the first
place.  As I'm sure Jesper will probably point out the atomic op for
get_page/page_ref_inc can be pretty expensive if I recall correctly.

- Alex
