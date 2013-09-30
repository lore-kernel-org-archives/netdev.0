From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: convert to GRO API
Date: Mon, 30 Sep 2013 14:24:32 +0100
Message-ID: <1380547472.1302.45.camel@kazak.uk.xensource.com>
References: <1380545194-13419-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	<konrad.wilk@oracle.com>, Anirban Chakraborty <abchak@juniper.net>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:5517 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754211Ab3I3NYf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Sep 2013 09:24:35 -0400
In-Reply-To: <1380545194-13419-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-30 at 13:46 +0100, Wei Liu wrote:
> Anirban was seeing netfront received MTU size packets, which downgraded
> throughput. The following patch makes netfront use GRO API which
> improves throughput for that case.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Cc: Anirban Chakraborty <abchak@juniper.net>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

> Acked-by: Konrad Wilk <konrad.wilk@oracle.com>
> ---
>  drivers/net/xen-netfront.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 36808bf..dd1011e 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -952,7 +952,7 @@ static int handle_incoming_queue(struct net_device *dev,
>  		u64_stats_update_end(&stats->syncp);
>  
>  		/* Pass it up. */
> -		netif_receive_skb(skb);
> +		napi_gro_receive(&np->napi, skb);
>  	}
>  
>  	return packets_dropped;
> @@ -1051,6 +1051,8 @@ err:
>  	if (work_done < budget) {
>  		int more_to_do = 0;
>  
> +		napi_gro_flush(napi, false);
> +
>  		local_irq_save(flags);
>  
>  		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
