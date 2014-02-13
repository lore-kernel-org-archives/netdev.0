From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: core: introduce netif_skb_dev_features
Date: Thu, 13 Feb 2014 15:43:47 -0500 (EST)
Message-ID: <20140213.154347.1868967252351926699.davem@davemloft.net>
References: <1392064537-30646-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbaBMUnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 15:43:49 -0500
In-Reply-To: <1392064537-30646-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 10 Feb 2014 21:35:36 +0100

> @@ -2495,34 +2495,36 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
>  }
>  
>  static netdev_features_t harmonize_features(struct sk_buff *skb,
> -	netdev_features_t features)
> +					    const struct net_device *dev,
> +					    netdev_features_t features)
 ...
> -	} else if (illegal_highdma(skb->dev, skb)) {
> +	} else if (illegal_highdma(dev, skb)) {

illegal_highdma() is not prepared to take a "const struct net_device *",
you must have seen the warning in your build.  At least I did.

Please fix this and resubmit this series, thanks.
