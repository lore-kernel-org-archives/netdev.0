From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] mlx4: fix XDP_TX is acting like XDP_PASS on TX ring
 full
Date: Fri, 16 Sep 2016 13:00:50 -0700
Message-ID: <1474056050.22679.75.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160916194645.13201.70408.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, tom@herbertland.com,
        bblanco@plumgrid.com, rana.shahot@gmail.com,
        "David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34932 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935021AbcIPUAw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 16:00:52 -0400
Received: by mail-pa0-f66.google.com with SMTP id pp5so3822323pac.2
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 13:00:52 -0700 (PDT)
In-Reply-To: <20160916194645.13201.70408.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-16 at 21:47 +0200, Jesper Dangaard Brouer wrote:
> The XDP_TX action can fail transmitting the frame in case the TX ring
> is full or port is down.  In case of TX failure it should drop the
> frame, and not as now call 'break' which is the same as XDP_PASS.
> 
> Fixes: 9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> ---
> Note, this fix have nothing to do with the page-refcnt bug I just reported.

Yeah, the e1000 driver proposal patch had the same issue.

> 
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 2040dad8611d..d414c67dfd12 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -906,6 +906,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  							length, tx_index,
>  							&doorbell_pending))
>  					goto consumed;
> +				goto next;
>  				break;

Why keeping this break; then ? ;)

>  			default:
>  				bpf_warn_invalid_xdp_action(act);
> 
