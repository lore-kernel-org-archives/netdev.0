From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [net-next PATCH] mlx4: add missed recycle opportunity for XDP_TX
 on TX failure
Date: Mon, 19 Sep 2016 13:54:16 +0300
Message-ID: <f4534665-cf8a-eba1-55b6-4344bd6a7d0b@gmail.com>
References: <20160919.013925.1660395475687226712.davem@davemloft.net>
 <20160919073957.32059.59156.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, bblanco@plumgrid.com, rana.shahot@gmail.com,
        "David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33019 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751694AbcISKyU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 06:54:20 -0400
Received: by mail-wm0-f67.google.com with SMTP id w84so7112450wmg.0
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 03:54:19 -0700 (PDT)
In-Reply-To: <20160919073957.32059.59156.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 19/09/2016 10:40 AM, Jesper Dangaard Brouer wrote:
> Correct drop handling for XDP_TX on TX failure, were recently added in
> commit 95357907ae73 ("mlx4: fix XDP_TX is acting like XDP_PASS on TX
> ring full").
>
> The change missed an opportunity for recycling the RX page, instead of
> going through the page allocator, like the regular XDP_DROP action does.
> This patch cease the opportunity, by going through the XDP_DROP case.
>
> Fixes: 95357907ae73 ("mlx4: fix XDP_TX is acting like XDP_PASS on TX ring full")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c |    3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index c80073e4947f..919f0604d04a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -906,11 +906,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>   							length, tx_index,
>   							&doorbell_pending))
>   					goto consumed;
> -				goto next; /* Drop on xmit failure */
> +				goto xdp_drop; /* Drop on xmit failure */
>   			default:
>   				bpf_warn_invalid_xdp_action(act);
>   			case XDP_ABORTED:
>   			case XDP_DROP:
> +			xdp_drop:
>   				if (mlx4_en_rx_recycle(ring, frags))
>   					goto consumed;
>   				goto next;
>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
Thanks.
