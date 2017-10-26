From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH v6 net-next 05/12] gtp: Change to use gro_cells
Date: Thu, 26 Oct 2017 13:35:06 -0600
Message-ID: <3760392e2813ec13d37430143f83571d@codeaurora.org>
References: <20171026190929.11619-1-tom@quantonium.net>
 <20171026190929.11619-6-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pablo@netfilter.org, laforge@gnumonks.org,
        aschultz@tpip.net, netdev@vger.kernel.org, rohit@quantonium.net,
        netdev-owner@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51382 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdJZTfI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 15:35:08 -0400
In-Reply-To: <20171026190929.11619-6-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -611,6 +615,8 @@ static const struct net_device_ops gtp_netdev_ops = 
> {
> 
>  static void gtp_link_setup(struct net_device *dev)
>  {
> +	struct gtp_dev *gtp = netdev_priv(dev);
> +
>  	dev->netdev_ops		= &gtp_netdev_ops;
>  	dev->needs_free_netdev	= true;
> 
> @@ -630,6 +636,8 @@ static void gtp_link_setup(struct net_device *dev)
>  				  sizeof(struct iphdr) +
>  				  sizeof(struct udphdr) +
>  				  sizeof(struct gtp0_header);
> +
> +	gro_cells_init(&gtp->gro_cells, dev);
>  }
> 

Hi Tom

This needs a check in case the initialization failed and moved to 
ndo_init().
Eric spotted a similar bug in rmnet and vxlan.


-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project
