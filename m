From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 0/9] mlx4: order-0 allocations and page recycling
Date: Tue, 7 Feb 2017 17:50:00 +0200
Message-ID: <3b996d14-0471-1fa3-e686-15cf48db4c19@gmail.com>
References: <20170207030240.31357-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:35047 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754199AbdBGPuE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 10:50:04 -0500
Received: by mail-wj0-f195.google.com with SMTP id i7so4717425wjf.2
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 07:50:03 -0800 (PST)
In-Reply-To: <20170207030240.31357-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks for your series.

On 07/02/2017 5:02 AM, Eric Dumazet wrote:
> As mentioned half a year ago, we better switch mlx4 driver to order-0
> allocations and page recycling.
>
> This reduces vulnerability surface thanks to better skb->truesize tracking
> and provides better performance in most cases.
The series makes significant change in the RX data-path, that requires 
deeper checks, in addition to code review.
We applied your series and started running both our functional and 
performance regression.
We will have results by tomorrow morning, and will analyze them during 
the day. I'll update about that.
>
> Worth noting this patch series deletes more than 100 lines of code ;)
>
> Eric Dumazet (9):
>    mlx4: use __skb_fill_page_desc()
>    mlx4: dma_dir is a mlx4_en_priv attribute
>    mlx4: remove order field from mlx4_en_frag_info
>    mlx4: get rid of frag_prefix_size
>    mlx4: rx_headroom is a per port attribute
>    mlx4: reduce rx ring page_cache size
>    mlx4: removal of frag_sizes[]
>    mlx4: use order-0 pages for RX
>    mlx4: add page recycling in receive path
>
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 350 +++++++++------------------
>   drivers/net/ethernet/mellanox/mlx4/en_tx.c   |   4 +-
>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  28 +--
>   3 files changed, 129 insertions(+), 253 deletions(-)
>
Thanks,
Tariq
