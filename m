From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 00/13] mlx4: order-0 allocations and page
 recycling
Date: Thu, 9 Mar 2017 15:49:11 +0200
Message-ID: <e762e84a-07eb-428d-cb48-643fd4516cec@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00045.outbound.protection.outlook.com ([40.107.0.45]:47184
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753638AbdCINuI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 08:50:08 -0500
In-Reply-To: <20170308161718.2867-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> As mentioned half a year ago, we better switch mlx4 driver to order-0
> allocations and page recycling.
>
> This reduces vulnerability surface thanks to better skb->truesize
> tracking and provides better performance in most cases.
> (33 Gbit for one TCP flow on my lab hosts)
>
> I will provide for linux-4.13 a patch on top of this series,
> trying to improve data locality as described in
> https://www.spinics.net/lists/netdev/msg422258.html
>
> v2 provides an ethtool -S new counter (rx_alloc_pages) and
> code factorization, plus Tariq fix.
>
> v3 includes various fixes based on Tariq tests and feedback
> from Saeed and Tariq.
>
> v4 rebased on net-next for inclusion in linux-4.12, as requested
> by Tariq.
>
Hi Eric,

I was preparing this series for submission as well.
You got it done first :)

Thanks for re-submitting.
I am Acking the patches now.

Regards,
Tariq

> Worth noting this patch series deletes ~250 lines of code ;)
>
> Eric Dumazet (13):
>   mlx4: dma_dir is a mlx4_en_priv attribute
>   mlx4: remove order field from mlx4_en_frag_info
>   mlx4: get rid of frag_prefix_size
>   mlx4: rx_headroom is a per port attribute
>   mlx4: reduce rx ring page_cache size
>   mlx4: removal of frag_sizes[]
>   mlx4: use order-0 pages for RX
>   mlx4: add page recycling in receive path
>   mlx4: add rx_alloc_pages counter in ethtool -S
>   mlx4: do not access rx_desc from mlx4_en_process_rx_cq()
>   mlx4: factorize page_address() calls
>   mlx4: make validate_loopback() more generic
>   mlx4: remove duplicate code in mlx4_en_process_rx_cq()
>
>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c  |   2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_port.c     |   2 +
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c       | 607 +++++++----------------
>  drivers/net/ethernet/mellanox/mlx4/en_selftest.c |   6 -
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c       |   4 +-
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h     |  30 +-
>  drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h  |   2 +-
>  7 files changed, 201 insertions(+), 452 deletions(-)
>
