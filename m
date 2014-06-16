From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] net: delete duplicate dev_set_rx_mode() call
Date: Sun, 15 Jun 2014 20:05:20 -0700 (PDT)
Message-ID: <20140615.200520.1683239215774653858.davem@davemloft.net>
References: <cover.1402826534.git.panweiping3@gmail.com>
	<cover.1402826534.git.panweiping3@gmail.com>
	<f470381d8e466741c71a38e5ad396c3850d10721.1402826534.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbaFPDFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 23:05:23 -0400
In-Reply-To: <f470381d8e466741c71a38e5ad396c3850d10721.1402826534.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>
Date: Sun, 15 Jun 2014 18:05:09 +0800

> In __dev_open(), it already calls dev_set_rx_mode().
> and dev_set_rx_mode() has no effect for a net device which does not have
> IFF_UP flag set.
> 
> So the call of dev_set_rx_mode() is duplicate in __dev_change_flags().
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>
> ---
>  net/core/dev.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 30eedf6..002678f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5434,9 +5434,6 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
>  	ret = 0;
>  	if ((old_flags ^ flags) & IFF_UP) {	/* Bit is different  ? */
>  		ret = ((old_flags & IFF_UP) ? __dev_close : __dev_open)(dev);
> -
> -		if (!ret)
> -			dev_set_rx_mode(dev);
>  	}

A single line statement is what we end up with, so kill the curly braces
as they are no longer necessary.
