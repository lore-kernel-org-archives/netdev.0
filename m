From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 10/11] mv643xx_eth: enable transmit time stamping.
Date: Sun, 19 Jun 2011 20:17:40 +0200
Message-ID: <20110619181740.GC3594@riccoc20.at.omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
 <1b5632e5cd90ed390245f3d1264e42fdd760dd7e.1308481492.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52677 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471Ab1FSSRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 14:17:38 -0400
Received: by fxm17 with SMTP id 17so551145fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 11:17:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1b5632e5cd90ed390245f3d1264e42fdd760dd7e.1308481492.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 19, 2011 at 01:20:06PM +0200, Richard Cochran wrote:
> This patch enables software (and phy device) transmit time stamping.
> Compile tested only.
> 
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  drivers/net/mv643xx_eth.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index a5d9b1c..c7a8f10 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -884,6 +884,8 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (!txq_submit_skb(txq, skb)) {
>  		int entries_left;
>  
> +		skb_tx_timestamp(skb);
> +
>  		txq->tx_bytes += skb->len;

And the line above is unsafe, as well.

>  		txq->tx_packets++;
>  
> -- 
> 1.7.0.4
> 
