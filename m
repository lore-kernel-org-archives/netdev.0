From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next-2.6] bnx2x: small fix in stats handling
Date: Wed, 25 Aug 2010 06:55:49 +0300
Message-ID: <1282708549.18068.0.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1282628648.2378.1492.camel@edumazet-laptop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1409 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932473Ab0HYD4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 23:56:03 -0400
In-Reply-To: <1282628648.2378.1492.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-23 at 22:44 -0700, Eric Dumazet wrote:
> Use a private variable to fold rx_dropped value, instead of shared
> destination buffer, as it might break SNMP applications.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Eilon Greenstein <eilong@broadcom.com>
> CC: Dmitry Kravkov <dmitry@broadcom.com>

Thanks Eric!

Acked-By: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/bnx2x/bnx2x_stats.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
> index c747244..efa1403 100644
> --- a/drivers/net/bnx2x/bnx2x_stats.c
> +++ b/drivers/net/bnx2x/bnx2x_stats.c
> @@ -969,6 +969,7 @@ static void bnx2x_net_stats_update(struct bnx2x *bp)
>  {
>  	struct bnx2x_eth_stats *estats = &bp->eth_stats;
>  	struct net_device_stats *nstats = &bp->dev->stats;
> +	unsigned long tmp;
>  	int i;
>  
>  	nstats->rx_packets =
> @@ -985,10 +986,10 @@ static void bnx2x_net_stats_update(struct bnx2x *bp)
>  
>  	nstats->tx_bytes = bnx2x_hilo(&estats->total_bytes_transmitted_hi);
>  
> -	nstats->rx_dropped = estats->mac_discard;
> +	tmp = estats->mac_discard;
>  	for_each_queue(bp, i)
> -		nstats->rx_dropped +=
> -			le32_to_cpu(bp->fp[i].old_tclient.checksum_discard);
> +		tmp += le32_to_cpu(bp->fp[i].old_tclient.checksum_discard);
> +	nstats->rx_dropped = tmp;
>  
>  	nstats->tx_dropped = 0;
>  
> 
> 
> 



