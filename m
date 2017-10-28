From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7 net-next 06/13] gtp: Change to use gro_cells
Date: Fri, 27 Oct 2017 18:00:01 -0700
Message-ID: <1509152401.11887.40.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171028000937.2631-1-tom@quantonium.net>
         <20171028000937.2631-7-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pablo@netfilter.org, laforge@gnumonks.org,
        aschultz@tpip.net, netdev@vger.kernel.org, rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:55626 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdJ1BAE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 21:00:04 -0400
Received: by mail-pg0-f53.google.com with SMTP id 15so6455043pgc.12
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 18:00:04 -0700 (PDT)
In-Reply-To: <20171028000937.2631-7-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-10-27 at 17:09 -0700, Tom Herbert wrote:
> Call gro_cells_receive instead of netif_rx.
> 

...

>  
>  static void gtp_link_setup(struct net_device *dev)
>  {
> +	struct gtp_dev *gtp = netdev_priv(dev);
> +
>  	dev->netdev_ops		= &gtp_netdev_ops;
>  	dev->needs_free_netdev	= true;
>  
> @@ -630,6 +643,8 @@ static void gtp_link_setup(struct net_device *dev)
>  				  sizeof(struct iphdr) +
>  				  sizeof(struct udphdr) +
>  				  sizeof(struct gtp0_header);
> +
> +	gro_cells_init(&gtp->gro_cells, dev);
>  }

You forgot to remove this part.
