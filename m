From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Fri, 19 Apr 2013 08:29:58 -0700
Message-ID: <1366385398.16391.19.camel@edumazet-glaptop>
References: <Jim Baxter <jim_baxter@mentor.com>
	 <1366384215-21441-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:45359 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030676Ab3DSPaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 11:30:01 -0400
Received: by mail-da0-f48.google.com with SMTP id f10so381188dak.7
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 08:30:00 -0700 (PDT)
In-Reply-To: <1366384215-21441-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 16:10 +0100, Jim Baxter wrote:
>  
> +static int
> +fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	/* Only run for packets requiring a checksum. */
> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
> +		return 0;
> +
> +	if (unlikely(skb_cow_head(skb, 0)))
> +		return -1;
> +
> +	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
> +
> +	return 0;
> +}


 
> +	/* HW acceleration for ICMP TCP UDP checksum */
> +	if (fec_enet_clear_csum(skb, ndev))
> +		return NETDEV_TX_BUSY;

No : You must drop the packet and return NETDEV_TX_OK
