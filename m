From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bgmac: Remove all offloading features, including GRO.
Date: Fri, 15 Sep 2017 17:34:56 -0700
Message-ID: <1505522096.29839.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170916002305.2794-1-rosenp@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rosen Penev <rosenp@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35885 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751143AbdIPAe6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 20:34:58 -0400
Received: by mail-pg0-f68.google.com with SMTP id d8so2069471pgt.3
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 17:34:58 -0700 (PDT)
In-Reply-To: <20170916002305.2794-1-rosenp@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-15 at 17:23 -0700, Rosen Penev wrote:
> On a linksys E1200v1 (actually a crossflashed E1000v2), the offloading features give no measurable benefit to speed or latency. Furthermore, disabling GRO actually improves iperf performance by a whoppimg 3mbps. Results:
> 
> Currently:

> 
> v2: Changed napi_gro_receive to netif_receive_skb. Seems to have an identical result.
> 
> Signed-off-by: Rosen Penev <rosenp@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bgmac.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index 48d672b204a4..1fb0053aeee7 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -483,7 +483,7 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
>  			skb->protocol = eth_type_trans(skb, bgmac->net_dev);
>  			bgmac->net_dev->stats.rx_bytes += len;
>  			bgmac->net_dev->stats.rx_packets++;
> -			napi_gro_receive(&bgmac->napi, skb);
> +			netif_receive_skb(skb);
>  			handled++;
>  		} while (0);
>  

And have you tested 1Gbit link speed ?
( Or 2.5 Gbit link speed )

If you want to disable GRO on your host, fine : you can use ethtool -K
