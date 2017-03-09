From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 13/13] mlx4: remove duplicate code in
 mlx4_en_process_rx_cq()
Date: Thu, 9 Mar 2017 15:58:00 +0200
Message-ID: <6bc15b8b-d2cb-de53-3bb3-d06962d844bd@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-14-edumazet@google.com>
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
Received: from mail-db5eur01on0047.outbound.protection.outlook.com ([104.47.2.47]:51648
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754137AbdCIN65 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 08:58:57 -0500
In-Reply-To: <20170308161718.2867-14-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> We should keep one way to build skbs, regardless of GRO being on or off.
>
> Note that I made sure to defer as much as possible the point we need to
> pull data from the frame, so that future prefetch() we might add
> are more effective.
>
> These skb attributes derive from the CQE or ring :
>  ip_summed, csum
>  hash
>  vlan offload
>  hwtstamps
>  queue_mapping
>
> As a bonus, this patch removes mlx4 dependency on eth_get_headlen()
> which is very often broken enough to give us headaches.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 209 ++++++-----------------------
>  1 file changed, 41 insertions(+), 168 deletions(-)
>
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
