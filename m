From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 07/13] mlx4: use order-0 pages for RX
Date: Thu, 9 Mar 2017 15:55:48 +0200
Message-ID: <fb20847b-b57e-1d09-2ee1-47d41633c152@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-8-edumazet@google.com>
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
Received: from mail-db5eur01on0074.outbound.protection.outlook.com ([104.47.2.74]:45712
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750770AbdCINz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 08:55:56 -0500
In-Reply-To: <20170308161718.2867-8-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> Use of order-3 pages is problematic in some cases.
>
> This patch might add three kinds of regression :
>
> 1) a CPU performance regression, but we will add later page
> recycling and performance should be back.
>
> 2) TCP receiver could grow its receive window slightly slower,
>    because skb->len/skb->truesize ratio will decrease.
>    This is mostly ok, we prefer being conservative to not risk OOM,
>    and eventually tune TCP better in the future.
>    This is consistent with other drivers using 2048 per ethernet frame.
>
> 3) Because we allocate one page per RX slot, we consume more
>    memory for the ring buffers. XDP already had this constraint anyway.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 72 +++++++++++++---------------
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  5 --
>  2 files changed, 33 insertions(+), 44 deletions(-)
>
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
