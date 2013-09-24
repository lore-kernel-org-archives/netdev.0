From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: convert to GRO API
 and advertise this feature
Date: Tue, 24 Sep 2013 12:30:36 -0400
Message-ID: <20130924163036.GB13979@phenom.dumpdata.com>
References: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Anirban Chakraborty <abchak@juniper.net>,
	Ian Campbell <ian.campbell@citrix.com>, xen-devel@lists.xen.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47843 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856Ab3IXQat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:30:49 -0400
Content-Disposition: inline
In-Reply-To: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 21, 2013 at 05:05:43PM +0100, Wei Liu wrote:
> Anirban was seeing netfront received MTU size packets, which downgraded
> throughput. The following patch makes netfront use GRO API which
> improves throughput for that case.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Signed-off-by: Anirban Chakraborty <abchak@juniper.net>
> Cc: Ian Campbell <ian.campbell@citrix.com>

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

> ---
>  drivers/net/xen-netfront.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 36808bf..5664165 100644
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
> @@ -1371,7 +1373,8 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
>  	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
>  	netdev->features        = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
>  				  NETIF_F_GSO_ROBUST;
> -	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
> +	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO |
> +				  NETIF_F_GRO;
>  
>  	/*
>           * Assume that all hw features are available for now. This set
> -- 
> 1.7.10.4
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
