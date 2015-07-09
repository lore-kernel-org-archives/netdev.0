From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Disable executions commands outside net_device_ops structure
Date: Fri, 10 Jul 2015 00:20:36 +0200
Message-ID: <20150709222035.GA12705@electric-eye.fr.zoreil.com>
References: <CAGg4U=FTi_qf0+bGx8Zggqade9R+LrtS5TnG0-7bJQroaR8X+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marian Corcodel <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57019 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046AbbGIWUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 18:20:49 -0400
Content-Disposition: inline
In-Reply-To: <CAGg4U=FTi_qf0+bGx8Zggqade9R+LrtS5TnG0-7bJQroaR8X+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 3df51fa..840a2ec 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -6881,7 +6881,7 @@ static void r8169_csum_workaround(struct rtl8169_private *tp,
>  			nskb = segs;
>  			segs = segs->next;
>  			nskb->next = NULL;
> -			rtl8169_start_xmit(nskb, tp->dev);
> +			//rtl8169_start_xmit(nskb, tp->dev);
>  		} while (segs);
>  
>  		dev_consume_skb_any(skb);

The original code does its best to send the data.

The suggested change drops the packet on the floor.

> @@ -6889,7 +6889,7 @@ static void r8169_csum_workaround(struct rtl8169_private *tp,
>  		if (skb_checksum_help(skb) < 0)
>  			goto drop;
>  
> -		rtl8169_start_xmit(skb, tp->dev);
> +		//rtl8169_start_xmit(skb, tp->dev);

Same thing as above.

>  	} else {
>  		struct net_device_stats *stats;
>  
> @@ -7623,7 +7623,7 @@ static int rtl_open(struct net_device *dev)
>  
>  	rtl8169_init_phy(dev, tp);
>  
> -	__rtl8169_set_features(dev, dev->features);
> +       //__rtl8169_set_features(dev, dev->features);

Did you notice the "if (features ^ dev->features)" part in
rtl8169_set_features ?

Did you check that the modified code can't miss some uninitialized bits
in CplusCmd ?

-- 
Ueimor
