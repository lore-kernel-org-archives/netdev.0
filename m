From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH net-2.6 5/7] atm: [br2864] fix routed vcmux support
Date: Thu, 02 Oct 2008 06:09:11 +0200
Message-ID: <1222920551.23279.103.camel@sakura.staff.proxad.net>
References: <200806161727.m5GHRfNh003377@cmf.nrl.navy.mil>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sakura.staff.proxad.net ([213.228.1.107]:60011 "EHLO
	sakura.staff.proxad.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbYJBERd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 00:17:33 -0400
In-Reply-To: <200806161727.m5GHRfNh003377@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-06-16 at 13:27 -0400, chas williams - CONTRACTOR wrote:

Hello,

> commit 1390b21d5244dc3a8a929778ffd2fde05613c761
> Author: Eric Kinzie <ekinzie@cmf.nrl.navy.mil>
> Date:   Sat Jun 14 17:33:35 2008 -0400
> 
>     atm: [br2864] fix routed vcmux support
>     
>     From: Eric Kinzie <ekinzie@cmf.nrl.navy.mil>
>     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
> 
> diff --git a/net/atm/br2684.c b/net/atm/br2684.c
> index ac60350..05fafdc 100644
> --- a/net/atm/br2684.c
> +++ b/net/atm/br2684.c
> @@ -188,10 +188,13 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct br2684_dev *brdev,
>  				return 0;
>  			}
>  		}
> -	} else {
> -		skb_push(skb, 2);
> -		if (brdev->payload == p_bridged)
> +	} else { /* e_vc */
> +		if (brdev->payload == p_bridged) {
> +			skb_push(skb, 2);
>  			memset(skb->data, 0, 2);
> +		} else { /* p_routed */
> +			skb_pull(skb, ETH_HLEN);
> +		}
>  	}

Very old stuff sorry, but could you explain the skb_pull(skb, ETH_HLEN)
for e_vc/p_routed ?

netdevice is declared like this:

	netdev->hard_header_len = 0;
	netdev->type = ARPHRD_PPP;
	netdev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;

so there should be no ethernet header to remove.


Regards,

-- 
Maxime

