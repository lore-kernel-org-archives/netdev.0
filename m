From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sky2: hw checksum failures
Date: Tue, 05 Sep 2006 13:42:38 +1000
Message-ID: <1157427758.22705.65.camel@localhost.localdomain>
References: <1157416603.22705.62.camel@localhost.localdomain>
	 <20060904203442.1c9ed2eb@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:21169 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S965132AbWIEDmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 23:42:53 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060904203442.1c9ed2eb@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-04 at 20:34 -0700, Stephen Hemminger wrote:
> Unneeded byte swap was occurring.
> 
> --- linux-2.6.orig/drivers/net/sky2.c
> +++ linux-2.6/drivers/net/sky2.c
> @@ -2001,7 +2001,7 @@ static int sky2_status_intr(struct sky2_
>  		case OP_RXCHKS:
>  			skb = sky2->rx_ring[sky2->rx_next].skb;
>  			skb->ip_summed = CHECKSUM_HW;
> -			skb->csum = le16_to_cpu(status);
> +			skb->csum = status;
>  			break;
>  
>  		case OP_TXINDEXLE:

I've removed it in my paches (have you seen the other patches I sent for
this driver ?), though I'm pre-swapping status and lenght now before the
switch/case so there might still be an issue there. I'll have a look.

Thanks,
Ben.


