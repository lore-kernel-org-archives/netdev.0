From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH] sunvnet: fix a memory leak in vnet_handle_offloads
Date: Fri, 19 Dec 2014 12:39:43 -0500
Message-ID: <549462DF.7050709@oracle.com>
References: <1418966375-23188-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36723 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511AbaLSRjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 12:39:51 -0500
In-Reply-To: <1418966375-23188-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Acked-by: David L Stevens <david.stevens@oracle.com>

On 12/19/2014 12:19 AM, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> when skb_gso_segment returns error, the original skb should be freed
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  drivers/net/ethernet/sun/sunvnet.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
> index 45c408e..d2835bf 100644
> --- a/drivers/net/ethernet/sun/sunvnet.c
> +++ b/drivers/net/ethernet/sun/sunvnet.c
> @@ -1201,6 +1201,7 @@ static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb)
>  		segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO);
>  	if (IS_ERR(segs)) {
>  		dev->stats.tx_dropped++;
> +		dev_kfree_skb_any(skb);
>  		return NETDEV_TX_OK;
>  	}
>  
> 
