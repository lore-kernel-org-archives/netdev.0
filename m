From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fm10k: fix memory leak
Date: Wed, 18 Nov 2015 13:53:49 -0800
Message-ID: <1447883629.22599.183.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151117142427.37a4cc36@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35689 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757033AbbKRVxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 16:53:52 -0500
Received: by pacej9 with SMTP id ej9so57250186pac.2
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 13:53:51 -0800 (PST)
In-Reply-To: <20151117142427.37a4cc36@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-17 at 14:24 -0800, Stephen Hemminger wrote:
> This was detected by Coverity.
> The function skb_cow_head leaves skb alone on failure, so caller needs
> to free.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c	2015-11-17 13:33:40.032694657 -0800
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c	2015-11-17 14:13:03.086942495 -0800
> @@ -627,8 +627,10 @@ static netdev_tx_t fm10k_xmit_frame(stru
>  
>  		/* verify the skb head is not shared */
>  		err = skb_cow_head(skb, 0);
> -		if (err)
> +		if (err) {
> +			dev_kfree_skb(skb);
>  			return NETDEV_TX_OK;
> +		}
>  
>  		/* locate vlan header */
>  


kfree_skb() to be drop monitor friendly ?
