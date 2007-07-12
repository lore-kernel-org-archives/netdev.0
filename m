From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] ps3: fix return value in the case of tx error
Date: Thu, 12 Jul 2007 12:27:12 -0700
Message-ID: <20070712122712.06145fa3@freepuppy.rosehill.hemminger.net>
References: <20070712154930.3DE4.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35256 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754692AbXGLT1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 15:27:54 -0400
In-Reply-To: <20070712154930.3DE4.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jul 2007 15:59:26 +0900
Masakazu Mokuno <mokuno@sm.sony.co.jp> wrote:

> 	Hi
> 	
> This patch fixes the improper return value of the hard_start_xmit()
> handler of PS3 gelic network driver.
> 
> Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> ---
>  drivers/net/ps3_gelic_net.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/drivers/net/ps3_gelic_net.c
> +++ b/drivers/net/ps3_gelic_net.c
> @@ -803,7 +803,7 @@ kick:
>  error:
>  	card->netdev_stats.tx_dropped++;
>  	spin_unlock_irqrestore(&card->tx_dma_lock, flags);
> -	return NETDEV_TX_LOCKED;
> +	return NETDEV_TX_BUSY;
>  }
>  

Wrong again. In case of error the device should free the skb
and return NETDEV_TX_OK. When you return NETDEV_TX_BUSY the
assumption is that send will be requeued. Chances are that what
ever caused the skb not to usable will continue.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
