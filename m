From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] 3C509: rx_bytes should not be increased when alloc_skb
 failed
Date: Thu, 22 May 2008 14:02:53 -0400
Message-ID: <4835B54D.6050600@pobox.com>
References: <48329650.60809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: becker@scyld.com, "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36657 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755998AbYEVSC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 14:02:59 -0400
In-Reply-To: <48329650.60809@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> If alloc_skb failed, the recieved packet will be dropped. Do not increase
> rx_bytes for dropped packet.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  drivers/net/3c509.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
> index e6c545f..fe6d841 100644
> --- a/drivers/net/3c509.c
> +++ b/drivers/net/3c509.c
> @@ -1063,7 +1063,6 @@ el3_rx(struct net_device *dev)
>  			struct sk_buff *skb;
>  
>  			skb = dev_alloc_skb(pkt_len+5);
> -			dev->stats.rx_bytes += pkt_len;
>  			if (el3_debug > 4)
>  				printk("Receiving packet size %d status %4.4x.\n",
>  					   pkt_len, rx_status);
> @@ -1078,6 +1077,7 @@ el3_rx(struct net_device *dev)
>  				skb->protocol = eth_type_trans(skb,dev);
>  				netif_rx(skb);
>  				dev->last_rx = jiffies;
> +				dev->stats.rx_bytes += pkt_len;
>  				dev->stats.rx_packets++;
>  				continue;

applied


