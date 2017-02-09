From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 4/9] mlx4: get rid of frag_prefix_size
Date: Thu, 9 Feb 2017 06:06:33 -0800
Message-ID: <CANn89iKOxpNg5Y0ntSdT6rvHegPgPGK7iF9Yos7aSkK8FNYPaQ@mail.gmail.com>
References: <20170207030240.31357-1-edumazet@google.com> <20170207030240.31357-5-edumazet@google.com>
 <008c9016-6781-374a-ab78-79c3a9af0f06@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35304 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752702AbdBIOhZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:37:25 -0500
Received: by mail-io0-f175.google.com with SMTP id j18so18048216ioe.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:36:08 -0800 (PST)
In-Reply-To: <008c9016-6781-374a-ab78-79c3a9af0f06@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 4:28 AM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:
>
>
> On 07/02/2017 5:02 AM, Eric Dumazet wrote:
>>

>> +       for (nr = 0;;) {
>> +               frag_size = min_t(int, length, frag_info->frag_size);
>> +
>>                 if (unlikely(!frags[nr].page))
>>                         goto fail;
>>   @@ -603,15 +602,16 @@ static int mlx4_en_complete_rx_desc(struct
>> mlx4_en_priv *priv,
>>                 __skb_fill_page_desc(skb, nr, frags[nr].page,
>>                                      frags[nr].page_offset,
>> -                                    frag_info->frag_size);
>> +                                    frag_size);
>
> Same for dma_sync_single (two lines above).

Oh right, although I was not sure it this really matter on a part of a page.
