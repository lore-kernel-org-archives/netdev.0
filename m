From: Roland Stigge <stigge@antcom.de>
Subject: Re: [PATCH] net: lpc_eth: no need to reserve 8 extra bytes in rx
 skb
Date: Wed, 04 Apr 2012 00:54:19 +0200
Message-ID: <4F7B7F9B.3050503@antcom.de>
References: <1333490531.18626.336.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from antcom.de ([188.40.178.216]:52137 "EHLO chuck.antcom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755737Ab2DCWy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 18:54:29 -0400
In-Reply-To: <1333490531.18626.336.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 04/04/12 00:02, Eric Dumazet wrote:
> Probably a leftover from ancient code...

...

> --- a/drivers/net/ethernet/nxp/lpc_eth.c
> +++ b/drivers/net/ethernet/nxp/lpc_eth.c
> @@ -990,10 +990,10 @@ static int __lpc_handle_recv(struct net_device *ndev, int budget)
>  			ndev->stats.rx_errors++;
>  		} else {
>  			/* Packet is good */
> -			skb = dev_alloc_skb(len + 8);
> -			if (!skb)
> +			skb = dev_alloc_skb(len);

I remember this issue from the discussion, a note from Ben Hutchings
actually, where there was a further "skb_reserve(skb, 8);" in the "else"
case below. Looks like I only removed the skb_reserve().

Can't find this review from you - I hope there are no other issues left?
(Was I on CC?)

> +			if (!skb) {
>  				ndev->stats.rx_dropped++;
> -			else {
> +			} else {

Why add curly braces around a single statement?

Thanks,

Roland
